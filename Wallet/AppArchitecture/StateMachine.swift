//
//  StateMachine.swift
//  Wallet
//
//  Created by Jakub Tomanik on 18/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import RxSwift

// MARK: Definitions

public protocol StateMachine {

    /// Defines the state that is managed by this StateMachine.
    associatedtype State: Equatable

    /// Defines the events this StateMachine can handle.
    /// Represents all possible events that can happen in your system which can cause a transition to a new State.
    associatedtype Events

    typealias Middleware = (Events) -> Observable<Events>
    typealias Reducer = (State, Events) -> State
    typealias Request = (State) -> Observable<Events>

    func handle(_ event: Events)
}

public protocol ComposableStateMachine: StateMachine {

    /// `Output` defines the type that can be emitted as output events.
    associatedtype Output

    typealias Transform = (State) -> Output

    var output: PublishSubject<Output> { get }
}

// MARK: Implementations

public class Automata<State: Equatable, Events, Output>: ComposableStateMachine {

    public let output: PublishSubject<Output>

    private let state: BehaviorSubject<State>
    private let events: PublishSubject<Events>

    private let disposeBag = DisposeBag()

    init(
        initialState: State,
        reducer: @escaping Reducer,
        transformer: @escaping Transform,
        middleware: [Middleware] = [],
        requests: [Request] = [],
        scheduler: ImmediateSchedulerType = MainScheduler.instance) {

        self.state = BehaviorSubject(value: initialState)
        self.events = PublishSubject()
        self.output = PublishSubject()

        events
            .map { [middleware] event in Automata.sanitize(middleware).map { $0(event) } }
            .map { Observable.from($0).merge() }.merge()
            .withLatestFrom(state) { ($1, $0) }
            .map { [reducer] in reducer($0.0, $0.1) }
            .distinctUntilChanged()
            .bind(to: state)
            .disposed(by: disposeBag)

        state
            .map { [requests] state in requests.map { $0(state) } }
            .map { Observable.from($0).merge() }.merge()
            .bind(to: events)
            .disposed(by: disposeBag)

        state
            .map { [transformer] state in transformer(state) }
            .bind(to: output)
            .disposed(by: disposeBag)
    }

    public func handle(_ event: Events) {
        events.on(.next(event))
    }

    private static func sanitize(_ array: [Middleware]) -> [Middleware] {
        guard !array.isEmpty else {
            func passthru(_ event: Events) -> Observable<Events> {
                return Observable.just(event)
            }

            return [passthru]
        }

        return array
    }
}
