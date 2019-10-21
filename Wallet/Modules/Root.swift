//
//  Root.swift
//  Wallet
//
//  Created by Jakub Tomanik on 20/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol RootViewPresenting: ViewPresenting {}

protocol RootNavigator {
    func navigate(_ flow: Modules.Root.Routes)
}

protocol RootViewModel {
    var output: ReplaySubject<Modules.Root.Routes> { get }
    func handle(_ event: UserSessionState.Events)
}

extension Modules {

    struct Root {
        
        enum Routes {
            case mainUI
            case lockedUI
        }
    }
}

extension Modules.Root {

    static func make() -> RootWindow {

        container.register(RootViewModel.self) { _ in
            UserSession()
        }.inObjectScope(.container)

        container.register(RootNavigator.self) { r in
            RootFlowController(parentFlow: r.resolve(RootViewPresenting.self)!)
        }.inObjectScope(.container)

        let bounds = UIScreen.main.bounds
        let window = RootWindow(frame: bounds,
                                viewModel: container.resolve(RootViewModel.self)!,
                                navigator: container.resolve(RootNavigator.self)!)
        window.backgroundColor = UIColor.white
        return window
    }
}

struct RootFlowController: RootNavigator {

    let parentFlow: RootViewPresenting

    func navigate(_ flow: Modules.Root.Routes) {
        switch flow {
        case .mainUI:
            parentFlow.dismiss()
            parentFlow.show(Modules.Wallet.make())
        case .lockedUI:
            parentFlow.present(Modules.Lock.make())
        }
    }
}

