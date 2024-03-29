//
//  PinValidator.swift
//  Wallet
//
//  Created by Jakub Tomanik on 21/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import RxSwift

struct PinValidator: PinValidation {

    private let secret = [1,2,3,4]

    func validate(pin: [Int]) -> Observable<Bool> {
        return Observable.just(pin == secret)
    }
}
