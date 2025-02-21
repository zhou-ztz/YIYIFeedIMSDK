//
//  TGIMSearchMessageContentCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/17.
//

import UIKit
import NIMSDK

// 定义常量
let SearchCellTitleFontSize: CGFloat = 13
let SearchCellContentFontSize: CGFloat = 12
let SearchCellTimeFontSize: CGFloat = 12

let SearchCellAvatarLeft: CGFloat = 15
let SearchCellAvatarAndTitleSpacing: CGFloat = 10
let SearchCellTitleTop: CGFloat = 10
let SearchCellTimeRight: CGFloat = 15
let SearchCellTimeTop: CGFloat = 10
let SearchCellContentTop: CGFloat = 30
let SearchCellContentBottom: CGFloat = 8
let SearchCellContentMaxWidth: CGFloat = 260
let SearchCellContentMinHeight: CGFloat = 15

let nameLabelMaxSize: CGFloat = 120

class TGIMSearchMessageContentCell: UITableViewCell {

    lazy var avatar: TGAvatarView = {
        let imageView = TGAvatarView()
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: SearchCellTitleFontSize)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: SearchCellContentFontSize)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: SearchCellTimeFontSize)
        label.textColor = .lightGray
        return label
    }()
    
    lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        return view
    }()
    
    var object: TGIMSearchLocalHistoryObject?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(avatar)
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(line)
    }
    
    private func setupConstraints() {
        avatar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(SearchCellTitleTop)
            make.left.equalToSuperview().offset(SearchCellAvatarLeft)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(SearchCellTitleTop)
            make.left.equalTo(avatar.snp.right).offset(SearchCellAvatarAndTitleSpacing)
            make.width.lessThanOrEqualTo(nameLabelMaxSize)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom)
            make.width.lessThanOrEqualTo(SearchCellContentMaxWidth)
            make.height.greaterThanOrEqualTo(SearchCellContentMinHeight)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-SearchCellTimeRight)
            make.top.equalToSuperview().offset(SearchCellTimeTop)
        }
        
        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-1)
            make.height.equalTo(1)
        }
    }
    
    func refresh(_ object: TGIMSearchLocalHistoryObject) {
        self.object = object
        let message = object.message
        var messageString = ""
        MessageUtils.getAvatarIcon(sessionId: message.senderId ?? "", conversationType: message.conversationType) {[weak self] avatarInfo in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.titleLabel.text = avatarInfo.nickname
                self.avatar.avatarInfo = avatarInfo
                if message.conversationType == .CONVERSATION_TYPE_P2P {
                    messageString = message.text ?? ""
                } else {
                    if message.senderId == (NIMSDK.shared().v2LoginService.getLoginUser() ?? ""){
                        messageString =  "You".localized + ": " + (message.text ?? "")
                    } else {
                        let nick = avatarInfo.nickname ?? ""
                        messageString = "\(nick): " + (message.text ?? "")
                    }
                }
                self.contentLabel.text = messageString
            }
        }
        
        timeLabel.text = TGDate().dateString(.normal, nsDate: NSDate(timeIntervalSince1970: message.createTime))
    }
}


