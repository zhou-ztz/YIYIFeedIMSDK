//
//  BaseMessageCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/4.
//

import UIKit

protocol BaseMessageCellDelegate: AnyObject {
    
    func tapItemMessage(cell: BaseMessageCell?, model: TGMessageData?)
    func handleBaseMessageCellLongPress(cell: BaseMessageCell, model: TGMessageData?)
    func tapUserAvatar(cell: BaseMessageCell?, model: TGMessageData?)
}

class BaseMessageCell: UITableViewCell {
    weak var delegate: BaseMessageCellDelegate?
    
    var contentModel: TGMessageData?
    let defaultSenderImage = UIImage.set_image(named: "senderMessage")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 18), resizingMode: .stretch)
    let defaultReceiverImage = UIImage.set_image(named: "receiverMessage")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 10), resizingMode: .stretch)
    
    let senderRedPacket = UIImage.set_image(named: "pink_bubble_right")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 18), resizingMode: .stretch)
    let receiverRedPacket = UIImage.set_image(named: "pink_bubble_left")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 10), resizingMode: .stretch)
    
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
    lazy var avatarHeaderView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.set_image(named: "defaultProfile")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = false
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var timeTickStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .fill
        stackView.alignment = .bottom
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.setUI()
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI(){
        
        self.contentView.addSubview(wholeContentStackView)
        self.contentView.addSubview(failImage)
        wholeContentStackView.addArrangedSubview(avatarHeaderView)
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
        failImage.addAction {
            
        }
    }
    
    func setData(model: TGMessageData){
        contentModel = model
        guard let messageModel = model.nimMessageModel else { return }
        
        nicknameLabel.isHidden = !(model.showName ?? false)
        wholeContentStackView.removeAllArrangedSubviews()
        
        let isleft = !messageModel.isSelf
        if isleft {
            wholeContentStackView.addArrangedSubview(avatarHeaderView)
            wholeContentStackView.addArrangedSubview(allContentStackView)
            allContentStackView.alignment = .leading
        }else{
            wholeContentStackView.addArrangedSubview(allContentStackView)
            wholeContentStackView.addArrangedSubview(avatarHeaderView)
            allContentStackView.alignment = .trailing
        }
        avatarHeaderView.isHidden = isleft ? false : true
        bubbleImage.image = isleft ? defaultReceiverImage : defaultSenderImage
        tickImage.isHidden = true
        failImage.isHidden = true
        pinendImage.isHidden = true
        tickImage.snp.remakeConstraints { make in
            make.height.width.equalTo(15)
        }
        pinendImage.snp.remakeConstraints { make in
            make.height.width.equalTo(15)
        }
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
            allContentStackView.snp.remakeConstraints { make in
                make.top.equalToSuperview()
            }
            nicknameLabel.snp.remakeConstraints { make in
                make.left.top.equalToSuperview()
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
            
            nicknameLabel.snp.remakeConstraints { make in
                make.right.top.equalToSuperview()
            }
            tickImage.image = messageModel.isSelf ? readImage : unreadImage
            
            if messageModel.sendingState != .MESSAGE_SENDING_STATE_FAILED {
                tickImage.isHidden = false
            }else{
                failImage.isHidden = false
            }
        }
        
        MessageUtils.getUserShowNameAvatar(conversationId: model.nimMessageModel?.conversationId ?? "") {[weak self] name, avatar in
            self?.avatarHeaderView.sd_setImage(with: URL(string: avatar ?? ""), placeholderImage: UIImage.set_image(named: "defaultProfile"))
        }
        //avatarHeaderView.sd_setImage(with: URL(string: messageModel.senderId ?? ""), placeholderImage: UIImage.set_image(named: "defaultProfile"))
        
        timeLabel.text = messageModel.createTime.messageTimeString()
        
    }
    
    private func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.delegate = self
        bubbleImage.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            // 长按手势开始，执行你的操作
            self.delegate?.handleBaseMessageCellLongPress(cell: self, model: contentModel)
        }
    }

}

extension TimeInterval {
    func messageTimeString() -> String {
        let date = Date(timeIntervalSince1970: self)
        let df = DateFormatter()
        //df.dateFormat = "MM-dd HH:mm"
        df.dateFormat = "hh:mm a"
        return df.string(from: date)

    }
}

