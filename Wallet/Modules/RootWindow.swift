//
//  RootWindow.swift
//  Wallet
//
//  Created by Jakub Tomanik on 20/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class RootWindow: UIWindow {

    let viewModel: RootViewModel

    private let disposeBag = DisposeBag()

    init(frame: CGRect, viewModel: RootViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
