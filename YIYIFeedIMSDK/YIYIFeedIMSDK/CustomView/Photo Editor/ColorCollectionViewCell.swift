//
//  ColorCollectionViewCell.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 5/1/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

@objcMembers class ColorCollectionViewCell: UICollectionViewCell {

    // 创建 colorView
    var colorView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 初始化 colorView
        colorView = UIView()
        contentView.addSubview(colorView)
        
        // 使用 SnapKit 设置布局
        colorView.snp.makeConstraints { make in
            make.center.equalTo(contentView)
            make.width.height.equalTo(20) // 设置大小
        }
        
        // 设置 colorView 的样式
        colorView.backgroundColor = .white
        colorView.layer.cornerRadius = 10  // 圆形
        colorView.clipsToBounds = true
        colorView.layer.borderWidth = 1.0
        colorView.layer.borderColor = UIColor.white.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 此方法可以进行额外的视图布局调整，如果需要的话
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                let previousTransform = colorView.transform
                UIView.animate(withDuration: 0.2,
                               animations: {
                                self.colorView.transform = self.colorView.transform.scaledBy(x: 1.3, y: 1.3)
                },
                               completion: { _ in
                                UIView.animate(withDuration: 0.2) {
                                    self.colorView.transform = previousTransform
                                }
                })
            } else {
                // animate deselection if needed
            }
        }
    }
}
