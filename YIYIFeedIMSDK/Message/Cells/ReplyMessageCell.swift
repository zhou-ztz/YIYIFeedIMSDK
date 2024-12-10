//
//  ReplyMessageCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/17.
//

import UIKit

class ReplyMessageCell: BaseMessageCell {
    
    lazy var repliedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = RLColor.share.lightGray
        label.text = ""
        label.numberOfLines = 1
        return label
    }()

    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = RLColor.share.black3
        label.text = "未知消息类型"
        label.numberOfLines = 0
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
        self.bubbleImage.addSubview(repliedLabel)
        self.bubbleImage.addSubview(contentLabel)
        repliedLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(6)
            make.top.equalToSuperview().inset(7)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(repliedLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(6)
            make.bottom.equalToSuperview().inset(7)
        }
    }
    
    override func setData(model: TGMessageData) {
        super.setData(model: model)
        let attribute = NEEmotionTool.getAttWithStr(
            str: model.nimMessageModel?.text ?? "",
          font: UIFont.systemFont(ofSize: 15),
          CGPoint(x: 0, y: -4)
        )
        let attribute1 = NEEmotionTool.getAttWithStr(
          str: model.replyText,
          font: UIFont.systemFont(ofSize: 13),
          CGPoint(x: 0, y: -4),
          color: RLColor.share.lightGray
        )
        contentLabel.attributedText = attribute
        repliedLabel.attributedText = attribute1
    }

}
