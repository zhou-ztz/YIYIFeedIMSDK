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
    
    func onReceiveP2PReadReceipts(_ indexPaths: [IndexPath])
    func onReceiveTeamReadReceipts(_ indexPaths: [IndexPath])
    func onReceiveMessagesModified(_ messages: [V2NIMMessage])
    func onRevokeMessage(atIndexs: [IndexPath])
    
    func onMessageRevokeNotifications(_ revokeNotifications: [V2NIMMessageRevokeNotification])
    func onMessagePinNotification(_ pinNotification: V2NIMMessagePinNotification)
    
    func onMessageQuickCommentNotification(_ notification: V2NIMMessageQuickCommentNotification)
    func onMessageDeletedNotifications(_ messageDeletedNotification: [V2NIMMessageDeletedNotification])
    func onClearHistoryNotifications(_ clearHistoryNotification: [V2NIMClearHistoryNotification])
    
    ///语音
    func recordAudio(_ filePath: String?, didBeganWithError error: Error?)
    func recordAudio(_ filePath: String?, didCompletedWithError error: Error?)
    func recordAudioDidCancelled()
    func recordAudioProgress(_ currentTime: TimeInterval)
    //func recordAudioInterruptionBegin()
    /// 自定义通知
    func onReceiveCustomNotification(senderId: String, content: [String: Any])
}

class TGChatViewModel: NSObject {
    
    var conversationId: String
    var sessionId: String = ""
    var conversationType: V2NIMConversationType 
    weak var delegate: TGChatViewModelDelegate?
    var messages = [TGMessageData]()
    // 下拉时间戳
    var oldMsg: V2NIMMessage?
    // 上拉时间戳
    private var newMsg: V2NIMMessage?

    var topMessage: V2NIMMessage? // 置顶消息
    var isReplying = false
    let messagPageNum: Int = 20
    var anchor: V2NIMMessage?
    
    //长按cell model
    var operationModel: TGMessageData?
    var isHistoryChat = false

    var deletingMsgDic = Set<String>()
    
    //记录播放语音的cell
    var playingCell: AudioMessageCell?
    var playingModel: TGMessageData?
    //记录当前录制的语音
    var saveAudioMessage: V2NIMMessage?
    //记录当前录制的语音文件地址
    var saveAudioFilePath: String?
    ///未播放语音列表
    var pendingAudioMessages: [V2NIMMessage]?
    
    var audioPlayer: AVAudioPlayer?
    var progressTimer: Timer?
    
    //被置顶的列表
    var pinnedList: [PinnedMessageModel] = []
    //当前的Pinned msg
    var currentPinned: PinnedMessageModel?
    
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
        NIMSDK.shared().mediaManager.add(self)
        NIMSDK.shared().v2NotificationService.addNoticationListener(self)
    }
    
    deinit {
        stop()
        NIMSDK.shared().v2MessageService.remove(self)
        NIMSDK.shared().mediaManager.remove(self)
        NIMSDK.shared().v2NotificationService.remove(self)
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
                self.handleMultiImageMessage()
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
                self.handleMultiImageMessage()
                var indexPath: IndexPath?
                if let msg = newDatas.last {
                    indexPath = self.getIndexPathForMessage(model: msg)
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
        if (dur / 60) > 60 {
            let msg = V2NIMMessageCreator.createTipsMessage("time")
            let timeData = TGMessageData(nimMessageModel: msg,  messageTime: message.createTime, type: .time)
            //timeData.nimMessageModel?.messageClientId = "-1"
            return timeData
        }
        return nil
    }
    ///处理多张连续图片消息
    func handleMultiImageMessage() {
        for (index, messageData) in messages.enumerated() {
            if messageData.nimMessageModel?.messageType == .MESSAGE_TYPE_IMAGE {
                var i = index + 1
                repeat {
                    if messages.indices.contains(i) {
                        let nextMessage = messages[i]
                        
                        if nextMessage.nimMessageModel?.messageType == .MESSAGE_TYPE_IMAGE && self.getMessageSecondsTimeInterval(messageData.messageTime, nextMessage.messageTime) < 5 {
                            if messageData.messageList.contains(messageData) == false {
                                messageData.messageList.append(messageData)
                            }
                            
                            messageData.messageList.append(nextMessage)
                        } else {
                            break
                        }
                    }
                    
                    i += 1
                } while messages.indices.contains(i)
            }
        }
        
        for (_, messageData) in messages.enumerated() {
            if messageData.messageList.count >= 4 {
                for sub in messageData.messageList {
                    if sub != messageData, let i = messages.firstIndex(of: sub) {
                        messages.remove(at: i)
                    }
                }
            } else {
                messageData.messageList.removeAll()
            }
        }
    }
    
    func getMessageSecondsTimeInterval(_ startInterval: TimeInterval, _ endInterval: TimeInterval) -> Int {
        let startIntervalDate = Date(timeIntervalSince1970: startInterval)
        let endIntervalDate = Date(timeIntervalSince1970: endInterval)
        
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([ .second])
        let datecomponents = calendar.dateComponents(unitFlags, from: startIntervalDate, to: endIntervalDate)
        let seconds = datecomponents.second ?? 0
        
        return seconds
    }

    ///删除消息
    ///onlyDeleteLocal 是否只删除本地
    func deleteMessage(messages: [V2NIMMessage], onlyDeleteLocal: Bool = false, completion: @escaping (Error?) -> Void) {
        NIMSDK.shared().v2MessageService.delete(messages, serverExtension: "", onlyDeleteLocal: onlyDeleteLocal) {
            completion(nil)
        } failure: { error in
            completion(error.nserror)
        }

    }
    /// 删除消息列表
    func deleteMessageForUI(messages: [V2NIMMessage]) {
        messages.forEach { data in
            if let index = self.messages.firstIndex(where: { model in
                model.nimMessageModel?.messageClientId == data.messageClientId
            }) {
                self.messages.remove(at: index)
            }
           
        }
        
    }
    ///删除所有人消息
    func revokeSelectedMessage(_ data: TGMessageData, completion: ((Int?, String?) -> Void)? = nil) {
        guard let message = data.nimMessageModel else {
            return
        }

        let dispatchGroup = DispatchGroup()
        var errorCount = 0
        var errorMessage : String? = nil
        
        if data.messageList.count >= 4 {
            for item in data.messageList {
                if errorCount > 0 { break }
                
                if let messageModel = item.nimMessageModel {
                    dispatchGroup.enter() // Notify the group a task has started
                    
                    self.deleteMessageRequest(messageModel, completion: { code, message in
                        defer { dispatchGroup.leave() } // Notify the group the task is done
                        
                        if let code = code, code == 200 {
                           
                        } else {
                            errorCount += 1
                            errorMessage = message
                        }
                    })
                }
            }
            
            // When all async calls are done, this gets called
            dispatchGroup.notify(queue: .main) {
                if errorCount > 0 {
                    completion?(-1, errorMessage)
                } else {
                    completion?(200, nil)
                }
            }
        } else {
            self.deleteMessageRequest(message, completion: { code, message in
                completion?(code, message)
            })
        }
    }
    
    private func deleteMessageRequest(_ message: V2NIMMessage, completion: ((Int?, String?) -> Void)? = nil) {
        if self.conversationType == .CONVERSATION_TYPE_P2P {
            
            if let json = MessageUtils.formPayloadParameters(sessionId: self.sessionId, sessionType: "0")?.toJSON {
                let param = V2NIMMessageRevokeParams()
                param.pushContent = "recent_msg_desc_p2p_msg".localized
                param.pushPayload = json
                NIMSDK.shared().v2MessageService.revokeMessage(message, revokeParams: param) {
                    completion?(200, nil)
                } failure: { error in
                    if let error1 = error.nserror as? NSError {
                        completion?(error1.code, nil)
                    }
                }
        
            }
        } else {
            let accountId = NIMSDK.shared().v2LoginService.getLoginUser() ?? ""
            NIMSDK.shared().v2TeamService.getTeamMemberList(byIds: self.sessionId, teamType: .TEAM_TYPE_NORMAL, accountIds: [accountId]) { teamMembers in
                if let teamMember = teamMembers.first, teamMember.memberRole == .TEAM_MEMBER_ROLE_OWNER || teamMember.memberRole == .TEAM_MEMBER_ROLE_MANAGER {
                    TGIMNetworkManager.revokeMessageRequest(deleteMsgid: message.messageServerId ?? "", timetag: String(Int(message.createTime * 1000)), type: 8, from: message.senderId ?? "", to: message.receiverId ?? "") { revokeModel, error in
                        if let model = revokeModel {
                            completion?(200, nil)
                        } else {
                            if let error = error as? NSError {
                                completion?(error.code, nil)
                            }
                        }
                    }
                } else {
                    
                    if let json = MessageUtils.formPayloadParameters(sessionId: self.sessionId, sessionType: "1")?.toJSON {
                        let param = V2NIMMessageRevokeParams()
                        param.pushContent = "recent_msg_desc_group_msg".localized
                        param.pushPayload = json
                        NIMSDK.shared().v2MessageService.revokeMessage(message, revokeParams: param) {
                            completion?(200, nil)
                        } failure: { error in
                            if let error1 = error.nserror as? NSError {
                                completion?(error1.code, nil)
                            }
                        }
                
                    }
                    
                }
            } failure: { error in
                if let error1 = error.nserror as? NSError {
                    completion?(error1.code, error1.localizedDescription)
                }
                
            }
            
            
        }
    }
    
    
    func findMessageIndexPath(messages: [V2NIMMessage]) -> [IndexPath]{
        var indexPaths: [IndexPath] = []
        messages.forEach { data in
            if let index = self.messages.firstIndex(where: { model in
                model.nimMessageModel?.messageClientId == data.messageClientId
            }){
                let indexPath = IndexPath(row: index, section: 0)
                indexPaths.append(indexPath)
            }
        }
        return indexPaths
    }
    
    func findMessageDataIndexPath(data: TGMessageData) -> IndexPath?{
        var indexPath: IndexPath?
        if let index = messages.firstIndex(of: data) {
            indexPath = IndexPath(row: index, section: 0)
        }
        return indexPath
    }
    
    func findMessageData(messageClientId: String) -> TGMessageData? {
        var data: TGMessageData?
        if let index = self.messages.firstIndex(where: { model in
            model.nimMessageModel?.messageClientId == messageClientId
        }) {
            data = self.messages[index]
        }
        return data
    }
    
    
    /// 获取消息列表
    func getDeleteMessages(indexPaths: [IndexPath]) -> [V2NIMMessage] {
        var messageList: [V2NIMMessage] = []
        indexPaths.forEach { indexPath in
            for (index, model) in self.messages.enumerated() {
                if index == indexPath.row , let message = model.nimMessageModel {
                    messageList.append(message)
                }
            }
        }
        return messageList
    }
    
    func getDeleteMessageDatas(indexPaths: [IndexPath]) -> [TGMessageData] {
        var messageList: [TGMessageData] = []
        indexPaths.forEach { indexPath in
            for (index, model) in self.messages.enumerated() {
                if index == indexPath.row {
                    messageList.append(model)
                }
            }
        }
        return messageList
    }
    
    func findRemainAudioMessages(message: V2NIMMessage) -> [V2NIMMessage]? {
        if message.isSelf  {
            return nil
        }
        return self.messages.filter {
            guard let model = $0.nimMessageModel else {
                return false
            }
            return !model.isSelf && model.messageType == .MESSAGE_TYPE_AUDIO
        }.compactMap{$0.nimMessageModel}
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
        let config = V2NIMMessageConfig()
        config.readReceiptEnabled = true
        config.unreadEnabled = true
        params?.messageConfig = config
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
        let param = V2NIMSendMessageParams()
        let message = MessageUtils.textV2Message(text: text, remoteExt: remoteExt)
        sendMessage(message: message, conversationId: conversationId, params: param) { v2message, error, _  in
            completion(v2message, error)
        }
    }
    /// 发送语音消息
    func sendAudioMessage(filePath: String, duration: Int32, conversationId: String, completion: @escaping (V2NIMError?) -> Void){
        let param = V2NIMSendMessageParams()
        let pushConfig = V2NIMMessagePushConfig()
        pushConfig.pushContent = "sent_a_voice_msg".localized
        param.pushConfig = pushConfig
        let message = MessageUtils.audioV2Message(filePath: filePath, name: nil, sceneName: nil, duration: duration)
        sendMessage(message: message, conversationId: conversationId, params: param) { v2message, error, pro  in
            completion(error)
        }
    }
    /// 发送图片消息
    func sendImageMessage(path: String, name: String? = "image", width: Int32 = 0, height: Int32 = 0, conversationId: String, completion: @escaping (V2NIMError?) -> Void) {
        let param = V2NIMSendMessageParams()
        let pushConfig = V2NIMMessagePushConfig()
    
        pushConfig.pushContent = "sent_a_img".localized
        param.pushConfig = pushConfig
        let message = MessageUtils.imageV2Message(path: path, name: name, sceneName: nil, width: width, height: height)
        sendMessage(message: message, conversationId: conversationId, params: param) { v2message, error, pro in
            completion(error)
        }
    }
    /// 发送视频消息
    func sendVideoMessage(url: URL, name: String? = "video", width: Int32 = 0, height: Int32 = 0, duration: Int32 = 0, conversationId: String, completion: @escaping (V2NIMMessage?, Error?, UInt) -> Void) {
        self.convertVideoToMP4(inputURL: url) { [weak self] path, error in
            if let path = path {
                let param = V2NIMSendMessageParams()
                let pushConfig = V2NIMMessagePushConfig()
                pushConfig.pushContent = "sent_a_video_msg".localized
                param.pushConfig = pushConfig
                let message = MessageUtils.videoV2Message(filePath: path, name: name, sceneName: nil, width: width, height: height, duration: duration)
                self?.sendMessage(message: message, conversationId: conversationId, params: param) { v2message, v2error, pro in
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
        let param = V2NIMSendMessageParams()
        let pushConfig = V2NIMMessagePushConfig()
        pushConfig.pushContent = "sent_a_file".localized
        param.pushConfig = pushConfig
        sendMessage(message: message, conversationId: conversationId, params: param) { message, error, pro in
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
        let param = V2NIMSendMessageParams()
        let pushConfig = V2NIMMessagePushConfig()
       // pushConfig.pushContent = "sent_a_file".localized
        param.pushConfig = pushConfig
        sendMessage(message: message, conversationId: conversationId, params: param) { _, error, _ in
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
    /// 转发消息
    func forwardV2Message(_ indexPaths: [IndexPath], to sessionId: String, isTeam: Bool) {
        indexPaths.forEach { path in
            if self.messages.count > path.row, let originalMessage = self.messages[path.row].nimMessageModel, let accountId = NIMSDK.shared().v2LoginService.getLoginUser() {
                
                let model = self.messages[path.row]
                let conversationId = isTeam ? "\(accountId)|2|\(sessionId)" : "\(accountId)|1|\(sessionId)"
                // 处理多图消息
                if model.messageList.count >= 4 {
                    model.messageList.forEach { data in
                        if let originalData = data.nimMessageModel {
                            let message = V2NIMMessageCreator.createForwardMessage(originalData)
                            NIMSDK.shared().v2MessageService.send(message, conversationId: conversationId, params: nil) { _ in
                                
                            } failure: { _ in
                                
                            }
                        }
                    }
                    
                } else {
                    let message = V2NIMMessageCreator.createForwardMessage(originalMessage)
                    NIMSDK.shared().v2MessageService.send(message, conversationId: conversationId, params: nil) { _ in
                        
                    } failure: { _ in
                        
                    }
                }
                
                
                
            }
        }
    }
    
    /// 撤回消息
    func revokeTextMessage(message: V2NIMMessage, _ completion: @escaping (Error?) -> Void) {
        let param = V2NIMMessageRevokeParams()
        param.postscript = MessageUtils.tipOnP2PV2MessageRevoked()
        NIMSDK.shared().v2MessageService.revokeMessage(message, revokeParams: param) {
            completion(nil)
        } failure: { error in
            completion(error.nserror)
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
    
    /// 消息发送完成
    /// - Parameters:
    ///   - message: 消息
    ///   - error: 错误信息
    func sendMsgSuccess(_ message: V2NIMMessage) {
    
        if message.conversationId != conversationId {
            return
        }

        for (i, msg) in messages.enumerated() {
            if message.messageClientId == msg.nimMessageModel?.messageClientId {
                messages[i].nimMessageModel = message
                break
            }
        }
        delegate?.onSend(message, succeeded: true)

    }
    
    func sendMsgFailed(_ message: V2NIMMessage, _ error: Error?) {
        guard message.messageClientId != nil else {
            return
        }
        for (i, msg) in messages.enumerated() {
            if message.messageClientId == msg.nimMessageModel?.messageClientId {
                messages[i].nimMessageModel = message
                break
            }
        }
        delegate?.onSend(message, succeeded: true)
    }
    
    
    func downLoadfFile(filePath: String, url: String){
        NIMSDK.shared().v2StorageService.downloadFile(url, filePath: filePath) { _ in
            
        } failure: { _ in
            
        }
    }
    //获取图片视频message
    func getImageMessages() -> [V2NIMMessage] {
        var imageMsgs = [V2NIMMessage]()
        messages.forEach { model in
            if model.messageType == .MESSAGE_TYPE_IMAGE || model.messageType == .MESSAGE_TYPE_VIDEO , let message = model.nimMessageModel {
                imageMsgs.append(message)
            }
        }
        return imageMsgs
    }
    /// 查询当前会话的ImageVideo message
    func searchImageVideoMessage(_ completion: @escaping ([V2NIMMessage]?, Error?)->Void) {
       
        let opt = V2NIMMessageListOption()
        opt.limit = 100
        opt.messageTypes = [V2NIMMessageType.MESSAGE_TYPE_IMAGE.rawValue,  V2NIMMessageType.MESSAGE_TYPE_VIDEO.rawValue]
        opt.anchorMessage = nil
        opt.conversationId = conversationId
        opt.direction = .QUERY_DIRECTION_ASC
        
        NIMSDK.shared().v2MessageService.getMessageList(opt) { messages in
            completion(messages, nil)
        } failure: { error in
            completion(nil, error.nserror )
        }
        

    }
    /// 获取当前indexpath
    func getIndexPathForMessage(model: TGMessageData) -> IndexPath?{
        var indexPath: IndexPath?
        if let index = messages.firstIndex(of: model) {
            indexPath = IndexPath(row: index, section: 0)
        }
        return indexPath
    }
    /// 根据MessageClientId获取当前indexpath
    func getIndexPathForMessageClientId(messageClientId: String) -> IndexPath?{
        var indexPath: IndexPath?
        if let index = messages.firstIndex(where: { model in
            model.nimMessageModel?.messageClientId == messageClientId
        }){
            indexPath = IndexPath(row: index, section: 0)
        }
        return indexPath
    }
    /// 获取message
    func getMessageDataForMessageClientId(messageClientId: String) -> TGMessageData? {
        let messageData = self.messages.first { message in
            message.nimMessageModel?.messageClientId == messageClientId
        }
        return messageData
    }
    
    func revokeMessageUpdateUI(_ messageServerId: String) {
        var index = -1
        for (i, model) in messages.enumerated() {
            if model.nimMessageModel?.messageServerId == messageServerId {
                index = i
                continue
            }
        }
        var indexs = [IndexPath]()
        if index >= 0 {
            indexs.append(IndexPath(row: index, section: 0))
            messages.remove(at: index)
            delegate?.onRevokeMessage(atIndexs: indexs)
            
        }
    }
    /// 获取 at RemoteExtension
    func getAtRemoteExtension(_ mentionUser: [AutoMentionsUser]) -> [String: Any]? {
        var remoteExt: [String: Any] = [:]
        let mentionUsernames = mentionUser.compactMap { $0.context?["username"] as? String }
        let isMentionAll: Bool = mentionUsernames.contains(where: { $0 == "rw_text_all_people".localized })
        remoteExt["usernames"] = mentionUsernames
        
        if isMentionAll {
            remoteExt["mentionAll"] = "rw_text_all_people".localized
        }
        
        return remoteExt
    }
    
    
    // MARK: audio play
    func startPlay(cell: AudioMessageCell?, model: TGMessageData?) {
        guard let isSend = model?.nimMessageModel?.isSelf else {
            return
        }
        if playingModel == model {
            if let audioPlayer = audioPlayer, audioPlayer.isPlaying {
                stopPlay()
            } else {
                startPlaying(model: model, isSend: isSend)
            }
        } else {
            stopPlay()
            playingCell = cell
            playingModel = model
            startPlaying(model: model, isSend: isSend)
        }
    }
    
    func startPlaying(model: TGMessageData?, isSend: Bool) {
        guard let message = model?.nimMessageModel, let audio = message.attachment as? V2NIMMessageAudioAttachment, let path = audio.path else {
            return
        }
        playingCell?.startAnimation(model: model)
        if FileManager.default.fileExists(atPath: path) {
            play(audioPath: path)
            playingModel?.isPlaying = true
            IMAudioCenter.shared.currentMessage = model?.nimMessageModel
            IMAudioCenter.shared.maximumValue = playingCell?.maximumValue ?? 0.0
            pendingAudioMessages = findRemainAudioMessages(message: message)
        } else {
            playingCell?.stopAnimation(model: model)
            pendingAudioMessages = nil
            IMAudioCenter.shared.clearAll()
        }
    }
    
    func stopPlay() {
        stop()
        playingCell?.stopAnimation(model: playingModel)
        playingModel = nil
        playingCell = nil
        pendingAudioMessages = nil
        IMAudioCenter.shared.clearAll()
    }
    
    func playNextAudio() {
        guard let pendingAudioMessage = pendingAudioMessages else {
            return
        }
        
        if let message = pendingAudioMessage.last {
            guard  let audio = message.attachment as? V2NIMMessageAudioAttachment, let path = audio.path else {
                return
            }
            pendingAudioMessages?.removeLast()
            DispatchQueue.main.async {
                NIMSDK.shared().mediaManager.play(path)
            }
        }
    }
    
    func play(audioPath: String) {
        let audioURL = URL(fileURLWithPath: audioPath)
        do {
            // 设置听筒/扬声器
            let cate: AVAudioSession.Category =  AVAudioSession.Category.playback
            try AVAudioSession.sharedInstance().setCategory(cate, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            startProgressTimer()
        } catch {
            print("音频加载失败: \(error)")
        }
        
    }
    
    func stop() {
        audioPlayer?.stop()
        stopProgressTimer()
        IMAudioCenter.shared.clearAll()
    }
    
    func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        RunLoop.current.add(progressTimer!, forMode: .common)
    }
    
    func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    @objc func updateProgress() {
        guard let player = audioPlayer else { return }
        let currentTime = player.currentTime
        let duration = player.duration
        let progress: Float = Float(currentTime) / Float(duration)
        print("当前播放时间: \(currentTime), 总时长: \(duration), 进度：\(progress)")
        IMAudioCenter.shared.progressValue = progress
        DispatchQueue.main.async {
            self.playingCell?.timerCountDown()
        }
    }

    
    /// 群组置顶消息
    func getGroupPinnedList(groupId: String, _ completion: @escaping ([PinnedMessageModel]?, Error?)->Void) {
        TGIMNetworkManager.showGroupPinnedMessage(group_id: groupId) { resultModel, error in
            completion(resultModel, error)
        }
    }
    /// 置顶消息
    func storePinnedMessage(imMsgId: String, imGroupId: String = "", content: String = "", deleteFlag: Bool = false, completion: @escaping (_ resultModel: PinnedMessageModel?, _ error: Error?) -> Void) {
        TGIMNetworkManager.storePinnedMessage(imMsgId: imMsgId, imGroupId: imGroupId, content: content, deleteFlag: deleteFlag) { resultModel, error in
            completion(resultModel, error)
        }
    }
    /// 删除置顶消息
    func deletePinnedMessage(id: Int, completion: @escaping (_ resultModel: PinnedMessageModel?, _ error: Error?) -> Void) {
        TGIMNetworkManager.deletePinnedMessage(id: id) { resultModel, error in
            completion(resultModel, error)
        }
    }
    /// 该消息是否置顶
    func messagePinned(for message: V2NIMMessage) -> Bool  {
        var flag = false
        for pinItem in pinnedList {
            if pinItem.im_msg_id == message.messageClientId {
                flag = true
                return flag
            }
        }
        return flag
    }
    
    func sessionBackgroundImage() -> UIImage? {
        let defaults = UserDefaults.standard
        let imagedata = defaults.object(forKey: Constants.GlobalChatWallpaperImageKey) as? Data
        if let imagedata = imagedata {
            return UIImage(data: imagedata)
        }
        return nil
    }
    
    func getP2PMessageReceipt(_ completion: @escaping ([IndexPath], Error?) -> Void) {
        NIMSDK.shared().v2MessageService.getP2PMessageReceipt(self.conversationId) {[weak self] readReceipt in
            guard let self = self else {return}

            var reloadIndexs = [IndexPath]()
            for (i, model) in self.messages.enumerated() {
                if model.nimMessageModel?.isSelf == false {
                    continue
                }
                if let msgCreateTime = model.nimMessageModel?.createTime, msgCreateTime <= readReceipt.timestamp {
                  if model.readCount == 1, model.unreadCount == 0 {
                    continue
                  }

                  model.readCount = 1
                  model.unreadCount = 0
                  reloadIndexs.append(IndexPath(row: i, section: 0))
                }
            }
            completion(reloadIndexs, nil)
            
        } failure: { error in
            completion([], error.nserror)
        }
        
        
        
    }
    
    func getTeamMessageReceipts(_ completion: @escaping ([IndexPath], Error?) -> Void) {
        
        var messageList: [V2NIMMessage] = []
        self.messages.forEach { model in
            if let message = model.nimMessageModel, message.isSelf, message.messageType != .MESSAGE_TYPE_TIP, message.messageType != .MESSAGE_TYPE_NOTIFICATION, model.type != .time, message.messageStatus.readReceiptSent == false {
                messageList.append(message)
            }
        }
        if messageList.count == 0 {
            completion([], nil)
            return
        }
        
        NIMSDK.shared().v2MessageService.getTeamMessageReceipts(messageList) {[weak self] readReceipts in
            guard let self = self else {return}
            var reloadIndexs = [IndexPath]()
            
            readReceipts.forEach { readReceipt in
                for (i, model) in self.messages.enumerated() {
                    if !self.getMessageCanReceipt(model: model) {
                        continue
                    }
                    if model.nimMessageModel?.messageClientId == readReceipt.messageClientId {
                        if model.readCount == readReceipt.readCount,
                           model.unreadCount == readReceipt.unreadCount {
                            continue
                        }
                        
                        model.readCount = readReceipt.readCount
                        model.unreadCount = readReceipt.unreadCount
                        reloadIndexs.append(IndexPath(row: i, section: 0))
                    }
                }
            }
            completion(reloadIndexs, nil)
        } failure: { error in
            completion([], error.nserror)
        }
        
    }
    
    func readAllMessageReceipt(completion: (() -> Void)?) {
//        NIMSDK.shared().v2ConversationService.clearUnreadCount(byIds: [self.conversationId]) { _ in
//            
//        } failure: { error in
//            
//        }
//        
//        NIMSDK.shared().v2ConversationService.markConversationRead(self.conversationId, success: nil)
        var messageReceipts: [V2NIMMessage] = []
        for model in self.messages {
            if model.type == .time || model.messageType == .MESSAGE_TYPE_TIP || model.messageType == .MESSAGE_TYPE_NOTIFICATION {
                continue
            }
            if let message = model.nimMessageModel, !message.isSelf {
                messageReceipts.append(message)
            }
        }
        if messageReceipts.count == 0 {
            return
        }
        if conversationType == .CONVERSATION_TYPE_P2P {
            for messageReceipt in messageReceipts {
                NIMSDK.shared().v2MessageService.sendP2PMessageReceipt(messageReceipt, success: {
                    
                }) { error in
                    
                }
            }
            completion?()
        } else {
            NIMSDK.shared().v2MessageService.sendTeamMessageReceipts(messageReceipts) {
                completion?()
            } failure: { error in
                completion?()
            }
            
        }
        
        
    }
    
    func readMessageReceipt(messages: [V2NIMMessage], completion: (() -> Void)?) {
        NIMSDK.shared().v2ConversationService.markConversationRead(self.conversationId, success: nil)
        if conversationType == .CONVERSATION_TYPE_P2P {
            for message in messages {
                NIMSDK.shared().v2MessageService.sendP2PMessageReceipt(message, success: nil, failure: nil)
            }
            completion?()
        } else {
            NIMSDK.shared().v2MessageService.sendTeamMessageReceipts(messages) {
                completion?()
            } failure: { _ in
                completion?()
            }
            
        }
    }
    /// 该消息是否可以 Receipt
    func getMessageCanReceipt(model: TGMessageData) -> Bool {
        if model.nimMessageModel?.isSelf != false, model.type != .time, model.nimMessageModel?.messageType != .MESSAGE_TYPE_TIP, model.nimMessageModel?.messageType != .MESSAGE_TYPE_NOTIFICATION{
            return true
        }
        return false
    }
    
    ///翻译文本消息
    func translateTextMessage(messageText: String, completion: ((String?, Error?) -> Void)?) {
        TGIMNetworkManager.translateTexts(message: messageText) { model, error in
            if let error = error {
                completion?(nil, error)
            } else {
                completion?(model?.text, nil)
            }
        }
    }
    
    func updateTranslateMessage(for data: TGMessageData, with result: String) -> TGMessageData {
        if let attach = data.customAttachment as? IMTextTranslateAttachment {
            attach.translatedText = result
        }
        return data
    }
    
    func insert(message: TGMessageData, after ori: TGMessageData) {
        if let indexPath = findMessageDataIndexPath(data: ori) {
            self.messages.insert(message, at: indexPath.row + 1)
        }
    }
    
    /// 发送礼物状态通知
    func sendGiftStatusNotification(message: TGMessageData, giftMessageStatus: GiftMessageStatus, completion: @escaping (Bool) -> Void) {
        guard let nimMessage = message.nimMessageModel, let ext = ["gift_message_status": giftMessageStatus.rawValue].toJSON else { return }
        let conversationId = self.conversationId
        nimMessage.localExtension = ext
        NIMSDK.shared().v2MessageService.updateMessageLocalExtension(nimMessage, localExtension: ext) { _ in
            completion(true)
            let dict: [String: Any] = [NTESNotifyID: NTESGiftMsgUpdated,
                                       "gift_message_status": giftMessageStatus.rawValue,
                                       "im_msg_id": nimMessage.messageClientId ?? ""]

            guard let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []),
                  let json = String(data: jsonData, encoding: .utf8) else { return }
            
            let param = V2NIMSendCustomNotificationParams()
            let pushConfig = V2NIMNotificationPushConfig()
            pushConfig.pushEnabled = false
            param.pushConfig = pushConfig
            let notificationConfig = V2NIMNotificationConfig()
            notificationConfig.offlineEnabled = false
            param.notificationConfig = notificationConfig
            NIMSDK.shared().v2NotificationService.sendCustomNotification(conversationId, content: json, params: param) {
                
            } failure: { _ in
                
            }
        } failure: { _ in
            completion(false)
        }

        
    }
    
}

extension TGChatViewModel: V2NIMMessageListener {
    
    func onSend(_ message: V2NIMMessage) {
        switch message.sendingState {
        case .MESSAGE_SENDING_STATE_SENDING:
            sendingMsg(message)
        case .MESSAGE_SENDING_STATE_FAILED:
            sendMsgFailed(message, nil)
        case .MESSAGE_SENDING_STATE_SUCCEEDED:
            sendMsgSuccess(message)
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
        var reloadIndexPaths: [IndexPath] = []
        
        for readReceipt in readReceipts {
            if readReceipt.conversationId != conversationId {
                continue
            }
            
            for (i, model) in messages.enumerated() {
                if !self.getMessageCanReceipt(model: model) {
                    continue
                }
                
                if let msgCreateTime = model.nimMessageModel?.createTime, msgCreateTime <= readReceipt.timestamp {
                    if model.readCount == 1, model.unreadCount == 0 {
                        continue
                    }
                    
                    model.readCount = 1
                    model.unreadCount = 0
                    reloadIndexPaths.append(IndexPath(row: i, section: 0))
                }
            }
        }
        
        self.delegate?.onReceiveP2PReadReceipts(reloadIndexPaths)
    }
    
    func onReceive(_ readReceipts: [V2NIMTeamMessageReadReceipt]) {
        var reloadIndexPaths: [IndexPath] = []
        
        for readReceipt in readReceipts {
            if readReceipt.conversationId != conversationId {
                continue
            }
            
            for (i, model) in messages.enumerated() {
                if !self.getMessageCanReceipt(model: model) {
                    continue
                }
                if model.nimMessageModel?.messageClientId == readReceipt.messageClientId {
                    model.readCount = readReceipt.readCount
                    model.unreadCount = readReceipt.unreadCount
                    reloadIndexPaths.append(IndexPath(row: i, section: 0))
                }
            }
        }
        
        self.delegate?.onReceiveTeamReadReceipts(reloadIndexPaths)
    }
    
    func onReceiveMessagesModified(_ messages: [V2NIMMessage]) {
        
    }
    
    func onMessageRevokeNotifications(_ revokeNotifications: [V2NIMMessageRevokeNotification]) {
        guard let messageServerId = revokeNotifications.first?.messageRefer?.messageServerId else { return }
        self.revokeMessageUpdateUI(messageServerId)
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
// MARK: NIMMediaManagerDelegate
extension TGChatViewModel: NIMMediaManagerDelegate {
    
    func recordAudio(_ filePath: String?, didBeganWithError error: Error?) {
        self.delegate?.recordAudio(filePath, didBeganWithError: error)
    }
    func recordAudio(_ filePath: String?, didCompletedWithError error: Error?) {
        self.delegate?.recordAudio(filePath, didCompletedWithError: error)
    }
    
    func recordAudioDidCancelled() {
        self.delegate?.recordAudioDidCancelled()
    }
    
    func recordAudioProgress(_ currentTime: TimeInterval) {
        self.delegate?.recordAudioProgress(currentTime)
    }
    
    func recordAudioInterruptionBegin() {
        NIMSDK.shared().mediaManager.cancelRecord()
    }
    
    func recordFileCanBeSend(filePath: String?) -> Bool {
        let anURL = URL(fileURLWithPath: filePath ?? "")
        let urlAsset = AVURLAsset(url: anURL, options: nil)
        let time = urlAsset.duration
        let mediaLength = CGFloat(CMTimeGetSeconds(time))
        return mediaLength > 1
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
// MARK:  V2NIMNotificationListener
extension TGChatViewModel: V2NIMNotificationListener {
    func onReceive(_ customNotifications: [V2NIMCustomNotification]) {
        guard let notification = customNotifications.first, let data = notification.content?.data(using: .utf8) else {
            return
        }
        do {
            let dic = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            guard let dict = dic as? [String: Any], let sender = notification.senderId else {
                return
            }
            self.delegate?.onReceiveCustomNotification(senderId: sender, content: dict)
            
        } catch  {
            
        }
    }
    
    func onReceive(_ boradcastNotifications: [V2NIMBroadcastNotification]) {
        
    }
    
}

// MARK: - AVAudioPlayerDelegate

extension TGChatViewModel: AVAudioPlayerDelegate {
    /// 声音播放完成回调
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlay()
    }
    
    /// 声音解码失败回调
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: (any Error)?) {
        stopPlay()
    }
}

