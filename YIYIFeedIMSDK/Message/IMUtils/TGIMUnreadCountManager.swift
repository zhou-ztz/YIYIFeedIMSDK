//
//  TGIMUnreadCountManager.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/15.
//

import UIKit
import NIMSDK

class TGIMUnreadCountManager: NSObject {
    static let shared = TGIMUnreadCountManager()
    
    func getConversationAllUnreadCount() -> Int{
        
        return NIMSDK.shared().v2ConversationService.getTotalUnreadCount()
    }
}
