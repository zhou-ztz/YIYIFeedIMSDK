//
//  ConversationListCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2023/12/19.
//

import UIKit
import NIMSDK

class ConversationListCell: UITableViewCell {
    
    lazy var headImage: TGAvatarView = {
        let img = TGAvatarView(type: .width38(showBorderLine: false))
        return img
    }()
    
    lazy var nameL: UILabel = {
        let lab = UILabel()
        lab.textColor = RLColor.share.black3
        lab.font = UIFont.boldSystemFont(ofSize: 15)
        lab.numberOfLines = 1
        lab.text = "笑死"
        return lab
    }()
    lazy var contentL: UILabel = {
        let lab = UILabel()
        lab.textColor = RLColor.normal.minor
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.numberOfLines = 1
        lab.text = "你好哈哈哈"
        return lab
    }()
    lazy var redPiont: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = UIFont.systemFont(ofSize: 9)
        lab.numberOfLines = 1
        lab.text = ""
        lab.backgroundColor = .red
        lab.textAlignment = .center
        lab.clipsToBounds = true
        lab.layer.cornerRadius = 9
        return lab
    }()
    
    lazy var timeL: UILabel = {
        let lab = UILabel()
        lab.textColor = RLColor.share.lightGray
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.numberOfLines = 1
        lab.text = ""
        return lab
    }()
    
    let stackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 10
    }
    var statusIcon = UIImageView()
    var screenGroup = UIImageView()
    var pinIcon = UIImageView(image: UIImage(named: "iconsPinGrey"))
    var muteIcon = UIImageView(image: UIImage(named: "iconsVolumeGrey"))
    
    var conversation: V2NIMConversation?
    
    var isShowLine: Bool = true
    
    // 会话内容
    private var _messageContent: NSMutableAttributedString?
    var messageContent: NSMutableAttributedString? {
        set {
            _messageContent = newValue
            guard let value = newValue else { return }
            DispatchQueue.main.async {
                self.contentL.attributedText = value
            }
        }
        get {
            return _messageContent
        }
    }
    
    lazy var shapeLayer: CAShapeLayer = {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: self.contentView.bounds.size.height - 0.5))
        bezierPath.addLine(to: CGPoint(x: (self.superview?.bounds.size.width)!, y: self.contentView.bounds.size.height - 0.5))
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = RLColor.inconspicuous.disabled.cgColor
        shapeLayer.lineWidth = 0.3
        shapeLayer.path = bezierPath.cgPath
        return shapeLayer
    }()

    static let cellIdentifier = "ConversationListCell"
    class func nib() -> UINib {
        return UINib(nibName: cellIdentifier, bundle: nil)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.setUI()
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isShowLine {
            if self.shapeLayer.superlayer == nil {
                self.contentView.layer.addSublayer(self.shapeLayer)
            } else {
                let bezierPath = UIBezierPath()
                bezierPath.move(to: CGPoint(x: 0, y: self.contentView.bounds.size.height - 0.5))
                bezierPath.addLine(to: CGPoint(x: (self.superview?.bounds.size.width)!, y: self.contentView.bounds.size.height - 0.5))
                self.shapeLayer.path = bezierPath.cgPath
            }
        }
    }

    func setUI(){
        
        self.contentView.addSubview(headImage)
        self.contentView.addSubview(nameL)
        self.contentView.addSubview(contentL)
        self.contentView.addSubview(timeL)
        self.contentView.addSubview(stackView)
        stackView.addArrangedSubview(muteIcon)
        stackView.addArrangedSubview(pinIcon)
        stackView.addArrangedSubview(redPiont)
        headImage.snp.makeConstraints { make in
            make.left.equalTo(11)
            make.top.equalTo(15)
            make.width.height.equalTo(38)
            make.bottom.equalTo(-15)
        }
        
        nameL.snp.makeConstraints { make in
            make.left.equalTo(headImage.snp.right).offset(10)
            make.top.equalTo(12)
            make.right.equalTo(-70)
        }
        
        contentL.snp.makeConstraints { make in
            make.left.equalTo(headImage.snp.right).offset(10)
            make.bottom.equalTo(-11)
            make.right.equalTo(-100)
        }
        
        
        timeL.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.right.equalTo(-10)
        }
        
        stackView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-15)
            $0.centerY.equalTo(contentL.snp.centerY)
        }
        
        muteIcon.snp.makeConstraints {
            $0.width.height.equalTo(20)
        }
        
        pinIcon.snp.makeConstraints {
            $0.width.height.equalTo(20)
        }
        redPiont.snp.makeConstraints {
            $0.width.height.equalTo(18)
        }

        
    }
    
    func setData(conversation: V2NIMConversation){
        self.conversation = conversation
        let sessionId = MessageUtils.conversationTargetId(conversation.conversationId)
        MessageUtils.getAvatarIcon(sessionId: sessionId, conversationType: conversation.type) {[weak self] avatarInfo in
            let info = TGAvatarInfo()
            info.avatarURL = avatarInfo.avatarURL
            info.verifiedType = avatarInfo.verifiedType
            info.verifiedIcon = avatarInfo.verifiedIcon
            info.avatarPlaceholderType = conversation.type == .CONVERSATION_TYPE_P2P ? .unknown : .group
            self?.headImage.avatarInfo = info
            self?.nameL.text = avatarInfo.nickname
        }
        redPiont.text = "\(conversation.unreadCount)"
        redPiont.isHidden = conversation.unreadCount == 0 ? true : false
        var width: CGFloat = conversation.unreadCount > 9 ? 20 : 18
        if conversation.unreadCount > 99 {
            width = 22
            redPiont.text = "99+"
        }
        print("unreadCount = \(conversation.unreadCount)")
        redPiont.snp.remakeConstraints {
            $0.width.equalTo(width)
            $0.height.equalTo(18)
        }
        timeL.text = TGDate().dateString(.normal, nsDate: NSDate(timeIntervalSince1970: conversation.lastMessage?.messageRefer.createTime ?? 0))
        muteIcon.isHidden = !conversation.mute
        pinIcon.isHidden = !conversation.stickTop
        
        var text = ""
        guard let messageType = conversation.lastMessage?.messageType else { return }
        switch messageType {
        case .MESSAGE_TYPE_TEXT:
            text = conversation.lastMessage?.text ?? ""
        case .MESSAGE_TYPE_IMAGE:
            text = "recent_msg_desc_picture".localized
        case .MESSAGE_TYPE_LOCATION:
            text = "recent_msg_desc_location".localized
        case .MESSAGE_TYPE_VIDEO:
            text = "recent_msg_desc_video".localized
        case .MESSAGE_TYPE_FILE:
            text = "recent_msg_desc_file".localized
        case .MESSAGE_TYPE_AUDIO:
            text = "recent_msg_desc_audio".localized
        case .MESSAGE_TYPE_NOTIFICATION:
            ///群通知处理
            if let _ = conversation.lastMessage?.attachment as? V2NIMMessageNotificationAttachment  {
                text = "recent_msg_desc_group_msg".localized
            } else {
                text = conversation.lastMessage?.text ?? ""
            }
        case .MESSAGE_TYPE_ROBOT:
            text = "recent_msg_desc_robot_msg".localized
        case .MESSAGE_TYPE_TIP:
            text = conversation.lastMessage?.text ?? ""
        case .MESSAGE_TYPE_CUSTOM:
            if let attach = conversation.lastMessage?.attachment {
               let (attachmentType, attachment) = CustomAttachmentDecoder.decodeAttachment(attach.raw)
                switch attachmentType {
                case .WhiteBoard:
                    text = "recent_msg_desc_whiteboard".localized
                case .VideoCall:
                    text = "recent_msg_desc_voice_call".localized
                    if let attachment = attachment as? IMCallingAttachment {
                        if attachment.callType == .SIGNALLING_CHANNEL_TYPE_AUDIO {
                            text = "recent_msg_desc_voice_call".localized
                        } else {
                            text = "recent_msg_desc_video_call".localized
                        }
                    }
                case .Sticker:
                    text = "recent_msg_desc_sticker".localized
                case .Egg:
                    text = "recent_msg_desc_redpacket".localized
                case .ContactCard:
                    text = "recent_msg_desc_contact".localized
                case .RPS:
                    text = "recent_msg_desc_guess".localized
                case .MiniProgram:
                    text = "recent_msg_desc_attachment".localized
                case .SocialPost:
                    text = "recent_msg_desc_attachment".localized
                case .Reply:
                    if let attachment = attachment as? IMReplyAttachment {
                        text = attachment.content
                    }
                case .Voucher:
                    text = "recent_msg_desc_voucher".localized
                default:
                    break
                }
            }
    
            break
        default:
            text = "recent_msg_unknown".localized
        }
        
        if conversation.type == .CONVERSATION_TYPE_TEAM {
            if let senderId = conversation.lastMessage?.senderName {
                text = senderId + ": " + text
            } else {
                text = "You".localized + " : " + text
            }
        }
        messageContent = NSMutableAttributedString(string: text)
        checkNeedAtTip(conversation: conversation)
    }
    
    //是否@某人
    func checkNeedAtTip(conversation: V2NIMConversation) {
        guard let ext = conversation.lastMessage?.serverExtension?.toDictionary, let _ = conversation.lastMessage?.senderName , conversation.unreadCount > 0 else {
            return
        }
        let content = messageContent
        let atTip = NSAttributedString(string: "\("recent_msg_desc_tag_by_other".localized) ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        if let _ = ext["mentionAll"] {
            content?.insert(atTip, at: 0)
            messageContent = content
            return
        }
        if let _ = ext["usernames"] {
            content?.insert(atTip, at: 0)
            messageContent = content
            return
        }
    }

    
}
