//
//  AddAccountCardController.swift
//  Wallet
//
//  Created by Jakub Tomanik on 22/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import CardParts

import RxSwift
import RxCocoa

class AddAccountCardController: CardPartsViewController {

    let viewModel: AddAccountViewModel

    private let disposeBag = DisposeBag()

    init(viewModel: AddAccountViewModel) {
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

    private func setupView() {
        UIApplication.shared.keyWindow?.rootViewController?.shouldDismissKeyboard()
    }

    private func bindViewModel() {
        self.viewModel
            .output
            .observeOn(MainScheduler.instance)
            .subscribeNext(weak: self, AddAccountCardController.handle)
            .disposed(by: disposeBag)
    }

    private func handle(_ output: AddAcountState) {
        switch output {
        case .initial:
            showShort()
        case .placeholder:
            showFull()
        default:
            return
        }
    }

    private func showShort() {
        setupCardParts(buildShort(), forState: .none)
        state = .none
    }

    private func showFull() {
        setupCardParts(buildFull(), forState: .hasData)
        state = .hasData
    }

    @objc fileprivate func addButtonTapped() {
        viewModel.handle(AddAcountState.Events.showFull)
    }

    @objc fileprivate func addAccountButtonTapped() {
        viewModel.handle(AddAcountState.Events.add)
    }

    @objc fileprivate func cancelAccountButtonTapped() {
        viewModel.handle(AddAcountState.Events.cancel)
    }

    @objc func tapDone() {
        self.view.endEditing(true)
    }
}

extension AddAccountCardController: ShadowCardTrait {
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

extension AddAccountCardController: RoundedCardTrait {
    func cornerRadius() -> CGFloat {
        return 10.0
    }
}

extension AddAccountCardController {

    func buildShort() -> [CardPartView] {
        let theme = CardPartsMintTheme()
        var parts: [CardPartView] = []

        let addButtonView = CardPartButtonView()
        addButtonView.setTitle("add".capitalized, for: .normal)
        addButtonView
            .rx
            .tap
            .map { AddAcountState.Events.showFull }
            .bind(onNext: viewModel.handle)
            .disposed(by: disposeBag)

        let containerView = CardPartCenteredView(leftView: CardPartStackView(), centeredView: addButtonView, rightView: CardPartStackView())
        parts.append(containerView)

        return parts
    }

    func buildFull() -> [CardPartView] {
        let theme = CardPartsMintTheme()
        var parts: [CardPartView] = []

        let titleView = CardPartTitleDescriptionView(titlePosition: .top, secondaryPosition: .right)
        titleView.leftTitleText = "add new account".capitalized
        titleView.leftTitleFont = theme.titleFont
        parts.append(titleView)

        let accountNameView = CardPartTextField(format: .none)
        accountNameView.placeholder = "account name"
        accountNameView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone))
        accountNameView
            .rx
            .text
            .filterNil()
            .map { AddAcountState.Events.entered($0) }
            .bind(onNext: viewModel.handle)
            .disposed(by: disposeBag)

        parts.append(accountNameView)

        let addButtonView = CardPartButtonView()
        addButtonView.setTitle("add".capitalized, for: .normal)
        addButtonView.contentHorizontalAlignment = .center
        addButtonView.isEnabled = false
        addButtonView
            .rx
            .tap
            .map { AddAcountState.Events.add }
            .bind(onNext: viewModel.handle)
            .disposed(by: disposeBag)

        viewModel
            .output
            .map { (account) -> Bool? in
                guard case let .accountName(_, isValid) = account else {
                    return nil
                }
                return isValid
            }
            .filterNil()
            .bind(to: addButtonView.rx.isEnabled)
            .disposed(by: disposeBag)


        let cancelButtonView = CardPartButtonView()
        cancelButtonView.setTitle("cancel".capitalized, for: .normal)
        cancelButtonView.contentHorizontalAlignment = .center
        cancelButtonView
            .rx
            .tap
            .map { AddAcountState.Events.cancel }
            .bind(onNext: viewModel.handle)
            .disposed(by: disposeBag)

        let containerView = CardPartCenteredView(leftView: addButtonView, centeredView: CardPartVerticalSeparatorView(), rightView: cancelButtonView)
        parts.append(containerView)

        return parts
    }
}
