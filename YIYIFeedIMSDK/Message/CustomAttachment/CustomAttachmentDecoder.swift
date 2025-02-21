//
//  CustomAttachmentDecoder.swift
//  Yippi
//
//  Created by Tinnolab on 13/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class CustomAttachmentDecoder: NSObject {
    
    class func decodeAttachment(_ content: String?) -> (CustomMessageType?, CustomAttachment?) {
        guard let _content = content, let data = _content.data(using: .utf8) else { return (nil, nil) }
        
        do {
            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                print(dict)
                let tt = dict.object(forKey: CMType) as? Int ?? Int(dict.object(forKey: CMType) as? String ?? "-1")
                let type = CustomMessageType(rawValue: tt ?? -1)
                let data = dict.object(forKey: CMData) as? NSDictionary ?? NSDictionary()
                let info = dict.object(forKey: CMInfo) as? NSDictionary ?? NSDictionary()
                
                switch type {
                case .RPS:
                    let attachment = IMRPSAttachment()
                    attachment.value = data.jsonInt(CMValue)
                    return (type, attachment)
                case .Snapchat:
                    let attachment = IMSnapchatAttachment()
                    attachment.md5 = data.jsonString(CMMD5)
                    attachment.url = data.jsonString(CMURL)
                    attachment.isFired = dict.jsonBool(CMFIRE)
                    return (type, attachment)
                case .ContactCard:
                    let attachment = IMContactCardAttachment()
                    attachment.memberId = data.jsonString(CMContactCard)
                    return (type, attachment)
                case .Egg:
                    let attachment = IMEggAttachment()
                    attachment.eggId = data.jsonString(CMEggId)
                    attachment.senderId = data.jsonString(CMEggSendId)
                    attachment.tid = data.jsonString(CMEggOpenId)
                    attachment.message = data.jsonString(CMEggMessage)
                    if let uids = data.jsonArray(CMEggUIDs) {
                        attachment.uids = uids
                    }
                    return (type, attachment)
                case .SocialPost:
                    let attachment = IMSocialPostAttachment()
                    attachment.postUrl = data.jsonString(CMShareURL)
                    attachment.imageURL = data.jsonString(CMShareImage)
                    attachment.title = data.jsonString(CMShareTitle)
                    attachment.desc = data.jsonString(CMShareDescription)
                    attachment.contentType = data.jsonString(CMShareContentType)
                    attachment.contentUrl = data.jsonString(CMShareContentUrl)
                    return (type, attachment)
                case .MiniProgram:
                    let attachment = IMMiniProgramAttachment()
                    attachment.appId = data.jsonString(CMAppId)
                    attachment.title = data.jsonString(CMMPTitle)
                    attachment.path = data.jsonString(CMPath)
                    attachment.desc = data.jsonString(CMMPDesc)
                    attachment.imageURL = data.jsonString(CMMPAvatar)
                    attachment.contentType = data.jsonString(CMMPType)
                    return (type, attachment)
                case .Voucher:
                    let attachment = IMVoucherAttachment()
                    attachment.postUrl = data.jsonString(CMShareURL)
                    attachment.imageURL = data.jsonString(CMShareImage)
                    attachment.title = data.jsonString(CMShareTitle)
                    attachment.desc = data.jsonString(CMShareDescription)
                    attachment.contentType = data.jsonString(CMShareContentType)
                    attachment.contentUrl = data.jsonString(CMShareContentUrl)
                    return (type, attachment)
                case .WhiteBoard:
                    let attachment = IMWhiteboardAttachment()
                    attachment.channel = data.jsonString(CMWhiteBoardChannel)
                    return (type, attachment)
                case .VideoCall:
                    let attachment = IMCallingAttachment()
                    attachment.callType = V2NIMSignallingChannelType(rawValue: Int(data.jsonString(CMCallType)) ?? 1) ?? .SIGNALLING_CHANNEL_TYPE_AUDIO
                    attachment.eventType = CallingEventType(rawValue: Int(data.jsonString(CMEventType)) ?? 0) ?? .miss
                    attachment.duration = Double(data.jsonString(CMCallDuration)) ?? 0
                    return (type, attachment)
                case .Sticker:
                    let attachment = IMStickerAttachment()
                    attachment.chartletCatalog = data.jsonString(CMCatalog)
                    attachment.stickerId = data.jsonString(CMStickerId)
                    attachment.chartletId = data.jsonString(CMChartlet)
                    return (type, attachment)
                case .Reply:
                    let attachment = IMReplyAttachment()
                    attachment.message = data.jsonString(CMReplyMessage)
                    attachment.content = data.jsonString(CMReplyContent)
                    attachment.name = data.jsonString(CMReplyName)
                    attachment.username = data.jsonString(CMReplyUserName)
                    attachment.image = data.jsonString(CMReplyImageURL)
                    attachment.messageID = data.jsonString(CMReplyMessageID)
                    attachment.videoURL = data.jsonString(CMReplyThumbURL)
                    attachment.messageType = data.jsonString(CMReplyMessageType)
                    attachment.messageCustomType = data.jsonString(CMReplyMessageCustomType)
                    return (type, attachment)
                case .MeetingRoom:
                    let attachment = IMMeetingRoomAttachment()
                    attachment.meetingId = data.jsonString(CMMeetingId)
                    attachment.meetingNum = data.jsonString(CMMeetingNum)
                    attachment.meetingShortNum = data.jsonString(CMMeetingShortNum)
                    attachment.meetingPassword = data.jsonString(CMMeetingPassword)
                    attachment.meetingStatus = data.jsonString(CMMeetingStatus)
                    attachment.meetingSubject = data.jsonString(CMMeetingSubject)
                    attachment.meetingType = data.jsonInt(CMMeetingType)
                    attachment.roomArchiveId = data.jsonString(CMRoomArchiveId)
                    attachment.roomUuid = data.jsonString(CMRoomUuid)
                    return (type, attachment)
                case .Translate:
                    let attachment = IMTextTranslateAttachment()
                    attachment.oriMessageId =  data.jsonString(CMOriginalMessageId)
                    attachment.originalText = data.jsonString(CMOriginalMessage)
                    attachment.translatedText = data.jsonString(CMTranslatedMessage)
                    attachment.isOutgoingMsg = data.jsonBool(CMTranslatedMessageIsOutgoing)
                    return (type, attachment)
                default:
                    return (type, nil)
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
       
        
        return (nil, nil)
    }
    
    /// 自定义白板
    class func WhiteBoardEncode(channel: String, creator: String) -> String {
        let dictContent: [String : Any] = [CMWhiteBoardChannel : channel,
                                           CMWhiteBoardCreator: creator]
        
        let dict: [String : Any] = [CMType: CustomMessageType.WhiteBoard.rawValue,
                                    CMData: dictContent]
        var stringToReturn = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            stringToReturn = String(data: jsonData, encoding: .utf8) ?? ""
        } catch let error {
            print(error.localizedDescription)
        }
        return stringToReturn
    }
    /// 音视频通话
    class func audioVideoEncode(callType: V2NIMSignallingChannelType, eventType: CallingEventType, duration: TimeInterval) -> String {
        let dictContent: [String : Any] = [CMCallType : callType.rawValue,
                                           CMEventType: eventType.rawValue,
                                           CMCallDuration: duration]
        
        let dict: [String : Any] = [CMType: CustomMessageType.VideoCall.rawValue,
                                    CMData: dictContent]
        var stringToReturn = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            stringToReturn = String(data: jsonData, encoding: .utf8) ?? ""
        } catch let error {
            print(error.localizedDescription)
        }
        return stringToReturn
    }
    
    /// 贴纸
    class func stickerMessageEncode(chartletId: String, stickerId: String, chartletCatalog: String) -> String {
        let dictContent: [String : Any] = [CMChartlet: chartletId,
                                           CMCatalog: chartletCatalog,
                                           CMStickerId: stickerId]
        let dict: [String : Any] = [CMType: CustomMessageType.Sticker.rawValue,
                                    CMData: dictContent]
        
        var stringToReturn = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            stringToReturn = String(data: jsonData, encoding: .utf8) ?? ""
        } catch let error {
            print(error.localizedDescription)
        }
        return stringToReturn
    }
    /// rps
    class func RPSMessageEncode(value: Int) -> String {
        let dictContent: [String : Int] = [CMValue: value]
        let dict: [String : Any] = [CMType: CustomMessageType.RPS.rawValue,
                                    CMData: dictContent]
        
        var stringToReturn = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            stringToReturn = String(data: jsonData, encoding: .utf8) ?? ""
        } catch let error {
            print(error.localizedDescription)
        }
        return stringToReturn
    }
    /// replay
    class func replayMessageEncode(attach: IMReplyAttachment) -> String {
        return attach.encode()
    }
    /// egg
    class func eggMessageEncode(attach: IMEggAttachment) -> String {
        return attach.encode()
    }
    /// socialPost
    class func sociaPostMessageEncode(attach: IMSocialPostAttachment) -> String {
        return attach.encode()
    }
    /// miniprogram
    class func miniProgramMessageEncode(attach: IMMiniProgramAttachment) -> String {
        return attach.encode()
    }
    /// voucher
    class func voucherMessageEncode(attach: IMVoucherAttachment) -> String {
        return attach.encode()
    }
    /// contactCard
    class func contactCardMessageEncode(attach: IMContactCardAttachment) -> String {
        return attach.encode()
    }
    
}

extension NSDictionary {
    func jsonInt(_ key: String) -> Int {
        let object = self.object(forKey: key)
        if (object is String) || (object is NSNumber) {
            return (object as? NSNumber)?.intValue ?? 0
        }
        return 0
    }
    
    func jsonDouble(_ key: String) -> Double {
        let object = self.object(forKey: key)
        if (object is String) || (object is NSNumber) {
            return (object as? NSNumber)?.doubleValue ?? 0.0
        }
        return 0.0
    }
    
    func jsonString(_ key: String) -> String {
        let object = self.object(forKey: key)
        if object is String {
            return object as? String ?? ""
        } else if object is NSNumber {
            if let object = object {
                return "\(object)"
            }
            return ""
        }
        return ""
    }
    
    func jsonBool(_ key: String) -> Bool {
        let object = self.object(forKey: key)
        if (object is String) || (object is NSNumber) {
            return (object as? NSNumber)?.boolValue ?? false
        }
        return false
    }
    
    func jsonDict(_ key: String) -> NSDictionary? {
        let object = self.object(forKey: key)
        if (object is NSDictionary) {
            return object as? NSDictionary
        }
        return nil
    }
    
    func jsonArray(_ key: String) -> NSArray? {
        let object = self.object(forKey: key)
        if (object is NSArray)  {
            return object as? NSArray
        }
        return nil
    }
}
