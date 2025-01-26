//
//  TGMeetingSettingViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/22.
//

import UIKit
import NIMSDK
import NEMeetingKit

class TGMeetingSettingViewController: TGViewController {
    let viewmodel = TGMeetingSettingViewModel()
    lazy var nextBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("done".localized, for: .normal)
        btn.setTitleColor(TGAppTheme.red, for: .normal)
        btn.titleLabel?.font = UIFont.systemMediumFont(ofSize: 17)
        return btn
    }()
    
    lazy var numL: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor(hex: "#212121")
        lab.font = UIFont.systemMediumFont(ofSize: 17)
        lab.textAlignment = .left
        lab.text = "Invited (15)".localized
        return lab
    }()
    
    var backStackView: UIStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.spacing = 16
        $0.distribution = .fill
        $0.alignment = .leading
    }
    var stackView: UIStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.spacing = 16
        $0.distribution = .fill
        $0.alignment = .leading
    }
    
    var passwordT: UITextField?
    var microphone: UISwitch!
    var camera: UISwitch!
    var priviteInvite: UISwitch!

    var meetingNameT: UITextField!
    
    var timer: TimerHolder?
    
    var roomUuid: Int = 0
    //记录 toast 是否弹出
    var leftNumber = false
    var maxNumber = false
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(MeetingSettingCell.self, forCellReuseIdentifier: "MeetingSettingCell")
        table.separatorStyle = .none
        table.backgroundColor = .white
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 73
        table.tableFooterView = UIView()
        table.tableHeaderView = UIView()
        return table
    }()
    var timeView: UIView?
    var timeLabel:  UILabel?
    //会议信息
    var meetingInfo: CreateMeetingInfo?
    var noAudio: Bool = false
    var noVideo: Bool = false
    
    init(data: [ContactData]) {
        self.viewmodel.dataSource = data
        super.init(nibName: nil, bundle: nil)
       
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.backItem.setTitle("dashboard_settings".localized, for: .normal)
        setUI()
        viewmodel.delegate = self
    }
    
    deinit {
        self.timer?.stopTimer()
        self.timeView?.removeFromSuperview()
    }

    func setUI(){
        let num = viewmodel.dataSource.count
        numL.text = String(format: "invited_ios".localized, "(\(num))")
        nextBtn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        self.customNavigationBar.setRightViews(views: [nextBtn])

        backBaseView.addSubview(backStackView)
        backStackView.bindToEdges()
        
        backStackView.addArrangedSubview(stackView)
        backStackView.addArrangedSubview(numL)
        backStackView.addArrangedSubview(tableView)
        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
        }
        numL.snp.makeConstraints { make in
            make.left.equalTo(16)
        }
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        let nameView = self.createMeetingNameView()
        stackView.addArrangedSubview(nameView)
        nameView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview().inset(16)
            make.height.equalTo(68)
        }
        
        let view1 = createSettingView(title: "password".localized, tagT: 101, isTextField: true, tag: 0)
        let view2 = createSettingView(title: "microphone".localized, tagT: 0, isTextField: false, tag: 102)

        let view3 = createSettingView(title: "camera".localized, tagT: 0, isTextField: false, tag: 103)
        if let textF = view1.viewWithTag(101) as? UITextField {
            passwordT = textF
            //passwordT?.keyboardType = .numberPad
        }
        passwordT?.placeholder = "Not Set".localized
        if let switchview = view2.viewWithTag(102) as? UISwitch {
            microphone = switchview
            microphone.isOn = true
            noAudio = false
            microphone.addTarget(self, action: #selector(clickOnMicrophone(_:)), for: .valueChanged)
        }
        if let switchview = view3.viewWithTag(103) as? UISwitch {
            camera = switchview
            camera.isOn = false
            noVideo = true
            camera.addTarget(self, action: #selector(clickOnCamera(_:)), for: .valueChanged)
        }
        
        stackView.addArrangedSubview(view1)
        stackView.addArrangedSubview(view2)
        stackView.addArrangedSubview(view3)
        
        let view4 = createSettingView(title: "meeting_private_invite".localized, tagT: 0, isOn: true, isTextField: false, tag: 104, content: "meeting_invite_invite_tip".localized)
        stackView.insertArrangedSubview(view4, at: 3)
        view4.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(68)
        }
        if let switchview = view4.viewWithTag(104) as? UISwitch {
            priviteInvite = switchview
            priviteInvite.addTarget(self, action: #selector(clickOnInvite(_:)), for: .valueChanged)
        }
        view4.isHidden = viewmodel.meetingLevel != 1
        priviteInvite.isOn = viewmodel.meetingLevel == 1

        view1.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(68)
        }
        view2.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(68)
        }
        view3.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(4)
            make.height.equalTo(68)
        }
        
        if self.meetingNameT.text?.count == 0 {
            self.nextBtn.isEnabled = false
            self.nextBtn.setTitleColor(.lightGray, for: .normal)
        }else{
            self.nextBtn.isEnabled = true
            self.nextBtn.setTitleColor(TGAppTheme.red, for: .normal)
        }
        
    }
    
    func createMeetingNameView() -> UIView {
        let bview = UIView()
        bview.backgroundColor = UIColor(hexString: "#F7F8FA")
        bview.layer.cornerRadius = 10
        bview.clipsToBounds = true
        
        meetingNameT = UITextField()
        meetingNameT.placeholder = "meeting_subject".localized
        meetingNameT.textColor = UIColor(hexString: "#808080")
        meetingNameT.font = UIFont.systemFont(ofSize: 14)
        bview.addSubview(meetingNameT)
        meetingNameT.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
            make.right.equalTo(-20)
            make.height.equalTo(24)
        }
        meetingNameT.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        return bview
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.count == 0 {
            self.nextBtn.isEnabled = false
            self.nextBtn.setTitleColor(.lightGray, for: .normal)
        }else{
            self.nextBtn.isEnabled = true
            self.nextBtn.setTitleColor(TGAppTheme.red, for: .normal)
        }
    }
    
    func createSettingView(title: String, tagT: Int, isOn: Bool = false, isTextField: Bool = false, tag: Int, content: String = "") -> UIView{

        let bview = UIView()
        bview.backgroundColor = UIColor(hexString: "#F7F8FA")
        bview.layer.cornerRadius = 10
        bview.clipsToBounds = true

        let stackview = UIStackView()
        stackview.spacing = 0
        stackview.axis = .vertical
        stackview.distribution = .fill
        bview.addSubview(stackview)
        stackview.snp.makeConstraints { make in
            make.left.equalTo(13)
            make.centerY.equalToSuperview()
        }

        let nameLabel = UILabel()
        nameLabel.textColor = .black
        nameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        nameLabel.textAlignment = NSTextAlignment.left
        nameLabel.text = title

       // bview.addSubview(nameLabel)
        stackview.addArrangedSubview(nameLabel)
        
        if tag == 104 {
            let contentL = UILabel()
            contentL.textColor = .black
            contentL.font = UIFont.systemRegularFont(ofSize: 10)
            contentL.textAlignment = NSTextAlignment.left
            contentL.text = content
            stackview.addArrangedSubview(contentL)
            contentL.snp.makeConstraints { make in
                make.height.equalTo(15)
            }
        }

        let textField = UITextField()
        textField.textColor = UIColor(hexString: "#808080")
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.textAlignment = .right
        textField.tag = tagT
        bview.addSubview(textField)
        textField.isHidden = !isTextField
        textField.isSecureTextEntry = true
        textField.keyboardType = .numberPad
        let switchB = UISwitch()
        switchB.tag = tag
        switchB.isOn = isOn
        switchB.tintColor = UIColor(hexString: "#C7C7C7")
        switchB.onTintColor = UIColor(hexString: "#69EC9D")
        if isOn {
            switchB.thumbTintColor = UIColor(hexString: "#0F7D56")
        }else{
            switchB.thumbTintColor = UIColor(hexString: "#808080")
        }
        
        bview.addSubview(switchB)
        switchB.isHidden = isTextField
        nameLabel.snp.makeConstraints { make in
            make.height.equalTo(21)

        }
        
        textField.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
            make.width.equalTo(150)
        }
        switchB.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(25)
        }
        
        return bview
    }
    
    @objc func nextAction(){
        self.view.endEditing(true)
        if meetingNameT.text?.count == 0 {
            return
        }
        AuthorizeStatusUtils.checkAuthorizeStatusByType(type: .videoCall, viewController: self, completion: {[weak self] in
            DispatchQueue.main.async {
                self?.quertMeetingKitAccountInfo()
            }
        })
  
    }
    
    func quertMeetingKitAccountInfo(){
        let userUuid: String? = UserDefaults.standard.string(forKey: "MeetingKit-userUuid")
        let token: String? = UserDefaults.standard.string(forKey: "MeetingKit-userToken")
        if let userUuid = userUuid, let token = token {
            viewmodel.meetingkitLogin(username: userUuid, password: token) {[weak self] code, msg in
                if code == 0 {
                    print("NEMeetingKit登录成功")
                    self?.createMeeting()
                }else {
                    //  self?.showError(message: msg ?? "")
                }
            }
        }
    }
    
    func createMeeting() {
        let password = passwordT?.text ?? ""
        let name = meetingNameT.text ?? ""
        let isPrivite = priviteInvite.isOn
        viewmodel.createMeeting(meetingName: name, password: password, priviteInvite: isPrivite) {[weak self] requestdata, error in
            DispatchQueue.main.async {
                if let data = requestdata {
                    self?.viewmodel.meetingId = data.data.meetingId
                    self?.viewmodel.meetingNum = data.data.meetingNum
                    self?.viewmodel.meetingInfo = data.data
                    self?.joinMeetingApi(meetingNum: self?.viewmodel.meetingNum ?? "", data: data.data)
                }
            }
        }
    }
    
    func joinMeetingApi(meetingNum: String, data: CreateMeetingInfo) {
        viewmodel.joinMeetingApi(meetingNum: meetingNum, data: data) {[weak self] model, error in
            if let model = model {
                self?.viewmodel.roomUuid = model.data.roomUuid
                self?.viewmodel.startTime = (model.data.meetingInfo?.startTime ?? "").toInt()
                self?.viewmodel.meetingTimeLimit = model.data.meetingTimeLimit
                DispatchQueue.main.async {
                    let isPrivate: Bool = (model.data.meetingInfo?.isPrivate ?? 0) == 1 ? true : false
                    self?.joinInMeeting(data: data, isPrivate: isPrivate)
                }
            }
            if let error = error {
                
            }
        }
    }
    
    func joinInMeeting(data: CreateMeetingInfo, isPrivate: Bool = false) {
        guard let meetingID = viewmodel.meetingNum else {
           
            return
        }
        viewmodel.joinInMeeting(meetingID: meetingID, password: passwordT?.text ?? "", noVideo: noVideo, noAudio: noAudio, data: data, isPrivate: isPrivate) {[weak self] requestdata, code, msg in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                if code == 0 {
                    print("会议加入成功")
                    self.leftNumber = false
                    self.maxNumber = false
                    if self.viewmodel.meetingLevel == 0 {
                        self.startTimerHolder()
                    }
                    self.viewmodel.sendMessage(model: data)
                    self.viewmodel.addNeRoomListener()
                    
                } else {
                  //  self.showError(message: resultMsg ?? "")
                }
            }
        }
    }
    
    @objc func clickOnMicrophone(_ sender: UISwitch){
        if sender.isOn {
            noAudio = false
            sender.thumbTintColor = UIColor(hexString: "#0F7D56")
        }else{
            noAudio = true
            sender.thumbTintColor = UIColor(hexString: "#808080")
        }
        
    }
    @objc func clickOnCamera(_ sender: UISwitch){
        if sender.isOn {
            noVideo = false
            sender.thumbTintColor = UIColor(hexString: "#0F7D56")
        }else{
            noVideo = true
            sender.thumbTintColor = UIColor(hexString: "#808080")
        }
    }

    @objc func clickOnInvite(_ sender: UISwitch){
        if sender.isOn {
            sender.thumbTintColor = UIColor(hexString: "#0F7D56")
        }else{
            sender.thumbTintColor = UIColor(hexString: "#808080")
        }
    }
    
    func showMemberNum(isLeft: Bool = true){
        guard let vc = UIViewController.topMostController  else {
            return
        }
        if isLeft {
           // vc.view.makeToast(String(format: "meeting_left_participants_ios".localized, "5"), duration: 3, position: CSToastPositionBottom)
        }else{
          //  vc.view.makeToast(String(format: "meeting_maximum_members_reached_ios".localized, "\(self.meetingNumlimit)"), duration: 3, position: CSToastPositionBottom)
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
        
        timeView = UIView()
        timeView?.backgroundColor = UIColor(red: 0.93, green: 0.13, blue: 0.13, alpha: 1)
        timeView?.layer.cornerRadius = 10
        timeView?.clipsToBounds = true
        vc.view.addSubview(timeView!)
        timeView?.isHidden = true
        timeLabel = UILabel()
        let nim = String(format: "%02d", nimute)
        let ss = String(format: "%02d", s)
        
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


}

extension TGMeetingSettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingSettingCell", for: indexPath) as! MeetingSettingCell
        cell.selectionStyle = .none
        cell.setData(model: viewmodel.dataSource[indexPath.row])
        return cell
    }
    
}
extension TGMeetingSettingViewController: TimerHolderDelegate {
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
extension TGMeetingSettingViewController: TGMeetingSettingViewModelDelegate {
    func leaveMeetingRoom() {
        self.timer?.stopTimer()
        self.timeView?.removeFromSuperview()
        DispatchQueue.main.asyncAfter(deadline: Dispatch.DispatchTime.now() + 0.2){
            if let nav = self.navigationController {
                for vc in nav.viewControllers {
                    if vc.isKind(of: TGMeetingListViewController.self) {
                        self.navigationController?.popToViewController(vc, animated: false)
                    }
                }
            }
        }
    }
    
    func updateMemberRoom() {
        viewmodel.getCurrentMeetingInfo {[weak self] meetingInfo in
            guard let self = self, let info = meetingInfo else { return }
            DispatchQueue.main.async {
                if info.userList.count == self.viewmodel.meetingNumlimit - 5 {
                    if self.leftNumber == false{
                        self.showMemberNum()
                    }
                    self.leftNumber = true
                }else if info.userList.count == self.viewmodel.meetingNumlimit{
                    if self.maxNumber == false{
                        self.showMemberNum(isLeft: false)
                    }
                    self.maxNumber = true
                }
            }
        }
    }
    
    
}
