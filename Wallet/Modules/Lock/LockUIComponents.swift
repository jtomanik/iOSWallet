//
//  LockUIComponents.swift
//  Wallet
//
//  Created by Jakub Tomanik on 20/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import UIKit

class Indicator: UIView {
    var isNeedClear = false
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawCircle(rect)
    }
}

class PinIndicator: UIButton {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawCircle(rect)
    }
}

extension UIView {
    func drawCircle(_ rect:CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {return}
        let rect = CGRect(x: rect.origin.x+0.5,
                          y: rect.origin.y+0.5,
                          width: rect.width-1.5,
                          height: rect.height-1.5)

        context.setLineWidth(1)
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.strokeEllipse(in: rect)
    }

    func shake(delegate: CAAnimationDelegate) {
        let animationKeyPath = "transform.translation.x"
        let shakeAnimation = "shake"
        let duration = 0.6
        let animation = CAKeyframeAnimation(keyPath: animationKeyPath)
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = duration
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        animation.delegate = delegate
        layer.add(animation, forKey: shakeAnimation)
    }
}
