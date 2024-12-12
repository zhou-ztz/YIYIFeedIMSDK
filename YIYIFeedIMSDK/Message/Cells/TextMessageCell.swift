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
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = RLColor.share.black3
        label.text = "未知消息类型"
        label.numberOfLines = 0
        return label
    }()
    
    lazy var textView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        return view
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.bubbleImage.addSubview(textView)
        self.textView.addSubview(contentLabel)
        self.textView.addSubview(timeTickStackView)
    }
    
    override func setData(model: TGMessageData) {
        super.setData(model: model)
        let showLeft = !(model.nimMessageModel?.isSelf ?? true)
        let attribute = TGNEEmotionTool.getAttWithStr(
          str: model.nimMessageModel?.text ?? "",
          font: UIFont.systemFont(ofSize: 14),
          CGPoint(x: 0, y: -4)
        )
        contentLabel.attributedText = attribute
       
        let atSide = !self.timeShowAtBottom(messageModel: model)
        
        timeTickStackView.snp.remakeConstraints { make in
            if atSide {
                make.top.right.bottom.equalToSuperview()
            } else {
                make.bottom.right.equalToSuperview()
            }
        }
        contentLabel.snp.remakeConstraints { make in
            if atSide {
                make.bottom.left.equalToSuperview()
                make.top.equalToSuperview().offset(0)
                make.right.equalTo(timeTickStackView.snp.left).offset(-8)
            } else {
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(timeTickStackView.snp.top)
            }
            make.height.greaterThanOrEqualTo(20)
        }
        
        textView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(showLeft ? 10:10)
            make.right.equalToSuperview().offset(showLeft ? -10:-10)
        }
        
        timeTickStackView.alignment = .fill
        timeTickStackView.layoutIfNeeded()
        contentLabel.layoutIfNeeded()
        textView.layoutIfNeeded()
        self.layoutIfNeeded()
        
    }
    
    private func timeShowAtBottom(messageModel: TGMessageData) -> Bool {
        let tempContentLabel = contentLabel
        let tempTimeLabel = timeLabel
        tempTimeLabel.text = messageModel.messageTime.messageTimeString()
        var atBottom = false
        let maxSize = CGSize(width: ScreenWidth - 140, height: CGFloat(Float.infinity))
        let contentLabelSize = tempContentLabel.sizeThatFits(maxSize)
        let timeLabelSize = tempTimeLabel.sizeThatFits(maxSize)
        let newLine = tempContentLabel.text!.contains("\n")
        print("-----=\(contentLabelSize.width + timeLabelSize.width + 30)")
        print("-----=\(ScreenWidth - 170)")
        if (contentLabelSize.width + timeLabelSize.width + 30 > ScreenWidth - 150 || newLine) || (contentLabelSize.height > 30 || newLine)  {
            atBottom = true
        }
        return atBottom
    }
}
