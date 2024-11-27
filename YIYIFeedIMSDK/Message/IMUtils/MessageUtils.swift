//
//  MessageUtils.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/25.
//

import UIKit
import NIMSDK

class MessageUtils: NSObject {
    
    public class func textMessage(text: String) -> NIMMessage {
        let message = NIMMessage()
        message.setting = messageSetting()
        message.text = text
        return message
    }
    
    public class func textMessage(text: String, remoteExt: [String: Any]?) -> NIMMessage {
        let message = NIMMessage()
        message.setting = messageSetting()
        message.text = text
        if remoteExt?.count ?? 0 > 0 {
            message.remoteExt = remoteExt
        }
        return message
    }
    
    public class func imageMessage(image: UIImage) -> NIMMessage {
        imageMessage(imageObject: NIMImageObject(image: image))
    }
    
    public class func imageMessage(path: String) -> NIMMessage {
        imageMessage(imageObject: NIMImageObject(filepath: path))
    }
    
    public class func imageMessage(imageObject: NIMImageObject) -> NIMMessage {
        let message = NIMMessage()
        let option = NIMImageOption()
        option.compressQuality = 0.8
        imageObject.option = option
        message.messageObject = imageObject
        message.apnsContent = "图片"
        message.setting = messageSetting()
        return message
    }
    
    public class func audioMessage(filePath: String) -> NIMMessage {
        let messageObject = NIMAudioObject(sourcePath: filePath)
        let message = NIMMessage()
        message.messageObject = messageObject
        message.apnsContent = "语音"
        message.setting = messageSetting()
        return message
    }
    
    public class func videoMessage(filePath: String) -> NIMMessage {
        let messageObject = NIMVideoObject(sourcePath: filePath, scene: NIMNOSSceneTypeMessage)
        let message = NIMMessage()
        message.messageObject = messageObject
        message.apnsContent = "视频"
        message.setting = messageSetting()
        return message
    }
    
    public class func locationMessage(_ lat: Double, _ lng: Double, _ title: String, _ address: String) -> NIMMessage {
        let messageObject = NIMLocationObject(latitude: lat, longitude: lng, title: address)
        let message = NIMMessage()
        message.messageObject = messageObject
        message.text = title
        message.apnsContent = "位置"
        message.setting = messageSetting()
        return message
    }
    
    public class func fileMessage(filePath: String, displayName: String?) -> NIMMessage {
        let messageObject = NIMFileObject(sourcePath: filePath)
        if let dpName = displayName {
            messageObject.displayName = dpName
        }
        let message = NIMMessage()
        message.messageObject = messageObject
        message.apnsContent = "文件"
        message.setting = messageSetting()
        return message
    }
    
    public class func fileMessage(data: Data, displayName: String?) -> NIMMessage {
        let dpName = displayName ?? ""
        let pointIndex = dpName.lastIndex(of: ".") ?? dpName.startIndex
        let suffix = dpName[dpName.index(after: pointIndex) ..< dpName.endIndex]
        let messageObject = NIMFileObject(data: data, extension: String(suffix))
        messageObject.displayName = dpName
        let message = NIMMessage()
        message.messageObject = messageObject
        message.apnsContent = "文件"
        message.setting = messageSetting()
        return message
    }
    
    public class func messageSetting() -> NIMMessageSetting {
        let setting = NIMMessageSetting()
        
        setting.teamReceiptEnabled = true
        return setting
    }
    
    //  获取展示的用户名字，p2p： 备注 > 昵称 > ID  team: 备注 > 群昵称 > 昵称 > ID
    public class func getShowName(userId: String, teamId: String?, session: NIMSession,  _ showAlias: Bool = true) -> String {
        
        let user = NIMSDK.shared().userManager.userInfo(userId)
        var fullName = userId
        if let nickName = user?.userInfo?.nickName {
            fullName = nickName
        }else {
            NIMSDK.shared().userManager.fetchUserInfos([userId])
        }
        if let tID = teamId, session.sessionType == .team {
            // team
            let teamMember = NIMSDK.shared().teamManager.teamMember(userId, inTeam: tID)
            if let teamNickname = teamMember?.nickname {
                fullName = teamNickname
            }
        }
        if showAlias, let alias = user?.alias {
            fullName = alias
        }
        return fullName
    }
    //获取用户头像
    public class func getUserAvatar(userId: String, session: NIMSession) ->String?{
        var avatarURL: String?
        if session.sessionType == .team {
            if let team: NIMTeam = NIMSDK.shared().teamManager.team(byId: session.sessionId) {
                avatarURL = team.thumbAvatarUrl
            }
        }else {
            let user = NIMSDK.shared().userManager.userInfo(userId)
            avatarURL = user?.userInfo?.avatarUrl
        }
        return avatarURL
    }
    
    
    public class func messagesInSession(session: NIMSession, messageId: [String]) -> [NIMMessage]?{
        let messages = NIMSDK.shared().conversationManager.messages(in: session, messageIds: messageId)
        
        return messages
    }
    
    public static func textForReplyModel(message: NIMMessage) -> String {
        var nick = ""
        if let session = message.session, let from = message.from {
            nick = MessageUtils.getShowName(userId: from, teamId: nil, session: session)
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
    
    class func mediaItems() -> [MediaItem] {
        return [.album, .camera, .file, .redpacket, .videoCall, .voiceCall, .sendCard, .whiteBoard, .sendLocation, .collectMessage, .voiceToText, .rps]
    }

}
