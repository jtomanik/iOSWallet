//
//  LockViewModel.swift
//  Wallet
//
//  Created by Jakub Tomanik on 20/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation

enum LockState: FiniteState {

    static let pinLength = 1

    case initial
    case pin([Int])
    case validating([Int])
    case invalid
    case valid

    enum Events {
        case digit(Int)
        case back
        case reset
        case pinValid
        case pinInvalid
//        case biometrics
    }

    static func reduce(_ state: LockState, _ event: LockState.Events) -> LockState {
        switch (state, event) {
        case (.initial, .digit(let i)):
            return .pin([i])

        case (.pin(let digits), .digit(let i)):
            var newDigits = digits
            newDigits.append(i)
            if digits.count <= LockState.pinLength - 1 {
                return .pin(newDigits)
            } else {
                return .validating(newDigits)
            }

        case (.pin(let digits), .back):
            if digits.count > 0 {
                var newDigits = digits
                newDigits.removeLast()
                return .pin(newDigits)
            } else {
                return state
            }

        case (.validating, .pinValid):
            return .valid

        case (.validating, .pinInvalid):
            return .invalid

        case (_, .reset):
            return .initial
            
        default:
            return state
        }
    }
}

extension Modules.Lock.Routes: Transformable {

    static func transform(_ state: LockState) -> Modules.Lock.Routes? {
        switch state {
        case .initial:
            return .config(digits: LockState.pinLength)
        case .valid:
            return .back
        default:
            return nil
        }
    }
}

class PinLock: Automata<LockState, Modules.Lock.Routes>, LockViewModel {

    init() {
        super.init(
            initialState: .initial,
            reducer: LockState.reduce,
            transformer: Modules.Lock.Routes.transform)
    }
}
