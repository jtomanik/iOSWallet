//
//  AppDelegate.swift
//  Wallet
//
//  Created by Jakub Tomanik on 18/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import UIKit
import CardParts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: RootWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        WalletTheme().apply()
        
        container.register(RootViewPresenting.self) { _ in
            return self
        }.inObjectScope(.container)

        window = Modules.Root.make()
        window?.viewModel.handle(.start)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        window?.viewModel.handle(.lock)
    }
}

extension AppDelegate: RootViewPresenting {

    func show(_ vc: UIViewController) {
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }

    func present(_ vc: UIViewController) {
        vc.modalPresentationStyle = .fullScreen
        window?.rootViewController?.present(vc, animated: false, completion: nil)
    }

    func dismiss() {
        window?.rootViewController?.dismiss(animated: false, completion: nil)
    }
}

