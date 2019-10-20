//
//  CardPartTextViewCardController.swift
//  Wallet
//
//  Created by Jakub Tomanik on 18/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import CardParts

class CardPartTextViewCardController: CardPartsViewController {

    let cardPartTextView = CardPartTextView(type: .normal)

    override func viewDidLoad() {
        super.viewDidLoad()

        cardPartTextView.text = "This is a CardPartTextView"

        setupCardParts([cardPartTextView])
    }
}
