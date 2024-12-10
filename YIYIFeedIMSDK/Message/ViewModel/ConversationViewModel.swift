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
}

class ConversationViewModel: NSObject {
    
    weak var delegate: ConversationViewModelDelegate?
    var conversationList: [V2NIMConversation] = []
    
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
            if result.conversationList?.count == 0 {
                self?.createConversation(completion: {
                    completion(result.conversationList, nil)
                })
            } else {
                completion(result.conversationList, nil)
            }
        }failure: { error in
            completion(nil, error)
        }
    }
    
    func  createConversation(completion: @escaping () -> Void){
        let cId = "azizistg22|1|zhouztz"
        NIMSDK.shared().v2ConversationService.createConversation(cId) {[weak self] conversation in
            self?.conversationList.append(conversation)
            completion()
        } failure: { error in
            print("\(error.code)")
            completion()
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
    
    //置顶会话
    func pinnedRecentSession(recentSession: NIMRecentSession){
        
    }

}
extension ConversationViewModel: V2NIMConversationListener {
    func onConversationChanged(_ conversations: [V2NIMConversation]) {
        
    }
    func onTotalUnreadCountChanged(_ unreadCount: Int) {
        
    }
}

// MARK: NIMConversationManagerDelegate
extension ConversationViewModel: NIMConversationManagerDelegate{
    func didAdd(_ recentSession: NIMRecentSession, totalUnreadCount: Int) {
        self.delegate?.didAddRecentSession()
    }
    func didUpdate(_ recentSession: NIMRecentSession, totalUnreadCount: Int) {
        self.delegate?.reloadData()
    }
}

// MARK: NIMChatManagerDelegate
extension ConversationViewModel: NIMChatManagerDelegate{
    //收到消息回执
    func onRecvMessageReceipts(_ receipts: [NIMMessageReceipt]) {
        receipts.forEach { receipt in
//            if receipt.session?.sessionType == .P2P {
//                for (i, conver) in self.conversationList.enumerated() {
//                    if conver.session?.sessionType == .P2P,
//                       receipt.session?.sessionId == conver.session?.sessionId {
//                        delegate?.didUpdateRecentSession(index: i)
//                    }
//                }
//                
//            }
        }
    }
}
