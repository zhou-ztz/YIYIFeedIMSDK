//
//  BaseMessageCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/4.
//

import UIKit

protocol BaseMessageCellDelegate: AnyObject {
    
    func tapItemMessage(cell: BaseMessageCell?, model: RLMessageData?)
    func handleBaseMessageCellLongPress(cell: BaseMessageCell, model: RLMessageData?)
    func tapUserAvatar(cell: BaseMessageCell?, model: RLMessageData?)
}

class BaseMessageCell: UITableViewCell {
    weak var delegate: BaseMessageCellDelegate?
    
    var contentModel: RLMessageData?
    let defaultSenderImage = UIImage(named: "chat_message_send")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 18), resizingMode: .stretch)
    let defaultReceiverImage = UIImage(named: "chat_message_receive")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 10), resizingMode: .stretch)
    
    let unreadImage = UIImage(named: "chat_unread_all")
    let readImage = UIImage(named: "chat_read_all")
    
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
        imageView.image = UIImage(named: "sendMessage_failed")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        //imageView.backgroundColor = .lightGray
        return imageView
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
        imageView.image = UIImage(named: "defaultProfile")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = false
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
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
        self.contentView.addSubview(tickImage)
        self.contentView.addSubview(failImage)
        wholeContentStackView.addArrangedSubview(avatarHeaderView)
        wholeContentStackView.addArrangedSubview(allContentStackView)
        
        allContentStackView.addArrangedSubview(nicknameLabel)
        allContentStackView.addArrangedSubview(bubbleView)
        bubbleView.addSubview(bubbleImage)
        bubbleImage.bindToEdges()
        setupLongPressGesture()
        bubbleView.addAction { [weak self] in
            self?.delegate?.tapItemMessage(cell: self, model: self?.contentModel)
        }
        avatarHeaderView.addAction { [weak self] in
            self?.delegate?.tapUserAvatar(cell: self, model: self?.contentModel)
        }
    }
    
    func setData(model: RLMessageData){
        contentModel = model
        guard let messageModel = model.nimMessageModel else { return }
        
        nicknameLabel.isHidden = !(model.showName ?? false)
        wholeContentStackView.removeAllArrangedSubviews()
        let isleft = messageModel.isReceivedMsg 
        if isleft {
            wholeContentStackView.addArrangedSubview(avatarHeaderView)
            wholeContentStackView.addArrangedSubview(allContentStackView)
            allContentStackView.alignment = .leading
        }else{
            wholeContentStackView.addArrangedSubview(allContentStackView)
            wholeContentStackView.addArrangedSubview(avatarHeaderView)
            allContentStackView.alignment = .trailing
        }
        bubbleImage.image = isleft ? defaultReceiverImage : defaultSenderImage
        tickImage.isHidden = true
        failImage.isHidden = true
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
            tickImage.snp.remakeConstraints { make in
                make.bottom.equalToSuperview().inset(9)
                make.height.width.equalTo(14)
                make.right.equalTo(wholeContentStackView.snp.left).offset(-5)
            }
            
            failImage.snp.remakeConstraints { make in
                make.centerY.equalTo(bubbleView.snp.centerY)
                make.height.width.equalTo(18)
                make.right.equalTo(wholeContentStackView.snp.left).offset(-8)
            }
            
            nicknameLabel.snp.remakeConstraints { make in
                make.right.top.equalToSuperview()
            }
            tickImage.image = messageModel.isRemoteRead ? readImage : unreadImage
            
            if messageModel.deliveryState != .failed {
                tickImage.isHidden = false
            }else{
                failImage.isHidden = false
            }
        }
        
        
        
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
