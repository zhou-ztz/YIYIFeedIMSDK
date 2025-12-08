//
//  TGMyFriendListCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/13.
//

import UIKit

protocol TGMyFriendListCellDelegate: AnyObject {
    func chatWithUserName(userName: String)
}

class TGMyFriendListCell: UITableViewCell {

    weak var delegate: TGMyFriendListCellDelegate?
    /// 头像
    var avatarImageView: TGAvatarView!
    var businessImageView: UIImageView!
    /// 昵称
    var nameLabel: UILabel!
    /// 简介
    var introLabel: UILabel!
    /// 聊天按钮
    var chatButton: UIButton!
    var chatUserName: String = ""
    var isMerchant: Bool = false
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.creatSubView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func creatSubView() {
        avatarImageView = TGAvatarView(origin: CGPoint(x: 10, y: 15), type: .width38(showBorderLine: false), animation: false)
        self.addSubview(avatarImageView)

        businessImageView = UIImageView(frame: CGRect(x: 16, y: 15, width: 35, height: 35))
        businessImageView.contentMode = .scaleAspectFill
        businessImageView.clipsToBounds = true
        businessImageView.layer.cornerRadius = 17.5
        businessImageView.isHidden = true
        self.addSubview(businessImageView)
        
        nameLabel = UILabel(frame: CGRect(x: avatarImageView.right + 15, y: 15, width: ScreenWidth - avatarImageView.right - 15, height: 17.5))
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.textColor = UIColor(hex: 0x333333)
        nameLabel.textAlignment = NSTextAlignment.left
        self.addSubview(nameLabel)
        chatButton = UIButton(frame: CGRect(x: ScreenWidth - 45, y: 0, width: 45, height: 70))
        chatButton.setTitle(nil, for: .normal)
        chatButton.setImage(UIImage(named: "ico_chat"), for: .normal)
        chatButton.addTarget(self, action: #selector(chatButtonClick(button:)), for: UIControl.Event.touchUpInside)
        self.addSubview(chatButton)
        let width = ScreenWidth - avatarImageView.right - 90 // - (15 - 65 - 10)
        introLabel = UILabel(frame: CGRect(x: avatarImageView.right + 15, y: nameLabel.bottom + 7.5, width: width, height: 14))
        introLabel.font = UIFont.systemFont(ofSize: 14)
        introLabel.textColor = UIColor(hex: 0x999999)
        introLabel.textAlignment = NSTextAlignment.left
        self.addSubview(introLabel)

        let lineView = UIView(frame: CGRect(x: 0, y: 67, width: ScreenWidth, height: 0.5))
        lineView.backgroundColor = UIColor(hex: 0xededed)
        self.addSubview(lineView)
    }

    func setUserInfoData(model: TGUserInfoModel) {
        avatarImageView.isHidden = false
        businessImageView.isHidden = true
        introLabel.isHidden = false
        
        avatarImageView.avatarPlaceholderType = TGAvatarView.PlaceholderType(sexNumber: model.sex)
        avatarImageView.avatarInfo = model.avatarInfo()
        // 用户名
        
        // MARK: REMARK NAME
        _ = TGLocalRemarkName.getRemarkName(userId: "\(model.userIdentity)", username: nil, originalName: model.name, label: nameLabel)

        // 简介
        introLabel.text = model.shortDesc
        chatUserName = model.username
    }
    func setMerchantData(model: TGTaggedBranchData) {
        avatarImageView.isHidden = true
        businessImageView.isHidden = false
        introLabel.isHidden = true
        
        // Center nameLabel horizontally from businessImageView with trailing padding 16
        let nameLabelWidth = ScreenWidth - businessImageView.right - 16 - 15 // 16 for trailing padding, 15 for leading spacing
        nameLabel.frame = CGRect(x: businessImageView.right + 15, y: 25, width: nameLabelWidth, height: 17.5)
        
        if let businessLogo = model.businessLogo {
            businessImageView.sd_setImage(with: URL(string: businessLogo), placeholderImage: UIImage(named: "icPicturePostPlaceholder"))
        }
        
        if let branchName = model.branchName {
            nameLabel.text = branchName
            chatUserName = branchName
        }
    }
    @objc func chatButtonClick(button: UIButton) {
        delegate?.chatWithUserName(userName: chatUserName)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
