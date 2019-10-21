//
//  Wallet.swift
//  Wallet
//
//  Created by Jakub Tomanik on 20/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import UIKit

extension Modules {

    struct Wallet {
    }
}

extension Modules.Wallet {

    static func make() -> UIViewController {
        return MainViewController()
    }
}
