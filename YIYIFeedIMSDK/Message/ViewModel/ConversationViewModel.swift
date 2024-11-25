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
    var conversationList: [NIMRecentSession] = []
    
    override init() {
        super.init()
        NIMSDK.shared().conversationManager.add(self)
        NIMSDK.shared().chatManager.add(self)
    }
    
    deinit {
        NIMSDK.shared().conversationManager.remove(self)
        NIMSDK.shared().chatManager.remove(self)
    }
    
    func getConversationList(_ completion: @escaping (Bool) -> Void) {
        if let recentSessions = NIMSDK.shared().conversationManager.allRecentSessions(){
            conversationList = recentSessions
            completion(true)
        }else{
            completion(false)
        }
        
    }
    
    func deleteRecentSession(recentSession: NIMRecentSession) {
        
        weak var weakSelf = self
        let option = NIMDeleteRecentSessionOption()
        option.isDeleteRoamMessage = true
        option.shouldMarkAllMessagesReadInSessions = true
        NIMSDK.shared().conversationManager.delete(recentSession, option: option) { error in
            if let error = error {
                print("\(error.localizedDescription)")
            }else{
               if let index = weakSelf?.conversationList.firstIndex(where: { session in
                    session == recentSession
               }){
                   weakSelf?.conversationList.remove(at: index)
                   weakSelf?.delegate?.didRemoveRecentSession(index: index)
               }
            
            }
        }

    }
    
    //置顶会话
    func pinnedRecentSession(recentSession: NIMRecentSession){
        
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
            if receipt.session?.sessionType == .P2P {
                for (i, conver) in self.conversationList.enumerated() {
                    if conver.session?.sessionType == .P2P,
                       receipt.session?.sessionId == conver.session?.sessionId {
                        delegate?.didUpdateRecentSession(index: i)
                    }
                }
                
            }
        }
    }
}
