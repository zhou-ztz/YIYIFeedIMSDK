//
//  ContactData.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2024/12/31.
//

import UIKit
import NIMSDK

class ContactData: NSObject {
    let userId : Int
    let userName : String
    var imageUrl : String
    let isTeam : Bool
    var displayname: String
    let remarkName: String
    let isBannedUser: Bool
    var verifiedType: String
    var verifiedIcon: String
    var isTop : Bool = false
    
    init(userId: Int, userName: String, imageUrl: String, isTeam: Bool, displayname: String, remarkName: String = "", isBannedUser: Bool, verifiedType: String, verifiedIcon: String) {
        
        self.userId = userId
        self.userName = userName
        self.imageUrl = imageUrl
        self.isTeam = isTeam
        self.displayname = displayname
        self.remarkName = remarkName
        self.isBannedUser = isBannedUser
        self.verifiedType = verifiedType
        self.verifiedIcon = verifiedIcon
    }
}

extension ContactData {
    convenience init(model: TGAvatarInfo) {
        self.init(userId: -1, userName: model.username.orEmpty, imageUrl: model.avatarURL.orEmpty, isTeam: true, displayname: model.nickname.orEmpty, isBannedUser: false, verifiedType: model.verifiedType, verifiedIcon: model.verifiedIcon)
    }
    
    convenience init(team: NIMTeam) {
        self.init(userId: -1, userName: team.teamId.orEmpty, imageUrl: team.avatarUrl.orEmpty, isTeam: true, displayname: team.teamName.orEmpty, isBannedUser: false, verifiedType: "", verifiedIcon: "")
    }
    
    convenience init(team: V2NIMTeam) {
        self.init(userId: -1, userName: team.teamId, imageUrl: team.avatar.orEmpty, isTeam: true, displayname: team.name, isBannedUser: false, verifiedType: "", verifiedIcon: "")
    }
    
    convenience init(model: TGUserInfoModel) {
        self.init(userId: model.userIdentity, userName: model.username, imageUrl: model.avatarUrl.orEmpty, isTeam: false, displayname: model.name, isBannedUser: model.isBannedUser, verifiedType: model.verificationType.orEmpty, verifiedIcon: model.verificationIcon.orEmpty)
    }
//    convenience init(model: TGUserInfoModel) {
//        self.init(userId: model.id, userName: model.username, imageUrl: model.avatar?.url ?? "", isTeam: false, displayname: model.name.orEmpty, isBannedUser: false, verifiedType: model.verified?.type ?? "", verifiedIcon: model.verified?.icon ?? "")
//    }
    
    convenience init(model: TGUserInfoModel, remarkName: String) {
        self.init(userId: model.userIdentity, userName: model.username, imageUrl: model.avatarUrl.orEmpty, isTeam: false, displayname: model.name, remarkName: remarkName, isBannedUser: model.isBannedUser, verifiedType: model.verificationType.orEmpty, verifiedIcon: model.verificationIcon.orEmpty)
    }
    
    convenience init(userName: String) {
        self.init(userId: -1, userName: userName, imageUrl: "", isTeam: false, displayname: userName, isBannedUser: false, verifiedType: "", verifiedIcon: "")
        setDisplayname()
    }
    
//    convenience init(userName: String, remarkName:String) {
//        let userInfo = NIMBridgeManager.sharedInstance().getUserInfo(userName)
//        self.init(userId: -1, userName: userInfo.infoId.orEmpty, imageUrl: userInfo.avatarUrlString.orEmpty, isTeam: false, displayname: userInfo.showName.orEmpty, isBannedUser: false, verifiedType: "", verifiedIcon: "")
//    }
    func setDisplayname() {
        MessageUtils.getAvatarIcon(sessionId: userName, conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
            self?.displayname = (avatarInfo.nickname ?? "").count > 0 ? (avatarInfo.nickname ?? "") : (self?.userName ?? "")
        }
    }
}

class ContactSelectorConfig: NSObject {
    
    @objc enum FUControllerMode:NSInteger {
        case IM
        case App
        case Social
    }
    
    @objc enum contentType: NSInteger {
        case defaultContent
        case sticker
        case image
        case video
        case post
    }
    
    let title : String
    let isMultiSelect : Bool
    let filterIds : NSArray?
    let maxSelectCount : Int
    let enableTeam : Bool
    let enableRobot : Bool
    let enableRecent : Bool
    let teamId : String?
    let doneBtnTitle : String?
    let doneBtnImage : UIImage?
    let typeOfContent: contentType
    let content : Any?
    let mode : FUControllerMode
    let shareToSocial: Bool
    let toastMessage : Int
    
    convenience init(title: String, isMultiSelect: Bool, filterIds: NSArray?, maxSelectCount: Int, enableTeam: Bool, enableRobot: Bool, enableRecent : Bool, teamId: String?, doneBtnTitle: String?, doneBtnImage: UIImage?, toastMessage: Int) {
        self.init(title: title, isMultiSelect: isMultiSelect, filterIds: filterIds, maxSelectCount: maxSelectCount, enableTeam: enableTeam, enableRobot: enableRobot, enableRecent: enableRecent, teamId: teamId, doneBtnTitle: doneBtnTitle, doneBtnImage: doneBtnImage, typeOfContent:  contentType.defaultContent, content: nil, mode: FUControllerMode.IM, shareToSocial: false, toastMessage: toastMessage)
    }

    @objc init(title: String, isMultiSelect: Bool, filterIds: NSArray?, maxSelectCount: Int, enableTeam: Bool, enableRobot: Bool, enableRecent : Bool, teamId: String?, doneBtnTitle: String?, doneBtnImage: UIImage?, typeOfContent: contentType, content: Any?, mode: FUControllerMode, shareToSocial: Bool, toastMessage: Int) {
        
        self.title = title
        self.isMultiSelect = isMultiSelect
        self.filterIds = filterIds
        self.maxSelectCount = maxSelectCount
        self.enableTeam = enableTeam
        self.enableRobot = enableRobot
        self.enableRecent = enableRecent
        self.teamId = teamId
        self.doneBtnTitle = doneBtnTitle
        self.doneBtnImage = doneBtnImage
        self.typeOfContent = typeOfContent
        self.content = content
        self.mode = mode
        self.shareToSocial = shareToSocial
        self.toastMessage = toastMessage
    }
}
