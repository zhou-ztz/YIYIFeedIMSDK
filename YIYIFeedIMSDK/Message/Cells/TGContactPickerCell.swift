//
//  TGContactPickerCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/2.
//

import UIKit

protocol TGContactPickerCellDelegate: AnyObject {
    func chatButtonClick(chatbutton: UIButton, userModel: ContactData)
}


class TGContactPickerCell: TGChatChooseFriendCell {

    weak var pickerDelegate: TGContactPickerCellDelegate?
    var blurCover = UIView()
    var contactData: ContactData? {
        didSet {
            guard let model = contactData else { return }
            
            
            if model.userName == "rw_text_all_people".localized {
                avatarImageView.avatarPlaceholderType = .unknown
                avatarImageView.avatarInfo = AvatarInfo()
            }
            
            MessageUtils.getAvatarIcon(sessionId: model.userName, conversationType: model.isTeam ? .CONVERSATION_TYPE_TEAM : .CONVERSATION_TYPE_P2P) { [weak self] avatarInfo in
                self?.avatarImageView.avatarInfo = avatarInfo
                self?.nameLabel.text = avatarInfo.nickname ?? ""
                model.displayname = avatarInfo.nickname ?? ""
                if (self?.nameLabel.text ?? "").isEmpty {
                    self?.nameLabel.text = model.userName
                }
            }
            
            
            
            chatButton.isSelected = false
            chatButton.setImage(UIImage(named: "ic_rl_checkbox_selected"), for: UIControl.State.selected)
            if model.isBannedUser {
                blurCover.backgroundColor = UIColor.white.withAlphaComponent(0.7)
                addSubview(blurCover)
                blurCover.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
            }
            for (_, element) in currentChooseArray.enumerated() {
                let userinfo: ContactData = element as! ContactData
                if userinfo.userName == model.userName {
                    chatButton.isSelected = true
                    break
                }
            }
            
            for (_, origin) in originData.enumerated() {
                let userinfo: String = origin as! String
                if userinfo == model.userName {
                    chatButton.isSelected = true
                    chatButton.setImage(UIImage(named: "msg_box_choose_before"), for: UIControl.State.selected)
                    break
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        blurCover.backgroundColor = UIColor.clear
    }
    
    override func changeButtonStatus() {
        guard let data = contactData else { return }
        pickerDelegate?.chatButtonClick(chatbutton: chatButton, userModel: data)
    }

}
