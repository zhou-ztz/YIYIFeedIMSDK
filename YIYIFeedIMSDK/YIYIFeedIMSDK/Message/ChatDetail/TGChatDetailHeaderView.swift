//
//  TGChatDetailHeaderView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/17.
//

import UIKit

class TGChatDetailHeaderView: UITableViewHeaderFooterView {

    lazy var avatar: TGAvatarView = {
        let avatar = TGAvatarView(type: .width60(showBorderLine: false))
        return avatar
    }()
    
    lazy var userName: UILabel = {
        let lab = UILabel()
        lab.textColor = RLColor.share.black3
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.numberOfLines = 1
        lab.text = ""
        lab.textAlignment = .center
        return lab
    }()
    
    lazy var inviteButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.set_image(named: "btn_chatdetail_add"), for: .normal)
        return btn
    }()
    
    let stackView: UIStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 3
    }
    var inviteHandler: (() -> Void)?
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commitUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commitUI() {
        backgroundColor = .white
        contentView.addSubview(stackView)
        contentView.addSubview(inviteButton)
        stackView.addArrangedSubview(avatar)
        stackView.addArrangedSubview(userName)
        stackView.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.centerY.equalToSuperview()
        }
        inviteButton.snp.makeConstraints { make in
            make.left.equalTo(stackView.snp.right).offset(14)
            make.centerY.equalTo(stackView)
            make.width.height.equalTo(60)
        }
        avatar.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.left.right.equalTo(0)
        }
        inviteButton.addTarget(self, action: #selector(inviteAction), for: .touchUpInside)
    }
    
    @objc func inviteAction() {
        self.inviteHandler?()
    }
    
    func configure(sessionId: String) {
        MessageUtils.getAvatarIcon(sessionId: sessionId, conversationType: .CONVERSATION_TYPE_P2P) { [weak self] avatarInfo in
            self?.userName.text = avatarInfo.nickname
            self?.avatar.avatarInfo = avatarInfo
        }
    }
}
