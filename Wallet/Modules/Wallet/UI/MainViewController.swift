//
//  MainViewController.swift
//  Wallet
//
//  Created by Jakub Tomanik on 18/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import UIKit
import CardParts

import RxSwift
import RxCocoa

class WalletViewController: CardsViewController {

    let viewModel: WalletViewModel

    private let disposeBag = DisposeBag()

    init(viewModel: WalletViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        bindViewModel()
    }

    func setupView() {
        loadCards(cards: [])
    }

    func bindViewModel() {
        self.viewModel
            .output
            .observeOn(MainScheduler.instance)
            .subscribeNext(weak: self, WalletViewController.handle)
            .disposed(by: disposeBag)
    }

    private func handle(_ output: Modules.Wallet.Output) {
        var cards: [CardPartsViewController] = []
        switch output {
        case .list(let accounts):
            let accountCards = accounts.map { EOSAccountCardController(cardModel: $0) }
            cards.append(contentsOf: accountCards)
            cards.append(AddAccountCardController(viewModel: viewModel.addAccountViewModel))
            viewModel.addAccountViewModel.handle(AddAcountState.Events.cancel)
        }
        loadCards(cards: cards)
    }
}
