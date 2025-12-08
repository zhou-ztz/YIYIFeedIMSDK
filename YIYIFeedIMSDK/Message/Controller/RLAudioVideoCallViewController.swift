//
//  RLAudioVideoCallViewController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/27.
//

import UIKit
import NERtcSDK
import NIMSDK
import AVFAudio
import Toast

class RLAudioVideoCallViewController: TGViewController {
    
    let viewmodel: AudioVideoViewModel = AudioVideoViewModel()
    var player: AVAudioPlayer?
    var timer: TimerHolder?
    var calleeResponseTimer : TimerHolder?
    var meetingSeconds: Int = 0
    var calleeResponsed: Bool = false //是否已接听
    
    init(callee: String, callType: V2NIMSignallingChannelType = .SIGNALLING_CHANNEL_TYPE_AUDIO) {
        self.viewmodel.callInfo.callType = callType
        self.viewmodel.callInfo.isCaller = true
        self.viewmodel.callInfo.callee = callee
        self.viewmodel.callInfo.caller = NIMSDK.shared().v2LoginService.getLoginUser()
        super.init(nibName: nil, bundle: nil)
        
    }
    
    init(caller: String, channelId: String, channelName: String, requestId: String, callType: V2NIMSignallingChannelType = .SIGNALLING_CHANNEL_TYPE_AUDIO) {
        self.viewmodel.callInfo.callType = callType
        self.viewmodel.callInfo.isCaller = false
        self.viewmodel.callInfo.caller = NIMSDK.shared().v2LoginService.getLoginUser()
        self.viewmodel.callInfo.callee = caller
        self.viewmodel.callInfo.channelId = channelId
        self.viewmodel.callInfo.channelName = channelName
        self.viewmodel.callInfo.requestId = requestId
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewmodel.delegate = self
        self.customNavigationBar.isHidden = true
        self.view.backgroundColor = UIColor(hex: 0x1E1E1E)
        afterCheckService()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.player?.stop()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    deinit {
        viewmodel.removeAllObserver()
    }
    //远端视频
    func setRemoteVideo(userID: UInt64){}
    //订阅远端视频
    func subscribeRemoteVideo(userID: UInt64, profile: NERtcVideoProfileType){}
    //监听到对方禁止视频
    func userMutedRemoteVideo(userID: UInt64, muted: Bool){}
    //停止预览
    func stopPreview(){}
    func onCalling () {}
    func waitForConnecting () {}
    func onCalleeBusy () {}
    func onResponseVideoMode(){}
    func videoCallingInterface(){}
    func switchToAudio(){}
    func switchToVideo(){}
    
    // MARK: 拨打接听操作
    func afterCheckService() {
        if !self.viewmodel.callInfo.isCaller {
            self.calleeResponseTimer = TimerHolder()
            self.calleeResponseTimer?.startTimer(seconds: TimeInterval(NoBodyResponseTimeOut), delegate: self, repeats: false)
            self.startByCallee()
        } else {
            startByCaller ()
        }
    }
    func startByCallee () {
        self.playReceiverRing()
    }
    func startByCaller () {
        self.playConnectRing()
        self.doStartByCaller()
    }
    
    func doStartByCaller () {
        viewmodel.doStartByCaller {[weak self]  info in
            self?.joinChannel()
            self?.calleeResponseTimer = TimerHolder()
            self?.calleeResponseTimer?.startTimer(seconds: TimeInterval(NoBodyResponseTimeOut), delegate: self!, repeats: false)
        } failure: { error in
            
        }
    }
    
    func joinChannel(){
        viewmodel.joinChannel {[weak self] in
            DispatchQueue.main.async {
                if !(self?.viewmodel.callInfo.isCaller ?? false) {
                    if self?.viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO {
                        self?.viewmodel.stopPreview()
                    }
                    self?.meetingSeconds = 0
                    self?.timer = TimerHolder()
                    self?.timer?.startTimer(seconds: 1, delegate: self!, repeats: true)
                    self?.onCalling()
                }
            }
        } failure: { [weak self] in
            DispatchQueue.main.async {
                self?.closeChannel()
                self?.dismiss(animated: true)
            }
            
        }
    }
    
    func response(_ accept: Bool){
        calleeResponseTimer?.stopTimer()
        self.player?.stop()
        viewmodel.response {[weak self] info in
            self?.calleeResponsed = true
            self?.joinChannel()
        } failure: {[weak self] error in
            UIViewController.showBottomFloatingToast(with: error.nserror.localizedDescription, desc: "")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0){
                self?.dismiss()
            }
        }
        self.waitForConnecting()
    }
    
    func hangup() {
        self.player?.stop()
        self.timer?.stopTimer()
        self.calleeResponseTimer?.stopTimer()
        if calleeResponsed {
            self.viewmodel.callEventType = .bill
            ///关闭频道
            self.closeChannel()
        } else {
            ///取消邀请
            guard let _ = viewmodel.callInfo.requestId, let _ = viewmodel.channelInfo?.channelInfo.channelId   else {
                self.dismiss()
                return
            }
            viewmodel.cancelInvite {[weak self] error in
                guard let self = self else {
                   return
                }
                if let error = error?.nserror {
                    UIViewController.showBottomFloatingToast(with: error.localizedDescription, desc: "")
                }
                self.viewmodel.callEventType = .miss
                self.closeChannel()
            }
        }
        
    }
    
    func refuseAnswer(){
        viewmodel.refuseAnswer { [weak self]error in
            self?.dismiss()
        }
    }
    
    func closeChannel(){
        viewmodel.closeChannel {[weak self] error in
            self?.leavlChannel()
        }
    }
    
    func leavlChannel(){
        NERtcEngine.shared().leaveChannel()
        self.dismiss()
    }
    
    func durationDesc() -> String? {
        return String(format: "%02d:%02d", meetingSeconds / 60, meetingSeconds % 60)
    }
    
    func dismiss(){
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                if self.viewmodel.callInfo.isCaller {
                    self.viewmodel.sendCallMessage(callType: self.viewmodel.callInfo.callType, eventType: self.viewmodel.callEventType, duration: TimeInterval(self.meetingSeconds))
                }
            }
        }
        
    }
    
    // MARK: Ring
    func playConnectRing () {
        self.player?.stop()
        let url = Bundle.main.url(forResource: "yippi_ringtone", withExtension: "wav")
        do {
            if let url = url {
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = 20
                player?.play()
            }
        } catch {
            
        }
    }
    
    func playHangUpRing () {
        self.player?.stop()
        let url = Bundle.main.url(forResource: "video_chat_tip_ended", withExtension: "aac")
        do {
            if let url = url {
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = 20
                player?.play()
            }
        } catch {
            
        }
    }
    
    func playOnCallRing () {
        self.player?.stop()
        let url = Bundle.main.url(forResource: "video_chat_tip_ended", withExtension: "aac")
        do {
            if let url = url {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            }
        } catch {
            
        }
    }
    
    func playTimeoutRing () {
        self.player?.stop()
        let url = Bundle.main.url(forResource: "video_chat_tip_ended", withExtension: "aac")
        do {
            if let url = url {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            }
        } catch {
            
        }
    }
    
    func playReceiverRing () {
        self.player?.stop()
        let url = Bundle.main.url(forResource: "yippi_ringtone", withExtension: "wav")
        do {
            if let url = url {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
                try AVAudioSession.sharedInstance().setActive(true)
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = 20
                player?.play()
            }
        } catch {
            
        }
    }
    
}

extension RLAudioVideoCallViewController: TimerHolderDelegate {
    @objc func onTimerFired(holder: TimerHolder) {
        if holder == self.timer {
            self.meetingSeconds = meetingSeconds + 1
        }else if holder == self.calleeResponseTimer {
            
            if !calleeResponsed {
                calleeResponseTimer?.stopTimer()
                self.player?.stop()
                if viewmodel.callInfo.isCaller {
                    viewmodel.callEventType = .noResponse
                    
                    view.makeToast("no_answer_call".localized, duration: 2, position: CSToastPositionCenter)
                    self.closeChannel()
                }else {
                    navigationController?.view.makeToast("timeout_answer".localized, duration: 2, position: CSToastPositionCenter)
                    self.dismiss()
                }
                
            }
        }
    }
    
    
}
extension RLAudioVideoCallViewController: AudioVideoViewModelDelegate {
    func onOnlineEvent(_ event: V2NIMSignallingEvent) {
        switch event.eventType {
        case .SIGNALLING_EVENT_TYPE_INVITE:
            break
        case .SIGNALLING_EVENT_TYPE_CANCEL_INVITE:
            if !calleeResponsed { //没接听
                calleeResponseTimer?.stopTimer()
                self.player?.stop()
                self.dismiss()
            }
        case .SIGNALLING_EVENT_TYPE_CLOSE:
            viewmodel.callEventType = .bill
            self.player?.stop()
            timer?.stopTimer()
            calleeResponseTimer?.stopTimer()
            self.closeChannel()
        case .SIGNALLING_EVENT_TYPE_REJECT:
            viewmodel.callEventType = .reject
            self.player?.stop()
            timer?.stopTimer()
            calleeResponseTimer?.stopTimer()
            if let data = event.channelInfo.channelExtension?.data(using: .utf8), let customInfo = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                if let type = customInfo["type"] as? String {
                    let msg = type == "isCallBusy" ? "avchat_peer_busy".localized : "chatroom_rejected".localized
                    UIViewController.showBottomFloatingToast(with: msg, desc: "")
                }
            }
            self.closeChannel()
        case .SIGNALLING_EVENT_TYPE_LEAVE:
            self.player?.stop()
            timer?.stopTimer()
            calleeResponseTimer?.stopTimer()
            self.closeChannel()
        case .SIGNALLING_EVENT_TYPE_ACCEPT:
            calleeResponseTimer?.stopTimer()
            calleeResponsed = true
            self.player?.stop()
            self.meetingSeconds = 0
            self.timer = TimerHolder()
            self.timer?.startTimer(seconds: 1, delegate: self, repeats: true)
            self.onCalling()
        case .SIGNALLING_EVENT_TYPE_CONTROL:
            if let data = event.serverExtension?.data(using: .utf8), let customInfo = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                if let type = customInfo["type"] as? String {
                    switch NERtChangeType(rawValue: type) {
                    case .toAudio:
                        self.switchToAudio()
                    case .toVideo:
                        self.onResponseVideoMode()
                    case .agreeToVideo:
                        self.switchToVideo()
                    case .rejectToVideo:
                        self.view.makeToast("switching_reject_video".localized, duration: 2, position: CSToastPositionCenter)
                    default:
                        break
                    }
                    
                }
            }
        default:
            break
        }
    }
    
    func onMultiClientEvent(_ event: V2NIMSignallingEvent) {
        switch event.eventType {
        case .SIGNALLING_EVENT_TYPE_REJECT:
            //其他端拒绝了邀请
            self.player?.stop()
            self.calleeResponseTimer?.stopTimer()
            self.dismiss()
        case .SIGNALLING_EVENT_TYPE_ACCEPT:
            //其他端接受了邀请
            self.player?.stop()
            self.calleeResponseTimer?.stopTimer()
            self.dismiss()
        default:
            break
        }
    }
    
    func onOfflineEvent(_ event: [V2NIMSignallingEvent]) {
    }
    
    func onNERtcEngineConnectionStateChange(state: NERtcConnectionStateType, reason: NERtcReasonConnectionChangedType) {
        
    }
    
    func onNERtcEngineUserDidJoin(withUserID userID: UInt64, userName: String) {
        self.setRemoteVideo(userID: userID)
    }
    
    func onNERtcEngineUserVideoDidStart(withUserID userID: UInt64, videoProfile profile: NERtcVideoProfileType) {
        self.subscribeRemoteVideo(userID: userID, profile: profile)
    }
    
    func onNERtcEngineUser(_ userID: UInt64, videoMuted muted: Bool, streamType: NERtcStreamChannelType) {
        self.userMutedRemoteVideo(userID: userID, muted: muted)
    }
    
    func onNERtcEngineDidDisconnect(withReason reason: NERtcError) {
        viewmodel.callEventType = .bill
        self.timer?.stopTimer()
        self.player?.stop()
        self.dismiss()
    }
    
    func onNERtcEngineUserDidLeave(withUserID userID: UInt64, reason: NERtcSessionLeaveReason) {
        if reason != .neRtcSessionLeaveNormal {
            self.player?.stop()
            timer?.stopTimer()
            calleeResponseTimer?.stopTimer()
            viewmodel.callEventType = .bill
            self.closeChannel()
        }
    }
    
    
}
