//
//  ContactCardCollectView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/13.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

class ContactCardCollectView: BaseCollectView {
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()
    
    lazy var imageView: TGAvatarView = {
        let view = TGAvatarView(type: .width43(showBorderLine: false))
        view.avatarPlaceholderType = .unknown
        return view
    }()
    
    lazy var contentLable: UILabel = {
        let name = UILabel()
        name.textColor = UIColor(red: 0, green: 0, blue: 0)
        name.font = UIFont.boldSystemFont(ofSize: 15)
        name.textAlignment = .left
        name.numberOfLines = 1
        name.text = "Suria KLCC, Kuala Lumpur"
        return name
    }()

    override init(collectModel: FavoriteMsgModel, indexPath: IndexPath) {
        super.init(collectModel: collectModel, indexPath: indexPath)
        self.commitUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commitUI() {
        self.contactAttachmentForJson(josnStr: self.collectModel.data)
        if let dict = self.attchDict?[CMData] as? [String: String], let memberId = dict[CMContactCard] {
            
            guard let model = self.dictModel else {return}
            self.nameLable.text = model.fromAccount
            MessageUtils.getAvatarIcon(sessionId: model.fromAccount, conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
                self?.avatarView.avatarInfo = avatarInfo
                self?.nameLable.text = avatarInfo.nickname
            }
            
            MessageUtils.getAvatarIcon(sessionId: memberId, conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
                self?.imageView.avatarInfo = avatarInfo
                self?.contentLable.text = avatarInfo.nickname
            }

            if model.sessionType == "Team" {
                self.contentStackView.addArrangedSubview(stackView)
                self.stackView.addArrangedSubview(imageView)
                self.stackView.addArrangedSubview(contentLable)
                self.contentStackView.addArrangedSubview(groupView)
            } else {
                self.contentStackView.addArrangedSubview(stackView)
                self.stackView.addArrangedSubview(imageView)
                self.stackView.addArrangedSubview(contentLable)
            }
            
            self.stackView.snp.makeConstraints { (make) in
                make.height.equalTo(43)
            }
            
            self.imageView.snp.makeConstraints { (make) in
                make.height.width.equalTo(43)
            }
            
            self.contentLable.snp.makeConstraints { (make) in
                make.height.equalTo(25)
            }
            
            self.contentStackView.snp.makeConstraints { (make) in
                make.top.left.equalTo(12)
                make.bottom.equalTo(-12)
                make.right.equalTo(-50)
            }
        }
    }
    
}
