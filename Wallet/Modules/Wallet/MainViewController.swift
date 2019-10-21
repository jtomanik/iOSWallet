//
//  MainViewController.swift
//  Wallet
//
//  Created by Jakub Tomanik on 18/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import UIKit
import CardParts

class MainViewController: CardsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Comment out one of the CardPartViewController in the card Array to change cards and/or their order
        let cards: [CardPartsViewController] = [
            CardPartTextViewCardController(), // Text
        ]

        loadCards(cards: cards)
    }
}
