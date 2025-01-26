//
//  TGTeamChatDetailViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/17.
//

import UIKit
import NIMSDK

class TGTeamChatDetailViewController: TGViewController {
    
    var contentView: UIView = UIView()
    lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.spacing = 8
        stack.distribution = .fill
        stack.axis = .vertical
        return stack
    }()
    lazy var memberCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
//        layout.minimumLineSpacing = 0
//        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.register(TGChatMemberCell.self, forCellWithReuseIdentifier: "TGChatMemberCell")
        return collectionView
    }()
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
    var sessionId: String
    var conversationId: String
    var clearMessageCall: (() -> ())?
    var team: V2NIMTeam
    let viewmodel: TeamDetailViewModel!

    var clearGroupMessageCall: (() -> ())?
    private lazy var groupDataView: UIStackView = {
        let view = UIStackView()
        view.spacing = 1
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        return view
    }()
    
    private lazy var groupInfoView: UIStackView = {
        let view = UIStackView()
        view.spacing = 1
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        return view
    }()
    
    private lazy var groupSensitiveView: UIStackView = {
        let view = UIStackView()
        view.spacing = 1
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        return view
    }()
    
    private lazy var preferencesView: UIStackView = {
        let view = UIStackView()
        view.spacing = 1
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        return view
    }()
    
    private lazy var leavedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xFFE0AD)
        
        let label = UILabel()
        label.text = "team_no_longer_in_group".localized
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15)
        view.addSubview(label)
        label.snp.makeConstraints({
            $0.height.equalTo(50)
            $0.width.equalTo(UIScreen.main.bounds.width - 28)
            $0.left.equalTo(view.snp.left).inset(14)
            $0.centerY.equalTo(view.snp.centerY)

        })
        return view
    }()
    
    private lazy var groupDataInfo: [TGChatSettingView] = {
        return [TGTeamSetting(type: .mediaDocuments, selector: #selector(self.onClickMedia)).toSettingView(self),
                TGTeamSetting(type: .searchMessage, selector: #selector(self.onClickSearchMessages)).toSettingView(self)]
    }()
    
    private lazy var groupBasicInfo: [TGChatSettingView] = {
        guard let myTeamInfo = viewmodel.myTeamInfo else { return [] }
        return [TGTeamSetting(type: .groupIcon, selector: #selector(self.onClickGroupImage), imageUrl: team.avatar).toSettingView(self),
                TGTeamSetting(type: .groupName, selector: #selector(self.onClickGroupName), detailValue: viewmodel.getValue(for: .groupName)).toSettingView(self),
                TGTeamSetting(type: .groupIntro, selector: #selector(self.onClickGroupIntro), detailValue: viewmodel.getValue(for: .groupIntro)).toSettingView(self),
                TGTeamSetting(type: .myNickname, selector: #selector(self.onClickGroupNickname), detailValue: viewmodel.getValue(for: .myNickname)).toSettingView(self)]
    }()
    
    private lazy var groupSensitiveInfo: [TGChatSettingView] = {
        return [TGTeamSetting(type: .groupType, selector: #selector(self.onClickGroupType), detailValue: viewmodel.joinModeText, clickable: viewmodel.hasPermission).toSettingView(self),
                TGTeamSetting(type: .groupWhoCanInvite, selector: #selector(self.onClickInvitor), detailValue: viewmodel.inviteModeText, clickable: viewmodel.hasPermission).toSettingView(self),
                TGTeamSetting(type: .groupWhoCanEdit, selector: #selector(self.onClickEditPermission), detailValue: viewmodel.updateInfoModeText, clickable: viewmodel.hasPermission).toSettingView(self)]
    }()
    
    private lazy var preferencesInfo: [TGChatSettingView] = {
        return [TGTeamSetting(type: .chatWallpaper, selector: #selector(self.onClickChatWallpaper)).toSettingView(self),
                TGTeamSetting(type: .muteNotification, selector: #selector(self.onMuteNotification(_:)), switchValue: viewmodel.isNotificationMuted).toSettingView(self),
                TGTeamSetting(type: .pinTop, selector: #selector(self.onSetTopValueChange(_:)), switchValue:viewmodel.isPinnedToTop).toSettingView(self)]
    }()
    
    private lazy var ownerButtons: [UIButton] = {
        return [TGTeamSetting(type: .transferGroup, selector: #selector(self.onClickTransferGroup)).toButton(self),
                TGTeamSetting(type: .dismissGroup, selector: #selector(self.onClickDismissTeam)).toButton(self)]
    }()
    
    private lazy var leaveButton: UIButton = {
        return TGTeamSetting(type: .leaveGroup, selector: #selector(self.onClickQuitTeam)).toButton(self)
    }()
    
    private lazy var clearAndDeleteButton: UIButton = {
        return TGTeamSetting(type: .clearAndDeleteChat, selector: #selector(self.onClickClearDeleteTeam)).toButton(self)
    }()
    
    var isActionSuccess: Bool = false
    var isLeavedMember: Bool = false
    
    init(sessionId: String, conversationId: String, team: V2NIMTeam) {
        self.sessionId = sessionId
        self.conversationId = conversationId
        self.team = team
        self.viewmodel = TeamDetailViewModel(team: team, teamId: team.teamId)
        self.viewmodel.conversationId = conversationId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commitUI()
        viewmodel.getConversationInfo()
    }
    
    func setupRightBarButton(_ needHide: Bool = false) {
        if needHide {
            self.customNavigationBar.setRightViews(views: [])
        } else {
            let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
            rightButton.setImage(UIImage(named: "iconsQrcodeBlack"), for: .normal)
            rightButton.addTarget(self, action: #selector(onClickQRCode), for: UIControl.Event.touchUpInside)
            self.customNavigationBar.setRightViews(views: [rightButton])
        }
    }
    
    func commitUI() {
        self.customNavigationBar.backItem.setTitle(team.name + "(\(team.memberCount))", for: .normal)
        
        self.backBaseView.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(memberCollection)
        scrollView.bindToEdges()
        contentView.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(0)
            make.width.equalTo(ScreenWidth)
        }
        contentStackView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        contentStackView.bindToEdges()
        contentStackView.spacing = 8
        contentStackView.backgroundColor = .clear
        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        self.backBaseView.backgroundColor = RLColor.inconspicuous.background
        helperCallback()
        viewmodel.getTeamMember { [weak self] done in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if done {
                    self.isLeavedMember = false
                    self.leaveButton.isHidden = self.viewmodel.isOwner
                    self.leavedView.isHidden = true
                } else {
                    self.isLeavedMember = true
                    self.memberCollection.isHidden = true
                    self.groupDataView.isHidden = false
                    self.groupInfoView.isHidden = true
                    self.groupSensitiveView.isHidden = true
                    self.preferencesView.isHidden = true
                    self.leaveButton.isHidden = true
                    self.leavedView.isHidden = false
                }
                self.checkMemberPermission()
                self.setupGroupInfoContent()
            }
        }
        
        scrollView.mj_header = SCRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        
        viewmodel.changeToNeedAuth()
    }
    
    @objc func refresh() {
        viewmodel.getTeamMember { [weak self] done in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.checkMemberPermission()
            }
            
        }
    }
    
    func helperCallback() {
        viewmodel.onShowSuccess = { [weak self] msg in
        guard let self = self else { return }
            DispatchQueue.main.async {
                self.scrollView.mj_header.endRefreshing()
               // self.showSuccess(msg)
                // By Kit Foong (added refresh when any action trigger)
                self.refresh()
            }
        }
        
        if !(self.isActionSuccess) {
            viewmodel.onShowFail = { [weak self] msg in
                guard let self = self, self.isLeavedMember != false else { return }
                self.scrollView.mj_header.endRefreshing()
               // self.showFail(msg)
            }
        }
        
        viewmodel.onReloadMembers = { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.scrollView.mj_header.endRefreshing()
                self.memberCollection.reloadData()
                let height = self.memberCollection.collectionViewLayout.collectionViewContentSize.height
                self.memberCollection.snp.remakeConstraints { make in
                    make.leading.right.top.equalToSuperview()
                    make.height.equalTo(height)
                }
               // self.memberCollection.he = height
                self.view.setNeedsLayout()
            }
        }
        
        viewmodel.onReloadData = { type in
            //self.updateDataContent(for: type)
           // self.checkMemberPermission(false)
        }
    }
    
    // By Kit Foong (Check member permission to hide qr code)
    private func checkMemberPermission(_ canRetrieveTeamInfo: Bool = true) {
        
        let isAdmin = viewmodel.hasPermission
        
        for item in groupSensitiveInfo {
            item.isUserInteractionEnabled = isAdmin
        }
        
        if isAdmin {
            if team.joinMode == .TEAM_JOIN_MODE_APPLY || team.joinMode == .TEAM_JOIN_MODE_FREE {
                self.setupRightBarButton()
            } else {
                self.setupRightBarButton(true)
            }
        } else {
          
            if team.joinMode == .TEAM_JOIN_MODE_APPLY {
                // Private Group
                if team.inviteMode == .TEAM_INVITE_MODE_ALL {
                    self.setupRightBarButton()
                } else {
                    self.setupRightBarButton(true)
                }
            } else if team.joinMode == .TEAM_JOIN_MODE_FREE {
                // Public Group
                if team.inviteMode == .TEAM_INVITE_MODE_ALL {
                    self.setupRightBarButton()
                } else {
                    self.setupRightBarButton(true)
                }
            } else {
                // Secret Group
                self.setupRightBarButton(true)
            }
        }
        
        if viewmodel.selectedType == .none {
            self.updateAllInfo()
        } else {
            self.updateDataContent(for: viewmodel.selectedType)
        }
        
       // viewmodel.updateTeamMembers()
        
        self.view.layoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    
    func setupGroupInfoContent() {
        contentStackView.addArrangedSubview(leavedView)
        leavedView.snp.makeConstraints({
            $0.height.equalTo(50)
        })

        groupDataInfo.forEach { view in
            groupDataView.addArrangedSubview(view)
        }
        contentStackView.addArrangedSubview(groupDataView)
        groupDataView.snp.makeConstraints({
            $0.leading.right.equalToSuperview()
        })
        
        groupBasicInfo.forEach { view in
            groupInfoView.addArrangedSubview(view)
        }
        contentStackView.addArrangedSubview(groupInfoView)
        groupInfoView.snp.makeConstraints({
            $0.leading.right.equalToSuperview()
        })
        
        groupSensitiveInfo.forEach { view in
            groupSensitiveView.addArrangedSubview(view)
        }
        contentStackView.addArrangedSubview(groupSensitiveView)
        groupSensitiveView.snp.makeConstraints({
            $0.leading.right.equalToSuperview()
        })
                
        preferencesInfo.forEach { view in
            preferencesView.addArrangedSubview(view)
        }
        contentStackView.addArrangedSubview(preferencesView)
        preferencesView.snp.makeConstraints({
            $0.leading.right.equalToSuperview()
        })

        if (isLeavedMember) {
            contentStackView.addArrangedSubview(TGTeamSetting(type: .clearAndDeleteChat, selector: #selector(self.onClickClearDeleteTeam), titleColor: .red).toSettingView(self))
        } else {
            contentStackView.addArrangedSubview(TGTeamSetting(type: .clearChat, selector: #selector(self.onClickClearChat), titleColor: .red).toSettingView(self))
        }
        
        ownerButtons.forEach { view in
            contentStackView.addArrangedSubview(view)
            view.isHidden = !viewmodel.isOwner
            view.snp.makeConstraints({
                $0.height.equalTo(40)
            })
        }
        
        contentStackView.addArrangedSubview(leaveButton)
        leaveButton.snp.makeConstraints {
            $0.height.equalTo(40)
        }
    }
    
    func updateDataContent(for type: SettingType) {
        switch type {
        case .groupName, .groupIntro, .groupAnnouncement, .myNickname:
            groupBasicInfo.filter { $0.type == type }.first?.setValue(viewmodel.getValue(for: type))
        case .groupIcon:
            groupBasicInfo.filter { $0.type == type }.first?.setImageUrl(viewmodel.getValue(for: type))
        case .groupInviteeApproval, .groupWhoCanInvite, .groupWhoCanEdit, .groupType:
            groupSensitiveInfo.filter { $0.type == type }.first?.setValue(viewmodel.getValue(for: type))
        case .muteNotification, .pinTop:
            preferencesInfo.filter { $0.type == type }.first?.setSwitchValue(viewmodel.getBoolValue(for: type))
        default:
            break
        }
                
        ownerButtons.forEach { button in
            button.isHidden = !viewmodel.isOwner
        }
    }
    
    // By Kit Foong (Update All info, when the Setting Type is .none)
    func updateAllInfo() {
        for item in groupBasicInfo {
            self.updateDataContent(for: item.type)
        }

        for item in groupSensitiveInfo {
            self.updateDataContent(for: item.type)
        }

        for item in preferencesInfo {
            self.updateDataContent(for: item.type)
        }
    }

    
    func showContactsPicker() {
        let config = TGContactsPickerConfig(title: "group_add_new_member".localized, rightButtonTitle: "add".localized, allowMultiSelect: true, maximumSelectCount: maximumTeamMemberAuthCompulsory, excludeIds: viewmodel.allTeamMembers)
        let vc = TGContactsPickerViewController(configuration: config, finishClosure: nil)
        vc.finishClosure = {[weak self] users in
            vc.navigationController?.popViewController(animated: true)
            let usernames = users.compactMap { $0.userName }
            self?.viewmodel.addMembers(usernames)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showRemoveMemberSelector() {
        let vc = TGRemoveMemberViewController(viewmodel.teamId)
        vc.members = viewmodel.removeMembersList
       
        vc.membersDidRemovedHandler = { [weak self] in
            guard let self = self else {return}
            MessageUtils.getTeamInfo(teamId: self.viewmodel.teamId, teamType: .TEAM_TYPE_NORMAL) { v2Team in
                if let v2Team = v2Team {
                    self.team = v2Team
                    self.viewmodel.team = v2Team
                    self.customNavigationBar.backItem.setTitle(self.viewmodel.team.name + "(\(self.viewmodel.team.memberCount))", for: .normal)
                }
            }
            
            self.viewmodel.getTeamMember { [weak self] done in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.checkMemberPermission()
                }
                
            }
            
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showViewMoreMembers() {
        let vc = TGMembersViewController(teamId: viewmodel.teamId, canEditTeamInfo: viewmodel.canEditTeamInfo)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onTapMember(member: TeamMember) {
        guard let accId = member.memberInfo?.accountId, let memberInfo = member.memberInfo else {
            return
        }
        if accId == RLSDKManager.shared.loginParma?.imAccid {
            RLSDKManager.shared.imDelegate?.didPressNameCard(memberId: accId)
        } else {
            
            TGNewFriendsNetworkManager.getUsersInfo(usersId: [], userNames: [accId]) {[weak self] users, error in
                guard let self = self, let model = users?.first else {
                    return
                }
                DispatchQueue.main.async {
                    
                    var titles = [model.name, "group_view_profile".localized]
                    
                    if model.followStatus == .eachOther {
                        titles.append("group_member_info_send_message".localized)
                    }
                    
                    if self.viewmodel.canEditTeamInfo {
                        if self.viewmodel.isOwner {
                            if memberInfo.memberRole == .TEAM_MEMBER_ROLE_NORMAL {
                                titles.append("group_make_admin".localized)
                            }
                            
                            if memberInfo.memberRole == .TEAM_MEMBER_ROLE_MANAGER {
                                titles.append("group_remove_admin".localized)
                            }
                            
                            titles.append("group_remove_member".localized)
                        } else if self.viewmodel.isManager {
                            if member.memberRole == .TEAM_MEMBER_ROLE_NORMAL {
                                titles.append("group_remove_member".localized)
                            }
                        }
                    }
                    
                    let actionsheetView = TGCustomActionsheetView(titles: titles)
                    if self.viewmodel.canEditTeamInfo {
                        actionsheetView.setColor(color: RLColor.main.warn, index: titles.count - 1)
                    }
                    actionsheetView.setColor(color: RLColor.normal.minor, index: 0)
                    actionsheetView.tag = 1
                    actionsheetView.notClickIndexs = [0]
                    actionsheetView.show()
                    actionsheetView.finishBlock = { [weak self] _, title, _ in
                        guard let self = self else { return }
                        switch title {
                        case "group_view_profile".localized:
                            RLSDKManager.shared.imDelegate?.didPressNameCard(memberId: accId)

                        case "group_member_info_send_message".localized:
                            let me = RLSDKManager.shared.loginParma?.imAccid ?? ""
                            let conversationId = "\(me)|1|\(accId)"
                            let vc = TGChatViewController(conversationId: conversationId, conversationType: 1)
                            self.navigationController?.pushViewController(vc, animated: true)
                        case "group_make_admin".localized:
                            self.viewmodel.makeAdmin(accId)
                        case "group_remove_admin".localized:
                            self.viewmodel.removeAdmin(accId)
                        case "group_remove_member".localized:
                            self.showAlert(title: nil, message: "team_member_remove_confirm".localized, buttonTitle: "confirm".localized, defaultAction: { _ in
                                self.viewmodel.kickMember(accId)
                            }, cancelTitle: "cancel".localized, cancelAction: nil)
                        default:
                            break
                        }
                    }
                    
                }
                
            }
            
        }
    }
    
    func uploadImage(_ image: UIImage) {
        let fileName = NSUUID().uuidString.lowercased() + ".jpg"
        let filepath = NSURL.fileURL(withPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        let data = image.jpegData(compressionQuality: 0.6)
        
        do {
            try data?.write(to: filepath, options: .atomic)
        } catch {
           // self.showFail("unable to write data")
            return
        }
       // self.showLoading()
        let uploadFilepath = filepath.absoluteString.replacingOccurrences(of: "file:///", with: "", options: .literal, range: nil)
        
        viewmodel.uploadGroupImage(uploadFilepath, onHideLoading: {
           // self.dismissAlert()
        })
    }

}

extension TGTeamChatDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewmodel.membersCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TGChatMemberCell", for: indexPath) as! TGChatMemberCell
        if viewmodel.members.indices.contains(indexPath.row) {
            cell.setData(viewmodel.members[indexPath.row])
        }
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // let member = viewmodel.members[indexPath.row]
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ScreenWidth / 5, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
}

extension TGTeamChatDetailViewController {
    // Selectors
    @objc func onClickSearchMessages() {
//        if let session = viewmodel.session {
//            let vc = SearchChatHistoryTableViewController(session: session)
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    @objc func onClickClearChat() {
        let alert = TGAlertController(title: "confirm_delete_record".localized, message: nil, style: .alert)
        alert.addAction(TGAlertAction(title: "confirm".localized, style: TGAlertActionStyle.destructive, handler: { [weak self] _ in
            self?.viewmodel.deleteAllMessages {
                self?.clearGroupMessageCall?()
            }
            
        }))
        self.presentPopup(alert: alert)
    }
    
    @objc func onSetTopValueChange(_ sender: UISwitch) {
        viewmodel.sticktopChat(isOn: sender.isOn, conversationId: self.conversationId)
    }
    
    @objc func onClickGroupNickname() {
        guard let info = viewmodel.myTeamInfo else { return }
        let vc = TGGroupInfoEditViewController.init(editType: .nickname, editText: info.teamNick ?? "", canEdit: true, viewmodel: viewmodel)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.onReloadUI = { [weak self] in
            self?.checkMemberPermission()
        }
    }
    
    @objc func onClickGroupImage() {
        guard viewmodel.canEditTeamInfo else {
           // self.view.makeToast("group_admin_edit_only".localized, duration: 0.5, position: CSToastPositionBottom)
            return
        }
        
        func showImagePicker(type: UIImagePickerController.SourceType, alert: TGAlertController) {
            alert.dismiss(animated: true, completion: {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = type
                picker.allowsEditing = true
                self.present(picker, animated: true, completion: nil)
            })
        }
        
        let alert = TGAlertController(title: nil, message: "set_group_avatar".localized, style: .actionsheet, sheetCancelTitle: "cancel".localized)
        
        alert.addAction(TGAlertAction(title: "choose_from_camera".localized, style: TGAlertSheetActionStyle.default, handler: { _ in
            showImagePicker(type: .camera, alert: alert)
        }))
        
        alert.addAction(TGAlertAction(title: "choose_from_photo".localized, style: TGAlertSheetActionStyle.default, handler: { _ in
            showImagePicker(type: .photoLibrary, alert: alert)
        }))
        
        self.presentPopup(alert: alert)
    }
    
    @objc func onClickGroupName() {
       
        let vc = TGGroupInfoEditViewController.init(editType: .name, editText: viewmodel.team.name, canEdit: viewmodel.canEditTeamInfo, viewmodel: viewmodel)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.onReloadUI = { [weak self] in
            self?.checkMemberPermission()
        }
    }
    
    @objc func onClickQRCode() {
        RLSDKManager.shared.imDelegate?.didPressQRCodeVC(qrType: .group, qrContent: viewmodel.teamId, descStr: "group_scan_qr_to_join_group".localized)
    }
    
    @objc func onClickGroupIntro() {
        let vc = TGGroupInfoEditViewController.init(editType: .description, editText: viewmodel.team.intro.orEmpty,canEdit: viewmodel.canEditTeamInfo, viewmodel: viewmodel)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.onReloadUI = { [weak self] in
            self?.checkMemberPermission()
        }
    }
    
    @objc func onClickGroupAnnouncement() {
//        viewmodel.selectedType = .groupAnnouncement
//        let vc = NTESTeamAnnouncementListViewController()
//        vc.team = viewmodel.team
//        vc.canCreateAnnouncement = viewmodel.canEditTeamInfo
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onClickGroupType() {
        let alert = TGAlertController(title: nil, message: "group_verify_method".localized, style: .actionsheet, sheetCancelTitle: "cancel".localized)
        
        alert.addAction(TGAlertAction(title: "group_public".localized, style: TGAlertSheetActionStyle.default, handler: {[weak self] _ in
            self?.viewmodel.updateJoinMode(.TEAM_JOIN_MODE_FREE)
        }))
        
        alert.addAction(TGAlertAction(title: "group_ask_to_join".localized, style: TGAlertSheetActionStyle.default, handler: { [weak self]_ in
            self?.viewmodel.updateJoinMode(.TEAM_JOIN_MODE_APPLY)
        }))
        
        alert.addAction(TGAlertAction(title: "group_private".localized, style: TGAlertSheetActionStyle.default, handler: {[weak self] _ in
            self?.viewmodel.updateJoinMode(.TEAM_JOIN_MODE_INVITE)
        }))
        
        self.presentPopup(alert: alert)
    }
    
    @objc func onClickInvitor() {
        let alert = TGAlertController(title: nil, message: "group_invite_others".localized, style: .actionsheet, sheetCancelTitle: "cancel".localized)
        
        alert.addAction(TGAlertAction(title: "group_admin_only".localized, style: TGAlertSheetActionStyle.default, handler: {[weak self] _ in
            self?.viewmodel.updateInviteMode(.TEAM_INVITE_MODE_MANAGER)
        }))
        
        alert.addAction(TGAlertAction(title: "group_anyone".localized, style: TGAlertSheetActionStyle.default, handler: {[weak self] _ in
            self?.viewmodel.updateInviteMode(.TEAM_INVITE_MODE_ALL)
        }))
        
        self.presentPopup(alert: alert)
    }
    
    @objc func onClickEditPermission() {
        let alert = TGAlertController(title: nil, message: "group_who_can_edit".localized, style: .actionsheet, sheetCancelTitle: "cancel".localized)
        
        alert.addAction(TGAlertAction(title: "group_admin_only".localized, style: TGAlertSheetActionStyle.default, handler: {[weak self] _ in
            self?.viewmodel.updateInfoMode(.TEAM_UPDATE_INFO_MODE_MANAGER)
        }))
        
        alert.addAction(TGAlertAction(title: "group_anyone".localized, style: TGAlertSheetActionStyle.default, handler: {[weak self] _ in
            self?.viewmodel.updateInfoMode(.TEAM_UPDATE_INFO_MODE_ALL)
        }))
        
        self.presentPopup(alert: alert)
    }
    
    @objc func onClickInviteeApproval() {
        if viewmodel.membersCount > maximumTeamMemberAuthCompulsory {
           // self.showError(message: String(format: "text_chage_verification_mode_not_allow".localized, "\(maximumTeamMemberAuthCompulsory)"))
            return
        }
        
        let alert = TGAlertController(title: nil, message: "group_invitee_approval".localized, style: .actionsheet, sheetCancelTitle: "cancel".localized)
        
        alert.addAction(TGAlertAction(title: "group_required".localized, style: TGAlertSheetActionStyle.default, handler: {[weak self] _ in
            self?.viewmodel.updateBeInviteMode(.TEAM_AGREE_MODE_AUTH)
        }))
        
        alert.addAction(TGAlertAction(title: "group_not_required".localized, style: TGAlertSheetActionStyle.default, handler: {[weak self] _ in
            self?.viewmodel.updateBeInviteMode(.TEAM_AGREE_MODE_NO_AUTH)
        }))
        
        self.presentPopup(alert: alert)
    }
    
    @objc func onClickMedia() {
        let vc = TGChatMediaViewController(conversationId: self.conversationId)
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func onClickChatWallpaper() {
        navigationController?.pushViewController(TGChatWallpaperViewController(), animated: true)
    }
    
    @objc func onMuteNotification(_ sender: UISwitch) {
        viewmodel.onActionMute(isOn: sender.isOn)
    }
    
    @objc func onClickTransferGroup() {
        func transferGroup(_ isLeaving: Bool) {
            let config = TGContactsPickerConfig(title: "group_transfer".localized, rightButtonTitle: "transfer".localized, members: viewmodel.members.compactMap { member in
                if member.memberInfo?.accountId != RLSDKManager.shared.loginParma?.imAccid {
                    return member.memberInfo?.accountId
                }
                return nil
            })
            
            let vc = TGContactsPickerViewController(configuration: config, finishClosure: nil)
            vc.finishClosure = {[weak self] users in
                guard let newOwner = users.first, let self = self else { return }
                
                if self.viewmodel.team.agreeMode == .TEAM_AGREE_MODE_NO_AUTH {
                    self.viewmodel.updateBeInviteMode(.TEAM_AGREE_MODE_AUTH)
                }
                
                self.viewmodel.transferGroup(to: newOwner.userName, isLeaving: isLeaving, onDismiss: {
                    self.isActionSuccess = true
                    if isLeaving {
                        self.navigationController?.popToRootViewController(animated: true)
                    } else {
                        vc.navigationController?.popViewController(animated: true)
                        self.updateDataContent(for: .groupAnnouncement)
                        self.updateDataContent(for: .groupIntro)
                    }
                })
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let alert = TGAlertController(title: nil, message: "group_transfer".localized, style: .actionsheet, sheetCancelTitle: "cancel".localized)
        
        alert.addAction(TGAlertAction(title: "group_transfer".localized, style: TGAlertSheetActionStyle.default, handler: { _ in
            self.leaveButton.isHidden = false
            transferGroup(false)
        }))
        
        alert.addAction(TGAlertAction(title: "group_transfer_group_exit".localized, style: TGAlertSheetActionStyle.default, handler: { _ in
            transferGroup(true)
        }))
        
        self.presentPopup(alert: alert)
    }
    
    @objc func onClickDismissTeam() {
        let alert = TGAlertController(title: nil, message: "group_confirm_dismiss".localized, style: .actionsheet, sheetCancelTitle: "cancel".localized)
        alert.addAction(TGAlertAction(title: "confirm".localized, style: TGAlertSheetActionStyle.destructive, handler: { [weak self] _ in
            self?.viewmodel.dismissGroup(onDismiss: {
                self?.isActionSuccess = true
                self?.navigationController?.popToRootViewController(animated: true)
            })
        }))
        self.presentPopup(alert: alert)
    }
    
    @objc func onClickQuitTeam() {
        let alert = UIAlertController(title: "group_confirm_to_leave".localized, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "confirm".localized, style: UIAlertAction.Style.default, handler: { [weak self] action in
            guard let self = self else { return }
            self.viewmodel.quitGroup {
                DispatchQueue.main.async {
                    self.isActionSuccess = true
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized, style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func onClickClearDeleteTeam() {
        let alert = UIAlertController(title: "group_confirm_clear_delete".localized, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "confirm".localized, style: UIAlertAction.Style.default, handler: { [weak self] action in
            guard let self = self else { return }
//            self.viewmodel.clearAndDelete(onDismiss: {
//                DispatchQueue.main.async {
//                    self.isActionSuccess = true
//                    self.navigationController?.popToRootViewController(animated: true)
//                }
//            })
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized, style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension TGTeamChatDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            picker.dismiss(animated: true) {
                self.uploadImage(image)
            }
        }
    }
}

extension TGTeamChatDetailViewController: TGChatMemberCellDelegate {
    func didPressAvatarAction(member: TeamMember) {
        onTapMember(member: member)
    }
    
    func didPressAddAction(member: TeamMember) {
        if member.isAdd {
            self.showContactsPicker()
        } else if member.isReduce {
            self.showRemoveMemberSelector()
        } else if member.isViewMore {
            self.showViewMoreMembers()
        } 
    }
    
    
}
