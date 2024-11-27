//
//  RLConversationListViewController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/25.
//

import UIKit
import NIMSDK

public class RLConversationListViewController: RLViewController, ConversationListCellDelegate {

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
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewmodel.getConversationList { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
    
    deinit{

    }
    
    func handleLongPress(cell: ConversationListCell, session: NIMRecentSession?) {
        
        weak var weakSelf = self
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        let pinned = UIAlertAction(title: "置顶", style: .default) { _ in
            
        }
        let setting = UIAlertAction(title: "设置备注名", style: .default) { _ in
            
        }
        let delete = UIAlertAction(title: "删除该聊天", style: .default) { _ in
            if let recentSession = session {
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
    
    

}

extension RLConversationListViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.conversationList.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationListCell.cellIdentifier, for: indexPath) as! ConversationListCell
        
        cell.selectionStyle = .none
        cell.setData(session: viewmodel.conversationList[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let session = viewmodel.conversationList[indexPath.row].session {
            let vc = RLBaseChatViewController(session: session, unreadCount: 0)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

// MARK: ConversationViewModelDelegate
extension RLConversationListViewController: ConversationViewModelDelegate {
    public func didRemoveRecentSession(index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.deleteRows(at: [indexPath], with: .none)
    }
    
    public func didAddRecentSession() {
        viewmodel.getConversationList { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
    
    public func didUpdateRecentSession(index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    public func reloadData() {
        viewmodel.getConversationList { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
}
