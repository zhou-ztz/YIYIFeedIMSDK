//
//  MessageUtils.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/25.
//

import UIKit
import NIMSDK

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
    /// 获取展示的用户名字，p2p： 备注 > 昵称 > ID  team: 备注 > 群昵称 > 昵称 > ID
    class func getShowName(conversationId: String, completion: @escaping (String) -> Void){
        let conversationType = MessageUtils.conversationTargetType(conversationId)
        let sessionId = MessageUtils.conversationTargetId(conversationId)
        var name = ""
        if conversationType == .CONVERSATION_TYPE_TEAM {
            MessageUtils.getTeamInfo(teamId: sessionId, teamType: .TEAM_TYPE_NORMAL) { team in
                if let team = team {
                    name = team.name
                    completion(name)
                } else{
                    completion(name)
                }
            }
        } else {
            MessageUtils.getUserInfo(accountIds: [sessionId]) { users, error in
                if let user = users?.first {
                    if let nick = user.name {
                        name = nick
                    } else {
                        name = user.accountId ?? ""
                    }
                    completion(name)
                } else{
                    completion(name)
                }
            }
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
    
    
    
    public class func messagesInSession(session: NIMSession, messageId: [String]) -> [NIMMessage]?{
        let messages = NIMSDK.shared().conversationManager.messages(in: session, messageIds: messageId)
        
        return messages
    }
    
    public static func textForReplyModel(message: NIMMessage) -> String {
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
    
    class func mediaItems() -> [MediaItem] {
        return [.album, .camera, .file, .redpacket, .videoCall, .voiceCall, .sendCard, .whiteBoard, .sendLocation, .collectMessage, .voiceToText, .rps]
    }

}
