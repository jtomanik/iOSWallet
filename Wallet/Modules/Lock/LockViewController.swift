//
//  LockViewController.swift
//  Wallet
//
//  Created by Jakub Tomanik on 20/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import UIKit
import Cartography

class LockViewController: UIViewController {

    let button = PinIndicator()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private func setupView() {
        self.view.backgroundColor = UIColor.white

        self.view.addSubview(button)
        button.setTitle("1", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        constrain(button) { view in
            view.width  == 75
            view.height == 75
            view.center == view.superview!.center
        }
    }
}
