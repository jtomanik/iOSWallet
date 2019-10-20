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
import Quick
import Nimble

class StateMachineSpec: QuickSpec {
    override func spec() {
        
        describe("StateMachine") {
            var mock:Automata<MockState, MockEvents, MockOutput>!
            var lastReducedState: MockState?
            var lastReducedEvent: MockEvents?
            var reducerInvoications = 0
            var lastTransformedState: MockState?
            var transformerInvoications = 0

            func testReducer(_ state: MockState, _ event: MockEvents) -> MockState {
                lastReducedState = state
                lastReducedEvent = event
                reducerInvoications = reducerInvoications + 1
                return MockState.reduce(state, event)
            }

            func testTransformer(_ state: MockState) -> MockOutput {
                lastTransformedState = state
                transformerInvoications = transformerInvoications + 1
                return MockOutput.transform(state)
            }

            beforeEach {
                mock = Automata<MockState, MockEvents, MockOutput>(
                    initialState: MockState.state(0),
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
                    expect(lastReducedState).to(equal(.state(0)))
                }
            }

            describe("has reducer function") {
                it("that is called for each event") {
                    mock.handle(.next(1))
                    mock.handle(.next(2))
                    expect(reducerInvoications).to(equal(2))
                    expect(lastReducedState).to(equal(.state(1)))
                    expect(lastReducedEvent).to(equal(.next(2)))
                }
            }

            describe("has transformer function") {
                it("that is called after each state change") {
                    mock.handle(.next(1))
                    mock.handle(.next(2))
                    expect(transformerInvoications).to(equal(2))
                    expect(lastTransformedState).to(equal(.state(2)))
                }
            }
        }
    }
}

enum MockEvents: Equatable {
    case next(Int)
    case skip
}

enum MockState: Equatable {
    case state(Int)

    static func reduce(_ state: MockState, _ event: MockEvents) -> MockState {
        guard case let .next(count) = event else {
            return state
        }
        return .state(count)
    }
}

enum MockOutput {
    case output(MockState)

    static func transform(_ state: MockState) -> MockOutput {
        return .output(state)
    }
}
