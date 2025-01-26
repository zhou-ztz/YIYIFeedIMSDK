//
//  TGMessageRequestModel.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/16.
//

import UIKit
import NIMSDK

protocol TGMessageRequestViewmodeldelete: AnyObject {
    func onReceive(_ joinActionInfo: V2NIMTeamJoinActionInfo)
}

class TGMessageRequestViewmodel: NSObject {
    
    var teamOffset: Int = 0
    var teamFinished: Bool = false
    var teamNotifications: [V2NIMTeamJoinActionInfo] = []
    var filterNotifications: [V2NIMTeamJoinActionInfo] = []
    var requestList: [TGMessageRequestModel] = []
    var limit: Int = 200
    var after: Int = 0
    weak var delegate: TGMessageRequestViewmodeldelete?
    
    override init() {
        super.init()
        addObserver()
    }
    
    func addObserver() {
        NIMSDK.shared().v2TeamService.add(self)
    }
    
    deinit {
        NIMSDK.shared().v2TeamService.remove(self)
    }
    
    func getTeamJoinActions(isRefresh: Bool = true, completion: @escaping (_ error: Error?) ->Void) {
        if isRefresh {
            teamOffset = 0
            self.teamNotifications.removeAll()
            self.filterNotifications.removeAll()
        }
        let option = V2NIMTeamJoinActionInfoQueryOption()
        option.offset = teamOffset
        option.types = [NSNumber(value: V2NIMTeamJoinActionType.TEAM_JOIN_ACTION_TYPE_INVITATION.rawValue), NSNumber(value: V2NIMTeamJoinActionType.TEAM_JOIN_ACTION_TYPE_APPLICATION.rawValue)]
        option.limit = 200
        option.status = [NSNumber(value: V2NIMTeamJoinActionStatus.TEAM_JOIN_ACTION_STATUS_INIT.rawValue)]
        NIMSDK.shared().v2TeamService.getTeamJoinActionInfoList(option) { [weak self] actionInfo in
            guard let self = self else { return }
            if let notis = actionInfo.infos {
                
                self.teamOffset = actionInfo.offset
                self.teamFinished = actionInfo.finished
                var uniqueValues = Set<String>()
                let filterN = notis.filter{ uniqueValues.insert("\($0.teamId)&\($0.operatorAccountId)").inserted }
                if isRefresh {
                    self.teamNotifications = notis
                    self.filterNotifications = filterN
                } else {
                    self.teamNotifications = self.teamNotifications + notis
                    self.filterNotifications = self.filterNotifications + filterN
                }
                
            }
            completion(nil)
        } failure: { error in
            completion(error.nserror)
        }
    }
    
    func getRequestList(isRefresh: Bool = true, completion: @escaping (_ requestList: [TGMessageRequestModel]?, _ error: Error?) ->Void) {
        if isRefresh {
            after = 0
            self.requestList.removeAll()
        }
        TGIMNetworkManager.getRequestMessage(limit: limit, after: after) {[weak self] requestList, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(nil, error)
            } else {
                if let requestList = requestList {
                    if isRefresh {
                        self.requestList = requestList
                    } else {
                        self.requestList = self.requestList + requestList
                    }
                    
                }
                completion(requestList, nil)
            }
           
        }

    }
    
    
    func acceptFriendRequest(data: TGMessageRequestModel, completion: @escaping (_ error: Error?) ->Void) {
        TGIMNetworkManager.followFriend(userId: data.user?.userIdentity ?? 0) {error in
            completion(error)
        }

    }
    
    func rejectFriendRequest(data: TGMessageRequestModel, completion: @escaping (_ error: Error?) ->Void) {
        TGIMNetworkManager.deleteMessageRequest(requestId: data.requestID) { error in
            completion(error)
        }
    }
    
    func acceptGroupInvitation(notification: V2NIMTeamJoinActionInfo, completion: @escaping (_ error: Error?) ->Void) {
        
        NIMSDK.shared().v2TeamService.acceptInvitation(notification) { _ in
            completion(nil)
        } failure: { error in
            completion(error.nserror)
        }

    }
    
    func rejectGroupInvitaton(notification: V2NIMTeamJoinActionInfo, completion: @escaping (_ error: Error?) ->Void) {
        
        NIMSDK.shared().v2TeamService.rejectInvitation(notification, postscript: nil) {
            completion(nil)
        } failure: { error in
            completion(error.nserror)
        }

    }
    

}

extension TGMessageRequestViewmodel: V2NIMTeamListener {
   
    func onReceive(_ joinActionInfo: V2NIMTeamJoinActionInfo) {
        if joinActionInfo.actionType == .TEAM_JOIN_ACTION_TYPE_APPLICATION || joinActionInfo.actionType == .TEAM_JOIN_ACTION_TYPE_INVITATION {
            if !self.filterNotifications.contains(where: {$0.teamId == joinActionInfo.teamId &&
                $0.operatorAccountId == joinActionInfo.operatorAccountId }) {
                self.filterNotifications.insert(joinActionInfo, at: 0)
                self.delegate?.onReceive(joinActionInfo)
            }
        }
       
    }
    
}
