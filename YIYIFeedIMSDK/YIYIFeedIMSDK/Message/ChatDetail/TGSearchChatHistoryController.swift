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
    var searchParams: V2NIMMessageSearchParams?
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
        self.tableView.register(TGIMSearchMessageContentCell.self, forCellReuseIdentifier: "TGIMSearchMessageContentCell")
        self.backBaseView.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
      
        let sessionId = MessageUtils.conversationTargetId(conversationId)
        let me = NIMSDK.shared().v2LoginService.getLoginUser() ?? ""
        let type = MessageUtils.conversationTargetType(conversationId)
        let params = V2NIMMessageSearchParams()
        params.messageLimit = UInt(SearchLimit)
        params.sortOrder = .SORT_ORDER_DESC
        if type == .CONVERSATION_TYPE_P2P {
            params.p2pAccountIds = [me, sessionId]
        } else {
            params.teamIds = [sessionId]
        }
        searchParams = params
        self.tableView.show(placeholderView: .emptyResult)
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
        if let searchParams = searchParams {
            self.searchParams?.beginTime  = 0
            self.searchParams?.endTime = 0
            searchHistory(searchParams, loadMore: false)
        }
    }
    
    @objc func loadMore() {
        guard let data = searchData.last else {return}
        self.searchParams?.beginTime  = 0
        self.searchParams?.endTime = data.message.createTime
        if let searchParams = searchParams {
            searchHistory(searchParams, loadMore: true)
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
        searchHistory(searchParams!, loadMore: false)
    }
    
    func searchHistory(_ params: V2NIMMessageSearchParams, loadMore: Bool) {
        if searchBar.text.orEmpty.isEmpty {
            self.searchData = []
            self.tableView.reloadData()
            return
        }
        if !loadMore {
            self.searchData.removeAll()
        }
        
        params.keyword = searchBar.text ?? ""
        NIMSDK.shared().v2MessageService.searchCloudMessages(params) {[weak self] messages in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.tableView.mj_footer.isHidden = false
                self.tableView.mj_header.endRefreshing()
                
                if !loadMore {
                    if messages.count == 0 {
                        self.tableView.show(placeholderView: .emptyResult)
                    } else {
                        self.tableView.removePlaceholderViews()
                    }
                } else {
                    if messages.count > 0 {
                        ///删除最后一条重复的消息
                        self.searchData.remove(at: self.searchData.count - 1)
                    }
                }
                
                for message in messages {
                    let object = TGIMSearchLocalHistoryObject(message: message)
                    object.type = .content
                    self.searchData.append(object)
                }
                
                if messages.count < SearchLimit {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self.tableView.mj_footer.endRefreshing()
                }
                
                self.tableView.reloadData()
            }
            
        } failure: {[weak self] error in
            DispatchQueue.main.async {
                self?.tableView.show(placeholderView: .network)
            }
        }
 
    }

}

extension TGSearchChatHistoryController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.searchData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TGIMSearchMessageContentCell", for: indexPath) as! TGIMSearchMessageContentCell
        cell.refresh(model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = searchData[indexPath.row]
  
        let type = MessageUtils.conversationTargetType(conversationId)
        let vc = TGIMSessionHistoryViewController(conversationId: conversationId, conversationType: type, anchor: data.message)
        self.navigationController?.pushViewController(vc, animated: false)

    }
}
