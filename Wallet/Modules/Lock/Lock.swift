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

protocol LockViewModel {
    var output: ReplaySubject<Modules.Lock.Output> { get }
    func handle(_ event: LockState.Events)
}

extension Modules {

    struct Lock {

        enum Output: Equatable {
            case config(digits: Int)
            case pin(digits: Int)
            case wrongPin
            case back
        }
    }
}

extension Modules.Lock {

    static func make() -> UIViewController {
        let vm = PinLock(validator: PinValidator())

        vm.output
            .observeOn(MainScheduler.instance)
            .map { Modules.Lock.translate(route: $0) }
            .filterNil()
            .bind(onNext: Modules.Root.navigate)

        let vc = LockViewController(viewModel: vm)
        return vc
    }

    private static func translate(route: Modules.Lock.Output) -> Modules.Root.Routes? {
        guard case .back = route else {
            return nil
        }

        return .mainUI
    }
}
