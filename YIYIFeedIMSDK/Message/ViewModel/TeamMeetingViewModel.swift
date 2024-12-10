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

class TeamMeetingViewModel: NSObject {
    
    var team: V2NIMTeam?
    var enableSpeaker: Bool = false
    var role: TeamMeetingRoleType = .TeamMeetingRoleCaller
    //发起者信息
    var callerInfo: IMTeamMeetingCallerInfo?
    //邀请的成员列表
    var invitedMembers: [IMMeetingMember] = []
    //接受的信息
    var calleeInfo: IMTeamMeetingCalleeInfo?

    //邀请成员的requestId列表
    var requestIdList: [String] = []
    var meetingSeconds: Int = 0
    var channelId: String?
    var channelInfo: NIMSignalingChannelDetailedInfo?
    var isResponse: Bool = false //是否有人已经接受邀请
    
    override init() {
        super.init()
        initNERtc()
        addObserver()
    }
    
    func initNERtc(){
        let coreEngine = NERtcEngine.shared()
        let context = NERtcEngineContext()
        context.engineDelegate = self
        context.appKey = NIMAppKey
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
    
    func getChannelName(caller: String, callee: String = "")-> String{
        let now = Date()
        let timeInterval: TimeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        let name = (caller + callee + String(timeStamp))
        return name.md5
    }
    
   
}

extension TeamMeetingViewModel: NERtcEngineDelegateEx {
    
}

extension TeamMeetingViewModel: V2NIMSignallingListener {
    
}
