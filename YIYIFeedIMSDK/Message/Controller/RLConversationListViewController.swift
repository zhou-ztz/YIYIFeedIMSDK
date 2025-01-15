//
//  RLConversationListViewController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/25.
//

import UIKit
import NIMSDK

protocol RLConversationListViewControllerDelegate: AnyObject {
    func didTapItem(conversationId: String, conversationType: Int)
}

public class RLConversationListViewController: TGViewController {
    
    weak var delegate: RLConversationListViewControllerDelegate?

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
        //tb.rowHeight = 86
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
    
    var isWebLoggedIn: Bool = false

    public override func viewDidLoad() {
        super.viewDidLoad()
        viewmodel.delegate = self
        backBaseView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        customNavigationBar.isHidden = true
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
    
    @objc func getConversationList(){
        viewmodel.getConversationList { [weak self] list,_  in
            guard let self = self else {return}
            self.tableView.mj_header.endRefreshing()
            self.tableView.reloadData()
            self.tableView.mj_footer.isHidden = false
            if let list = list, list.count < self.viewmodel.limit {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
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
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversationId = viewmodel.conversationList[indexPath.row].conversationId
        let conversationType = viewmodel.conversationList[indexPath.row].type
        self.delegate?.didTapItem(conversationId: conversationId, conversationType: conversationType.rawValue)
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row >= viewmodel.notificationList.count {
            let recentSession = self.viewmodel.conversationList[indexPath.row]
            var name = ""
            let sessionId = MessageUtils.conversationTargetId(recentSession.conversationId)
            MessageUtils.getAvatarIcon(sessionId: sessionId, conversationType: recentSession.type) { avatarInfo in
                name = avatarInfo.nickname ?? ""
            }
            
            let nameStr = String(format: "main_msg_list_delete_chatting_confirmation".localized, name)
            
            let delete = UIContextualAction(style: .destructive, title: "choice_delete") { (action, sourceView, completionHandler) in
                
                let alert = TGAlertController(title: "main_msg_list_delete_chatting".localized, message: nameStr, style: .alert, hideCloseButton: false, animateView: false)

                let dismissAction = TGAlertAction(title: "cancel".localized, style: TGAlertActionStyle.cancel) { (_) in
                    alert.dismiss()
                }

                let deleteAction = TGAlertAction(title: "delete".localized, style: TGAlertActionStyle.theme) { (_) in
                    self.viewmodel.deleteRecentSession(recentSession: recentSession)
                    alert.dismiss()
                }

                alert.addAction(deleteAction)
                alert.addAction(dismissAction)

                self.present(alert, animated: false, completion: nil)
                completionHandler(true)
            }
            delete.backgroundColor = UIColor(hex: 0xED1A3B)
            let deleteLabel = UILabel()
            deleteLabel.text = "choice_delete".localized
            deleteLabel.sizeToFit()
            deleteLabel.textColor = .white
            if let deleteImage = UIImage.set_image(named: "iconsDeleteWhite") {
                delete.image = self.viewmodel.resizeActionRow(image: deleteImage, label: deleteLabel)
            }
            
            let isTop = recentSession.stickTop
            let top = UIContextualAction(style: .normal, title: isTop ? "main_msg_list_clear_sticky_on_top".localized : "main_msg_list_sticky_on_top".localized) { [weak self] (action, sourceView, completionHandler)  in
                NIMSDK.shared().v2ConversationService.stickTopConversation(recentSession.conversationId, stickTop: !isTop) {
                    self?.tableView.setEditing(false, animated: true)
                    DispatchQueue.main.async {
                        self?.tableView.reloadRow(at: indexPath, with: .none)
                    }
                    completionHandler(true)
                } failure: { error in
                    self?.tableView.setEditing(false, animated: true)
                    DispatchQueue.main.async {
                        self?.tableView.reloadRow(at: indexPath, with: .none)
                    }
                }

            }
            let pinLabel = UILabel()
            pinLabel.text = isTop ? "main_msg_list_clear_sticky_on_top".localized : "main_msg_list_sticky_on_top".localized
            pinLabel.sizeToFit()
            pinLabel.textColor = .white
            if let pinImage = UIImage(named: "iconsPinWhite"){
                top.image = self.viewmodel.resizeActionRow(image: pinImage, label: pinLabel)
            }
            if isTop {
                if let pinImage = UIImage(named: "iconsUnpinWhite") {
                    top.image = self.viewmodel.resizeActionRow(image: pinImage, label: pinLabel)
                }
            } else {
                if let unpinImage = UIImage(named: "iconsPinWhite") {
                    top.image = self.viewmodel.resizeActionRow(image: unpinImage, label: pinLabel)
                }
            }
            top.backgroundColor = UIColor(hex: 0xFFB516)
            
            let isMute = recentSession.mute
            let mute = UIContextualAction(style: .normal, title: "") { [weak self] (action, sourceView, completionHandler) in
                if recentSession.type == .CONVERSATION_TYPE_TEAM {
                    let teamId = MessageUtils.conversationTargetId(recentSession.conversationId)
                    let muteMode: V2NIMTeamMessageMuteMode = isMute ? .TEAM_MESSAGE_MUTE_MODE_OFF : .TEAM_MESSAGE_MUTE_MODE_ON
                    NIMSDK.shared().v2SettingService.setTeamMessageMuteMode(teamId, teamType: .TEAM_TYPE_NORMAL, muteMode: muteMode) {
                        DispatchQueue.main.async {
                            self?.tableView.reloadRow(at: indexPath, with: .none)
                        }
                        completionHandler(true)
                    }
                } else {
                    let muteMode: V2NIMP2PMessageMuteMode = isMute ? .NIM_P2P_MESSAGE_MUTE_MODE_OFF : .NIM_P2P_MESSAGE_MUTE_MODE_ON
                    let acountId = MessageUtils.conversationTargetId(recentSession.conversationId)
                    NIMSDK.shared().v2SettingService.setP2PMessageMuteMode(acountId, muteMode: muteMode) {
                        DispatchQueue.main.async {
                            self?.tableView.reloadRow(at: indexPath, with: .none)
                        }
                        completionHandler(true)
                    }
                }
                
            }
            mute.backgroundColor = UIColor(hex: 0x808080)
            let muteLabel = UILabel()
            
            muteLabel.text = !isMute ? "mute".localized : "unmute".localized
            muteLabel.sizeToFit()
            muteLabel.textColor = .white
            if !isMute {
                if let volumeImage = UIImage(named: "mute_white") {
                    mute.image = self.viewmodel.resizeActionRow(image: volumeImage, label: muteLabel)
                }
            } else {
                if let volumeImage = UIImage(named: "unmute_white") {
                    mute.image = self.viewmodel.resizeActionRow(image: volumeImage, label: muteLabel)
                }
            }
            let swipeAction = UISwipeActionsConfiguration(actions: [delete, top, mute])
            swipeAction.performsFirstActionWithFullSwipe = false
            return swipeAction
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: ConversationViewModelDelegate
extension RLConversationListViewController: ConversationViewModelDelegate {
    
    public func onConversationChanged() {
        self.tableView.reloadData()
    }
    
    public func onTotalUnreadCountChanged(_ unreadCount: Int) {
        
    }
    
    public func onUnreadCountChanged(unreadCount: Int) {
        
    }
    
    public func didRemoveRecentSession(index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.deleteRows(at: [indexPath], with: .none)
        self.tableView.setEditing(false, animated: true)
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
