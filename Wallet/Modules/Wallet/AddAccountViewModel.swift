//
//  AddAccountViewModel.swift
//  Wallet
//
//  Created by Jakub Tomanik on 22/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import RxSwift

enum AddAcountState: FiniteState {
    case initial
    case placeholder(String)
    case accountName(String, isValid: Bool)
    case adding(String)

    enum Events {
        case showFull
        case entered(String)
        case cancel
        case add
    }

    static func reduce(_ state: AddAcountState, _ event: AddAcountState.Events) -> AddAcountState {
        switch (state, event) {
        case (.initial, .showFull):
            return .placeholder("account name")
        case (_, .entered(let input)):
            return .accountName(input, isValid: validate(accountName: input))
        case (_, .cancel):
            return .initial
        case (.accountName(let name, let isValid), .add) where isValid:
            return .adding(name)
        default:
            return state
        }
    }

    static func validate(accountName: String) -> Bool {
        return accountName.count >= 12
    }
}

extension AddAcountState: Transformable {
    typealias State = AddAcountState

    static func transform(_ state: AddAcountState) -> AddAcountState? {
        return state
    }
}

class AddAccount: Automata<AddAcountState, AddAcountState>, AddAccountViewModel {
    init() {
        super.init(
            initialState: .initial,
            reducer: AddAcountState.reduce,
            transformer: AddAcountState.transform,
            middleware: nil,
            request: nil)
    }
}
