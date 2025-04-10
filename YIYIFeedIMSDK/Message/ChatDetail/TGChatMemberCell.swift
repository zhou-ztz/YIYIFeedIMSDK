//
//  TGChatMemberCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/20.
//

import UIKit

protocol TGChatMemberCellDelegate: AnyObject {
    func didPressAvatarAction(member: TeamMember)
    func didPressAddAction(member: TeamMember)
}

class TGChatMemberCell: UICollectionViewCell {
    
    let memberImage: TGAvatarView = TGAvatarView()
    let memberImageAdd: UIImageView = UIImageView()
    lazy var memberName: UILabel = {
        let lab = UILabel()
        return lab
    }()
    
    lazy var memberTypeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.textAlignment = .center
        lab.font = UIFont.systemFont(ofSize: 9)
        return lab
    }()
    
    let memberTypeLabelView: UIView = UIView()
    
    var member: TeamMember?
    weak var delegate: TGChatMemberCellDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        
        self.contentView.addSubview(memberImage)
        self.contentView.addSubview(memberImageAdd)
        self.contentView.addSubview(memberName)
        self.contentView.addSubview(memberTypeLabelView)
        memberTypeLabelView.addSubview(memberTypeLabel)
        memberImage.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(2)
            make.height.width.equalTo(44)
            make.centerX.equalToSuperview()
        }
        memberImage.roundCorner(22)
        memberImageAdd.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(2)
            make.height.width.equalTo(44)
            make.centerX.equalToSuperview()
        }
        memberImageAdd.roundCorner(22)
        memberName.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(memberImage.snp.bottom).offset(3)
        }
        memberName.textAlignment = NSTextAlignment.center
        memberName.font = UIFont.systemFont(ofSize: 12)
        memberName.textColor = RLColor.normal.minor
        
        memberTypeLabelView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(memberImage.snp.top)
        }
        memberTypeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.right.left.bottom.top.equalToSuperview().inset(2)
        }
        
        memberImageAdd.layer.masksToBounds = true
        memberImageAdd.layer.borderColor = UIColor.white.cgColor
        memberImageAdd.layer.borderWidth = 2
        memberImageAdd.contentMode = .scaleAspectFit
        
        memberTypeLabel.sizeToFit()
        memberTypeLabelView.layer.cornerRadius = 3
        memberTypeLabelView.layer.borderColor = UIColor.white.cgColor
        memberTypeLabelView.layer.borderWidth = 1
        memberTypeLabelView.sizeToFit()
        memberTypeLabelView.backgroundColor = RLColor.main.blue
        memberTypeLabelView.makeHidden()
        memberImageAdd.addAction {[weak self] in
            if let member = self?.member {
                self?.delegate?.didPressAddAction(member: member)
            }
        }

    }
    
    func setData(_ member: TeamMember) {
        self.member = member
        self.memberName.isHidden = true
        if member.isAdd {
            self.addMemberView()
        } else if member.isReduce {
            self.removeMemberView()
        } else if member.isViewMore {
            self.viewMore()
        } else {
            self.memberImage.isHidden = false
            self.memberImageAdd.isHidden = true
            self.memberName.isHidden = false
            // MARK: REMARK NAME
            self.memberName.text = member.memberInfo?.accountId
            if let nick = member.memberInfo?.teamNick, nick.count > 0 {
                self.memberName.text =  nick
            }
            let avatarInfo = TGAvatarInfo()
            avatarInfo.avatarPlaceholderType = .unknown
            self.memberImage.avatarInfo = avatarInfo
            
            if let memberinfo = member.memberInfo {
                switch memberinfo.memberRole {
                case .TEAM_MEMBER_ROLE_MANAGER:
                    self.memberTypeLabelView.makeVisible()
                    self.memberTypeLabel.text = "team_admin".localized
                    self.memberTypeLabelView.layer.backgroundColor = TGAppTheme.orange.cgColor
                case .TEAM_MEMBER_ROLE_OWNER:
                    self.memberTypeLabelView.makeVisible()
                    self.memberTypeLabel.text = "team_creator".localized
                    self.memberTypeLabelView.layer.backgroundColor = TGAppTheme.aquaBlue.cgColor
                default:
                    self.memberTypeLabelView.makeHidden()
                }
            }
            
            setAvatar(member: member)
        }
 
    }
    
    func addMemberView() {
        self.memberImage.isHidden = true
        self.memberImageAdd.isHidden = false
        memberTypeLabelView.makeHidden()
        memberImageAdd.image = UIImage(named: "btn_chatdetail_add")
    }
    
    func removeMemberView() {
        self.memberImage.isHidden = true
        self.memberImageAdd.isHidden = false
        memberTypeLabelView.makeHidden()
        memberImageAdd.image = UIImage(named: "btn_chatdetail_reduce")
        
    }
    
    func viewMore() {
        self.memberImage.isHidden = true
        self.memberImageAdd.isHidden = false
        memberTypeLabelView.makeHidden()
        memberImageAdd.image = UIImage(named: "btn_chatdetail_more")
    }
    
    func setAvatar(member: TeamMember) {
        
        MessageUtils.getAvatarIcon(sessionId: member.memberInfo?.accountId ?? "", conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.memberImage.avatarInfo = avatarInfo
                self.memberName.text = avatarInfo.nickname
                if let nick = member.memberInfo?.teamNick, nick.count > 0 {
                    self.memberName.text =  nick
                }
                self.memberImage.buttonForAvatar.removeAllTargets()
                self.memberImage.buttonForAvatar.addTarget(self, action: #selector(self.didAvatarAction), for: .touchUpInside)
            }
        }
    }
    
    @objc func didAvatarAction() {
        if let member = self.member {
            self.delegate?.didPressAvatarAction(member: member)
        }
    }
    
    
}
