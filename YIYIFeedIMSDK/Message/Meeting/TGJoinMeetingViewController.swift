//
//  TGJoinMeetingViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/24.
//

import UIKit

let scale: CGFloat = 82.0 / (151.0 + 82.0)
class TGJoinMeetingViewController: TGViewController {
    
    let viewmodel = TGJoinMeetingViewModel()
    
    lazy var logoImageView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "cropped-yippi_logo")
        img.contentMode = .scaleAspectFill
        return img
    }()
    
    lazy var logoL: UILabel = {
        let lab = UILabel()
        lab.text = "Meet"
        lab.textColor = UIColor(hex: "#28A8E0")
        lab.font = UIFont.boldSystemFont(ofSize: 30)
        return lab
    }()
    lazy var meetL: UILabel = {
        let lab = UILabel()
        lab.text = "meeting_code".localized
        lab.textColor = .black
        lab.font = UIFont.boldSystemFont(ofSize: 14)
        return lab
    }()
    
    lazy var codeT: UITextField = {
        let textF = UITextField()
        textF.backgroundColor = UIColor(hex: "#F5F5F5")//#808080
        textF.placeholder = "rw_meeting_id".localized
        textF.font = UIFont.systemRegularFont(ofSize: 14)
        textF.layer.cornerRadius = 10
        textF.clipsToBounds = true
        textF.leftViewMode = .always
        textF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 10))
        return textF
    }()
    
    lazy var joinBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("meeting_join".localized, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemMediumFont(ofSize: 17)
        btn.backgroundColor = UIColor(hex: 0xD1D1D1)
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    lazy var settingsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "settings".localized
        lab.textColor = .black
        lab.font = UIFont.boldSystemFont(ofSize: 17)
        return lab
    }()
    
    lazy var muteStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .horizontal
        return stack
    }()
    
    lazy var muteLabel: UILabel = {
        let label = UILabel()
        label.text = "mute".localized
        label.textColor = .black
        label.font = UIFont.systemRegularFont(ofSize: 14)
        return label
    }()
    
    lazy var cameraStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .horizontal
        return stack
    }()
    
    lazy var cameraLabel: UILabel = {
        let label = UILabel()
        label.text = "rw_turn_off_camera".localized
        label.textColor = .black
        label.font = UIFont.systemRegularFont(ofSize: 14)
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    var muteSwitch = UISwitch()
    var cameraSwitch = UISwitch()
    var pop: JoiningVC?
    var timer: TimerHolder?
    
    var timeView: UIView?
    var timeLabel:  UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.backItem.setTitle("dashboard_settings".localized, for: .normal)
        setUI()
        viewmodel.delegate = self
    }
    
    func setUI(){
        self.backBaseView.addSubview(codeT)
        codeT.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.left.equalTo(17)
            make.right.equalTo(-17)
            make.height.equalTo(68)
        }
        codeT.text = viewmodel.meetingNum
      
        self.backBaseView.addSubview(settingsLabel)
        settingsLabel.snp.makeConstraints { make in
            make.top.equalTo(codeT.snp.bottom).offset(16)
            make.left.equalTo(17)
        }
        
        self.backBaseView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(settingsLabel.snp.bottom).offset(12)
            make.left.equalTo(17)
            make.right.equalTo(-17)
        }
        
        stackView.addArrangedSubview(muteStackView)
        muteStackView.addArrangedSubview(muteLabel)
        muteLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.centerX.equalToSuperview().offset(-25)
        }
        muteStackView.addArrangedSubview(muteSwitch)
        muteSwitch.isOn = viewmodel.isUnMute
        muteSwitch.addTarget(self, action: #selector(muteAction), for: .valueChanged)
        
        stackView.addArrangedSubview(cameraStackView)
        cameraStackView.addArrangedSubview(cameraLabel)
        cameraLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.centerX.equalToSuperview().offset(-25)
        }
        cameraStackView.addArrangedSubview(cameraSwitch)
        cameraSwitch.isOn = viewmodel.isOnCamera
        cameraSwitch.addTarget(self, action: #selector(cameraAction), for: .valueChanged)
        
        self.backBaseView.addSubview(joinBtn)
        joinBtn.snp.makeConstraints { make in
            make.bottom.equalTo(self.view).inset(TSBottomSafeAreaHeight)
            make.left.equalTo(17)
            make.right.equalTo(-17)
            make.height.equalTo(55)
        }
        
        
        //加入会议
        joinBtn.addAction {
            self.view.endEditing(true)
            if self.codeT.text?.count == 0 {
                //self.showError(message: "请输入会议码".localized)
                return
            }
            AuthorizeStatusUtils.checkAuthorizeStatusByType(type: .videoCall, viewController: self, completion: { [weak self] in
                DispatchQueue.main.async {
                    self?.joinMeetingApi(meetingNum: self?.codeT.text ?? "")
                }
            })
            
        }
        self.joinBtn.isEnabled = false
        codeT.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if textField.text?.count == 0 {
            self.joinBtn.isEnabled = false
            self.joinBtn.backgroundColor = UIColor(hex: 0xD1D1D1)
        }else{
            self.joinBtn.isEnabled = true
            self.joinBtn.backgroundColor = RLColor.main.red
        }
    }
    
    //后端接口加入会议- 会议记录
    func joinMeetingApi(meetingNum: String) {
        viewmodel.meetingNum = meetingNum
        pop = JoiningVC()
        pop?.show()
        viewmodel.joinMeetingApi(meetingNum: meetingNum) {[weak self] requestdata, error in
            guard let self = self else {
                return
            }
            
            if let model = requestdata {
                self.viewmodel.level = model.data.meetingLevel
                self.viewmodel.roomUuid = (model.data.roomUuid).stringValue
                self.viewmodel.meetingTimeLimit = model.data.meetingTimeLimit
                self.viewmodel.meetingMemberLimit = model.data.meetingMemberLimit
                self.viewmodel.startTime = (model.data.meetingInfo?.startTime ?? "").toInt()
                self.viewmodel.isPrivate = (model.data.meetingInfo?.isPrivate ?? 0) == 1 ? true : false
                self.quertMeetingKitAccountInfo()
            } else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
                    self.pop?.dismiss()
                }
                if let error = error as? NSError {
                    if error.code == 1012 {
                        print("会议不存在")
                        UIViewController.showBottomFloatingToast(with: "meeting_ended".localized, desc: "")
                    } else if error.code == 1013 {
                        UIViewController.showBottomFloatingToast(with: "meeeting_max_user_limit_reached".localized, desc: "")
                    } else {
                        UIViewController.showBottomFloatingToast(with: error.localizedDescription, desc: "")
                    }
                }
            }
            
            
        }
    }
    
    func quertMeetingKitAccountInfo(){
        let userUuid: String? = UserDefaults.standard.string(forKey: "MeetingKit-userUuid")
        let token: String? = UserDefaults.standard.string(forKey: "MeetingKit-userToken")
        if let userUuid = userUuid, let token = token {
            viewmodel.meetingkitLogin(username: userUuid, password: token) {[weak self] code, msg in
                if code == 0 {
                    print("NEMeetingKit登录成功")
                    self?.joinInMeeting()
                }else {
                    UIViewController.showBottomFloatingToast(with:  msg ?? "" , desc: "")
                }
            }
        }
    }
    
    ///加入会议
    func joinInMeeting() {
        
        viewmodel.joinInMeeting(meetingID: viewmodel.meetingNum, password: "") {[weak self] requestdata, code, msg in
            guard let self = self else {
                return
            }
            if code == 0 {
                if self.viewmodel.level == 0 {
                    self.startTimerHolder()
                }
            }
            else {
                UIViewController.showBottomFloatingToast(with:  msg ?? "" , desc: "")
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
                self.pop?.dismiss()
            }
        }
    }
    
    
    func startTimerHolder(){
        if self.timer != nil {
            self.timeView?.removeFromSuperview()
            self.timer?.stopTimer()
        }
        let now = Date().timeIntervalSince1970
       
        let dt = Int(now) - viewmodel.startTime / 1000
        
        viewmodel.duration = viewmodel.meetingTimeLimit * 60 - dt
        self.timer = TimerHolder()
        self.timer?.startTimer(seconds: 1, delegate: self, repeats: true)
        self.showTimeView()
    }
    
    
    func showTimeView(){
        guard let vc = UIViewController.topMostController  else {
            return
        }
        let nimute = viewmodel.duration / 60
        let s = viewmodel.duration % 60
        let nim = String(format: "%02d", nimute)
        let ss = String(format: "%02d", s)
        timeView = UIView()
        timeView?.backgroundColor = UIColor(red: 0.93, green: 0.13, blue: 0.13, alpha: 1)
        timeView?.layer.cornerRadius = 10
        timeView?.clipsToBounds = true
        vc.view.addSubview(timeView!)
        timeView?.isHidden = true
        timeLabel = UILabel()
        let timeStr = "\(nim):\(ss)"
        timeLabel?.text = String(format: "meeting_end_in_ios".localized, timeStr)
        timeLabel?.textColor = .white
        timeLabel?.font = UIFont.systemFont(ofSize: 15)
        timeLabel?.textAlignment = .center
        timeView?.addSubview(timeLabel!)
        timeView?.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.top.equalTo(26 + TSNavigationBarHeight)
            
        }
        timeLabel?.snp.makeConstraints { make in
            make.left.top.equalTo(3)
            make.right.bottom.equalTo(-3)
            make.height.equalTo(24)
        }
        
    }
    
    @objc func muteAction(mySwitch: UISwitch) {
        if mySwitch.isOn {
            viewmodel.isUnMute = true
        } else {
            viewmodel.isUnMute = false
        }
    }
    
    @objc func cameraAction(mySwitch: UISwitch) {
        if mySwitch.isOn {
            viewmodel.isOnCamera = true
        } else {
            viewmodel.isOnCamera = false
        }
    }

}

extension TGJoinMeetingViewController: TimerHolderDelegate {
    func onTimerFired(holder: TimerHolder) {
        if viewmodel.duration > 0 {
            viewmodel.duration = viewmodel.duration - 1
            let nimute = viewmodel.duration / 60
            let s = viewmodel.duration % 60
            let nim = String(format: "%02d", nimute)
            let ss = String(format: "%02d", s)
            let timeStr = "\(nim):\(ss)"
            timeLabel?.text = String(format: "meeting_end_in_ios".localized, timeStr)
            if viewmodel.duration <= 5 * 60 {
                self.timeView?.isHidden = false
            }
        }else {
            self.timer?.stopTimer()
            let window = UIApplication.shared.keyWindow
            let bgView = MeetingEndView()
            bgView.backgroundColor = .black.withAlphaComponent(0.2)
            window?.addSubview(bgView)
            bgView.bindToEdges()
            bgView.okAction = {
                bgView.isHidden = true
                bgView.removeFromSuperview()
                self.timeView?.isHidden = true
                self.timeView?.removeFromSuperview()
                self.viewmodel.leaveMeetingRoom()
                
            }
        }
        
    }
    
    
}


class JoiningVC: UIView {
    
    let alertView: UIView = UIView()
    lazy var titleL: UILabel = {
        let lab = UILabel()
        lab.text = "meeting_joining_meeting".localized
        lab.textColor = .black
        lab.font = UIFont.systemRegularFont(ofSize: 12)
        lab.textAlignment = .center
        lab.numberOfLines = 0
        return lab
    }()

    
    init(){
        super.init(frame: .zero)
        self.initialUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialUI() {
        self.backgroundColor = UIColor.clear
        let coverBtn = UIView()
        self.addSubview(coverBtn)
        coverBtn.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        coverBtn.addAction {
            //self.dismiss(animated: false)
        }
        coverBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        self.addSubview(alertView)
        alertView.clipsToBounds = true
        alertView.layer.cornerRadius = 10
        alertView.backgroundColor = UIColor.white
        alertView.snp.makeConstraints { (make) in
            make.height.equalTo(55)
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(51)
        }
        let layer0 = CALayer()
        layer0.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        layer0.shadowOpacity = 1
        layer0.shadowRadius = 10
        layer0.shadowOffset = CGSize(width: 0, height: 4)
        alertView.layer.addSublayer(layer0)
    
        alertView.addSubview(titleL)
        titleL.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(30)
            make.top.equalTo(9)
        }

    }
    
    func show(){
        let window = UIApplication.shared.windows.first
        window?.addSubview(self)
        self.bindToEdges()
    }
    
    func dismiss(){
        self.removeFromSuperview()
    }
}

extension TGJoinMeetingViewController: TGJoinMeetingViewModelDelegate {
    func leaveMeetingRoom() {
        self.timer?.stopTimer()
        self.timeView?.removeFromSuperview()
    }
    
    
}
