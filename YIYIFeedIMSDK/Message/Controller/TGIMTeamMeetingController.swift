//
//  TGIMTeamMeetingController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/29.
//

import UIKit
import NIMSDK
import NERtcSDK
import AVFAudio
import AVFoundation

enum TeamMeetingRoleType: Int {
    case TeamMeetingRoleCaller = 0 //发起者
    case TeamMeetingRoleCallee     //受邀请者
}

enum IMMeetingMemberState: Int {
    case IMMeetingMemberStateConnecting //连接中
    case IMMeetingMemberStateTimeout    //未连接
    case IMMeetingMemberStateConnected  //已连接
    case IMMeetingMemberStateDisconnected //已挂断
}

class IMMeetingMember: NSObject {
    
    var userId: String = ""
    var mute: Bool = false
    var state: IMMeetingMemberState = .IMMeetingMemberStateDisconnected
    
    var isJoined: Bool = false// 是否进入频道
    var uid: UInt64 = 0
    var isMutedVoice: Bool = false
    var volume: Int32 = 0
    var isOpenLocalVideo: Bool = false //是否开启本端视频

}

class IMTeamMeetingCallerInfo: NSObject {
    var members: [String] = []
    var teamId: String = ""
}

class IMTeamMeetingCalleeInfo: NSObject {
    var members: [String] = []
    var teamId: String = ""
    var requestId: String = ""
    var caller: String = ""
    var channelId: String = ""
    var channelName: String?
}


class TGIMTeamMeetingController: TGViewController {

    let rowsInSection = 9
    let durationLabel: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 22, color: .white))
        $0.textAlignment = .center
        $0.numberOfLines = 1
    }
    
    let titleL: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 17, color: .white))
        $0.textAlignment = .center
        $0.text = "Group Video Call".localized
    }
    let callingMembers: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 27, color: .white))
        $0.textAlignment = .center
        $0.text = "连接中，请稍候..."
    }

    let callingInfoLabel: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 20, color: .white))
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.text = "连接中，请稍候..."
    }

    let muteLabel: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 16, color: .white))
        $0.textAlignment = .center
        $0.text = "mute".localized
    }

    let cameraOffLabel: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 16, color: .white))
        $0.textAlignment = .center
        $0.text = "group_open_camera".localized
    }

    let cameraSwitchButton: UIButton = UIButton().configure {
        $0.setImage(UIImage(named: "btn_turn"), for: .normal)
        $0.isHidden = true
    }

    let cameraDisableButton: UIButton = UIButton().configure {
        $0.setImage(UIImage(named: "btn_camera_group_video_normal"), for: .normal)
        $0.setImage(UIImage(named: "btn_camera_group_video_selected"), for: .selected)
        $0.isEnabled = false
    }

    let acceptBtn: UIButton = UIButton().configure {
        $0.setImage(UIImage(named: "icon_accept_video"), for: .normal)
    }

    let refuseBtn: UIButton = UIButton().configure {
        $0.setImage(UIImage(named: "icon_decline"), for: .normal)
    }

    let muteButton: UIButton = UIButton().configure {
        $0.setImage(UIImage(named: "btn_mute_normal"), for: .normal)
        $0.setImage(UIImage(named: "btn_mute_pressed"), for: .selected)
        $0.isEnabled = false
    }

    let hangupButton: UIButton = UIButton().configure {
        $0.setImage(UIImage(named: "icon_reject"), for: .normal)
        $0.isHidden = true
    }

    let inviteBtn: UIButton = UIButton().configure {
        $0.setImage(UIImage(named: "ic_group_add"), for: .normal)
        $0.isHidden = true
    }

    let viewmodel = TeamMeetingViewModel()
    var player: AVAudioPlayer?
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
    var timer: TimerHolder?
    var timerCallee: TimerHolder? //呼叫超时记录
    var startTime: TimeInterval? //开始时间
    var cameraType: NERtcCameraPosition = .front
    //var notificaionSender: ChatCustomSysNotificationSender?
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collection.delegate = self
//        collection.dataSource = self
        collection.register(TGTeamMeetingCell.self, forCellWithReuseIdentifier: "TGTeamMeetingCell")
        collection.backgroundColor = .clear
        collection.isHidden = true
        return collection
    }()
    lazy var callingCollectionView: UICollectionView = {
        let layout = TGIMContactViewLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collection.delegate = self
//        collection.dataSource = self
        collection.register(TGTeamMeetingPreviewCell.self, forCellWithReuseIdentifier: "TGTeamMeetingPreviewCell")
        
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()

    
    
    convenience init(info: IMTeamMeetingCallerInfo, session: NIMSession?) {
        self.init(nibName: nil, bundle: nil)
        self.viewmodel.callerInfo = info
        self.viewmodel.role = .TeamMeetingRoleCaller
        self.viewmodel.setupMembers(members: info.members, teamId: info.teamId)
    }
    
    convenience init(channelInfo: IMTeamMeetingCalleeInfo) {
        self.init(nibName: nil, bundle: nil)
        self.viewmodel.calleeInfo = channelInfo
        self.viewmodel.role = .TeamMeetingRoleCallee
        self.viewmodel.setupMembers(members: channelInfo.members, teamId: channelInfo.teamId)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        timer = TimerHolder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    func initUI(){
        self.view.backgroundColor = UIColor(hex: "0x1b1e20")
        self.view.addSubview(self.titleL)
        self.titleL.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(TSStatusBarHeight)
        }
        self.view.addSubview(self.inviteBtn)
        self.inviteBtn.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(TSStatusBarHeight)
        }
       // self.inviteBtn.addTarget(self, action: #selector(inviteMemberAction), for: .touchUpInside)
        self.view.addSubview(self.cameraSwitchButton)
       // self.cameraSwitchButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        self.cameraSwitchButton.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.top.equalTo(TSStatusBarHeight)
        }
        
//        self.view.addSubview(self.collectionView)
//        self.collectionView.snp.makeConstraints { make in
//            make.right.equalTo(-8)
//            make.left.equalTo(8)
//            make.height.equalTo(self.view.width - 16)
//            make.top.equalTo(self.inviteBtn.snp.bottom).offset(8)
//        }
//        self.collectionView.layoutIfNeeded()
        
        
//        self.view.addSubview(self.callingCollectionView)
//        self.callingCollectionView.snp.makeConstraints { make in
//            make.right.equalTo(-8)
//            make.left.equalTo(8)
//            make.height.equalTo(166)
//            make.top.equalTo(self.inviteBtn.snp.bottom).offset(8)
//        }
        
        self.view.addSubview(self.callingMembers)
//        self.callingMembers.snp.makeConstraints { make in
//            make.right.equalTo(-20)
//            make.left.equalTo(20)
//            make.top.equalTo(self.callingCollectionView.snp_bottom).offset(2)
//        }
        self.view.addSubview(self.callingInfoLabel)
        self.callingInfoLabel.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.left.equalTo(20)
            make.top.equalTo(self.callingMembers.snp.bottom).offset(8)
        }
        
        self.view.addSubview(self.refuseBtn)
        self.refuseBtn.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.left.equalTo(59)
            make.bottom.equalTo(-TSBottomSafeAreaHeight - 8)
        }
      //  self.refuseBtn.addTarget(self, action: #selector(refuseCall), for: .touchUpInside)
        
        self.view.addSubview(self.acceptBtn)
        self.acceptBtn.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.right.equalTo(-59)
            make.bottom.equalTo(-TSBottomSafeAreaHeight - 8)
        }
       // self.acceptBtn.addTarget(self, action: #selector(acceptCall), for: .touchUpInside)
        self.view.addSubview(self.hangupButton)
       // self.hangupButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.hangupButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-TSBottomSafeAreaHeight - 8)
        }
        
        self.view.addSubview(self.muteLabel)
        self.muteLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.refuseBtn.snp.centerX)
            make.bottom.equalTo(self.refuseBtn.snp.top).offset(-12)
        }
        
        self.view.addSubview(self.cameraOffLabel)
        self.cameraOffLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.acceptBtn.snp.centerX)
            make.bottom.equalTo(self.refuseBtn.snp.top).offset(-12)
        }
        
        self.view.addSubview(self.muteButton)
        self.muteButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.left.equalTo(59)
            make.bottom.equalTo(self.muteLabel.snp.top).offset(-4)
        }
       // self.muteButton.addTarget(self, action: #selector(mute), for: .touchUpInside)
        
        self.view.addSubview(self.cameraDisableButton)
        self.cameraDisableButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.right.equalTo(-59)
            make.bottom.equalTo(self.cameraOffLabel.snp.top).offset(-4)
        }
     //   self.cameraDisableButton.addTarget(self, action: #selector(cameraDisable), for: .touchUpInside)
        self.view.addSubview(self.durationLabel)
        self.durationLabel.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.cameraDisableButton.snp.top).offset(-8)
        }
        self.callingMembers.text = ""
        self.callingMembers.adjustsFontSizeToFitWidth = true
        var i: Int = 0
        for member in self.invitedMembers{
            if (member.userId.count > 0)
            {
                var nick = ""
               
                if i == self.invitedMembers.count - 1 {
                    self.callingMembers.text = self.callingMembers.text?.appending(nick)
                }else {
                    nick =  nick.appending(",")
                    self.callingMembers.text = self.callingMembers.text?.appending(nick)
                }
                i = i + 1
            }
        }
        
      //  self.callingCollectionView.reloadData()

        if self.role == .TeamMeetingRoleCaller {
            self.callingInfoLabel.text = "waiting_for_respond".localized
//            self.showCallingButtons()
//            self.reserveMeetting()

        }else {
           // self.playRevicer()
            self.timerCallee = TimerHolder()
           // self.timerCallee?.startTimer(seconds: TimeInterval(NoBodyResponseTimeOut), delegate: self, repeats: false)
            self.callingInfoLabel.text = "calling_in_video".localized
            //self.showReceiverButtons()
  
        }
        
    }
    
    func checkServiceEnable (completionHandler:@escaping (Bool) -> ()) {
        let audioStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        let videoStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if videoStatus == .restricted || videoStatus == .denied {
            let alertController = UIAlertController(title: nil, message: "rw_camera_limited_video_chat_fail".localized, preferredStyle: .alert)
            let DestructiveAction = UIAlertAction(title: "cancel".localized, style: .destructive) {
                (result : UIAlertAction) -> Void in
            }
            let okAction = UIAlertAction(title: "title_settings".localized, style: .default) {
                (result : UIAlertAction) -> Void in
            }
            alertController.addAction(DestructiveAction)
            alertController.addAction(okAction)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
                self.present(alertController, animated: true) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            return
        }
        if audioStatus == .restricted || audioStatus == .denied {
            let alertController = UIAlertController(title: nil, message: "microphone_limited_chat_fail".localized, preferredStyle: .alert)
            let DestructiveAction = UIAlertAction(title: "rw_camera_limited_video_chat_fail".localized, style: .destructive) {
                (result : UIAlertAction) -> Void in
            }
            let okAction = UIAlertAction(title: "confirm".localized, style: .default) {
                (result : UIAlertAction) -> Void in
                completionHandler(false)
            }
            alertController.addAction(DestructiveAction)
            alertController.addAction(okAction)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
                self.present(alertController, animated: true) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            return
        }
        AVAudioSession.sharedInstance().requestRecordPermission({ (granted) -> Void in
            DispatchQueue.main.async {
                if granted {
                    let mediaType = AVMediaType.video
                    let authStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
                    
                    if authStatus == .restricted || authStatus == .denied {
                        let alertController = UIAlertController(title: nil, message: "rw_camera_limited_video_chat_fail".localized, preferredStyle: .alert)
                        let confirmBtn = UIAlertAction(title: "confirm".localized, style: .default) {
                            (result : UIAlertAction) -> Void in
                        }
                        alertController.addAction(confirmBtn)
                        self.present(alertController, animated: true) {
                            completionHandler(false)
                        }
                    } else {
                        completionHandler(true)
                    }
                } else {
                    let alertController = UIAlertController(title: nil, message: "microphone_limited_chat_fail".localized, preferredStyle: .alert)
                    let confirmBtn = UIAlertAction(title: "confirm".localized, style: .default) {
                        (result : UIAlertAction) -> Void in
                    }
                    alertController.addAction(confirmBtn)
                    self.present(alertController, animated: true) {
                        completionHandler(false)
                    }
                }
            }
        })
    }
    
    //关闭音频
    @objc func mute(){
        muteButton.isSelected = !muteButton.isSelected
        NERtcEngine.shared().muteLocalAudio(muteButton.isSelected)
    }
    //关闭相机
    @objc func cameraDisable(){
        cameraDisableButton.isSelected = !cameraDisableButton.isSelected
        NERtcEngine.shared().muteLocalVideo(!cameraDisableButton.isSelected, streamType: .mainStream)
        if let member = self.invitedMembers.first(where: {$0.userId == NIMSDK.shared().loginManager.currentAccount()}) {
            member.isOpenLocalVideo = cameraDisableButton.isSelected
//            if let indexPath = self.findIndexPathWithMember(member: member), let cell = self.collectionView.cellForItem(at: indexPath) as? IMTeamMeetingCollectionViewCell{
//                cell.setLocalVideo(enable: cameraDisableButton.isSelected, model: member)
//                cell.canvasViewMueted(enable: !cameraDisableButton.isSelected, model: member)
//            }
        }
        
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
    
    
    func checkCondition() -> Bool{
        if (!TGReachability.share.isReachable()) {
            //showError(message: "network_is_not_available".localized)
            return false
        }
        if self.invitedMembers.count > 9{
           // showError(message: "text_whiteboard_exceed_limit_user".localized)
            return false
        }
        return true
    }
    

    

}
