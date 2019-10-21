//
//  Architecture.swift
//  Wallet
//
//  Created by Jakub Tomanik on 20/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import UIKit

protocol ViewPresenting {
    func show(_ vc: UIViewController)
    func present(_ vc: UIViewController)
    func dismiss()
}
