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

import RxSwift
import RxCocoa

import AudioToolbox

class LockViewController: UIViewController {

    weak var viewModel: LockViewModel!

    private let digit0 = PinIndicator(digit: 0)
    private let digit1 = PinIndicator(digit: 1)
    private let digit2 = PinIndicator(digit: 2)
    private let digit3 = PinIndicator(digit: 3)
    private let digit4 = PinIndicator(digit: 4)
    private let digit5 = PinIndicator(digit: 5)
    private let digit6 = PinIndicator(digit: 6)
    private let digit7 = PinIndicator(digit: 7)
    private let digit8 = PinIndicator(digit: 8)
    private let digit9 = PinIndicator(digit: 9)

    private var indicators: [Indicator] = []
    private var buttonContainer: UIView!
    private var buttons: [PinIndicator] {
        return [digit0,digit1,digit2,digit3,digit4,digit5,digit6,digit7,digit8,digit9]
    }
    private let disposeBag = DisposeBag()

    init(viewModel: LockViewModel) {
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
        self.view.backgroundColor = UIColor.white
        setupPinButtons(buttons: buttons)
    }

    private func setupPinButtons(buttons: [PinIndicator]) {
        let buttonSize: CGFloat = 75
        let buttonPadding: CGFloat = 10

        let container = UIView()
        self.view.addSubview(container)
        constrain(container) { container in
            container.width == 3*buttonSize + 2*buttonPadding
            container.height == 4*buttonSize + 3*buttonPadding
            container.center == container.superview!.center
        }
        self.buttonContainer = container

        buttons.forEach {
            container.addSubview($0)
            constrain($0) { view in
                view.width  == buttonSize
                view.height == buttonSize
            }
        }

        constrain(digit1, digit4, digit7) { view1, view2, view3 in
            view1.top == view1.superview!.top
            view1.left == view1.superview!.left
            align(left: view1, view2, view3)
            distribute(by: buttonPadding, vertically: view1, view2, view3)
        }

        constrain(digit1, digit2, digit3) { view1, view2, view3 in
            align(top: view1, view2, view3)
            distribute(by: buttonPadding, horizontally: view1, view2, view3)
        }

        constrain(digit4, digit5, digit6) { view1, view2, view3 in
            align(top: view1, view2, view3)
            distribute(by: buttonPadding, horizontally: view1, view2, view3)
        }

        constrain(digit7, digit8, digit9) { view1, view2, view3 in
            align(top: view1, view2, view3)
            distribute(by: buttonPadding, horizontally: view1, view2, view3)
        }

        constrain(digit2, digit5, digit8, digit0) { view1, view2, view3, view4 in
           align(left: view1, view2, view3, view4)
           distribute(by: buttonPadding, vertically: view1, view2, view3, view4)
       }
    }

    func bindViewModel() {
        self.buttons.forEach { self.bind(button: $0) }

        self.viewModel
            .output
            .observeOn(MainScheduler.instance)
            .subscribeNext(weak: self, LockViewController.handle)
            .disposed(by: disposeBag)
    }

    private func handle(_ output: Modules.Lock.Output) {
        switch output {
        case .config(let digits):
            setupIndicators(digits)
        case .wrongPin:
            incorrectPinAnimation()
        case .pin(let digits):
            setIndicators(number: digits)
        default:
            return
        }
    }

    private func setupIndicators(_ digits: Int) {
        let indicatorSize: CGFloat = 14
        let indicatorPadding: CGFloat = 14
        let distanceToKeyPad: CGFloat = -20

        let container = UIView()
        self.view.addSubview(container)
        constrain(container, buttonContainer) { container, keyPad in
            container.width == CGFloat(digits)*indicatorSize + CGFloat(digits - 1)*indicatorPadding
            container.height == indicatorSize
            container.centerX == container.superview!.centerX
            container.bottom == keyPad.top + distanceToKeyPad
        }

        for i in 1...digits {
            let indicator = Indicator()
            indicator.backgroundColor = UIColor.clear
            container.addSubview(indicator)
            constrain(indicator) { view in
                if i == 1 {
                    view.top == view.superview!.top
                    view.left == view.superview!.left
                }
                view.width == indicatorSize
                view.height == indicatorSize
            }
            indicators.append(indicator)
        }

        constrain(indicators) { array in
            distribute(by: indicatorPadding, horizontally: array)
        }
    }

    private func setIndicators(number: Int) {
        for i in 1...indicators.count {
            indicators[i-1].needsClearBackground = i > number
        }
    }

    private func bind(button: PinIndicator) {
        digitStream(for: button)
            .subscribeNext(weak: self) { $0.viewModel.handle }
            .disposed(by: disposeBag)
    }

    private func digitStream(for button: PinIndicator) -> Observable<LockState.Events> {
        return button.digitStream.map { LockState.Events.digit($0) }
    }

    private func incorrectPinAnimation() {
        indicators.forEach { view in
            view.shake(delegate: self)
        }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }

    fileprivate func clearView() {
        indicators.forEach { view in
            view.needsClearBackground = true
        }
        viewModel.handle(LockState.Events.reset)
    }
}

// MARK: - CAAnimationDelegate
extension LockViewController: CAAnimationDelegate {
  public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    clearView()
  }
}
