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
    
    func getRequestlistCountAllUnreadCount(completion: @escaping (_ count: Int) ->Void){
        var count: Int = 0
        let group = DispatchGroup()
        
        let option = V2NIMTeamJoinActionInfoQueryOption()
        option.offset = 0
        option.types = [NSNumber(value: V2NIMTeamJoinActionType.TEAM_JOIN_ACTION_TYPE_INVITATION.rawValue), NSNumber(value: V2NIMTeamJoinActionType.TEAM_JOIN_ACTION_TYPE_APPLICATION.rawValue)]
        option.limit = 200
        option.status = [NSNumber(value: V2NIMTeamJoinActionStatus.TEAM_JOIN_ACTION_STATUS_INIT.rawValue)]
        group.enter()
        NIMSDK.shared().v2TeamService.getTeamJoinActionInfoList(option) { actionInfo in
            if let notis = actionInfo.infos {
                var uniqueValues = Set<String>()
                let filterN = notis.filter{ uniqueValues.insert("\($0.teamId)&\($0.operatorAccountId)").inserted }
                count = count + filterN.count
            }
            group.leave()
        } failure: { error in
            group.leave()
        }
        group.enter()
        TGIMNetworkManager.getRequestUnreadCount { model, error in
            if let model = model {
                count = count + model.count
            }
            group.leave()
        }
        group.notify(queue: .main) {
            completion(count)
        }
    }
}
