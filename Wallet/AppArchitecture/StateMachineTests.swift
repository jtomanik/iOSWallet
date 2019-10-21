//
//  StateMachineTests.swift
//  WalletTests
//
//  Created by Jakub Tomanik on 19/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

@testable import Wallet

import RxSwift
import RxTest
import RxBlocking
import Quick
import Nimble

/**
    flow:
        .state([])              // initial state
        call transform()    -> .output(.state([]))
        call request()
        .next(1)
        call reducer()      -> .state([1])
        .state([1])
        call transform()    -> .output(.state([1]))
        call request()
        .next(2)
        call reducer()      -> .state([1,2])
        .state([1,2])
        call transform()    -> .output(.state([1,2]))
        call request()       -> .next(3)
        .next(3)                // injected by the Request
        call reducer()      -> .state([1,2,3])
        .state([1,2,3])
        call transform()    -> .output(.state([1,2,3]))
        call request()
 */

class StateMachineSpec: QuickSpec {
    override func spec() {

        let backgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .background)

        describe("StateMachine") {
            var mock:Automata<MockState, MockOutput>!
            var lastReducedState: MockState?
            var lastReducedEvent: MockState.Events?
            var reducerInvoications = 0
            var lastTransformedState: MockState?
            var transformerInvoications = 0
            var lastRequestedState: MockState?
            var requestInvoications = 0
            var lastMiddlewareEvent: MockState.Events?
            var middlewareInvoications = 0

            func testReducer(_ state: MockState, _ event: MockState.Events) -> MockState {
                lastReducedState = state
                lastReducedEvent = event
                reducerInvoications += 1

                return MockState.reduce(state, event)
            }

            func testTransformer(_ state: MockState) -> MockOutput? {
                lastTransformedState = state
                transformerInvoications += 1

                return MockOutput.transform(state)
            }

            func testRequest(_ state: MockState) -> Observable<MockState.Events> {
                lastRequestedState = state
                requestInvoications += 1

                guard case .state(let stack) = state,
                    stack.count == 2,
                    let value = stack.last else {
                        return Observable.empty()
                }
                let random = Int.random(in: 2..<10)
                let randomDelay = Double(1/random)
                return Observable
                    .just(.next(value+1))
                    .delay(randomDelay, scheduler: backgroundScheduler)
                    .debug()
            }

            func testMiddleware(_ event: MockState.Events) -> Observable<MockState.Events> {
                lastMiddlewareEvent = event
                middlewareInvoications += 1

                guard case .trigger(let value) = event else {
                        return Observable.just(event)
                }
                let random = Int.random(in: 2..<10)
                let randomDelay = Double(1/random)
                return Observable
                    .just(.next(value+1))
                    .delay(randomDelay, scheduler: backgroundScheduler)
                    .debug()
            }

            beforeEach {
                mock = Automata<MockState, MockOutput>(
                    initialState: MockState.state([]),
                    reducer: testReducer,
                    transformer: testTransformer,
                    middleware: [],
                    requests: []
                )

                lastReducedState = nil
                lastReducedEvent = nil
                reducerInvoications = 0
                lastTransformedState = nil
                transformerInvoications = 0
                lastRequestedState = nil
                requestInvoications = 0
                lastMiddlewareEvent = nil
                middlewareInvoications = 0
            }

            describe("has initial state") {
                it("that is properly initialised") {
                    mock.handle(.next(1))
                    sleep(1)
                    
                    expect(reducerInvoications).to(equal(1))
                    expect(lastReducedState).to(equal(.state([])))
                }
            }

            describe("has Reducer function") {
                it("that is called for each event") {
                    mock.handle(.next(1))
                    mock.handle(.next(2))
                    sleep(1)

                    expect(reducerInvoications).to(equal(2))
                    expect(lastReducedState).to(equal(.state([1])))
                    expect(lastReducedEvent).to(equal(.next(2)))
                }
            }

            describe("has Transformer function") {
                it("that is called after each state change") {
                    mock.handle(.next(1))
                    mock.handle(.next(2))
                    sleep(1)

                    expect(transformerInvoications).to(equal(2))
                    expect(lastTransformedState).to(equal(.state([1,2])))
                }

                it("that transforms state into the output") {
                    mock.handle(.next(1))
                    mock.handle(.next(2))
                    sleep(1)

                    let result = try! mock.output.asObservable().toBlocking().first()
                    expect(result).to(equal(.output(.state([1,2]))))
                }
            }

            describe("can have Request functions") {

                beforeEach {
                    mock = Automata<MockState, MockOutput>(
                        initialState: MockState.state([]),
                        reducer: testReducer,
                        transformer: testTransformer,
                        middleware: [],
                        requests: [testRequest]
                    )
                }

                it("which are called after each state change") {
                    mock.handle(.next(1))

                    // requests are being called an a differnt thread we need to wait for them to finish
                    // in order to properly update test variables
                    sleep(2)

                    expect(requestInvoications).to(equal(2))
                    expect(lastRequestedState).to(equal(.state([1])))

                    expect(reducerInvoications).to(equal(1))
                    expect(lastReducedState).to(equal(.state([])))
                    expect(lastReducedEvent).to(equal(.next(1)))

                    expect(transformerInvoications).to(equal(2))
                    expect(lastTransformedState).to(equal(.state([1])))
                }

                it("which can inject new events to be processed") {
                    mock.handle(.next(1))
                    mock.handle(.next(2))

                    // requests are being called an a differnt thread we need to wait for them to finish
                    // in order to properly update test variables
                    sleep(4)

                    expect(requestInvoications).to(equal(4))
                    expect(lastRequestedState).to(equal(.state([1,2,3])))

                    expect(reducerInvoications).to(equal(3))
                    expect(lastReducedState).to(equal(.state([1,2])))
                    expect(lastReducedEvent).to(equal(.next(3)))

                    expect(transformerInvoications).to(equal(4))
                    expect(lastTransformedState).to(equal(.state([1,2,3])))
                }
            }

            describe("can have Middleware functions") {

                beforeEach {
                    mock = Automata<MockState, MockOutput>(
                        initialState: MockState.state([]),
                        reducer: testReducer,
                        transformer: testTransformer,
                        middleware: [testMiddleware],
                        requests: []
                    )
                }

                it("which are called after each new event change") {
                    mock.handle(.next(1))

                    // requests are being called an a differnt thread we need to wait for them to finish
                    // in order to properly update test variables
                    sleep(2)

                    expect(middlewareInvoications).to(equal(1))
                    expect(lastMiddlewareEvent).to(equal(.next(1)))

                    expect(reducerInvoications).to(equal(1))
                    expect(lastReducedState).to(equal(.state([])))
                    expect(lastReducedEvent).to(equal(.next(1)))
                }

                it("which can inject new events to be processed") {
                    mock.handle(.next(1))
                    mock.handle(.trigger(1))

                    // requests are being called an a differnt thread we need to wait for them to finish
                    // in order to properly update test variables
                    sleep(4)

                    expect(middlewareInvoications).to(equal(2))
                    expect(lastMiddlewareEvent).to(equal(.trigger(1)))

                    expect(reducerInvoications).to(equal(2))
                    expect(lastReducedState).to(equal(.state([1])))
                    expect(lastReducedEvent).to(equal(.next(2)))
                }
            }
        }
    }
}

enum MockState: FiniteState {

    case state([Int])

    enum Events: Equatable {
        case next(Int)
        case skip
        case trigger(Int)
    }

    static func reduce(_ state: MockState, _ event: Events) -> MockState {
        guard case let .next(value) = event else {
            return state
        }
        switch state {
        case let .state(stack):
            var newStack = stack
            newStack.append(value)
            return .state(newStack)
        }
    }
}

enum MockOutput: Transformable, Equatable {

    case output(MockState)

    static func transform(_ state: MockState) -> MockOutput? {
        return .output(state)
    }
}
