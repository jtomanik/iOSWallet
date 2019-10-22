//
//  Container.swift
//  Wallet
//
//  Created by Jakub Tomanik on 20/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import Swinject

let container: Container = {
    return setupDependencies()
}()

fileprivate func setupDependencies() -> Container {
    let container = Container()

    container.register(NetworkRequestProvider.self) { _ in
        NetworkRequester()
    }.inObjectScope(.container)

    container.register(AccountInfoProvider.self) { r in
        AccountInfo(network: r.resolve(NetworkRequestProvider.self)!)
    }.inObjectScope(.container)

    container.register(PriceFeedProvider.self) { r in
        PriceFeed(network: r.resolve(NetworkRequestProvider.self)!)
    }.inObjectScope(.container)

    return container
}
