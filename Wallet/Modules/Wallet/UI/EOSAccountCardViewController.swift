//
//  CardPartTextViewCardController.swift
//  Wallet
//
//  Created by Jakub Tomanik on 18/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import CardParts

import RxSwift

struct EOSAccountCardModel: Equatable {

    struct Resource: Equatable {
        let name: String
        let utilisation: String
        let value: Int // values 0 - 100
        let used: String
        let available: String
        let staked: String?
    }

    let name: String
    let balance: String
    let value: String
    let net: Resource
    let cpu: Resource
    let ram: Resource
}

class EOSAccountCardController: CardPartsViewController {

    private let cardModel: EOSAccountCardModel

    init(cardModel: EOSAccountCardModel) {
        self.cardModel = cardModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView() {
        setupCardParts(EOSAccountCardController.build(from: cardModel))
    }
}

extension EOSAccountCardController: ShadowCardTrait {
    func shadowOffset() -> CGSize {
        return CGSize(width: 1.0, height: 1.0)
    }

    func shadowColor() -> CGColor {
        return UIColor.lightGray.cgColor
    }

    func shadowRadius() -> CGFloat {
        return 10.0
    }

    func shadowOpacity() -> Float {
        return 0.8
    }
}

extension EOSAccountCardController: RoundedCardTrait {
    func cornerRadius() -> CGFloat {
        return 10.0
    }
}

extension EOSAccountCardController {

    static func build(from model: EOSAccountCardModel) -> [CardPartView] {
        let theme = CardPartsMintTheme()
        var parts: [CardPartView] = []

        let headerView = CardPartTitleDescriptionView(titlePosition: .top, secondaryPosition: .right)
        headerView.leftTitleText = model.name
        headerView.leftTitleFont = theme.headerTextFont
        parts.append(headerView)

        let balanceLabelView = CardPartTextView(type: .normal)
        balanceLabelView.text = "balance".uppercased()
        parts.append(balanceLabelView)

        let balanceView = CardPartTitleDescriptionView(titlePosition: .top, secondaryPosition: .center(amount: 0))
        balanceView.leftTitleText = model.balance
        balanceView.leftTitleFont = theme.titleFont
        balanceView.rightTitleText = model.value
        balanceView.rightTitleFont = theme.titleFont
        parts.append(balanceView)

        parts.append(CardPartSeparatorView())
        parts.append(contentsOf: build(from: model.net))
        parts.append(CardPartSeparatorView())
        parts.append(contentsOf: build(from: model.cpu))
        parts.append(CardPartSeparatorView())
        parts.append(contentsOf: build(from: model.ram))

        return parts
    }

    fileprivate static func build(from resource: EOSAccountCardModel.Resource) -> [CardPartView] {
        let theme = CardPartsMintTheme()
        var parts: [CardPartView] = []

        let titleView = CardPartTitleDescriptionView(titlePosition: .top, secondaryPosition: .right)
        titleView.leftTitleText = resource.name.uppercased()
        titleView.leftTitleFont = theme.titleFont
        titleView.rightTitleText = resource.utilisation
        titleView.rightTitleFont = theme.titleFont
        parts.append(titleView)

        let barColours = [UIColor.colorFromHex(0xF7D2C1),
                          UIColor.colorFromHex(0xF7C4AC),
                          UIColor.colorFromHex(0xF6B698),
                          UIColor.colorFromHex(0xF49971),
                          UIColor.colorFromHex(0xF0804E),
                          UIColor.colorFromHex(0xEB6931),
                          UIColor.colorFromHex(0xE5561B),
                          UIColor.colorFromHex(0xDC450A),
                          UIColor.colorFromHex(0xD13700),
                          UIColor.colorFromHex(0xC43100),
                          UIColor.colorFromHex(0xB52A00),
                          UIColor.colorFromHex(0xA62400)]
        let usagePercent = Double(resource.value)/100
        let barView = CardPartBarView()
        let colorIndicator = Int(usagePercent.rounded())
        barView.percent = usagePercent
        barView.barColor = barColours[colorIndicator]
        parts.append(barView)

        let labelsView = CardPartTitleDescriptionView(titlePosition: .top, secondaryPosition: .center(amount: 0))
        labelsView.leftTitleText = "used".uppercased()
        labelsView.leftTitleFont = theme.detailTextFont
        labelsView.rightTitleText = "available".uppercased()
        labelsView.rightTitleFont = theme.detailTextFont
        parts.append(labelsView)

        let valuesView = CardPartTitleDescriptionView(titlePosition: .top, secondaryPosition: .center(amount: 0))
        valuesView.leftTitleText = resource.used
        valuesView.leftTitleFont = theme.titleFont
        valuesView.rightTitleText = resource.available
        valuesView.rightTitleFont = theme.titleFont
        parts.append(valuesView)

        if let staked = resource.staked {
            let stakedView = CardPartTitleDescriptionView(titlePosition: .top, secondaryPosition: .center(amount: 0))
            stakedView.leftTitleText = "staked".uppercased()
            stakedView.leftTitleFont = theme.detailTextFont
            stakedView.rightTitleText = staked
            stakedView.rightTitleFont = theme.detailTextFont
            parts.append(stakedView)
        }

        return parts
    }
}
