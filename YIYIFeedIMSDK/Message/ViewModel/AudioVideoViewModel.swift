//
//  AudioVideoViewModel.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/27.
//

import UIKit
import NIMSDK
import NERtcSDK

let DelaySelfStartControlTime = 10
//激活铃声后无人接听的超时时间
let NoBodyResponseTimeOut = 45

class AudioVideoViewModel: NSObject {
    
    var callInfo: NetCallChatInfo = NetCallChatInfo()
    var callEventType: CallingEventType = .noResponse
    
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
    
        NERtcEngine.shared().adjustPlaybackSignalVolume(200)
        NERtcEngine.shared().adjustRecordingSignalVolume(200)
        NERtcEngine.shared().muteLocalAudio(false)
        NERtcEngine.shared().subscribeAllRemoteAudio(true)
       
    }
    
    func addObserver() {
        NIMSDK.shared().mediaManager.switch(NIMAudioOutputDevice.speaker)
        NIMSDK.shared().signalManager.add(self)
    }
    
    func removeAllObserver() {
        NIMSDK.shared().signalManager.remove(self)
        DispatchQueue.global().async {
            NERtcEngine.destroy()
        }
    }

}

extension AudioVideoViewModel: NIMSignalManagerDelegate {
    func nimSignalingOnlineNotify(_ eventType: NIMSignalingEventType, response notifyResponse: NIMSignalingNotifyInfo) {
//        
//        switch eventType {
//        case .invite:
//            break
//        case .cancelInvite:
//            if !calleeResponsed { //没接听
//                calleeResponseTimer?.stopTimer()
//                self.player?.stop()
//                self.dismiss {}
//            }
//            
//        case .close:
//            callEventType = .bill
//            self.player?.stop()
//            timer?.stopTimer()
//            calleeResponseTimer?.stopTimer()
//            self.closeChannel()
//        case .reject:
//            callEventType = .reject
//            self.player?.stop()
//            timer?.stopTimer()
//            calleeResponseTimer?.stopTimer()
//            if let data = notifyResponse.customInfo.data(using: .utf8), let customInfo = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
//                if let type = customInfo["type"] as? String {
//                    let msg = type == "isCallBusy" ? "avchat_peer_busy".localized : "chatroom_rejected".localized
//                    self.view.makeToast(msg, duration: 2, position: CSToastPositionCenter)
//                }
//            }
//            self.closeChannel()
//        case .leave:
//            self.player?.stop()
//            timer?.stopTimer()
//            calleeResponseTimer?.stopTimer()
//            self.closeChannel()
//        case .accept:
//            calleeResponseTimer?.stopTimer()
//            calleeResponsed = true
//            self.player?.stop()
//            self.meetingSeconds = 0
//            self.timer = TimerHolder()
//            self.timer?.startTimer(seconds: 1, delegate: self, repeats: true)
//            self.onCalling()
//            
//        case .contrl:
//            
//            if let data = notifyResponse.customInfo.data(using: .utf8), let customInfo = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
//                if let type = customInfo["type"] as? String {
//                    switch NERtChangeType(rawValue: type) {
//                    case .toAudio:
//                        self.switchToAudio()
//                    case .toVideo:
//                        self.onResponseVideoMode()
//                    case .agreeToVideo:
//                        self.switchToVideo()
//                    case .rejectToVideo:
//                        self.view.makeToast("switching_reject_video".localized, duration: 2, position: CSToastPositionCenter)
//                    default:
//                        break
//                    }
//                    
//                }
//            }
//            
//        default:
//            break
//        }
//        
    }
     /*在线多端同步通知

     @param eventType 信令操作事件类型：这里只有接受和拒绝
     @param notifyResponse 信令通知回调数据
     @discussion 用于通知信令相关的多端同步通知。比如自己在手机端接受邀请，PC端会同步收到这个通知  NIMSignalingEventType 5-6有效
     */
    func nimSignalingMultiClientSyncNotify(_ eventType: NIMSignalingEventType, response notifyResponse: NIMSignalingNotifyInfo) {
        
//        switch eventType {
//        case .reject:
//            //其他端拒绝了邀请
//            self.player?.stop()
//            self.calleeResponseTimer?.stopTimer()
//            self.dismiss()
//            break
//        case .accept:
//            //其他端接受了邀请
//            self.player?.stop()
//            self.calleeResponseTimer?.stopTimer()
//            self.dismiss()
//            
//            break
//        default:
//            break
//        }
    }
}

extension AudioVideoViewModel: NERtcEngineDelegateEx {
    
    func onNERtcEngineConnectionStateChange(with state: NERtcConnectionStateType, reason: NERtcReasonConnectionChangedType) {
        
    }
    
    func onNERtcEngineUserDidJoin(withUserID userID: UInt64, userName: String) {
//        self.oppositeUserID = userID
//        
//        self.setRemoteVideo(userID: userID)
    }
    
    func onNERtcEngineUserSubStreamAudioDidStart(_ userID: UInt64) {
        
    }
    
    func onNERtcEngineUserVideoDidStart(withUserID userID: UInt64, videoProfile profile: NERtcVideoProfileType) {
        
      //  self.subscribeRemoteVideo(userID: userID, profile: profile)
        
    }
    
    func onNERtcEngineUserVideoDidStop(_ userID: UInt64) {
        
    }
    //对方关闭摄像机
    func onNERtcEngineUser(_ userID: UInt64, videoMuted muted: Bool, streamType: NERtcStreamChannelType) {
      //  self.userMutedRemoteVideo(userID: userID, muted: muted)
    }
    
    func onNERtcEngineDidDisconnect(withReason reason: NERtcError) {
//        callEventType = .bill
//        self.timer?.stopTimer()
//        self.player?.stop()
//        self.dismiss()
    }
    
    func onNERtcEngineUserDidLeave(withUserID userID: UInt64, reason: NERtcSessionLeaveReason) {
//        if reason != .neRtcSessionLeaveNormal {
//            self.player?.stop()
//            timer?.stopTimer()
//            calleeResponseTimer?.stopTimer()
//            callEventType = .bill
//            self.closeChannel(isCallApi: true)
//        }
    }
    
}
