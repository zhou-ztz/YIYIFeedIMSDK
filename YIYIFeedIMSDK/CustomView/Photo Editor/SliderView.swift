//
//  SliderView.swift
//  Photo Editor
//
//  Created by ChuenWai on 22/05/2020.
//  Copyright © 2020 Mohamed Hamed. All rights reserved.
//

import UIKit

class SliderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.5
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.beginPath()
        context.move(to: CGPoint(x: rect.maxX / 2, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.closePath()

        context.setFillColor(red: 242, green: 242, blue: 242, alpha: 0.7)
        context.fillPath()
    }
}
