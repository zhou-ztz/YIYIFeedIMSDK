//
//  TGMessageRequestCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/16.
//

import UIKit
import NIMSDK

protocol TGMessageRequestCellDelegate: AnyObject {
    func buttonActionDelegate(isAccept: Bool, indexPath: IndexPath)
}

class TGMessageRequestCell: UITableViewCell {
    
    lazy var avatarView: TGAvatarView = {
        let avatarView = TGAvatarView(type: .width70(showBorderLine: false))
        avatarView.avatarPlaceholderType = .unknown
        return avatarView
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = RLColor.share.black3
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.numberOfLines = 1
        return lab
    }()
    lazy var descLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = RLColor.normal.minor
        lab.font = UIFont.systemFont(ofSize: 11)
        lab.numberOfLines = 1
        return lab
    }()
    lazy var acceptButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }()
    lazy var rejectButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }()
    var indexPath: IndexPath!
    weak var delegate: TGMessageRequestCellDelegate?
    static let cellReuseIdentifier = "TGMessageRequestCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.setUI()
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        selectionStyle = .none
        self.contentView.addSubview(avatarView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(descLabel)
        self.contentView.addSubview(acceptButton)
        self.contentView.addSubview(rejectButton)
        avatarView.snp.makeConstraints { make in
            make.height.width.equalTo(70)
            make.top.equalTo(12)
            make.left.equalTo(10)
            make.bottom.equalTo(-12)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(avatarView.snp.right).offset(8)
            make.right.equalTo(-10)
        }
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.equalTo(avatarView.snp.right).offset(8)
            make.right.equalTo(-10)
        }
        
        let width = (ScreenWidth - 118) / 2
        
        acceptButton.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(6)
            make.left.equalTo(avatarView.snp.right).offset(8)
            make.height.equalTo(30)
            make.width.equalTo(width)
        }
        
        rejectButton.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(6)
            make.right.equalTo(-20)
            make.height.equalTo(30)
            make.width.equalTo(width)
        }
        acceptButton.setTitle("accept_session".localized, for: .normal)
        acceptButton.backgroundColor = RLColor.main.red
        acceptButton.setTitleColor(RLColor.main.white, for: .normal)
        acceptButton.layer.cornerRadius = 10
        
        rejectButton.setTitle("reject_session".localized, for: .normal)
        rejectButton.backgroundColor = UIColor(hex: 0xE5E6EB)
        rejectButton.setTitleColor(RLColor.normal.blackTitle, for: .normal)
        rejectButton.layer.cornerRadius = 10
        
        descLabel.text = "sdfdfdfdfdfd"
        titleLabel.text = "qweqwererere"
        acceptButton.addTarget(self, action: #selector(acceptAction), for: .touchUpInside)
        rejectButton.addTarget(self, action: #selector(rejectAction), for: .touchUpInside)
    }
    @objc func acceptAction() {
        self.delegate?.buttonActionDelegate(isAccept: true, indexPath: indexPath)
    }
    @objc func rejectAction() {
        self.delegate?.buttonActionDelegate(isAccept: false, indexPath: indexPath)
    }
    
    func updatePersonalCell(data: TGMessageRequestModel) {
        guard let userInfo = data.user else { return }
        
        titleLabel.text = ""
        descLabel.text = ""

        avatarView.avatarPlaceholderType = .unknown
        avatarView.avatarInfo = userInfo.avatarInfo()
        
        titleLabel.text = data.user?.name
        
        let userId = userInfo.userIdentity
        let username = userInfo.username
        let name = userInfo.name
        
        // MARK: REMARK NAME
        TGLocalRemarkName.getRemarkName(userId: "\(userId)", username: username, originalName: name, label: titleLabel)
        descLabel.text = data.messageDetail?.content
        
        if data.fromUserID == RLSDKManager.shared.loginParma?.uid ?? 0 {
            acceptButton.isHidden = true
        } else {
            acceptButton.isHidden = false
        }
    }
    
    func updateGroupCell(data: V2NIMTeamJoinActionInfo?) {
        titleLabel.text = ""
        descLabel.text = ""
        acceptButton.isHidden = false
    
        guard let noti = data else { return }
        let sourceID = noti.operatorAccountId
        avatarView.avatarPlaceholderType = .unknown
        MessageUtils.getAvatarIcon(sessionId: sourceID, conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
            self?.avatarView.avatarInfo = avatarInfo
            self?.titleLabel.text = avatarInfo.nickname ?? ""
        }
        var teamName = ""
        MessageUtils.getTeamInfo(teamId: noti.teamId, teamType: noti.teamType) {[weak self] team in
            if let team = team {
                teamName = team.name
                switch noti.actionType {
                case .TEAM_JOIN_ACTION_TYPE_APPLICATION:
                    self?.descLabel.text = String(format: "request_join_group".localized, teamName)
                    
                case .TEAM_JOIN_ACTION_TYPE_REJECT_APPLICATION:
                    self?.descLabel.text = String(format: "group_denied_your_apply".localized, teamName)
                    
                case .TEAM_JOIN_ACTION_TYPE_INVITATION:
                    self?.descLabel.text = String(format: "text_group_invitation".localized, teamName)
                    
                case .TEAM_JOIN_ACTION_TYPE_REJECT_INVITATION:
                    self?.descLabel.text = String(format: "user_denied_invitation_join_group".localized, teamName)
                    
                default:
                    break
                }
                
                switch noti.actionStatus {
                case .TEAM_JOIN_ACTION_STATUS_AGREED:
                    self?.descLabel.text = String(format: "notification_group_joined".localized, teamName)
                case .TEAM_JOIN_ACTION_STATUS_REJECTED:
                    self?.descLabel.text = "Rejected".localized
                case .TEAM_JOIN_ACTION_STATUS_EXPIRED:
                    self?.descLabel.text = "text_expired".localized
                default:
                    break
                }
            }
        }

    }
}
