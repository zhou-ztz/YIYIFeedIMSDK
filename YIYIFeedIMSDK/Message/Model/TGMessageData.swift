//
//  TGMessageData.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/2.
//

import UIKit
import NIMSDK

/// 增加的讯息类型
enum TGChatMessageType: Int {
    case none = 0
    case time
    case revoke
    case reply
    case user
}
class TGMessageData: NSObject {
    
    var nimMessageModel : V2NIMMessage?
    var showName : Bool?
    var messageType: V2NIMMessageType = .MESSAGE_TYPE_TEXT
    var messageTime: TimeInterval = 0
    var type: TGChatMessageType
    var isPlaying: Bool = false
    var isReplay: Bool = false
    var replyText: String = ""
    var isRevokedText: Bool = false
    var isRevoked: Bool = false
    ///处理自定义消息
    var customType: CustomMessageType?
    var customAttachment: CustomAttachment?
    //是否置顶
    var isPinned: Bool = false

    var messageList: [TGMessageData] = []
    // 是否被翻译
    var isTranslated: Bool = false
    // 对方是否已读
    var unreadCount: Int = 1
    var readCount: Int = 0
    
    init(nimMessageModel: V2NIMMessage? = nil, showName: Bool? = nil, messageType: V2NIMMessageType = .MESSAGE_TYPE_TEXT, messageTime: TimeInterval = 0, type: TGChatMessageType, replyText: String = "") {
        self.nimMessageModel = nimMessageModel
        self.showName = showName
        self.messageType = messageType
        self.messageTime = messageTime
        self.type = type
        self.replyText = replyText
        if messageType == .MESSAGE_TYPE_CUSTOM, let attach = nimMessageModel?.attachment {
            let (attachmentType, attachment) = CustomAttachmentDecoder.decodeAttachment(attach.raw)
            self.customType = attachmentType
            self.customAttachment = attachment
        }
    }
    
    convenience init(_ messageModel: V2NIMMessage) {
        //let showName = messageModel.session?.sessionType == .team ? true : false
        var msgType: TGChatMessageType = .none
        var replyText = ""
//        
//        if let yxReplyMsg = messageModel.serverExtension?[keyReplyMsgKey] as? [String: Any], let replyId = yxReplyMsg["idClient"] as? String, let session = messageModel.session  {
//            
//            if let message = MessageUtils.messagesInSession(session: session, messageId: [replyId])?.first {
//                replyText = MessageUtils.textForReplyModel(message: message)
//                msgType = .reply
//            }
//        }
        self.init(nimMessageModel: messageModel, showName: nil, messageType: messageModel.messageType, messageTime: messageModel.createTime, type: msgType, replyText: replyText)
    }
    
    
}

extension TimeInterval {
    func messageTime(showDetail: Bool) -> String? {
        //今天的时间
        let nowDate = Date()
        let msgDate = Date(timeIntervalSince1970: self)
        var result: String = ""
        
        let components = Set<Calendar.Component>([.year, .month, .day, .weekday, .hour, .minute])
        let nowDateComponents = Calendar.current.dateComponents(components, from: nowDate)
        let msgDateComponents = Calendar.current.dateComponents(components, from: msgDate)
        
       // let hour = msgDateComponents.hour
        let OnedayTimeIntervalValue: Double = 24 * 60 * 60 //一天的秒数
        //result = self.getPeriodOfTime(hour!, withMinute: msgDateComponents.minute!)
        
        let isSameMonth = (nowDateComponents.year == msgDateComponents.year) && (nowDateComponents.month == msgDateComponents.month)
        let isSameYear = nowDateComponents.year == msgDateComponents.year
        
        if isSameMonth && (nowDateComponents.day == msgDateComponents.day) {
            //同一天,显示时间
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            result = formatter.string(from: msgDate)

        } else if isSameMonth && (nowDateComponents.day == (msgDateComponents.day! + 1)) {
            //昨天
            let formatter = DateFormatter()
            formatter.dateFormat = "MM月dd日 HH:mm"
            result = formatter.string(from: msgDate)
        } else if isSameMonth && (nowDateComponents.day == (msgDateComponents.day! + 2)) {
            //前天
            let formatter = DateFormatter()
            formatter.dateFormat = "MM月dd日 HH:mm"
            result = formatter.string(from: msgDate)
        } else if nowDate.timeIntervalSince(msgDate) < 7 * OnedayTimeIntervalValue {
            //一周内
            let formatter = DateFormatter()
            formatter.dateFormat = "MM月dd日 HH:mm"
            result = formatter.string(from: msgDate)
        } else if isSameYear && Double(nowDate.timeIntervalSince(msgDate)) > (7 *  OnedayTimeIntervalValue) {
            //一年内
            let formatter = DateFormatter()
            formatter.dateFormat = "MM月dd日 HH:mm"
            result = formatter.string(from: msgDate)
        } else {
            //显示日期
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY年MM月dd日 HH:mm"
            result = formatter.string(from: msgDate)
        }
        return result
    }
    
    private func getPeriodOfTime(_ time: Int, withMinute minute: Int) -> String? {
        let totalMin = time * 60 + minute
        var showPeriodOfTime = ""
        if totalMin > 0 && totalMin <= 5 * 60 {
            showPeriodOfTime = "chatroom_text_morning"
        } else if totalMin > 5 * 60 && totalMin < 12 * 60 {
            showPeriodOfTime = "chatroom_text_am"
        } else if totalMin >= 12 * 60 && totalMin <= 18 * 60 {
            showPeriodOfTime = "chatroom_text_pm"
        } else if (totalMin > 18 * 60 && totalMin <= (23 * 60 + 59)) || totalMin == 0 {
            showPeriodOfTime = "chatroom_text_night"
        }
        return showPeriodOfTime
    }
}
@objcMembers
public class MessageAtInfoModel: NSObject, Codable {
    public var start = 0
    public var end = 0
    public var broken = false
}
@objcMembers
public class MessageAtCacheModel: NSObject {
    public var atModel: MessageAtInfoModel
    public var accid: String
    public var text: String?
    init(atModel: MessageAtInfoModel, accid: String) {
        self.atModel = atModel
        self.accid = accid
    }
}

