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
    // 文本是否在 底部
   // var atBottom: Bool = true
    
    //modifyTime
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
//        if let message = nimMessageModel , message.messageType == .MESSAGE_TYPE_TEXT {
//            atBottom = MessageUtils.timeShowAtBottom(messageModel: message)
//        }
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
