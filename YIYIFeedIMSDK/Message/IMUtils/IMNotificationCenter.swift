//
//  IMNotificationCenter.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/2.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
import AVFAudio

let VoiceOrVideoMuteNotificationKey = "yippi.app.MuteVoiceAndVideo"

//音视频通话呼叫类型
enum NERtCallingType: String {
    case team = "teamCall"
    case p2p  = "p2pCall"
}
//1v1音视频通话 切换类型
enum NERtChangeType: String {
    case toAudio       = "toAudio" //视频切换音频
    case toVideo       = "toVideo" //音频切换视频请求
    case agreeToVideo  = "agreeToVideo" //同意
    case rejectToVideo = "rejectToVideo" // 拒绝
}

class IMNotificationCenter: NSObject {
    
    static let sharedCenter = IMNotificationCenter()
    
    let NTESCustomNotificationCountChanged = "NTESCustomNotificationCountChanged"
    let NTESSecretChatResponded = "NTESSecretChatResponded"
    let NTESWhiteboardResponded = "NTESWhiteboardResponded"
    
    
    var player: AVAudioPlayer! //播放提示音
   // var notifier: NTESAVNotifier!
    
    public func start(){
        
    }
    
    public func dismissOrExitGroup(teamId: String){
        
    }
    
    override init() {
        super.init()
        NIMSDK.shared().v2SignallingService.add(self)
    }
    
    deinit {
        NIMSDK.shared().v2SignallingService.remove(self)
    }
    
    
    func shouldResponseBusy() -> Bool{
        guard let topController = TGViewController.topMostController  else { return true }
        return topController.isKind(of: RLAudioVideoCallViewController.self)
        || topController.isKind(of: RLAudioCallController.self)
    }
    
    func shouldAutoRejectCall() -> Bool {
        var should = false
        let apnsManager = NIMSDK.shared().apnsManager
        guard let setting = apnsManager.currentSetting() else { return false }
        //免打扰关闭
        if !setting.noDisturbing {
            let defaults = UserDefaults.standard
            if !defaults.dictionaryRepresentation().keys.contains(where: {$0 == VoiceOrVideoMuteNotificationKey}) {
                defaults.set(true, forKey: VoiceOrVideoMuteNotificationKey)
            }
        }else {
            UserDefaults.standard.set(false, forKey: VoiceOrVideoMuteNotificationKey)
        }
        
        //音视频通话
        let voiceCallNotification = UserDefaults.standard.bool(forKey: VoiceOrVideoMuteNotificationKey)
        should = !voiceCallNotification
        if setting.noDisturbing {
            let date = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: date)
            let now = (components.hour ?? 0) * 60 + (components.minute ?? 0)
            let start = setting.noDisturbingStartH * 60 + setting.noDisturbingStartM
            let end = setting.noDisturbingEndH * 60 + setting.noDisturbingEndM
            
            //当天区间
            if (end > start && end >= now && now >= start)
            {
                should = true
            }
            //隔天区间
            else if(end < start && (now <= end || now >= start))
            {
                should = true
            }
        }

        return should
    }
    
    //拒绝邀请- 信令
    func unAcceptInvited(channelId: String, caller: String, requestId: String){
        let data: [String: Any] = [:]
        let dict = ["type": "isCallBusy", "data": data] as [String : Any]
        let customInfo = dict.toJSON
        let v2parma = V2NIMSignallingRejectInviteParams()
        v2parma.channelId = channelId
        v2parma.inviterAccountId = caller
        v2parma.requestId = requestId
        v2parma.serverExtension = customInfo
        NIMSDK.shared().v2SignallingService.rejectInvite(v2parma) {
            
        } failure: { _ in
           
        }
    }
    /// 跳转音视频
    private func presentCalls(types: V2NIMSignallingChannelType, caller: String, channelId: String, channelName: String, requestId: String) {

        guard let topVC = TGViewController.topMostController else {return}
        switch (types) {
        case .SIGNALLING_CHANNEL_TYPE_VIDEO:
            DispatchQueue.main.async {
                let vc = RLAudioCallController(caller: caller, channelId: channelId, channelName: channelName, requestId: requestId, callType: types)
                let nav = TGNavigationController(rootViewController: vc)
                topVC.present(nav.fullScreenRepresentation, animated: true)
                
            }
        case .SIGNALLING_CHANNEL_TYPE_AUDIO:
            DispatchQueue.main.async {
                let vc = RLAudioCallController(caller: caller, channelId: channelId, channelName: channelName, requestId: requestId, callType: types)
                let nav = TGNavigationController(rootViewController: vc)
                topVC.present(nav.fullScreenRepresentation, animated: true)
            }
            
        default: break
        }
    }

    ///群呼
    @objc func presentTeamCall(data: [String : Any], event: V2NIMSignallingEvent){
        
        guard let topVC = TGViewController.topMostController else {
            return
        }
//        let channelInfo = IMTeamMeetingCalleeInfo()
//        channelInfo.requestId = notifyResponse.requestId
//        channelInfo.channelId = notifyResponse.channelInfo.channelId
//        channelInfo.channelName = notifyResponse.channelInfo.channelName
//        channelInfo.caller = notifyResponse.fromAccountId
//        channelInfo.teamId = (data["teamId"] as? String) ?? ""
//        channelInfo.members = (data["members"] as? [String]) ?? []
//        TSUtil.checkAuthorizeStatusByType(type: .videoCall, viewController: topVC, completion: {
//            DispatchQueue.main.async {
//                let vc = IMTeamMeetingViewController(channelInfo: channelInfo)
//                topVC.present(vc.fullScreenRepresentation, animated: true, completion: nil)
//            }
//        })
        
        
    }
}

extension IMNotificationCenter: V2NIMSignallingListener {
    func onOnlineEvent(_ event: V2NIMSignallingEvent) {
        switch event.eventType {
        case .SIGNALLING_EVENT_TYPE_INVITE:
 
            if self.shouldResponseBusy() || self.shouldAutoRejectCall() {
                self.unAcceptInvited(channelId: event.channelInfo.channelId, caller: event.inviterAccountId ?? "", requestId: event.requestId)
                return
                
            }
            if let data = event.channelInfo.channelExtension?.data(using: .utf8), let customInfo = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                if let type = customInfo["type"] as? String {
                    switch NERtCallingType(rawValue: type) {
                    case .team:
                        
                        if let data = customInfo["data"] as? [String : Any] {
                            self.presentTeamCall(data: data, event: event)
                        }
                    case .p2p:
                        self.presentCalls(types: event.channelInfo.channelType, caller: event.inviterAccountId ?? "", channelId: event.channelInfo.channelId, channelName: event.channelInfo.channelName ?? "", requestId: event.requestId)
                    default:
                        break
                    }
                    
                }
            }
            
    
            
        default:
            break
        }
    }
    
    func onOfflineEvent(_ event: [V2NIMSignallingEvent]) {
        guard let eventOne = event.first else {
            return
        }
//        switch eventOne.eventType {
//        case .SIGNALLING_EVENT_TYPE_INVITE:
//            if self.shouldResponseBusy() || self.shouldAutoRejectCall() {
//                self.unAcceptInvited(channelId: eventOne.channelInfo.channelId, caller: eventOne.inviterAccountId ?? "", requestId: eventOne.requestId)
//                return
//            }
//            if let data = eventOne.channelInfo.channelExtension?.data(using: .utf8), let customInfo = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
//                if let type = customInfo["type"] as? String {
//                    switch NERtCallingType(rawValue: type) {
//                    case .team:
//                        if let data = customInfo["data"] as? [String : Any] {
//                            self.presentTeamCall(data: data, event: eventOne)
//                        }
//                    case .p2p:
//                        self.presentCalls(types: eventOne.channelInfo.channelType, caller: eventOne.inviterAccountId ?? "", channelId: eventOne.channelInfo.channelId, channelName: eventOne.channelInfo.channelName ?? "", requestId: eventOne.requestId)
//
//                    default:
//                        break
//                    }
//                    
//                }
//            }
//        default:
//            break
//        }
    }
}
