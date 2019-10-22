//
//  WalletViewModel.swift
//  Wallet
//
//  Created by Jakub Tomanik on 21/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import RxSwift

typealias EOSAccountName = String

protocol AccountInfoProvider: class {
    func fetch(for accountName: String) -> Observable<EOSAccountResponse>
}

protocol PriceFeedProvider: class {
    func fetch() -> Observable<Double>
}

enum WalletState: FiniteState {
    case initial
    case accounts([EOSAccountCardModel])

    enum Events {
        case skip
        case add(accountName: String)
        case fetched(EOSAccountCardModel)
        case error
//        case remove(accountName: String)
    }

    static func reduce(_ state: WalletState, _ event: WalletState.Events) -> WalletState {
        switch (state, event) {
        case (.initial, .fetched(let model)):
            return .accounts([model])
        case (.accounts(let models), .fetched(let model)):
            var newModels = models
            newModels.append(model)
            return .accounts(newModels)
        case (_, .error):
            return .initial
        default:
            return state
        }
    }
}

extension Modules.Wallet.Output: Transformable {
    typealias State = WalletState

    static func transform(_ state: WalletState) -> Modules.Wallet.Output? {
        switch state {
        case .initial:
            return .list([])
        case .accounts(let models):
            return .list(models)
        }
    }
}

class WalletCollection: Automata<WalletState, Modules.Wallet.Output>, WalletViewModel {

    let addAccountViewModel: AddAccountViewModel

    init(addAccountViewModel: AddAccountViewModel,
         accountFetcher: AccountInfoProvider,
         priceFetcher: PriceFeedProvider) {

        self.addAccountViewModel = addAccountViewModel

        super.init(
            initialState: .initial,
            reducer: WalletState.reduce,
            transformer: Modules.Wallet.Output.transform,
            middleware: WalletCollection.middlewareFetchingAccount(accountFetcher: accountFetcher, priceFetcher: priceFetcher),
            request: WalletCollection.requestAddingAccount(addAccountViewModel: addAccountViewModel))
    }

    static func middlewareFetchingAccount(accountFetcher: AccountInfoProvider, priceFetcher: PriceFeedProvider) -> Middleware {
        var lastEvent: WalletState.Events?

        return { event -> Observable<WalletState.Events> in
            guard case let .add(accountName) = event else {
                return Observable.just(event)
            }

            if let last = lastEvent,
                case let .add(oldAccountName) = last,
                accountName == oldAccountName {
                    return Observable.just(.skip)
            }
            lastEvent = event
            let account = accountFetcher.fetch(for: accountName)
            let price = priceFetcher.fetch()

            return Observable
                .combineLatest(account, price)
                .observeOn(MainScheduler.instance)
                .map { $0.0.toCardModel(withRate: $0.1) }
                .filterNil()
                .map { WalletState.Events.fetched($0) }
                .catchErrorJustReturn(WalletState.Events.error)
                .take(1)
        }
    }

    static func requestAddingAccount(addAccountViewModel: AddAccountViewModel) -> Request {
        return { state -> Observable<WalletState.Events> in
            return addAccountViewModel
                .output
                .distinctUntilChanged()
                .map { (addAccountState) -> WalletState.Events? in
                    if case let .adding(name) = addAccountState {
                        return .add(accountName: name)
                    }
                    return nil
                }
                .filterNil()
        }
    }
}

fileprivate extension EOSAccountResponse {

    var normalisedCoreLiquidBalance: String {
        if coreLiquidBalance.count == 0 {
            return "0 EOS"
        }
        return coreLiquidBalance
    }

    var normalisedCoreLiquidBalanceValue: Double {
        let stringValue = normalisedCoreLiquidBalance.replacingOccurrences(of: " EOS", with: "")
        let value = Double(stringValue) ?? 0.0
        return value
    }

    func toCardModel(withRate rate: Double = 0.0 ) -> EOSAccountCardModel? {

        func format(_ double: Double) -> String {
            return String(format: "%.2f", double)
        }

        func format(_ value: Int64, divider: Int64, unit: String) -> String {
            return "\(format(Double(value/divider))) \(unit)"
        }

        func format(_ value: Double, rate: Double, symbol: String) -> String {
            return "\(format(Double(value * rate))) \(symbol)"
        }

        func percent(_ a: Int64, _ b: Int64) -> Int {
            let value =  Int((100*a/b))
            return value
        }

        func usage(_ a: Int64, _ b: Int64) -> String {
            return "\(percent(a, b))%"
        }

        return EOSAccountCardModel(
            name: accountName,
            balance: normalisedCoreLiquidBalance,
            value: "≈ \(format(normalisedCoreLiquidBalanceValue, rate: rate, symbol: "$"))",
            net: EOSAccountCardModel.Resource(name: "NET",
                                              utilisation: usage(netLimit.used.value, netLimit.max.value),
                                              value: percent(netLimit.used.value, netLimit.max.value),
                                              used: format(netLimit.used.value, divider: 1, unit: ""),
                                              available: format(netLimit.max.value, divider: 1024, unit: "KB"),
                                              staked: totalResources?.netWeight),
            cpu: EOSAccountCardModel.Resource(name: "CPU",
                                              utilisation: usage(cpuLimit.used.value,cpuLimit.max.value),
                                              value: percent(cpuLimit.used.value,cpuLimit.max.value),
                                              used: format(cpuLimit.used.value, divider: 1, unit: ""),
                                              available: format(cpuLimit.max.value, divider: 1000, unit: "ms"),
                                              staked: totalResources?.cpuWeight),
            ram: EOSAccountCardModel.Resource(name: "RAM",
                                              utilisation: usage(ramUsage.value, ramQuota.value),
                                              value: percent(ramUsage.value, ramQuota.value),
                                              used: format(ramUsage.value, divider: 1024, unit: "KB"),
                                              available: format(ramQuota.value, divider: 1024, unit: "KB"),
                                              staked: nil))
    }
}
