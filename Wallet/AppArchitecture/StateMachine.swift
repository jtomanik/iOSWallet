//
//  StateMachine.swift
//  Wallet
//
//  Created by Jakub Tomanik on 18/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import RxSwift
import RxOptional

// MARK: Definitions

public protocol FiniteState: Equatable {

    /// Represents all possible events that can happen in your system which can cause a transition to a new State.
    associatedtype Events

    static func reduce(_ state: Self, _ event: Events) -> Self
}

public protocol StateMachine {

    /// Defines the state that is managed by this StateMachine.
    associatedtype State: FiniteState

    /// Defines the events this StateMachine can handle.

    typealias Middleware = (State.Events) -> Observable<State.Events>
    typealias Reducer = (State, State.Events) -> State
    typealias Request = (State) -> Observable<State.Events>

    var events: PublishSubject<State.Events> { get }

    func handle(_ event: State.Events)
}

public protocol Transformable: Equatable {
    associatedtype State: FiniteState
    static func transform(_ state: State) -> Self?
}

public protocol ComposableStateMachine: StateMachine {

    /// `Output` defines the type that can be emitted as output events.
    associatedtype Output: Transformable

    typealias Transform = (State) -> Output?

    var output: ReplaySubject<Output> { get }
}

// MARK: Implementations

public class Automata<State: FiniteState, Output: Transformable>: ComposableStateMachine {

    public let output: ReplaySubject<Output>
    public let events: PublishSubject<State.Events>

    private let state: BehaviorSubject<State>
    private let middleware: Middleware
    private let request: Request
    private let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
    private let disposeBag = DisposeBag()

    init(
        initialState: State,
        reducer: @escaping Reducer,
        transformer: @escaping Transform,
        middleware: Middleware? = nil,
        request: Request? = nil,
        scheduler: ImmediateSchedulerType = MainScheduler.instance) {

        self.state = BehaviorSubject(value: initialState)
        self.events = PublishSubject()
        self.output = ReplaySubject.create(bufferSize: 1)

        self.middleware = middleware ?? { event in return Observable.just(event) }
        self.request = request ?? { _ in return Observable.empty() }

        events
            .flatMap { self.middleware($0) }
            .observeOn(MainScheduler.asyncInstance)
            .withLatestFrom(state) { ($1, $0) }
            .map { [reducer] in reducer($0.0, $0.1) }
            .distinctUntilChanged()
            .bind(to: state)
            .disposed(by: disposeBag)

        state
            .flatMap { self.request($0) }
            .bind(to: events)
            .disposed(by: disposeBag)

        state
            .map { [transformer] state in transformer(state) }
            .filterNil()
            .distinctUntilChanged()
            .bind(to: output)
            .disposed(by: disposeBag)
    }

    public func handle(_ event: State.Events) {
        events.on(.next(event))
    }
}
