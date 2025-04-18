//
//  TextMessageCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/4.
//

import UIKit

class TextMessageCell: BaseMessageCell {
    
    lazy var contentLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = RLColor.share.black3
        label.text = "未知消息类型"
        label.numberOfLines = 0
        label.enabledTypes = [.mention, .hashtag, .url]
        label.mentionColor = TGAppTheme.primaryColor
        label.URLColor = TGAppTheme.primaryBlueColor
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
        var attribute = TGNEEmotionTool.getAttWithStr(
          str: model.nimMessageModel?.text ?? "",
          font: UIFont.systemFont(ofSize: 14),
          CGPoint(x: 0, y: -4)
        )
        if let ext = model.nimMessageModel?.serverExtension?.toDictionary {
            if let usernames = ext["usernames"] as? [String], usernames.count > 0 {
                self.formMentionNamesContent(content: attribute, usernames: usernames) { attributedString in
                    if let attributedString = attributedString {
                        attribute = attributedString
                        attribute = self.formUrlContent(content: attribute)
                        self.contentLabel.attributedText = attribute
                        self.textLayout(model: model)
                    }
                   
                }
               
            }
            
            if let mentionAll = ext["mentionAll"] as? String {
                attribute = self.formMentionAllContent(content: attribute, mentionAll: mentionAll)
                attribute = self.formUrlContent(content: attribute)
                self.contentLabel.attributedText = attribute
                self.textLayout(model: model)
            }
        } else {
            attribute = self.formUrlContent(content: attribute)
            self.contentLabel.attributedText = attribute
            self.textLayout(model: model)
        }

    }
    
    func textLayout(model: TGMessageData) {
        let showLeft = !(model.nimMessageModel?.isSelf ?? true)
        let atSide = !self.timeShowAtBottom(messageModel: model)
        
        self.timeTickStackView.snp.remakeConstraints { make in
            if atSide {
                make.top.right.bottom.equalToSuperview()
            } else {
                make.bottom.right.equalToSuperview()
            }
        }
        self.contentLabel.snp.remakeConstraints { make in
            if atSide {
                make.bottom.left.equalToSuperview()
                make.top.equalToSuperview().offset(0)
                make.right.equalTo(self.timeTickStackView.snp.left).offset(-8)
            } else {
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(self.timeTickStackView.snp.top)
            }
            make.height.greaterThanOrEqualTo(20)
        }
        
        self.textView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(showLeft ? 10:10)
            make.right.equalToSuperview().offset(showLeft ? -10:-10)
        }
        
        self.timeTickStackView.alignment = .fill
        self.timeTickStackView.layoutIfNeeded()
        self.contentLabel.layoutIfNeeded()
        self.textView.layoutIfNeeded()
        self.layoutIfNeeded()
        if let bubbleViewTap = bubbleViewTap {
            self.bubbleView.removeGestureRecognizer(bubbleViewTap)
        }
        contentLabel.handleURLTap({[weak self] url in
            self?.delegate?.didTapTextUrl(textUrl: url.absoluteString)
        })
    }
    
    func timeShowAtBottom(messageModel: TGMessageData) -> Bool {
        let tempContentLabel = contentLabel
        let tempTimeLabel = timeLabel
        tempTimeLabel.text = messageModel.messageTime.messageTimeString()
        var atBottom = false
        let maxSize = CGSize(width: ScreenWidth - 140, height: CGFloat(Float.infinity))
        let contentLabelSize = tempContentLabel.sizeThatFits(maxSize)
        let timeLabelSize = tempTimeLabel.sizeThatFits(maxSize)
        let newLine = tempContentLabel.text!.contains("\n")
        if (contentLabelSize.width + timeLabelSize.width + 30 > ScreenWidth - 150 || newLine) || (contentLabelSize.height > 30 || newLine)  {
            atBottom = true
        }
        return atBottom
    }
    
    
    
    func formUrlContent(content: NSMutableAttributedString) -> NSMutableAttributedString {
        var mutableAttributedString = content
        
        guard let regex = try? NSRegularExpression(pattern: urlPattern, options: []) else { return mutableAttributedString }
        let matches = regex.enumerateMatches(in: mutableAttributedString.string,
                range: NSRange(mutableAttributedString.string.startIndex..<mutableAttributedString.string.endIndex, in: mutableAttributedString.string)
        ) { (matchResult, _, stop) -> () in
            if let match = matchResult {
                let url = mutableAttributedString.string.subString(with: match.range)
                mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: match.range)
                mutableAttributedString.addAttributes([NSAttributedString.Key.link: url], range: match.range)
            }
        }
        
        return mutableAttributedString
    }
}


