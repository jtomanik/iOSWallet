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

protocol RootViewPresenting {
    func show(_ vc: UIViewController)
    func present(_ vc: UIViewController)
    func dismiss()
}

protocol RootNavigator {
    func navigate(_ flow: Modules.Root.Routes)
}

protocol RootViewModel {
    var output: ReplaySubject<Modules.Root.Routes> { get }
    func handle(_ event: UserSessionState.Events)
}

extension Modules {

    struct Root {
        
        enum Routes: Equatable {
            case mainUI(fromLock: Bool)
            case lockedUI
        }
    }
}

extension Modules.Root {

    static func make() -> RootWindow {

        container.register(RootViewModel.self) { _ in
            UserSession()
        }.inObjectScope(.container)

        let vm = container.resolve(RootViewModel.self)!
        vm.output
            .observeOn(MainScheduler.instance)
            .bind(onNext: Modules.Root.navigate)

        let bounds = UIScreen.main.bounds
        let window = RootWindow(frame: bounds,
                                viewModel: vm)
        window.backgroundColor = UIColor.white
        return window
    }

    static func navigate(_ flow: Modules.Root.Routes) {
        guard let parentFlow = container.resolve(RootViewPresenting.self),
            let vm = container.resolve(RootViewModel.self) else {
            fatalError("Could not resolve dependency")
        }

        switch flow {
        case .mainUI(let isFromLock):
            if isFromLock {
                vm.handle(UserSessionState.Events.unlock)
                parentFlow.dismiss()
            } else {
                parentFlow.show(Modules.Wallet.make())
            }
        case .lockedUI:
            parentFlow.present(Modules.Lock.make())
        }
    }
}

