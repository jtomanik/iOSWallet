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

class StateMachineSpec: QuickSpec {
    override func spec() {
        
        describe("StateMachine") {
            var mock:Automata<MockState, MockOutput>!
            var lastReducedState: MockState?
            var lastReducedEvent: MockState.Events?
            var reducerInvoications = 0
            var lastTransformedState: MockState?
            var transformerInvoications = 0

            func testReducer(_ state: MockState, _ event: MockState.Events) -> MockState {
                lastReducedState = state
                lastReducedEvent = event
                reducerInvoications = reducerInvoications + 1
                return MockState.reduce(state, event)
            }

            func testTransformer(_ state: MockState) -> MockOutput? {
                lastTransformedState = state
                transformerInvoications = transformerInvoications + 1
                return MockOutput.transform(state)
            }

            beforeEach {
                mock = Automata<MockState, MockOutput>(
                    initialState: MockState.state([]),
                    reducer: testReducer,
                    transformer: testTransformer)

                lastReducedState = nil
                lastReducedEvent = nil
                reducerInvoications = 0
                lastTransformedState = nil
                transformerInvoications = 0
            }

            describe("has initial state") {
                it("that is properly initialised") {
                    mock.handle(.next(1))
                    expect(lastReducedState).to(equal(.state([])))
                }
            }

            describe("has reducer function") {
                it("that is called for each event") {
                    mock.handle(.next(1))
                    mock.handle(.next(2))
                    expect(reducerInvoications).to(equal(2))
                    expect(lastReducedState).to(equal(.state([1])))
                    expect(lastReducedEvent).to(equal(.next(2)))
                }
            }

            describe("has transformer function") {

                it("that is called after each state change") {
                    mock.handle(.next(1))
                    mock.handle(.next(2))
                    expect(transformerInvoications).to(equal(2))
                    expect(lastTransformedState).to(equal(.state([1,2])))
                }

                it("that transforms state into the output") {
                    mock.handle(.next(1))
                    mock.handle(.next(2))
                    let result = try! mock.output.asObservable().toBlocking().first()
                    expect(result).to(equal(.output(.state([1,2]))))
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
