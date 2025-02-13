//
//  TGCreateMeetingViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/22.
//

import UIKit

///会议最多邀请人数
let meetingMaxNum: Int = 120

class TGCreateMeetingViewController: NewContactsViewController {

    ///会议邀请人数
    var meetingNum: Int = 0
    //会议等级 0 免费 1 付过年费
    var meetingLevel: Int = 0
    //会议时长
    var duration: Int = 0
    //会议最高人数
    var meetingNumlimit: Int = 50
    
    lazy var nextBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("next".localized, for: .normal)
        btn.setTitleColor(TGAppTheme.red, for: .normal)
        btn.titleLabel?.font = UIFont.systemMediumFont(ofSize: 17)
        return btn
    }()
    
    lazy var meetNumL: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor(hex: "#86909C")
        lab.font = UIFont.systemRegularFont(ofSize: 12)
        lab.textAlignment = .center
        return lab
    }()

    var groupStackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.spacing = 28
        $0.distribution = .fill
        $0.alignment = .center
    }
    
    lazy var groupImg: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "iconsNewGroup")
        img.contentMode = .scaleAspectFit
        img.image = img.image?.withRenderingMode(.alwaysTemplate)
        img.tintColor = .black
        return img
    }()
    
    lazy var groupL: UILabel = {
        let lab = UILabel()
        lab.textColor = .black
        lab.font = UIFont.boldSystemFont(ofSize: 15)
        lab.textAlignment = .left
        lab.text = "meeting_select_group".localized
        return lab
    }()

    lazy var searchTableView: RLTableView = {
        let table = RLTableView(frame: .zero, style: .plain)
        table.register(MeetingFriendsListCell.self, forCellReuseIdentifier: "MeetingFriendsListCell")
        table.separatorStyle = .none
        table.backgroundColor = .white
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 56
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.customNavigationBar.backItem.setTitle("new_meeting".localized, for: .normal)
        setUpUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setUpUI(){
        nextBtn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        self.customNavigationBar.setRightViews(views: [nextBtn])
        self.customNavigationBar.titleView = meetNumL
        meetingNum = choosedDataSource.count
        meetNumL.text = "\(meetingNum)/\(meetingMaxNum)"
        meetNumL.isHidden = true

        stackView.insertArrangedSubview(groupStackView, at: 2)
        groupStackView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.height.equalTo(43)
        }
        groupStackView.addArrangedSubview(groupImg)
        groupStackView.addArrangedSubview(groupL)
        groupL.addAction {
            self.groupAction()
        }

        searchTableView.isHidden = true
        self.backBaseView.addSubview(searchTableView)
        searchTableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom).offset(14)
        }
        searchTableView.mj_header = SCRefreshHeader(refreshingTarget: self, refreshingAction: #selector(searchkeyWordRefresh))
        searchTableView.mj_footer = SCRefreshFooter(refreshingTarget: self, refreshingAction: #selector(searchkeyWordloadMore))
        searchBar.delegate = self
        
        if choosedDataSource.count == 0 {
            nextBtn.isEnabled = false
            nextBtn.setTitleColor(.lightGray, for: .normal)
        }else{
            nextBtn.isEnabled = true
            nextBtn.setTitleColor(TGAppTheme.red, for: .normal)
        }
    }
    
    @objc func nextAction(){
       
        if isSearching {
            isSearching = false
            searchTableView.isHidden = true
        }else{
            if choosedDataSource.count == 0 {
//                showError(message: "请选择邀请成员".localized)
                return
            }
            let vc = TGMeetingSettingViewController(data: choosedDataSource)
            vc.viewmodel.meetingLevel = meetingLevel
            vc.viewmodel.duration = duration
            vc.viewmodel.meetingNumlimit = meetingNumlimit
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    //群组
    func groupAction(){
        let vc = TGMeetingGroupViewController()
        vc.choosedDataSource = choosedDataSource
        vc.meetingNumlimit = meetingNumlimit
        self.navigationController?.pushViewController(vc, animated: true)
        vc.comfirmCall = { data in
            self.choosedDataSource = data
            self.collectionView.isHidden = self.choosedDataSource.count == 0
            self.collectionView.reloadData()
            self.reloadNumberUI()
        }
    }
    override func reloadNumberUI(){
        meetingNum = choosedDataSource.count
        meetNumL.text = "\(meetingNum)/\(meetingMaxNum)"
        if choosedDataSource.count == 0 {
            nextBtn.isEnabled = false
            nextBtn.setTitleColor(.lightGray, for: .normal)
        }else{
            nextBtn.isEnabled = true
            nextBtn.setTitleColor(TGAppTheme.red, for: .normal)
        }
    }

    @objc func searchkeyWordRefresh(){
        searchOffset = 0
        TGNewFriendsNetworkManager.searchMyFriend(offset: searchOffset, keyWordString: keyword) {[weak self] usermodels, error in
            self?.searchTableView.mj_header.endRefreshing()
            guard let self = self else { return }
            if error != nil {
                // self.tableView.show(placeholderView: .network)
            } else {
                if let datas = usermodels {
                    let users = datas.compactMap {
                        ContactData(model: $0)
                    }

                    self.searchdDataSource = users
                    if self.searchdDataSource.isEmpty  {
                        //self.searchTableView.show(placeholderView: .empty)
                    } else {
                        self.searchTableView.removePlaceholderViews()
                    }
                    if datas.count < TGNewFriendsNetworkManager.limit {
                        self.searchTableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.searchTableView.mj_footer.endRefreshing()
                    }
                    self.searchOffset = datas.count
                    DispatchQueue.main.async {
                        self.searchTableView.reloadData()
                    }
                }
            }
        }
        
    }
    
    @objc func searchkeyWordloadMore(){
        searchOffset = searchOffset + 1
        
        TGNewFriendsNetworkManager.searchMyFriend(offset: searchOffset, keyWordString: keyword) {[weak self] userModels, error in
            self?.searchTableView.mj_footer.endRefreshing()
            guard let self = self else { return }
            if error != nil {
                self.searchTableView.mj_footer.endRefreshing()
                // self.searchTableView.show(placeholderView: .network)
            } else {
                if let datas = userModels {
                    self.searchOffset = self.searchOffset + datas.count
                    let users = datas.compactMap {
                        ContactData(model: $0)
                    }
                    self.searchdDataSource = self.searchdDataSource + users
                    if self.searchdDataSource.isEmpty  {
                       // self.searchTableView.show(placeholderView: .empty)
                    }
                    if datas.count < TGNewFriendsNetworkManager.limit {
                        self.searchTableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.searchTableView.mj_footer.endRefreshing()
                    }
                    DispatchQueue.main.async {
                        self.searchTableView.reloadData()
                    }
                }
            }
        }
        
    }
    
}

extension TGCreateMeetingViewController: MeetingSearchViewDelegate{
    func searchDidClickReturn(text: String) {
        self.searchBar.searchTextFiled.resignFirstResponder()
        keyword = text
        self.searchTableView.isHidden = false
        self.searchkeyWordRefresh()
        isSearching = !self.searchTableView.isHidden
    }
    
    func searchDidClickCancel() {
        self.searchBar.searchTextFiled.resignFirstResponder()
        self.searchTableView.isHidden = true
        isSearching = !self.searchTableView.isHidden
    }
}

extension TGCreateMeetingViewController{
    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.searchTableView {
            return 1
        }
        return indexDataSource.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchTableView {
            return self.searchdDataSource.count
        }
        return sortedModelArr[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.searchTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingFriendsListCell", for: indexPath) as! MeetingFriendsListCell
            cell.currentChooseArray = self.choosedDataSource
            cell.contactData = searchdDataSource[indexPath.row]
            cell.selectionStyle = .none
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingFriendsListCell", for: indexPath) as! MeetingFriendsListCell
        cell.currentChooseArray = self.choosedDataSource
        cell.contactData = sortedModelArr[indexPath.section][indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.searchTableView {
            return 0.01
        }
        return 30.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.searchTableView {
            return UIView()
        }
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#D9D9D9")
        let lab = UILabel()
        lab.frame = CGRect(x: 15, y: 0, width: 100, height: 30)
        lab.text = indexDataSource[section]
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = UIColor(hex: "#808080")
        view.addSubview(lab)
        return view
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell: MeetingFriendsListCell = tableView.cellForRow(at: indexPath) as! MeetingFriendsListCell
        ///防止快速点击 UI刷新错乱
        if !canSelected {
            return
        }
        self.perform(#selector(changeTableViewSelectedStatus), with: nil, afterDelay: 0.3)
        canSelected = false
        if cell.chatButton.isSelected {
            for (index, model) in choosedDataSource.enumerated() {
                let userinfo: ContactData = model 
                if userinfo.userName == cell.contactData?.userName {
                    if let collIndex = choosedDataSource.firstIndex(where: {$0.userName == cell.contactData?.userName}) {
                        let collectionIndexPath = IndexPath(row: collIndex, section: 0)
                        choosedDataSource.remove(at: index)
                        self.collectionView.performBatchUpdates {
                            self.collectionView.deleteItems(at: [collectionIndexPath])
                        }
                        
                    }

                    collectionView.isHidden = choosedDataSource.count == 0
                    break
                }
            }
            cell.chatButton.isSelected = !cell.chatButton.isSelected
            
        } else {
            if choosedDataSource.count >= meetingNumlimit {
                UIViewController.showBottomFloatingToast(with: String(format: "meeting_maximum_members_reached_ios".localized, "\(self.meetingNumlimit)"), desc: "")
                return
            }
            if let contactData = cell.contactData {
                choosedDataSource.insert(contactData, at: 0)
                collectionView.isHidden = choosedDataSource.count == 0
                let collectionIndexPath = IndexPath(row: 0, section: 0)
                self.collectionView.performBatchUpdates {
                    self.collectionView.insertItems(at: [collectionIndexPath])
                }
            }
            cell.chatButton.isSelected = !cell.chatButton.isSelected
            
        }
        reloadNumberUI()
        
    }
    
    
}
