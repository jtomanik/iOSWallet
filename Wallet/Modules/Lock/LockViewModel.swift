//
//  LockViewModel.swift
//  Wallet
//
//  Created by Jakub Tomanik on 20/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import RxSwift

protocol PinValidation {
    func validate(pin: [Int]) -> Observable<Bool>
}

enum LockState: FiniteState {

    case initial
    case pin([Int])
    case invalid
    case valid

    enum Events {
        case digit(Int)
        case validating([Int])
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
            return .pin(newDigits)

        case (.pin(let digits), .back):
            if digits.count > 0 {
                var newDigits = digits
                newDigits.removeLast()
                return .pin(newDigits)
            } else {
                return state
            }

        case (.pin, .pinValid):
            return .valid

        case (.pin, .pinInvalid):
            return .invalid

        case (_, .reset):
            return .pin([])
            
        default:
            return state
        }
    }
}

extension Modules.Lock.Output: Transformable {

    static func transform(_ state: LockState) -> Modules.Lock.Output? {
        switch state {
        case .initial:
            return .config(digits: PinLock.pinLength)
        case .pin(let digits):
            return .pin(digits: digits.count)
        case .invalid:
            return .wrongPin
        case .valid:
            return .back
        }
    }
}

class PinLock: Automata<LockState, Modules.Lock.Output>, LockViewModel {

    static let pinLength = 4

    init(validator: PinValidation) {
        super.init(
            initialState: .initial,
            reducer: LockState.reduce,
            transformer: Modules.Lock.Output.transform,
            middleware: [PinLock.middlewarePinValidation(with: validator)],
            requests: [PinLock.requestPinValidation(digits: PinLock.pinLength)])
    }

    static func middlewarePinValidation(with validator: PinValidation) -> Middleware {
        return { event -> Observable<LockState.Events> in
            guard case let .validating(input) = event else {
                return Observable.just(event)
            }
            return validator
                .validate(pin: input)
                .map { return $0 ? LockState.Events.pinValid : LockState.Events.pinInvalid }
        }
    }

    static func requestPinValidation(digits: Int) -> Request {
        return { state -> Observable<LockState.Events> in
            guard case let .pin(input) = state,
                input.count == digits else {
                return Observable.empty()
            }
            return Observable.just(LockState.Events.validating(input))
        }
    }
}
