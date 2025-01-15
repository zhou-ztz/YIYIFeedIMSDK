//
//  ConversationViewModel.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/11.
//

import UIKit
import NIMSDK

let revokeLocalMessage = "revoke_message_local"
let revokeLocalMessageContent = "revoke_message_local_content"

@objc
public protocol ConversationViewModelDelegate: NSObjectProtocol {
    func didAddRecentSession()
    func didUpdateRecentSession(index: Int)
    func reloadData()
    func didRemoveRecentSession(index: Int)
    
    /// conversation
    func onConversationChanged()
    func onTotalUnreadCountChanged(_ unreadCount: Int)
    func onUnreadCountChanged(unreadCount: Int)
}

class ConversationViewModel: NSObject {
    
    weak var delegate: ConversationViewModelDelegate?
    var conversationList: [V2NIMConversation] = []
    var notificationList: [[String : Any]] = []
    
    var offset: Int64 = 0
    var limit: Int = 100
    var finished: Bool = false
    override init() {
        super.init()
        NIMSDK.shared().v2ConversationService.add(self)
    }
    
    deinit {
        NIMSDK.shared().v2ConversationService.remove(self)
    }
    
    func getConversationList(isRefresh: Bool = true , _ completion: @escaping ([V2NIMConversation]?, V2NIMError?) -> Void) {
        if isRefresh {
            offset = 0
        }
        NIMSDK.shared().v2ConversationService.getConversationList(offset, limit: limit) {[weak self] result in
            self?.offset = result.offset
            self?.finished = result.finished
            if isRefresh {
                self?.conversationList = result.conversationList ?? []
            } else {
                self?.conversationList = (self?.conversationList ?? []) + (result.conversationList ?? [])
            }
            completion(result.conversationList, nil)
        }failure: { error in
            completion(nil, error)
        }
    }
    
    
    func deleteRecentSession(recentSession: V2NIMConversation) {
        weak var weakSelf = self
        NIMSDK.shared().v2ConversationService.deleteConversation(recentSession.conversationId, clearMessage: true) {
            if let index = weakSelf?.conversationList.firstIndex(where: { session in
                session == recentSession
            }){
                weakSelf?.conversationList.remove(at: index)
                weakSelf?.delegate?.didRemoveRecentSession(index: index)
            }
        } failure: { error in
            
        }

    }
    
    func resizeActionRow(image: UIImage, label: UILabel) -> UIImage? {
        let tempView = UIStackView(frame: CGRect(x: 0, y: 0, width: 80, height: 50))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.height))
        tempView.axis = .vertical
        tempView.alignment = .center
        tempView.spacing = 8
        imageView.image = image
        tempView.addArrangedSubview(imageView)
        tempView.addArrangedSubview(label)
        let renderer = UIGraphicsImageRenderer(bounds: tempView.bounds)
        let image = renderer.image { rendererContext in
            tempView.layer.render(in: rendererContext.cgContext)
        }
        return image
    }
    
    /// 添加或者更新会话
    /// - Parameter conversation 会话对象
    func addOrUpdateConversationData(_ conversation: V2NIMConversation) {
        ///被置顶的
        var stickTopConversations: [V2NIMConversation] = []
        var normalConversations: [V2NIMConversation] = []
        self.conversationList.forEach { item in
            if item.stickTop {
                stickTopConversations.append(item)
            } else {
                normalConversations.append(item)
            }
        }
        if let index = stickTopConversations.firstIndex(where: { item in
            item.conversationId == conversation.conversationId
        }) {
            
            let item = stickTopConversations[index]
            if conversation.stickTop {
                /// 是否有新消息
                if item.lastMessage?.messageRefer.messageClientId != conversation.lastMessage?.messageRefer.messageClientId {
                      stickTopConversations.remove(at: index)
                      stickTopConversations.insert(conversation, at: 0)
                } else {
                    stickTopConversations[index] = conversation
                }
               
            } else {
                stickTopConversations.remove(at: index)
                normalConversations.insert(conversation, at: 0)
            }
        }
        
        if let index = normalConversations.firstIndex(where: { item in
            item.conversationId == conversation.conversationId
        }) {
            let item = normalConversations[index]
            if conversation.stickTop {
                normalConversations.remove(at: index)
                stickTopConversations.insert(conversation, at: 0)
            } else {
                /// 是否有新消息
                if item.lastMessage?.messageRefer.messageClientId != conversation.lastMessage?.messageRefer.messageClientId {
                    normalConversations.remove(at: index)
                    normalConversations.insert(conversation, at: 0)
                } else {
                    normalConversations[index] = conversation
                }
                
            }
        }
        
        
        if let _ = self.conversationList.firstIndex(where: { item in
            item.conversationId == conversation.conversationId
        }) {

        } else {
            if conversation.stickTop {
                stickTopConversations.insert(conversation, at: 0)
            } else {
                normalConversations.insert(conversation, at: 0)
            }
        }
        
        self.conversationList = stickTopConversations + normalConversations
      
    }

}
extension ConversationViewModel: V2NIMConversationListener {
    func onConversationChanged(_ conversations: [V2NIMConversation]) {
        conversations.forEach { conversation in
            self.addOrUpdateConversationData(conversation)
        }
        self.delegate?.onConversationChanged()
    }
    func onTotalUnreadCountChanged(_ unreadCount: Int) {
        self.delegate?.onTotalUnreadCountChanged(unreadCount)
        NotificationCenter.default.post(name: NSNotification.Name("updateConversationUnreadCount"), object: nil)
    }
    
    func onUnreadCountChanged(by filter: V2NIMConversationFilter, unreadCount: Int) {
        self.delegate?.onUnreadCountChanged(unreadCount: unreadCount)
        NotificationCenter.default.post(name: NSNotification.Name("updateConversationUnreadCount"), object: nil)
    }
    
    func onConversationReadTimeUpdated(_ conversationId: String, readTime: TimeInterval) {
        
    }
    
    func onSyncStarted() {
        
    }
    
    func onSyncFinished() {
        
    }
}

