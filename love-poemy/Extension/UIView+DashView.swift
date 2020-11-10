//
//  UIView+DashView.swift
//  love-poemy
//
//  Created by 野中志保 on 2020/05/03.
//  Copyright © 2020 野中志保. All rights reserved.
//

import UIKit

// 画面幅の破線を描く
extension UIView {
    func drawDashedLine(color: UIColor, lineWidth: CGFloat, lineSize: NSNumber, spaceSize: NSNumber) {
        let screenRect = UIScreen.main.bounds
        let dashedLineLayer: CAShapeLayer = CAShapeLayer()
        dashedLineLayer.frame = screenRect
        dashedLineLayer.strokeColor = color.cgColor
        dashedLineLayer.lineWidth = lineWidth
        dashedLineLayer.lineDashPattern = [lineSize, spaceSize]
        let path: CGMutablePath = CGMutablePath()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        // 左右のマージンを抜いた画面幅の分破線を引く
        path.addLine(to: CGPoint(x: screenRect.size.width-40, y: 0.0))
        dashedLineLayer.path = path
        self.layer.addSublayer(dashedLineLayer)
    }
}

