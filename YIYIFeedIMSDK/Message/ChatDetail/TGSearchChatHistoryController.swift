//
//  TGSearchChatHistoryController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/18.
//

import UIKit
import NIMSDK

class TGSearchChatHistoryController: TGViewController, UISearchBarDelegate {
    
    var tableView: RLTableView!
    /// 搜索框
    var searchBar: TGSearchBar!
    var dataSource = [NIMMessage]()
    
    let conversationId: String
    var lastOption: V2NIMMessageSearchParams?
    var searchData = [TGIMSearchLocalHistoryObject]()
    var members = [String]()
    
    init(conversationId: String) {
        self.conversationId = conversationId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        searchBar?.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        backBaseView.backgroundColor = UIColor.white
        setSearchBarUI()
        self.tableView = RLTableView(frame: .zero, style: .plain)
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.mj_header = SCRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        self.tableView.mj_footer = SCRefreshFooter(refreshingTarget: self, refreshingAction: #selector(self.loadMore))
        self.tableView.mj_footer.isHidden = true
        self.tableView.register(ConversationListCell.self, forCellReuseIdentifier: "ConversationListCell")
        self.backBaseView.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        prepareMember()
    }
    func setSearchBarUI() {
        let bgView = UIView(frame: CGRect(x: 40, y: 0, width: ScreenWidth - 45, height: 40))
        bgView.backgroundColor = UIColor.white
        self.customNavigationBar.backgroudView.addSubview(bgView)
        self.searchBar = TGSearchBar(frame: CGRect(x: 0, y: 0, width: bgView.width, height: bgView.height))
        self.searchBar.layer.masksToBounds = true
        self.searchBar.layer.cornerRadius = 5.0
        self.searchBar.backgroundImage = nil
        self.searchBar.backgroundColor = UIColor.white
        self.searchBar.returnKeyType = .search
        self.searchBar.barStyle = UIBarStyle.default
        self.searchBar.barTintColor = UIColor.clear
        self.searchBar.tintColor = RLColor.main.theme
        self.searchBar.searchBarStyle = UISearchBar.Style.minimal
        self.searchBar.delegate = self
        self.searchBar.placeholder = "placeholder_search_message".localized
        bgView.addSubview(self.searchBar)
    }

    // MARK: - Actions
    @objc func refresh() {
//        guard let data = searchData.first else {return}
//        let obj: SearchLocalHistoryObject = data
//        if NTESBundleSetting.sharedConfig().localSearchOrderByTimeDesc() == false {
//            self.lastOption?.startTime = 0
//            self.lastOption?.endTime = obj.message?.timestamp ?? 0
//        } else {
//            self.lastOption?.startTime  = obj.message?.timestamp ?? 0
//            self.lastOption?.endTime = 0
//        }
//        searchHistory(lastOption, loadMore: false)
    }
    
    @objc func loadMore() {
        guard let data = searchData.last else {return}
        let obj: TGIMSearchLocalHistoryObject = data
//        if NTESBundleSetting.sharedConfig().localSearchOrderByTimeDesc() == false {
//            self.lastOption?.startTime = obj.message?.timestamp ?? 0
//            self.lastOption?.endTime = 0
//        } else {
//            self.lastOption?.startTime = 0
//            self.lastOption?.endTime  = obj.message?.timestamp ?? 0
//        }
//        searchHistory(lastOption, loadMore: true)
    }
    
    func searchUsers(byKeyword keyword: String, userIds: [String], completion: @escaping ([String])-> Void) {
        var accounIds: [String] = []
        MessageUtils.getUserInfo(accountIds: userIds) { users, error in
            guard let users = users else {
                completion([])
                return
            }
            for user in users {
                let nickName = user.name ?? user.accountId
                if nickName!.lowercased().contains(keyword.lowercased()) {
                    accounIds.append(user.accountId ?? "")
                }
            }
            
            completion(accounIds)
        }
    }
    
    func prepareMember() {
        let conversationType = MessageUtils.conversationTargetType(self.conversationId)
       
        if conversationType == .CONVERSATION_TYPE_TEAM {
            let teamId = MessageUtils.conversationTargetId(conversationId)
            let option = V2NIMTeamMemberQueryOption()
            option.limit = 500
            option.nextToken = ""
            option.roleQueryType = .TEAM_MEMBER_ROLE_QUERY_TYPE_ALL
            NIMSDK.shared().v2TeamService.getTeamMemberList(teamId, teamType: .TEAM_TYPE_NORMAL, queryOption: option) {[weak self] listResult in
                guard let self = self, let members = listResult.memberList, let accontId = RLSDKManager.shared.loginParma?.imAccid else {
                    return
                }
                var memberIds = [String]()
                memberIds = members.map({ $0.accountId})
                self.members = memberIds
            }
        }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchData.count > 0 {
            self.searchData.removeAll()
            self.tableView.reloadData()
        }
     
        if searchText.count == 0 {
            self.tableView.mj_footer.isHidden = true
        }
        // 创建搜索选项
        let params = V2NIMMessageSearchParams()
        params.keyword = searchText
        params.messageLimit = UInt(SearchLimit)
        //        let uids = searchUsers(byKeyword: self.searchBar.text, users: members)
        //        option.fromIds = uids as! [String]

        self.lastOption = params
        searchHistory(params, loadMore: true)
    }
    
    func searchHistory(_ params: V2NIMMessageSearchParams, loadMore: Bool) {
        if searchBar.text.orEmpty.isEmpty {
            self.searchData = []
           // self.dataSource = []
            self.tableView.reloadData()
            return
        }
        
        
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
        
//        if let option = option  {
//            option.order = .asc
//            NIMSDK.shared().conversationManager.searchMessages(session, option: option) { [weak self] (error, messages) in
//                guard let self = self, var messages = messages else { return }
//                self.tableView.mj_footer.isHidden = false
//                if self.tableView.mj_header.isRefreshing {
//                    self.tableView.mj_header.endRefreshing()
//                }
//                if self.tableView.mj_footer.isRefreshing {
//                    self.tableView.mj_footer.endRefreshing()
//                }
//                
//                var array = [SearchLocalHistoryObject]()
//                for message in messages {
//                    let obj = SearchLocalHistoryObject(message: message)
//                    obj.type = .searchLocalHistoryTypeContent
//                    array.append(obj)
//                }
//                
//                if loadMore {
//                    self.searchData.append(contentsOf: array)
//                    self.tableView.tableFooterView = array.count == 10 ? self.tableView.tableFooterView : UIView()
//                } else {
//                    array.append(contentsOf: self.searchData)
//                    self.searchData = array
//                }
//                self.tableView.reloadData()
//            }
//        }
    }

}

extension TGSearchChatHistoryController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = searchData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationListCell", for: indexPath) as! ConversationListCell
        //cell.setData(conversation: data)
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return kTSConversationTableViewCellDefaltHeight
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let data = searchData[indexPath.row]
//        let vc = IMSessionHistoryViewController(session: self.session, message: data.message!)
//        self.navigationController?.pushViewController(vc, animated: false)

    }
}
