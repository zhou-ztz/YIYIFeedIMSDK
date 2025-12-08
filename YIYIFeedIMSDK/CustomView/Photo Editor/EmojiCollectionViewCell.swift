//
//  EmojiCollectionViewCell.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/30/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit
@objcMembers class EmojiCollectionViewCell: UICollectionViewCell {

    // 创建 emojiLabel
    var emojiLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 初始化 emojiLabel
        emojiLabel = UILabel()
        emojiLabel.text = "😂" // 设置表情文字
        emojiLabel.textAlignment = .center
        emojiLabel.font = UIFont.systemFont(ofSize: 60)
        emojiLabel.numberOfLines = 1
        emojiLabel.adjustsFontSizeToFitWidth = false
        contentView.addSubview(emojiLabel)
        
        // 使用 SnapKit 设置布局
        emojiLabel.snp.makeConstraints { make in
            make.center.equalTo(contentView)
            make.width.equalTo(emojiLabel.intrinsicContentSize.width)
            make.height.equalTo(emojiLabel.intrinsicContentSize.height)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // 进行任何额外的初始化
    }
}
