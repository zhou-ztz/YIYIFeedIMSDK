//
//  TGMessageRequestListController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/13.
//

import UIKit
import NIMSDK

class TGMessageRequestListController: TGViewController {
    
    var currentIndex = 0
    var viewmodel: TGMessageRequestViewmodel!
    
    var sliderView: TGMessageSliderView!
    
    var temRequestList: [TGMessageRequestModel] = []
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    lazy var tableView: RLTableView = {
        let tb = RLTableView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 0), style: .plain)
        tb.register(TGMessageRequestCell.self, forCellReuseIdentifier: TGMessageRequestCell.cellReuseIdentifier)
        tb.showsVerticalScrollIndicator = false
        tb.separatorStyle = .none
        tb.delegate = self
        tb.dataSource = self
        tb.backgroundColor = .white
        return tb
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewmodel = TGMessageRequestViewmodel()
        viewmodel.delegate = self
        commitUI()
    }
    
    func commitUI(){
        self.customNavigationBar.backItem.setTitle("message_request_title".localized, for: .normal)
        let tabs = [TabHeaderdModal(titleString: "rw_text_individual".localized, messageCount: 0, bubbleColor: RLColor.share.theme, isSelected: true), TabHeaderdModal(titleString: "group_invitation_title".localized, messageCount: 0, bubbleColor: RLColor.share.theme, isSelected: false)]
        sliderView = TGMessageSliderView(frame: .zero, tabs: tabs)
        sliderView.isCanSlider = true
        backBaseView.addSubview(contentStackView)
        contentStackView.bindToEdges()
        contentStackView.addArrangedSubview(sliderView)
        contentStackView.addArrangedSubview(tableView)
        sliderView.snp.makeConstraints { make in
            make.left.right.top.equalTo(0)
            make.height.equalTo(40)
        }
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
        }
       
        sliderView.selectCallBack = {[weak self] index in
            self?.currentIndex = index
            self?.tableRefresh()
        }
        tableView.mj_header = SCRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = SCRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.mj_footer.isHidden = true
        loadData()
    }
    
    func loadData() {
        let group = DispatchGroup()
        group.enter()
        viewmodel.getRequestList {[weak self] requestList, error in
            self?.temRequestList = requestList ?? []
            group.leave()
        }
        group.enter()
        viewmodel.getTeamJoinActions { error in
            group.leave()
        }
        group.notify(queue: DispatchQueue.global()) { [weak self] in
            self?.tableRefresh()
        }
    }
    
    @objc func refresh() {
        if currentIndex == 0 {
            viewmodel.getRequestList {[weak self] requestList, error in
                self?.temRequestList = requestList ?? []
                self?.tableRefresh()
            }
        } else {
            viewmodel.getTeamJoinActions {[weak self] error in
                self?.tableRefresh()
            }
        }
    }
    
    @objc func loadMore() {
        if currentIndex == 0 {
            viewmodel.getRequestList(isRefresh: false) {[weak self] requestList, error in
                DispatchQueue.main.async {
                    self?.tableRefresh()
                }
            }
        } else {
            viewmodel.getTeamJoinActions(isRefresh: false) {[weak self] error in
                DispatchQueue.main.async {
                    self?.tableRefresh()
                }
            }
        }
    }
    
    
    private func tableRefresh() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.makeVisible()
            if self.currentIndex == 0 {
                if self.viewmodel.requestList.count <= 0  {
                     self.tableView.show(placeholderView: .empty)
                } else {
                    self.tableView.removePlaceholderViews()
                    if self.temRequestList.count < self.viewmodel.limit {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.tableView.mj_footer.endRefreshing()
                    }
                }
            } else {
                if self.viewmodel.filterNotifications.count <= 0  {
                     self.tableView.show(placeholderView: .empty)
                } else {
                    self.tableView.removePlaceholderViews()
                    if self.viewmodel.teamFinished {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.tableView.mj_footer.endRefreshing()
                    }
                    
                }
            }
            
            self.sliderView.updateUnreadCount(count: self.viewmodel.requestList.count, index: 0)
            self.sliderView.updateUnreadCount(count: self.viewmodel.filterNotifications.count, index: 1)
            self.tableView.reloadData()
        }
        
    }
    
    func showAlert(isAccept: Bool, isGroup: Bool, name: String, indexPath: IndexPath){
        let view = TGMessageRequestActionView(isAccept: isAccept, isGroup: isGroup, name: name)
        let popup = TGAlertController(style: .popup(customview: view), hideCloseButton: true)
        
        view.alertButtonClosure = {
            if isGroup {
                let notification = self.viewmodel.filterNotifications[indexPath.row]
                
                if isAccept {
                    self.acceptGroupInvitation(indexPath: indexPath, notification: notification)
                } else {
                    self.rejectGroupInvitaton(indexPath: indexPath, notification: notification)
                }
            } else {
               
                let messageModel = self.viewmodel.requestList[indexPath.row]
                if isAccept {
                    self.acceptFriendRequest(data: messageModel)
                } else {
                    self.rejectFriendRequest(data: messageModel)
                }
            }
            popup.dismiss()
        }
        
        view.cancelButtonClosure = {
            popup.dismiss()
        }
        
        self.present(popup, animated: false)
    }
    func acceptFriendRequest(data: TGMessageRequestModel) {
        viewmodel.acceptFriendRequest(data: data) {[weak self] error in
            DispatchQueue.main.async {
                self?.refresh()
            }
        }
    }
    
    func rejectFriendRequest(data: TGMessageRequestModel) {
        viewmodel.rejectFriendRequest(data: data) {[weak self] error in
            DispatchQueue.main.async {
                self?.refresh()
            }
        }
    }
    
    func acceptGroupInvitation(indexPath: IndexPath, notification: V2NIMTeamJoinActionInfo) {
        viewmodel.acceptGroupInvitation(notification: notification) {[weak self] error in
            if error == nil {
                self?.viewmodel.filterNotifications.remove(at: indexPath.row)
                self?.tableRefresh()
            }
        }
    }
    
    func rejectGroupInvitaton(indexPath: IndexPath, notification: V2NIMTeamJoinActionInfo) {
        viewmodel.rejectGroupInvitaton(notification: notification) {[weak self] error in
            if error == nil {
                self?.viewmodel.filterNotifications.remove(at: indexPath.row)
                self?.tableRefresh()
            }
        }
    }
    
}


extension TGMessageRequestListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentIndex == 0 {
            return viewmodel.requestList.count
        }

        return viewmodel.filterNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TGMessageRequestCell.cellReuseIdentifier) as! TGMessageRequestCell
        cell.delegate = self
        cell.indexPath = indexPath
        if currentIndex == 0 {
            let messageData = viewmodel.requestList[indexPath.row]
            cell.updatePersonalCell(data: messageData)
        } else {
            let messageData = viewmodel.filterNotifications[indexPath.row]
            cell.updateGroupCell(data: messageData)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension TGMessageRequestListController: TGMessageRequestCellDelegate {
    func buttonActionDelegate(isAccept: Bool, indexPath: IndexPath) {
        let isGroup = currentIndex == 1
        var name: String = ""

        if isGroup {
            if let noti = viewmodel.filterNotifications[safe: indexPath.row] {
                MessageUtils.getTeamInfo(teamId: noti.teamId, teamType: noti.teamType) {[weak self] team in
                    if let team = team {
                        name = team.name
                        self?.showAlert(isAccept: isAccept, isGroup: true, name: name, indexPath: indexPath)
                    }
                }
                
            }
        } else {
            if let messageModel = viewmodel.requestList[safe: indexPath.row] {
                name = messageModel.user?.name ?? ""
                self.showAlert(isAccept: isAccept, isGroup: false, name: name, indexPath: indexPath)
            }
        }
    }
    
    
}
// MARK: TGMessageRequestViewmodeldelete
extension TGMessageRequestListController: TGMessageRequestViewmodeldelete {
    func onReceive(_ joinActionInfo: V2NIMTeamJoinActionInfo) {
        DispatchQueue.main.async {
            self.tableRefresh()
        }
    }
    
    
}
