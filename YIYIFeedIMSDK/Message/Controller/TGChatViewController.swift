//
//  TGChatViewController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/2.
//

import UIKit
import NIMSDK
import AVFoundation
import Photos
import PhotosUI

// 发送文件大小限制(单位：MB)
let fileSizeLimit: Double = 200
//录音时长
let record_duration: TimeInterval = 60.0

let maxPhoto: Int = 9

public class TGChatViewController: TGViewController {
    
    var viewmodel: TGChatViewModel
    private var userInfo: UserInfoModel? = nil
    var meetingViewmodel: TGJoinMeetingViewModel = TGJoinMeetingViewModel()
    
    lazy var headerAvatarView: TGAvatarView = {
        let view = TGAvatarView(type: .width26(showBorderLine: false))
        return view
    }()
    
    lazy var headerTitle: UILabel = {
        let label = UILabel()
        label.textColor = TGAppTheme.black
        label.font = UIFont.systemFont(ofSize: TGFontSize.chatroomMsgFontSize)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var tableView: RLTableView = {
        let tableView = RLTableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.allowsSelection = false
        tableView.mj_header = SCRefreshHeader(
            refreshingTarget: self,
            refreshingAction: #selector(loadMoreData)
        )
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    let chatInputView = BaseChatInputView(frame: .zero)
    var bottomExanpndHeight: CGFloat = 234 + TSBottomSafeAreaHeight // 底部展开高度
    var normalInputHeight: CGFloat = 50.0
    
    let ges = UITapGestureRecognizer()

    var replyView: MessageReplyView?
    
    var currentSelectedLangCode: SupportedLanguage?
 
    lazy var enterInfoBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(UIImage.set_image(named: "more")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setImage(UIImage.set_image(named: "more")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
        button.tintColor = UIColor(hex: 0x808080)
        button.addTarget(self, action: #selector(enterPersonInfoCard), for: .touchUpInside)
        return button
    }()
    
    lazy var videoCallBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(UIImage.set_image(named: "ic_call_plus")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setImage(UIImage.set_image(named: "ic_call_plus")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
        button.tintColor = UIColor(hex: 0x808080)
        button.addTarget(self, action: #selector(callActionSheet), for: .touchUpInside)
        return button
    }()
    
    lazy var teamMeetingBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(UIImage.set_image(named: "ic_call_plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setImage(UIImage.set_image(named: "ic_call_plus")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        button.tintColor = UIColor(hex: 0x808080)
        button.addTarget(self, action: #selector(callActionSheet), for: .touchUpInside)
        return button
    }()
    
    lazy var cancelSelectionBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        button.setTitle("cancel".localized, for: .normal)
        button.setTitleColor(TGAppTheme.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(cancelSelectMessage), for: .touchUpInside)
        return button
    }()
    
    lazy var selectActionToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.tintColor = TGAppTheme.white
        toolbar.isTranslucent = false
        toolbar.isHidden = true
        return toolbar
    }()
    lazy var shareButton: UIBarButtonItem = {
        let button = UIButton()
        button.setImage(UIImage(named: "msg_select_forward"), for: .normal)
        button.addTarget(self, action: #selector(forwardMessages), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    lazy var deleteButton: UIBarButtonItem = {
        let button = UIButton()
        button.setImage(UIImage(named: "msg_select_delete"), for: .normal)
        button.addTarget(self, action: #selector(deleteMessages), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    lazy var selectedItem: UIButton = {
        let button = UIButton()
        button.setTitle("msg_number_of_selected".localized, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        //button.tintColor = UIColor.black
        return button
    }()
    
    lazy var eggOverlayView: RedPacketView = {
        let view = RedPacketView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.bounds.width, height: self.view.bounds.height)))
        view.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
        return view
    }()
    private var eggOverlayTapGesture : UITapGestureRecognizer!
    private var openEggTapGesture : UITapGestureRecognizer!
    private var eggAttachment: IMEggAttachment?
    private var isEggAttachmentOutgoing: Bool?
    
    var selectedMsgId: [String] = []
    
    //保存识别结果
    private var receiveResult = ""
    // speech model
    var locale: Locale = .current
    var recognizedText = ""
    var isRecognitionInProgress = false
    
    var isForwarding: Bool = false
    
    //白板房间id
    var whiteboardRoomId: Int = 0
    var interactionController: UIDocumentInteractionController!
    ///附件是否在下载
    var isDownLoading: Bool = false
    /// 是否在打开egg
    var onClickedEgg: Bool = false
    var isRedPacket = false
    /// 置顶view
    var pinnedView: IMPinnedView?
    var pinnedAlert: TGAlertController?
    
    lazy var nonfriendBottomView = NonFriendBottomView()
    lazy var leaveGroupBottomView = LeaveGroupBottomView()
    private var isLeavedGroupUser = false {
        didSet {
            if isLeavedGroupUser {
                guard leaveGroupBottomView.superview == nil else {
                    return
                }
                self.backBaseView.addSubview(self.leaveGroupBottomView)
                leaveGroupBottomView.snp.makeConstraints {
                    $0.leading.bottom.trailing.equalToSuperview()
                }
            } else {
                leaveGroupBottomView.removeFromSuperview()
            }
        }
    }
    
    ///会议
    var timer: TimerHolder?
    var timeView: UIView?
    var timeLabel:  UILabel?
    var password = ""
    /// @用户列表
    var mentionsUsernames = [AutoMentionsUser]()
    
    var dependVC : UIViewController!
  
    public init(conversationId: String, conversationType: Int) {
        let type = V2NIMConversationType(rawValue: conversationType) ?? .CONVERSATION_TYPE_P2P
        self.viewmodel = TGChatViewModel(conversationId: conversationId, conversationType: type)
        super.init(nibName: nil, bundle: nil)
    }
    init(conversationId: String, conversationType: V2NIMConversationType, anchor: V2NIMMessage?) {
        self.viewmodel = TGChatViewModel(conversationId: conversationId, conversationType: conversationType, anchor: anchor)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        addObserve()
        commonUI()
        loadData()
    }
    public override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
        if self.viewmodel.conversationType == .CONVERSATION_TYPE_TEAM {
            self.loadMessagePins()
        }
        ///聊天背景
        setChatWallpaper()
        updateNavLeftItem()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if NIMSDK.shared().mediaManager.isPlaying() {
            NIMSDK.shared().mediaManager.stopPlay()
        }
        IMAudioCenter.shared.currentMessage = nil
    }

    func addObserve() {
        meetingViewmodel.delegate = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    
        NotificationCenter.default.addObserver(self, selector: #selector(handleCustomNotification(_:)), name: NSNotification.Name("ChatViewCustomNotication"), object: nil)
    }
    
    //    MARK: 键盘通知相关操作
    @objc func keyBoardWillShow(_ notification: Notification) {
        if chatInputView.currentType != .text {
            return
        }
        chatInputView.currentButton?.isSelected = false
        
        chatInputView.contentSubView.isHidden = true
        let oldKeyboardRect = (notification
            .userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardRect = (notification
            .userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        print("chat view key board size : ", keyboardRect)
        layoutInputView(offset: keyboardRect.size.height)
        weak var weakSelf = self
        UIView.animate(withDuration: 0.25, animations: {
            weakSelf?.view.layoutIfNeeded()
        })
        
        // 键盘已经弹出
        if oldKeyboardRect == keyboardRect {
            return
        }
        scrollTableViewToBottom()
    }
    
    @objc func keyBoardWillHide(_ notification: Notification) {
        if chatInputView.currentType != .text {
            return
        }
        chatInputView.currentButton?.isSelected = false
        layoutInputView(offset: TSBottomSafeAreaHeight)
    }
    
    private func scrollTableViewToBottom() {
        if viewmodel.messages.count > 0 {
            weak var weakSelf = self
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: DispatchWorkItem(block: {
                if let row = weakSelf?.tableView.numberOfRows(inSection: 0) {
                    let indexPath = IndexPath(row: row - 1, section: 0)
                    weakSelf?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }))
        }
    }
    
    func commonUI(){
        viewmodel.delegate = self
        chatInputView.configMoreViewData(conversationType: viewmodel.conversationType) 
        backBaseView.addSubview(tableView)
        backBaseView.addSubview(chatInputView)
        chatInputView.delegate = self
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: backBaseView.bounds.height - chatInputView.menuHeight - TSBottomSafeAreaHeight)
        tableView.register(TextMessageCell.self, forCellReuseIdentifier: "TextMessageCell")
        tableView.register(ImageMessageCell.self, forCellReuseIdentifier: "ImageMessageCell")
        tableView.register(TipMessageCell.self, forCellReuseIdentifier: "TipMessageCell")
        tableView.register(AudioMessageCell.self, forCellReuseIdentifier: "AudioMessageCell")
        tableView.register(FileMessageCell.self, forCellReuseIdentifier: "FileMessageCell")
        tableView.register(LocationMessageCell.self, forCellReuseIdentifier: "LocationMessageCell")
        tableView.register(ReplyMessageCell.self, forCellReuseIdentifier: "ReplyMessageCell")
        tableView.register(WhiteBoardMessageCell.self, forCellReuseIdentifier: "WhiteBoardMessageCell")
        tableView.register(VideoCallingCell.self, forCellReuseIdentifier: "VideoCallingCell")
        tableView.register(StickerRPSMessageCell.self, forCellReuseIdentifier: "StickerRPSMessageCell")
        tableView.register(EggMessageCell.self, forCellReuseIdentifier: "EggMessageCell")
        tableView.register(NameCardMessageCell.self, forCellReuseIdentifier: "NameCardMessageCell")
        tableView.register(ReplyMessageCell.self, forCellReuseIdentifier: "ReplyMessageCell")
        tableView.register(MeetingMessageCell.self, forCellReuseIdentifier: "MeetingMessageCell")
        tableView.register(SocialPostMessageCell.self, forCellReuseIdentifier: "SocialPostMessageCell")
        tableView.register(VoucherMessageCell.self, forCellReuseIdentifier: "VoucherMessageCell")
        tableView.register(MiniProgramMessageCell.self, forCellReuseIdentifier: "MiniProgramMessageCell")
        tableView.register(MultiImageMessageCell.self, forCellReuseIdentifier: "MultiImageMessageCell")
        tableView.register(TranslateMessageCell.self, forCellReuseIdentifier: "TranslateMessageCell")
        
    
        chatInputView.frame = CGRect(x: 0, y: backBaseView.bounds.height - chatInputView.menuHeight - TSBottomSafeAreaHeight, width: self.view.bounds.width, height: chatInputView.menuHeight + chatInputView.contentHeight)
        
        customNavigationBar.setRightViews(views: [videoCallBtn, enterInfoBtn])
        
        self.backBaseView.addSubview(nonfriendBottomView)
        nonfriendBottomView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        nonfriendBottomView.makeHidden()
        /// 目前先做桥接回去
        nonfriendBottomView.messageRequestLabel.addAction { [weak self] in
            guard let userInfo = self?.userInfo else { return }
            RLSDKManager.shared.imDelegate?.openMsgRequestChat(username: userInfo.username, userIdentity: userInfo.userIdentity)
        }

        self.backBaseView.addSubview(selectActionToolbar)
        selectActionToolbar.snp.makeConstraints { make in
            if RLUserInterfacePrinciples.share.hasNotch() {
                make.height.equalTo(64)
            }else{
                make.height.equalTo(50)
            }
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        setupNav()
        eggOverlayTapGesture = UITapGestureRecognizer(target: self, action: #selector(closeEggView))
        eggOverlayView.addGestureRecognizer(eggOverlayTapGesture)
        
        openEggTapGesture = UITapGestureRecognizer(target: self, action: #selector(checkOpenEggStatus))
        eggOverlayView.openEggView.addGestureRecognizer(openEggTapGesture)
        
    }
    
    func setupNav() {
        if self.tableView.isEditing {
            customNavigationBar.setRightViews(views: [cancelSelectionBtn])
        } else {
            switch viewmodel.conversationType {
            case .CONVERSATION_TYPE_P2P:
                TGNewFriendsNetworkManager.getUsersInfo(usersId: [], names: [self.viewmodel.sessionId]) {[weak self] users, error in
                    guard let self = self, let model = users?.first else {
                        return
                    }
                    self.userInfo = model
                    DispatchQueue.main.async {
                        self.updateNav(model)
                    }
                }
            case .CONVERSATION_TYPE_TEAM:
                customNavigationBar.setRightViews(views: [enterInfoBtn])
                MessageUtils.getTeamInfo(teamId: self.viewmodel.sessionId, teamType: .TEAM_TYPE_NORMAL) {[weak self] team in
                    DispatchQueue.main.async {
                        if let team = team , team.isValidTeam, let self = self {
                            self.customNavigationBar.setRightViews(views: [self.teamMeetingBtn, self.enterInfoBtn])
                        }
                    }
                }
            default:
                customNavigationBar.setRightViews(views: [])
            }
        }
        
        headerAvatarView.buttonForAvatar.addAction(action: { [weak self] in
            guard let self = self else { return }
            if self.viewmodel.conversationType == .CONVERSATION_TYPE_P2P {
                RLSDKManager.shared.imDelegate?.didPressNameCard(memberId: self.viewmodel.sessionId)
            } else {
                self.enterPersonInfoCard()
            }
        })
        headerTitle.addAction(action: { [weak self] in
            guard let self = self else { return }
            if self.viewmodel.conversationType == .CONVERSATION_TYPE_P2P {
                RLSDKManager.shared.imDelegate?.didPressNameCard(memberId: self.viewmodel.sessionId)
            } else {
                self.enterPersonInfoCard()
            }
        })
    }
    
    func updateNavLeftItem() {
        let allunreadCount = RLSDKManager.shared.getConversationAllUnreadCount()
        
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 58, height: 30))
        backButton.setImage(UIImage.set_image(named: "iconsArrowCaretleftBlack"), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        self.customNavigationBar.setLeftViews(views: [backButton])
        
        let unreadCountLabel = UILabel()
        unreadCountLabel.isHidden = (allunreadCount <= 0)
        unreadCountLabel.backgroundColor = TGAppTheme.secondaryColor
        unreadCountLabel.textColor = TGAppTheme.twilightBlue
        unreadCountLabel.font = UIFont.boldSystemFont(ofSize: 12)
        unreadCountLabel.numberOfLines = 1
        unreadCountLabel.text = allunreadCount.stringValue
        unreadCountLabel.textAlignment = .center
        unreadCountLabel.sizeToFit()
        let unreadCountView = UIView()
        unreadCountView.addSubview(unreadCountLabel)
        
        let lblHeight: CGFloat = unreadCountLabel.height + 4
        let lblWidth: CGFloat = unreadCountLabel.width + 10.0
        
        let titleStackView = UIStackView().configure { (stack) in
            stack.axis = .horizontal
            stack.spacing = 10
            stack.distribution = .fill
            stack.alignment = .center
        }

        unreadCountView.isHidden = allunreadCount == 0
        titleStackView.addArrangedSubview(unreadCountView)
        titleStackView.addArrangedSubview(headerAvatarView)
        titleStackView.addArrangedSubview(headerTitle)
        
        headerAvatarView.snp.makeConstraints({make in
            make.width.height.equalTo(26)
        })
        unreadCountView.snp.makeConstraints({make in
            make.width.equalTo(lblWidth)
        })
        unreadCountLabel.snp.makeConstraints({make in
            make.width.equalTo(lblWidth)
            make.height.equalTo(lblHeight)
            make.centerY.equalToSuperview()
        })
        unreadCountLabel.roundCorner(lblHeight/2)
        
        MessageUtils.getAvatarIcon(sessionId: viewmodel.sessionId, conversationType: viewmodel.conversationType) {[weak self] avatarInfo in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.headerAvatarView.avatarInfo = avatarInfo
                self.headerTitle.text = avatarInfo.nickname
                self.customNavigationBar.setLeftViews(views: [backButton, titleStackView])
            }
        }
    }
    
    func updateNav(_ model: UserInfoModel) {
        guard let relationship = model.relationshipWithCurrentUser else { return }
        var showIM = false
      //  let isMeWhitelist = TSCurrentUserInfo.share.userInfo?.whiteListType?.contains("outgoing_message") ?? false
        let isUserWhitelist = model.whiteListType?.contains("incoming_call") ?? false
        switch relationship.status {
        case .eachOther:
            showIM = true
        case .follow, .unfollow:
            showIM = isUserWhitelist
        case .oneself:
            return
        }
        if showIM {
            customNavigationBar.setRightViews(views: [videoCallBtn, enterInfoBtn])
            self.nonfriendBottomView.makeHidden()
        } else {
            customNavigationBar.setRightViews(views: [])
            self.backBaseView.bringSubviewToFront(self.nonfriendBottomView)
            self.chatInputView.isHidden = true
            self.nonfriendBottomView.makeVisible()
        }
    }
    
    @objc func backAction (){
        self.navigationController?.popViewController(animated: true)
    }
    
    func loadData() {
        viewmodel.loadData {[weak self] error, count, messages in
            if messages.count > 0 {
                DispatchQueue.main.async {
                    self?.tableView.removePlaceholderViews()
                    self?.tableView.reloadData()
                    let indexPath = IndexPath(row: messages.count - 1, section: 0)
                    self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
                self?.viewmodel.readAllMessageReceipt(completion: nil)
            } else {
                DispatchQueue.main.async {
                    self?.tableView.show(placeholderView: .imEmpty)
                }
            }
        }
    }
    
    @objc func loadMoreData(){
        viewmodel.dropDownRemoteRefresh {[weak self] error, count, messages, indexpath  in
            self?.tableView.mj_header.endRefreshing()
            if let indexPath = indexpath {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                }
            }
        }
    }
    
    @objc func enterPersonInfoCard(){
        if self.viewmodel.conversationType == .CONVERSATION_TYPE_P2P {
            let vc = TGChatDetailViewController(sessionId: self.viewmodel.sessionId, conversationId: self.viewmodel.conversationId)
            self.navigationController?.pushViewController(vc, animated: true)
            vc.clearMessageCall = {[weak self] in
                self?.viewmodel.messages.removeAll()
                DispatchQueue.main.async {
                    self?.tableView.show(placeholderView: .imEmpty)
                    self?.tableView.reloadData()
                }
            }
        } else {
            MessageUtils.getTeamInfo(teamId: self.viewmodel.sessionId, teamType: .TEAM_TYPE_NORMAL) {  [weak self] team in
                guard let self = self else { return }
                if let team = team {
                    DispatchQueue.main.async {
                        let vc = TGTeamChatDetailViewController(sessionId: self.viewmodel.sessionId, conversationId: self.viewmodel.conversationId, team: team)
                        self.navigationController?.pushViewController(vc, animated: true)
                        vc.clearGroupMessageCall = { [weak self] in
                            self?.viewmodel.messages.removeAll()
                            DispatchQueue.main.async {
                                self?.tableView.show(placeholderView: .imEmpty)
                                self?.tableView.reloadData()
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    @objc func callActionSheet(){
        self.layoutInputView(offset: TSBottomSafeAreaHeight)
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let voiceImage = UIImage.set_image(named: "voiceCallTop")
        let videoImage = UIImage.set_image(named: "videoCallTop")
        let videoCall = UIAlertAction(title: "msg_type_video_call".localized, style: .default, handler: nil)
        videoCall.setValue(videoImage?.withRenderingMode(.alwaysOriginal), forKey: "image")
        let type = MessageUtils.conversationTargetType(self.viewmodel.conversationId)
        switch type {
        case .CONVERSATION_TYPE_TEAM:
            let videoCall = UIAlertAction(title: "msg_type_video_call".localized, style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                MessageUtils.fetchMembersTeam(teamId: self.viewmodel.sessionId) { userIds in
                    DispatchQueue.main.async {
                        self.teamMeeting(userIds: userIds)
                    }
                    
                }
            })
            videoCall.setValue(videoImage?.withRenderingMode(.alwaysOriginal), forKey: "image")
            actionSheet.addAction(videoCall)
            break
        case .CONVERSATION_TYPE_P2P:
            let voiceCall = UIAlertAction(title: "msg_type_voice_call".localized, style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                let vc = RLAudioCallController(callee: self.viewmodel.sessionId, callType: .SIGNALLING_CHANNEL_TYPE_AUDIO)
                let nav = TGNavigationController(rootViewController: vc)
                self.present(nav.fullScreenRepresentation, animated: true)
            })
            voiceCall.setValue(voiceImage?.withRenderingMode(.alwaysOriginal), forKey: "image")

            let videoImage = UIImage.set_image(named: "videoCallTop")
            let videoCall = UIAlertAction(title: "msg_type_video_call".localized, style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                let vc = RLAudioCallController(callee: self.viewmodel.sessionId, callType: .SIGNALLING_CHANNEL_TYPE_VIDEO)
                let nav = TGNavigationController(rootViewController: vc)
                self.present(nav.fullScreenRepresentation, animated: true)
            })
            videoCall.setValue(videoImage?.withRenderingMode(.alwaysOriginal), forKey: "image")
            
            actionSheet.addAction(voiceCall)
            actionSheet.addAction(videoCall)
            break
        default:
            break
        }
        
        actionSheet.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func teamMeeting(userIds: [String]) {
        let currentUserID = NIMSDK.shared().v2LoginService.getLoginUser() ?? ""
        var memberIds = [String]()
        for userId in userIds{
            if userId != currentUserID {
                memberIds.append(userId)
            }
        }
        
        let config = TGContactsPickerConfig(title: "select_contact".localized, rightButtonTitle: "confirm".localized, allowMultiSelect: true, enableTeam: false, enableRecent: false, enableRobot: false, maximumSelectCount: 8, members: memberIds, enableButtons: false, allowSearchForOtherPeople: true)
        
        self.dependVC = TGContactsPickerViewController(configuration: config, finishClosure: {[weak self] contacts in
            guard let self = self  else {return}
            let users = contacts.compactMap {$0.userName}
            var members : [String] = [currentUserID]
            members.append(contentsOf: users)
            let info = IMTeamMeetingCallerInfo()
            info.members = members
            info.teamId = self.viewmodel.sessionId
            AuthorizeStatusUtils.checkAuthorizeStatusByType(type: .videoCall, viewController: self, completion: {
                DispatchQueue.main.async {
                    self.dependVC.dismiss(animated: true) {
                        let vc1 = TGIMTeamMeetingController(info: info, conversationId: self.viewmodel.conversationId)
                        vc1.modalPresentationStyle = .fullScreen
                        self.present(vc1, animated: true, completion: nil)
                    }
                }
            })
        }, isTeamMeeting: true)
        
        DispatchQueue.main.async {
            let nav = TGNavigationController(rootViewController: self.dependVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
        
    }
    
    func setChatWallpaper() {
        let image = viewmodel.sessionBackgroundImage()
        tableView.backgroundColor = .white
        if image != nil {
            let cellBackgroundView = UIImageView(image: image)
            cellBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            cellBackgroundView.clipsToBounds = true
            cellBackgroundView.contentMode = .scaleAspectFill
            cellBackgroundView.frame = tableView.bounds
            
            tableView.backgroundView = cellBackgroundView
        } else {
            tableView.backgroundView = nil
        }
    }
    
    // MARK: inputview action
    // 打开相册
    func openPhotoLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        present(imagePicker, animated: true, completion: nil)

        
    }
    
    /// 处理受限访问模式下的逻辑
    private func handleLimitedAccess() {
        
        self.showAlert(message: "rw_limited_feed_photo_tip".localized, buttonTitle: "ok".localized) { action in
            if #available(iOS 15, *) {
                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self) { ids in
                    var selectedAssets: [PHAsset] = []
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                        selectedAssets = self.fetchAllLimitedAssets()
//                        self.handleSelectedPhotos(photos: [UIImage()], imageAsset: selectedAssets, isGifImage: false)
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    /// 获取当前受限模式下的所有 PHAsset
    private func fetchAllLimitedAssets() -> [PHAsset] {
        var assets: [PHAsset] = []
         // 设置排序条件：按创建日期降序排列
         let fetchOptions = PHFetchOptions()
         fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
         
         let allAssets = PHAsset.fetchAssets(with: fetchOptions)
         allAssets.enumerateObjects { asset, _, _ in
             assets.append(asset)
         }
         return assets
    }
    
    /// 打开 PHPickerViewController
    func presentPHPicker() {
        if #available(iOS 14.0, *) {
            var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
            phPickerConfig.selectionLimit = maxPhoto
            phPickerConfig.filter = .any(of: [.images, .livePhotos])
            
            let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
            phPickerVC.delegate = self
            present(phPickerVC, animated: true)
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    // 打开相机
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("Camera not available")
        }
    }
    //打开文件
    func openFile(){
        RLSendFileManager.shared.presentView(owner: self)
        RLSendFileManager.shared.completion = {[weak self] urls in
            guard let url = urls.first else { return }
            NSFileCoordinator().coordinate(readingItemAt: url, options: .withoutChanges, error: nil) { newUrl in
                let displayName = newUrl.lastPathComponent
                self?.copyFileToSend(url: newUrl, displayName: displayName)
            }
        }
    }
    //打开地图
    func openLocation(model: ChatLocaitonModel?){
        let vc = TGMessageMapViewController()
        if let model = model {
            vc.model = model
        }
        self.navigationController?.pushViewController(vc, animated: true)
        vc.sendBlock = { [weak self] model in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.15){
                self?.viewmodel.sendLocationMessage(model: model, conversationId: self?.viewmodel.conversationId ?? "", { _ in
                    
                })
            }
        }
    }
    
    func copyFileToSend(url: URL, displayName: String) {
        let desPath = NSTemporaryDirectory() + "\(url.lastPathComponent)"
        let dirUrl = URL(fileURLWithPath: desPath)
        if !FileManager.default.fileExists(atPath: desPath) {
            do {
                try FileManager.default.copyItem(at: url, to: dirUrl)
            } catch {
                
            }
        }
        if FileManager.default.fileExists(atPath: desPath) {
            do {
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: desPath)
                if let size_B = fileAttributes[FileAttributeKey.size] as? Double {
                    let size_MB = size_B / 1e6
                    if size_MB > fileSizeLimit {
                        UIViewController.showBottomFloatingToast(with: "文件大小不能超过\(fileSizeLimit)MB", desc: "")
                        try? FileManager.default.removeItem(atPath: desPath)
                    } else {
                        viewmodel.sendFileMessage(filePath: desPath, displayName: displayName, conversationId: viewmodel.conversationId) { _, error, _ in
                            
                        }

                    }
                }
            } catch {
                
            }
        }
    }
    
    func openWhiteBoard(){
        let timeStamp = Date().timeIntervalSince1970
        TGIMNetworkManager.createWhiteboard(roomName: viewmodel.sessionId + String(timeStamp)) {[weak self] model, error in
            guard let self = self else {return}
            if let error = error {
                UIViewController.showBottomFloatingToast(with: error.localizedDescription, desc: "")
            } else {
                self.whiteboardRoomId = model?.data?.cid ?? 0
                self.showWhiteBoard(channelName: self.whiteboardRoomId.stringValue)
                self.sendWhiteboardMessage(channel: self.whiteboardRoomId.stringValue)
            }
        }
       
    }
    ///发送白板信息
    func sendWhiteboardMessage(channel: String) {
        let creator = NIMSDK.shared().v2LoginService.getLoginUser()
        let rawAttachment = CustomAttachmentDecoder.WhiteBoardEncode(channel: channel, creator: creator ?? "")
        viewmodel.sendCustomMessage(text: "", rawAttachment: rawAttachment, conversationId: viewmodel.conversationId) { _ in
            
        }
    }
    /// 显示白板
    func showWhiteBoard(channelName: String){
        let baseUrl: String = RLSDKManager.shared.loginParma?.apiBaseURL ?? "https://preprod-api-rewardslink.getyippi.cn/"
        let param = NMCWhiteBoardParam()
        param.uid = RLSDKManager.shared.loginParma?.uid ?? 0
        param.appKey = NIMAppKey
        param.channelName = channelName
        param.webViewUrl = baseUrl + kwebViewUrl

        DispatchQueue.main.async {
            let vc = NMCWhiteBoardViewController(whiteBoardParam: param)
            self.present(TGNavigationController(rootViewController: vc).fullScreenRepresentation, animated: true)
        }
    }
    /// egg红包
    func eggTapped() {
        self.layoutInputView(offset: TSBottomSafeAreaHeight)
        self.onClickedEgg = true
        if self.viewmodel.conversationType == .CONVERSATION_TYPE_TEAM {
            MessageUtils.getTeamInfo(teamId: self.viewmodel.sessionId, teamType: .TEAM_TYPE_NORMAL) {[weak self] team in
                if let team = team, let self = self {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
                        RLSDKManager.shared.imDelegate?.openRedPackect(transactionType: .group, fromUser: NIMSDK.shared().v2LoginService.getLoginUser() ?? "", toUser: self.viewmodel.sessionId, numberOfMember: team.memberCount, teamId: team.teamId, completion: { id, userId, msg in
                            self.onClickedEgg = false
                            self.isRedPacket = true
                            let message = MessageUtils.eggV2Message(with: id, tid: team.teamId, uid: userId, messageStr: msg)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
                                self.viewmodel.sendMessage(message: message, conversationId: self.viewmodel.conversationId, params: nil) { _, _, _ in
                                    
                                }
                            }
                            
                        })
                    }
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
                RLSDKManager.shared.imDelegate?.openRedPackect(transactionType: .personal, fromUser: NIMSDK.shared().v2LoginService.getLoginUser() ?? "", toUser: self.viewmodel.sessionId, numberOfMember: 0, teamId: nil, completion: {[weak self] id, userId, msg in
                    guard let self = self else { return }
                    self.onClickedEgg = false
                    self.isRedPacket = true
                    let message = MessageUtils.eggV2Message(with: id, tid: self.viewmodel.sessionId, uid: userId, messageStr: msg)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
                        self.viewmodel.sendMessage(message: message, conversationId: self.viewmodel.conversationId, params: nil) { _, _, _ in
                            
                        }
                    }
                })
            }
        }
    }
    
    /// 发送名片
    func onContactTapped() {
        self.layoutInputView(offset: TSBottomSafeAreaHeight)
        let vc = TGShareContactsViewController(cancelType: .allwayNoShow)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.compleleHandle = { [weak self] (contacts) in
            guard let self = self else { return }
            for contactData in contacts {
                let message = MessageUtils.contactCardV2Message(userName: contactData.userName)
                let param = V2NIMSendMessageParams()
                let pushConfig = V2NIMMessagePushConfig()
                pushConfig.pushContent = "recent_msg_desc_contact".localized
                param.pushConfig = pushConfig
                self.viewmodel.sendMessage(message: message, conversationId: self.viewmodel.conversationId, params: param) { _, _, _ in
                    
                }
            }
        }
    }
    
    
    func layoutInputView(offset: CGFloat) {
        print("layoutInputView offset : ", offset)
        if offset == TSBottomSafeAreaHeight {
            removeGesture()
            chatInputView.keyboardDismiss()
            
        }else{
            addGesture()
        }
        UIView.animate(withDuration: 0.15, animations: {
            
            var frame = self.chatInputView.frame
            frame.origin.y = self.backBaseView.bounds.height - self.normalInputHeight - offset
            self.chatInputView.frame = frame
            self.scrollTableViewToBottom()
            var contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: offset - TSBottomSafeAreaHeight, right: 0)
            if self.viewmodel.isReplying {
                self.replyView?.snp.remakeConstraints { make in
                    make.bottom.equalTo(self.chatInputView.snp.top)
                    make.height.equalTo(rePlyHeight)
                    make.left.right.equalTo(0)
                }
                contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: offset - TSBottomSafeAreaHeight + rePlyHeight, right: 0)
            }
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
        })
        
    }

    func addGesture(){
        self.tableView.addGestureRecognizer(ges)
        ges.addTarget(self, action: #selector(dismissInputView))
    }
    func removeGesture(){
        self.tableView.removeGestureRecognizer(ges)
    }
    
    @objc func dismissInputView(){
        chatInputView.textView.resignFirstResponder()
        layoutInputView(offset: TSBottomSafeAreaHeight)
    }
    
    @objc func forwardMessages(){
        guard let selectedRows = tableView.indexPathsForSelectedRows, selectedRows.count > 0 else {
            let alertController = UIAlertController(title: "warning".localized, message: "text_please_select_one_item".localized, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "ok".localized, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
            return
        }
        let configuration = TGContactsPickerConfig(title: "select_contact".localized, rightButtonTitle: "confirm".localized, allowMultiSelect: true, enableTeam: true, enableRecent: true, enableRobot: false, maximumSelectCount: maximumSendContactCount, excludeIds: [self.viewmodel.sessionId], members: nil, enableButtons: false, allowSearchForOtherPeople: true)
        
        let picker = TGContactsPickerViewController(configuration: configuration) { [weak self] (contacts) in
            guard let self = self else { return }
            for contact in contacts {
                self.viewmodel.forwardV2Message(selectedRows, to: contact.userName, isTeam: contact.isTeam)
            }
            self.selectedMsgId.removeAll()
        }
        self.navigationController?.pushViewController(picker, animated: true)
    }
    
    
    
    @objc func deleteMessages(){
        guard let selectedRows = tableView.indexPathsForSelectedRows, selectedRows.count > 0 else {
            let alertController = UIAlertController(title: "warning".localized, message: "text_please_select_one_item".localized, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "ok".localized, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
            return
        }
        let messages = viewmodel.getDeleteMessages(indexPaths: selectedRows)
       // let sortedRows = selectedRows.sorted(by: { $0.row > $1.row })
//        var canDeleteForEveryone = true
//
//        sortedRows.forEach { path in
//            let model = dataSource.itemIdentifier(for: path)
//            if let message = model?.nimMessageModel, !SessionUtil().canMessageBeRevoked(message) || !showRevokeButton(message) {
//                canDeleteForEveryone = false
//            }
//        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
//        let deleteForEveryone = UIAlertAction(title: "longclick_msg_revoke_message".localized, style: .default, handler: { [weak self] action in
//            guard let self = self else { return }
//            
//            self.selectedMsgId.removeAll()
//            self.showSelectActionToolbar(false, isDelete: false)
//        })
        let deleteForMe = UIAlertAction(title: "longclick_msg_delete_for_me".localized, style: .default, handler: { [weak self] action in
            guard let self = self else { return }
            self.viewmodel.deleteMessage(messages: messages, onlyDeleteLocal: false) { error in
                if error == nil {
                    self.selectedMsgId.removeAll()
                    DispatchQueue.main.async {
                        self.showSelectActionToolbar(false, isDelete: false)
                        self.viewmodel.deleteMessageForUI(messages: messages)
                        self.tableView.reloadData()
                    }
                }
            }
            
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteForMe)
        
//        if canDeleteForEveryone {
//            alertController.addAction(deleteForEveryone)
//        }
        
        self.present(alertController, animated: true)
        
    }
    @objc func cancelSelectMessage(){
        self.showSelectActionToolbar(false, isDelete: false)
    }
    
    //MARK: 打开其他应用
    func openWithDocumentInterator(object: V2NIMMessageFileAttachment) {
        let url = URL(fileURLWithPath: object.path ?? "")
        self.interactionController = UIDocumentInteractionController(url: url)
        self.interactionController.delegate = self
        self.interactionController.name = object.name
        self.interactionController.presentPreview(animated: true)
    }
    
    //MARK: 长按操作 - action
    private func showSelectActionToolbar(_ show: Bool, isDelete: Bool) {
        self.selectActionToolbar.setToolbarHidden(!show)
        self.chatInputView.isHidden = show
        let spacing = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        if show {
            guard let menuMessage = viewmodel.operationModel, let message = menuMessage.nimMessageModel else { return }
            selectedMsgId = [message.messageClientId ?? ""]
            self.selectedItem.bounds = CGRect(x: 0, y: 0, width: self.selectActionToolbar.bounds.width / 4, height: self.selectActionToolbar.bounds.height)
            let selectedItem1 = UIBarButtonItem(customView: self.selectedItem)
            if (isDelete) {
                self.selectActionToolbar.setItems([self.deleteButton, spacing, selectedItem1, spacing], animated: true)
            } else {
                self.selectActionToolbar.setItems([self.shareButton, spacing, selectedItem1, spacing], animated: true)
            }
            
            self.tableView.allowsMultipleSelectionDuringEditing = true
            self.tableView.setEditing(true, animated: false)
            if let msgIndexPath = viewmodel.getIndexPathForMessage(model: menuMessage) {
                tableView.selectRow(at: msgIndexPath, animated: true, scrollPosition: .none)
            }
//            self.updateShareButton()
//            self.updateRevokeButton()
            self.updateSelectedItem()
        } else {
            tableView.setEditing(show, animated: true)
            let selectedMessage = tableView.indexPathsForSelectedRows
            for path in selectedMessage ?? [] {
                tableView.deselectRow(at: path, animated: false)
            }
        }
        setupNav()
    }
    
    func updateTableViewSelection(by messageIndexPath: IndexPath, select: Bool) {
        if select {
            updateSelectedItem()
            tableView.selectRow(at: messageIndexPath, animated: true, scrollPosition: .none)
        } else {
            updateSelectedItem()
            tableView.deselectRow(at: messageIndexPath, animated: true)
        }
    }
    
    func updateSelectedItem() {
        selectedItem.setTitle(String(format: "msg_number_of_selected".localized, String(format: "%i", selectedMsgId.count)), for: .normal)
    }
    
    func copyTextIM() {
        guard let message = viewmodel.operationModel?.nimMessageModel else { return }
        let pasteboard = UIPasteboard.general
        guard let messageText = message.text else { return }
        let ext = message.serverExtension?.toDictionary
        let usernames = ext?["usernames"] as? [String] ?? []
        if (usernames.count) > 0 {
            pasteboard.items = [["usernames": usernames.joined(separator: ","), "message": messageText]]
        } else {
            pasteboard.string = messageText
        }
    }
    
    func revokeTextIM() {
        guard let message = viewmodel.operationModel?.nimMessageModel else { return }
        self.viewmodel.revokeTextMessage(message: message) {[weak self] error in
            if let _ = error {
                let alertController = UIAlertController(title: nil, message: "revoke_try_again".localized, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "confirm".localized, style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self?.present(alertController, animated: true)
            } else {
                self?.viewmodel.deleteMessageForUI(messages: [message])
                self?.tableView.reloadData()
                self?.chatInputView.textView.insertText(message.text ?? "")
                self?.chatInputView.textView.becomeFirstResponder()
                
                let tip = MessageUtils.tipOnP2PV2MessageRevoked()
                let tipMessage = MessageUtils.tipV2Message(text: tip)
                tipMessage.createTime = message.createTime
                self?.viewmodel.sendMessage(message: tipMessage, conversationId: self?.viewmodel.conversationId ?? "", params: nil, completion: { _, _, _ in
                    
                })
            }
            
        }
    }
    ///消息收藏
    func collectMessage(){
        guard let model = viewmodel.operationModel, let message = model.nimMessageModel else { return }
        guard let msgData = MessageUtils.collectionMsgData(model) else { return }
        let type = MessageUtils.collectionMsgType(model)
        let params = V2NIMAddCollectionParams()
        params.collectionType = Int32(type.rawValue)
        params.collectionData = msgData
        params.uniqueId = message.messageClientId
        NIMSDK.shared().v2MessageService.addCollection(params) { _ in
            //TODO:
            if UserDefaults.isMessageFirstCollection == false {
                UserDefaults.isMessageFirstCollection = true
                UserDefaults.messageFirstCollectionFilterTooltipShouldHide = true
            }
            UIViewController.showBottomFloatingToast(with: "favourite_msg_save_success".localized, desc: "")
        } failure: { error in
            UIViewController.showBottomFloatingToast(with: error.nserror.localizedDescription, desc: "")
        }

    }
    /// 文本消息翻译
    func translateTextIM() {
        guard let model = viewmodel.operationModel, let message = model.nimMessageModel else { return }
        var messageText = message.text
        if let attach = model.customAttachment as? IMReplyAttachment {
            messageText = attach.content
        }
        guard let messageText = messageText, messageText != "" else { return }
        
        textTranslate(withText: messageText, oriMessage: model)
 
    }
    
    func textTranslate(withText messageText: String, oriMessage: TGMessageData, translateMessage: TGMessageData? = nil) {
        viewmodel.translateTextMessage(messageText: messageText) {[weak self] text, error in
            oriMessage.isTranslated = true
            guard let self = self else {return}
            if let error = error {
                
                if let translateMessage = translateMessage {
                    let _ = self.viewmodel.updateTranslateMessage(for: translateMessage, with: error.localizedDescription)
                } else {
                    let messageData = MessageUtils.translateMessage(oriMessage, with: error.localizedDescription)
                    self.viewmodel.insert(message: messageData, after: oriMessage)
                }
            } else {
                if let translateMessage = translateMessage {
                    let _ = self.viewmodel.updateTranslateMessage(for: translateMessage, with: text ?? "")
                } else {
                    let messageData = MessageUtils.translateMessage(oriMessage, with: text ?? "")
                    self.viewmodel.insert(message: messageData, after: oriMessage)
                    
                }

            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    ///语音翻译
    func vioceTotext() {
        
        guard let model = viewmodel.operationModel, let message = model.nimMessageModel, let attach = message.attachment as? V2NIMMessageAudioAttachment else { return }
        
        let audioPath = attach.path ?? ""
        let fileUrl = URL(fileURLWithPath: audioPath)
        
        let voiceToTextVC = TGVoiceToTextIMViewController(fileUrl: fileUrl, selectedLanguage: currentSelectedLangCode, isLanguageSelection: false)
        self.present(voiceToTextVC, animated: true)
    }
    private func scrollToMessage(by indexpath: IndexPath, animation: Bool) {
        self.tableView.scrollToRow(at: indexpath, at: .top, animated: false)
        
        if animation {
            self.perform(#selector(cellAnimation(indexpath:)), with: indexpath, afterDelay: 0.3)
        }
    }
    
    @objc func cellAnimation(indexpath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexpath) as? BaseMessageCell else { return }
        let bubble = cell.bubbleView
        let layer = CALayer()
        layer.frame = bubble.bounds
        bubble.layer.addSublayer(layer)
        let colorsAnimation = CAKeyframeAnimation(keyPath: "backgroundColor")
        colorsAnimation.values = [UIColor(red: 0.81, green: 0.81, blue: 0.81, alpha: 1.0).cgColor].compactMap { $0 }
        colorsAnimation.fillMode = .forwards
        colorsAnimation.duration = 1.0
        colorsAnimation.autoreverses = true
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.toValue = NSNumber(value: 0)
        fade.duration = 1.0
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.toValue = NSNumber(value: 2)
        
        let group = CAAnimationGroup()
        group.duration = 1.0
        group.animations = [colorsAnimation, fade]
        layer.add(group, forKey: nil)
    }
    
    // MARK: Pinned - 置顶
    
    //查询 pin 列表
    func loadMessagePins() {
        viewmodel.getGroupPinnedList(groupId: viewmodel.sessionId) {[weak self] pins, error in
            guard let self = self else { return }
            if let error = error  {
                UIViewController.showBottomFloatingToast(with: error.localizedDescription, desc: "")
            } else {
                if let models = pins, let model = models.first {
                    self.viewmodel.pinnedList = models
                    self.viewmodel.currentPinned = model
                    self.showPinnedView(pinItem: model)
                    self.setPinnedMessageForMessageId()
                }
            }
        }
    }
    
    func pinnedMessage() {
        guard let model = viewmodel.operationModel, let data = MessageUtils.collectionMsgData(model, isType: true), let messageClientId = model.nimMessageModel?.messageClientId  else {
            return
        }
        
        viewmodel.storePinnedMessage(imMsgId: messageClientId, imGroupId: self.viewmodel.sessionId, content: data, deleteFlag: true) {[weak self] resultModel, error in
            guard let self = self else { return }
            if let error = error  {
                UIViewController.showBottomFloatingToast(with: error.localizedDescription, desc: "")
            } else {
                if let model = resultModel {
                    self.viewmodel.currentPinned = model
                    self.viewmodel.pinnedList.insert(model, at: 0)
                    self.showPinnedView(pinItem: model)
                    self.cellForMessageId(messageId: model.im_msg_id, isPinned: true)
                    self.sendPinnedNotify(type: NTESPinnedStored, pinnedModel: model)
                    //删除之前的 pinned
                    for item in self.viewmodel.pinnedList {
                        if item.id != model.id {
                            self.messageDeletePinItem(pinnedModel: item)
                        }
                    }
                }
            }
        }

    }
    
    func unPinnedMessage(model: PinnedMessageModel) {
        viewmodel.deletePinnedMessage(id: model.id) {[weak self] resultModel, error in
            guard let self = self else { return }
            if let error = error  {
                UIViewController.showBottomFloatingToast(with: error.localizedDescription, desc: "")
            } else {
                DispatchQueue.main.async {
                    self.messageDeletePinItem(pinnedModel: model)
                    self.sendPinnedNotify(type: NTESPinnedDeleted, pinnedModel: model)
                }
                
            }
        }
    }
    
    func showPinnedView(pinItem: PinnedMessageModel) {
        if pinnedView != nil{
            pinnedView?.setData(pinItem: pinItem)
        } else {
            pinnedView = IMPinnedView(pinItem: pinItem)
            pinnedView?.setData(pinItem: pinItem)
            allStackView.insertArrangedSubview(pinnedView!, at: 1)
            pinnedView?.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.height.equalTo(50)
            }
            pinnedView?.delegate = self
            pinnedView?.addAction(action: { [weak self] in
                guard let self = self else { return }
                self.layoutInputView(offset: TSBottomSafeAreaHeight)
                let popView = IMPinnedPopView(pinItem: self.pinnedView!.pinItem)
                let popup = TGAlertController(style: .popup(customview: popView), hideCloseButton: false)
                popView.delegate = self
                self.present(popup, animated: false)
                self.pinnedAlert = popup
            })
            self.updateUI(isPinned: true)
        }
    }
    //处理点击删除消息后，移除pinnedView
    func messageDeletePinItem(pinnedModel: PinnedMessageModel) {
        viewmodel.pinnedList.removeAll { item in
            item.id == pinnedModel.id
        }
        self.cellForMessageId(messageId: pinnedModel.im_msg_id, isPinned: false)
        if viewmodel.pinnedList.count == 0 {
            viewmodel.currentPinned = nil
            self.pinnedView?.isHidden = true
            self.pinnedView?.removeFromSuperview()
            self.pinnedView = nil
            self.updateUI(isPinned: false)
        } else {
            viewmodel.currentPinned = viewmodel.pinnedList.first
            self.pinnedView?.setData(pinItem: viewmodel.currentPinned!)
        }
    }
    
    func cellForMessageId(messageId: String, isPinned: Bool = false) {
        if let messageData = viewmodel.getMessageDataForMessageClientId(messageClientId: messageId), let indexPath = viewmodel.getIndexPathForMessage(model: messageData) {
            messageData.isPinned = isPinned
            self.tableView.reloadRow(at: indexPath, with: .none)
        }
    }
    
    func setPinnedMessageForMessageId() {
        viewmodel.messages.forEach { messageData in
            if let _ = self.viewmodel.pinnedList.first(where: { model in
                model.im_msg_id == messageData.nimMessageModel?.messageClientId
            }) {
                messageData.isPinned = true
            } else {
                messageData.isPinned = false
            }
            
        }
        self.tableView.reloadData()
    }
    
    func sendPinnedNotify(type: Int, pinnedModel: PinnedMessageModel) {
        let dict: [String : Any] = [NTESNotifyID: type, NTESCustomContent: pinnedModel.content ?? "", "pinned_id": pinnedModel.id, "im_msg_id": pinnedModel.im_msg_id]
        
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []), let json = String(data: data, encoding: .utf8) else {
            return
        }
        let param = V2NIMSendCustomNotificationParams()
        let pushConfig = V2NIMNotificationPushConfig()
        pushConfig.pushEnabled = false
        param.pushConfig = pushConfig
        let notificationConfig = V2NIMNotificationConfig()
        notificationConfig.offlineEnabled = false
        param.notificationConfig = notificationConfig
        NIMSDK.shared().v2NotificationService.sendCustomNotification(viewmodel.conversationId, content: json, params: param) {
            
        } failure: { _ in
            
        }

    }
    
    func updateUI(isPinned: Bool = false){
        backBaseView.layoutIfNeeded()
        if isPinned {
            tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: backBaseView.bounds.height - chatInputView.menuHeight - TSBottomSafeAreaHeight - 50)
            chatInputView.frame = CGRect(x: 0, y: backBaseView.bounds.height - chatInputView.menuHeight - TSBottomSafeAreaHeight - 50.0, width: self.view.bounds.width, height: chatInputView.menuHeight + chatInputView.contentHeight)
        } else {
            
            tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: backBaseView.bounds.height - chatInputView.menuHeight - TSBottomSafeAreaHeight)
            chatInputView.frame = CGRect(x: 0, y: backBaseView.bounds.height - chatInputView.menuHeight - TSBottomSafeAreaHeight, width: self.view.bounds.width, height: chatInputView.menuHeight + chatInputView.contentHeight)
        }
    }
    
    @objc func handleCustomNotification(_ notification: Notification) {
//        guard let dict = notification.userInfo else {
//            return
//        }
    }
    
    // MARK: MeetingKit - 会议
    //后端接口加入会议- 会议记录
    func joinMeetingApi(meetingNum: String, password: String) {
        self.password = password
        meetingViewmodel.joinMeetingApi(meetingNum: meetingNum) {[weak self] requestdata, error in
            guard let self = self else {return}
            if let model = requestdata {
                self.meetingViewmodel.level = model.data.meetingLevel
                self.meetingViewmodel.roomUuid = (model.data.roomUuid).stringValue
                self.meetingViewmodel.meetingTimeLimit = model.data.meetingTimeLimit
                self.meetingViewmodel.meetingMemberLimit = model.data.meetingMemberLimit
                self.meetingViewmodel.startTime = (model.data.meetingInfo?.startTime ?? "").toInt()
                self.meetingViewmodel.isPrivate = (model.data.meetingInfo?.isPrivate ?? 0) == 1 ? true : false
                self.quertMeetingKitAccountInfo()
            } else {
                if let error = error as? NSError {
                    if error.code == 1012 {
                        print("会议不存在")
                        UIViewController.showBottomFloatingToast(with: "meeting_ended".localized, desc: "")
                    } else if error.code == 1013 {
                        UIViewController.showBottomFloatingToast(with: "meeeting_max_user_limit_reached".localized, desc: "")
                    } else {
                        UIViewController.showBottomFloatingToast(with: error.localizedDescription, desc: "")
                    }
                }
            }
        }
    }
    
    func quertMeetingKitAccountInfo(){
        let userUuid: String? = UserDefaults.standard.string(forKey: "MeetingKit-userUuid")
        let token: String? = UserDefaults.standard.string(forKey: "MeetingKit-userToken")
        if let userUuid = userUuid, let token = token {
            meetingViewmodel.meetingkitLogin(username: userUuid, password: token) {[weak self] code, msg in
                if code == 0 {
                    print("NEMeetingKit登录成功")
                    self?.joinInMeeting()
                }else {
                    UIViewController.showBottomFloatingToast(with:  msg ?? "" , desc: "")
                }
            }
        }
    }
    ///加入会议
    func joinInMeeting() {
        
        meetingViewmodel.joinInMeeting(meetingID: meetingViewmodel.meetingNum, password: self.password) {[weak self] requestdata, code, msg in
            guard let self = self else {
                return
            }
            if code == 0 {
                if self.meetingViewmodel.level == 0 {
                    self.startTimerHolder()
                }
            }
            else {
                UIViewController.showBottomFloatingToast(with:  msg ?? "" , desc: "")
            }
        }
    }
    
    func startTimerHolder(){
        if self.timer != nil {
            self.timeView?.removeFromSuperview()
            self.timer?.stopTimer()
        }
        let now = Date().timeIntervalSince1970
       
        let dt = Int(now) - self.meetingViewmodel.startTime / 1000
        
        self.meetingViewmodel.duration = self.meetingViewmodel.meetingTimeLimit * 60 - dt
        self.timer = TimerHolder()
        self.timer?.startTimer(seconds: 1, delegate: self, repeats: true)
        self.showTimeView()
    }
    
    
    func showTimeView(){
        guard let vc = UIViewController.topMostController  else {
            return
        }
        let nimute = self.meetingViewmodel.duration / 60
        let s = self.meetingViewmodel.duration % 60
        let nim = String(format: "%02d", nimute)
        let ss = String(format: "%02d", s)
        timeView = UIView()
        timeView?.backgroundColor = UIColor(red: 0.93, green: 0.13, blue: 0.13, alpha: 1)
        timeView?.layer.cornerRadius = 10
        timeView?.clipsToBounds = true
        vc.view.addSubview(timeView!)
        timeView?.isHidden = true
        timeLabel = UILabel()
        let timeStr = "\(nim):\(ss)"
        timeLabel?.text = String(format: "meeting_end_in_ios".localized, timeStr)
        timeLabel?.textColor = .white
        timeLabel?.font = UIFont.systemFont(ofSize: 15)
        timeLabel?.textAlignment = .center
        timeView?.addSubview(timeLabel!)
        timeView?.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.top.equalTo(26 + TSNavigationBarHeight)
            
        }
        timeLabel?.snp.makeConstraints { make in
            make.left.top.equalTo(3)
            make.right.bottom.equalTo(-3)
            make.height.equalTo(24)
        }
        
    }
    // MARK: Egg 🧧
    private func renderEggView() {
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = .fade
        eggOverlayView.layer.add(transition, forKey: nil)
        eggOverlayView.frame = UIScreen.main.bounds
        let count = UIApplication.shared.windows.count
        UIApplication.shared.windows[count - 1].addSubview(eggOverlayView)
        UIApplication.shared.windows[count - 1].bringSubviewToFront(eggOverlayView)
    }
    @objc func closeEggView() {
        eggOverlayView.removeFromSuperview()
        self.eggAttachment = nil
    }
    
    @objc func checkOpenEggStatus() {
        eggOverlayView.removeFromSuperview()
        
        guard let attachment = self.eggAttachment, let eggId = Int(attachment.eggId) else { return }
        self.view.isUserInteractionEnabled = false
        let isGroup = self.viewmodel.conversationType == .CONVERSATION_TYPE_P2P ? false : true
        TGIMNetworkManager.openEgg(eggId: eggId, isGroup: isGroup) { [weak self] eggResponse, error in
            guard let self = self else { return }
            self.view.isUserInteractionEnabled = true
            if error == nil {
                let vc = TGEggDetailViewController()
                vc.info = eggResponse
                vc.isSender = self.isEggAttachmentOutgoing ?? true
                vc.isGroup = isGroup
                let nav = TGNavigationController(rootViewController: vc).fullScreenRepresentation
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
                    self.present(nav, animated: true, completion: { [weak self] in
                        self?.closeEggView()
                    })
                }
            } else {
                self.closeEggView()
                UIViewController.showBottomFloatingToast(with: error?.localizedDescription ?? "", desc: "")
            }
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension TGChatViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.messages.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewmodel.messages[indexPath.row]
        //插入的时间类
        if model.type == .time {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TipMessageCell", for: indexPath) as! TipMessageCell
            cell.selectionStyle = .none
            cell.setData(model: model)
            return cell
        }
        // 多张图片类型
        if model.messageList.count >= 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MultiImageMessageCell", for: indexPath) as! MultiImageMessageCell
            cell.setData(model: model)
            cell.delegate = self
            return cell
        }
        
        switch model.messageType {
        case .MESSAGE_TYPE_TEXT:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextMessageCell", for: indexPath) as! TextMessageCell
            cell.setData(model: model)
            cell.delegate = self
            return cell
        case .MESSAGE_TYPE_IMAGE, .MESSAGE_TYPE_VIDEO:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageMessageCell", for: indexPath) as! ImageMessageCell
            cell.setData(model: model)
            cell.delegate = self
            return cell
        case .MESSAGE_TYPE_TIP, .MESSAGE_TYPE_NOTIFICATION:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TipMessageCell", for: indexPath) as! TipMessageCell
            cell.setData(model: model)
            return cell
        case .MESSAGE_TYPE_AUDIO:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AudioMessageCell", for: indexPath) as! AudioMessageCell
            cell.setData(model: model)
            cell.delegate = self
            return cell
        case .MESSAGE_TYPE_FILE:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FileMessageCell", for: indexPath) as! FileMessageCell
            cell.setData(model: model)
            cell.delegate = self
            return cell
        case .MESSAGE_TYPE_LOCATION:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationMessageCell", for: indexPath) as! LocationMessageCell
            cell.setData(model: model)
            cell.delegate = self
            return cell
        case .MESSAGE_TYPE_CUSTOM:
            if let type = model.customType {
                switch type {
                case .WhiteBoard:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "WhiteBoardMessageCell", for: indexPath) as! WhiteBoardMessageCell
                    cell.setData(model: model)
                    cell.delegate = self
                    return cell
                case .VideoCall:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCallingCell", for: indexPath) as! VideoCallingCell
                    cell.setData(model: model)
                    cell.delegate = self
                    return cell
                case .Sticker, .RPS:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "StickerRPSMessageCell", for: indexPath) as! StickerRPSMessageCell
                    cell.setData(model: model)
                    cell.delegate = self
                    return cell
                case .Egg:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "EggMessageCell", for: indexPath) as! EggMessageCell
                    cell.setData(model: model)
                    cell.delegate = self
                    return cell
                case .ContactCard:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NameCardMessageCell", for: indexPath) as! NameCardMessageCell
                    cell.setData(model: model)
                    cell.delegate = self
                    return cell
                case .Reply:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyMessageCell", for: indexPath) as! ReplyMessageCell
                    cell.setData(model: model)
                    cell.delegate = self
                    return cell
                case .MeetingRoom:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingMessageCell", for: indexPath) as! MeetingMessageCell
                    cell.setData(model: model)
                    cell.delegate = self
                    return cell
                case .SocialPost:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SocialPostMessageCell", for: indexPath) as! SocialPostMessageCell
                    cell.setData(model: model)
                    cell.delegate = self
                    return cell
                case .Voucher:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "VoucherMessageCell", for: indexPath) as! VoucherMessageCell
                    cell.setData(model: model)
                    cell.delegate = self
                    return cell
                case .MiniProgram:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MiniProgramMessageCell", for: indexPath) as! MiniProgramMessageCell
                    cell.setData(model: model)
                    cell.delegate = self
                    return cell
                case .Translate: 
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TranslateMessageCell", for: indexPath) as! TranslateMessageCell
                    cell.setData(model: model)
                    cell.delegate = self
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TextMessageCell", for: indexPath) as! TextMessageCell
                    cell.setData(model: model)
                    cell.contentLabel.text = "unknown_message".localized
                    cell.delegate = self
                   
                    return cell
                }
            }
            return UITableViewCell()
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextMessageCell", for: indexPath) as! TextMessageCell
            cell.setData(model: model)
            cell.contentLabel.text = "unknown_message".localized
            cell.delegate = self
           
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView.isEditing else {
            return
        }
        let model = viewmodel.messages[indexPath.row]
        guard  let message = model.nimMessageModel , model.type != .time else {
            return
        }
        
//        if !MessageUtils.canMessageBeForwarded(model) {
//            shareButton.isEnabled = false
//        }
        
        selectedMsgId.append(message.messageClientId ?? "")
        self.updateSelectedItem()
        
        if (tableView.indexPathsForSelectedRows?.count ?? 0) > 30 {
            DispatchQueue.main.async(execute: { [self] in
                var alert = UIAlertController()
                alert = UIAlertController(title: nil, message: "choice_overrun".localized, preferredStyle: .alert)
                let ok = UIAlertAction(title: "confirm".localized, style: .cancel, handler: { [self] action in
                    DispatchQueue.main.async(execute: { [self] in
                        let selectedMessageIndex = tableView.indexPathsForSelectedRows
                        if let lastIndex = selectedMessageIndex?.last {
                            self.updateTableViewSelection(by: lastIndex, select: false)
                        }
                    })
                })
                alert.addAction(ok)
                self.present(alert, animated: true)
            })
        }
        
    }
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.isEditing else {
            return
        }
        let model = viewmodel.messages[indexPath.row]
        guard  let message = model.nimMessageModel, model.type != .time else {
            return
        }
        
        selectedMsgId.removeAll { $0 == message.messageClientId }
        self.updateSelectedItem()
    }
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if viewmodel.messages.count <= indexPath.row {return false}
        let model = viewmodel.messages[indexPath.row]
        if model.type == .time {
            return false
        }
        if model.nimMessageModel?.messageType == .MESSAGE_TYPE_NOTIFICATION {
            return false
        }
        guard let message = model.nimMessageModel else { return false }
        if let ext = message.serverExtension, let dict = ext.toDictionary, dict.keys.contains("secretChatTimer") { return false }
        if isForwarding, let attach = model.customAttachment {
            return attach.canBeForwarded()
        }
        return true
    }
    
}
//  MARK: BaseMessageCellDelegate
extension TGChatViewController: BaseMessageCellDelegate {
    /// 长按头像
    func longPressUserAvatar(cell: BaseMessageCell?, model: TGMessageData?) {
        if self.viewmodel.conversationType != .CONVERSATION_TYPE_TEAM { return }
        guard let message = model?.nimMessageModel, !isLeavedGroupUser , let userId = message.senderId else { return }
        if userId == RLSDKManager.shared.loginParma?.imAccid { return }
        MessageUtils.getAvatarIcon(sessionId: userId, conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
            self?.chatInputView.insertTagTextIntoContent(userId: 0, userName: avatarInfo.nickname ?? "")
            self?.mentionsUsernames.append(AutoMentionsUser(text: avatarInfo.nickname ?? "", context: ["username": userId]))
        }

    }
    
    ///重发消息
    func reSendMessage(cell: BaseMessageCell?, model: TGMessageData?) {
        if let message = model?.nimMessageModel {
            viewmodel.sendMessage(message: message, conversationId: viewmodel.conversationId, params: nil) { _, _, _ in
                
            }
        }
    }
    
    
    func meetingTapped(cell: BaseMessageCell?, model: TGMessageData?) {
        guard let attachment = model?.customAttachment as? IMMeetingRoomAttachment else { return }
        
        AuthorizeStatusUtils.checkAuthorizeStatusByType(type: .videoCall, viewController: self, completion: {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "tips".localized, message: "meeting_join_confirmation".localized, preferredStyle: .alert)
                
                let cancel = UIAlertAction(title: "cancel".localized, style: .cancel)
                let comfirm = UIAlertAction(title: "confirm".localized,style: .default) {_ in
                    self.joinMeetingApi(meetingNum: attachment.meetingNum, password: attachment.meetingPassword)
                }
                alert.addAction(cancel)
                alert.addAction(comfirm)
                self.present(alert, animated: true)
            }
            
        })
        
    }
    
    func replyMessageTapped(cell: BaseMessageCell?, model: TGMessageData?) {
        guard let _ = model?.nimMessageModel, let attachment = model?.customAttachment as? IMReplyAttachment else { return }
        if let indexPath = viewmodel.getIndexPathForMessageClientId(messageClientId: attachment.messageID) {
            self.scrollToMessage(by: indexPath, animation: true)
        }
    }

    func startAudioPlay(cell: BaseMessageCell?, model: TGMessageData?) {
        if let cell = cell as? AudioMessageCell {
            viewmodel.startPlay(cell: cell, model: model)
        }
    }
    
    func selectionLanguageTapped(cell: BaseMessageCell?, model: TGMessageData?) {
        guard let nimMessage = model?.nimMessageModel, let audioObject = nimMessage.attachment as? V2NIMMessageAudioAttachment else { return }
        
        let audioPath = audioObject.url ?? ""
        let fileUrl = URL(fileURLWithPath: audioPath)
        
        let voiceToTextVC = TGVoiceToTextIMViewController(fileUrl: fileUrl, selectedLanguage: currentSelectedLangCode, isLanguageSelection: true)
        voiceToTextVC.onLanguageChanged = { [weak self] model in
            guard let self = self else { return }
            self.currentSelectedLangCode = model
        }
        self.present(voiceToTextVC, animated: true)
    }
    
    /// 点击cell
    func tapItemMessage(cell: BaseMessageCell?, model: TGMessageData?) {
        guard let model = model, let message = model.nimMessageModel  else { return }
        switch model.messageType {
        case .MESSAGE_TYPE_IMAGE:
            viewmodel.searchImageVideoMessage {[weak self] messages, error in
                guard let self = self, let messages = messages, messages.count > 0  else { return }
                var mediaArray: [MediaPreviewObject] = []
                var focusObject: MediaPreviewObject = MediaPreviewObject()
                for previewMessage in messages {
                    switch previewMessage.messageType {
                    case .MESSAGE_TYPE_IMAGE:
                        if let previewMedia = MessageUtils.previewImageVideoMedia(by: previewMessage){
                            if previewMessage.messageClientId == message.messageClientId {
                                focusObject = previewMedia
                            }
                            mediaArray.append(previewMedia)
                        }
                        break
                    case .MESSAGE_TYPE_VIDEO:
                        if let previewMedia = MessageUtils.previewImageVideoMedia(by: previewMessage){
                            if previewMessage.messageClientId == message.messageClientId {
                                focusObject = previewMedia
                            }
                            mediaArray.append(previewMedia)
                        }
                    default:
                        break
                    }
                }
             
                DispatchQueue.main.async {
                    let vc = TGMediaGalleryPageViewController(objects: mediaArray, focusObject: focusObject, conversationId: self.viewmodel.conversationId, showMore: true)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            break
        case .MESSAGE_TYPE_VIDEO:
            guard let object = message.attachment as? V2NIMMessageVideoAttachment else { return }

            guard let url = object.url else { return }
            let vc = TGChatroomplayerViewController(url: url)
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.present(vc, animated: true, completion: nil)
        case .MESSAGE_TYPE_AUDIO:
            break
        case .MESSAGE_TYPE_LOCATION:
            guard let attach = message.attachment as? V2NIMMessageLocationAttachment else { return }
            let model = ChatLocaitonModel()
            model.title = attach.address
            model.lat = attach.latitude
            model.lng = attach.longitude
            openLocation(model: model)
            break
        case .MESSAGE_TYPE_FILE:
            guard let attach = message.attachment as? V2NIMMessageFileAttachment, let path = attach.path else { return}
            if FileManager.default.fileExists(atPath: path) {
                let url = URL(fileURLWithPath: path)
                if url.isFileURL {
                    self.openWithDocumentInterator(object: attach)
                } else {
                    let vc = TGWebViewController()
                    vc.urlString = attach.url ?? ""
                    vc.customNavigationBar.title = attach.name
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                self.viewmodel.downLoadfFile(filePath: path, url: attach.url ?? "")
                let vc = TGIMFilePreViewController(object: attach)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case .MESSAGE_TYPE_CUSTOM: //自定义消息
            if let customType = model.customType {
                switch customType {
                case .WhiteBoard:
                    guard let attach = model.customAttachment as? IMWhiteboardAttachment else { return}
                    self.showWhiteBoard(channelName: attach.channel)
                case .ContactCard:
                    guard let attach = model.customAttachment as? IMContactCardAttachment else { return}
                    RLSDKManager.shared.imDelegate?.didPressNameCard(memberId: attach.memberId)
                case .SocialPost:
                    guard let attach = model.customAttachment as? IMSocialPostAttachment else { return}
                    RLSDKManager.shared.imDelegate?.didPressSocialPost(urlString: attach.postUrl)
                case .MeetingRoom:
                    break
                case .Voucher:
                    guard let attach = model.customAttachment as? IMVoucherAttachment else { return}
                    RLSDKManager.shared.imDelegate?.didPressVoucher(urlString: attach.postUrl)
                case .Egg:
                    guard let message = model.nimMessageModel, let attachment = model.customAttachment as? IMEggAttachment  else { return }
                    self.chatInputView.textView.resignFirstResponder()
                    self.eggAttachment = attachment
                    self.isEggAttachmentOutgoing = message.isSelf
                    
                    if message.isSelf {
                        self.checkOpenEggStatus()
                    } else {
                        MessageUtils.getAvatarIcon(sessionId: message.senderId ?? "", conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
                            guard let self = self else { return }
                            self.eggOverlayView.updateInfo(avatarInfo: avatarInfo, name: avatarInfo.nickname ?? "", message: attachment.message, uids: attachment.uids, completion: {
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                                    self.renderEggView()
                                }
                            })
                        }
                        
                    }
                case .MiniProgram:
                    guard let attach = model.customAttachment as? IMMiniProgramAttachment else { return}
                    RLSDKManager.shared.imDelegate?.didPressMiniProgrom(appId: attach.appId, path: attach.path)
                case .Translate:
                    guard let attach = model.customAttachment as? IMTextTranslateAttachment, let oriMessage = self.viewmodel.findMessageData(messageClientId: model.nimMessageModel?.messageClientId ?? "")  else { return}
                    textTranslate(withText: attach.originalText, oriMessage: oriMessage, translateMessage: model)
                default:
                    break
                }
            }
        default:
            break
        }
    }
    
    func handleBaseMessageCellLongPress(cell: BaseMessageCell, model: TGMessageData?) {
        guard let model = model, !isLeavedGroupUser , let message = model.nimMessageModel else { return }
        let isPinned = self.viewmodel.messagePinned(for: message)
        let items = MessageUtils.itemsActionArray(model, isPinned: isPinned)
        if items.count > 0  && !tableView.isEditing {
            var groupItems: [GroupIMActionItem] = []
            for (index, item) in items.enumerated() {
                if groupItems.isEmpty {
                    groupItems.append(GroupIMActionItem(sectionId: 0, items: [item]))
                    var i = index + 1
                    repeat {
                        if items.indices.contains(i) {
                            let nextItem = items[i]
                            
                            if let firstGroup = groupItems.first {
                                if firstGroup.items.count < 4 {
                                    firstGroup.items.append(nextItem)
                                } else {
                                    break
                                }
                            } else {
                                break
                            }
                        }
                        
                        i += 1
                    } while items.indices.contains(i)
                } else {
                    if groupItems.contains(where: { $0.items.contains(where: { $0 == item })}) == false {
                        groupItems.append(GroupIMActionItem(sectionId: groupItems.count, items: [item]))
                        var i = index + 1
                        repeat {
                            if items.indices.contains(i) {
                                let nextItem = items[i]
                                
                                if groupItems.last!.items.count < 4 {
                                    groupItems.last!.items.append(nextItem)
                                } else {
                                    break
                                }
                            }
                            
                            i += 1
                        } while items.indices.contains(i)
                    } else {
                        continue
                    }
                }
            }
            
            if let indexPath = viewmodel.getIndexPathForMessage(model: model) {
                let rectOfCellInTableView = self.tableView.rectForRow(at: indexPath)
                let rectOfCellInSuperview = self.tableView.convert(rectOfCellInTableView, to: self.tableView.superview)
                let preference = TGToolChoosePreferences()
                preference.drawing.bubble.color = UIColor(red: 38, green: 50, blue: 56)
                preference.drawing.message.color = .white
                preference.drawing.background.color = .clear
                preference.drawing.bubble.cornerRadius = 10
                
                if rectOfCellInSuperview.y > ((ScreenHeight - TSNavigationBarHeight) / 2 - self.chatInputView.menuHeight - 25) {
                    cell.showIMToolChoose(identifier: "", data: groupItems, arrowPosition: !message.isSelf ? .bottomLeft : .bottomRight, preferences: preference, delegate: self)
                } else {
                    if (cell.frame.y + cell.height + self.chatInputView.menuHeight) > self.tableView.contentSize.height {
                        self.tableView.contentInset.bottom = (self.chatInputView.menuHeight) * 2.5
                        
                        UIView.animate(withDuration: 0.2) {
                            self.tableView.scrollRectToVisible(CGRect(x: 0, y: cell.frame.y + (cell.frame.height / 2), width: cell.frame.width, height: cell.frame.height), animated: false)
                        } completion: { _ in
                            cell.showIMToolChoose(identifier: "", data: groupItems, arrowPosition: !message.isSelf ? .topLeft : .topRight, preferences: preference, delegate: self, dismissCompletion: {
                                UIView.animate(withDuration: 0.2) {
                                    self.tableView.contentInset.bottom = self.chatInputView.menuHeight
                                }
                            })
                        }
                    } else if rectOfCellInTableView.height > (ScreenHeight - self.chatInputView.menuHeight) {
                        UIView.animate(withDuration: 0.2) {
                            self.tableView.scrollRectToVisible(CGRect(x: 0, y: cell.frame.y + (cell.frame.height / 2), width: cell.frame.width, height: cell.frame.height), animated: false)
                        } completion: { _ in
                            cell.showIMToolChoose(identifier: "", data: groupItems, arrowPosition: !message.isSelf ? .topLeft : .topRight, preferences: preference, delegate: self)
                        }
                    } else if rectOfCellInSuperview.y > 200 && (self.tableView.height - rectOfCellInSuperview.y - rectOfCellInTableView.height ) < 180 {
                        cell.showIMToolChoose(identifier: "", data: groupItems, arrowPosition: !message.isSelf ? .bottomLeft : .bottomRight, preferences: preference, delegate: self)
                    } else  {
                        cell.showIMToolChoose(identifier: "", data: groupItems, arrowPosition: !message.isSelf ? .topLeft : .topRight, preferences: preference, delegate: self)
                    }
                }
                
                viewmodel.operationModel = model
            }
            
           
        }
    }
    
    func tapUserAvatar(cell: BaseMessageCell?, model: TGMessageData?) {
        guard let accoudId = model?.nimMessageModel?.senderId else {
            return
        }
        RLSDKManager.shared.imDelegate?.didPressNameCard(memberId: accoudId)
    }
    
    
}


extension TGChatViewController{
    
    // MARK: UIScrollViewDelegate
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    // MARK: OperationView Action
    //回复消息
    func showReplyMessageView() {
        guard let model = viewmodel.operationModel else { return }
        replyView?.removeFromSuperview()
        replyView = MessageReplyView()
        viewmodel.isReplying = true
        backBaseView.addSubview(replyView!)
        replyView?.closeBtn.addTarget(self, action: #selector(closeReply), for: .touchUpInside)
        replyView?.translatesAutoresizingMaskIntoConstraints = false
        replyView?.snp.makeConstraints { make in
           // make.top.equalTo(self.backBaseView.bounds.height - normalInputHeight - rePlyHeight - TSBottomSafeAreaHeight)
            make.bottom.equalTo(chatInputView.snp.top)
            make.height.equalTo(rePlyHeight)
            make.left.right.equalTo(0)
        }
        replyView?.configure(model)
        let  contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: rePlyHeight, right: 0)
        self.tableView.contentInset = contentInsets
    }
    
    @objc func closeReply(){
        replyView?.removeFromSuperview()
        viewmodel.isReplying = false
        let  contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.tableView.contentInset.bottom - rePlyHeight, right: 0)
        self.tableView.contentInset = contentInsets
    }
    
    func showStickerCollection() {
        if let message = viewmodel.operationModel, let attachment = message.customAttachment as? IMStickerAttachment {
            if attachment.chartletCatalog == "-1" {
                let vc = CustomerStickerViewController(sticker: attachment.stickerId)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                RLSDKManager.shared.imDelegate?.didPressStickerDetail(bundleId: attachment.chartletCatalog)
            }
        }
    }
    
  
    func sendMediaMessage(didFinishPickingMediaWithInfo info: [UIImagePickerController
        .InfoKey: Any]) {
            var imageName = "IMG_0001"
            var imageWidth: Int32 = 0
            var imageHeight: Int32 = 0
            var videoDuration: Int32 = 0
            
            // 获取展示名称
            if let imgUrl = info[.referenceURL] as? URL {
                let fetchRes = PHAsset.fetchAssets(withALAssetURLs: [imgUrl], options: nil)
                let asset = fetchRes.firstObject
                if let fileName = asset?.value(forKey: "filename") as? String {
                    imageName = fileName
                }
            }
            
            // 获取图片宽高、视频时长
            // phAsset 不一定有
            if #available(iOS 11.0, *) {
                if let phAsset = info[.phAsset] as? PHAsset {
                    imageWidth = Int32(phAsset.pixelWidth)
                    imageHeight = Int32(phAsset.pixelHeight)
                    videoDuration = Int32(phAsset.duration * 1000)
                }
            }
            
            // video
            if let videoUrl = info[.mediaURL] as? URL {
                print("image picker video : url", videoUrl)
                // 获取视频宽高、时长
                let asset = AVURLAsset(url: videoUrl)
                videoDuration = Int32(asset.duration.seconds * 1000)
                let track = asset.tracks(withMediaType: .video).first
                if let track = track {
                    let size = track.naturalSize
                    let transform = track.preferredTransform
                    let correctedSize = size.applying(transform)
                    imageWidth = Int32(abs(correctedSize.width))
                    imageHeight = Int32(abs(correctedSize.height))
                }
                
               // weak var weakSelf = self
                viewmodel.sendVideoMessage(url: videoUrl, name: imageName, width: imageWidth, height: imageHeight, duration: videoDuration, conversationId: viewmodel.conversationId) { message, error, progress in
                    //if progress > 0, progress <= 100 {
                    // self?.setModelProgress(message, progress)
                    //  }
                    
                }
                
                return
            }
            
            if #available(iOS 11.0, *) {
                var imageUrl = info[.imageURL] as? URL
                var image = info[.originalImage] as? UIImage
                image = image?.fixOrientation()
                // 获取图片宽度
                if let width = image?.size.width {
                    imageWidth = Int32(width)
                }
                // 获取图片高度度
                if let height = image?.size.height {
                    imageHeight = Int32(height)
                }
                
                let pngImage = image?.pngData()
                var needDelete = false
                // 无url则临时保存到本地，发送成功后删除临时文件
                if imageUrl == nil {
                    if let data = pngImage {
                        let url = FileUtils.getDocumentsDirectory().appendingPathComponent("photo_\(UUID().uuidString).png")
                        do {
                            try data.write(to: url)
                            imageUrl = url
                            needDelete = true
                        } catch  {
                            print("Error saving image: \(error)")
                            // showToast(chatLocalizable("image_is_nil"))
                        }
                    }
                }
                guard let imageUrl = imageUrl else {
                    return
                }
                
                if let url = info[.referenceURL] as? URL {
                    if url.absoluteString.hasSuffix("ext=GIF") == true {
                        // GIF 需要特殊处理
                        let imageAsset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset
                        let options = PHImageRequestOptions()
                        options.version = .current
                        guard let asset = imageAsset else {
                            return
                        }
                        weak var weakSelf = self
                        PHImageManager.default().requestImageData(for: asset, options: options) { imageData, dataUTI, orientation, info in
                            if let data = imageData {
                                let tempDirectoryURL = FileManager.default.temporaryDirectory
                                let uniqueString = UUID().uuidString
                                let temUrl = tempDirectoryURL.appendingPathComponent(uniqueString + ".gif")
                                print("tem url path : ", temUrl.path)
                                do {
                                    try data.write(to: temUrl)
                                    DispatchQueue.main.async {
                                        weakSelf?.viewmodel.sendImageMessage(path: temUrl.path, name: imageName, width: imageWidth, height: imageHeight, conversationId: weakSelf?.viewmodel.conversationId ?? "") { error in
                                            
                                            
                                        }
                                    }
                                } catch {
                                    
                                }
                            }
                        }
                        return
                    }
                }
                
                viewmodel.sendImageMessage(path: imageUrl.relativePath, name: imageName, width: imageWidth, height: imageHeight, conversationId: viewmodel.conversationId) { _ in
                    // 删除临时保存的图片
                    if needDelete {
                        try? FileManager.default.removeItem(at: imageUrl)
                    }
                }
        }
    }
    
}
// MARK: UIDocumentInteractionControllerDelegate
extension TGChatViewController: UIDocumentInteractionControllerDelegate{
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    public func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        controller.dismissPreview(animated: true)
    }
}
//MARK: TGChatViewModelDelegate
extension TGChatViewController: TGChatViewModelDelegate {
    
    func onSend(_ message: V2NIMMessage, succeeded: Bool) {
       // let row = viewmodel.messages.count - 1
        DispatchQueue.main.async { [weak self] in
            self?.tableView.removePlaceholderViews()
            self?.tableView.reloadData()
//            let indexpath = IndexPath(row: row, section: 0)
//            self?.tableView.insertRow(at: indexpath, with: .none)
            self?.scrollTableViewToBottom()
            
        }
    }
    
    func onReceive(_ messages: [V2NIMMessage]) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.removePlaceholderViews()
            self?.tableView.reloadData()
            self?.scrollTableViewToBottom()
            self?.viewmodel.readMessageReceipt(messages: messages, completion: nil)
        }
    }
    
    func onReceive(_ readReceipts: [V2NIMP2PMessageReadReceipt]) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func onReceive(_ readReceipts: [V2NIMTeamMessageReadReceipt]) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func onReceiveMessagesModified(_ messages: [V2NIMMessage]) {
        
    }
    
    func onRevokeMessage(atIndexs: [IndexPath]) {
        self.tableView.reloadData()
    }
    
    func onMessageRevokeNotifications(_ revokeNotifications: [V2NIMMessageRevokeNotification]) {
        
    }
    
    func onMessagePinNotification(_ pinNotification: V2NIMMessagePinNotification) {
        
    }
    
    func onMessageQuickCommentNotification(_ notification: V2NIMMessageQuickCommentNotification) {
        
    }
    
    func onMessageDeletedNotifications(_ messageDeletedNotification: [V2NIMMessageDeletedNotification]) {
        
    }
    
    func onClearHistoryNotifications(_ clearHistoryNotification: [V2NIMClearHistoryNotification]) {
        
    }
    
    //MARK: RecordAudio
    func recordAudio(_ filePath: String?, didBeganWithError error: (any Error)?) {
        if filePath == nil || error != nil {
            chatInputView.recording = false
        }
    }
    
    func recordAudio(_ filePath: String?, didCompletedWithError error: (any Error)?) {
        if error == nil {
            if viewmodel.recordFileCanBeSend(filePath: filePath) {
                guard let filepath = filePath  else { return }
                let message = MessageUtils.audioV2Message(filePath: filepath, name: nil, sceneName: nil, duration: Int32(self.chatInputView.audioRecordIndicator.recordTime * 1000))
                if self.chatInputView.recordPhase == .converted || self.chatInputView.recordPhase == .converting || self.chatInputView.recordPhase == .converterror{
                    self.viewmodel.saveAudioMessage = message
                    self.viewmodel.saveAudioFilePath = filepath
                    return
                }
                let volumeLevels = self.getVolumeLevels()
                message.serverExtension = ["voice":volumeLevels].toJSON
                NIMSDK.shared().v2MessageService.send(message, conversationId: self.viewmodel.conversationId, params: nil) { _ in
                    
                } failure: { _ in
                    
                }
            }
        }
        chatInputView.recording = false
    }
    
    func recordAudioDidCancelled() {
        chatInputView.recording = false
    }
    
    func recordAudioProgress(_ currentTime: TimeInterval) {
        chatInputView.updateAudioRecordTime(time: currentTime)
    }
    
    //获取处理后的语音分贝数据
    func getVolumeLevels() -> String {
        let saveLevels = self.chatInputView.audioRecordIndicator.recordStateView.saveLevels
        let filterArrays = saveLevels.filterDuplicates({$0})
        var resultArrays = [CGFloat]()
        let audioSecond = filterArrays.count / 10
        switch audioSecond {
        case 5..<10:
            resultArrays = filterArrays.enumerated().filter { $0.offset % 2 == 0 }.map { CGFloat($0.element) }
        case 10..<25:
            resultArrays = filterArrays.enumerated().filter { $0.offset % 4 == 0 }.map { CGFloat($0.element) }
        case 25..<40:
            resultArrays = filterArrays.enumerated().filter { $0.offset % 6 == 0 }.map { CGFloat($0.element) }
        default:
            resultArrays = filterArrays.enumerated().filter { $0.offset % 1 == 0 }.map { CGFloat($0.element) }
            break
        }
        // 转换为Android需要的格式
        let targetArray = (0..<27).map { index -> Int in
            if index < resultArrays.count {
                let value = Int(resultArrays[index] * 100)
                return min(value, 55)
            } else {
                return 5
            }
        }
        let dblist = VoiceDBBean(dbList: targetArray)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let jsonData = try? encoder.encode(dblist),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return ""
    }
    
    func onReceiveCustomNotification(senderId: String, content: [String : Any]) {
        guard let type = content[NTESNotifyID] as? Int  else {
            return
        }
        if type == NTESCommandTyping && self.viewmodel.conversationType == .CONVERSATION_TYPE_P2P && senderId == self.viewmodel.sessionId {
//            isTypingLabel.isHidden = false
//            self.titleTimer?.stopTimer()
//            self.titleTimer?.startTimer(seconds: 5, delegate: self, repeats: false)
        }
        if type == NTESPinnedStored && self.viewmodel.conversationType == .CONVERSATION_TYPE_TEAM {
            loadMessagePins()
        }
        if type == NTESPinnedDeleted && self.viewmodel.conversationType == .CONVERSATION_TYPE_TEAM{
            if let pinned_id = content["pinned_id"] as? Int , let item = viewmodel.pinnedList.first(where: { e in
                e.id == pinned_id
            }) {
                self.messageDeletePinItem(pinnedModel: item)
            }
            
        }
        if type == NTESPinnedUpdated && self.viewmodel.conversationType == .CONVERSATION_TYPE_TEAM {
            loadMessagePins()
        }
    }
    
    
}
//MARK: ChatInputViewDelegate
extension TGChatViewController: ChatInputViewDelegate {
    ///贴纸
    func didPressAdd(_ sender: Any?) {
        layoutInputView(offset: TSBottomSafeAreaHeight)
        RLSDKManager.shared.imDelegate?.didPressAdd(sender)
    }
    
    func selectedEmoticon(_ emoticonID: String?, catalog emotCatalogID: String?, description: String?, stickerId: String?) {
        guard let stickerUrl = emoticonID, let bundleId = emotCatalogID, let stickerId = stickerId else { return }
        let rawAttachment = CustomAttachmentDecoder.stickerMessageEncode(chartletId: stickerUrl, stickerId: stickerId, chartletCatalog: bundleId)
        viewmodel.sendCustomMessage(text: "", rawAttachment: rawAttachment, conversationId: viewmodel.conversationId) { _ in
        }
        
    }
    
    func didPressMySticker(_ sender: Any?) {
        layoutInputView(offset: TSBottomSafeAreaHeight)
        RLSDKManager.shared.imDelegate?.didPressMySticker(sender)
    }
    
    func didPressCustomerSticker() {
        layoutInputView(offset: TSBottomSafeAreaHeight)
        let vc = CustomerStickerViewController(sticker: "")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    ///发送地址
    func didSendLocation(isSend: Bool, title: String, coordinate: CLLocationCoordinate2D) {
        if isSend {
            let model = ChatLocaitonModel()
            model.title = title
            model.lat = coordinate.latitude
            model.lng = coordinate.longitude
            self.viewmodel.sendLocationMessage(model: model, conversationId: self.viewmodel.conversationId, { _ in
                
            })
        } else {
            openLocation(model: nil)
        }
    }
    ///更多菜单
    func didSelectMoreCell(cell: InputMoreCell) {
        guard let item = cell.cellData else {
            return
        }
        switch item {
        case .album:
            openPhotoLibrary()
        case .file:
            openFile()
        case .sendLocation:
            break
        case .sendCard:
            onContactTapped()
        case .camera:
            openCamera()
        case .redpacket:
            eggTapped()
        case .videoCall:
            if viewmodel.conversationType == .CONVERSATION_TYPE_P2P {
                let vc = RLAudioCallController(callee: self.viewmodel.sessionId, callType: .SIGNALLING_CHANNEL_TYPE_VIDEO)
                let nav = TGNavigationController(rootViewController: vc)
                self.present(nav.fullScreenRepresentation, animated: true)
            } else {
                MessageUtils.fetchMembersTeam(teamId: self.viewmodel.sessionId) {[weak self] userIds in
                    DispatchQueue.main.async {
                        self?.teamMeeting(userIds: userIds)
                    }
                    
                }
            }
        case .voiceCall:
            let vc = RLAudioCallController(callee: self.viewmodel.sessionId, callType: .SIGNALLING_CHANNEL_TYPE_AUDIO)
            let nav = TGNavigationController(rootViewController: vc)
            self.present(nav.fullScreenRepresentation, animated: true)
        case .whiteBoard:
            openWhiteBoard()
        case .voiceToText:
            break
        case .rps:
            let value = arc4random() % 3 + 1
            let rawAttachment = CustomAttachmentDecoder.RPSMessageEncode(value: Int(value))
            viewmodel.sendCustomMessage(text: "", rawAttachment: rawAttachment, conversationId: viewmodel.conversationId) { _ in
            }
        case .collectMessage:
            let vc = MsgCollectionViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    func sendText(text: String?, attribute: NSAttributedString?) {
        guard let content = text, content.count > 0 else {
          return
        }
        
        if content.isValidURL() {
            guard let contentUrl = TGAppUtil.matchUrlInString(urlString: content) else { return }
            let attactment = IMSocialPostAttachment()
            attactment.postUrl = content
            attactment.contentUrl = contentUrl.absoluteString
            let rawAttachment = attactment.encode()
            let message = MessageUtils.customV2Message(text: "", rawAttachment: rawAttachment)
            viewmodel.sendMessage(message: message, conversationId: viewmodel.conversationId) { _, _, _ in
                
            }
            return
        }
        var remoteExt: [String: Any]?
        if self.mentionsUsernames.count > 0 {
             remoteExt = viewmodel.getAtRemoteExtension(self.mentionsUsernames)
        }
        
        if viewmodel.isReplying, let model = viewmodel.operationModel, let reply = self.replyView {
            MessageUtils.replyV2Message(with: model, replyView: reply, text: content) {[weak self] message in
                guard let self = self, let message = message else { return }
                self.closeReply()
                message.serverExtension = remoteExt?.toJSON
                self.viewmodel.sendMessage(message: message, conversationId: self.viewmodel.conversationId) { _, _, _ in
                    
                }
            }
            
        } else {
            viewmodel.sendTextMessage(text: content, conversationId: viewmodel.conversationId, remoteExt: remoteExt) {message, error in
                if let _ = error {
                    
                }
            }
        }
        self.mentionsUsernames.removeAll()
        
    }
    ///移除 已删除的 mentionsUsernames
    func removeAtUsertext(text: String) {
        var arr: [AutoMentionsUser] = []
        self.mentionsUsernames.forEach { mentionsUser in
            let user = "@" + mentionsUser.text
            if text.contains(user) {
                arr.append(mentionsUser)
            }
        }
        arr.forEach { autoMentionsUser in
            if let index = self.mentionsUsernames.firstIndex(where: { mentionsUser in
                mentionsUser.text == autoMentionsUser.text
            }) {
                self.mentionsUsernames.remove(at: index)
            }
        }
        
    }
    
    
    func willSelectItem(show: Bool) {
        if show {
            self.layoutInputView(offset: self.bottomExanpndHeight)
        }else{
            self.layoutInputView(offset: TSBottomSafeAreaHeight)
        }
    }
    
    func textChanged(text: String) -> Bool {
        /// 群@
        if viewmodel.conversationType == .CONVERSATION_TYPE_TEAM , text == "@" {
            
            let option = V2NIMTeamMemberQueryOption()
            option.limit = 100
            option.nextToken = ""
            option.roleQueryType = .TEAM_MEMBER_ROLE_QUERY_TYPE_ALL
            
            NIMSDK.shared().v2TeamService.getTeamMemberList(viewmodel.sessionId, teamType: .TEAM_TYPE_NORMAL, queryOption: option) {[weak self] listResult in
                guard let self = self, let memberList = listResult.memberList, let accontId = RLSDKManager.shared.loginParma?.imAccid else { return }
                self.chatInputView.textView.resignFirstResponder()
                let teamMembers: [String] = memberList.filter({ $0.accountId != accontId }).map({ $0.accountId })
                let contactsPickerVC = TGContactsPickerViewController(configuration: TGContactsPickerConfig.mentionConfig(teamMembers), finishClosure: nil)
                contactsPickerVC.modalPresentationStyle = .fullScreen
                contactsPickerVC.cancelClosure = { [weak self] in
                    self?.chatInputView.textView.deleteBackward()
                }
                contactsPickerVC.finishClosure = { [weak self] contacts in
                    guard let self = self else { return }
                    for contact in contacts {
                        if contact.displayname.count == 0 {
                            self.chatInputView.insertTagTextIntoContent(userId: contact.userId, userName: contact.userName)
                        } else {
                            self.chatInputView.insertTagTextIntoContent(userId: contact.userId, userName: contact.displayname)
                        }
                        self.mentionsUsernames.append(AutoMentionsUser(text: contact.displayname, context: ["username": contact.userName]))
                    }

                }
                DispatchQueue.main.async {
                    let nav = TGNavigationController(rootViewController: contactsPickerVC)
                    nav.modalPresentationStyle = .overFullScreen
                    self.present(nav, animated: true, completion: nil)
                }
                
            } failure: { error in
                
            }
            return false
        } else {
            return true
        }
        
    }
    
    func textDelete(range: NSRange, text: String) -> Bool {
        
        return true
    }
    
    func textFieldDidChange(_ textField: UITextView) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextView) {
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextView) {
        
    }
    
    // MARK: Audio
    func onStartRecording() {
        //RLAuthManager.shared.checkRecordPermission()
        if NIMSDK.shared().mediaManager.isPlaying() {
            NIMSDK.shared().mediaManager.stopPlay()
        }
        chatInputView.recognizedText = ""
        chatInputView.recording = true

        NIMSDK.shared().mediaManager.record(NIMAudioType.AAC, duration: 65)
        //保存识别结果
        SpeechVoiceDetectManager.shared.state = .recording
        SpeechVoiceDetectManager.shared.onReceiveValue = { [weak self] (receiveValue, isFinal) in
            guard let self = self else { return }
            //判断识别结果是否为空
            guard let receiveValue = receiveValue, receiveValue.count > 0 else {
                //判断之前识别到了结果，但是最终为nil 取用之前的结果显示
                if self.receiveResult.count > 0 {
                    self.chatInputView.recordPhase = .converted
                    self.chatInputView.recognizedText = self.receiveResult
                } else if self.chatInputView.audioRecordIndicator.moreButton.isHidden == false && isFinal {
                    //判断是否是二次识别，需要更改状态为识别错误
                    self.chatInputView.recordPhase = .converterror
                }
                return
            }
            
            self.receiveResult = receiveValue
            // 在识别错误的前提下，识别到了文字，将状态改回识别成功状态
            if self.receiveResult.count > 0 && self.chatInputView.audioRecordIndicator.convertErrorView.isHidden == false {
                self.chatInputView.recordPhase = .converted
            }
            //识别结果赋值给TextView
            self.chatInputView.recognizedText = self.receiveResult
        }
        
        SpeechVoiceDetectManager.shared.onRequestAuthorizationStateChanged = { [weak self] (state,errorMsg) in
            guard let self = self else { return }
            if state != .authorized {
                //声音授权出现问题
                self.chatInputView.audioRecordIndicator.authErrorMsg = errorMsg
            }
        }
        
        var dotCount = 1 // 初始点数为 3
        SpeechVoiceDetectManager.shared.onDurationChanged = { [weak self] (duration) in
            guard let self = self else { return }
            if dotCount == 1 {
                dotCount = 2
            } else if dotCount == 2 {
                dotCount = 3
            } else if dotCount == 3 {
                dotCount = 1
            }
            let dots = String(repeating: "·", count: dotCount)
            
            self.chatInputView.audioRecordIndicator.countDownNumber = duration
            self.chatInputView.audioRecordIndicator.recognizedTextView.text = "\(self.chatInputView.recognizedText)\(dots)"
        }
        
        SpeechVoiceDetectManager.shared.onRecordEnd = { [weak self] in
            guard let self = self else { return }
            self.onRecordEnd()
        }
    }
    
    func onStopRecording() {
        NIMSDK.shared().mediaManager.stopRecord()
        SpeechVoiceDetectManager.shared.stopRecording()
        self.chatInputView.audioRecordIndicator.countDownNumber = 60
        self.recognizedText = ""
    }
    
    func onRecordEnd() {
        let isConvert = (self.chatInputView.recordPhase == .converting || self.chatInputView.recordPhase == .converted)
        if isConvert && self.chatInputView.recognizedText.isEmpty {
            //没有识别到任何文字
            self.chatInputView.recordPhase = .converterror
        } else {
            self.chatInputView.recordPhase = isConvert == true ? .converted : .end
        }
    }
    
    func onCancelRecording() {
        NIMSDK.shared().mediaManager.cancelRecord()
        SpeechVoiceDetectManager.shared.stopRecording()
        self.chatInputView.audioRecordIndicator.countDownNumber = 60
        self.chatInputView.audioRecordIndicator.recognizedTextView.text = ""
        self.recognizedText = ""
    }
    
    func onConverting() {
        SpeechVoiceDetectManager.shared.stopRecording()
        NIMSDK.shared().mediaManager.stopRecord()
    }
    
    func onConvertError() {
        SpeechVoiceDetectManager.shared.stopRecording()
        self.chatInputView.audioRecordIndicator.countDownNumber = 60
        NIMSDK.shared().mediaManager.stopRecord()
    }
    
    //取消发送
    func cancelButtonTapped() {
        self.view.resignFirstResponder()
        NIMSDK.shared().mediaManager.cancelRecord()
        SpeechVoiceDetectManager.shared.stopRecording()
        self.recognizedText = ""
        chatInputView.recording = false
    }
    
    //发送原语音
    func sendVoiceButtonTapped() {
        self.view.resignFirstResponder()
        if let message = self.viewmodel.saveAudioMessage{
            let volumeLevels = getVolumeLevels()
            message.serverExtension = ["voice":volumeLevels].toJSON
            NIMSDK.shared().v2MessageService.send(message, conversationId: self.viewmodel.conversationId, params: nil) { _ in
                
            } failure: { _ in
                
            }
            chatInputView.recording = false
        }
        NIMSDK.shared().mediaManager.cancelRecord()
        SpeechVoiceDetectManager.shared.stopRecording()
    }
    
    //发送语音文字
    func sendVoiceMsgTextButtonTapped() {
        self.view.resignFirstResponder()
        
        NIMSDK.shared().mediaManager.cancelRecord()
        SpeechVoiceDetectManager.shared.stopRecording()
        let recognizedText = self.chatInputView.audioRecordIndicator.recognizedTextView.text ?? ""
        if recognizedText != "" {
            self.viewmodel.sendTextMessage(text: recognizedText, conversationId: self.viewmodel.conversationId) { _, _ in
                
            }
        }
        self.recognizedText = ""
        chatInputView.recording = false
    }
    
    //弹出更多语言页面
    func moreLanguageButtonTapped() {
        let vc = TGIMAudioLanguageController()
        vc.onLanguageCodeDidSelect =  { [weak self] (langCode) in
            guard let self = self else { return }
            self.chatInputView.recordPhase = .converted
            self.receiveResult = ""
            SpeechVoiceDetectManager.shared.convertToTextWithAudioFile(filePath: self.viewmodel.saveAudioFilePath ?? "", langCode: langCode)
        }
        vc.modalTransitionStyle = .coverVertical
        vc.isModalInPresentation = true
        self.present(vc, animated: true, completion: nil)
    }
}

//    MARK: UIImagePickerControllerDelegate
extension TGChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    // 处理选择的照片
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        sendMediaMessage(didFinishPickingMediaWithInfo: info)
        picker.dismiss(animated: true, completion: nil)
    }
    // 取消选择时调用
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}

// MARK: PHPickerViewControllerDelegate
extension TGChatViewController: PHPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: .none)
        
        var photos: [UIImage] = []
        var imageAsset: [PHAsset] = []
        var isGifImage = false
        
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            // Check if the item is a GIF
            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.gif.identifier) {
                isGifImage = true
            } else {
                isGifImage = false
            }
            
            // Handle UIImage extraction
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage {
                    photos.append(image)
                }
                dispatchGroup.leave()
            }
            
            // Handle PHAsset extraction
            if let assetIdentifier = result.assetIdentifier {
                let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject
                if let phAsset = asset {
                    imageAsset.append(phAsset)
                }
            }
        }
        
        // After all images are loaded
        dispatchGroup.notify(queue: .main) {
            
        }
        
    }
    
    
}

//MARK: IMToolChooseDelegate
extension TGChatViewController: IMToolChooseDelegate {
    func didSelectedItem(model: IMActionItem) {
        switch model {
        case .stickerCollection:
            showStickerCollection()
        case .cancelUpload:
        
            break
        case .reply:
            self.showReplyMessageView()
        case .copy:
            copyTextIM()
        case .copyImage:
            break
        case .forward:
            isForwarding = true
            self.showSelectActionToolbar(true, isDelete: false)
        case .edit:
            revokeTextIM()
        case .delete:
            isForwarding = false
            self.showSelectActionToolbar(true, isDelete: true)
        case .translate:
            translateTextIM()
        case .voiceToText:
            vioceTotext()
        case .collection:
            collectMessage()
        case .save:
            break
        case .forwardAll, .deleteAll:
            break
        case .pinned:
            pinnedMessage()
        case .unPinned:
            if let message = viewmodel.operationModel?.nimMessageModel, let model = viewmodel.pinnedList.filter({ pinnedModel in
                pinnedModel.im_msg_id == message.messageClientId
            }).first {
                unPinnedMessage(model: model)
            }
        default:
            break
        }
    }
}

//MARK: IMPinnedViewDelegate
extension TGChatViewController: IMPinnedViewDelegate {
    func deletePinItem(pinItem: PinnedMessageModel) {
        unPinnedMessage(model: pinItem)
    }
}

//MARK: IMPinnedPopViewDeleagte
extension TGChatViewController: IMPinnedPopViewDeleagte {
    func didClickImageVideo(model: FavoriteMsgModel) {
        pinnedAlert?.dismiss()
        pinnedAlert = nil
        let vc = CollectionImageVideoMsgViewController(model: model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didClickLocaltion(title: String, lat: Double, lng: Double, popView: IMPinnedPopView) {
        pinnedAlert?.dismiss()
        pinnedAlert = nil
        let object: ChatLocaitonModel = ChatLocaitonModel()
        object.title = title
        object.lat = lat
        object.lng = lng
        let vc = TGMessageMapViewController()
        vc.model = object
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    func didClickFile(attachment: IMFileCollectionAttachment) {
        pinnedAlert?.dismiss()
        pinnedAlert = nil
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        let name = attachment.name
        let path = "\(documentsPath)/collectionFile/\(name)"
        if FileManager.default.fileExists(atPath: path) {
            let url = URL(fileURLWithPath: path)
            self.interactionController = UIDocumentInteractionController(url: url)
            self.interactionController.delegate = self
            self.interactionController.name = name
            self.interactionController.presentPreview(animated: true)
        } else {
            let vc: CollectionFileMsgViewController = CollectionFileMsgViewController(model: attachment)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func didClickAudio(model: FavoriteMsgModel) {
        pinnedAlert?.dismiss()
        pinnedAlert = nil
        let vc = CollectionAudioMsgViewController(model: model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didClickContactCard(memberId: String, popView: IMPinnedPopView) {
        pinnedAlert?.dismiss()
        pinnedAlert = nil
        RLSDKManager.shared.imDelegate?.didPressNameCard(memberId: memberId)
    }
    
    func didClickEgg(attachment: IMEggAttachment, nickName: String, avatarInfo: AvatarInfo) {
        pinnedAlert?.dismiss()
        pinnedAlert = nil
    }
    
    func didClickMeeting(meetingNum: String, meetingPw: String) {
        pinnedAlert?.dismiss()
        pinnedAlert = nil
    }
    
    func didUpdateProfileData(_ data: String, avatar: AvatarInfo) {
        self.pinnedView?.avatarImageView.avatarInfo = avatar
        self.pinnedView?.avatarImageView.avatarPlaceholderType = .unknown
        self.pinnedView?.content.text = data
        self.pinnedView?.layoutIfNeeded()
    }
}

extension TGChatViewController: TimerHolderDelegate {
    func onTimerFired(holder: TimerHolder) {
        if holder == timer {
            if self.meetingViewmodel.duration > 0 {
                self.meetingViewmodel.duration = self.meetingViewmodel.duration - 1
                let nimute = self.meetingViewmodel.duration / 60
                let s = self.meetingViewmodel.duration % 60
                let nim = String(format: "%02d", nimute)
                let ss = String(format: "%02d", s)
                let timeStr = "\(nim):\(ss)"
                timeLabel?.text = String(format: "meeting_end_in_ios".localized, timeStr)
                if self.meetingViewmodel.duration <= 5 * 60 {
                    self.timeView?.isHidden = false
                }
            }else {
                self.timer?.stopTimer()

                let window = UIApplication.shared.keyWindow
                
                let bgView = MeetingEndView()
                bgView.backgroundColor = .black.withAlphaComponent(0.2)
                window?.addSubview(bgView)
                bgView.bindToEdges()
                bgView.okAction = { [weak self] in
                    bgView.isHidden = true
                    bgView.removeFromSuperview()
                    self?.timeView?.isHidden = true
                    self?.timeView?.removeFromSuperview()
                    self?.meetingViewmodel.leaveMeetingRoom()
                    
                }
            }
        }
//        else if holder == titleTimer {
//            isTypingLabel.isHidden = true
//        }
    }
}

extension TGChatViewController: TGJoinMeetingViewModelDelegate {
    func leaveMeetingRoom() {
        self.timer?.stopTimer()
        self.timeView?.removeFromSuperview()
    }
    
    
}
