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
