//
//  BaseMessageCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/4.
//

import UIKit
import NIMSDK

protocol BaseMessageCellDelegate: AnyObject {
    
    func tapItemMessage(cell: BaseMessageCell?, model: TGMessageData?)
    func handleBaseMessageCellLongPress(cell: BaseMessageCell, model: TGMessageData?)
    func tapUserAvatar(cell: BaseMessageCell?, model: TGMessageData?)
    func reSendMessage(cell: BaseMessageCell?, model: TGMessageData?)
    func longPressUserAvatar(cell: BaseMessageCell?, model: TGMessageData?)
    ///语音
    func startAudioPlay(cell: BaseMessageCell?, model: TGMessageData?)
    func selectionLanguageTapped(cell: BaseMessageCell?, model: TGMessageData?)
    func replyMessageTapped(cell: BaseMessageCell?, model: TGMessageData?)
    func meetingTapped(cell: BaseMessageCell?, model: TGMessageData?)
}

class BaseMessageCell: UITableViewCell {
    weak var delegate: BaseMessageCellDelegate?
    
    var contentModel: TGMessageData?
    let defaultSenderImage = UIImage.set_image(named: "senderMessage")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 18), resizingMode: .stretch)
    let defaultReceiverImage = UIImage.set_image(named: "receiverMessage")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 10), resizingMode: .stretch)
    
    let senderRedPacket = UIImage.set_image(named: "pink_bubble_right")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 18), resizingMode: .stretch)
    let receiverRedPacket = UIImage.set_image(named: "pink_bubble_left")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 10), resizingMode: .stretch)
    
    let rightBackgroundImg = UIImage.set_image(named: "rightTranslate")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), resizingMode: .stretch)
    let leftBackgroundImg = UIImage.set_image(named: "leftTranslate")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), resizingMode: .stretch)
    
    let urlPattern = "<{0,1}(((https|http)?://)?([a-z0-9_-]+[.])|(www.))" + "\\w+[.|\\/]([a-z0-9\\-]{0,})?[[.]([a-z0-9\\-]{0,})]+((/[\\S&&[^,;\\u4E00-\\u9FA5]]+)+)?([.][a-z0-9\\-]{0,}+|/?)>{0,1}"
    
    let unreadImage = UIImage.set_image(named: "unreadTick")
    let readImage = UIImage.set_image(named: "readTick")
    
    lazy var bubbleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = defaultReceiverImage
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    let bubbleView = UIView()
    //已读未读标记
    lazy var tickImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = unreadImage
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        //imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    //发送失败
    lazy var failImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.set_image(named: "icMessageError")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        //imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    lazy var pinendImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.set_image(named: "MdOutlinePushPin")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9)
        label.textColor = UIColor(hex: "#808080")
        label.text = "00:00"
        label.isHidden = false
        return label
    }()
    
    lazy var wholeContentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fill
        stackView.alignment = .top
        return stackView
    }()
    lazy var allContentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fill
        stackView.alignment = .leading
        return stackView
    }()
    lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = RLColor.share.lightGray
        label.text = "name"
        label.isHidden = false
        return label
    }()
    lazy var avatarHeaderView: TGAvatarView = {
        let imageView = TGAvatarView(type: .width43(showBorderLine: false))
        return imageView
    }()
    
    lazy var timeTickStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 3
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var emptyHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    private let pulseIndicator = IMSendMsgIndicator(radius: 8.0, color: RLColor.main.red)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.setUI()
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI(){
        
        self.contentView.addSubview(wholeContentStackView)
        self.contentView.addSubview(failImage)
        self.contentView.addSubview(pulseIndicator)
        wholeContentStackView.addArrangedSubview(avatarHeaderView)
        wholeContentStackView.addArrangedSubview(emptyHeaderView)
        wholeContentStackView.addArrangedSubview(allContentStackView)
        
        allContentStackView.addArrangedSubview(nicknameLabel)
        allContentStackView.addArrangedSubview(bubbleView)
        bubbleView.addSubview(bubbleImage)
        bubbleImage.bindToEdges()
        
        timeTickStackView.addArrangedSubview(timeLabel)
        timeTickStackView.addArrangedSubview(pinendImage)
        timeTickStackView.addArrangedSubview(tickImage)
        
        setupLongPressGesture()
        bubbleView.addAction { [weak self] in
            self?.delegate?.tapItemMessage(cell: self, model: self?.contentModel)
        }
        avatarHeaderView.addAction { [weak self] in
            self?.delegate?.tapUserAvatar(cell: self, model: self?.contentModel)
        }
        failImage.addAction { [weak self] in
            self?.delegate?.reSendMessage(cell: self, model: self?.contentModel)
        }
    }
    
    func setData(model: TGMessageData){
        contentModel = model
        guard let messageModel = model.nimMessageModel else { return }
        
        nicknameLabel.isHidden = !(model.showName ?? false)
        wholeContentStackView.removeAllArrangedSubviews()
        
        var isleft = !messageModel.isSelf
        emptyHeaderView.isHidden = true
        avatarHeaderView.isHidden = isleft ? false : true
        ///如果是翻译的消息
        if let customType = model.customType , customType == .Translate, let attach =  model.customAttachment as? IMTextTranslateAttachment {
            isleft = !attach.isOutgoingMsg
            emptyHeaderView.isHidden = !isleft
            avatarHeaderView.isHidden = true
        }
        if isleft {
            wholeContentStackView.addArrangedSubview(avatarHeaderView)
            wholeContentStackView.addArrangedSubview(emptyHeaderView)
            wholeContentStackView.addArrangedSubview(allContentStackView)
            allContentStackView.alignment = .leading
        }else{
            wholeContentStackView.addArrangedSubview(allContentStackView)
            wholeContentStackView.addArrangedSubview(avatarHeaderView)
            allContentStackView.alignment = .trailing
        }
        
        bubbleImage.image = isleft ? defaultReceiverImage : defaultSenderImage
        if let customType = model.customType {
            if customType == .Egg {
                bubbleImage.image = isleft ? receiverRedPacket : senderRedPacket
            } else if customType == .Translate {
                bubbleImage.image = isleft ? leftBackgroundImg : rightBackgroundImg
            }
        }
        
        tickImage.isHidden = true
        failImage.isHidden = true
        pinendImage.isHidden = true
        tickImage.snp.remakeConstraints { make in
            make.height.width.equalTo(15)
        }
        pinendImage.snp.remakeConstraints { make in
            make.height.width.equalTo(15)
        }
        pinendImage.isHidden = !model.isPinned
        if isleft {
            wholeContentStackView.snp.remakeConstraints { make in
                make.left.equalTo(8)
                make.top.bottom.equalToSuperview().inset(8)
                make.width.lessThanOrEqualTo(ScreenWidth - 120)
            }
            avatarHeaderView.snp.remakeConstraints { make in
                make.left.top.equalToSuperview()
                make.height.width.equalTo(40)
            }
            emptyHeaderView.snp.remakeConstraints { make in
                make.top.equalToSuperview()
                make.height.width.equalTo(40)
            }
            allContentStackView.snp.remakeConstraints { make in
                make.top.equalToSuperview()
            }
            nicknameLabel.snp.remakeConstraints { make in
                make.left.top.equalToSuperview()
            }
            
            failImage.snp.remakeConstraints { make in
                make.centerY.equalTo(bubbleView.snp.centerY)
                make.height.width.equalTo(18)
                make.left.equalTo(wholeContentStackView.snp.right).offset(-8)
            }
            pulseIndicator.snp.remakeConstraints { make in
                make.centerY.equalTo(bubbleView.snp.centerY)
                make.height.equalTo(18)
                make.left.equalTo(wholeContentStackView.snp.right).offset(-8)
            }
        }else{
            wholeContentStackView.snp.remakeConstraints { make in
                make.right.equalTo(-8)
                make.top.bottom.equalToSuperview().inset(8)
                make.width.lessThanOrEqualTo(ScreenWidth - 120)
            }
            avatarHeaderView.snp.remakeConstraints { make in
                make.right.top.equalToSuperview()
                make.height.width.equalTo(40)
            }
            allContentStackView.snp.remakeConstraints { make in
                make.top.equalToSuperview()
            }
            
            
            failImage.snp.remakeConstraints { make in
                make.centerY.equalTo(bubbleView.snp.centerY)
                make.height.width.equalTo(18)
                make.right.equalTo(wholeContentStackView.snp.left).offset(-8)
            }
            
            pulseIndicator.snp.remakeConstraints { make in
                make.centerY.equalTo(bubbleView.snp.centerY)
                make.right.equalTo(wholeContentStackView.snp.left).offset(-10)
            }
            
            nicknameLabel.snp.remakeConstraints { make in
                make.right.top.equalToSuperview()
            }
            tickImage.image = model.unreadCount == 0 ? readImage : unreadImage
            
            if messageModel.sendingState != .MESSAGE_SENDING_STATE_FAILED {
                tickImage.isHidden = false
            }else{
                failImage.isHidden = false
            }
            
        }
        
        MessageUtils.getAvatarIcon(sessionId: messageModel.senderId ?? "", conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
            self?.avatarHeaderView.avatarInfo = avatarInfo
        }
        
        timeLabel.text = messageModel.createTime.messageTimeString()
        
        if (model.messageType == .MESSAGE_TYPE_IMAGE || model.messageType == .MESSAGE_TYPE_VIDEO) && model.messageList.count < 4  {
            timeLabel.textColor = .white
        } else {
            timeLabel.textColor = UIColor(hex: "#808080")
        }
        
        failImage.isHidden = hideErrorButton(model.nimMessageModel)
        pulseIndicator.isHidden = hideloadingView(model.nimMessageModel)
    }
    
    private func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.delegate = self
        bubbleView.addGestureRecognizer(longPressGesture)
        
        let longPressGesture1 = UILongPressGestureRecognizer(target: self, action: #selector(avatarLongPress(_:)))
        longPressGesture1.delegate = self
        avatarHeaderView.addGestureRecognizer(longPressGesture1)
    }
    
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            // 长按手势开始，执行你的操作
            self.delegate?.handleBaseMessageCellLongPress(cell: self, model: contentModel)
        }
    }
    
    @objc private func avatarLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            // 长按手势开始，执行你的操作
            self.delegate?.longPressUserAvatar(cell: self, model: contentModel)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    func formMentionNamesContent(content: NSMutableAttributedString, usernames: [String], completion: @escaping (NSMutableAttributedString?) -> Void ) {
        let mutableAttributedString = content
        let dispatchGroup = DispatchGroup()
        for item in usernames {
            dispatchGroup.enter()
            MessageUtils.getAvatarIcon(sessionId: item, conversationType: .CONVERSATION_TYPE_P2P) { avatarInfo in
                let nickName = avatarInfo.nickname ?? ""
                guard let regex = try? NSRegularExpression(pattern: "@\(nickName)", options: []) else {
                    dispatchGroup.leave()
                    return }
                let matches = regex.enumerateMatches(in: mutableAttributedString.string,
                                                     range: NSRange(mutableAttributedString.string.startIndex..<mutableAttributedString.string.endIndex, in: mutableAttributedString.string)
                ) { (matchResult, _, stop) -> () in
                    if let match = matchResult {
                        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: TGAppTheme.primaryColor, range: match.range)
                    }
                   
                }
                dispatchGroup.leave()
            }
            
        }
        dispatchGroup.notify(queue: .main){
            completion(mutableAttributedString)
        }
        
    }
    
    func formMentionAllContent(content: NSMutableAttributedString, mentionAll: String) -> NSMutableAttributedString {
        let mutableAttributedString = content
        
        guard let regex = try? NSRegularExpression(pattern: "@\(mentionAll)", options: []) else { return mutableAttributedString }
        let matches = regex.enumerateMatches(in: mutableAttributedString.string,
                                             range: NSRange(mutableAttributedString.string.startIndex..<mutableAttributedString.string.endIndex, in: mutableAttributedString.string)
        ) { (matchResult, _, stop) -> () in
            if let match = matchResult {
                mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: TGAppTheme.primaryColor, range: match.range)
            }
        }
        
        return mutableAttributedString
    }
    
    private func hideErrorButton(_ message: V2NIMMessage?) -> Bool {
        guard let message = message else {
            return true
        }
        
        if message.isSelf {
            if let yidunAntiSpamRes = message.antispamConfig?.antispamExtension, yidunAntiSpamRes.isEmpty == false {
                return false
            } else if let localExt = message.localExtension?.toDictionary, let yidunAntiSpam = localExt["yidunAntiSpamRes"] as? String, yidunAntiSpam.isEmpty == false {
                return false
            }
            return message.sendingState != .MESSAGE_SENDING_STATE_FAILED
        } else {
            return true
        }
    }
    private func hideloadingView(_ message: V2NIMMessage?) -> Bool{
        guard let message = message else {
            pulseIndicator.stopAnimating()
            return true
        }
        if message.isSelf {
            pulseIndicator.startAnimating()
            message.sendingState == .MESSAGE_SENDING_STATE_SENDING ? pulseIndicator.startAnimating() : pulseIndicator.stopAnimating()
            return message.sendingState != .MESSAGE_SENDING_STATE_SENDING
        } else {
            pulseIndicator.stopAnimating()
            return true
        }
    }
}

extension TimeInterval {
    func messageTimeString() -> String {
        let date = Date(timeIntervalSince1970: self)
        let df = DateFormatter()
        df.dateFormat = "hh:mm a"
        return df.string(from: date)

    }
}

