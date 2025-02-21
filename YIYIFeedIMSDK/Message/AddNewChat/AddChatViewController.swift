//
//  AddChatViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/4/11.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class AddChatViewController: NewContactsListViewController {
    
    var searchBarView: ContactsSearchView!
    var searchKeyword = ""
    lazy var searchBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "iconsSearchGrey"), for: .normal)
        
        return btn
    }()
    
    var groupStackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.distribution = .fill
        $0.alignment = .center
    }
    
    lazy var groupImg: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "newGroup")
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    lazy var groupL: UILabel = {
        let lab = UILabel()
        lab.textColor = .black
        lab.font = UIFont.boldSystemFont(ofSize: 14)
        lab.textAlignment = .left
        lab.text = "new_group".localized
        return lab
    }()
    
    var contactsStackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.distribution = .fill
        $0.alignment = .center
    }
    lazy var contactsImg: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "addNewChat")
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    lazy var contactsL: UILabel = {
        let lab = UILabel()
        lab.textColor = .black
        lab.font = UIFont.boldSystemFont(ofSize: 14)
        lab.textAlignment = .left
        lab.text = "rw_text_add_contact".localized
        return lab
    }()
    
    var leftStackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.distribution = .fill
        $0.alignment = .center
    }

    lazy var searchTableView: RLTableView = {
        let table = RLTableView(frame: .zero, style: .plain)
        table.register(NewContactsListCell.self, forCellReuseIdentifier: "NewContactsListCell")
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
        setupUI()
    }
    
    func setupUI(){
        
        customNavigationBar.titleView.isHidden = true
        searchBarView = ContactsSearchView(frame: CGRect(x: 0, y: 0, width: ScreenWidth - 20, height: 36), cancelType: self.cancelType)
        let image = UIImage(named: "iconsArrowCaretleftBlack")
        let backimage = UIImageView(image: image)
        let lab = UILabel()
        lab.textColor = .black
        lab.font = UIFont.boldSystemFont(ofSize: 17)
        lab.textAlignment = .left
        lab.text = "new_chat_title".localized
        
        leftStackView.addArrangedSubview(backimage)
        leftStackView.addArrangedSubview(lab)
        self.customNavigationBar.setLeftViews(views: [leftStackView])
        leftStackView.addAction { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        searchBtn.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        self.customNavigationBar.setRightViews(views: [searchBtn])
        searchBar.isHidden = true
        
        stackView.insertArrangedSubview(groupStackView, at: 2)
        groupStackView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.height.equalTo(43)
        }
        groupStackView.addArrangedSubview(groupImg)
        groupImg.image = UIImage(named: "iconsNewGroup")?.withRenderingMode(.alwaysTemplate)
        groupImg.tintColor = .black
        groupStackView.addArrangedSubview(groupL)
        groupL.addAction {[weak self] in
           let vc = AddGroupChatViewController()
           self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        stackView.insertArrangedSubview(contactsStackView, at: 3)
        contactsStackView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.height.equalTo(43)
        }
        contactsStackView.addArrangedSubview(contactsImg)
        contactsImg.image = UIImage(named: "iconsNewContact")?.withRenderingMode(.alwaysTemplate)
        contactsImg.tintColor = .black
        contactsStackView.addArrangedSubview(contactsL)
        contactsL.addAction {
            RLSDKManager.shared.imDelegate?.didPressContacts()
        }

        self.backBaseView.addSubview(searchTableView)
        searchTableView.isHidden = true
        searchTableView.snp.makeConstraints { make in
            make.left.right.bottom.top.equalToSuperview()
        }
        searchTableView.mj_header = SCRefreshHeader(refreshingTarget: self, refreshingAction: #selector(searchkeyWordRefresh))
        searchTableView.mj_footer = SCRefreshFooter(refreshingTarget: self, refreshingAction: #selector(searchkeyWordloadMore))
        searchBarView.delegate = self
        
        self.customNavigationBar.setTitleView(view: searchBarView)
        searchBarView.snp.makeConstraints { make in
            make.width.equalTo(ScreenWidth - 20)
            make.height.equalTo(36)
        }
        setNavigateBarStatus(isSearching: false)
    }
    
    @objc func searchkeyWordRefresh(){
        searchOffset = 0
        TGNewFriendsNetworkManager.searchMyFriend(offset: searchOffset, keyWordString: searchKeyword) { [weak self] datas, error in
            self?.searchTableView.mj_header.endRefreshing()
            guard let self = self else {return}
            if let _ = error {
                self.searchTableView.show(placeholderView: .network)
            } else {
                if let datas = datas {
                    let users = datas.compactMap {
                        ContactData(model: $0)
                    }
                    
                    self.searchdDataSource = users
                    if self.searchdDataSource.isEmpty && self.searchKeyword.isEmpty {
                        self.searchTableView.show(placeholderView: .empty)
                    } else {
                        
                    }
                    if datas.count < 15 {
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
        TGNewFriendsNetworkManager.searchMyFriend(offset: searchOffset, keyWordString: searchKeyword) { [weak self] datas, error in
            self?.searchTableView.mj_header.endRefreshing()
            guard let self = self else {return}
            if let _ = error {
                self.searchTableView.mj_footer.endRefreshing()
                self.searchTableView.show(placeholderView: .network)
            }else {
                if let datas = datas {
                    self.searchOffset = self.searchOffset + datas.count
                    let users = datas.compactMap {
                        ContactData(model: $0)
                    }
                    self.searchdDataSource = self.searchdDataSource + users
                    if self.searchdDataSource.isEmpty && self.keyword.isEmpty {
                        self.searchTableView.show(placeholderView: .empty)
                    } else {
                        
                    }
                    if datas.count < 15 {
                        self.searchTableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.searchTableView.mj_footer.endRefreshing()
                    }
                    DispatchQueue.main.async {
                        self.searchTableView.reloadData()
                    }
                    
                }else{
                    self.searchTableView.mj_footer.endRefreshing()
                }
            }
        }
    }
    
    @objc func searchAction(){
        self.searchBarView.searchTextFiled.becomeFirstResponder()
        setNavigateBarStatus(isSearching: true)
    }
    
    func setNavigateBarStatus(isSearching: Bool = false){
        if isSearching {
            customNavigationBar.titleView.isHidden = false
            customNavigationBar.setLeftViews(views: [])
            customNavigationBar.setRightViews(views: [])
        }else {
            customNavigationBar.titleView.isHidden = true
            customNavigationBar.setLeftViews(views: [leftStackView])
            customNavigationBar.setRightViews(views: [searchBtn])
        }
    }

}

extension AddChatViewController{
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewContactsListCell", for: indexPath) as! NewContactsListCell
            cell.currentChooseArray = self.choosedDataSource
            cell.contactData = searchdDataSource[indexPath.row]
            cell.selectionStyle = .none
            cell.chatButton.isHidden = true
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewContactsListCell", for: indexPath) as! NewContactsListCell
        cell.currentChooseArray = self.choosedDataSource
        cell.contactData = sortedModelArr[indexPath.section][indexPath.row]
        cell.selectionStyle = .none
        cell.chatButton.isHidden = true
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
        view.backgroundColor = UIColor(hex: 0xF6F6F6)
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
        
        self.searchBarView.searchTextFiled.resignFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2){
            if tableView == self.searchTableView {
                let model = self.searchdDataSource[indexPath.row]
                let me: String = NIMSDK.shared().v2LoginService.getLoginUser() ?? ""
                let conversationId = "\(me)|1|\(model.userName)"
                let vc = TGChatViewController(conversationId: conversationId, conversationType: 1)
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                let model = self.sortedModelArr[indexPath.section][indexPath.row]
                let me: String = NIMSDK.shared().v2LoginService.getLoginUser() ?? ""
                let conversationId = "\(me)|1|\(model.userName)"
                let vc = TGChatViewController(conversationId: conversationId, conversationType: 1)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        
    }
    
    
}

extension AddChatViewController: ContactsSearchViewDelegate {
    func searchDidClickCancel() {
        self.searchBarView.searchTextFiled.resignFirstResponder()
        self.setNavigateBarStatus(isSearching: false)
        self.searchTableView.isHidden = true
    }
    
    func searchDidClickReturn(text: String) {
        self.searchBar.searchTextFiled.resignFirstResponder()
        searchKeyword = text
        self.searchTableView.isHidden = false
        self.searchkeyWordRefresh()
        isSearching = !self.searchTableView.isHidden
    }
    func searchTextDidChange(text: String) {
        
    }
}
