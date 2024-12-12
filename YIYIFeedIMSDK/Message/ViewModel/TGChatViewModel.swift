//
//  TGChatViewModel.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/2.
//

import UIKit
import NIMSDK
import AVFoundation

protocol TGChatViewModelDelegate: AnyObject {
    func onSend(_ message: V2NIMMessage, succeeded: Bool)
    func onReceive(_ messages: [V2NIMMessage])
    
    func onReceive(_ readReceipts: [V2NIMP2PMessageReadReceipt])
    func onReceive(_ readReceipts: [V2NIMTeamMessageReadReceipt])
    func onReceiveMessagesModified(_ messages: [V2NIMMessage])
    
    func onMessageRevokeNotifications(_ revokeNotifications: [V2NIMMessageRevokeNotification])
    func onMessagePinNotification(_ pinNotification: V2NIMMessagePinNotification)
    
    func onMessageQuickCommentNotification(_ notification: V2NIMMessageQuickCommentNotification)
    func onMessageDeletedNotifications(_ messageDeletedNotification: [V2NIMMessageDeletedNotification])
    func onClearHistoryNotifications(_ clearHistoryNotification: [V2NIMClearHistoryNotification])
}

class TGChatViewModel: NSObject {
    
    var conversationId: String
    var sessionId: String = ""
    var conversationType: V2NIMConversationType 
    weak var delegate: TGChatViewModelDelegate?
    var messages = [TGMessageData]()
    // 下拉时间戳
    private var oldMsg: V2NIMMessage?
    // 上拉时间戳
    private var newMsg: V2NIMMessage?

    var topMessage: V2NIMMessage? // 置顶消息
    var isReplying = false
    let messagPageNum: Int = 100
    var anchor: V2NIMMessage?
    
    //长按cell model
    var operationModel: TGMessageData?

    var isHistoryChat = false

    var deletingMsgDic = Set<String>()
    
    init(conversationId: String, conversationType: V2NIMConversationType) {
        self.conversationId = conversationId
        self.sessionId = MessageUtils.conversationTargetId(conversationId)
        self.conversationType = conversationType
        super.init()
        addObserver()
    }
    init(conversationId: String, conversationType: V2NIMConversationType, anchor: V2NIMMessage?) {
        self.conversationId = conversationId
        self.sessionId = MessageUtils.conversationTargetId(conversationId)
        self.conversationType = conversationType
        self.anchor = anchor
        super.init()
        addObserver()
    }

    func addObserver() {
        NIMSDK.shared().v2MessageService.add(self)
    }
    
    deinit {
        NIMSDK.shared().v2MessageService.remove(self)
    }
    
    func clearUnreadCount() {
        NIMSDK.shared().v2ConversationService.clearUnreadCount(byIds: [conversationId]) { result in
            
        }
        NIMSDK.shared().v2ConversationService.markConversationRead(conversationId) { _ in
            
        } failure: { _ in
            
        }

    }
    
    func loadData(_ completion: @escaping (V2NIMError?, Int, [TGMessageData]) -> Void) {
        messages.removeAll()
        getHistoryMessage(order: .QUERY_DIRECTION_DESC, message: nil) {[weak self] error, count, messageList in
            if messageList.count > 0 , let self = self {
                self.oldMsg = messageList.last
                let datas = messageList.reversed().compactMap { TGMessageData($0) }
                self.messages = processTimeData(datas)
                completion(error, self.messages.count, self.messages)
            } else {
                completion(error, 0, [])
            }
        }
    }
    
    /// 下拉获取历史消息
    /// - Parameter completion: 完成回调
    func dropDownRemoteRefresh(_ completion: @escaping (V2NIMError?, Int, [TGMessageData], IndexPath?)
                               -> Void) {
        if messages.isEmpty {
            oldMsg = nil
        }
        getHistoryMessage(order: .QUERY_DIRECTION_DESC, message: oldMsg) { [weak self] error, count, messageList in
            if messageList.count > 0 , let self = self {
                self.oldMsg = messageList.last
                let datas = messageList.reversed().compactMap { TGMessageData($0) }
                let newDatas = self.processTimeData(datas)
                self.messages.insert(contentsOf: newDatas, at: 0)
                var indexPath: IndexPath?
                if let msg = newDatas.last {
                    indexPath = self.getIndexPath(for: msg)
                }
                completion(error, self.messages.count, self.messages, indexPath)
            } else {
                completion(error, 0, [], nil)
            }
        }
    }

    
    func getHistoryMessage(order: V2NIMQueryDirection,
                                message: V2NIMMessage?,
                                _ completion: @escaping (V2NIMError?, NSInteger, [V2NIMMessage])
                                  -> Void) {
        let opt = V2NIMMessageListOption()
        opt.limit = messagPageNum
        opt.anchorMessage = message
        opt.conversationId = conversationId
        opt.direction = order
        if let msg = message {
            if order == .QUERY_DIRECTION_DESC {
                opt.endTime = msg.createTime
            } else {
                opt.beginTime = msg.createTime
            }
        }
        NIMSDK.shared().v2MessageService.getMessageList(opt) { messageArray in
            completion(nil, messageArray.count, messageArray)
        } failure: { error in
            completion(error, 0, [])
        }
    
    }
    //追加时间
    func processTimeData(_ datas: [TGMessageData]) -> [TGMessageData] {
        let lastTimeMessage = self.messages.filter { $0.type == .time }.last
        var compareTime: TimeInterval =  lastTimeMessage?.messageTime ?? 0.0
        var newDatas: [TGMessageData] = []
        datas.forEach { item in
            if let message = item.nimMessageModel,  let timeData = self.addTimeMessage(message, lastTs: compareTime){
                compareTime = item.messageTime
                newDatas.append(timeData)
            }
            newDatas.append(item)
        }
        return newDatas
    }
    
    func addTimeMessage(_ message: V2NIMMessage, lastTs: TimeInterval) ->TGMessageData?  {
        let curTs = message.createTime
        let dur = curTs - lastTs
        if (dur / 60) > 5 {
            let timeData = TGMessageData(nimMessageModel: message,  messageTime: message.createTime, type: .time)
//            messages.append(timeData)
            return timeData
        }
        return nil
    }


    
    func getIndexPath(for message: TGMessageData) -> IndexPath? {
        let index = self.messages.firstIndex { data in
            data.nimMessageModel?.messageClientId == message.nimMessageModel?.messageClientId
        }
        if let index = index {
            return IndexPath(row: index, section: 0)
        }
        return nil
    }
    
    func modelFromMessage(message: V2NIMMessage) -> TGMessageData {
       let model = TGMessageData(message)
//      let model = ChatMessageHelper.modelFromMessage(message: message)
//
//      if ChatMessageHelper.isRevokeMessage(message: model.message) {
//        if let content = ChatMessageHelper.getRevokeMessageContent(message: model.message) {
//          model.isReedit = true
//          model.message?.text = content
//        }
//        model.isRevoked = true
//      }
//
//      if let uid = ChatMessageHelper.getSenderId(message) {
//        let fullName = getShowName(uid)
//        let user = ChatMessageHelper.getUserFromCache(uid)
//        model.avatar = user?.user?.avatar
//        model.fullName = fullName
//        model.shortName = NEFriendUserCache.getShortName(fullName)
//
//        if user == nil {
//          contactRepo.getUserWithFriend(accountIds: [uid]) { _, _ in }
//        }
//      }
//
//      if let replyModel = getReplyMessageWithoutThread(message: message) {
//        model.replyedModel = replyModel
//        if replyModel.message == nil {
//          model.replyText = chatLocalizable("message_not_found")
//        }
//      }
//      delegate?.getMessageModel?(model: model)
      return model
    }
    /// 插入消息
    /// - Parameter newModel: 新消息模型
    /// - Returns: 插入位置
    func insertToMessages(_ newModel: TGMessageData) -> Int {
      var index = -1

      // 无消息时直接尾插
      if messages.isEmpty {
        messages.append(newModel)
        return 0
      }

      // 最新的消息直接尾插
      if newModel.nimMessageModel?.createTime ?? 0 >= (messages.last?.nimMessageModel?.createTime ?? 0) {
        messages.append(newModel)
        return messages.count - 1
      }

      for (i, model) in messages.enumerated() {
        if (newModel.nimMessageModel?.createTime ?? 0) < (model.nimMessageModel?.createTime ?? 0) {
          messages.insert(newModel, at: i)
          index = i
          break
        }
      }

      return index
    }
    
    func convertVideoToMP4(inputURL: URL, completion: @escaping (String?, Error?) -> Void) {
        let asset = AVURLAsset(url: inputURL)
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = String(dateFormatter.string(from: Date()))
        let fileName = String(date.filter { String($0).rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789")) != nil })
        
        let url = URL(fileURLWithPath: documentDirectory).appendingPathComponent("\(fileName).mp4")
      
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil, NSError(domain: "com.yourapp.videoconverter", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAssetExportSession"]))
            return
        }

        exportSession.outputURL = url
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(exportSession.outputURL?.path, nil)
            case .failed, .cancelled:
                let error = exportSession.error ?? NSError(domain: "com.yourapp.videoconverter", code: 0, userInfo: [NSLocalizedDescriptionKey: "Video export failed"])
                completion(nil, error)
            default:
                break
            }
        }
    }
    
    /// 发送消息
    /// - Parameters:
    ///   - message: 需要发送的消息体
    ///   - conversationId: 会话id
    ///   - completion: 回调
    func sendMessage(message: V2NIMMessage, conversationId: String, params: V2NIMSendMessageParams? = nil, completion: @escaping (V2NIMMessage?, V2NIMError?, UInt) -> Void) {
        NIMSDK.shared().v2MessageService.send(message, conversationId: conversationId, params: params) { result in
            completion(result.message, nil, 100)
        } failure: { error in
            completion(nil, error, 0)
        } progress: { pro in
            completion(nil, nil, pro)
        }
    }
    

    /// 发送文字消息
    func sendTextMessage(text: String, conversationId: String, remoteExt: [String: Any]? = nil, completion: @escaping (V2NIMMessage?, V2NIMError?) -> Void) {
        if text.count <= 0 {
          completion(nil, nil)
          return
        }
        let message = MessageUtils.textV2Message(text: text, remoteExt: remoteExt)
        sendMessage(message: message, conversationId: conversationId) { v2message, error, _  in
            completion(v2message, error)
        }
    }
    /// 发送语音消息
    func sendAudioMessage(filePath: String, conversationId: String, completion: @escaping (V2NIMError?) -> Void){
        let message = MessageUtils.audioV2Message(filePath: filePath, name: nil, sceneName: nil, duration: 0)
        sendMessage(message: message, conversationId: conversationId, params: nil) { v2message, error, pro  in
            completion(error)
        }
    }
    /// 发送图片消息
    func sendImageMessage(path: String, name: String? = "image", width: Int32 = 0, height: Int32 = 0, conversationId: String, completion: @escaping (V2NIMError?) -> Void) {
        let message = MessageUtils.imageV2Message(path: path, name: name, sceneName: nil, width: width, height: height)
        sendMessage(message: message, conversationId: conversationId, params: nil) { v2message, error, pro in
            completion(error)
        }
    }
    /// 发送视频消息
    func sendVideoMessage(url: URL, name: String? = "video", width: Int32 = 0, height: Int32 = 0, duration: Int32 = 0, conversationId: String, completion: @escaping (V2NIMMessage?, Error?, UInt) -> Void) {
        self.convertVideoToMP4(inputURL: url) { [weak self] path, error in
            if let path = path {
              let message = MessageUtils.videoV2Message(filePath: path, name: name, sceneName: nil, width: width, height: height, duration: duration)
                self?.sendMessage(message: message, conversationId: conversationId, params: nil) { v2message, v2error, pro in
                    completion(v2message, v2error?.nserror, pro)
                }
            } else {
             
              completion(nil, NSError(domain: "convert mov to mp4 failed", code: 414), 0)
            }
        }
    }
    
    /// 发送文件消息
    func sendFileMessage(filePath: String,
                         displayName: String?,
                         conversationId: String,
                         _ completion: @escaping (V2NIMMessage?, Error?, UInt) -> Void) {
        let message = MessageUtils.fileV2Message(filePath: filePath, displayName: displayName, sceneName: nil)
        
        sendMessage(message: message, conversationId: conversationId, params: nil) { message, error, pro in
            completion(message, error?.nserror, pro)
        }
    }
    
    /// 发送地理位置消息
    func sendLocationMessage(model: ChatLocaitonModel,
                                  conversationId: String,
                                  _ completion: @escaping (Error?) -> Void) {
        let message = MessageUtils.locationV2Message(lat: model.lat,
                                                     lng: model.lng,
                                                     address: model.title + model.address)
        message.text = model.title
        sendMessage(message: message, conversationId: conversationId, params: nil) { _, error, _ in
            completion(error?.nserror)
        }
    }
    
    /// 发送自定义消息
    func sendCustomMessage(text: String,
                                rawAttachment: String,
                                conversationId: String,
                                _ completion: @escaping (Error?) -> Void) {
        let message = MessageUtils.customV2Message(text: text, rawAttachment: rawAttachment)
        sendMessage(message: message, conversationId: conversationId, params: nil) { _, error, _ in
            completion(error?.nserror)
        }
    }
        
        /// 消息即将发送
    /// - Parameter message: 消息
    func sendingMsg(_ message: V2NIMMessage) {
        // 消息不是当前会话的消息，不处理（转发）
        if message.conversationId != conversationId {
            return
        }
        
        // 消息已存在则更新消息状态
        for (i, model) in messages.enumerated() {
            if message.messageClientId == model.nimMessageModel?.messageClientId {
                messages[i].nimMessageModel = message
                delegate?.onSend(message, succeeded: true)
                return
            }
        }
        
        // 避免重复发送
        //      if ChatDeduplicationHelper.instance.isMessageSended(messageId: message.messageClientId ?? "") {
        //        return
        //      }
        
        // 自定义消息发送之前的处理
        if newMsg == nil {
            newMsg = message
        }
        
        // 插入一条消息
        let _ = addTimeMessage(message, lastTs: self.messages.last?.nimMessageModel?.createTime ?? 0.0)
        let model = TGMessageData(message)
        messages.append(model)
        
        delegate?.onSend(message, succeeded: true)
    }
    
    
}

extension TGChatViewModel: V2NIMMessageListener {
    
    func onSend(_ message: V2NIMMessage) {
        switch message.sendingState {
        case .MESSAGE_SENDING_STATE_SENDING:
            sendingMsg(message)
        case .MESSAGE_SENDING_STATE_FAILED:
            delegate?.onSend(message, succeeded: false)
        case .MESSAGE_SENDING_STATE_SUCCEEDED: break

        default:
          break
        }
    }
    
    func onReceive(_ messages: [V2NIMMessage]) {
        var count = 0
        for msg in messages {
            if MessageUtils.conversationTargetId(msg.conversationId ?? "") == sessionId {
                if !(msg.messageServerId?.isEmpty == false), msg.messageType != .MESSAGE_TYPE_CUSTOM {
                  continue
                }
                count += 1
                // 自定义消息处理
                newMsg = msg
                let _ = addTimeMessage(msg, lastTs: self.messages.last?.nimMessageModel?.createTime ?? 0.0)
                let model = TGMessageData(msg)
                self.messages.append(model)
                
            }
        }
        if count > 0 { delegate?.onReceive(messages)}
        
    }
    
    func onReceive(_ readReceipts: [V2NIMP2PMessageReadReceipt]) {
        
    }
    
    func onReceive(_ readReceipts: [V2NIMTeamMessageReadReceipt]) {
        
    }
    
    func onReceiveMessagesModified(_ messages: [V2NIMMessage]) {
        
    }
    
    func onMessageRevokeNotifications(_ revokeNotifications: [V2NIMMessageRevokeNotification]) {
        
    }
    
    func onMessagePinNotification(_ pinNotification: V2NIMMessagePinNotification) {
        
    }
    
    func onMessageQuickCommentNotification(_ notification: V2NIMMessageQuickCommentNotification) {
        
    }
    
    func onMessageDeletedNotifications(_ messageDeletedNotification: [V2NIMMessageDeletedNotification]) {
        
    }
    
    func onClearHistoryNotifications(_ clearHistoryNotification: [V2NIMClearHistoryNotification]) {
        
    }
    
    
}

extension Array {
    // 数组去重
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
}
