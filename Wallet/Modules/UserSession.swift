//
//  UserSession.swift
//  Wallet
//
//  Created by Jakub Tomanik on 20/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation

enum UserSessionState: FiniteState {
    case loading
    case unlocked(fromLock: Bool)
    case locked

    enum Events {
        case start
        case lock
        case unlock
    }

    static func reduce(_ state: UserSessionState, _ event: UserSessionState.Events) -> UserSessionState {
        switch (state, event) {
        case (.loading, .start):
            return .unlocked(fromLock: false)
        case (_ , .lock):
            return .locked
        case (_ , .unlock):
            return .unlocked(fromLock: true)
        default:
            return state
        }
    }
}

extension Modules.Root.Routes: Transformable {
    typealias State = UserSessionState
    
    static func transform(_ state: UserSessionState) -> Modules.Root.Routes? {
        switch state {
        case .unlocked(let isFromLock):
            return .mainUI(fromLock: isFromLock)
        case .locked:
            return .lockedUI
        default:
            return nil
        }
    }
}

class UserSession: Automata<UserSessionState, Modules.Root.Routes>, RootViewModel {

    init() {
        super.init(
            initialState: .loading,
            reducer: UserSessionState.reduce,
            transformer: Modules.Root.Routes.transform)
    }
}
