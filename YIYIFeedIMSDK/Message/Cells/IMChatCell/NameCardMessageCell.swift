//
//  NameCardMessageCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2024/12/30.
//

import UIKit

class NameCardMessageCell: BaseMessageCell {
    
    let leftSeparatorColor = UIColor(red: 216.0/255.0, green: 216.0/255.0, blue: 216.0/255.0, alpha: 1)
    let rightSeparatorColor = UIColor(hex: 0xD9D9D9)
    
    lazy var profileView: TGAvatarView = {
        let view = TGAvatarView(type: .custom(avatarWidth: 50, showBorderLine: false))
        let avatar = AvatarInfo()
        avatar.avatarPlaceholderType = .unknown
        view.avatarInfo = avatar
        return view
    }()
    let buttonForVerified = UIButton(type: .custom)
    lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.font = TGAppTheme.Font.regular(TGFontSize.defaultLocationDefaultFontSize)
        label.textColor = UIColor(hex: 0x4A5553)
        label.text = "Contact"
        label.numberOfLines = 1
        return label
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = leftSeparatorColor
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = TGAppTheme.Font.regular(TGFontSize.defaultTextFontSize)
        label.textColor = .black
        label.text = ""
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
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
        bubbleImage.addSubview(profileView)
        bubbleImage.addSubview(nameLabel)
        bubbleImage.addSubview(typeLabel)
        bubbleImage.addSubview(separatorView)
        bubbleImage.addSubview(timeTickStackView)
        profileView.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.top.equalToSuperview().inset(8)
            make.left.equalTo(12)
        }
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileView.snp.centerY)
            make.left.equalTo(profileView.snp.right).offset(5)
        }
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom).offset(7)
            make.width.equalTo(201)
            make.height.equalTo(1)
            make.left.right.equalToSuperview().inset(12)
        }
        typeLabel.snp.makeConstraints { make in
            make.leading.equalTo(12)
            make.top.equalTo(separatorView.snp.bottom).offset(5)
            make.bottom.equalTo(-5)
        }
        timeTickStackView.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.top.equalTo(separatorView.snp.bottom).offset(5)
            make.bottom.equalTo(-5)
        }
    }
    
    override func setData(model: TGMessageData) {
        super.setData(model: model)
        guard let message = model.nimMessageModel, let attachment = model.customAttachment as? IMContactCardAttachment else { return }
        separatorView.backgroundColor = !message.isSelf ? leftSeparatorColor : rightSeparatorColor
        let memberId = attachment.memberId
        MessageUtils.getAvatarIcon(sessionId: memberId, conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
            DispatchQueue.main.async {
                self?.profileView.avatarInfo = avatarInfo
                self?.nameLabel.text = avatarInfo.nickname
            }
        }
        
    }

}
