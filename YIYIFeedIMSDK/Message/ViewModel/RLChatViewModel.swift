//
//  RLChatViewModel.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/25.
//

import UIKit
import NIMSDK
import AVFoundation
import Photos

//回复消息 key
let keyReplyMsgKey = "yxReplyMsg"

protocol ChatViewModelDelegate: NSObjectProtocol {
    func onRecvMessages(_ messages: [NIMMessage])
    func willSend(_ message: NIMMessage)
    func send(_ message: NIMMessage, didCompleteWithError error: Error?)
    func send(_ message: NIMMessage, progress: Float)
    func didReadedMessageIndexs()
    func onDeleteMessage(_ message: NIMMessage, atIndexs: [IndexPath], reloadIndex: [IndexPath])
    func onRevokeMessage(_ message: NIMMessage, atIndexs: [IndexPath])
//    func onAddMessagePin(_ message: NIMMessage, atIndexs: [IndexPath])
//    func onRemoveMessagePin(_ message: NIMMessage, atIndexs: [IndexPath])
//    func updateDownloadProgress(_ message: NIMMessage, atIndex: IndexPath, progress: Float)
//    func remoteUserEditing()
//    func remoteUserEndEditing()
//    func didLeaveTeam()
//    func didDismissTeam()
//    func didRefreshTable()
    
    //@objc optional
    //func getMessageModel(model: MessageModel)
}

class RLChatViewModel: NSObject {

    weak var delegate: ChatViewModelDelegate?
    var team: NIMTeam?
    var session: NIMSession
    var messages = [RLMessageData]()
    //未读数
    var unreadCount: Int = 0
    // 下拉时间戳
    private var oldMsg: NIMMessage?
    // 上拉时间戳
    private var newMsg: NIMMessage?
    
    var messageLimit: Int = 50
    
    //长按cell model
    var operationModel: RLMessageData?
    //是否正在回复
    var isReplying: Bool = false
    
    public var deletingMsgDic = Set<String>()
    
    init(session: NIMSession, unreadCount: Int = 0) {
        self.session = session
        self.unreadCount =  unreadCount
        super.init()
        addObserver()
    }
    
    func addObserver() {
        NIMSDK.shared().chatManager.add(self)
    }
    
    //本地消息
    func getLocalMessages(_ completion: @escaping (NSInteger, [RLMessageData]?) -> Void) {
        
        if let nimMessages = NIMSDK.shared().conversationManager.messages(in: self.session, message: nil, limit: messageLimit + unreadCount), nimMessages.count > 0 {
            oldMsg = nimMessages.first
            readAllMessages(messages: nimMessages)
            let datas = nimMessages.compactMap { RLMessageData($0) }
            messages = processTimeData(datas)
            completion(messages.count, messages)
        }else{
            completion(0, nil)
        }
        
    }
    
    func loadMoreMessage(_ completion: @escaping (NSInteger, [RLMessageData]?, IndexPath?) -> Void){
        if let nimMessages = NIMSDK.shared().conversationManager.messages(in: self.session, message: oldMsg, limit: messageLimit), nimMessages.count > 0 {
            oldMsg = nimMessages.first
            
            let datas = nimMessages.compactMap { RLMessageData($0) }
            let newDatas = self.processTimeData(datas)
            messages.insert(contentsOf: newDatas, at: 0)
            var indexPath: IndexPath?
            if let msg = newDatas.last {
                indexPath = self.getIndexPath(for: msg)
            }
            completion(newDatas.count, newDatas, indexPath)
        }else
        {
            completion(0, nil, nil)
        }
        
    }
    
    //读所有消息
    func readAllMessages(messages: [NIMMessage]) {
        if (self.session.sessionType != .P2P) {
            for item in messages {
                if !item.isOutgoingMsg {
                    let setting = NIMMessageSetting()
                    setting.teamReceiptEnabled = true
                    item.setting = setting
                    let returnReceipt = NIMMessageReceipt(message: item)
                    NIMSDK.shared().chatManager.sendTeamMessageReceipts([returnReceipt])
                }
            }
        } else {
            let reversedMessages = messages.reversed()
            DispatchQueue.global().async {
                let semahore = DispatchSemaphore(value: 0)
                for item in reversedMessages {
                    if !item.isOutgoingMsg {
                        let returnReceipt = NIMMessageReceipt(message: item)
                        NIMSDK.shared().chatManager.send(returnReceipt, completion: { error in
                            semahore.signal()
                        })
                        semahore.wait()
                    }
                }
            }
        }
        
        NIMSDK.shared().conversationManager.markAllMessagesRead(in: self.session)
    }
    
    //追加时间
    func processTimeData(_ datas: [RLMessageData]) -> [RLMessageData] {
    
        let lastTimeMessage = self.messages.filter { $0.type == .time }.last
        var compareTime: TimeInterval =  lastTimeMessage?.messageTime ?? 0.0
        var newDatas: [RLMessageData] = []
        
        datas.forEach { item in
//            if item.shouldInsertTimestamp(compare: compareTime) && item.disableBeInviteAuthTipsMessage() {
//                let timeData = RLMessageData(messageTime: item.messageTime, type: .time)
//                newDatas.append(timeData)
//            }
            if let message = item.nimMessageModel,  let timeData = self.addTimeMessage(message, lastTs: compareTime){
                compareTime = item.messageTime
                newDatas.append(timeData)
            }
            newDatas.append(item)
        }
        return newDatas
    }

    
    func getIndexPath(for message: RLMessageData) -> IndexPath? {
        let index = self.messages.firstIndex { data in
            data.nimMessageModel?.messageId == message.nimMessageModel?.messageId
        }
        if let index = index {
            return IndexPath(row: index, section: 0)
        }
        return nil
    }
    
    
    // MARK: 发送消息操作
    func sendTextMessage(text: String, remoteExt: [String: Any]?,  _ completion: @escaping (Error?) -> Void) {
        if text.count <= 0 {
            return
        }
        NIMSDK.shared().chatManager.send(MessageUtils.textMessage(text: text, remoteExt: remoteExt), to: session) { error in
            completion(error)
        }
    }
    
    func sendAudioMessage(filePath: String, _ completion: @escaping (Error?) -> Void) {
        NIMSDK.shared().chatManager.send(MessageUtils.audioMessage(filePath: filePath), to: session) { error in
            completion(error)
        }
    }

    func sendImageMessage(image: UIImage, _ completion: @escaping (Error?) -> Void) {
        NIMSDK.shared().chatManager.send(MessageUtils.imageMessage(image: image), to: session) { error in
            completion(error)
        }
    }

    func sendVideoMessage(url: URL, _ completion: @escaping (Error?) -> Void) {
        weak var weakSelf = self
        convertVideoToMP4(inputURL: url) { path, error in
            if let path = path , let session = weakSelf?.session {
                NIMSDK.shared().chatManager.send(MessageUtils.videoMessage(filePath: path), to: session) { error in
                    completion(error)
                }
                
            
            }
        }
    }

    func sendLocationMessage(_ model: ChatLocaitonModel, _ completion: @escaping (Error?) -> Void) {
        let message = MessageUtils.locationMessage(model.lat, model.lng, model.title, model.address)
        NIMSDK.shared().chatManager.send(message, to: session){ error in
            completion(error)
        }
    }

    func sendFileMessage(filePath: String, displayName: String?, _ completion: @escaping (Error?) -> Void) {
        NIMSDK.shared().chatManager.send(MessageUtils.fileMessage(filePath: filePath, displayName: displayName), to: session) { error in
            completion(error)
        }
    }

    func sendFileMessage(data: Data, displayName: String?, _ completion: @escaping (Error?) -> Void) {
        NIMSDK.shared().chatManager.send(MessageUtils.fileMessage(data: data, displayName: displayName), to: session) { error in
            completion(error)
        }
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
    
    func addTimeMessage(_ message: NIMMessage, lastTs: TimeInterval) ->RLMessageData?  {
//        let lastTs = messages.last?.nimMessageModel?.timestamp ?? 0.0
        let curTs = message.timestamp
        let dur = curTs - lastTs
        if (dur / 60) > 5 {
            let timeData = RLMessageData(messageTime: message.timestamp, type: .time)
            messages.append(timeData)
            return timeData
        }
        return nil
    }
    
    //MARK: 文件下载
    func downLoadFile(object: NIMFileObject)
    {
        if let msg = object.message {
            do {
                try NIMSDK.shared().chatManager.fetchMessageAttachment(msg)
            } catch {
                print("error = \(error.localizedDescription)")
            }
        }
    }
    //下载资源文件
    public func downLoad(_ urlString: String, _ filePath: String, _ progress: NIMHttpProgressBlock?,
                         _ completion: NIMDownloadCompleteBlock?) {
        NIMSDK.shared().resourceManager.download(urlString, filepath: filePath, progress: progress, completion: completion)
    }
    //获取图片urls
    public func getUrls() -> [String] {
        var urls = [String]()
        messages.forEach { model in
            if model.messageType == .image, let message = model.nimMessageModel?.messageObject as? NIMImageObject {
                if let url = message.url {
                    urls.append(url)
                } else {
                    if let path = message.path, FileManager.default.fileExists(atPath: path) {
                        urls.append(path)
                    }
                }
            }
        }
        print("urls:\(urls)")
        return urls
    }
    
    //  获取展示的用户名字，p2p： 备注 > 昵称 > ID  team: 备注 > 群昵称 > 昵称 > ID
    func getShowName(userId: String, teamId: String?, _ showAlias: Bool = true) -> String {
        
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
    //获取 OperationItem
    func avalibleOperationsForMessage(_ model: RLMessageData?) -> [OperationItem]? {
     
        var items = [OperationItem]()
        
        if model?.nimMessageModel?.deliveryState == .failed || model?.nimMessageModel?.deliveryState == .delivering, model?.nimMessageModel?.messageType != .rtcCallRecord {
            switch model?.nimMessageModel?.messageType {
            case .text:
                items.append(contentsOf: [
                    OperationItem.copyItem(),
                    OperationItem.deleteItem(),
                ])
                return items
            case .audio, .video, .image, .location, .file:
                items.append(contentsOf: [
                    OperationItem.deleteItem(),
                ])
                return items
            default:
                break
            }
            
            return nil
        }
        switch model?.nimMessageModel?.messageType {
        case .location:
            items.append(contentsOf: [
                OperationItem.replayItem(),
                OperationItem.forwardItem(),
                OperationItem.deleteItem(),
            ])
        case .text:
            items = [
                OperationItem.copyItem(),
                OperationItem.replayItem(),
                OperationItem.forwardItem(),
                OperationItem.deleteItem(),
            ]
            
        case .image, .video, .file:
            items = [
                OperationItem.replayItem(),
                OperationItem.forwardItem(),
                OperationItem.deleteItem(),
            ]
        case .audio:
            items = [
                OperationItem.replayItem(),
                OperationItem.deleteItem(),
            ]
        case .rtcCallRecord:
            items = [OperationItem.deleteItem()]
            
        default:
            items = [
                OperationItem.replayItem(),
                OperationItem.deleteItem(),
            ]
        }
        
        if model?.nimMessageModel?.from == NIMSDK.shared().loginManager.currentAccount(), model?.nimMessageModel?.messageType != .rtcCallRecord {
            items.append(OperationItem.recallItem())
        }
        return items
    }
    // MARK: operation
    public func replyMessage(_ message: NIMMessage, _ target: NIMMessage,
                             _ completion: @escaping (Error?) -> Void) {
    }
    
    public func replyMessageWithoutThread(message: NIMMessage,
                                          target: NIMMessage,
                                          _ completion: @escaping (Error?) -> Void) {
        NIMSDK.shared().chatExtendManager.reply(message, to: target) { error in
            completion(error)
        }
    }
    public func getReplyMessageWithoutThread(message: NIMMessage) -> RLMessageData? {
     
        var replyId: String? = message.repliedMessageId
        if let yxReplyMsg = message.remoteExt?[keyReplyMsgKey] as? [String: Any] {
            replyId = yxReplyMsg["idClient"] as? String
        }
        
        guard let id = replyId, !id.isEmpty else {
            return nil
        }
        
        if let m = MessageUtils.messagesInSession(session: session, messageId: [id])?
            .first {
            let model = RLMessageData(m)
            model.isReplay = true
            return model
        }
        let message = NIMMessage()
        let model = RLMessageData(message)
        model.isReplay = true
        return model
    }
    
    public func deleteMessage(message: NIMMessage, _ completion: @escaping (Error?) -> Void) {
        if deletingMsgDic.contains(message.messageId) {
            return
        }
        deletingMsgDic.insert(message.messageId)
        if message.serverID.count <= 0 {
            NIMSDK.shared().conversationManager.delete(message)
            deleteMessageUpdateUI(message)
            deletingMsgDic.remove(message.messageId)
            completion(nil)
            return
        }
        weak var weakSelf = self
        NIMSDK.shared().conversationManager.deleteMessage(fromServer: message, ext: nil) { error in
            if error == nil {
                weakSelf?.deleteMessageUpdateUI(message)
            } else {
                completion(error)
            }
            weakSelf?.deletingMsgDic.remove(message.messageId)
        }
    }
    
    func deleteMessageUpdateUI(_ message: NIMMessage) {
        var index = -1
        var replyIndex = [Int]()
        var hasFind = false
        for (i, model) in messages.enumerated() {
            if hasFind {
                var replyId: String? = model.nimMessageModel?.repliedMessageId
                if let yxReplyMsg = model.nimMessageModel?.remoteExt?[keyReplyMsgKey] as? [String: Any] {
                    replyId = yxReplyMsg["idClient"] as? String
                }
                
                if let id = replyId, !id.isEmpty, id == message.messageId {
                    messages[i].replyText = "未找到该消息"
                    replyIndex.append(i)
                }
            } else {
                if model.nimMessageModel?.messageId == message.messageId {
                    index = i
                    hasFind = true
                }
            }
        }
        
        var indexs = [IndexPath]()
        var reloadIndexs = [IndexPath]()
        if index >= 0 {
            //            remove time tip
            let last = index - 1
            let timeModel = messages[last]
            if last >= 0,
               timeModel.type == .time {
                messages.removeSubrange(last ... index)
                indexs.append(IndexPath(row: last, section: 0))
                indexs.append(IndexPath(row: index, section: 0))
                for replyIdx in replyIndex {
                    reloadIndexs.append(IndexPath(row: replyIdx - 2, section: 0))
                }
            } else {
                messages.remove(at: index)
                indexs.append(IndexPath(row: index, section: 0))
                for replyIdx in replyIndex {
                    reloadIndexs.append(IndexPath(row: replyIdx - 1, section: 0))
                }
            }
        }
        
        delegate?.onDeleteMessage(message, atIndexs: indexs, reloadIndex: reloadIndexs)
    }
    //转发其他用户
    public func forwardUserMessage(_ message: NIMMessage, _ users: [String]) {
        users.forEach { userId in
            let session = NIMSession(userId, type: .P2P)
            var error: NSError?
            let nMsg = NIMSDK.shared().chatManager.makeForwardMessage(from: message, error: &error)
            do {
                try NIMSDK.shared().chatManager.sendForwardMessage(nMsg, to: session)
            } catch let sendError as NSError {
                // 发送转发消息时发生错误
                print("Error sending forward message: \(sendError.localizedDescription)")
            }
        }
    }
    //撤回
    public func revokeMessage(message: NIMMessage, _ completion: @escaping (Error?) -> Void) {
        NIMSDK.shared().chatManager.revokeMessage(message) { error in
            completion(error)
            if error == nil {
                self.revokeMessageUpdateUI(message)
            }
        }
    }
    
    func revokeMessageUpdateUI(_ message: NIMMessage) {
        var index = -1
        for (i, model) in messages.enumerated() {
            if model.nimMessageModel?.serverID == message.serverID {
                index = i
                continue
            }
        }
        var indexs = [IndexPath]()
        if index >= 0 {
            indexs.append(IndexPath(row: index, section: 0))
            messages.remove(at: index)
            delegate?.onRevokeMessage(message, atIndexs: indexs)
            
        }

        
    }
    
    public func saveRevokeMessage(_ message: NIMMessage, _ completion: @escaping (Error?) -> Void) {
    
        let messageNew = NIMMessage()
        messageNew.text = "撤回一条消息"
        let tipObject = NIMTipObject()
        messageNew.messageObject = tipObject
        let setting = NIMMessageSetting()
        setting.shouldBeCounted = false
        setting.isSessionUpdate = false
        messageNew.setting = setting
        
        NIMSDK.shared().chatManager.send(messageNew, to: session) { error in
            completion(error)
        }
    }
}
//    MARK: NIMChatManagerDelegate
extension RLChatViewModel: NIMChatManagerDelegate {
    func onRecvMessages(_ messages: [NIMMessage]) {
        var count = 0
        for msg in messages {
            if msg.session?.sessionId == session.sessionId {
                if msg.serverID.count <= 0, msg.messageType != .custom {
                  continue
                }
                if msg.isDeleted == true {
                  continue
                }
                count += 1
                // 自定义消息处理
                newMsg = msg
                let _ = addTimeMessage(msg, lastTs: self.messages.last?.nimMessageModel?.timestamp ?? 0.0)
                let model = RLMessageData(msg)
                self.messages.append(model)
                
            }
        }
        if count > 0 { delegate?.onRecvMessages(messages) }
    }
    
    func willSend(_ message: NIMMessage) {
        if message.session?.sessionId != session.sessionId {
            return
        }
        // 自定义消息发送之前的处理
        if newMsg == nil {
            newMsg = message
        }
        
        var isResend = false
        for (i, msg) in messages.enumerated() {
            if message.messageId == msg.nimMessageModel?.messageId {
                messages[i].nimMessageModel = message
                isResend = true
                break
            }
        }
        
        if !isResend {
            let _ = addTimeMessage(message, lastTs: self.messages.last?.nimMessageModel?.timestamp ?? 0.0)
            let model = RLMessageData(message)
            //filterRevokeMessage([model])
            messages.append(model)
        }
        
        delegate?.willSend(message)
    }
    
    func send(_ message: NIMMessage, progress: Float) {
        
        delegate?.send(message, progress: progress)
    }
    
    func send(_ message: NIMMessage, didCompleteWithError error: Error?) {
        
        for (i, msg) in messages.enumerated() {
            if message.messageId == msg.nimMessageModel?.messageId {
                messages[i].nimMessageModel = message
                break
            }
        }
        delegate?.send(message, didCompleteWithError: error)
    }
    
    func onRecvRevokeMessageNotification(_ notification: NIMRevokeMessageNotification) {
        guard let msg = notification.message else {
          return
        }

        revokeMessageUpdateUI(msg)
    }
    ///已读回执
    func onRecvMessageReceipts(_ receipts: [NIMMessageReceipt]) {
        
        delegate?.didReadedMessageIndexs()
    }

}
