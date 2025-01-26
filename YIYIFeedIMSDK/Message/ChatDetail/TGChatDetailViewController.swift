//
//  TGChatDetailViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/17.
//

import UIKit
import NIMSDK

class TGChatDetailViewController: TGViewController {
    
    var sessionId: String
    var conversationId: String
    var clearMessageCall: (() -> ())?
    lazy var tableView: RLTableView = {
        let tb = RLTableView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 0), style: .plain)
        tb.rowHeight = 48
        tb.register(TGChatDetailCell.self, forCellReuseIdentifier: TGChatDetailCell.cellIdentifier)
        tb.register(TGChatDetailHeaderView.self, forHeaderFooterViewReuseIdentifier: "TGChatDetailHeaderView")
        tb.showsVerticalScrollIndicator = false
        //tb.separatorStyle = .none
        tb.delegate = self
        tb.dataSource = self
        tb.backgroundColor = TGAppTheme.headerGrey
        tb.tableFooterView = UIView()
        tb.separatorInset = .zero
        return tb
    }()
    
    init(sessionId: String, conversationId: String) {
        self.sessionId = sessionId
        self.conversationId = conversationId
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commitUI()
    }
    
    func commitUI() {
        self.customNavigationBar.title = "title_personal_chat_info".localized
        MessageUtils.getAvatarIcon(sessionId: sessionId, conversationType: .CONVERSATION_TYPE_P2P) { [weak self] avatarInfo in
            if let username = avatarInfo.nickname {
                self?.customNavigationBar.title = username
            }
        }
        self.backBaseView.addSubview(tableView)
        tableView.bindToEdges()
    }
    
    @objc func onActionNeedNotifyValueChange(_ sender: UISwitch) {
        let muteMode: V2NIMP2PMessageMuteMode = !sender.isOn ? .NIM_P2P_MESSAGE_MUTE_MODE_OFF : .NIM_P2P_MESSAGE_MUTE_MODE_ON
        let acountId = MessageUtils.conversationTargetId(self.conversationId)
        NIMSDK.shared().v2SettingService.setP2PMessageMuteMode(acountId, muteMode: muteMode) { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
            
        }
    }

    @objc func onActionNeedTopValueChange(_ sender: UISwitch) {
        NIMSDK.shared().v2ConversationService.stickTopConversation(self.conversationId, stickTop: sender.isOn) {[weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        } failure: { _ in
            
        }

    }
    
    @objc func onInviteTap() {
        presentMemberSelector { [weak self] (members) in
            let vc = TGCreateGroupViewController()
            vc.choosedDataSource = members
            self?.navigationController?.pushViewController(vc, animated: true)
            vc.finishBlock = { teamId, name in
                let text = String(format: "%@ %@", name,"created".localized)
                let message = MessageUtils.tipV2Message(text: text)
                let me = NIMSDK.shared().v2LoginService.getLoginUser() ?? ""
                let conversationId = me + "|2|" + teamId
                NIMSDK.shared().v2MessageService.send(message, conversationId: conversationId, params: nil) { _ in
                    DispatchQueue.main.async {
                        let chat = TGChatViewController(conversationId: conversationId, conversationType: 2)
                        self?.navigationController?.pushViewController(chat, animated: true)
                    }
                    
                } failure: { _ in
                    
                }
            }
        }
    }
    
    func presentMemberSelector(block: @escaping (([ContactData]) -> Void)) {
        let config = TGContactsPickerConfig.selectFriendBasicConfig([sessionId])
        
        let contactsPickerVC = TGContactsPickerViewController(configuration: config, finishClosure: block)
        contactsPickerVC.isP2PInvite = true
        
        self.navigationController?.pushViewController(contactsPickerVC, animated: true)
    }
    
    func onActionClearMessage() {
        let option = V2NIMClearHistoryMessageOption()
        option.conversationId = self.conversationId
        option.deleteRoam = true
        NIMSDK.shared().v2MessageService.clearHistoryMessage(option) { [weak self] in
            DispatchQueue.main.async {
                self?.clearMessageCall?()
            }
        } failure: { _ in
            
        }
    }

}

extension TGChatDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 0
        case 1:
            return 2
        case 2:
            return 3
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TGChatDetailCell.cellIdentifier) as! TGChatDetailCell
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            break
        case 1:
            if row == 0 {
                cell.configure(title: NSLocalizedString("photo_video_files", comment: ""))
                cell.accessoryType = .disclosureIndicator
                cell.switcher.makeHidden()
            } else {
                cell.configure(title: NSLocalizedString("chatinfo_search_message", comment: ""))
                cell.accessoryType = .disclosureIndicator
                cell.switcher.makeHidden()
            }
            cell.cellTitle.textColor = .black
            break
        case 2:
            if(row == 0) {
                cell.configure(title: NSLocalizedString("chat_wallpaper", comment: ""))
                cell.accessoryType = .none
                cell.switcher.makeHidden()
            } else if(row == 1) {
                cell.switcher.makeVisible()
                cell.configure(title: NSLocalizedString("chatinfo_mute_notification", comment: ""))
                cell.selectionStyle = .none
                
                NIMSDK.shared().v2ConversationService.getConversation(self.conversationId) { conversation in
                    DispatchQueue.main.async {
                        if conversation.mute {
                            cell.switcher.setOn(true, animated: false)
                        } else {
                            cell.switcher.setOn(false, animated: false)
                        }
                    }
                } failure: { _ in
                    DispatchQueue.main.async {
                        cell.switcher.setOn(false, animated: false)
                    }
                }
                cell.switcher.addTarget(self, action: #selector(onActionNeedNotifyValueChange(_:)), for: .valueChanged)
            } else if(row == 2) {
                cell.configure(title: NSLocalizedString("chatinfo_set_chat_on_top", comment: ""))
                
                cell.switcher.addTarget(self, action: #selector(onActionNeedTopValueChange(_:)), for: .valueChanged)
                NIMSDK.shared().v2ConversationService.getConversation(self.conversationId) { conversation in
                    DispatchQueue.main.async {
                        if conversation.stickTop {
                            cell.switcher.setOn(true, animated: false)
                        } else {
                            cell.switcher.setOn(false, animated: false)
                        }
                    }
                } failure: { _ in
                    DispatchQueue.main.async {
                        cell.switcher.setOn(false, animated: false)
                    }
                }
                cell.switcher.makeVisible()
            }
            
            cell.cellTitle.textColor = .black
            break
        case 3:
            cell.configure(title: NSLocalizedString("chatinfo_clear_chat", comment: ""))
            cell.accessoryType = .none
            cell.switcher.makeHidden()
            cell.cellTitle.textColor = .red
            break
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 0:
            break
        case 1:
            if row == 0 {
                let vc = TGChatMediaViewController(conversationId: self.conversationId)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                
            }
            break
        case 2:
            if(row == 0) {
                let vc = TGChatWallpaperViewController()
                self.navigationController?.pushViewController(vc, animated: true)
             }
            break
        case 3:
            let alert = UIAlertController(title: NSLocalizedString("confirm_delete_record", comment: ""), message: nil, preferredStyle: .alert)
            let confirm = UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .destructive) { [weak self] _ in
                guard let strongself = self else { return }
                strongself.onActionClearMessage()
            }
            let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
            alert.addAction(confirm)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section == 0) {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TGChatDetailHeaderView") as! TGChatDetailHeaderView
            header.configure(sessionId: self.sessionId)
            header.contentView.backgroundColor = .white
            header.inviteHandler = { [weak self] in
                self?.onInviteTap()
            }
            return header
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0) {
            return 100
        }

        return 25
    }
    
    
}
