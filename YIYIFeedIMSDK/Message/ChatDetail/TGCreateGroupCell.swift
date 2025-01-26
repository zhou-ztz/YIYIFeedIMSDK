//
//  TGCreateGroupCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/17.
//

import UIKit

class TGCreateGroupCell: UITableViewCell {
    /// 头像
    var avatarImageView: TGAvatarView! = TGAvatarView(type: .width38(showBorderLine: false), animation: false)
    /// 昵称
    var nameLabel: UILabel!
    
    var stackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.spacing = 15
        $0.distribution = .fill
        $0.alignment = .center
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        creatSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func creatSubView() {
        nameLabel = UILabel()
        nameLabel.textColor = UIColor(hex: 0x333333)
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.textAlignment = NSTextAlignment.left
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview().inset(14)
            make.left.equalTo(15)
            
        }
        
        stackView.addArrangedSubview(avatarImageView)
        stackView.addArrangedSubview(nameLabel)
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(38)
        }
       
        
        
        nameLabel.snp.makeConstraints { make in
            make.right.equalTo(0)
        }
    }

    func setData(model: ContactData){
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = model.imageUrl
        avatarInfo.verifiedIcon = model.verifiedIcon
        avatarInfo.verifiedType = model.verifiedType
        avatarInfo.avatarPlaceholderType = model.isTeam ? .group : .unknown
        avatarInfo.type = .normal(userId: model.userId)
        avatarImageView.avatarPlaceholderType = model.isTeam ? .group : .unknown
        avatarImageView.avatarInfo = avatarInfo
        // MARK: REMARK NAME
        if model.userId == -1 {
            TGLocalRemarkName.getRemarkName(userId: nil, username: model.userName, originalName: model.displayname, label: nameLabel)
        } else {
            TGLocalRemarkName.getRemarkName(userId: String(model.userId), username: nil, originalName: model.displayname, label: nameLabel)
        }
        
    }
}
