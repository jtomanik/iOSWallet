//
//  Lock.swift
//  Wallet
//
//  Created by Jakub Tomanik on 20/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol LockViewPresenting: ViewPresenting {}

protocol LockNavigator {
    func navigate(_ flow: Modules.Lock.Routes)
}

protocol LockViewModel {
    var output: ReplaySubject<Modules.Lock.Routes> { get }
    func handle(_ event: LockState.Events)
}

extension Modules {

    struct Lock {

        enum Routes {
            case config(digits: Int)
            case back
        }
    }
}

extension Modules.Lock {

    static func make() -> UIViewController {
        let vc = LockViewController()
        return vc
    }
}

struct LockFlowController: LockNavigator {

    let parentFlow: RootViewPresenting

    func navigate(_ flow: Modules.Lock.Routes) {
        switch flow {
        case .back:
            parentFlow.dismiss()
        default:
            return
        }
    }
}
