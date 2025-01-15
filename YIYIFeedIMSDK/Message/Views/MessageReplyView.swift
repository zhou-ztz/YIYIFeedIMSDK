//
//  MessageReplyView.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/18.
//

import UIKit
import NIMSDK
import SnapKit
import SDWebImage

let rePlyHeight: CGFloat = 64

class MessageReplyView: UIView {
    
    var contentView: UIView = UIView()
    lazy var imageView: UIImageView = {
        let image =  UIImageView()
        return image
    }()
    var lineView: UIView = UIView()
    var avatarView: TGAvatarView = TGAvatarView(type: .width38(showBorderLine: false))
    lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = RLColor.share.black3
        label.textAlignment = .center
        return label
    }()
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = RLColor.share.black3
        label.textAlignment = .center
        return label
    }()
    var audioImageView: UIImageView = {
        let image =  UIImageView()
        return image
    }()
    var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.set_image(named: "IMG_topbar_close"), for: .normal)
        return btn
    }()
    
    let headView = UIView()
    
    var messageID: String?
    var messageType: String?
    var messageCustomType: String?
    var username: String = ""
    
    var videoCoverUrl: String = ""
    
    lazy var playBtnImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "icon_play_normal")
        image.isUserInteractionEnabled = false
        image.isHidden = true
        return image
    }()
    
    let stackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 6
    }
    
    let headStackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 8
    }
    
    let contentStackView: UIStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.distribution = .fill
        $0.spacing = 8
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commitUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func commitUI() {
        imageView.contentMode = .scaleAspectFit
        self.backgroundColor = .white
        addSubview(contentView)
        contentView.bindToEdges()
        contentView.addSubview(headStackView)
        headStackView.snp.makeConstraints { make in
            make.bottom.top.equalTo(0)
            make.left.right.equalToSuperview().inset(12)
        }
        
        headStackView.addArrangedSubview(headView)
        headStackView.addArrangedSubview(contentStackView)
        
        headView.addSubview(avatarView)
        headView.addSubview(imageView)
        
        contentStackView.addArrangedSubview(nicknameLabel)
        contentStackView.addArrangedSubview(stackView)
        
        contentView.addSubview(closeBtn)
        contentView.addSubview(lineView)
        let line = UIView()
        line.backgroundColor = RLColor.inconspicuous.disabled
        contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.right.top.left.equalTo(0)
            make.height.equalTo(1)
        }
        
        stackView.addArrangedSubview(audioImageView)
        stackView.addArrangedSubview(messageLabel)
        
        lineView.backgroundColor = RLColor.share.theme
        lineView.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(0)
            make.width.equalTo(7)
        }
        
        headView.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.height.width.equalTo(40)
            make.bottom.top.equalToSuperview().inset(12)
        }
        
        avatarView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(38)
        }
        imageView.bindToEdges()
        
        contentStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
        }
        stackView.snp.makeConstraints { make in
            make.left.equalTo(0)
        }
        closeBtn.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.top.equalTo(10)
        }
        
        nicknameLabel.textColor = .black
        messageLabel.textColor = .gray
        
        imageView.layer.cornerRadius = 0
        imageView.clipsToBounds = false
        
        imageView.addSubview(playBtnImageView)
        playBtnImageView.snp.makeConstraints({make in
            make.width.height.equalTo(20)
            make.center.equalToSuperview()
        })
        
        
    }
    
    func configure(_ model: TGMessageData) {
        guard let message = model.nimMessageModel else { return }
        
        imageView.isHidden = false
        avatarView.isHidden = true
        messageCustomType = ""
        playBtnImageView.isHidden = true
        audioImageView.isHidden = true
        headView.isHidden = true
        username = message.senderId ?? ""
        
        switch(message.messageType) {
        case .MESSAGE_TYPE_IMAGE:
            if let imageObject = message.attachment as? V2NIMMessageImageAttachment, let url = URL(string: imageObject.url.orEmpty) {
                self.messageLabel.isHidden = false
                self.imageView.isHidden = false
                self.headView.isHidden = false
                self.messageLabel.text = "image".localized
                self.imageView.sd_setImage(with: url, placeholderImage: rl_defalut_placeholder_image)
            }
        case .MESSAGE_TYPE_AUDIO:
            guard let audioObject = message.attachment as? V2NIMMessageAudioAttachment else { return }
            var milliseconds = Float(audioObject.duration)
            milliseconds = milliseconds / 1000
            let currSeconds = Int(fmod(milliseconds, 60))
            let currMinute = Int(fmod((milliseconds / 60), 60))

            audioImageView.isHidden = false
            messageLabel.isHidden = false
            
            messageLabel.text = String(format: "%01d:%02d", currMinute, currSeconds)
            audioImageView.contentMode = .scaleAspectFit
            audioImageView.image = UIImage.set_image(named: "icon_reply_message_audio")
        case .MESSAGE_TYPE_VIDEO:
            headView.isHidden = false
            if let videoObject = message.attachment as? V2NIMMessageVideoAttachment{
                self.messageLabel.isHidden = false
                self.imageView.isHidden = false
                self.playBtnImageView.isHidden = false
                self.messageLabel.text = "video".localized
                let finalImageSize = MessageUtils.videoSize(videoObject)
                let v2size: V2NIMSize = V2NIMSize(width: Int(finalImageSize.width), height: Int(finalImageSize.height))
                NIMSDK.shared().v2StorageService.getVideoCoverUrl(videoObject, thumbSize: v2size) {[weak self] result in
                    self?.videoCoverUrl = result.url
                    DispatchQueue.main.async {
                        self?.imageView.sd_setImage(with: URL(string: result.url), placeholderImage: rl_defalut_placeholder_image)
                    }
                } failure: {[weak self] _ in
                    DispatchQueue.main.async {
                        self?.imageView.image = rl_defalut_placeholder_image
                    }
                }
            }
        case .MESSAGE_TYPE_LOCATION:
            guard let locationObject = message.attachment as? V2NIMMessageLocationAttachment else { return }
            headView.isHidden = false
            imageView.isHidden = false
            messageLabel.isHidden = false
            imageView.image = UIImage(named: "ic_map_default")
            messageLabel.text = locationObject.address
            
        case .MESSAGE_TYPE_FILE:
            guard let fileObject = message.attachment as? V2NIMMessageFileAttachment else { return }
            let fileType = URL(fileURLWithPath: fileObject.path ?? "").pathExtension
            let image = RLSendFileManager.fileIcon(with: fileType).icon
            imageView.isHidden = false
            messageLabel.isHidden = false
            imageView.image = image
            messageLabel.text = fileObject.name
            headView.isHidden = false
        case .MESSAGE_TYPE_CUSTOM:
            guard let customType = model.customType else { return }
            switch customType {
            case .ContactCard:
                headView.isHidden = false
                imageView.isHidden = true
                avatarView.isHidden = false
                messageLabel.isHidden = false
                if let attact = model.customAttachment as? IMContactCardAttachment {
                    messageCustomType = String(format: "%ld", Int(CustomMessageType.ContactCard.rawValue))
                    MessageUtils.getAvatarIcon(sessionId: attact.memberId, conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
                        self?.avatarView.avatarInfo = avatarInfo
                        self?.messageLabel.text = String(format: "reply_contact_im".localized, avatarInfo.nickname ?? "")
                    }
                }
            case .Sticker:
                headView.isHidden = false
                self.messageLabel.isHidden = false
                self.imageView.isHidden = false
                self.messageLabel.text = "title_sticker".localized
                self.messageCustomType = String(format: "%ld", Int(CustomMessageType.Sticker.rawValue))
                if let attact = model.customAttachment as? IMStickerAttachment, let url = URL(string: attact.chartletId) {
                    self.imageView.sd_setImage(with: url, placeholderImage: rl_defalut_placeholder_image)
                }
            case .SocialPost:
                if let attachment = model.customAttachment as? IMSocialPostAttachment {
                    imageView.isHidden = false
                    messageLabel.isHidden = false
                    imageView.sd_setImage(with: URL(string: attachment.imageURL), placeholderImage: rl_defalut_placeholder_image, context: [.storeCacheType : SDImageCacheType.memory.rawValue])
                    headView.isHidden = false
                    messageLabel.text = attachment.title
                    if let localExt = message.localExtension?.toDictionary, let _ = localExt["title"] as? String, let desc = localExt["description"] as? String, let image = localExt["image"] as? String {
                        self.imageView.sd_setImage(with: URL(string: image), placeholderImage: rl_defalut_placeholder_image, context: [.storeCacheType : SDImageCacheType.memory.rawValue])
                        self.messageLabel.text = desc
                    }
                    messageCustomType = String(format: "%ld", Int(CustomMessageType.SocialPost.rawValue))
                }
            case .MiniProgram:
                if let attachment = model.customAttachment as? IMMiniProgramAttachment {
                    imageView.isHidden = false
                    messageLabel.isHidden = false
                    imageView.sd_setImage(with: URL(string: attachment.imageURL), placeholderImage: UIImage(named: "default_image"), context: [.storeCacheType : SDImageCacheType.memory.rawValue])
                    headView.isHidden = false
                    messageLabel.text = attachment.title
                    if let localExt = message.localExtension?.toDictionary, let _ = localExt["title"] as? String, let desc = localExt["description"] as? String, let image = localExt["image"] as? String {
                        self.imageView.sd_setImage(with: URL(string: image), placeholderImage: rl_defalut_placeholder_image, context: [.storeCacheType : SDImageCacheType.memory.rawValue])
                        self.messageLabel.text = desc
                    }
                    messageCustomType = String(format: "%ld", Int(CustomMessageType.MiniProgram.rawValue))
                }
            case .Voucher:
                if let attachment = model.customAttachment as? IMVoucherAttachment {
                    imageView.isHidden = false
                    messageLabel.isHidden = false
                    imageView.sd_setImage(with: URL(string: attachment.imageURL), placeholderImage: UIImage(named: "default_image_reply"), context: [.storeCacheType : SDImageCacheType.memory.rawValue])
                    headView.isHidden = false
                    messageLabel.text = attachment.title
                    if let localExt = message.localExtension?.toDictionary, let _ = localExt["title"] as? String, let desc = localExt["description"] as? String, let image = localExt["image"] as? String {
                        self.imageView.sd_setImage(with: URL(string: image), placeholderImage: rl_defalut_placeholder_image, context: [.storeCacheType : SDImageCacheType.memory.rawValue])
                        self.messageLabel.text = desc
                    }
                    messageCustomType = String(format: "%ld", Int(CustomMessageType.Voucher.rawValue))
                }
            default:
                messageLabel.isHidden = false
                messageLabel.text = message.text
                break
            }
        case .MESSAGE_TYPE_TEXT:
            messageLabel.isHidden = false
            messageLabel.text = message.text
            break
        case .MESSAGE_TYPE_NOTIFICATION, .MESSAGE_TYPE_TIP, .MESSAGE_TYPE_ROBOT:
            messageLabel.isHidden = false
            messageLabel.text = message.text
            break
        default:
            break
        }
        if message.isSelf {
            self.nicknameLabel.text = "you".localized
        } else {
            MessageUtils.getAvatarIcon(sessionId: message.senderId ?? "", conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
                self?.nicknameLabel.text = avatarInfo.nickname ?? ""
            }
        }
        
        messageID = message.messageClientId
        messageType = String(format: "%ld", message.messageType.rawValue)
    }


}
