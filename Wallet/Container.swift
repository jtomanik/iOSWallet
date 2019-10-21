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
    return container
}
