//
//  ReplyMessageCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/17.
//

import UIKit
import SDWebImage
import NIMSDK

class ReplyMessageCell: BaseMessageCell {
    
    lazy var headImage: SDAnimatedImageView = {
        let imageView = SDAnimatedImageView()
        imageView.image = UIImage(named: "icon_voice_call")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var avatar: TGAvatarView = {
        let imageView = TGAvatarView(type: .width48(showBorderLine: false))
        imageView.isHidden = true
        imageView.roundCorner(24)
        return imageView
    }()
    var audioImageView: UIImageView = {
        let imageView =  UIImageView()
        imageView.image = UIImage(named: "icon_reply_message_audio")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = TGAppTheme.Font.semibold(TGFontSize.defaultLocationDefaultFontSize)
        label.textColor = UIColor(hex: 0x0D57BC)
        label.text = ""
        label.numberOfLines = 1
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = TGAppTheme.Font.regular(TGFontSize.defaultLocationDefaultFontSize)
        label.textColor = UIColor(hex: 0x4a4a4a)
        label.text = ""
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = TGAppTheme.Font.regular(TGFontSize.defaultLocationDefaultFontSize)
        label.textColor = .black
        label.text = ""
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = TGAppTheme.Font.regular(TGFontSize.defaultFontSize)
        label.textColor = .black
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    
    lazy var imgTextContentView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        return view
    }()
    
    lazy var contentTextView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        view.backgroundColor = .white
        return view
    }()
    
    lazy var replyContentView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        view.backgroundColor = UIColor(hex: 0x0D57BC)
        view.round3Corners()
        return view
    }()
    
    lazy var wholeContentView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        return view
    }()
    let textStackView = UIStackView().configure { (stack) in
        stack.axis = .vertical
        stack.spacing = 11
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        bubbleImage.addSubview(replyContentView)
        bubbleImage.addSubview(messageLabel)
        bubbleImage.addSubview(timeTickStackView)
        
        textStackView.addArrangedSubview(descriptionLabel)
        textStackView.addArrangedSubview(titleLabel)
        
        imgTextContentView.addSubview(headImage)
        imgTextContentView.addSubview(avatar)
        imgTextContentView.addSubview(audioImageView)
        imgTextContentView.addSubview(textStackView)
        
        contentTextView.addSubview(nameLabel)
        contentTextView.addSubview(imgTextContentView)
        replyContentView.addSubview(contentTextView)
        
        
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(messageViewDidTap))
        replyContentView.addGestureRecognizer(tapAction)
    }
    
    override func setData(model: TGMessageData) {
        super.setData(model: model)
        
        guard let message = model.nimMessageModel, let attachment = model.customAttachment as? IMReplyAttachment else { return }
        contentTextView.backgroundColor = !message.isSelf ? UIColor(hex: 0xf0f0f0) : UIColor(hex: 0xd5eeff)
        
        let defaultImage = UIImage(named: "default_image")
        
        self.descriptionLabel.isHidden = false
        self.descriptionLabel.text = attachment.message
        
        self.headImage.sd_setImage(with: URL(string: attachment.image), placeholderImage: defaultImage, completed: nil)
        
        if attachment.username == RLSDKManager.shared.loginParma?.imAccid {
            self.nameLabel.text = "you".localized
        } else {
            MessageUtils.getAvatarIcon(sessionId: attachment.username, conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
                self?.nameLabel.text = avatarInfo.nickname
            }
        }
        
        var mutableAttributedString = attachment.content.attributonString().setTextFont(14).setlineSpacing(0)
        self.messageLabel.attributedText = mutableAttributedString
        if let ext = message.serverExtension?.toDictionary {
            if let usernames = ext["usernames"] as? [String], usernames.count > 0 {
                self.formMentionNamesContent(content: mutableAttributedString, usernames: usernames) {[weak self] str in
                    if let str = str {
                        mutableAttributedString = str
                        self?.messageLabel.attributedText = mutableAttributedString
                    }
                    
                }
               
            }
            
            if let mentionAll = ext["mentionAll"] as? String {
                mutableAttributedString = self.formMentionAllContent(content: mutableAttributedString, mentionAll: mentionAll)
                self.messageLabel.attributedText = mutableAttributedString
            }
        }
        
        self.avatar.isHidden = true
        self.audioImageView.isHidden = true
        let type = V2NIMMessageType(rawValue: Int(attachment.messageType) ?? -1)
        switch type {
        case .MESSAGE_TYPE_TEXT:
            self.headImage.isHidden = true
            self.titleLabel.isHidden = true
            self.descriptionLabel.text = attachment.message
            break
        case .MESSAGE_TYPE_IMAGE:
            self.headImage.isHidden = false
            self.titleLabel.isHidden = false
            self.descriptionLabel.isHidden = true
            
            self.titleLabel.text = "image".localized
            self.headImage.contentMode = .scaleToFill
            break
        case .MESSAGE_TYPE_AUDIO:
            self.headImage.isHidden = true
            self.titleLabel.isHidden = true
            self.audioImageView.image = UIImage(named: "icon_reply_message_audio")?.withRenderingMode(.alwaysOriginal)

            self.audioImageView.isHidden = false
            break
        case .MESSAGE_TYPE_VIDEO:
            self.headImage.isHidden = false
            self.titleLabel.isHidden = false
            self.descriptionLabel.isHidden = true
            
            if attachment.image.count > 0 {
                self.headImage.sd_setImage(with: URL(string: attachment.image), placeholderImage: defaultImage, completed: nil)
            } else {
                self.headImage.sd_setImage(with: URL(string: attachment.videoURL), placeholderImage: defaultImage, completed: nil)
            }
            self.headImage.contentMode = .scaleToFill
            self.titleLabel.text = "video".localized
            break
        case .MESSAGE_TYPE_LOCATION:
            self.headImage.isHidden = false
            self.titleLabel.isHidden = false
            
            self.headImage.image = UIImage(named: "ic_map_default")
            self.titleLabel.text = "location".localized
            break
        case .MESSAGE_TYPE_FILE:
            self.headImage.isHidden = false
            self.titleLabel.isHidden = false
            
            let fileType = URL(fileURLWithPath: attachment.message).pathExtension
            let fileInfo = RLSendFileManager.fileIcon(with:fileType)
            self.headImage.image = fileInfo.icon
            self.titleLabel.text = fileInfo.type
            break
        case .MESSAGE_TYPE_CUSTOM:
            self.customAttachment(attachment: attachment)
            break
        default:
            break
        }
        
        let atSide = !self.timeShowAtBottom(messageModel: model)
        ///刷新UI
        headImage.snp.remakeConstraints { make in
            make.width.height.equalTo(48)
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            
            if !headImage.isHidden {
                make.top.bottom.greaterThanOrEqualToSuperview()
            }
        }
        
        avatar.snp.remakeConstraints { make in
            make.width.height.equalTo(48)
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            
            if !headImage.isHidden {
                make.top.bottom.greaterThanOrEqualToSuperview()
            }
        }
        audioImageView.snp.remakeConstraints { make in
            make.width.equalTo(17)
            make.height.equalTo(28)
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            if !audioImageView.isHidden {
                make.top.bottom.greaterThanOrEqualToSuperview()
            }
        }
        
        textStackView.snp.remakeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            if headImage.isHidden && avatar.isHidden && audioImageView.isHidden {
                make.left.equalToSuperview()
            } else {
                if type == .MESSAGE_TYPE_AUDIO {
                    make.left.equalTo(audioImageView.snp.right).offset(8)
                } else {
                    make.left.equalTo(headImage.snp.right).offset(8)
                }
            }
            make.centerY.equalToSuperview()
        }
        
        nameLabel.snp.remakeConstraints { make in
            make.top.left.equalToSuperview().inset(8)
            make.right.equalToSuperview()
        }
        
        imgTextContentView.snp.remakeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(8)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
        }
        
        contentTextView.snp.remakeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(4)
        }
        
        replyContentView.snp.remakeConstraints { make in
            make.top.left.right.equalToSuperview().inset(8)
            make.bottom.equalTo(messageLabel.snp.top).offset(-8)
        }
        
        messageLabel.snp.remakeConstraints { make in
            if atSide {
                make.left.bottom.equalToSuperview().inset(8)
            } else {
                make.left.right.equalToSuperview().inset(8)
                make.bottom.equalTo(timeTickStackView.snp.top).offset(-8)
            }
        }
        
        timeTickStackView.snp.remakeConstraints { make in
            make.bottom.right.equalToSuperview().inset(8)
            
            if atSide {
                make.left.greaterThanOrEqualTo(messageLabel.snp.right).inset(-8)
            }
        }
        
    }
 
    
    func customAttachment(attachment: IMReplyAttachment) {
        switch CustomMessageType(rawValue: Int(attachment.messageCustomType) ?? -1) {
        case .Sticker:
            self.headImage.isHidden = false
            self.titleLabel.isHidden = true
            self.descriptionLabel.isHidden = true
            break
        case .ContactCard:
            self.headImage.isHidden = true
            self.titleLabel.isHidden = false
            self.descriptionLabel.isHidden = false
            self.titleLabel.text = "contact".localized
            let avatarInfo = TGAvatarInfo()
            avatarInfo.avatarURL = attachment.image
            self.avatar.avatarInfo = avatarInfo
            self.avatar.isHidden = false
            break
        case .Reply:
            self.headImage.isHidden = true
            self.titleLabel.isHidden = true
            self.descriptionLabel.isHidden = false
            break
        case .StickerCard:
            self.headImage.isHidden = false
            self.descriptionLabel.isHidden = false
            self.titleLabel.isHidden = false
            self.titleLabel.text = "rw_yippi_sticker".localized
            break
        case .SocialPost:
            self.headImage.isHidden = false
            self.descriptionLabel.isHidden = false
            self.titleLabel.isHidden = false
            self.titleLabel.text =  "link".localized
            break
        case .Voucher:
            self.headImage.isHidden = false
            self.descriptionLabel.isHidden = false
            self.titleLabel.isHidden = false
            self.titleLabel.text =  "rw_voucher_text".localized
            break
        default:
            break
        }
    }
    
    func timeShowAtBottom(messageModel: TGMessageData) -> Bool {
        let tempContentLabel = messageLabel
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
    
    @objc func messageViewDidTap(_ gestureRecognizer: UIGestureRecognizer) {
        self.delegate?.replyMessageTapped(cell: self, model: self.contentModel)
    }

}

extension UIView {
    func roundCorners(_ frame: CGRect) {
        let path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.topLeft, .topRight, .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.fillColor = UIColor(hex: 0x0D57BC).cgColor
        
        self.layer.mask = mask
        self.layer.masksToBounds = true
    }
    
    func round3Corners() {
        self.backgroundColor = UIColor(hex: 0x0D57BC)
        self.layer.cornerRadius = 10
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        self.layer.masksToBounds = true
    }
}
