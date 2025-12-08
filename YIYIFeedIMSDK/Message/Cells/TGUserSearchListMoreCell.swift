//
//  TGUserSearchListMoreCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/18.
//

import UIKit

class TGUserSearchListMoreCell: UITableViewCell {

    static let identifier = "TGUserSearchListMoreCell"
    
    lazy var headerAvatarView: TGAvatarView = {
        let view = TGAvatarView(type: .width48(showBorderLine: false))
        return view
    }()
    
    lazy var headerTitle: UILabel = {
        let label = UILabel()
        label.textColor = TGAppTheme.black
        label.font = UIFont.systemFont(ofSize: TGFontSize.chatroomMsgFontSize)
        label.numberOfLines = 1
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        contentView.addSubview(headerAvatarView)
        contentView.addSubview(headerTitle)
        
        headerAvatarView.snp.makeConstraints({make in
            make.top.equalTo(5)
            make.width.height.equalTo(48)
            make.left.equalTo(10)
        })
        
        headerTitle.snp.makeConstraints { make in
            make.left.equalTo(headerAvatarView.snp.right).offset(10)
            make.right.equalTo(-10)
            make.top.equalTo(20)
            make.height.equalTo(20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func refreshUser(withUser user: TGUserInfoModel) {
        headerAvatarView.avatarInfo = user.avatarInfo()
        headerTitle.text = user.displayName
    }

}
