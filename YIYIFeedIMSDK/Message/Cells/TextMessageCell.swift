//
//  TextMessageCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/4.
//

import UIKit

class TextMessageCell: BaseMessageCell {
    
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
        self.bubbleImage.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(6)
            make.top.bottom.equalToSuperview().inset(7)
        }
    }
    
    override func setData(model: RLMessageData) {
        super.setData(model: model)
        let attribute = NEEmotionTool.getAttWithStr(
          str: model.nimMessageModel?.text ?? "",
          font: UIFont.systemFont(ofSize: 15),
          CGPoint(x: 0, y: -4)
        )
        contentLabel.attributedText = attribute
        
    }
}
