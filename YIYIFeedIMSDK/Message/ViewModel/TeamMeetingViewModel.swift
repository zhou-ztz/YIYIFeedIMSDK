//
//  TeamMeetingViewModel.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/29.
//

import UIKit
import NIMSDK
import NERtcSDK
import AVFoundation

protocol TeamMeetingViewModelDelegate: AnyObject {
    func onOnlineEvent(_ event: V2NIMSignallingEvent)
    func onOfflineEvent(_ event: [V2NIMSignallingEvent])
    func onMultiClientEvent(_ event: V2NIMSignallingEvent)
    func onNERtcEngineConnectionStateChange(state: NERtcConnectionStateType, reason: NERtcReasonConnectionChangedType)
    func onNERtcEngineUserDidJoin(withUserID userID: UInt64, userName: String)
    func onNERtcEngineUserVideoDidStart(withUserID userID: UInt64, videoProfile profile: NERtcVideoProfileType)
    func onNERtcEngineUser(_ userID: UInt64, videoMuted muted: Bool, streamType: NERtcStreamChannelType)
    func onNERtcEngineDidDisconnect(withReason reason: NERtcError)
    func onNERtcEngineUserDidLeave(withUserID userID: UInt64, reason: NERtcSessionLeaveReason)
    func onLocalAudioVolumeIndication(_ volume: Int32, withVad enableVad: Bool)
    func onRemoteAudioVolumeIndication(_ speakers: [NERtcAudioVolumeInfo]?, totalVolume: Int32)
}

class TeamMeetingViewModel: NSObject {
    weak var delegate: TeamMeetingViewModelDelegate?
    var team: V2NIMTeam?
    var enableSpeaker: Bool = false
    var role: TeamMeetingRoleType = .TeamMeetingRoleCaller
    //发起者信息
    var callerInfo: IMTeamMeetingCallerInfo?
    //邀请的成员列表
    var invitedMembers: [IMMeetingMember] = []
    //接受的信息
    var calleeInfo: IMTeamMeetingCalleeInfo?
    
    var conversationId: String?

    var channelId: String?
    var channelInfo: V2NIMSignallingRoomInfo?
    var rtcInfo: V2NIMSignallingRtcInfo?
    var isResponse: Bool = false //是否有人已经接受邀请
    
    let rowsInSection = 9
    
    var teamId: String?
    
    override init() {
        super.init()
        initNERtc()
        addObserver()
    }
    deinit {
        removeAllObserver()
    }
    
    func initNERtc(){
        let coreEngine = NERtcEngine.shared()
        let context = NERtcEngineContext()
        context.engineDelegate = self
        context.appKey = RLSDKManager.shared.appKey
        coreEngine.setupEngine(with: context)
        coreEngine.enableAudioVolumeIndication(true, interval: 100, vad: true)
        NERtcEngine.shared().muteLocalAudio(false)
        NERtcEngine.shared().subscribeAllRemoteAudio(true)
        //以开启本地视频主流采集并发送
        NERtcEngine.shared().enableLocalVideo(true, streamType: .mainStream)
    }
    
    func addObserver() {
        NIMSDK.shared().v2SignallingService.add(self)
    }
    
    func removeAllObserver() {
        NIMSDK.shared().v2SignallingService.remove(self)
        DispatchQueue.global().async {
            NERtcEngine.destroy()
        }
    }

    
    //房间成员
    func setupMembers(members: [String], teamId: String)
    {
        self.teamId = teamId
        invitedMembers.removeAll()
        for uid in members {
            let member = IMMeetingMember()
            member.userId = uid
            if uid == NIMSDK.shared().v2LoginService.getLoginUser() {
                if role == .TeamMeetingRoleCaller {
                    member.isJoined = true
                }else {
                    member.isJoined = false
                }
            }
            invitedMembers.append(member)
        }
        //V2NIMError
        NIMSDK.shared().v2TeamService.getTeamInfo(byIds: [teamId], teamType: .TEAM_TYPE_NORMAL, success: {[weak self] teams in
            self?.team = teams.first
        }) { error in
        }
        enableSpeaker = true
    }
    
    func reserveMeetting(requestId: String, calleeAccountId: String, channelName: String, teamId: String, success: @escaping () ->Void, failure: @escaping (Error) ->Void) {
        
        
        let userIds: [String] = invitedMembers.compactMap {$0.userId}
        let data: [String: Any] = ["teamId": teamId, "members": userIds]
        let dict: [String : Any] = ["type": NERtCallingType.team.rawValue, "data": data]
        
        let customInfo = dict.toJSON
        let v2param = V2NIMSignallingCallParams()
        v2param.channelType = .SIGNALLING_CHANNEL_TYPE_VIDEO
        v2param.calleeAccountId = calleeAccountId
        v2param.requestId = requestId
        //v2param.channelName = channelName
        v2param.channelExtension = customInfo ?? ""
        let pushConfig = V2NIMSignallingPushConfig()
        pushConfig.pushEnabled = true
        pushConfig.pushTitle = "".localized
        pushConfig.pushContent = String(format: "calling_you".localized, calleeAccountId)
        v2param.pushConfig = pushConfig
        
        let rtcConfig = V2NIMSignallingRtcConfig()
        rtcConfig.rtcChannelName = channelName
        v2param.rtcConfig = rtcConfig
        NIMSDK.shared().v2SignallingService.call(v2param) {[weak self] callResult in
            guard let self = self else { return }
            self.rtcInfo = callResult.rtcInfo
            self.channelInfo = callResult.roomInfo
            self.channelId = callResult.roomInfo.channelInfo.channelId
            success()
        } failure: { error in
            failure(error.nserror)
        }
 
    }
    
    ///音视频2.0
    func joinChannel(rtcToken: String, channelName: String, success: @escaping () ->Void, failure: @escaping (Error) ->Void) {
        let member = self.channelInfo?.members.first(where: {$0.accountId == NIMSDK.shared().v2LoginService.getLoginUser()})
        if let uid = member?.uid {
            let _ = NERtcEngine.shared().joinChannel(withToken: rtcToken, channelName: channelName, myUid: UInt64(uid)) { error, a, b, c in
                if let error = error {
                    failure(error)
                } else {
                    success()
                }
            }
        }
        
    }
    
    func inviteMember(requestId: String, inviteeAccountId: String, teamId: String, success: @escaping () ->Void, failure: @escaping (Error?) ->Void) {
        guard let channelInfo = self.channelInfo?.channelInfo else {
            failure(nil)
            return
        }
        
        let userIds: [String] = invitedMembers.compactMap {$0.userId}
        let data: [String: Any] = ["teamId": teamId, "members": userIds]
        let dict: [String : Any] = ["type": NERtCallingType.team.rawValue, "data": data]
        
        let customInfo = dict.toJSON
        
        let params = V2NIMSignallingInviteParams()
        params.channelId = channelInfo.channelId
        params.requestId = requestId
        params.inviteeAccountId = inviteeAccountId
        params.serverExtension = customInfo
        let pushConfig = V2NIMSignallingPushConfig()
        pushConfig.pushEnabled = true
        pushConfig.pushTitle = "".localized
        pushConfig.pushContent = String(format: "calling_you".localized, inviteeAccountId)
        params.pushConfig = pushConfig
        NIMSDK.shared().v2SignallingService.invite(params) {
            success()
        } failure: { error in
            failure(error.nserror)
        }

    }
    
    /// 接受邀请
    func response(success: @escaping () ->Void, failure: @escaping (Error?) ->Void) {
        guard let calleeInfo = self.calleeInfo else {
            failure(nil)
            return
        }
        let v2parma = V2NIMSignallingCallSetupParams()
        v2parma.channelId = calleeInfo.channelId
        v2parma.callerAccountId = calleeInfo.caller
        v2parma.requestId = calleeInfo.requestId

        NIMSDK.shared().v2SignallingService.callSetup(v2parma) {[weak self] callSetupResult in
            self?.channelInfo = callSetupResult.roomInfo
            self?.rtcInfo = callSetupResult.rtcInfo
            self?.channelId = callSetupResult.roomInfo.channelInfo.channelId
            success()
        } failure: { error in
            failure(error.nserror)
        }
        
        
    }
    
    //拒绝邀请
    func refuseAnswer(success: @escaping () ->Void, failure: @escaping (Error?) ->Void){
        guard let calleeInfo = self.calleeInfo else {
            failure(nil)
            return
        }
        let v2parma = V2NIMSignallingRejectInviteParams()
        v2parma.channelId = calleeInfo.channelId
        v2parma.inviterAccountId = calleeInfo.caller
        v2parma.requestId = calleeInfo.requestId
        NIMSDK.shared().v2SignallingService.rejectInvite(v2parma) {
            success()
        } failure: { error in
            failure(error.nserror)
        }
        
    }
    
    ///关闭信令频道
    func closeChannel(success: @escaping () ->Void, failure: @escaping (Error?) ->Void){
        guard let channelId = channelInfo?.channelInfo.channelId else {
            failure(nil)
            return
        }
        NIMSDK.shared().v2SignallingService.closeRoom(channelId, offlineEnabled: true, serverExtension: nil) {
            success()
        } failure: { error in
            failure(error.nserror)
        }
        
    }
    
    /// 取消邀请
    func cancelInvite(channelId: String, inviteeAccountId: String, requestId: String, success: @escaping () ->Void, failure: @escaping (Error?) ->Void) {
        
        let v2parma = V2NIMSignallingCancelInviteParams()
        v2parma.channelId = channelId
        v2parma.inviteeAccountId = inviteeAccountId
        v2parma.requestId = requestId
        NIMSDK.shared().v2SignallingService.cancelInvite(v2parma) {
            success()
        } failure: { error in
            failure(error.nserror)
        }
        
    }
    /// 离开信令频道
    func signalingLeave(channelId: String, success: @escaping () ->Void, failure: @escaping (Error?) ->Void) {
        
        NIMSDK.shared().v2SignallingService.leaveRoom(channelId, offlineEnabled: true, serverExtension: nil) {
            success()
        } failure: { error in
            failure(error.nserror)
        }

    }
    
    func getChannelName(caller: String, callee: String = "")-> String{
        let now = Date()
        let timeInterval: TimeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        let name = (caller + callee + String(timeStamp))
        return name.md5
    }

    
    
    func findMemberWithIndexPath(indexPath: IndexPath) -> IMMeetingMember?
    {
        let index = indexPath.section * self.rowsInSection + indexPath.row
        if self.invitedMembers.count > index {
            return self.invitedMembers[index]
        }
        return nil
    }
    
    func findMemberWithUserId(_ userId: String) -> IMMeetingMember?
    {
        if let index = self.invitedMembers.firstIndex(where: {$0.userId == userId}){
            return self.invitedMembers[index]
        }
        return nil
    }
    func findIndexPathWithMember(member: IMMeetingMember) -> IndexPath?{
        if let index = self.invitedMembers.firstIndex(of: member) {
            return IndexPath(row: index, section: 0)
        }
        return nil
    }
    //发送提示消息
    func sendTipMessage(nickName: String) {
        let currentId = NIMSDK.shared().v2LoginService.getLoginUser() ?? ""
        let teamId = self.teamId ?? ""
        let conversationId = self.conversationId != nil ? self.conversationId : "\(currentId)|2|\(teamId)"
        let text = String(format: "opponent_request_video".localized, nickName)
        let message = MessageUtils.tipV2Message(text: text)
        NIMSDK.shared().v2MessageService.send(message, conversationId: conversationId ?? "", params: nil) { _ in
            
        } failure: { _ in
            
        }

    }
   
}

extension TeamMeetingViewModel: NERtcEngineDelegateEx {
    func onNERtcEngineConnectionStateChange(with state: NERtcConnectionStateType, reason: NERtcReasonConnectionChangedType) {
        
    }
    
    func onNERtcEngineUserDidJoin(withUserID userID: UInt64, userName: String) {
        self.delegate?.onNERtcEngineUserDidJoin(withUserID: userID, userName: userName)
    }
    
    func onNERtcEngineUserSubStreamAudioDidStart(_ userID: UInt64) {
        
    }
    
    func onNERtcEngineUserVideoDidStart(withUserID userID: UInt64, videoProfile profile: NERtcVideoProfileType) {
        self.delegate?.onNERtcEngineUserVideoDidStart(withUserID: userID, videoProfile: profile)
    }
    
    func onNERtcEngineUserVideoDidStop(_ userID: UInt64) {

    }
    
   
    func onNERtcEngineUser(_ userID: UInt64, videoMuted muted: Bool, streamType: NERtcStreamChannelType) {
        self.delegate?.onNERtcEngineUser(userID, videoMuted: muted, streamType: streamType)
    }
    
    func onNERtcEngineUser(_ userID: UInt64, videoMuted muted: Bool) {
        
    }
    //本地异常离开
    func onNERtcEngineDidDisconnect(withReason reason: NERtcError) {
        print("reason = \(reason)")
        self.delegate?.onNERtcEngineDidDisconnect(withReason: reason)
    }
    //本端离开
    func onNERtcEngineDidLeaveChannel(withResult result: NERtcError) {
        
    }
    //远端离开
    func onNERtcEngineUserDidLeave(withUserID userID: UInt64, reason: NERtcSessionLeaveReason) {
        self.delegate?.onNERtcEngineUserDidLeave(withUserID: userID, reason: reason)
    }
    
    func onNERtcEngineRejoinChannel(_ result: NERtcError) {
        
    }
    //音量
    func onLocalAudioVolumeIndication(_ volume: Int32, withVad enableVad: Bool) {
        self.delegate?.onLocalAudioVolumeIndication(volume, withVad: enableVad)
        
    }
    //远端音量
    func onRemoteAudioVolumeIndication(_ speakers: [NERtcAudioVolumeInfo]?, totalVolume: Int32) {
        self.delegate?.onRemoteAudioVolumeIndication(speakers, totalVolume: totalVolume)
    }
}

extension TeamMeetingViewModel: V2NIMSignallingListener {
    func onOnlineEvent(_ event: V2NIMSignallingEvent) {
        self.delegate?.onOnlineEvent(event)
    }
    
    func onOfflineEvent(_ event: [V2NIMSignallingEvent]) {
        self.delegate?.onOfflineEvent(event)
    }
    
    func onMultiClientEvent(_ event: V2NIMSignallingEvent) {
        self.delegate?.onMultiClientEvent(event)
    }
}
