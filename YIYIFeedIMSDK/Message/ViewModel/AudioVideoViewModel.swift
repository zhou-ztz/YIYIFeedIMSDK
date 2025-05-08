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

protocol AudioVideoViewModelDelegate: AnyObject {
    func onOnlineEvent(_ event: V2NIMSignallingEvent)
    func onOfflineEvent(_ event: [V2NIMSignallingEvent])
    func onMultiClientEvent(_ event: V2NIMSignallingEvent)
    func onNERtcEngineConnectionStateChange(state: NERtcConnectionStateType, reason: NERtcReasonConnectionChangedType)
    func onNERtcEngineUserDidJoin(withUserID userID: UInt64, userName: String)
    func onNERtcEngineUserVideoDidStart(withUserID userID: UInt64, videoProfile profile: NERtcVideoProfileType)
    func onNERtcEngineUser(_ userID: UInt64, videoMuted muted: Bool, streamType: NERtcStreamChannelType)
    func onNERtcEngineDidDisconnect(withReason reason: NERtcError)
    func onNERtcEngineUserDidLeave(withUserID userID: UInt64, reason: NERtcSessionLeaveReason)
}

class AudioVideoViewModel: NSObject {
    
    weak var delegate: AudioVideoViewModelDelegate?
    
    var callInfo: NetCallChatInfo = NetCallChatInfo()
    var callEventType: CallingEventType = .noResponse
    var channelInfo: V2NIMSignallingRoomInfo?
    var oppositeUserID: UInt64?//对方的useriD
    var V2NIMSignalCallerInfo: V2NIMSignallingCallResult?
    var V2NIMSignalCalleeInfo: V2NIMSignallingCallSetupResult?
    
    var removeCanvas: NERtcVideoCanvas?
    var localCanvas: NERtcVideoCanvas?
    var cameraType: NERtcCameraPosition = .front
    
    override init() {
        super.init()
        initNERtc()
        addObserver()
    }
    
    func initNERtc(){
        let coreEngine = NERtcEngine.shared()
        let context = NERtcEngineContext()
        context.engineDelegate = self
        context.appKey = RLSDKManager.shared.appKey
        coreEngine.setupEngine(with: context)
        
        NERtcEngine.shared().adjustPlaybackSignalVolume(200)
        NERtcEngine.shared().adjustRecordingSignalVolume(200)
        NERtcEngine.shared().muteLocalAudio(false)
        NERtcEngine.shared().subscribeAllRemoteAudio(true)
        
    }
    
    func addObserver() {
        NIMSDK.shared().mediaManager.switch(NIMAudioOutputDevice.speaker)
        NIMSDK.shared().v2SignallingService.add(self)
    }
    
    func removeAllObserver() {
        NIMSDK.shared().v2SignallingService.remove(self)
        DispatchQueue.global().async {
            NERtcEngine.destroy()
        }
    }
    
    func sendCallMessage(callType: V2NIMSignallingChannelType , eventType: CallingEventType, duration: TimeInterval = 0){
        let attact = CustomAttachmentDecoder.audioVideoEncode(callType: callType, eventType: eventType, duration: duration)
        let message = MessageUtils.customV2Message(text: "", rawAttachment: attact)
        let convasationId = (callInfo.caller ?? "") + "|1|" + (callInfo.callee ?? "")
        NIMSDK.shared().v2MessageService.send(message, conversationId: convasationId, params: nil) { _ in
            
        } failure: { _ in
            
        }
    }
    
    func getChannelName(caller: String, callee: String = "")-> String{
        let now = Date()
        let timeInterval: TimeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        let name = callInfo.isCaller ? (caller + callee + String(timeStamp)) : (callee + caller + String(timeStamp))
        return name.md5
    }
    
    func doStartByCaller (success: @escaping (V2NIMSignallingRoomInfo?) ->Void, failure: @escaping (V2NIMError) ->Void) {
        
        callInfo.requestId = getChannelName(caller: callInfo.caller ?? "", callee: callInfo.callee ?? "")
        let data: [String: Any] = [:]
        let dict: [String : Any] = ["type": NERtCallingType.p2p.rawValue, "data": data]
        
        let customInfo = dict.toJSON
        let v2param = V2NIMSignallingCallParams()
        v2param.channelType = callInfo.callType
        v2param.calleeAccountId = callInfo.callee ?? ""
        v2param.requestId = callInfo.requestId ?? ""
        v2param.channelName = getChannelName(caller: callInfo.caller ?? "")
        v2param.channelExtension = customInfo ?? ""
        let pushConfig = V2NIMSignallingPushConfig()
        pushConfig.pushEnabled = true
        pushConfig.pushTitle = "".localized
       // pushConfig.pushPayload = "测试"
        pushConfig.pushContent = String(format: "call_request".localized, callInfo.callType.rawValue == NIMSignalingChannelType.audio.rawValue ? "msg_type_voice_call".localized : "msg_type_video_call".localized )
        v2param.pushConfig = pushConfig
        
        let rtcConfig = V2NIMSignallingRtcConfig()
        v2param.rtcConfig = rtcConfig
        NIMSDK.shared().v2SignallingService.call(v2param) {[weak self] callResult in
            self?.V2NIMSignalCallerInfo = callResult
            self?.channelInfo = callResult.roomInfo
            self?.callInfo.channelId = self?.channelInfo?.channelInfo.channelId
            success(self?.channelInfo)
        } failure: { error in
            failure(error)
        }
    }
    //音视频2.0 加入频道
    func joinChannel(isResponse: Bool = false, success: @escaping () ->Void, failure: @escaping () ->Void){
        let member = self.channelInfo?.members.first(where: {$0.accountId == NIMSDK.shared().v2LoginService.getLoginUser()})
        let rtcToken = self.callInfo.isCaller ? (self.V2NIMSignalCallerInfo?.rtcInfo?.rtcToken ?? "") : (self.V2NIMSignalCalleeInfo?.rtcInfo?.rtcToken ?? "")
        if let uid = member?.uid, let channelName = self.channelInfo?.channelInfo.channelName{ 
            let _ = NERtcEngine.shared().joinChannel(withToken: rtcToken, channelName: channelName, myUid: UInt64(uid)) { error, _, _, _ in
                if let _ = error {
                    failure()
                }else{
                    success()
                }
            }
        } else {
            failure()
        }
    }
    func response(success: @escaping (V2NIMSignallingRoomInfo?) ->Void, failure: @escaping (V2NIMError) ->Void) {
        guard let channelId = self.callInfo.channelId ,let requestId = self.callInfo.requestId else {
            return
        }
        let v2parma = V2NIMSignallingCallSetupParams()
        v2parma.channelId = channelId
        v2parma.callerAccountId = self.callInfo.callee ?? ""
        v2parma.requestId = requestId

        NIMSDK.shared().v2SignallingService.callSetup(v2parma) {[weak self] callSetupResult in
            self?.channelInfo = callSetupResult.roomInfo
            self?.V2NIMSignalCalleeInfo = callSetupResult
            self?.callInfo.channelId = self?.channelInfo?.channelInfo.channelId
            success(self?.channelInfo)
        } failure: { error in
            failure(error)
        }
        
        
    }
    /// 取消邀请
    func cancelInvite(completed: @escaping (V2NIMError?) ->Void) {
        guard let requestId = self.callInfo.requestId, let channelId = channelInfo?.channelInfo.channelId   else {
            return
        }
        let v2parma = V2NIMSignallingCancelInviteParams()
        v2parma.channelId = channelId
        v2parma.inviteeAccountId = self.callInfo.callee ?? ""
        v2parma.requestId = requestId
        NIMSDK.shared().v2SignallingService.cancelInvite(v2parma) {
            completed(nil)
        } failure: { error in
            completed(error)
        }
        
    }
    //拒绝邀请
    func refuseAnswer(completed: @escaping (V2NIMError?) ->Void){
        guard let channelId = self.callInfo.channelId, let requestId = self.callInfo.requestId else {
            return
        }
        let v2parma = V2NIMSignallingRejectInviteParams()
        v2parma.channelId = channelId
        v2parma.inviterAccountId = self.callInfo.callee ?? ""
        v2parma.requestId = requestId
        NIMSDK.shared().v2SignallingService.rejectInvite(v2parma) {
            completed(nil)
        } failure: { error in
            completed(error)
        }
        
    }
    
    ///关闭频道
    func closeChannel(completed: @escaping (V2NIMError?) ->Void){
        NIMSDK.shared().v2SignallingService.closeRoom(channelInfo?.channelInfo.channelId ?? "", offlineEnabled: true, serverExtension: nil) {
            completed(nil)
        } failure: { error in
            completed(error)
        }
        
    }
    /// 切换是视频模式
    func switchAudioVideoMode(serverExtension: String = "", completed: @escaping (V2NIMError?) ->Void){
        NIMSDK.shared().v2SignallingService.sendControl(callInfo.channelId ?? "", receiverAccountId: callInfo.callee, serverExtension: serverExtension) {
            completed(nil)
        } failure: { error in
            completed(error)
        }
    }
    ///停止预览
    func stopPreview(){
        NERtcEngine.shared().stopPreview(.mainStream)
    }
    ///订阅远端视频
    func subscribeRemoteVideo(userID: UInt64, profile: NERtcVideoProfileType){
        NERtcEngine.shared().subscribeRemoteVideo(true, forUserID: userID, streamType: .high)
    }
    
    func setLocalVideo(videoView: UIView, isPreView: Bool = false , enable: Bool = true){
        if localCanvas == nil {
            localCanvas = NERtcVideoCanvas()
        }
        localCanvas?.container = videoView
        localCanvas?.renderMode = .cropFill
        localCanvas?.mirrorMode = .enabled
        NERtcEngine.shared().setupLocalVideoCanvas(localCanvas)
        if isPreView {
            //预览
            NERtcEngine.shared().startPreview(.mainStream)
        }else {
            //以开启本地视频主流采集并发送
            NERtcEngine.shared().enableLocalVideo(enable, streamType: .mainStream)
        }
        
    }
    
    func setRemoteVideo(remoteView: UIView?, userID: UInt64){
        if removeCanvas == nil {
            removeCanvas = NERtcVideoCanvas()
        }
        removeCanvas?.container = remoteView
        removeCanvas?.renderMode = .cropFill
        removeCanvas?.mirrorMode = .enabled
        NERtcEngine.shared().setupRemoteVideoCanvas(removeCanvas, forUserID: userID)
        
    }
    
    func setAudioCallNERtcArgument(){
        NERtcEngine.shared().setLoudspeakerMode(false)
        NERtcEngine.shared().muteLocalAudio(false)
    }
    
    func setVideoCallNERtcArgument(){
        NERtcEngine.shared().setLoudspeakerMode(self.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO)
        NERtcEngine.shared().switchCamera(with: .front)
        NERtcEngine.shared().muteLocalAudio(false)
        NERtcEngine.shared().muteLocalVideo(false, streamType: .mainStream)
    }

}

extension AudioVideoViewModel: V2NIMSignallingListener {
    
    func onOnlineEvent(_ event: V2NIMSignallingEvent) {
        self.delegate?.onOnlineEvent(event)
    }
    
    func onOfflineEvent(_ event: [V2NIMSignallingEvent]) {
        self.delegate?.onOfflineEvent(event)
    }
    
    func onMultiClientEvent(_ event: V2NIMSignallingEvent) {
        self.delegate?.onMultiClientEvent(event)
    }
    
    func onSyncRoomInfoList(_ channelRooms: [V2NIMSignallingRoomInfo]) {
        
    }
    
}


extension AudioVideoViewModel: NERtcEngineDelegateEx {
    
    func onNERtcEngineConnectionStateChange(with state: NERtcConnectionStateType, reason: NERtcReasonConnectionChangedType) {
        self.delegate?.onNERtcEngineConnectionStateChange(state: state, reason: reason)
    }
    
    func onNERtcEngineUserDidJoin(withUserID userID: UInt64, userName: String) {
        self.oppositeUserID = userID
        self.delegate?.onNERtcEngineUserDidJoin(withUserID: userID, userName: userName)
    }
    
    func onNERtcEngineUserSubStreamAudioDidStart(_ userID: UInt64) {
        
    }
    
    func onNERtcEngineUserVideoDidStart(withUserID userID: UInt64, videoProfile profile: NERtcVideoProfileType) {
        self.delegate?.onNERtcEngineUserVideoDidStart(withUserID: userID, videoProfile: profile)
        
    }
    
    func onNERtcEngineUserVideoDidStop(_ userID: UInt64) {
        
    }
    //对方关闭摄像机
    func onNERtcEngineUser(_ userID: UInt64, videoMuted muted: Bool, streamType: NERtcStreamChannelType) {
        self.delegate?.onNERtcEngineUser(userID, videoMuted: muted, streamType: streamType)
    }
    
    func onNERtcEngineDidDisconnect(withReason reason: NERtcError) {
        self.delegate?.onNERtcEngineDidDisconnect(withReason: reason)
    }
    
    func onNERtcEngineUserDidLeave(withUserID userID: UInt64, reason: NERtcSessionLeaveReason) {
        self.delegate?.onNERtcEngineUserDidLeave(withUserID: userID, reason: reason)

    }
    
}
