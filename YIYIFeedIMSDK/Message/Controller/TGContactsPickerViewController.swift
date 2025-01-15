//
//  TGContactsPickerViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/2.
//

import UIKit
import NIMSDK

typealias ContactPickerFinishClosure = ([ContactData]) -> Void
typealias ContactPickerCancelClosure = () -> Void

class TGContactsPickerViewController: TGChatFriendListViewController {

    var model: TGmessagePopModel?
    var sessionId: String?
    var postContent = TGPostContentView(frame: .zero)
    let configuration: TGContactsPickerConfig
    var isSearching: Bool = false
    /// Datasource
    var teamData: [ContactData] = []
    var recentChatData: [ContactData] = []
    var friendData: [ContactData] = []
    var allData = [ContactData]()
    var searchResults = [ContactData]()
    var friendOffset = 0
    /// 自定义回调处理
    var finishClosure: ContactPickerFinishClosure?
    var cancelClosure: ContactPickerCancelClosure?
    var allowSearchForOtherPeople: Bool = true
    var isInnerFeed: Bool = false
    var isCreatNewChat = false //是否新建会话
    var isP2PInvite = false //是否p2p邀请其他人加入
    var isProfile: Bool = false
    var isTeamMeeting: Bool = false
    // By Kit Foong (Check is it mini program)
    var isMiniProgram: Bool = false
    var allContactData: ContactData?
    var isAllSelected: Bool = false
    
    private var apiDebouncer = Debouncer(delay: 0.5)
    
    init(model: TGmessagePopModel? = nil,
         configuration: TGContactsPickerConfig,
         isInnerFeed: Bool = false,
         finishClosure: ContactPickerFinishClosure?, cancelClosure: ContactPickerCancelClosure? = nil,
         isProfile: Bool = false,
         isTeamMeeting: Bool = false) {
        
        self.model = model
        self.configuration = configuration
        self.isInnerFeed = isInnerFeed
        self.finishClosure = finishClosure
        self.cancelClosure = cancelClosure
        self.isProfile = isProfile
        self.isTeamMeeting = isTeamMeeting
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatItem?.setTitleColor(choosedDataSource.count > 0 ? TGAppTheme.red : TGAppTheme.headerTitleGrey, for: .normal)
        chatItem?.isEnabled =  choosedDataSource.count > 0 ? true : false
        self.allowSearchForOtherPeople = configuration.allowSearchForOtherPeople
        searchTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func configureNavTitle() {
        rightButtonTitle = configuration.rightButtonTitle
        customNavigationBar.title = configuration.title
    }
    
    override func creatTableView() {
        super.creatTableView()
        self.friendListTableView.allowsMultipleSelection = configuration.allowMultiSelect
        self.friendListTableView.mj_footer = SCRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreFriends))
    }
    
    override func creatTopSubView() {
        setupShareView()
        super.creatTopSubView()
        setupActions()
    }
    
    override func createCollectionView() {
        super.createCollectionView()
    }
    
    override func rightButtonClick() {
        guard TGReachability.share.isReachable() else {
           // showError(message: "network_is_not_available".localized)
            return
        }
        
        guard let model = model else {
            var array = choosedDataSource as! [ContactData]
            if self.isCreatNewChat && array.count > 1 {
                self.finishClosure?(array)
                return
            }
            if self.isP2PInvite {
                self.finishClosure?(array)
                return
            }
            if let data = allContactData, isAllSelected {
                array.removeAll()
                array.append(data)
            }
            self.navigationController?.popViewController(animated: true)
            self.finishClosure?(array)
            return
        }
        
        if finishClosure != nil {
            let array = choosedDataSource as! [ContactData]
            self.finishClosure?(array)
            return
        }
        
        switch model.contentType {
        case .sticker:
            shareStickerToChat()
        case .miniProgram:
            shareMiniProgramToChat()
        case .pic:
            if model.isQRCode { //发送二维码图片
                sharePicToChat()
            } else {
                sharePostToChat()
            }
        case .voucher:
            shareVoucherToChat()
        case .referral:
            shareReferralToChat()
        default:
            sharePostToChat()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupActions() {
        guard configuration.enableButtons else {
            return
        }
        
        func actionView(imageName: String, title: String) -> UIView {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            let icon = UIImageView(image: UIImage(named: imageName))
            icon.frame = CGRect(origin: CGPoint(x: 16, y: 0), size: CGSize(width: 20, height: 20))
            icon.centerY = view.centerY
            icon.tintColor = .lightGray
            view.addSubview(icon)
            let title = UILabel(text: title, font: UIFont.systemFont(ofSize: 14) , textColor: RLColor.main.content, alignment: .left)
            view.addSubview(title)
            title.frame = CGRect(x: icon.frame.maxX + 16, y: 0, width: UIScreen.main.bounds.width - icon.frame.maxX - 16 - 16, height: 16)
            title.centerY = icon.centerY
            return view
        }
        
        let findPeopleButton = actionView(imageName: "IMG_ico_search", title: "contact_select_search_people".localized)
        findPeopleButton.addAction {
//            let vc = TSNewFriendsVC.vc()
//            self.navigationController?.pushViewController(vc, animated: true)
        }
        stackview.addArrangedSubview(findPeopleButton)
        findPeopleButton.snp.makeConstraints { $0.height.equalTo(50) }
        
        let scannerButton = actionView(imageName: "ic_qr", title: "contact_select_friend_scan".localized)
        scannerButton.addAction {
            RLSDKManager.shared.imDelegate?.didPressQRCodeVC(qrType: .user, qrContent: RLSDKManager.shared.loginParma?.imAccid ?? "", descStr: "")
        }
        stackview.addArrangedSubview(scannerButton)
        scannerButton.snp.makeConstraints { $0.height.equalTo(50) }
    }
    
    func setupShareView() {
        guard let model = model else { return }
        if model.isQRCode {
            return
        }
        postContent.model = model
        stackview.addArrangedSubview(postContent)
        postContent.snp.makeConstraints {
            $0.height.equalTo(100)
        }
    }
    
    //TO-DO: Confirm again about the sequence of friends & groups, and should separate section or not
    func fetchDatas() {
        if let members = configuration.members {
            allData = members.compactMap { ContactData(userName: $0) }
            //隐藏Video Call 模式下的 'All'
            if isTeamMeeting == false {
                allContactData = ContactData(userName: "rw_text_all_people".localized)
                if let allContact = allContactData {
                    allData.insert(allContact, at: 0)
                }
            }
            updateTable()
            
        } else {
            let dispatchGroup = DispatchGroup()
            
            if configuration.enableRecent {
                dispatchGroup.enter()
                fetchRecentChats {
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.enter()
            
            fetchFriends {
                dispatchGroup.leave()
            }
            
            
            if configuration.enableTeam {
                dispatchGroup.enter()
                fetchTeams {
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.configureData()
            }
        }
    }
    
    func configureData() {
        allData.removeAll()
        
        self.updateFriendListData(model: nil)
        
        if configuration.enableRecent {
            allData.append(contentsOf: recentChatData)
        }
        
        if configuration.enableTeam {
            allData.append(contentsOf: teamData)
        }
        
        allData.append(contentsOf: friendData)
        
        updateTable()
    }
    
    private func updateTable() {
        if allData.count > 0 {
            searchView.isHidden = false
            friendListTableView.reloadData()
        } else {
           // friendListTableView.show(placeholderView: .empty)
        }
        friendListTableView.mj_header.endRefreshing()
    }
    
    override func refresh() {
        friendOffset = 0
        if !isSearching {
            searchResults.removeAll()
            isSearching = false
            searchTextfield.text = nil
            keyword = ""
            view.endEditing(true)
            fetchDatas()
        } else {
            self.searchResults = allData.filter { $0.displayname.lowercased().contains(keyword.lowercased())}
            
            if allowSearchForOtherPeople == false {
                self.friendListTableView.mj_header.endRefreshing()
                self.friendListTableView.reloadData()
                return
            }
            
            let extras = TGAppUtil.getUserID(remarkName: keyword)
            
            apiDebouncer.handler = {
                TGNewFriendsNetworkManager.searchMyFriend(offset: 0, keyWordString: self.keyword, extras: extras) {[weak self] userModels, error in
                    defer { self?.friendListTableView.mj_header.endRefreshing() }
                    guard let weakSelf = self else {
                        return
                    }
                    DispatchQueue.main.async {
                        weakSelf.friendListTableView.mj_footer.resetNoMoreData()
                    }
                    
                    guard let datas = userModels else {
                       // weakSelf.friendListTableView.show(placeholderView: .empty)
                        return
                    }
                    weakSelf.friendOffset = datas.count
                    weakSelf.updateFriendListData(model: datas)
                    
                    if error != nil {
                       // weakSelf.friendListTableView.show(placeholderView: .network)
                        return
                    }
                    
                    weakSelf.searchResults = weakSelf.searchResults + datas.compactMap { result in
                        if weakSelf.searchResults.contains( where: { $0.userId == ContactData(model: result).userId}) {
                            return nil
                        }
                        return ContactData(model: result)
                    }
                    
                    DispatchQueue.main.async {
                        if weakSelf.searchResults.isEmpty {
                          //  weakSelf.friendListTableView.show(placeholderView: .empty)
                        }
                        weakSelf.friendListTableView.reloadData()
                    }
                }

            }
            apiDebouncer.execute()
        }
    }
    
    func leftBtnClick() {
        self.view.endEditing(true)
        self.cancelClosure?()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func loadMoreFriends() {
        if configuration.members != nil {
            self.friendListTableView.mj_footer.endRefreshingWithNoMoreData()
        } else {
            let topTeam = recentChatData.filter{ $0.isTeam == true }
            let offset = isSearching ? searchResults.filter { $0.isTeam == false }.count : allData.count - teamData.count - topTeam.count
            let extras = TGAppUtil.getUserID(remarkName: keyword)
            TGNewFriendsNetworkManager.searchMyFriend(offset: friendOffset, keyWordString: self.keyword, extras: extras) {[weak self] userModels, error in
                guard let weakSelf = self else {
                    return
                }
                
                guard var datas = userModels else {
                    weakSelf.friendListTableView.mj_footer.endRefreshing()
                    return
                }
                
                weakSelf.friendOffset = weakSelf.friendOffset + datas.count
                datas.enumerated().forEach { (index, userInfo) in
                    if userInfo.isBannedUser {
                        let bannedUsername = String(format: "user_deleted_displayname".localized,userInfo.name)
                        datas[index].name = bannedUsername
                    }
                }
                
                if datas.count < TGNewFriendsNetworkManager.limit {
                    weakSelf.friendListTableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    weakSelf.friendListTableView.mj_footer.endRefreshing()
                }
                
                weakSelf.updateFriendListData(model: datas)
                
                if weakSelf.isSearching {
                    weakSelf.searchResults = weakSelf.searchResults + datas.compactMap { ContactData(model: $0) }
                } else {
                    var friends = datas.compactMap { ContactData(model: $0) }
                    
                    //
                    if weakSelf.recentChatData.count > 0 {
                        let existingFriendIds = weakSelf.recentChatData.filter { !$0.isTeam }.compactMap { $0.userName }
                        friends.removeAll(where: { existingFriendIds.contains($0.userName) })
                    }
                    
                    weakSelf.allData = weakSelf.allData + friends
                }
                weakSelf.friendListTableView.reloadData()
            }
            
        }
    }
    
    private func updateFriendListData(model: [UserInfoModel]?) {
        if let excludeIds = configuration.excludeIds {
            if let models = model {
                self.friendData += models.compactMap { ContactData(model: $0) }
            }
            let friendList = self.friendData.compactMap { $0.userName } + self.recentChatData.filter{$0.isTeam == false}.compactMap{ $0.userName }
            let friendInGroup = friendList.filter { excludeIds.contains($0) }
            
            for(_, username) in friendInGroup.enumerated() {
                if friendList.contains(where: { $0 == username }) && !self.originDataSource.contains(username) {
                    self.originDataSource.append(username)
                }
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        apiDebouncer.handler = {
            self.friendListTableView.removePlaceholderViews()
            if (self.searchTextfield.text ?? "").isEmpty {
                self.isSearching = false
                self.friendListTableView.reloadData()
            } else {
                self.searchResults.removeAll()
                self.keyword = self.searchTextfield.text ?? ""
                self.refresh()
            }
        }
        apiDebouncer.execute()
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        searchResults.removeAll()
        isSearching = true
        friendListTableView.reloadData()
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchResults.removeAll()
        
        keyword = searchTextfield.text ?? ""
        keyword = keyword.replacingOccurrences(of: " ", with: "")
        view.endEditing(true)
        isSearching = !keyword.isEmpty
        if isSearching {
            self.friendListTableView.mj_header.beginRefreshing()
            return true
        }
        friendListTableView.reloadData()
        return true
    }
    
    //    override func populateHeadImage(_ chooseArray: NSMutableArray) {
    //        if chooseArray.count > 1 {
    //            if !isProfile {
    //                chatItem?.setTitle("next".localized, for: .normal)
    //                //chatItem?.sizeToFit()
    //            }
    //        } else {
    //            chatItem?.setTitle(rightButtonTitle, for: .normal)
    //        }
    //
    //        chooseArray.enumerated().forEach { (index, contact) in
    //            let contact = contact as! ContactData
    //            let headerButton: ContactPickerHeaderButton = ContactPickerHeaderButton(frame: CGRect(x: index * (headerWidth + headerSpace) + headerSpace, y: (49 - headerWidth) / 2, width: headerWidth, height: headerWidth))
    //            headerButton.layer.masksToBounds = true
    //            headerButton.layer.cornerRadius = CGFloat(headerWidth) / 2.0
    //            headerButton.contact = contact
    //            headerButton.tag = index
    //            headerButton.addTarget(self, action: #selector(deleteUser(_:)), for: .touchUpInside)
    //            let placeholderName = contact.isTeam ? AvatarView.PlaceholderType.group.rawValue : AvatarView.PlaceholderType.unknown.rawValue
    //
    //            if contact.imageUrl.isEmpty {
    //                headerButton.setImage(UIImage(named: placeholderName), for: .normal)
    //            } else {
    //                headerButton.sd_setImage(with: URL(string: contact.imageUrl), for: .normal, placeholderImage: UIImage(named: placeholderName))
    //            }
    //
    //            let iconImage: UIImageView = UIImageView(frame: CGRect(x: headerButton.left + headerButton.frame.width * 0.65, y: headerButton.top + headerButton.frame.width * 0.65, width: headerButton.frame.width * 0.35, height: headerButton.frame.width * 0.35)).configure { $0.contentMode = .scaleAspectFill }
    //            iconImage.layer.masksToBounds = true
    //            iconImage.layer.cornerRadius = headerButton.frame.width * 0.35 / 2.0
    //            if contact.verifiedType == "" {
    //                iconImage.isHidden = true
    //            } else {
    //                iconImage.isHidden = false
    //                if contact.verifiedIcon == "" {
    //                    switch contact.verifiedType {
    //                    case "user":
    //                        iconImage.image = UIImage(named: "IMG_pic_identi_individual")
    //                    case "org":
    //                        iconImage.image = UIImage(named: "IMG_pic_identi_company")
    //                    default:
    //                        iconImage.image = nil
    //                    }
    //                } else {
    //                    let iconURL = URL(string: contact.verifiedIcon)
    //                    iconImage.sd_setImage(with: iconURL, completed: nil)
    //                }
    //            }
    //            choosedScrollView.addSubview(headerButton)
    //            choosedScrollView.addSubview(iconImage)
    //        }
    //    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell: TGContactPickerCell = tableView.cellForRow(at: indexPath) as! TGContactPickerCell
        
        for (_, model) in originDataSource.enumerated() {
            let username: String = model as! String
            if username == cell.contactData?.userName {
                return
            }
        }
        
        guard let contactData = cell.contactData, contactData.isBannedUser == false else {
          //  self.showTopIndicator(status: .faild, "alert_banned_description".localized)
            return
        }
        
        if cell.chatButton.isSelected {
            for (index, model) in choosedDataSource.enumerated() {
                let userinfo: ContactData = model as! ContactData
                if userinfo.userName == contactData.userName {
                    
                    let collectionIndexPath = IndexPath(row: index, section: 0)
                    self.collectionView.performBatchUpdates {
                        choosedDataSource.removeObject(at: index)
                        self.collectionView.deleteItems(at: [collectionIndexPath])
                    }
                    break
                }
            }
            collectionView.isHidden = choosedDataSource.count == 0
            cell.chatButton.isSelected = !cell.chatButton.isSelected
        } else {
            if contactData.userName == "rw_text_all_people".localized {
                isAllSelected = true
                rightButtonClick()
                return
            }
            
            if choosedDataSource.count >= configuration.maximumSelectCount {
              //  self.showTopIndicator(status: .faild, String(format: "maximum_contact_select".localized, configuration.maximumSelectCount))
                return
            }
            choosedDataSource.insert(contactData, at: choosedDataSource.count)
            let collectionIndexPath = IndexPath(row: choosedDataSource.count - 1, section: 0)
            self.collectionView.performBatchUpdates {
                self.collectionView.insertItems(at: [collectionIndexPath])
            }
            collectionView.isHidden = choosedDataSource.count == 0
            cell.chatButton.isSelected = !cell.chatButton.isSelected
        }
        
        updateNumberOfSelection()
        chatItem?.setTitleColor(choosedDataSource.count > 0 ? TGAppTheme.red : TGAppTheme.headerTitleGrey, for: .normal)
        chatItem?.isEnabled = choosedDataSource.count > 0 ? true : false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indentifier = "chatfiendlistcell"
        var cell = tableView.dequeueReusableCell(withIdentifier: indentifier) as? TGContactPickerCell
        if cell == nil {
            cell = TGContactPickerCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: indentifier)
        }
        
        cell?.currentChooseArray = choosedDataSource
        cell?.originData = originDataSource
        cell?.selectionStyle = .none
        
        if isSearching == true {
            guard searchResults.count != 0 else { return cell! }
            
            if let result = searchResults[safe: indexPath.row] {
                cell?.contactData = result
            }
        } else {
            guard allData.count != 0 else { return cell! }
            
            if let result = allData[safe: indexPath.row] {
                cell?.contactData = result
            }
        }
        cell?.delegate = self
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isSearching {
            friendListTableView.mj_footer.isHidden = allData.count < TGNewFriendsNetworkManager.limit
        } else {
            friendListTableView.mj_footer.isHidden = searchResults.count < TGNewFriendsNetworkManager.limit
        }
        return isSearching ? searchResults.count : allData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return choosedDataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactsSelecletdCell", for: indexPath) as? ContactsSelecletdCell, let data = choosedDataSource[indexPath.item] as? ContactData {
            cell.setData(model: data)
            cell.delegate = self
            return cell
        }
        return UICollectionViewCell()
    }
}

/// 获取data
extension TGContactsPickerViewController {
    func fetchTeams(_ completion: @escaping EmptyClosure) {
        if let teams = NIMSDK.shared().teamManager.allMyTeams() {
            
            teamData = teams.filter { $0.type == NIMTeamType.advanced }.compactMap { ContactData(team: $0) }
            
            if recentChatData.count > 0 {
                let existingTeamIds = recentChatData.filter { $0.isTeam }.compactMap { $0.userName }
                teamData.removeAll(where: { existingTeamIds.contains($0.userName)})
            }
            completion()
        }
    }
    
    func fetchRecentChats(_ completion: @escaping EmptyClosure) {
        recentChatData.removeAll()
        var recentsData = [String]()
        let dispatchGroup = DispatchGroup()
        NIMSDK.shared().v2ConversationService.getConversationList(0, limit: 100){[weak self] result in
            if let recents = result.conversationList?.filter({ conversation in
                conversation.stickTop == true
            }) {
                for recent in recents {
                    if recent.type == .CONVERSATION_TYPE_TEAM {
                        let sessionId = MessageUtils.conversationTargetId(recent.conversationId)
                        dispatchGroup.enter()
                        NIMSDK.shared().v2TeamService.getTeamInfo(sessionId, teamType: .TEAM_TYPE_NORMAL) { team in
                            let data = ContactData(team: team)
                            self?.recentChatData.append(data)
                            dispatchGroup.leave()
                        }
                    } else if recent.type == .CONVERSATION_TYPE_P2P {
                        let userName = MessageUtils.conversationTargetId(recent.conversationId)
                            recentsData.append(userName)
                    }
                }
            }
        }
        dispatchGroup.notify(queue: .global()){
            if recentsData.count == 0 {
                completion()
                return
            }
            TGNewFriendsNetworkManager.getUsersInfo(usersId: [], userNames: recentsData) { users, error in
                if let users = users {
                    for userinfo in users {
                        let data = ContactData(model: userinfo)
                        self.recentChatData.append(data)
                    }
                    completion()
                } else {
                    completion()
                }
            }
            
            
        }
        
    }
    
    func fetchFriends(_ completion: @escaping EmptyClosure) {
        TGNewFriendsNetworkManager.searchMyFriend(offset: 0, keyWordString: nil) {[weak self] userModels, error in
            guard let self = self else {
                return
            }
            defer {
                self.friendListTableView.mj_header.endRefreshing()
            }
            // 获取数据失败
            if let error = error {
               // self.friendListTableView.show(placeholderView: .network)
                return
            }
            
            // 获取数据成功
            guard let datas = userModels else {
                completion()
                return
            }
            
            if datas.count < TGNewFriendsNetworkManager.limit {
                self.friendListTableView.mj_footer.endRefreshingWithNoMoreData()
            } else {
                self.friendListTableView.mj_footer.endRefreshing()
            }
            
            self.updateFriendListData(model: datas)
            self.friendOffset = datas.count
            datas.forEach { userInfo in
                var userInfo = userInfo
                if userInfo.isBannedUser {
                    let bannedUsername = String(format: "user_deleted_displayname".localized,userInfo.name)
                    userInfo.name = bannedUsername
                }
            }
            self.friendData = datas.compactMap {
                ContactData(model: $0)
            }
            // Avoid duplicate contact from recent section
            if self.recentChatData.count > 0 {
                let existingFriendIds = self.recentChatData.filter { !$0.isTeam }.compactMap { $0.userName }
                self.friendData.removeAll(where: { existingFriendIds.contains($0.userName) })
            }
            completion()
        }
    }
}

/// handler actions
extension TGContactsPickerViewController {
    func shareStickerToChat() {
        guard let sticker = model else { return }
        
//        let attachment = IMStickerCardAttachment()
//        attachment.stickerCardAttachment(with: sticker)
//        
//        let custom = NIMCustomObject()
//        custom.attachment = attachment
//        
//        choosedDataSource.forEach {
//            let contact = $0 as! ContactData
//            let session = NIMSession(contact.userName, type:  contact.isTeam ? .team : .P2P)
//            let message = NIMMessage()
//            message.messageObject = custom
//            message.text = sticker.owner
//            try? NIMSDK.shared().chatManager.send(self.updateApnsPayload(message, session.sessionId, contact.isTeam), to: session)
//        }
//        
//        showTopIndicator(status: .success, "select_friend_success_sent".localized)
    }
    
    func shareMiniProgramToChat() {
        guard let model = model else { return }
        
        let content = IMMiniProgramAttachment()
        content.appId = model.appId
        content.path = model.path
        content.title = model.owner
        content.desc = model.content
        content.imageURL = model.coverImage
        content.contentType = "\(model.contentType.messageTypeID)"
        
        let custom = NIMCustomObject()
        custom.attachment = content as! any NIMCustomAttachment
        
        choosedDataSource.forEach {
            let contact = $0 as! ContactData
            let message = NIMMessage()
            message.messageObject = custom
            let session = NIMSession(contact.userName, type:  contact.isTeam ? .team : .P2P)
            try? NIMSDK.shared().chatManager.send(self.updateApnsPayload(message, session.sessionId, contact.isTeam), to: session)
        }
        
       // showTopIndicator(status: .success, "select_friend_success_sent".localized)
    }
    
    func sharePostToChat() {
        guard let model = model else { return }
        
        let content = IMSocialPostAttachment()
//        content.socialPostMessage(with: model)
//        
//        let custom = NIMCustomObject()
//        custom.attachment = content
//        
//        choosedDataSource.forEach {
//            let contact = $0 as! ContactData
//            let message = NIMMessage()
//            message.messageObject = custom
//            let session = NIMSession(contact.userName, type:  contact.isTeam ? .team : .P2P)
//            try? NIMSDK.shared().chatManager.send(self.updateApnsPayload(message, session.sessionId, contact.isTeam), to: session)
//        }
        
       // showTopIndicator(status: .success, "select_friend_success_sent".localized)
    }
    
    func shareVoucherToChat() {
        guard let model = model else { return }
        
        let content = IMVoucherAttachment()
       // content.voucherPostMessage(with: model)
        
//        let custom = NIMCustomObject()
//        custom.attachment = content
//        
//        choosedDataSource.forEach {
//            let contact = $0 as! ContactData
//            let message = NIMMessage()
//            message.messageObject = custom
//            let session = NIMSession(contact.userName, type:  contact.isTeam ? .team : .P2P)
//            try? NIMSDK.shared().chatManager.send(self.updateApnsPayload(message, session.sessionId, contact.isTeam), to: session)
//        }
        
        //showTopIndicator(status: .success, "select_friend_success_sent".localized)
    }
    
    func shareReferralToChat() {
        guard let model = model else { return }
//        var imageURL: String = ""
//        
//        let group = DispatchGroup()
//        group.enter()
//        
//        model.coverImage = model.coverImage.replacingOccurrences(of: "file:///", with: "", options: NSString.CompareOptions.literal, range: nil)
//        NIMSDK.shared().resourceManager.upload(model.coverImage, progress: nil) { [weak self] (urlString, error) in
//            if error == nil, let urlString = urlString {
//                imageURL = urlString
//            } else {
//                print("Error uploading image: \(error?.localizedDescription ?? "Unknown error")")
//            }
//            group.leave()
//        }
//        
//        group.notify(queue: .main) {
//            let content = IMReferralAttachment()
//            model.coverImage = imageURL
//            content.referralPostMessage(with: model)
//            
//            let custom = NIMCustomObject()
//            custom.attachment = content
//            
//            self.choosedDataSource.forEach {
//                let contact = $0 as! ContactData
//                let message = NIMMessage()
//                message.messageObject = custom
//                let session = NIMSession(contact.userName, type:  contact.isTeam ? .team : .P2P)
//                try? NIMSDK.shared().chatManager.send(self.updateApnsPayload(message, session.sessionId, contact.isTeam), to: session)
//            }
//            
//            self.showTopIndicator(status: .success, "select_friend_success_sent".localized)
  //      }
        
    }
    
    func sharePicToChat() {
        guard let model = model else { return }
        
        choosedDataSource.forEach {
            let contact = $0 as! ContactData
            let message = NIMMessage()
            let messageObject = NIMImageObject(image: model.qrImage)
            message.messageObject = messageObject
            let session = NIMSession(contact.userName, type:  contact.isTeam ? .team : .P2P)
            try? NIMSDK.shared().chatManager.send(self.updateApnsPayload(message, session.sessionId, contact.isTeam), to: session)
            
            if !model.content.isEmpty {
                let textMessage = NIMMessage()
                textMessage.text = model.content
                try? NIMSDK.shared().chatManager.send(self.updateApnsPayload(textMessage, session.sessionId, contact.isTeam), to: session)
            }
        }
        
      //  showTopIndicator(status: .success, "select_friend_success_sent".localized)
    }
    
    // By Kit Foong (Update message session id and type into apns payload)
    func updateApnsPayload(_ message: NIMMessage, _ sessionIdString: String, _ isTeam: Bool) -> NIMMessage {
        var sessionId: String = ""
        var sessionType: Int = 0
        
        sessionType = isTeam ? 1 : 0
        
        if (sessionType == 0) {
            sessionId =  NIMSDK.shared().loginManager.currentAccount() ?? ""
        } else {
            sessionId = sessionIdString
            let setting = NIMMessageSetting()
            setting.teamReceiptEnabled = true
            message.setting = setting
        }
        
        if sessionId.isEmpty == false {
            var parameters: String = ""
            parameters = String(format: "{\"sessionID\": \"%@\", \"sessionType\": \"%@\"}", sessionId, sessionType.stringValue)
            print(parameters)
            
            if let data = parameters.data(using: String.Encoding.utf8) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                    print(json)
                    message.apnsPayload = json
                } catch {
                    print("Something went wrong")
                }
            }
        }
        
        return message
    }
}

extension TGContactsPickerViewController: ContactsSelecletdCellDelegate {
    @objc func deleteButtonClick(model: ContactData?) {
        if let model = model, let choosedDataSource = choosedDataSource as AnyObject as? [ContactData], let indexCol = choosedDataSource.firstIndex(where: {$0.userName == model.userName})  {
            self.choosedDataSource.removeObject(at: indexCol)
            UIView.performWithoutAnimation {
                self.collectionView.performBatchUpdates {
                    self.collectionView.deleteItems(at: [IndexPath(row: indexCol, section: 0)])
                }
            }
            
            var section = 0
            var row = 0
            var flag = false
            
            if isSearching == true {
                if let index = searchResults.firstIndex(where: {$0.userName == model.userName}) {
                    row = index
                    flag = true
                }
            } else {
                if let index = allData.firstIndex(where: {$0.userName == model.userName}) {
                    row = index
                    flag = true
                }
            }
            
            if flag {
                let index = IndexPath(row: row, section: section)
                if let cell: TGContactPickerCell = friendListTableView.cellForRow(at: index) as? TGContactPickerCell {
                    cell.chatButton.isSelected = false
                }
            }
            collectionView.isHidden = self.choosedDataSource.count == 0
            updateNumberOfSelection()
        }
    }

}

class Debouncer: NSObject {
    var handler: (() -> ())?
    private(set) var delay: Double
    private(set) weak var timer: Timer?
    
    public init(delay: Double) {
        self.delay = delay
    }
    
    public func execute() {
        timer?.invalidate()
        let nextTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(Debouncer.fireNow), userInfo: nil, repeats: false)
        timer = nextTimer
    }
    
    @objc private func fireNow() {
        self.handler?()
    }
}
