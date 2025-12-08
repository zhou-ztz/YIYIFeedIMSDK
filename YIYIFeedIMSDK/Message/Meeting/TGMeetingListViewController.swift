//
//  TGMeetingListViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/22.
//

import UIKit

class TGMeetingListViewController: TGViewController {

    var newMeeting: UIButton!
    var joinMeeting: UIButton!
    var offset: Int = 1
    let contentStackView: UIStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.spacing = 2
        $0.distribution = .fill
    }
    
    let stackView: UIView = UIView().configure {
        $0.backgroundColor = .white
       
    }
    
    //空白填充view
    let fillView: UIView = UIView().configure {
        $0.backgroundColor = .white
    }
    
    lazy var tableView: RLTableView = {
        let tb = RLTableView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 0), style: .plain)
        tb.rowHeight = 74
        tb.register(MeetingListViewCell.self, forCellReuseIdentifier: MeetingListViewCell.cellIdentifier)
        tb.showsVerticalScrollIndicator = false
        tb.separatorStyle = .none
        tb.delegate = self
        tb.dataSource = self
        tb.backgroundColor = .white
        return tb
    }()
    
    var dataSouce: [QuertMeetingListDetailModel]?
    var payInfo:PayInfo?
    
    var payInfoVC: TGMeetingVarietyViewController?
    
    var infoVC: MeetingPayinfoView?
    
    var isFrist = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.backItem.setTitle("meeting_kit".localized, for: .normal)
        setUI()
        tableView.mj_header.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMeetingPayInfo()
    }
    
    @objc func initData(){
        offset = 1
        TGIMNetworkManager.getMeetingList(page: "\(offset)") {[weak self] resultModel, error in
            self?.tableView.mj_header.endRefreshing()
            guard let self = self else { return }
            if let error = error {
                UIViewController.showBottomFloatingToast(with:  error.localizedDescription , desc: "")
                self.tableView.show(placeholderView: .network)
            }else {
                if let datas = resultModel?.data {
                    self.dataSouce = datas.data
                    self.tableView.removePlaceholderViews()
                    if (datas.data?.count ?? 0) < 15 {
                        if (datas.data?.count ?? 0) == 0{
                            self.tableView.show(placeholderView: .empty)
                        }
                        self.tableView.mj_footer.makeVisible()
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.tableView.mj_footer.makeVisible()
                        self.tableView.mj_footer.endRefreshing()
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }

    }
    
    @objc func loadMoreFriends(){
        offset = offset + 1
        self.tableView.mj_footer.makeVisible()
        TGIMNetworkManager.getMeetingList(page: "\(offset)") {[weak self] resultModel, error in
            self?.tableView.mj_header.endRefreshing()
            guard let self = self else { return }
            if let _ = error {
                self.tableView.mj_footer.endRefreshing()
                self.tableView.show(placeholderView: .network)
            } else {
                if let datas = resultModel?.data {
                    self.dataSouce = (self.dataSouce ?? []) + (datas.data ?? [])
                    if (datas.data?.count ?? 0) < 15 {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.tableView.mj_footer.endRefreshing()
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }
            }
        }
        
    }
    
    func getMeetingPayInfo(){
        TGIMNetworkManager.quertUserMeetingPayInfo {[weak self] model, error in
            DispatchQueue.main.async {
                if let model = model {
                    self?.payInfo = model.data
                    if self?.payInfo?.level == 1 {
                        self?.showPayInfoView()
                        self?.isFrist = false
                    }
                }
            }
        }

    }

    func setUI(){
        backBaseView.addSubview(contentStackView)
        contentStackView.bindToEdges()
        contentStackView.addArrangedSubview(fillView)
        fillView.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        
        let myMeeting = UILabel()
        myMeeting.textColor = UIColor(red: 0.129, green: 0.129, blue: 0.129, alpha: 1)
        myMeeting.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
        myMeeting.text = "meeting_my_meeting".localized
        contentStackView.addArrangedSubview(myMeeting)
        myMeeting.snp.makeConstraints { make in
            make.height.equalTo(27)
            make.left.equalTo(16)
        }
        contentStackView.addArrangedSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
        }
        
        tableView.mj_header = SCRefreshHeader(refreshingTarget: self, refreshingAction: #selector(initData))
        tableView.mj_footer = SCRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreFriends))
        tableView.mj_footer.makeHidden()
        
        contentStackView.addArrangedSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            make.height.equalTo(47)
        }
        
        newMeeting = self.createMeetingButton(backColor: TGAppTheme.red, title: "new_meeting".localized)
        joinMeeting = self.createMeetingButton(backColor: UIColor(hex: "#EDEDED"), title: "join_meeting".localized, titleColor: .black)
        stackView.addSubview(newMeeting)
        stackView.addSubview(joinMeeting)
        newMeeting.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.width.equalTo((ScreenWidth - 56) / 2)
            make.height.equalTo(47)
        }
        joinMeeting.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.width.equalTo((ScreenWidth - 56) / 2)
            make.height.equalTo(47)
        }
        newMeeting.addTarget(self, action: #selector(createMeetingAction), for: .touchUpInside)
        joinMeeting.addTarget(self, action: #selector(joinMeetingAction), for: .touchUpInside)
    }
    
    func showPayInfoView(){
        if let info = self.payInfo {
            if isFrist {
                fillView.snp.makeConstraints { make in
                    make.height.equalTo(10)
                }
                infoVC = MeetingPayinfoView(frame: .zero, payInfo: info)
                contentStackView.insertArrangedSubview(infoVC!, at: 0)
            }else {
                infoVC?.setTitleInfo(payInfo: info)
            }
            
        }
    }
    
    //创建会议
    @objc func createMeetingAction(){
        guard let payInfo = self.payInfo else {
            if !(TGReachability.share.isReachable()) {
                UIViewController.showBottomFloatingToast(with: "network_is_not_available".localized, desc: "")
            }else{
                getMeetingPayInfo()
            }
            return
        }

        if payInfo.level == 1 {
            let vc = TGCreateMeetingViewController()
            vc.meetingLevel = payInfo.level
            vc.meetingNumlimit =  payInfo.vipMeetingMemberLimit.toInt()
            vc.duration =  0
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        guard let rootVC = UIApplication.topViewController() else {
            return
        }
        
        let vc = TGMeetingVarietyViewController()
        vc.payInfo = payInfo
        vc.view.frame = rootVC.view.bounds
        rootVC.view.addSubview(vc.view)
        rootVC.addChild(vc)
        vc.didMove(toParent: rootVC)
        payInfoVC = vc
        vc.starBackCall = { tag in
            if tag == 100 {
                self.payInfoVC?.dismiss()
                self.payInfoVC = nil
                let vc1 = TGCreateMeetingViewController()
                vc1.meetingLevel = 0
                vc1.meetingNumlimit = payInfo.freeMemberLimit.toInt()
                vc1.duration = payInfo.freeTimeLimit.toInt()
                self.navigationController?.pushViewController(vc1, animated: true)
                
            }else{
                RLSDKManager.shared.imDelegate?.showPin(type: .purchase, {[weak self] pin in
                    self?.meetingPay(pin: pin)
                }, cancel: nil, needDisplayError: false)
            }
        }
    }
    
    //加入会议
    @objc func joinMeetingAction(){
        let vc = TGJoinMeetingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func createMeetingButton(backColor: UIColor, title: String, titleColor: UIColor = .white) -> UIButton{
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(titleColor, for: .normal)
        btn.backgroundColor = backColor
        btn.layer.cornerRadius = 10
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.clipsToBounds = true
        return btn
    }
    
    func meetingPay(pin: String) {
        TGIMNetworkManager.meetingPayment(pin: pin) {[weak self] requestdata, error, statusCode in
            guard let self = self, let rootVC = UIApplication.topViewController() else { return }
            if let error = error {
                self.payInfoVC?.dismiss()
                self.payInfoVC = nil
                RLSDKManager.shared.imDelegate?.dismissPin()
                UIViewController.showBottomFloatingToast(with: error.localizedDescription, desc: "")
                
            } else if let statusCode = statusCode {
                if statusCode == 409 {
                    if UserDefaults.biometricEnabled {
                        UserDefaults.biometricEnabled = false
                        let view = TGCancelPopView(isInvalidPin: true)
                        let popup = TGAlertController(style: .popup(customview: view), hideCloseButton: true)
                        view.alertButtonClosure = {
                            popup.dismiss {
                                RLSDKManager.shared.imDelegate?.showPin(type: .purchase, {[weak self] pin in
                                    self?.meetingPay(pin: pin)
                                }, cancel: nil, needDisplayError: false)
                            }
                        }
                        rootVC.present(popup, animated: false)
                        
                    } else {
                        RLSDKManager.shared.imDelegate?.showPinError(message: error?.localizedDescription ?? "")
                    }
                }
            }
            else {
                guard let model = requestdata else { return }
                switch model.code {
                case 1007:
                    RLSDKManager.shared.imDelegate?.dismissPin()
                    let lView = MeetingPayView(frame:CGRect(x: 0, y: 0, width: 0, height: 0), isSucceed: true, time: model.data?.expiredAt ?? "")
                    let popup = TGAlertController(style: .popup(customview: lView), hideCloseButton: true, allowBackgroundDismiss: false)
                    
                    lView.okBtnClosure = {
                        self.payInfoVC?.dismiss()
                        self.payInfoVC = nil
                        self.getMeetingPayInfo()
                        popup.dismiss()
                    }
                    popup.modalPresentationStyle = .overFullScreen
                    rootVC.present(popup, animated: false)
                case 1008, 1005, 1006, 1003:
                    RLSDKManager.shared.imDelegate?.dismissPin()
                    let lView = MeetingPayView(frame:CGRect(x: 0, y: 0, width: 0, height: 0), isSucceed: false, time: "")
                    let popup = TGAlertController(style: .popup(customview: lView), hideCloseButton: true, allowBackgroundDismiss: false)
                    
                    lView.okBtnClosure = {
                        popup.dismiss()
                    }
                    popup.modalPresentationStyle = .overFullScreen
                    rootVC.present(popup, animated: false)
                default:
                    RLSDKManager.shared.imDelegate?.showPinError(message: model.message)
                    break
                }
            }
        }

    }
}

extension TGMeetingListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSouce?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MeetingListViewCell.cellIdentifier, for: indexPath) as! MeetingListViewCell
        cell.setData(model: self.dataSouce?[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}
