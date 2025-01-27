//
//  MessageUtils.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/25.
//

import UIKit
import NIMSDK
import AVFoundation
//import NEMeetingKit

enum IMActionItem: Equatable {
    case reply
    case copy
    case copyImage
    case forward
    case translate
    case edit
    case delete
    case stickerCollection
    case voiceToText
    case cancelUpload
    case collection //新增收藏
    case save //新增保存
    case forwardAll
    case deleteAll
    case pinned //置顶
    case unPinned //取消置顶
    case collect_copy //
    case collect_delete
    case collect_forward
    // Favourite Message
    case fvCopy
    case fvSave
    case fvForward
    case fvDelete

    var title: String {
        switch self {
        case .stickerCollection:
            return "longclick_msg_collection".localized
        case .reply:
            return "longclick_msg_reply".localized
        case .copy, .collect_copy:
            return "longclick_msg_copy".localized
        case .copyImage:
            return "longclick_msg_copy".localized
        case .forward, .collect_forward:
            return "longclick_msg_forward".localized
        case .translate:
            return "longclick_msg_translate".localized
        case .edit:
            return "longclick_msg_revoke_and_edit".localized
        case .delete, .collect_delete:
            return "longclick_msg_delete".localized
        case .voiceToText:
            return "longclick_msg_voice_to_text".localized
        case .cancelUpload:
            return "longclick_msg_cancel_upload".localized
        case .collection:
            return "longclick_msg_favourite".localized
        case .save:
            return "save".localized
        case .forwardAll:
            return "longclick_msg_forward_all".localized
        case .deleteAll:
            return "longclick_msg_delete_all".localized

        case .pinned:
            return "detail_share_pin".localized
        case .unPinned:
            return "detail_share_unpin".localized
        case .fvCopy:
            return "longclick_msg_copy".localized
        case .fvSave:
            return "save".localized
        case .fvForward:
            return "longclick_msg_forward".localized
        case .fvDelete:
            return "longclick_msg_delete_all".localized

        }
    }
    
    var image: String {
        switch self {
        case .stickerCollection:
            return "ic_collect_sticker"
        case .reply:
            return "ic_reply"
        case .copy:
            return "ic_copy"
        case .copyImage:
            return "ic_copy"
        case .forward:
            return "ic_forward"
        case .translate:
            return "ic_translate"
        case .edit:
            return "ic_MdCreate"
        case .delete:
            return "ic_delete"
        case .voiceToText:
            return "ic_voice_to_text"
        case .cancelUpload:
            return "ic_unUpload"
        case .collection:
            return "ic_im_favourite"
        case .save:
            return "imOptionDownload"
        case .forwardAll:
            return "ic_forward"
        case .deleteAll:
            return "ic_delete"
        case .pinned:
            return "ic_pin_on"
        case .unPinned:
            return "ic_pin_on"
        case .collect_copy:
            return "ic_collect_copy"
        case .collect_delete:
            return "ic_collect_delete"
        case .collect_forward:
            return "ic_collect_forward"
        case .fvCopy:
            return "imOptionCopy"
        case .fvSave:
            return "imOptionDownload"
        case .fvForward:
            return "detail_share_forwarding"
        case .fvDelete:
            return "delete"

        }
    }
}

class GroupIMActionItem {
    let sectionId: Int
    var items: [IMActionItem]
    
    init(sectionId: Int, items: [IMActionItem]) {
        self.sectionId = sectionId
        self.items = items
    }
}

class MessageUtils: NSObject {
    ///获取sessionId
    class func conversationTargetId(_ conversationId: String) -> String {
        let strs = conversationId.components(separatedBy: "|")
        return strs.last ?? ""
    }
    ///获取sessiontype , conversationType
    class func conversationTargetType(_ conversationId: String) -> V2NIMConversationType {
        var type: V2NIMConversationType = .CONVERSATION_TYPE_P2P
        let strs = conversationId.components(separatedBy: "|")
        if strs.count > 2 {
            type = V2NIMConversationType(rawValue: strs[1].toInt()) ?? .CONVERSATION_TYPE_P2P
        }
        return type
    }
    ///获取用户信息
    class func getUserInfo(accountIds: [String], completion: @escaping ([V2NIMUser]?, Error?) -> Void){
        NIMSDK.shared().v2UserService.getUserList(accountIds) { users in
            completion(users, nil)
        } failure: { v2error in
            completion(nil, v2error.nserror)
        }

    }
    /// 获取team 信息
    class func getTeamInfo(teamId: String, teamType: V2NIMTeamType, completion: @escaping (V2NIMTeam?) -> Void){
        NIMSDK.shared().v2TeamService.getTeamInfo(teamId, teamType: teamType) { team in
            completion(team)
        }
    }
    /// 获取用户头像信息
    class func getAvatarIcon(sessionId: String, conversationType: V2NIMConversationType, completion: @escaping (AvatarInfo) -> Void) {
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = ""
        avatarInfo.verifiedIcon = ""
        avatarInfo.verifiedType = ""
        
        if conversationType == .CONVERSATION_TYPE_TEAM {
            MessageUtils.getTeamInfo(teamId: sessionId, teamType: .TEAM_TYPE_NORMAL) { team in
                if let team = team {
                    avatarInfo.nickname = team.name
                    avatarInfo.avatarURL = team.avatar
                    avatarInfo.avatarPlaceholderType = .group
                }
                completion(avatarInfo)
            }
        }else {
            MessageUtils.getUserInfo(accountIds: [sessionId]) { users, error in
                guard let user = users?.first else {
                    completion(avatarInfo)
                    return
                }
                if let ext = user.serverExtension, let data = ext.data(using: .utf8) {
                    do {
                        let jsonDecoder = JSONDecoder()
                        let userInfo = try jsonDecoder.decode(TGNIMUserInfo.self, from: data)
                        avatarInfo.avatarURL = userInfo.avatar?.url ?? ""
                        avatarInfo.verifiedIcon = userInfo.verified?.icon ?? ""
                        avatarInfo.verifiedType = userInfo.verified?.type ?? ""
                        avatarInfo.nickname = user.name ?? user.accountId
                    } catch {
                        
                    }
                } else {
                    avatarInfo.avatarURL = user.avatar ?? ""
                    avatarInfo.verifiedIcon = ""
                    avatarInfo.verifiedType = ""
                    avatarInfo.nickname = user.name ?? user.accountId
                }
                completion(avatarInfo)
            }
            
        }
        
        
    }
    
    //获取展示的用户名字,用户头像
    class func getUserShowNameAvatar(conversationId: String, completion: @escaping (String, String?) -> Void){
        let conversationType = MessageUtils.conversationTargetType(conversationId)
        let sessionId = MessageUtils.conversationTargetId(conversationId)
        var avatarURL: String?
        var name = ""
        if conversationType == .CONVERSATION_TYPE_TEAM {
            MessageUtils.getTeamInfo(teamId: sessionId, teamType: .TEAM_TYPE_NORMAL) { team in
                if let team = team {
                    avatarURL = team.avatar
                    name = team.name
                    completion(name, avatarURL)
                } else{
                    completion(name, avatarURL)
                }
            }
        }else {
            MessageUtils.getUserInfo(accountIds: [sessionId]) { users, error in
                if let user = users?.first {
                    avatarURL = user.avatar
                    if let nick = user.name {
                        name = nick
                    } else {
                        name = user.accountId ?? ""
                    }
                    completion(name, avatarURL)
                } else{
                    completion(name, avatarURL)
                }
            }
            
        }
    }
    ///删除消息
    ///onlyDeleteLocal 是否只删除本地
    class func deleteMessage(messages: [V2NIMMessage], onlyDeleteLocal: Bool = false, completion: @escaping (Error?) -> Void) {
        NIMSDK.shared().v2MessageService.delete(messages, serverExtension: "", onlyDeleteLocal: onlyDeleteLocal) {
            completion(nil)
        } failure: { error in
            completion(error.nserror)
        }

    }
    
    /// V2 云信message
    class func textV2Message(text: String, remoteExt: [String: Any]?) -> V2NIMMessage {
        let message = V2NIMMessageCreator.createTextMessage(text)
        if let remoteExt = remoteExt, let extDict = remoteExt.toJSON{
            message.serverExtension = extDict
        }
        return message
    }
    
    class func imageV2Message(path: String,
                              name: String?,
                              sceneName: String?,
                              width: Int32,
                              height: Int32) -> V2NIMMessage {
        let message = V2NIMMessageCreator.createImageMessage(path, name: name, sceneName: sceneName ?? V2NIMStorageSceneConfig.default_IM().sceneName, width: width, height: height)
        return message
    }
    
    class func audioV2Message(filePath: String,
                              name: String?,
                              sceneName: String?,
                              duration: Int32) -> V2NIMMessage {
        let message = V2NIMMessageCreator.createAudioMessage(filePath, name: name, sceneName: sceneName ?? V2NIMStorageSceneConfig.default_IM().sceneName, duration: duration)
        return message
    }
    
    class func videoV2Message(filePath: String,
                              name: String?,
                              sceneName: String?,
                              width: Int32,
                              height: Int32,
                              duration: Int32) -> V2NIMMessage {
        let message = V2NIMMessageCreator.createVideoMessage(filePath, name: name, sceneName: sceneName ?? V2NIMStorageSceneConfig.default_IM().sceneName, duration: duration, width: width, height: height)
        return message
    }
    
    class func locationV2Message(lat: Double,
                                 lng: Double,
                                 address: String) -> V2NIMMessage {
        V2NIMMessageCreator.createLocationMessage(lat, longitude: lng, address: address)
    }
    
    class func fileV2Message(filePath: String,
                             displayName: String?,
                             sceneName: String?) -> V2NIMMessage {
        V2NIMMessageCreator.createFileMessage(filePath,
                                              name: displayName,
                                              sceneName: sceneName ?? V2NIMStorageSceneConfig.default_IM().sceneName)
    }
    
    class func customV2Message(text: String,
                               rawAttachment: String) -> V2NIMMessage {
        V2NIMMessageCreator.createCustomMessage(text, rawAttachment: rawAttachment)
    }
    
    class func tipV2Message(text: String) -> V2NIMMessage {
        V2NIMMessageCreator.createTipsMessage(text)
    }
    
    class func eggV2Message(with rid: Int, tid: String? = nil, uid: [String]? = nil, messageStr: String) ->V2NIMMessage {
        let attachment = IMEggAttachment()
        attachment.eggId = "\(rid)"
        attachment.senderId = NIMSDK.shared().v2LoginService.getLoginUser() ?? ""
        attachment.message = messageStr
        
        if let tid = tid {
            attachment.tid = tid
        }
        let uids = NSMutableArray()
        if let uid = uid {
            for item in uid {
                uids.add(item)
            }
        }
        attachment.uids = uids
        let rawAttachment = attachment.encode()
        return V2NIMMessageCreator.createCustomMessage("", rawAttachment: rawAttachment)
    }
    
    class func contactCardV2Message(userName: String) ->V2NIMMessage {
        let attactment = IMContactCardAttachment()
        attactment.memberId = userName
        let rawAttachment = attactment.encode()
        let message = V2NIMMessageCreator.createCustomMessage("", rawAttachment: rawAttachment)
        //message.apnsContent = "recent_msg_desc_contact".localized
        message.text = userName
        return message
    }
    
    class func replyV2Message(with messageModel: TGMessageData, replyView: MessageReplyView, text: String, completion: @escaping (V2NIMMessage?) -> Void) {
        guard let messageReplied = messageModel.nimMessageModel else {
            completion(nil)
            return }
        let attachment = IMReplyAttachment()
        attachment.message = replyView.messageLabel.text ?? ""
        attachment.name = replyView.nicknameLabel.text ?? ""
        attachment.username = replyView.username
        
        let dispatchGroup = DispatchGroup()
        
        if String(replyView.messageCustomType ?? "") == String(CustomMessageType.ContactCard.rawValue) {
            let strArr = replyView.messageLabel.text?.components(separatedBy: ": ")
            let suffix = strArr?.last
            attachment.message = suffix ?? ""
        }
        if replyView.nicknameLabel.text == "you".localized, let sessionId = RLSDKManager.shared.loginParma?.imAccid {
            dispatchGroup.enter()
            MessageUtils.getAvatarIcon(sessionId: sessionId, conversationType: .CONVERSATION_TYPE_P2P) { vatarInfo in
                attachment.name = vatarInfo.nickname ?? ""
                dispatchGroup.leave()
            }
        }
        
        attachment.content = text
        attachment.messageType = String(replyView.messageType ?? "")
        attachment.messageID = String(replyView.messageID ?? "")
        attachment.messageCustomType = String(replyView.messageCustomType ?? "")
        attachment.image = ""
        attachment.videoURL = ""
        
        if let imageObject = messageReplied.attachment as? V2NIMMessageImageAttachment {
            attachment.image = imageObject.url ?? ""
            attachment.videoURL = ""
        } else if let videoObject = messageReplied.attachment as? V2NIMMessageVideoAttachment {
            attachment.image = replyView.videoCoverUrl
            attachment.videoURL = String(videoObject.url ?? "")
        } else if messageReplied.messageType == .MESSAGE_TYPE_CUSTOM{
            if let contactCard = messageModel.customAttachment as? IMContactCardAttachment {
                dispatchGroup.enter()
                MessageUtils.getAvatarIcon(sessionId: contactCard.memberId, conversationType: .CONVERSATION_TYPE_P2P) { vatarInfo in
                    attachment.image = vatarInfo.avatarURL ?? ""
                    attachment.videoURL = ""
                    dispatchGroup.leave()
                }
                
            } else if let charlet = messageModel.customAttachment as? IMStickerAttachment {
                attachment.image = charlet.chartletId
                attachment.videoURL = ""
            } else if let shareSocial = messageModel.customAttachment as? IMSocialPostAttachment {
                attachment.image = shareSocial.imageURL
                attachment.message = shareSocial.title
                attachment.videoURL = ""
            } else if let voucher = messageModel.customAttachment as? IMVoucherAttachment {
                attachment.image = voucher.imageURL
                attachment.message = voucher.title
                attachment.videoURL = ""
            }
            else {
                attachment.image = ""
                attachment.videoURL = ""
            }
        } else {
            attachment.image = ""
            attachment.videoURL = ""
        }
        
        dispatchGroup.notify(queue: .main){
            let rawAttachment = attachment.encode()
            let message = V2NIMMessageCreator.createCustomMessage("", rawAttachment: rawAttachment)
            message.text = "reply"
            completion(message)
        }
        
    }
    
    class func textForReplyModel(message: NIMMessage) -> String {
        var nick = ""
        if let session = message.session, let from = message.from {
            nick = ""//MessageUtils.getShowName(userId: from, teamId: nil, session: session)
        }
        var text = "|" + nick
        text += ": "
        switch message.messageType {
        case .text:
            if let t = message.text {
                text += t
            }
        case .image:
            text += "[图片消息]"
        case .audio:
            text += "[语音消息]"
        case .video:
            text += "[视频消息]"
        case .file:
            text += "[文件消息]"
        case .location:
            text += "[位置消息]"
        case .custom:
            text += "[自定义消息]"
        default:
            text += "[未知消息]"
        }
        return text
    }
    
    class func itemsActionArray(_ message: TGMessageData, isPinned: Bool = false, isUpLoad: Bool = false) -> [IMActionItem] {
        var items: [IMActionItem] = []
        
        switch message.messageType {
        case .MESSAGE_TYPE_TEXT:
            if let msg = message.nimMessageModel, MessageUtils.showRevokeButton(msg), msg.isSelf  {
                items = [.copy, .forward, .reply, .collection, .translate, .edit, .delete]
            } else {
                items = [.copy, .forward, .reply, .collection, .translate, .delete]
            }
            
        case .MESSAGE_TYPE_IMAGE, .MESSAGE_TYPE_LOCATION, .MESSAGE_TYPE_FILE:
            items = [.forward, .reply, .collection, .delete]
        case .MESSAGE_TYPE_VIDEO:
            if !isUpLoad {
                items = [.forward, .reply, .collection, .delete]
            } else {
                items = [.forward, .cancelUpload, .collection, .delete]
            }
        case .MESSAGE_TYPE_AUDIO:
            items = [.reply, .collection, .voiceToText, .delete]
        case .MESSAGE_TYPE_CUSTOM: //自定义消息
            if let customType = message.customType {
                switch customType {
                case .ContactCard, .SocialPost, .MiniProgram:
                    items = [.forward, .reply, .collection, .delete]
                case .WhiteBoard:
                    items = [.forward, .delete]
                case .VideoCall, .Egg, .RPS:
                    items = [.delete]
                case .Reply:
                    items = [.reply, .translate, .delete]
                default:
                    items = [.delete]
                }
            }
        default:
            items = [.forward, .reply, .collection, .delete]
        }
        if MessageUtils.canMessageBePinned(message) {
            if isPinned {
                items.insert(.unPinned, at: 0)
            } else {
                items.insert(.pinned, at: 0)
            }
        }
        return items
    }
    
    class func mediaItems() -> [MediaItem] {
        return [.album, .camera, .file, .redpacket, .videoCall, .voiceCall, .sendCard, .whiteBoard, .sendLocation, .collectMessage, .voiceToText, .rps]
    }
    
    class func canMessageBePinned (_ model: TGMessageData) -> Bool {
        guard let message = model.nimMessageModel else {
            return false
        }
        if message.sendingState == .MESSAGE_SENDING_STATE_FAILED {
            return false
        }
        //不是群组不可以显示
        if message.conversationType != .CONVERSATION_TYPE_TEAM {
            return false
        }
        if message.messageType == .MESSAGE_TYPE_TEXT || message.messageType == .MESSAGE_TYPE_IMAGE || message.messageType == .MESSAGE_TYPE_VIDEO
            || message.messageType == .MESSAGE_TYPE_AUDIO || message.messageType == .MESSAGE_TYPE_FILE || message.messageType == .MESSAGE_TYPE_LOCATION{
            return true
        }
        if message.messageType == .MESSAGE_TYPE_CUSTOM {
            if let attachment = model.customAttachment {
                if attachment is IMMeetingRoomAttachment {
                    return true
                }
                if attachment is IMContactCardAttachment {
                    return true
                }
                if attachment is IMRPSAttachment {
                    return true
                }
                if attachment is IMEggAttachment {
                    return true
                }
            }
        }
        return false
    }
    
    class func canMessageBeForwarded (_ model: TGMessageData) -> Bool {
        guard let message = model.nimMessageModel else {
            return false
        }
//        if MessageUtils.checkYidunAntiSpamIsEmpty(message) == false {
//            return false
//        }
        
        if message.sendingState == .MESSAGE_SENDING_STATE_FAILED {
            return false
        }
        
        if let ext = message.serverExtension, let dict = ext.toDictionary{
            
            let duration = dict["secretChatTimer"] as? Int
            
            if duration != 0 {
                return false
            }

            return true
        }
        
        if message.messageType == .MESSAGE_TYPE_CUSTOM, let attach = model.customAttachment{
            return attach.canBeForwarded()
        }
        
        if message.messageType == .MESSAGE_TYPE_NOTIFICATION {
            return false
        }
        
        if message.messageType == .MESSAGE_TYPE_TIP {
            return false
        }
        
        if message.messageType == .MESSAGE_TYPE_ROBOT {
            
            return false
        }
        
        return true
    }
    
    class func checkYidunAntiSpamIsEmpty(_ message: V2NIMMessage) -> Bool {
        
        if let yidunAntiSpamRes = message.antispamConfig?.antispamExtension, yidunAntiSpamRes.isEmpty == false {
            return false
        }
        
        if let localExt = message.localExtension, let dict = localExt.toDictionary, let yidunAntiSpamRes = dict["yidunAntiSpamRes"] as? String, yidunAntiSpamRes.isEmpty == false {
            return false
        }
        
        return true
    }
    
    class func previewImageVideoMedia(by message: V2NIMMessage) -> MediaPreviewObject? {
        if let imageObject = message.attachment as? V2NIMMessageImageAttachment {
            let previewObject = MediaPreviewObject()
            previewObject.objectId = message.messageClientId
            previewObject.thumbPath = imageObject.path
            previewObject.thumbUrl  = imageObject.url
            previewObject.path      = imageObject.path
            previewObject.url       = imageObject.url
            previewObject.type      = MediaPreviewType.image
            previewObject.timestamp = TimeInterval(message.createTime)
            previewObject.displayName = imageObject.name
            previewObject.imageSize = CGSize(width: Int(imageObject.width), height: Int(imageObject.height))
            return previewObject
        } else if let videoObject = message.attachment as? V2NIMMessageVideoAttachment {
            
            let previewObject = MediaPreviewObject()
            previewObject.objectId = message.messageClientId
            previewObject.thumbPath = videoObject.path
            previewObject.thumbUrl  = videoObject.url
            previewObject.path      = videoObject.path
            previewObject.url       = videoObject.url
            previewObject.type      = MediaPreviewType.video
            previewObject.timestamp = TimeInterval(message.createTime)
            previewObject.displayName = videoObject.name
            previewObject.duration  = TimeInterval(videoObject.duration)
            previewObject.imageSize = CGSize(width: videoObject.width, height: videoObject.height)
            return previewObject
        }
        return nil
    }

    
    class func showRevokeButton(_ message: V2NIMMessage) -> Bool {
        let currentTime = Date().timeIntervalSince1970
        let result = currentTime - message.createTime
        
        if ((message.createTime > 0) && result >= 120) == true {
            return false
        }
        return true
    }
    /// 群通知消息处理
    class func teamNotificationFormatedMessage(_ message: V2NIMMessage, completion: @escaping (String) -> Void)  {
        var formatedMessage = "unknown_message".localized
        guard let attachment = message.attachment as? V2NIMMessageNotificationAttachment else {
            completion(formatedMessage)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        var source = ""
        var targets: [String] = []
        var teamName = ""
        dispatchGroup.enter()
        MessageUtils.teamNotificationSourceName(message) { name in
            source = name
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        MessageUtils.teamNotificationTargetNames(message) { names in
            targets = names
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        MessageUtils.teamNotificationTeamShowName(message) { name in
            teamName = name
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main){
            let targetText: String = (targets.count > 1 ? targets.joined(separator: ",") : (targets.first)) ?? ""
            
            switch attachment.type {
            case .MESSAGE_NOTIFICATION_TYPE_TEAM_INVITE:
                var str: String = ""
                if let firstObject = targets.first {
                    str = String(format: "chatroom_team_invitation_one_to_one".localized, source, firstObject)
                }
                if targets.count > 1 {
                    str = str + String(format: "chatroom_team_waiting_people".localized, targets.count)
                }
                str = str + String(format: "chatroom_team_enter_group".localized, teamName)
                formatedMessage = str
            case .MESSAGE_NOTIFICATION_TYPE_TEAM_INVITE_ACCEPT:
                formatedMessage = String(format: "chatroom_team_accept_invite_group".localized, source, targetText)
            case .MESSAGE_NOTIFICATION_TYPE_TEAM_DISMISS:
                formatedMessage = String(format: "chatroom_team_person_dismiss_group".localized, source, teamName)
            case .MESSAGE_NOTIFICATION_TYPE_TEAM_LEAVE:
                formatedMessage = String(format: "chatroom_team_leave".localized, source, teamName)
            case .MESSAGE_NOTIFICATION_TYPE_TEAM_KICK:
                var str: String = ""
                if let firstObject = targets.first {
                    str = String(format: "chatroom_team_person_do_something".localized, source, firstObject)
                }
                if targets.count > 1 {
                    str = str + String(format: "chatroom_team_waiting_people".localized, targets.count)
                }
                str = str + String(format: "chatroom_team_moving_from".localized, teamName)
                formatedMessage = str
            case .MESSAGE_NOTIFICATION_TYPE_TEAM_UPDATE_TINFO:
                formatedMessage = String(format: "chatroom_team_update_info".localized, source, teamName)
            case .MESSAGE_NOTIFICATION_TYPE_TEAM_APPLY_PASS:
                if source == targetText {
                    //说明是以不需要验证的方式进入
                    formatedMessage = String(format: "chatroom_team_joined".localized, source, teamName)
                } else {
                    formatedMessage = String(format: "chatroom_team_approval".localized, source, targetText)
                }
            case .MESSAGE_NOTIFICATION_TYPE_TEAM_OWNER_TRANSFER:
                formatedMessage = String(format: "chatroom_team_update_admin".localized, source, targetText)
            case .MESSAGE_NOTIFICATION_TYPE_TEAM_ADD_MANAGER:
                formatedMessage = String(format: "chatroom_team_add_admin".localized, targetText)
            case .MESSAGE_NOTIFICATION_TYPE_TEAM_REMOVE_MANAGER:
                formatedMessage = String(format: "chatroom_team_remove_as_admin".localized, targetText)
            case .MESSAGE_NOTIFICATION_TYPE_TEAM_BANNED_TEAM_MEMBER:
                let mute = false
                let muteStr = mute ? "chatroom_team_group_mute".localized : "group_unmute".localized
                let str = targets.joined(separator: ",")
                formatedMessage = String(format: "chatroom_team_get_mute".localized, str, source, muteStr)
            default:
                break
            }
            
            completion(formatedMessage)
        }

    }
    
    class func teamNotificationSourceName(_ message: V2NIMMessage, completion: @escaping (String) -> Void) {
        var source: String = ""
        if message.senderId == (RLSDKManager.shared.loginParma?.imAccid ?? "") {
            source = "you".localized
            completion(source)
        } else {
            MessageUtils.getAvatarIcon(sessionId: message.senderId ?? "", conversationType: .CONVERSATION_TYPE_P2P, completion: { info in
                source = info.nickname ?? ""
                completion(source)
            })
        }
        
    }
    
    class func teamNotificationTargetNames(_ message: V2NIMMessage, completion: @escaping ([String]) -> Void) {
        var targets: [String] = []
        guard  let object = message.attachment as? V2NIMMessageNotificationAttachment, let currentAccount = RLSDKManager.shared.loginParma?.imAccid else {
            completion(targets)
            return
        }
        let dispatchGroup = DispatchGroup()
        if let targetIDs = object.targetIds {
            for item in targetIDs {
                dispatchGroup.enter()
                if item == currentAccount {
                    targets.append("you".localized)
                    dispatchGroup.leave()
                } else {
                    MessageUtils.getAvatarIcon(sessionId: message.senderId ?? "", conversationType: .CONVERSATION_TYPE_P2P, completion: { info in
                        targets.append(info.nickname ?? "")
                        dispatchGroup.leave()
                    })
                   
                }
            }
        }
        dispatchGroup.notify(queue: .main){
            completion(targets)
        }
        
    }
    
    class func teamNotificationTeamShowName(_ message: V2NIMMessage, completion: @escaping (String) -> Void) {
        let sessionId = MessageUtils.conversationTargetId(message.conversationId ?? "")
        MessageUtils.getTeamInfo(teamId: sessionId, teamType: .TEAM_TYPE_NORMAL) { team in
            if let team = team {
                completion(team.name)
            } else {
                completion("")
            }
        }
        
    }
    
    /// 撤销消息 tip p2p
    class func tipOnP2PV2MessageRevoked() -> String{
        let tip = "you".localized
        return String(format: "revoke_msg".localized, tip)
    }
    /// 撤销消息 tip Team
    class func tipOnTeamV2MessageRevoked() -> String{
        var tip = ""
//        NSString *fromUid = notification.messageFromUserId;
//        NSString *operatorUid = notification.fromUserId;
//        BOOL revokeBySender = !operatorUid || [operatorUid isEqualToString:fromUid];
//        BOOL fromMe = [fromUid isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]];
//        
//        // 自己撤回自己的
//        if (revokeBySender && fromMe) {
//            tipTitle = String(@"you");
//            break;
//        }
//        
//        NIMSession *session = notification.session;
//        NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
//        option.session = session;
//        NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:(revokeBySender ? fromUid : operatorUid) option:option];
//        
//        // 别人撤回自己的
//        if (revokeBySender) {
//            tipTitle = info.showName;
//            break;
//        }
//        
//        NIMTeamMember *member = [[NIMSDK sharedSDK].teamManager teamMember:operatorUid inTeam:session.sessionId];
//        // 被群主/管理员撤回的
//        if (member.type == NIMTeamMemberTypeOwner) {
//            tipTitle = [String(@"team_creator") stringByAppendingString:info.showName];
//        } else if (member.type == NIMTeamMemberTypeManager) {
//            tipTitle = [String(@"team_admin") stringByAppendingString:info.showName];
//        }
        return tip
    }
    
    
    class func imageSize(_ imageObject: V2NIMMessageImageAttachment) -> CGSize {
        var imageSize: CGSize = .zero
        imageSize = CGSize(width: CGFloat(imageObject.width), height: CGFloat(imageObject.height))
        
        let attachmentImageMinWidth  = (ScreenWidth / 4.0);
        let attachmentImageMinHeight = (ScreenWidth / 4.0);
        let attachmemtImageMaxWidth  = (ScreenWidth - 170);
        let attachmentImageMaxHeight = (ScreenWidth - 170);
        
        let minSize = CGSize(width: attachmentImageMinWidth, height: attachmentImageMinHeight)
        let maxSize = CGSize(width: attachmemtImageMaxWidth, height: attachmentImageMaxHeight)
        return  UIImage.nim_sizeWithImage(originSize: imageSize, minSize: minSize, maxSize: maxSize)
    }
    
    class func videoSize(_ videoObject: V2NIMMessageVideoAttachment?) -> CGSize {
        var imageSize: CGSize = .zero
        guard let messageObject = videoObject else { return .zero }
        imageSize = CGSize(width: CGFloat(messageObject.width), height: CGFloat(messageObject.height))
        imageSize = CGSize(width: CGFloat(messageObject.width), height: CGFloat(messageObject.height))
        
        let attachmentImageMinWidth  = (ScreenWidth / 4.0);
        let attachmentImageMinHeight = (ScreenWidth / 4.0);
        let attachmemtImageMaxWidth  = (ScreenWidth - 170);
        let attachmentImageMaxHeight = (ScreenWidth - 170);
        
        let minSize = CGSize(width: attachmentImageMinWidth, height: attachmentImageMinHeight)
        let maxSize = CGSize(width: attachmemtImageMaxWidth, height: attachmentImageMaxHeight)
        return  UIImage.nim_sizeWithImage(originSize: imageSize, minSize: minSize, maxSize: maxSize)
    }
    
    class func collectionMsgType(_ model: TGMessageData) -> MessageCollectionType {
        guard let message = model.nimMessageModel else { return MessageCollectionType.unknown }
        let msgType = message.messageType
        switch msgType {
        case .MESSAGE_TYPE_TEXT:
            return MessageCollectionType.text
        case .MESSAGE_TYPE_IMAGE:
            return MessageCollectionType.image
        case .MESSAGE_TYPE_AUDIO:
            return MessageCollectionType.audio
        case .MESSAGE_TYPE_VIDEO:
            return MessageCollectionType.video
        case .MESSAGE_TYPE_LOCATION:
            return MessageCollectionType.location
        case .MESSAGE_TYPE_NOTIFICATION:
            return MessageCollectionType.unknown
        case .MESSAGE_TYPE_FILE:
            return MessageCollectionType.file
        case .MESSAGE_TYPE_TIP:
            return MessageCollectionType.unknown
        case .MESSAGE_TYPE_ROBOT:
            return MessageCollectionType.unknown
        case .MESSAGE_TYPE_CUSTOM:
            if let attachment = model.customAttachment {
                if attachment.isKind(of: IMContactCardAttachment.self) {
                    return MessageCollectionType.nameCard
                } else if attachment.isKind(of: IMSocialPostAttachment.self) {
                    return MessageCollectionType.link
                } else if attachment.isKind(of: IMMiniProgramAttachment.self) {
                    return MessageCollectionType.miniProgram
                } else if attachment.isKind(of: IMVoucherAttachment.self) {
                    return MessageCollectionType.voucher
                } else if attachment.isKind(of: IMMeetingRoomAttachment.self) {
                    return MessageCollectionType.meeting
                } else if attachment.isKind(of: IMEggAttachment.self) {
                    return MessageCollectionType.egg
                } else if attachment.isKind(of: IMRPSAttachment.self) {
                    return MessageCollectionType.rps
                }
            }
        default:
            return MessageCollectionType.unknown
        }
        return MessageCollectionType.unknown
    }
    
    class func collectionMsgData(_ model: TGMessageData, isType: Bool = false) -> String? {
        guard let message = model.nimMessageModel else {
            return nil
        }
        let sessionId = MessageUtils.conversationTargetId(message.conversationId ?? "")
        let sessionType =  message.conversationType == .CONVERSATION_TYPE_TEAM ? "Team" : "P2P"

        var dict: [String: Any] = ["sessionId": sessionId, "sessionType": sessionType, "content": message.text ?? "", "fromAccount": message.senderId ?? ""]
        if isType {
            dict["type"] = collectionMsgType(model).rawValue
        }
        var dictStr = "{}"
        switch message.messageType {
        case .MESSAGE_TYPE_IMAGE:
            if let object = message.attachment as? V2NIMMessageImageAttachment {
                let ext = NSString(string: object.url ?? "")
                let imageAttachment = IMImageCollectionAttachment(md5: object.md5 , url: object.url ?? "", size: Int64(object.size), h: CGFloat(object.height) , w: CGFloat(object.width) , name: object.name, ext: ext.pathExtension, sen: "nim_default_im", path: object.path ?? "", force_upload: false )
                dictStr = imageAttachment.encode()
            }
        case .MESSAGE_TYPE_AUDIO:
            if let object = message.attachment as? V2NIMMessageAudioAttachment {
                let ext = NSString(string: object.path ?? "")
                let audioAttachment = IMAudioCollectionAttachment(md5: object.md5, url: object.url ?? "", size: Int64(object.size), dur: Int(object.duration) , ext: ext.pathExtension )
                dictStr = audioAttachment.encode()
            }
        case .MESSAGE_TYPE_FILE:
            if let object = message.attachment as? V2NIMMessageFileAttachment {
                let ext = NSString(string: object.path ?? "")
                let fileAttachment = IMFileCollectionAttachment(md5: object.md5, url: object.url ?? "", size: Int64(object.size), sence: "nim_msg" , name: object.name , ext: ext.pathExtension )
                dictStr = fileAttachment.encode()
            }
        case .MESSAGE_TYPE_VIDEO:
            if let object = message.attachment as? V2NIMMessageVideoAttachment {
                let finalImageSize = MessageUtils.videoSize(object)
                let v2size: V2NIMSize = V2NIMSize(width: Int(finalImageSize.width), height: Int(finalImageSize.height))
                NIMSDK.shared().v2StorageService.getVideoCoverUrl(object, thumbSize: v2size) { result in
                    let coverUrl = result.url
                    let ext = NSString(string: object.path ?? "")
                    let videoAttachment = IMVideoCollectionAttachment(md5: object.md5 , url: object.url ?? "", size: Int64(object.size), dur: Int(object.duration), h: CGFloat(object.height) , w: CGFloat(object.width) , name: object.name , ext: ext.pathExtension, coverUrl: coverUrl)
                    dictStr = videoAttachment.encode()
                } failure: { _ in
                    let ext = NSString(string: object.path ?? "")
                    let videoAttachment = IMVideoCollectionAttachment(md5: object.md5 , url: object.url ?? "", size: Int64(object.size), dur: Int(object.duration), h: CGFloat(object.height) , w: CGFloat(object.width) , name: object.name , ext: ext.pathExtension, coverUrl: "")
                    dictStr = videoAttachment.encode()
                }
                
            }
        case .MESSAGE_TYPE_LOCATION:
            if let object = message.attachment as? V2NIMMessageLocationAttachment {
                let location = IMLocationCollectionAttachment(title: object.address , lat: object.latitude, lng: object.longitude)
                dictStr = location.encode()
            }
        case .MESSAGE_TYPE_CUSTOM:
            if let attachment = model.customAttachment {
                dictStr = attachment.encode()
            }
        default:
            break
        }
        
        dict["attachment"] = dictStr
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted])
        guard let jsonStr = String(data: data!, encoding: .utf8) else {
            return nil
        }
        print("jsonStr = \(jsonStr)")
        return jsonStr
    }
    
    //自定义更多菜单的子按钮
//    class func configMoreMenus(options: NEMeetingOptions) {
//        // 1. 创建更多菜单列表构建类，列表默认包含："邀请"、"聊天"
//        var moreMenus = NEMenuItems.defaultMoreMenuItems() as! [NEMeetingMenuItem]
//        
//        // 2. 添加一个多选菜单项
//        let newItem = NESingleStateMenuItem()
//        newItem.itemId = 1000
//        newItem.visibility = .VISIBLE_TO_HOST_ONLY
//        newItem.singleStateItem = NEMenuItemInfo()
//        newItem.singleStateItem.icon = "private-invite"
//        newItem.singleStateItem.text = "meeting_private".localized
//    
//        moreMenus.append(newItem)
//        // 3. 配置完成，设置参数字段
//        options.fullMoreMenuItems = moreMenus
//    }
    
    //获取群成员userId
    class func fetchMembersTeam(teamId: String, completed: @escaping (([String])-> Void)){
        let option = V2NIMTeamMemberQueryOption()
        option.limit = 1000
        option.nextToken = ""
        option.roleQueryType = .TEAM_MEMBER_ROLE_QUERY_TYPE_ALL
        NIMSDK.shared().v2TeamService.getTeamMemberList(teamId, teamType: .TEAM_TYPE_NORMAL, queryOption: option) { listResult in
            if let members = listResult.memberList {
                var memberIds = [String]()
                for member in members{
                    memberIds.append(member.accountId)
                }
                completed(memberIds)
            }
        }
        
    }
}
