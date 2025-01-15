//
//  ContactTableViewCell.swift
//  Yippi
//
//  Created by Kit Foong on 14/06/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation
import UIKit
import Contacts


class TGNewContactTableViewCell: UITableViewCell {
    static let cellReuseIdentifier = "TGNewContactTableViewCell"
    
    @IBOutlet weak var avatarView: TGAvatarView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
    var onClickAction: EmptyClosure?
    
    class func nib() -> UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        selectionStyle = .none
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
    }
    
    // MARK: - Public
    func setInfo(model: UserInfoModel) {
        // 头像
        avatarView.avatarInfo = model.avatarInfo()
        // 用户名
        TGLocalRemarkName.getRemarkName(userId: "\(model.userIdentity)", username: nil, originalName: model.name, label: usernameLabel)
        
        actionButton.layer.borderWidth = 2
        actionButton.layer.borderColor = TGAppTheme.red.cgColor
        actionButton.roundCorner(5)
        actionButton.setTitleColor(TGAppTheme.red)
        messageButton.setTitle("")
        
        // 邀请按钮
//        if model.relationshipWithCurrentUser?.texts.localizedString != nil {
//            guard let relationship = model.relationshipWithCurrentUser else {
//                TSRootViewController.share.guestJoinLandingVC()
//                return
//            }
//            switch relationship.status {
//            case .eachOther:
//                messageButton.makeVisible()
//                actionButton.makeHidden()
//                break
//            case .follow:
//                messageButton.makeHidden()
//                actionButton.makeVisible()
//                actionButton.setTitle("followed".localized)
//                break
//            case .unfollow:
//                messageButton.makeHidden()
//                actionButton.makeVisible()
//                actionButton.setTitle("display_follow".localized)
//                break
//            default:
//                messageButton.makeHidden()
//                actionButton.makeHidden()
//                break
//            }
//        } else {
//            messageButton.makeHidden()
//            actionButton.makeHidden()
//        }
        messageButton.makeHidden()
        actionButton.makeHidden()
    }
    
//    func setContactInfo(model: ContactModel) {
//        // 头像
//        avatarView.avatarInfo = AvatarInfo()
//        let avatarImage = model.avatar == nil ? UIImage(named: "IMG_pic_default_secret")! : model.avatar!
//        avatarView.buttonForAvatar.setImage(avatarImage, for: .normal)
//        // 用户名
//        usernameLabel.text = model.name
//        // 邀请按钮
//        messageButton.makeHidden()
//        actionButton.makeVisible()
//        
//        actionButton.layer.borderWidth = 2
//        actionButton.layer.borderColor = TGAppTheme.red.cgColor
//        actionButton.roundCorner(5)
//        actionButton.setTitleColor(TGAppTheme.red)
//        actionButton.setTitle("invite".localized)
//    }
    
    func setContactData(model: ContactData) {
        // 邀请按钮
        messageButton.makeHidden()
        actionButton.makeHidden()
        MessageUtils.getAvatarIcon(sessionId: model.userName, conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
            self?.avatarView.avatarInfo = avatarInfo
        }
        
        // MARK: REMARK NAME
        if model.userId == -1 {
            TGLocalRemarkName.getRemarkName(userId: nil, username: model.userName, originalName: model.displayname, label: usernameLabel)
        } else {
            TGLocalRemarkName.getRemarkName(userId: String(model.userId), username: nil, originalName: model.displayname, label: usernameLabel)
        }
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        self.onClickAction?()
    }
    
    @IBAction func messageAction(_ sender: Any) {
        self.onClickAction?()
    }
}


//struct ContactModel {
//
//    /// 姓名
//    var name: String
//    /// 电话
//    var phone: String
//    /// 头像
//    var avatar: UIImage?
//    /// 是否已经邀请过
//    var isInvite = false
//
//    init?(contact: CNContact) {
//        let nameInfo = CNContactFormatter.string(from: contact, style: CNContactFormatterStyle.fullName) ?? "wu_ming_shi".localized
//        let phoneInfo = contact.phoneNumbers
//        guard let phoneNumber = TSContactModel.filter(phone: phoneInfo), nameInfo != "" else {
//            return nil
//        }
//        name = nameInfo
//        phone = phoneNumber
//        let imageData = contact.thumbnailImageData ?? NSData.init() as Data
//        avatar = UIImage(data: imageData)
//    }
//
//    /// 过滤手机号的格式
//    static func filter(phone: [CNLabeledValue<CNPhoneNumber>]?) -> String? {
//        guard var phone = phone else {
//            return nil
//        }
//        var phoneNum = ""
//        var phoneNumArr: [String] = []
//        for phoneInfo in phone {
//            phoneNumArr.append(phoneInfo.value.stringValue)
//        }
////        if phoneNumArr.contains(CurrentUserSessionInfo?.phone ?? "") {
////            return nil
////        }
//        // 获取整个数组中符合要求的第一个手机号码
//        for phoneInfo in phone {
//            var phoneNums = phoneInfo.value.stringValue
//            phoneNums = phoneNums.replacingOccurrences(of: "-", with: "")
//            phoneNums = phoneNums.replacingOccurrences(of: "+86", with: "")
//            phoneNums = phoneNums.replacingOccurrences(of: " ", with: "")
//            phoneNums = phoneNums.replacingOccurrences(of: "+", with: "")
//            if phoneNums.count >= 10 {
//                if TGAccountRegex.isPhoneNumberFormat(phoneNums) {
//                    phoneNum = phoneNums
//                    break
//                }
//            }
//        }
//
//        //walk around, special handling for MY phone number only to adapt to server's required format
//        if let phoneCode = Country.default.phoneCode, phoneCode == "+60", phoneNum.prefix(1) == "0" {
//            let phone = phoneNum.dropFirst()
//            let code = phoneCode.replacingOccurrences(of: "+", with: "")
//            phoneNum = "\(code)\(phone)"
//        }
//
//        return phoneNum == "" ? nil : phoneNum
//    }
//}
