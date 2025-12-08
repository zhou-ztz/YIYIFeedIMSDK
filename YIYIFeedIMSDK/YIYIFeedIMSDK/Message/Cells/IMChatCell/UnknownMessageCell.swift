//
//  UnknownMessageCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/6/16.
//

import UIKit

class UnknownMessageCell: BaseMessageCell {

    lazy var contentLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = RLColor.share.black3
        label.numberOfLines = 1
        label.enabledTypes = [.mention, .hashtag, .url]
        label.mentionColor = TGAppTheme.primaryColor
        label.URLColor = TGAppTheme.primaryBlueColor
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.bubbleImage.addSubview(contentLabel)
        self.bubbleImage.addSubview(timeTickStackView)
        contentLabel.text = "unknown_message".localized
        contentLabel.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(10)
        }
        timeTickStackView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.left.equalTo(contentLabel.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        self.timeTickStackView.alignment = .fill
    }
    

}
