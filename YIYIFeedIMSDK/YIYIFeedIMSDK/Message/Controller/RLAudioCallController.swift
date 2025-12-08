//
//  RLAudioCallController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/27.
//

import UIKit
import NIMSDK
import NERtcSDK
import Toast

class RLAudioCallController: RLAudioVideoCallViewController {
    
    lazy var bigVideoView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var smallVideoView: UIView = {
        let imageView = UIView()
        imageView.backgroundColor = UIColor(hex: 0x393939)
        return imageView
    }()
    
    lazy var switchVideoBtn: UIButton = {
        let button = UIButton()
        button.setTitle("视频模式", for: .normal)
        button.setImage(UIImage.set_image(named: "ic_switch_video"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(switchToVideoMode), for: .touchUpInside)
        return button
    }()
    
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "连接中，请稍候..."
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 27)
        label.textColor = .white
        return label
    }()
    
    lazy var connectLabel: UILabel = {
        let label = UILabel()
        label.text = "连接中，请稍候..."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    
    lazy var userProfileImageView: TGAvatarView = {
        let imageView = TGAvatarView()
       // imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 53 // 根据实际需要调整
        imageView.clipsToBounds = true
       // imageView.backgroundColor = .white
        return imageView
    }()
    
    lazy var muteBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.set_image(named: "btn_mute_normal"), for: .normal)
        button.setImage(UIImage.set_image(named: "btn_mute_pressed"), for: .selected)
        button.addTarget(self, action: #selector(mute), for: .touchUpInside)
        return button
    }()
    
    lazy var cameraMute: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.set_image(named: "btn_camera_pressed"), for: .normal)
        return button
    }()
    
    lazy var disableCameraBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.set_image(named: "btn_speaker_normal"), for: .normal)
        button.setImage(UIImage.set_image(named: "btn_speaker_pressed"), for: .selected)
        button.addTarget(self, action: #selector(userSpeaker), for: .touchUpInside)
        return button
    }()
    
    lazy var muteLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    lazy var speakerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    //
    lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "00:01"
        return label
    }()
    
    lazy var hangUpBtn: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(hangup), for: .touchUpInside)
        return button
    }()
    
    lazy var acceptBtn: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(acceptToCall), for: .touchUpInside)
        return button
    }()
    
    lazy var refuseBtn: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(refuseToCall), for: .touchUpInside)
        return button
    }()
    
    lazy var switchCameraBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.set_image(named: "btn_turn"), for: .normal)
        button.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        return button
    }()
    
    lazy var videoCallLabel: UILabel = {
        let label = UILabel()
        label.text = "Video Call"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()

    var localView: UIView? = UIView()
    weak var localPreView: UIView?
    var calleeBasy = false
    var isWaitForConnecting = false

    var overLayView: UIView?
    var connected = false
    //var previewView: PreviewView?
    var isUsingFrontCameraPreview = false
    
    var remoteView: UIView? = UIView()
    
    override init(callee: String, callType: V2NIMSignallingChannelType = .SIGNALLING_CHANNEL_TYPE_VIDEO) {
        super.init(callee: callee, callType: callType)
    }
    
    override init(caller: String, channelId: String, channelName: String, requestId: String, callType: V2NIMSignallingChannelType = .SIGNALLING_CHANNEL_TYPE_VIDEO) {
        super.init(caller: caller, channelId: channelId, channelName: channelName, requestId: requestId, callType: callType)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.088, green: 0.070, blue: 0.118, alpha: 1.00)
        bigVideoView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        // 添加子视图
        view.addSubview(bigVideoView)
        view.addSubview(smallVideoView)
        view.addSubview(videoCallLabel)
        view.addSubview(switchCameraBtn)
        view.addSubview(switchVideoBtn)
        view.addSubview(usernameLabel)
        view.addSubview(connectLabel)
        view.addSubview(userProfileImageView)
        view.addSubview(muteBtn)
        view.addSubview(muteLabel)
        view.addSubview(speakerLabel)
        view.addSubview(hangUpBtn)
        view.addSubview(acceptBtn)
        view.addSubview(refuseBtn)
        view.addSubview(durationLabel)
        view.addSubview(disableCameraBtn)
        
        smallVideoView.addSubview(cameraMute)
        
        switchVideoBtn.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(TSStatusBarHeight + 20)
            make.height.equalTo(30)
        }
        switchCameraBtn.snp.makeConstraints { make in
            make.right.equalTo(-14)
            make.top.equalTo(TSStatusBarHeight + 20)
            make.height.equalTo(30)
        }
        videoCallLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(TSStatusBarHeight + 20)
            make.height.equalTo(30)
        }
        smallVideoView.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.top.equalTo(self.switchCameraBtn.snp.bottom).offset(15)
            make.height.equalTo(118)
            make.width.equalTo(76)
        }
        cameraMute.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        smallVideoView.layoutIfNeeded()
        userProfileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(106)
            make.top.equalTo(TSNavigationBarHeight + 20)
        }
        userProfileImageView.circleCorner()
        usernameLabel.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(userProfileImageView.snp.bottom).offset(20)
        }
        connectLabel.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(usernameLabel.snp.bottom).offset(20)
        }
        
        
        refuseBtn.isHidden = viewmodel.callInfo.isCaller
        durationLabel.isHidden = true
        
        muteLabel.text = "mute".localized
        switchCameraBtn.isHidden = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_AUDIO
        speakerLabel.text =  viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO ? "camera_off".localized : "speaker".localized

        let image = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO ? UIImage.set_image(named: "btn_camera_video_normal") : UIImage.set_image(named: "btn_speaker_normal")
        let selectImage = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO ? UIImage.set_image(named: "btn_camera_video_pressed") : UIImage.set_image(named: "btn_speaker_pressed")
        disableCameraBtn.setImage(image, for: .normal)
        disableCameraBtn.setImage(selectImage, for: .selected)
        videoCallLabel.text = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO ? "Video Call".localized : "Voice Call".localized
        smallVideoView.isHidden = true
        speakerLabel.adjustsFontSizeToFitWidth = true

        let refuse_image = UIImage.set_image(named: "icon_decline")
        refuseBtn.setBackgroundImage(refuse_image, for: .normal)

        let accept_image = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO ? UIImage.set_image(named: "icon_accept_video") : UIImage.set_image(named: "icon_accept")
        acceptBtn.setBackgroundImage(accept_image, for: .normal)

        let hangUp_image = UIImage.set_image(named: "icon_reject")
        hangUpBtn.setBackgroundImage(hangUp_image, for: .normal)
       
        let mute_image = UIImage.set_image(named: "btn_mute_normal")
        muteBtn.setBackgroundImage(mute_image, for: .normal)

        connectLabel.adjustsFontSizeToFitWidth = true
        let switchModelText =  viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO ? "avchat_switch_to_audio".localized : "avchat_switch_to_video".localized
        switchVideoBtn.setTitle(switchModelText, for: .normal)
        switchVideoBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        if viewmodel.callInfo.caller == NIMSDK.shared().v2LoginService.getLoginUser() {
            connectLabel.text = "avchat_wait_receive".localized
        } else {
            connectLabel.text = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_AUDIO ? "invite_you_to_voice_call".localized : "calling_in_video".localized
        }
        
        hangUpBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(70)
            make.bottom.equalTo(-TSBottomSafeAreaHeight - 40)
        }
        refuseBtn.snp.makeConstraints { make in
            make.left.equalTo(69)
            make.width.height.equalTo(70)
            make.bottom.equalTo(-TSBottomSafeAreaHeight - 40)
        }
        acceptBtn.snp.makeConstraints { make in
            make.right.equalTo(-69)
            make.width.height.equalTo(70)
            make.bottom.equalTo(-TSBottomSafeAreaHeight - 40)
        }
        
        muteBtn.snp.makeConstraints { make in
            make.left.equalTo(79)
            make.bottom.equalTo(acceptBtn.snp.top).offset(-74)
            make.width.height.equalTo(50)
        }
        
        disableCameraBtn.snp.makeConstraints { make in
            make.right.equalTo(-79)
            make.bottom.equalTo(acceptBtn.snp.top).offset(-74)
            make.width.height.equalTo(50)
        }
        
        muteLabel.snp.makeConstraints { make in
            make.centerX.equalTo(muteBtn.snp.centerX)
            make.top.equalTo(muteBtn.snp.bottom).offset(5)
            make.width.equalTo(100)
        }
        
        speakerLabel.snp.makeConstraints { make in
            make.centerX.equalTo(disableCameraBtn.snp.centerX)
            make.top.equalTo(muteBtn.snp.bottom).offset(5)
            make.width.equalTo(100)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(muteBtn.snp.top).offset(-10)
            make.width.equalTo(200)
        }
        
        remoteView?.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        bigVideoView.addSubview(remoteView!)
        localView?.frame = smallVideoView.bounds
        smallVideoView.addSubview(localView!)
    }
    
    
    @objc func switchToVideoMode() {
        let type = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO ? NERtChangeType.toAudio : NERtChangeType.toVideo
        let data: [String: Any] = [:]
        let dict = ["type": type.rawValue, "data": data] as [String : Any]
        let customInfo = dict.toJSON
        viewmodel.switchAudioVideoMode(serverExtension: customInfo ?? "") { [weak self] error in
            if let error = error?.nserror {
                UIViewController.showBottomFloatingToast(with: error.localizedDescription, desc: "")
            } else {
                if self?.viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO {
                    self?.switchToAudio()
                } else {
                    self?.view.makeToast("request_switching_sent".localized, duration: 2, position: CSToastPositionCenter)
                }
            }
        }
    }
    
    @objc func mute() {
        // 静音的逻辑
        viewmodel.callInfo.isMute = !viewmodel.callInfo.isMute!
        self.muteBtn.isSelected = viewmodel.callInfo.isMute ?? false
        NERtcEngine.shared().muteLocalAudio(viewmodel.callInfo.isMute ?? false)
        player?.volume = !viewmodel.callInfo.isMute! ? 1 : 0
        
    }
    
    @objc func userSpeaker() {
       
        if viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO {
            viewmodel.callInfo.disableCammera = !viewmodel.callInfo.disableCammera!
            NERtcEngine.shared().muteLocalVideo(viewmodel.callInfo.disableCammera ?? false, streamType: .mainStream)
            disableCameraBtn.isSelected = viewmodel.callInfo.disableCammera!
            if viewmodel.callInfo.disableCammera == true {
                if localView != nil {
                    localView?.removeFromSuperview()
                }
            } else {
                if localView == nil {
                    localView = UIView(frame: smallVideoView.bounds)
                }
                smallVideoView.addSubview(localView!)
                viewmodel.localCanvas?.container = localView
                viewmodel.localCanvas?.renderMode = .cropFill
                viewmodel.localCanvas?.mirrorMode = .enabled
                NERtcEngine.shared().setupLocalVideoCanvas(viewmodel.localCanvas)
            }
            
        }else{
            // 使用扬声器的逻辑
            viewmodel.callInfo.useSpeaker = !viewmodel.callInfo.useSpeaker!
            self.disableCameraBtn.isSelected = viewmodel.callInfo.useSpeaker ?? false
            NERtcEngine.shared().setLoudspeakerMode(viewmodel.callInfo.useSpeaker ?? false)
        }
    }

    
    @objc override func hangup() {
        // 挂断电话的逻辑
        super.hangup()
    }
    
    @objc func acceptToCall() {
        // 接受来电的逻辑
        self.response(true)
    }
    
    @objc func refuseToCall(){
        self.refuseAnswer()
    }
    
    @objc func switchCamera() {
        // 切换摄像头的逻辑
        isUsingFrontCameraPreview = !isUsingFrontCameraPreview
        switchCameraBtn.isSelected = isUsingFrontCameraPreview
        viewmodel.cameraType = isUsingFrontCameraPreview ? .back : .front
        NERtcEngine.shared().switchCamera(with: viewmodel.cameraType)
    }
    
    func setLocalVideo(videoView: UIView, isPreView: Bool = false , enable: Bool = true){
        viewmodel.setLocalVideo(videoView: videoView, isPreView: isPreView, enable: enable)
    }
    
    override func stopPreview(){
        viewmodel.stopPreview()
    }
    
    override func setRemoteVideo(userID: UInt64){
        viewmodel.setRemoteVideo(remoteView: remoteView, userID: userID)
    }
    //订阅远端视频
    override func subscribeRemoteVideo(userID: UInt64, profile: NERtcVideoProfileType){
        viewmodel.subscribeRemoteVideo(userID: userID, profile: profile)
    }
    
    override func userMutedRemoteVideo(userID: UInt64, muted: Bool){
        if muted {
            if remoteView != nil {
                remoteView?.removeFromSuperview()
            }
        }else{
            if remoteView == nil {
                remoteView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
            }
            bigVideoView.addSubview(remoteView!)
            viewmodel.removeCanvas?.container = remoteView
            viewmodel.removeCanvas?.renderMode = .cropFill
            viewmodel.removeCanvas?.mirrorMode = .enabled
            NERtcEngine.shared().setupRemoteVideoCanvas(viewmodel.removeCanvas, forUserID: userID)
        }
    }
    
    // MARK: Call Life
    override func startByCaller() {
        super.startByCaller()
        startInterface()
    }

    override func startByCallee() {
        super.startByCallee()
        waitToCallInterface()
    }

    override func onCalling() {
        super.onCalling()
        videoCallingInterface()
    }

    override func waitForConnecting() {
        super.waitForConnecting()
        connectingInterface()
    }

    override func onCalleeBusy() {
        calleeBasy = true
        localPreView?.removeFromSuperview()
    }
    
    // MARK: Interface
    func startInterface () {
        let nick = ""
        usernameLabel.text = nick
        
        connectLabel.text = "calling_pls_wait".localized

        acceptBtn.isHidden = true
        refuseBtn.isHidden = true
        hangUpBtn.isHidden = false
        smallVideoView.isHidden = true
        switchVideoBtn.isHidden = true

        connectLabel.isHidden = false
        switchCameraBtn.isHidden = false
        muteBtn.isHidden = false
        disableCameraBtn.isHidden = false

        muteBtn.isEnabled = false
        disableCameraBtn.isEnabled = false
        isWaitForConnecting = false
        
        localView?.isHidden = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_AUDIO
        remoteView?.isHidden = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_AUDIO
        self.setLocalVideo(videoView: remoteView!, enable: viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO)
        if viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO {
            bigVideoView.isHidden = false
        }else {
            bigVideoView.isHidden = true
            smallVideoView.isHidden = true
            switchCameraBtn.isHidden = true
        }
        MessageUtils.getAvatarIcon(sessionId: viewmodel.callInfo.callee ?? "", conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
            self?.userProfileImageView.avatarInfo = avatarInfo
        }
    }
    
    func waitToCallInterface () {
        let nick = ""
        usernameLabel.text = nick
        connectLabel.text = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO ? "calling_in_video".localized : "calling_in_voice".localized
      
        hangUpBtn.isHidden = true
        smallVideoView.isHidden = true
        switchVideoBtn.isHidden = true

        muteLabel.isHidden = false

        muteBtn.isHidden = false
        disableCameraBtn.isHidden = false
        
        acceptBtn.isHidden = false
        refuseBtn.isHidden = false

        switchCameraBtn.isHidden = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_AUDIO
        localView?.isHidden = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_AUDIO
        remoteView?.isHidden = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_AUDIO
        if viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO {
            viewmodel.setLocalVideo(videoView: remoteView!, isPreView: true)
        }
        isWaitForConnecting = true

        muteBtn.isEnabled = false
        disableCameraBtn.isEnabled = false
        MessageUtils.getAvatarIcon(sessionId: viewmodel.callInfo.callee ?? "", conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
            self?.userProfileImageView.avatarInfo = avatarInfo
        }
    }
    
    func connectingInterface () {
        isWaitForConnecting = false
        acceptBtn.isHidden = true
        refuseBtn.isHidden = true
        hangUpBtn.isHidden = false
        usernameLabel.isHidden = true
        connectLabel.isHidden = false
        connectLabel.text = "connecting".localized
        switchVideoBtn.isHidden = true
        switchCameraBtn.isHidden = true
        muteBtn.isHidden = true
        disableCameraBtn.isHidden = true
    }
    
    func audioCallingInterface () {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(.easeInOut)
        UIView.setAnimationDuration(0.75)
        UIView.setAnimationTransition(.flipFromRight, for: view, cache: false)
        UIView.commitAnimations()
        self.durationLabel.isHidden = false
        viewmodel.callInfo.callType = .SIGNALLING_CHANNEL_TYPE_AUDIO
        userProfileImageView.isHidden = false
        usernameLabel.isHidden = false
        switchCameraBtn.isHidden = true
        switchVideoBtn.setTitle("avchat_switch_to_video".localized, for: .normal)
        self.disableCameraBtn.isSelected = false
        viewmodel.setAudioCallNERtcArgument()
        muteBtn.isSelected = false
        viewmodel.callInfo.isMute = false
        viewmodel.callInfo.useSpeaker = false
        speakerLabel.text = "speaker".localized
        let image =  UIImage.set_image(named: "btn_speaker_normal")
        let selectImage =  UIImage.set_image(named: "btn_speaker_pressed")
        disableCameraBtn.setImage(image, for: .normal)
        disableCameraBtn.setImage(selectImage, for: .selected)
        remoteView?.isHidden = true
        localView?.isHidden = true
        if remoteView != nil {
            remoteView?.removeFromSuperview()
        }
        if localView != nil {
            localView?.removeFromSuperview()
        }
        self.smallVideoView.isHidden = true
    }
    
    override func videoCallingInterface () {
        userProfileImageView.isHidden = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO
        usernameLabel.isHidden = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO
        videoCallLabel.isHidden = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO
        acceptBtn.isHidden = true
        refuseBtn.isHidden = true

        hangUpBtn.isHidden = false
        connectLabel.isHidden = true
        muteBtn.isEnabled = true
        disableCameraBtn.isEnabled = true
        self.durationLabel.isHidden = false
        
        muteBtn.isHidden = false
        smallVideoView.isHidden = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_AUDIO
        switchCameraBtn.isHidden = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_AUDIO
        disableCameraBtn.isHidden = false
        switchVideoBtn.isHidden = false

        muteBtn.isSelected = false
        self.disableCameraBtn.isSelected = false
        viewmodel.setVideoCallNERtcArgument()
        viewmodel.callInfo.isMute = false
        isUsingFrontCameraPreview = true
        viewmodel.callInfo.disableCammera = false
        let switchText = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO ? "avchat_switch_to_audio".localized : "avchat_switch_to_video".localized
        switchVideoBtn.setTitle(switchText, for: .normal)

        isWaitForConnecting = false
        connected = true
        localView?.isHidden = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_AUDIO
        remoteView?.isHidden = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_AUDIO
        self.setLocalVideo(videoView: localView!,enable: viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO)
  
    }
    
    //切换接听中界面(视频)
    func videoCallingChange() {
        viewmodel.callInfo.callType = .SIGNALLING_CHANNEL_TYPE_VIDEO
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(.easeInOut)
        UIView.setAnimationDuration(0.75)
        UIView.setAnimationTransition(.flipFromRight, for: view, cache: false)
        UIView.commitAnimations()
        self.smallVideoView.isHidden = false
        bigVideoView.isHidden = false
        remoteView?.isHidden = false
        localView?.isHidden = false
        if localView == nil {
            localView = UIView(frame: smallVideoView.bounds)
        }
        smallVideoView.addSubview(localView!)
        if remoteView == nil {
            remoteView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        }
        if let userId = viewmodel.oppositeUserID , viewmodel.removeCanvas == nil{
            self.setRemoteVideo(userID: userId)
        }
        
        bigVideoView.addSubview(remoteView!)
        viewmodel.localCanvas?.container = localView
        viewmodel.removeCanvas?.container = remoteView
        
        speakerLabel.text =  viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO ? "camera_off".localized : "speaker".localized
        let image = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO ? UIImage.set_image(named: "btn_camera_video_normal") : UIImage.set_image(named: "btn_speaker_normal")
        let selectImage = viewmodel.callInfo.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO ? UIImage.set_image(named: "btn_camera_video_pressed") : UIImage.set_image(named: "btn_speaker_pressed")
        disableCameraBtn.setImage(image, for: .normal)
        disableCameraBtn.setImage(selectImage, for: .selected)
        
        self.videoCallingInterface()
    }
    
    override func onResponseVideoMode() {
        let alert = UIAlertController(title: nil, message: "request_switching".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "rejected".localized, style: .cancel, handler: { (action) in
            let data: [String: Any] = [:]
            let dict = ["type": NERtChangeType.rejectToVideo.rawValue, "data": data] as [String : Any]
            let customInfo = dict.toJSON
            
            NIMSDK.shared().v2SignallingService.sendControl(self.viewmodel.channelInfo?.channelInfo.channelId ?? "", receiverAccountId: self.viewmodel.callInfo.callee ?? "", serverExtension: customInfo) {
                self.view.makeToast(String("rejected"),duration: 2, position: CSToastPositionCenter)
            } failure: { error in
                
            }
        }))
        alert.addAction(UIAlertAction(title: "accept_session".localized, style: .default, handler: { (action) in
            let data: [String: Any] = [:]
            let dict = ["type": NERtChangeType.agreeToVideo.rawValue, "data": data] as [String : Any]
            let customInfo = dict.toJSON
            NIMSDK.shared().v2SignallingService.sendControl(self.viewmodel.channelInfo?.channelInfo.channelId ?? "", receiverAccountId: self.viewmodel.callInfo.callee ?? "", serverExtension: customInfo) {
                self.videoCallingChange()
            } failure: { error in
                
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func onTimerFired(holder: TimerHolder) {
        super.onTimerFired(holder: holder)
        self.durationLabel.text = self.durationDesc()
    }
    override func switchToAudio() {
        audioCallingInterface()
    }
    override func switchToVideo(){
        videoCallingChange()
    }

}
