//
//  TGMessageSearchListController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/17.
//

import UIKit
import NIMSDK
import SVProgressHUD

let SearchLimit: Int = 30

class TGMessageSearchListController: TGViewController {
    
    var friendSectionFirstLoad = false
    
    lazy var collectionView: RLCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let width = floor(UIScreen.main.bounds.width / 5)
        layout.itemSize = CGSize(width: width, height: width + 3)
        layout.scrollDirection = .horizontal
        
        let collectionView = RLCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TGIMSearchFriendCell.self, forCellWithReuseIdentifier: "TGIMSearchFriendCell")
        collectionView.isHidden = true
        collectionView.backgroundColor = .white
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    lazy var tableView: RLTableView = {
        let tableView = RLTableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.tableFooterView = UIView()
        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        tableView.separatorStyle = .none
        tableView.register(TGIMSearchMessageContentCell.self, forCellReuseIdentifier: "TGIMSearchMessageContentCell")
        tableView.register(ConversationListCell.self, forCellReuseIdentifier: "ConversationListCell")
        tableView.backgroundColor = .white
        return tableView
    }()
    
    lazy var headerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 1.0)
        return view
    }()
    
    lazy var moreView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.isUserInteractionEnabled = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onPressMoreView))
        view.addGestureRecognizer(recognizer)
        return view
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
    }()
    
    lazy var bgView: UIControl = {
        let control = UIControl()
        control.backgroundColor = .clear
        control.isHidden = true
        control.addTarget(self, action: #selector(hiddenKeyBoard), for: .touchUpInside)
        return control
    }()
    
    lazy var emptyView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()

    var searchUserList: [UserInfoModel] = []
    var searchData: [TGIMSearchLocalHistoryObject] = []
    var searchSession: [V2NIMConversation] = []
    var keyWord: String = ""
    var recentSessions: [V2NIMConversation] = []
    
    var footerView: UITableViewHeaderFooterView!
    
    var tableHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.isHidden = true
        backBaseView.backgroundColor = .white
        setUpSearchBar()
        backBaseView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.right.bottom.equalTo(0)
            make.top.equalTo(searchBar.snp.bottom).offset(10)
        }
        
        stackView.addArrangedSubview(headerView)
        stackView.addArrangedSubview(collectionView)
        stackView.addArrangedSubview(tableView)
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.right.equalTo(0)
            make.height.equalTo(40)
        }
        
        collectionView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.height.equalTo(floor(UIScreen.main.bounds.width / 5) + 10)
        }
        tableView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.bottom.equalToSuperview()
        }
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .gray
        label.text = "contact".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(label)
        
        headerView.addSubview(moreView)
        label.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(5)
            make.bottom.equalTo(-5)
        }
        moreView.snp.makeConstraints { make in
            make.right.top.bottom.equalTo(0)
        }
        
        let moreLabel = UILabel()
        moreLabel.font = UIFont.boldSystemFont(ofSize: 14)
        moreLabel.textColor = UIColor(red: 59.0/255.0, green: 179.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        moreLabel.text = "more".localized
        
        let nextImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        nextImage.image = UIImage(named: "ic_history_arrow")
        
        moreLabel.translatesAutoresizingMaskIntoConstraints = false
        nextImage.translatesAutoresizingMaskIntoConstraints = false
        
        moreView.addSubview(moreLabel)
        moreView.addSubview(nextImage)
        nextImage.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
        }
        moreLabel.snp.makeConstraints { make in
            make.right.equalTo(nextImage.snp.left).offset(-5)
            make.centerY.equalToSuperview()
            make.left.equalTo(0)
        }

        bgView.frame = view.bounds
        backBaseView.addSubview(bgView)
        fetchAllRecentSessions()
        collectionView.isHidden = true
        headerView.isHidden = true
        self.tableView.show(placeholderView: .empty)
    }
    
    func setUpSearchBar() {
        // 创建自定义返回按钮
        let backButton = UIButton(type: .custom)
        backButton.frame = CGRect(x: 10, y: 55, width: 30, height: 25)
        backButton.setImage(UIImage(named: "btn_back_normal"), for: .normal)
        backButton.contentMode = .scaleAspectFit
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        backBaseView.addSubview(backButton)
        
        // 创建搜索栏
        let searchBar = UISearchBar(frame: CGRect(x: 45, y: 50, width: view.bounds.width - 60, height: 36))
        searchBar.barStyle = .default
        searchBar.searchBarStyle = .default
        searchBar.placeholder = "placeholder_search_message".localized
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBar.layer.cornerRadius = 36 / 2
        searchBar.clipsToBounds = true
        searchBar.setImage(UIImage(named: "group3"), for: .search, state: .normal)
        searchBar.backgroundColor = UIColor(red: 238.0 / 255.0, green: 238.0 / 255.0, blue: 238.0 / 255.0, alpha: 1.0)
        searchBar.backgroundImage = UIImage()
        
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.backgroundColor = UIColor(red: 238.0 / 255.0, green: 238.0 / 255.0, blue: 238.0 / 255.0, alpha: 1.0)
            searchBar.searchTextField.font = UIFont.systemFont(ofSize: 15)
        } else {
            if let searchField = searchBar.value(forKey: "_searchField") as? UITextField {
                searchField.font = UIFont.systemFont(ofSize: 15)
                searchField.backgroundColor = UIColor(red: 238.0 / 255.0, green: 238.0 / 255.0, blue: 238.0 / 255.0, alpha: 1.0)
            }
        }
        
        backBaseView.addSubview(searchBar)
        self.searchBar = searchBar
        // 创建分隔线
        let lineView = UIView(frame: CGRect(x: 13, y: 95, width: view.bounds.width - 26, height: 2))
        lineView.backgroundColor = UIColor(red: 238.0 / 255.0, green: 238.0 / 255.0, blue: 238.0 / 255.0, alpha: 1.0)
        backBaseView.addSubview(lineView)
        
    }
    
    func fetchAllRecentSessions() {
        NIMSDK.shared().v2ConversationService.getConversationList(0, limit: 200) {[weak self] conversationResult in
            guard let self = self, let list = conversationResult.conversationList  else {
                return
            }
            self.recentSessions = self.customSortRecents(list)
        } failure: { error in
            UIViewController.showBottomFloatingToast(with: error.nserror.localizedDescription, desc: "")
        }

    }
    
    func customSortRecents(_ recentSessions: [V2NIMConversation]) -> [V2NIMConversation] {
        var array = recentSessions
        array.sort {(obj1: V2NIMConversation, obj2: V2NIMConversation) -> Bool in
            var score1 = obj1.stickTop ? 10 : 0
            var score2 = obj2.stickTop ? 10 : 0
            
            if (obj1.lastMessage?.messageRefer.createTime ?? 0) > (obj2.lastMessage?.messageRefer.createTime ?? 0) {
                score1 += 1
            } else if (obj1.lastMessage?.messageRefer.createTime ?? 0) < (obj2.lastMessage?.messageRefer.createTime ?? 0) {
                score2 += 1
            }
            
            if score1 == score2 {
                return false // 保持顺序不变
            }
            return score1 > score2
        }
        return array
    }
   
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func hiddenKeyBoard() {
        searchBar.resignFirstResponder()
        self.bgView.isHidden = true
    }
    
    @objc func onPressMoreView() {
        let vc = TGIMSearchUserListMoreVC()
        vc.members = searchUserList
        vc.keyword = keyWord
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getDataFromServer(keyword: String) {
        searchConversation(withKeyword: keyword)
        searchFriendWithKeyword(keyword)
    }
    
    func searchFriendWithKeyword(_ keyword: String){
        SVProgressHUD.show()
        let extras = TGAppUtil.getUserID(remarkName: keyword)
        TGNewFriendsNetworkManager.searchMyFriend(offset: 0, keyWordString: keyword, extras: extras) {[weak self] userModels, error in
            SVProgressHUD.dismiss()
            guard let users = userModels, let self = self else {
                return
            }
            self.searchUserList = users
            DispatchQueue.main.async {
                self.refresh()
            }
        }
    }
    
    func searchConversation(withKeyword keyword: String) {
        searchData.removeAll()
        searchSession.removeAll()
        // 设置关键字
        self.keyWord = keyword
        // 创建搜索选项
        let params = V2NIMMessageSearchParams()
        params.keyword = self.keyWord
        params.messageLimit = UInt(SearchLimit)
        params.sortOrder = .SORT_ORDER_DESC
        NIMSDK.shared().v2MessageService.searchCloudMessages(params) {[weak self] messages in
            guard let self = self else {return}
            print("messages = \(messages.count)")

            for message in messages {
                let object = TGIMSearchLocalHistoryObject(message: message)
                object.type = .content
                self.searchData.append(object)
            }
            DispatchQueue.main.async {
                self.refresh()
            }
            
        } failure: { error in
            
        }
        
        let group = DispatchGroup()
        for recentSession in recentSessions {
            let sessionId = MessageUtils.conversationTargetId(recentSession.conversationId)
            if sessionId == NIMSDK.shared().v2LoginService.getLoginUser() {
                continue
            }
            group.enter()
            MessageUtils.getAvatarIcon(sessionId: sessionId, conversationType: recentSession.type) {[weak self] avatarInfo in
                guard let self = self, let nickname = avatarInfo.nickname else {
                    group.leave()
                    return} 
                if nickname.lowercased().contains(keyword.lowercased()) {
                    self.searchSession.append(recentSession)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            self.refresh()
        }
        
    }
    
    func searchUsersBy(keyWord: String, users: [String]) -> [String] {
        
    //    var nicks: [String] = []
   //     for user in users {
//            MessageUtils.getAvatarIcon(sessionId: user, conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
//                nicks.append(avatarInfo.nickname ?? "")
//            }
   //     }
        return []
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        searchBar.resignFirstResponder()
    }
    
    func refresh() {
        if self.searchData.count == 0 && self.searchUserList.count == 0 && self.searchSession.count == 0 {
            self.tableView.show(placeholderView: .empty)
        } else {
            self.tableView.removePlaceholderViews()
        }
        self.collectionView.isHidden = self.searchUserList.count == 0
        self.headerView.isHidden = self.searchUserList.count == 0
        self.moreView.isHidden = self.searchUserList.count < 6
        self.moreView.isUserInteractionEnabled = self.searchUserList.count > 5
        collectionView.reloadData()
        collectionView.layoutIfNeeded()

        tableView.reloadData()
        tableView.layoutIfNeeded()

    }
    
}

extension TGMessageSearchListController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return searchSession.count
        case 1:
            return searchData.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let recent = self.searchSession[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationListCell", for: indexPath) as! ConversationListCell
            cell.setData(conversation: recent)
            return cell
        case 1:
            let model = self.searchData[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "TGIMSearchMessageContentCell", for: indexPath) as! TGIMSearchMessageContentCell
            cell.refresh(model)
            return cell
        default:
            return UITableViewCell()
        }
            
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        headerView.backgroundColor = UIColor(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 1.0)
        
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: headerView.frame.width, height: headerView.frame.height))
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .gray
        
        switch section {
        case 0:
            label.text = "rw_text_chats".localized
        case 1:
            label.text = "messages".localized
        default:
            break
        }
        
        label.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5),
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -5)
        ])
        
        return headerView
    }

//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return footerView
//    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if searchSession.count > 0 && searchData.count > 0 {
                return 15
            }
        case 1:
            break
        default:
            break
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    
        switch section {
        case 0:
            if self.searchSession.count > 0 {
                return 40
            }
        case 1:
            if self.searchData.count > 0 {
                return 40
            }
        default:
            break
        }
        return CGFloat.leastNormalMagnitude
    }
}

extension TGMessageSearchListController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if friendSectionFirstLoad {
            return 1
        }
        return searchUserList.count > 5 ? 5 : searchUserList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TGIMSearchFriendCell", for: indexPath) as! TGIMSearchFriendCell
        cell.delegate = self
        if searchUserList.count > indexPath.item {
            cell.refreshUserInfo(searchUserList[indexPath.item])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let me = NIMSDK.shared().v2LoginService.getLoginUser() else {return}
        let model = searchUserList[indexPath.item]
        let conversationId = "\(me)|1|\(model.username)"
        let vc = TGChatViewController(conversationId: conversationId, conversationType: 1)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension TGMessageSearchListController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
           bgView.isHidden = false
       }

       func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           guard !searchText.isEmpty else { return }
           getDataFromServer(keyword: searchText)
       }

       func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {

       }

       func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           bgView.isHidden = true
           searchBar.resignFirstResponder()
       }
}

extension TGMessageSearchListController: TGIMSearchFriendCellDelegate {
    func didTapOnCollectionCell(_ cell: TGIMSearchFriendCell) {
        
    }
}


