//
//  Wallet.swift
//  Wallet
//
//  Created by Jakub Tomanik on 20/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol WalletViewModel {
    var output: ReplaySubject<Modules.Wallet.Output> { get }
    var addAccountViewModel: AddAccountViewModel { get }

    func handle(_ event: WalletState.Events)
}

protocol AddAccountViewModel {
    var output: ReplaySubject<AddAcountState> { get }
    func handle(_ event: AddAcountState.Events)
}

extension Modules {

    struct Wallet {

        enum Output: Equatable {
            case list([EOSAccountCardModel])
        }
    }
}

extension Modules.Wallet {

    static func make() -> UIViewController {
        let vm = WalletCollection(addAccountViewModel: AddAccount(),
                                  accountFetcher: container.resolve(AccountInfoProvider.self)!,
                                  priceFetcher: container.resolve(PriceFeedProvider.self)!)
        let vc = WalletViewController(viewModel: vm)
        return vc
    }
}
