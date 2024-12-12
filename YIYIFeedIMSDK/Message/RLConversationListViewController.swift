//
//  RLConversationListViewController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/25.
//

import UIKit
import NIMSDK

public class RLConversationListViewController: TGViewController, ConversationListCellDelegate {

    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        stack.axis = .vertical
        return stack
    }()
    let viewmodel: ConversationViewModel = ConversationViewModel()
    
    lazy var tableView: RLTableView = {
        let tb = RLTableView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 0), style: .plain)
        tb.rowHeight = 86
        tb.register(ConversationListCell.self, forCellReuseIdentifier: ConversationListCell.cellIdentifier)
        tb.showsVerticalScrollIndicator = false
        tb.separatorStyle = .none
        tb.delegate = self
        tb.dataSource = self
        tb.backgroundColor = .white
        return tb
    }()
    
    lazy var advertisement: UIView = {
        let ad = UIView()
        ad.backgroundColor = RLColor.share.lightGray
        ad.layer.cornerRadius = 15
        ad.clipsToBounds = true
        return ad
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        viewmodel.delegate = self
        backBaseView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        customNavigationBar.backItem.isHidden = true
        stackView.addArrangedSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        tableView.mj_header = SCRefreshHeader(refreshingTarget: self, refreshingAction: #selector(getConversationList))
        tableView.mj_footer = SCRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadmoreConversationList))
        tableView.mj_footer.isHidden = true
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewmodel.getConversationList { [weak self] _,_  in
            guard let self = self else {return}
            self.tableView.reloadData()
            self.tableView.mj_footer.isHidden = false
            if self.viewmodel.conversationList.count < self.viewmodel.limit {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
            }
        }
    }
    
    deinit{

    }
    
    func handleLongPress(cell: ConversationListCell, conversation: V2NIMConversation?) {
        
        weak var weakSelf = self
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        let pinned = UIAlertAction(title: "置顶", style: .default) { _ in
            
        }
        let setting = UIAlertAction(title: "设置备注名", style: .default) { _ in
            
        }
        let delete = UIAlertAction(title: "删除该聊天", style: .default) { _ in
            if let recentSession = conversation {
                weakSelf?.viewmodel.deleteRecentSession(recentSession: recentSession)
            }
        }
        let deleteAllList = UIAlertAction(title: "删除消息列表", style: .default) { _ in
            
        }
        let readAllMsg = UIAlertAction(title: "清除全部未读", style: .default) { _ in
            
        }
        alertVC.addAction(pinned)
        alertVC.addAction(setting)
        alertVC.addAction(delete)
        alertVC.addAction(deleteAllList)
        alertVC.addAction(readAllMsg)
        alertVC.addAction(cancel)
        present(alertVC, animated: true)
    }
    
    @objc func getConversationList(){
        viewmodel.getConversationList { [weak self] list,_  in
            guard let self = self else {return}
            self.tableView.mj_header.endRefreshing()
            self.tableView.reloadData()
            self.tableView.mj_footer.isHidden = false
            if let list = list, list.count < self.viewmodel.limit {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                if list.count < 10 {
                    DispatchQueue.main.async {
                        // newmee azizistg22|1|zhouztz   azizistg60|1|azizistg22
                        let vc = TGChatViewController(conversationId: "azizistg22|1|azizistg60", conversationType: .CONVERSATION_TYPE_P2P)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                }
            } else {
                self.tableView.mj_footer.endRefreshing()
            }
        }
        
    }
    @objc func loadmoreConversationList(){
        guard !self.viewmodel.finished else {
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
            return}
        viewmodel.getConversationList(isRefresh: false) { [weak self] list,_  in
            guard let self = self else {return}
            self.tableView.mj_footer.endRefreshing()
            self.tableView.reloadData()
            if let list = list, list.count < self.viewmodel.limit {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
            }
        }
    }

}

extension RLConversationListViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.conversationList.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationListCell.cellIdentifier, for: indexPath) as! ConversationListCell
        
        cell.selectionStyle = .none
        cell.setData(conversation: viewmodel.conversationList[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversationId = viewmodel.conversationList[indexPath.row].conversationId
        let conversationType = viewmodel.conversationList[indexPath.row].type
        let vc = TGChatViewController(conversationId: conversationId, conversationType: conversationType)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: ConversationViewModelDelegate
extension RLConversationListViewController: ConversationViewModelDelegate {
    public func didRemoveRecentSession(index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.deleteRows(at: [indexPath], with: .none)
    }
    
    public func didAddRecentSession() {
        viewmodel.getConversationList { [weak self] _,_  in
            self?.tableView.reloadData()
        }
    }
    
    public func didUpdateRecentSession(index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    public func reloadData() {
        viewmodel.getConversationList { [weak self] _,_  in
            self?.tableView.reloadData()
        }
    }
}
