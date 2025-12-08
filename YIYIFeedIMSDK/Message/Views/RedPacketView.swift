//
//  RedPacketView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/12.
//

import UIKit
import NIMSDK
class RedPacketView: UIView {
    let stackview = UIStackView()
    let eggImageView = UIImageView()
    let openEggView = UIView()
    let avatarView = TGAvatarView()
    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        // 添加子视图
        addSubview(eggImageView)
        addSubview(openEggView)
        addSubview(stackview)
        stackview.addArrangedSubview(avatarView)
        stackview.addArrangedSubview(nameLabel)
        addSubview(descriptionLabel)
        
        stackview.axis = .horizontal
        stackview.spacing = 5
        stackview.distribution = .fill
        stackview.alignment = .fill
        
        // 配置视图属性
        eggImageView.image = UIImage(named: "open_egg_icon")
        eggImageView.contentMode = .scaleAspectFit
        
        openEggView.backgroundColor = .clear
        
        avatarView.backgroundColor = .clear
        
        nameLabel.text = "Sent by chinghan5"
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.boldSystemFont(ofSize: 12)
        nameLabel.textColor = .white
        
        descriptionLabel.text = "Label"
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        descriptionLabel.textColor = .white
        
        avatarView.avatarPlaceholderType = .unknown
        
        openEggView.roundCorner(55)
    }
    
    private func setupConstraints() {
        
        eggImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(420)
            make.width.equalTo(320)
        }
        
        openEggView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-65)
            make.width.height.equalTo(110)
        }
        stackview.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(openEggView.snp.bottom).offset(15)
        }
        avatarView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.left.equalTo(10)
        }
        avatarView.layer.cornerRadius = 15
        avatarView.clipsToBounds = true
        nameLabel.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.height.equalTo(30)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalTo(eggImageView)
            make.top.equalTo(stackview.snp.bottom).offset(10)
            make.width.equalTo(200)
            make.height.equalTo(18)
        }
    }
    
    func updateInfo(avatarInfo: TGAvatarInfo, name: String, message: String, uids: NSArray? = nil, completion: (() -> Void)? = nil) {
        avatarView.avatarInfo = avatarInfo
        nameLabel.text = "title_sender_send_packet".localized.replacingFirstOccurrence(of: "%s", with: name)
        let currentId = NIMSDK.shared().v2LoginService.getLoginUser() ?? ""
        if let uids = uids, uids.count > 0, let uidsList = uids as? [String] {
            if uidsList.contains(currentId) {
                eggImageView.image = UIImage(named: "open_egg_icon")
                openEggView.isUserInteractionEnabled = true
                
                if message.isEmpty {
                    descriptionLabel.text = "rw_red_packet_best_wishes".localized
                } else {
                    descriptionLabel.text = message
                }
            } else {
                eggImageView.image = UIImage(named: "unable_open_egg_icon")
                openEggView.isUserInteractionEnabled = false
                descriptionLabel.text = "title_specific_packet_title".localized.replacingFirstOccurrence(of: "%s", with: uidsList.first ?? "")
            }
        } else {
            eggImageView.image = UIImage(named: "open_egg_icon")
            openEggView.isUserInteractionEnabled = true
            
            if message.isEmpty {
                descriptionLabel.text = "rw_red_packet_best_wishes".localized
            } else {
                descriptionLabel.text = message
            }
        }
        
        completion?()
    }

}
