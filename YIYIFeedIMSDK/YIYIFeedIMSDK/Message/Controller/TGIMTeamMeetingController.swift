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
import Toast

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
    var requestId: String = ""
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
    var enableSpeaker: Bool = false

    //邀请成员的requestId列表
    //var requestIdList: [String] = []
    var meetingSeconds: Int = 0
    var channelId: String?
    var channelInfo: NIMSignalingChannelDetailedInfo?
    var isResponse: Bool = false //是否有人已经接受邀请
    var timer: TimerHolder?
    var timerCallee: TimerHolder? //呼叫超时记录
    var startTime: TimeInterval? //开始时间
    var cameraType: NERtcCameraPosition = .front

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.register(TGTeamMeetingCell.self, forCellWithReuseIdentifier: "TGTeamMeetingCell")
        collection.backgroundColor = .clear
        collection.isHidden = true
        return collection
    }()
    lazy var callingCollectionView: UICollectionView = {
        let layout = TGIMContactViewLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.register(TGTeamMeetingPreviewCell.self, forCellWithReuseIdentifier: "TGTeamMeetingPreviewCell")
        
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()

    
    
    convenience init(info: IMTeamMeetingCallerInfo, conversationId: String?) {
        self.init(nibName: nil, bundle: nil)
        self.viewmodel.callerInfo = info
        self.viewmodel.role = .TeamMeetingRoleCaller
        self.viewmodel.conversationId = conversationId
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
        viewmodel.delegate = self
        initUI()
    }
    
    func initUI(){
        self.customNavigationBar.isHidden = true
        self.view.backgroundColor = UIColor(red: 0.088, green: 0.070, blue: 0.118, alpha: 1.00)
        self.backBaseView.addSubview(self.titleL)
        self.titleL.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(TSStatusBarHeight)
        }
        self.backBaseView.addSubview(self.inviteBtn)
        self.inviteBtn.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(TSStatusBarHeight)
        }
        self.inviteBtn.addTarget(self, action: #selector(inviteMemberAction), for: .touchUpInside)
        self.backBaseView.addSubview(self.cameraSwitchButton)
        self.cameraSwitchButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        self.cameraSwitchButton.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.top.equalTo(TSStatusBarHeight)
        }
        
        self.backBaseView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.right.equalTo(-8)
            make.left.equalTo(8)
            make.height.equalTo(self.view.width - 16)
            make.top.equalTo(self.inviteBtn.snp.bottom).offset(8)
        }
        self.collectionView.layoutIfNeeded()
        
        
        self.backBaseView.addSubview(self.callingCollectionView)
        self.callingCollectionView.snp.makeConstraints { make in
            make.right.equalTo(-8)
            make.left.equalTo(8)
            make.height.equalTo(166)
            make.top.equalTo(self.inviteBtn.snp.bottom).offset(8)
        }
        
        self.backBaseView.addSubview(self.callingMembers)
        self.callingMembers.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.left.equalTo(20)
            make.top.equalTo(self.callingCollectionView.snp.bottom).offset(2)
        }
        self.backBaseView.addSubview(self.callingInfoLabel)
        self.callingInfoLabel.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.left.equalTo(20)
            make.top.equalTo(self.callingMembers.snp.bottom).offset(8)
        }
        
        self.backBaseView.addSubview(self.refuseBtn)
        self.refuseBtn.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.left.equalTo(59)
            make.bottom.equalTo(-TSBottomSafeAreaHeight - 8)
        }
        self.refuseBtn.addTarget(self, action: #selector(refuseCall), for: .touchUpInside)
        
        self.backBaseView.addSubview(self.acceptBtn)
        self.acceptBtn.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.right.equalTo(-59)
            make.bottom.equalTo(-TSBottomSafeAreaHeight - 8)
        }
        self.acceptBtn.addTarget(self, action: #selector(acceptCall), for: .touchUpInside)
        self.backBaseView.addSubview(self.hangupButton)
        self.hangupButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.hangupButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-TSBottomSafeAreaHeight - 8)
        }
        
        self.backBaseView.addSubview(self.muteLabel)
        self.muteLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.refuseBtn.snp.centerX)
            make.bottom.equalTo(self.refuseBtn.snp.top).offset(-12)
        }
        
        self.backBaseView.addSubview(self.cameraOffLabel)
        self.cameraOffLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.acceptBtn.snp.centerX)
            make.bottom.equalTo(self.refuseBtn.snp.top).offset(-12)
        }
        
        self.backBaseView.addSubview(self.muteButton)
        self.muteButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.left.equalTo(59)
            make.bottom.equalTo(self.muteLabel.snp.top).offset(-4)
        }
        self.muteButton.addTarget(self, action: #selector(mute), for: .touchUpInside)
        
        self.backBaseView.addSubview(self.cameraDisableButton)
        self.cameraDisableButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.right.equalTo(-59)
            make.bottom.equalTo(self.cameraOffLabel.snp.top).offset(-4)
        }
        self.cameraDisableButton.addTarget(self, action: #selector(cameraDisable), for: .touchUpInside)
        self.backBaseView.addSubview(self.durationLabel)
        self.durationLabel.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.cameraDisableButton.snp.top).offset(-8)
        }
        showMemberName()
        self.callingCollectionView.reloadData()

        if viewmodel.role == .TeamMeetingRoleCaller {
            self.callingInfoLabel.text = "waiting_for_respond".localized
            self.showCallingButtons()
            self.reserveMeetting()
        } else {
            self.playRevicer()
            self.timerCallee = TimerHolder()
            self.timerCallee?.startTimer(seconds: TimeInterval(NoBodyResponseTimeOut), delegate: self, repeats: false)
            self.callingInfoLabel.text = "calling_in_video".localized
            self.showReceiverButtons()
  
        }
        
    }
    
    func showMemberName() {
        self.callingMembers.text = ""
        self.callingMembers.adjustsFontSizeToFitWidth = true
        var i: Int = 0
        let userIds = viewmodel.invitedMembers.compactMap { $0.userId }
        
        MessageUtils.getUserInfo(accountIds: userIds) {[weak self] users, error in
            if let users = users, let self = self {
                for user in users {
                    var nick = ""
                    if let ext = user.serverExtension, let data = ext.data(using: .utf8) {
                        do {
                            let jsonDecoder = JSONDecoder()
                            let userInfo = try jsonDecoder.decode(TGNIMUserInfo.self, from: data)
                            nick = userInfo.name ?? (user.accountId ?? "")
                        } catch {
                            
                        }
                    } else {
                        nick = user.name ?? (user.accountId ?? "")
                    }
                    if i == self.viewmodel.invitedMembers.count - 1 {
                        DispatchQueue.main.async {
                            self.callingMembers.text = self.callingMembers.text?.appending(nick)
                        }
                    } else {
                        nick =  nick.appending(",")
                    }
                    i = i + 1
                }
            }
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
    /// 目前v10 版本 由于加入房间时没有返回rtcToken， 特殊处理批量呼叫 , 首先调用一次call 方法呼叫一位成员，拿到 rtcToken，再循环邀请其他剩下的成员
    func reserveMeetting() {
        let currentId = NIMSDK.shared().v2LoginService.getLoginUser() ?? ""
        let index = viewmodel.invitedMembers.firstIndex(where: { member in
            member.userId != currentId
        })
        
        guard let teamId = viewmodel.teamId, let index = index, let member = viewmodel.invitedMembers[safe: index] else { return }
        let calleeAccountId = member.userId
        let channelName = viewmodel.getChannelName(caller: currentId)
        let requestId = viewmodel.getChannelName(caller: currentId, callee: calleeAccountId)
        ///删除call 的成员
        var members = self.viewmodel.invitedMembers
        members.remove(at: index)
        //呼叫 calleeAccountId 成员
        viewmodel.reserveMeetting(requestId: requestId, calleeAccountId: calleeAccountId, channelName: channelName, teamId: teamId) { [weak self] in
            guard let self = self else {return}
            self.joinChannel()
            member.requestId = requestId
            //邀请其他成员
            self.signaInvite(members: members)
        } failure: {[weak self] error in
            UIViewController.showBottomFloatingToast(with: error.localizedDescription, desc: "")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5){
                self?.closeChannel()
                self?.dismiss()
            }
        }

    }
    
    //关闭频道
    func closeChannel(){
        viewmodel.closeChannel { [weak self] in
            self?.leavlChannel()
        } failure: {[weak self] error in
            UIViewController.showBottomFloatingToast(with: error?.localizedDescription ?? "", desc: "")
            self?.leavlChannel()
        }
    }
    //邀请成员
    func signaInvite(members: [IMMeetingMember], isFirst: Bool = true){
        guard let teamId = viewmodel.teamId else { return }
       
        let currentId = NIMSDK.shared().v2LoginService.getLoginUser() ?? ""
        
        if isFirst {
            self.timerCallee = TimerHolder()
            self.timerCallee?.startTimer(seconds: TimeInterval(NoBodyResponseTimeOut), delegate: self, repeats: false)
        }
        for member in members {
            if member.userId == currentId {
                continue
            }
            let requestId = viewmodel.getChannelName(caller: currentId, callee: member.userId)
            viewmodel.inviteMember(requestId: requestId, inviteeAccountId: member.userId, teamId: teamId) {
            } failure: { error in
                UIViewController.showBottomFloatingToast(with: error?.localizedDescription ?? "", desc: "")
            }
            member.requestId = requestId
        }
        
        /// 处理 requestId
        members.forEach { member in
            for invitedMember in viewmodel.invitedMembers {
                if invitedMember.userId == member.userId {
                    invitedMember.requestId = member.requestId
                }
            }
        }
        if isFirst {
            MessageUtils.getAvatarIcon(sessionId: NIMSDK.shared().v2LoginService.getLoginUser() ?? "", conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
                self?.viewmodel.sendTipMessage(nickName: avatarInfo.nickname ?? "")
            }
        }
    }
    
    func showCallingButtons(){
        acceptBtn.isHidden = true
        refuseBtn.isHidden = true
        hangupButton.isHidden = false
        self.collectionView.isHidden = true
    }
    
    func showReceiverButtons() {
        acceptBtn.isHidden = false
        refuseBtn.isHidden = false
        hangupButton.isHidden = true
        self.callingCollectionView.isHidden = false
        self.collectionView.isHidden = true
    }
    //同意接通UI
    func showCalled(){
        self.collectionView.isHidden = false
        self.callingCollectionView.isHidden = true
        muteButton.isEnabled = true
        cameraDisableButton.isEnabled = true
        acceptBtn.isHidden = true
        refuseBtn.isHidden = true
        hangupButton.isHidden = false
        self.callingMembers.isHidden = true
        self.callingInfoLabel.isHidden = true
        inviteBtn.isHidden = false
        cameraSwitchButton.isHidden = false
    }
        
    
    func checkCondition() -> Bool{
        if viewmodel.invitedMembers.count > 9 {
            UIViewController.showBottomFloatingToast(with: "text_whiteboard_exceed_limit_user".localized, desc: "")
            return false
        }
        return true
    }
    
    //MARK: action
    //拒绝
    @objc func refuseCall(){
        self.player?.stop()
        self.timerCallee?.stopTimer()
        viewmodel.refuseAnswer { [weak self] in
            self?.dismiss()
        } failure: { [weak self] error in
            UIViewController.showBottomFloatingToast(with: error?.localizedDescription ?? "", desc: "")
            self?.dismiss()
        }
        
    }
    //接受
    @objc func acceptCall(){
        self.player?.stop()
        self.timerCallee?.stopTimer()
        self.joinMeeting()
        self.showCalled()

    }
    @objc func inviteMemberAction(){
        if self.checkCondition() {
            guard let teamID = viewmodel.teamId else {
                return
            }
            MessageUtils.fetchMembersTeam(teamId: teamID) {[weak self] userIds in
                guard let self = self else {return}
                var memberIds = [String]()
                for userId in userIds {
                    if let _ = self.viewmodel.invitedMembers.first(where: {$0.userId == userId}) {
                    }else{
                        memberIds.append(userId)
                    }
                    
                }
                
                let config = TGContactsPickerConfig(title: "select_contact".localized, rightButtonTitle: "done".localized, allowMultiSelect: true, enableTeam: false, enableRecent: false, enableRobot: false, maximumSelectCount: 9 - self.viewmodel.invitedMembers.count, members: memberIds, enableButtons: false, allowSearchForOtherPeople: true)
                
                let contactsPickerVC = TGContactsPickerViewController(configuration: config, finishClosure: { (contacts) in
                    var members = [IMMeetingMember]()
                    for contact in contacts {
                        let member = IMMeetingMember()
                        member.userId = contact.userName
                        member.state = .IMMeetingMemberStateConnecting
                        members.append(member)
                    }
                    self.signaInvite(members: members, isFirst: false)

                })
                let nav = TGNavigationController(rootViewController: contactsPickerVC)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
            
        }
    }
    @objc func switchCamera(){
        cameraType = cameraType == .front ? .back : .front
        NERtcEngine.shared().switchCamera(with: cameraType)
    }
    @objc func close() {
        if viewmodel.role == .TeamMeetingRoleCaller {
            if isResponse {
                timer?.stopTimer()
                timerCallee?.stopTimer()
                self.player?.stop()
                //离开信令频道
                viewmodel.signalingLeave(channelId: viewmodel.channelInfo?.channelInfo.channelId ?? "") { [weak self] in
                    self?.leavlChannel()
                } failure: { [weak self] error in
                    UIViewController.showBottomFloatingToast(with: error?.localizedDescription ?? "", desc: "")
                    self?.leavlChannel()
                }

            } else {
                timer?.stopTimer()
                timerCallee?.stopTimer()
                self.player?.stop()
                
                let group = DispatchGroup()
                for member in viewmodel.invitedMembers {
                    if member.requestId == "" {
                        continue
                    }
                    group.enter()
                    viewmodel.cancelInvite(channelId: viewmodel.channelInfo?.channelInfo.channelId ?? "", inviteeAccountId: member.userId, requestId: member.requestId) {
                        group.leave()
                    } failure: { error in
                        group.leave()
                        UIViewController.showBottomFloatingToast(with: error?.localizedDescription ?? "", desc: "")
                    }
                }
                
                group.notify(queue: DispatchQueue.main) { [weak self] in
                    self?.closeChannel()
                }
                
            }
            
        } else {
            timer?.stopTimer()
            timerCallee?.stopTimer()
            self.player?.stop()
            guard let calleeInfo = viewmodel.calleeInfo else {
                self.dismiss()
                return
            }
            //离开频道
            viewmodel.signalingLeave(channelId: calleeInfo.channelId) { [weak self] in
                self?.leavlChannel()
            } failure: { error in
                UIViewController.showBottomFloatingToast(with: error?.localizedDescription ?? "", desc: "")
            }
        }
        
        
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
        if let member = viewmodel.invitedMembers.first(where: {$0.userId == NIMSDK.shared().v2LoginService.getLoginUser()}) {
            member.isOpenLocalVideo = cameraDisableButton.isSelected
            if let indexPath = viewmodel.findIndexPathWithMember(member: member), let cell = self.collectionView.cellForItem(at: indexPath) as? TGTeamMeetingCell {
                cell.setLocalVideo(enable: cameraDisableButton.isSelected, model: member)
                cell.canvasViewMueted(enable: !cameraDisableButton.isSelected, model: member)
            }
        }
        
    }
    
    func dismiss(){
        
        if let topController = TGViewController.topMostController {
            if topController.isKind(of: TGContactsPickerViewController.self) {
                self.dismiss(animated: true) {
                    self.dismiss(animated: true)
                }
            }else{
                self.dismiss(animated: true)
            }
        }else{
            self.dismiss(animated: true)
        }
        
        
    }
    
    func joinMeeting(){
        viewmodel.response { [weak self] in
            self?.joinChannel()
        } failure: { [weak self] error in
            UIViewController.showBottomFloatingToast(with: error?.localizedDescription ?? "", desc: "")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5){
                self?.dismiss()
            }
        }
        
    }
    
    //音视频2.0
    func joinChannel(){
        guard let rtcToken = viewmodel.rtcInfo?.rtcToken, let channelName = viewmodel.channelInfo?.channelInfo.channelName else { return }
        viewmodel.joinChannel(rtcToken: rtcToken, channelName: channelName) { [weak self] in
            guard let self = self else { return }
            if let info = self.viewmodel.channelInfo {
                //默认禁止视频
                NERtcEngine.shared().muteLocalVideo(true, streamType: .mainStream)
                for member in info.members {
                    if let model = self.viewmodel.invitedMembers.first(where: {$0.userId == member.accountId}) {
                        model.uid = UInt64(member.uid)
                        model.isJoined = true
                    }else{
                        let model = IMMeetingMember()
                        model.userId = member.accountId
                        model.uid = UInt64(member.uid)
                        model.isJoined = true
                        self.viewmodel.invitedMembers.append(model)
                    }
                }
            }
            if self.viewmodel.role == .TeamMeetingRoleCallee { //接受者
                DispatchQueue.main.async{
                    self.startTimer()
                    self.showCalled()
                    self.isResponse = true
                    self.collectionView.reloadData()
                }
            } else {
                self.playConnectRing()
            }
        } failure: {[weak self] error in
            UIViewController.showBottomFloatingToast(with: error.localizedDescription, desc: "")
            self?.closeChannel()
            self?.dismiss()
        }
        
    }
    /// 离开音视频2.0频道
    func leavlChannel(){
        NERtcEngine.shared().leaveChannel()
        self.dismiss()
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
    
    func playRevicer () {
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
    
    func startTimer()
    {
        meetingSeconds = 0
        timer = TimerHolder()
        timer?.startTimer(seconds: 1, delegate: self, repeats: true)
       
    }
    
    func checkForTimeoutCallee(){
        var connectedCount: Int = 0
        var indexPaths: [IndexPath] = []
        var members = [IMMeetingMember]()
        for member in viewmodel.invitedMembers {
            if member.isJoined { //还没有进入房间
                connectedCount = connectedCount + 1
            } else {
                members.append(member)
                if let indexPath = viewmodel.findIndexPathWithMember(member: member) {
                    indexPaths.append(indexPath)
                }
            }
        }
        
        for member in members {
            if let index = self.viewmodel.invitedMembers.firstIndex(where: {$0.userId == member.userId}) {
                self.viewmodel.invitedMembers.remove(at: index)
            }
        }
        
        //如果有人接受状态
        if isResponse {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2){
                self.collectionView.reloadData()
            }
            
        }
        
        if  connectedCount <= 1 {
            self.timer?.stopTimer()
            self.player?.stop()
            if viewmodel.role == .TeamMeetingRoleCaller {
               // self.presentingViewController?.view.makeToast("no_answer_call".localized, duration: 2, position: CSToastPositionCenter)
    
                self.closeChannel()
            }else {
                if isResponse {
                    self.closeChannel()
                }
            }
            
            
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func durationDesc() -> String? {
        return String(format: "%02d:%02d", meetingSeconds / 60, meetingSeconds % 60)
    }
    

}

extension TGIMTeamMeetingController: TimerHolderDelegate {
    @objc func onTimerFired(holder: TimerHolder) {
        if holder == self.timer {
            meetingSeconds = meetingSeconds + 1
            if meetingSeconds == Int(NoBodyResponseTimeOut) {
                self.checkForTimeoutCallee()
            }
            self.durationLabel.text = self.durationDesc()
        }else if holder == self.timerCallee {
            
            self.timerCallee?.stopTimer()
            self.player?.stop()
            if viewmodel.role == .TeamMeetingRoleCaller {
                self.checkForTimeoutCallee()
            }else {
                self.presentingViewController?.view.makeToast("timeout_answer".localized, duration: 2, position: CSToastPositionCenter)
                self.dismiss()
            }
            
            
        }
        
    }
}

extension TGIMTeamMeetingController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.callingCollectionView {
            return CGSize(width: 90, height: 90)
        }
        
        let width: CGFloat  = collectionView.width / 3
        let height: CGFloat = width
        return CGSize(width: width - 4, height: height - 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.callingCollectionView {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        return  UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    }
}

extension TGIMTeamMeetingController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return viewmodel.rowsInSection
        }else{
            if self.viewmodel.invitedMembers.count > 4 {
                return 4
            }
            return self.viewmodel.invitedMembers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.callingCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TGTeamMeetingPreviewCell", for: indexPath) as! TGTeamMeetingPreviewCell
            cell.team = viewmodel.team
            
            let member = viewmodel.findMemberWithIndexPath(indexPath: indexPath)
             
            if let member = member {
                cell.loadCallingUser(user: member.userId, number: viewmodel.invitedMembers.count, index: indexPath.row)
            }
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TGTeamMeetingCell", for: indexPath) as! TGTeamMeetingCell
            cell.team = viewmodel.team
            if let member = viewmodel.findMemberWithIndexPath(indexPath: indexPath) {
                
                if member.isJoined {
                    cell.refreshWithModel(model: member)
                }else {
                    cell.refrehWithConnecting(user: member.userId)
                }
            }else {
                cell.refreshWithEmpty()
            }
            
            return cell
        }
        
    }
    
}

extension TGIMTeamMeetingController: TeamMeetingViewModelDelegate {
    
    func onOnlineEvent(_ event: V2NIMSignallingEvent) {
        switch event.eventType {
        case .SIGNALLING_EVENT_TYPE_INVITE:
            break
        case .SIGNALLING_EVENT_TYPE_CANCEL_INVITE:
            if viewmodel.channelId == nil { //没有加入任何频道
                self.timer?.stopTimer()
                self.player?.stop()
                self.dismiss()
            }
        case .SIGNALLING_EVENT_TYPE_CLOSE:
            self.timer?.stopTimer()
            self.player?.stop()
            self.leavlChannel()
        case .SIGNALLING_EVENT_TYPE_REJECT:
            let fromAccountId = event.operatorAccountId
            if let member = viewmodel.invitedMembers.first(where: {$0.userId == fromAccountId}){
                if self.isResponse { //如果有人接受邀请了
                    if let _ = viewmodel.findIndexPathWithMember(member: member){
                        viewmodel.invitedMembers.removeAll(where: {$0.userId == fromAccountId})
                        self.collectionView.reloadData()
                    } else {
                        viewmodel.invitedMembers.removeAll(where: {$0.userId == fromAccountId})
                    }
                } else {
                    viewmodel.invitedMembers.removeAll(where: {$0.userId == fromAccountId})
                }
                
                if viewmodel.invitedMembers.count <= 1 {
                    self.timer?.stopTimer()
                    self.timerCallee?.stopTimer()
                    self.player?.stop()
                    if let data = event.channelInfo.channelExtension?.data(using: .utf8), let customInfo = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                        if let type = customInfo["type"] as? String {
                            let msg = type == "isCallBusy" ? "avchat_peer_busy".localized : "chatroom_rejected".localized
                            UIViewController.showBottomFloatingToast(with: msg, desc: "")
                        }
                    }
                    self.closeChannel()
                    
                }
                
                
            }
        case .SIGNALLING_EVENT_TYPE_LEAVE:
            let fromAccountId = event.operatorAccountId
            if let member = viewmodel.invitedMembers.first(where: {$0.userId == fromAccountId}), let _ = viewmodel.findIndexPathWithMember(member: member){
                viewmodel.invitedMembers.removeAll(where: {$0.userId == fromAccountId})
                self.collectionView.reloadData()

            }
            //如果房间内只有一个人，主动关闭房间
            if viewmodel.invitedMembers.count <= 1 {
                self.timer?.stopTimer()
                self.player?.stop()
                self.closeChannel()
            }
            
        case .SIGNALLING_EVENT_TYPE_ACCEPT:
            if !self.isResponse {
                self.timerCallee?.stopTimer()
                self.startTimer()
                self.player?.stop()
                self.isResponse = true
                self.showCalled()
                self.collectionView.reloadData()
            }
        case .SIGNALLING_EVENT_TYPE_JOIN:
            if let opmember = event.member {
                if let member = viewmodel.invitedMembers.first(where: {$0.userId == opmember.accountId}) {
                    //已在房间
                    member.uid = UInt64(opmember.uid)
                    member.isJoined = true
                    if let indexPath = viewmodel.findIndexPathWithMember(member: member) {
                        self.collectionView.performBatchUpdates {
                            self.collectionView.reloadItems(at: [indexPath])
                        }
                    }
                } else {
                    let model = IMMeetingMember()
                    model.userId = opmember.accountId
                    model.uid = UInt64(opmember.uid)
                    model.isJoined = true
                    viewmodel.invitedMembers.append(model)
                    let indexPath = IndexPath(row: viewmodel.invitedMembers.count - 1, section: 0)
                    self.collectionView.performBatchUpdates {
                        self.collectionView.reloadItems(at: [indexPath])
                    }

                }
            }
        case .SIGNALLING_EVENT_TYPE_CONTROL:
            break
        default:
            break
        }
    }
    
    func onOfflineEvent(_ event: [V2NIMSignallingEvent]) {
        
    }
    
    func onMultiClientEvent(_ event: V2NIMSignallingEvent) {
        switch event.eventType {
        case .SIGNALLING_EVENT_TYPE_REJECT:
            //其他端拒绝了邀请
            self.player?.stop()
            self.timerCallee?.stopTimer()
            self.dismiss()
            break
        case .SIGNALLING_EVENT_TYPE_ACCEPT:
            //其他端接受了邀请
            self.player?.stop()
            self.timerCallee?.stopTimer()
            self.dismiss()
        default:
            break
        }
    }
    
    func onNERtcEngineConnectionStateChange(state: NERtcConnectionStateType, reason: NERtcReasonConnectionChangedType) {
        
    }
    
    func onNERtcEngineUserDidJoin(withUserID userID: UInt64, userName: String) {
        if let member = viewmodel.invitedMembers.first(where: {$0.uid == userID}) {
            if let indexPath = viewmodel.findIndexPathWithMember(member: member), let cell = self.collectionView.cellForItem(at: indexPath) as? TGTeamMeetingCell {
                cell.setRemoteView(enable: true, model: member)
                
            }
        }
    }
    
    func onNERtcEngineUserVideoDidStart(withUserID userID: UInt64, videoProfile profile: NERtcVideoProfileType) {
        if let member = viewmodel.invitedMembers.first(where: {$0.uid == userID}) {
            member.isOpenLocalVideo = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2){
                if let indexPath = self.viewmodel.findIndexPathWithMember(member: member), let cell = self.collectionView.cellForItem(at: indexPath) as? TGTeamMeetingCell{
                    cell.setRemoteView(enable: true, model: member)
                    cell.subscribeRemoteVideo(userID: member.uid)
                    cell.canvasViewMueted(enable: !member.isOpenLocalVideo, model: member)

                }
            }
            
            
        }
    }
    
    func onNERtcEngineUser(_ userID: UInt64, videoMuted muted: Bool, streamType: NERtcStreamChannelType) {
        if let member = viewmodel.invitedMembers.first(where: {$0.uid == userID}) {
            member.isOpenLocalVideo = !muted
            if let indexPath = viewmodel.findIndexPathWithMember(member: member), let cell = self.collectionView.cellForItem(at: indexPath) as? TGTeamMeetingCell {
                if muted {
                    cell.canvasViewMueted(enable: true, model: member)
                }else {
                    cell.setRemoteView(enable: true, model: member)
                    cell.subscribeRemoteVideo(userID: member.uid)
                    cell.canvasViewMueted(enable: false, model: member)
                }
                
            }
        }
    }
    //本地异常离开
    func onNERtcEngineDidDisconnect(withReason reason: NERtcError) {
        self.timer?.stopTimer()
        self.player?.stop()
        self.dismiss()
    }
    
    func onNERtcEngineUserDidLeave(withUserID userID: UInt64, reason: NERtcSessionLeaveReason) {
        if reason != .neRtcSessionLeaveNormal {
            if let member = viewmodel.invitedMembers.first(where: {$0.uid == userID}), let indexPath = viewmodel.findIndexPathWithMember(member: member){
                viewmodel.invitedMembers.removeAll(where: {$0.uid == userID})
                self.collectionView.performBatchUpdates {
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
            //如果房间内只有一个人，主动关闭房间
            if viewmodel.invitedMembers.count <= 1 {
                self.timer?.stopTimer()
                self.player?.stop()
                self.closeChannel()
                
            }
        }
    }
    
    
    func onLocalAudioVolumeIndication(_ volume: Int32, withVad enableVad: Bool) {
        if let member = viewmodel.invitedMembers.first(where: {$0.userId == NIMSDK.shared().v2LoginService.getLoginUser()}) {
            member.volume = volume
            if let indexPath = viewmodel.findIndexPathWithMember(member: member), let cell = self.collectionView.cellForItem(at: indexPath) as? TGTeamMeetingCell{
                cell.refreshWidthVolume(volume: member.volume)
            }
        }
    }
    
    func onRemoteAudioVolumeIndication(_ speakers: [NERtcAudioVolumeInfo]?, totalVolume: Int32) {
        guard let speakers = speakers else { return }
        for speaker in speakers {
            if let member = viewmodel.invitedMembers.first(where: {$0.uid == speaker.uid}) {
                member.volume = Int32(speaker.volume)
                if let indexPath = viewmodel.findIndexPathWithMember(member: member), let cell = self.collectionView.cellForItem(at: indexPath) as? TGTeamMeetingCell{
                    cell.refreshWidthVolume(volume: member.volume)
                    
                }
            }
        }
    }
    
}

