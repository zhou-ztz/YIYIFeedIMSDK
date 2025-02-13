//
//  TGFeedInfoDetailViewController.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/28.
//

import UIKit
import CoreMedia
import IQKeyboardManagerSwift
import AVFoundation

enum TGSendCommentType {
    /// 删除状态
    case delete
    /// 发送状态
    case send
    /// 回复状态
    case replySend
    /// 重新发送状态
    case reSend
    /// 获取评论列表
    case getList
    /// 置顶评论
    case top
}

public class TGFeedInfoDetailViewController: TGViewController {
    
    lazy var tableView: UITableView = {
        let tb = UITableView(frame: CGRect.zero, style: .plain)
        tb.register(FeedDetailCommentTableViewCell.self, forCellReuseIdentifier: FeedDetailCommentTableViewCell.cellIdentifier)
        tb.showsVerticalScrollIndicator = false
        tb.backgroundColor = .white
        tb.tableFooterView = UIView()
        tb.separatorStyle = .none
        tb.delegate = self
        tb.dataSource = self
        return tb
    }()
    
    private var headerView: FeedDetailTableHeaderView = FeedDetailTableHeaderView()
    private let navView: TGMomentDetailNavTitle = TGMomentDetailNavTitle()
    
    //    var currentPrimaryButtonState: SocialButtonState = .follow
    var onToolbarUpdated: onToolbarUpdate?
    var reactionHandler: TGReactionHandler?
    var reactionSelected: ReactionTypes?
    private let primaryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("display_follow".localized, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = TGAppTheme.Font.regular(12)
        button.backgroundColor = TGAppTheme.primaryRedColor
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.roundCorner(10)
        return button
    }()
    var addPostButton = UIButton(type: .custom).configure {
        $0.setImage(UIImage(named: "iconsAddmomentBlack"), for: .normal)
    }
    var miniVideoButton = UIButton(type: .custom).configure {
        $0.setImage(UIImage(named: "ico_video_disabled"), for: .normal)
    }
    var moreButton = UIButton(type: .custom).configure {
        $0.setImage(UIImage(named: "icMoreBlack"), for: .normal)
    }
    
    var dontTriggerObservers:Bool = false
    var feedModel: FeedListCellModel?
    var model: TGFeedResponse? {
        didSet {
            self.setHeader()
            self.setBottomViewData()
            self.getCommentList()
            //            self.navView.updateSponsorStatus(model?.isSponsored ?? false)
        }
    }
    public var transitionId = UUID().uuidString
    public var afterTime: String = ""
    
    private var commentModel: TGFeedCommentListModel?
    private var commentDatas: [TGFeedCommentListModel] = [TGFeedCommentListModel]()
    
    private var sendText: String?
    private var isTapMore = false
    private var isClickCommentButton = false
    
    private let commentInputView = UIView()
    private var feedId: Int = 0
    private var feedOwnerId: Int = 0
    private var afterId: Int?
    private var isFullScreen: Bool = false
    private var sendCommentType: TGSendCommentType = .send
    //    private var headerView: FeedCommentDetailTableHeaderView = FeedCommentDetailTableHeaderView()
    private var bottomToolBarView: TGFeedCommentDetailBottomView = TGFeedCommentDetailBottomView(frame: .zero, colorStyle: .normal)
    //
  
    
    var isHomePage: Bool = false
    // feed type
    var type: TGFeedListType?
    
    public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return true
    }
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    
    var startPlayTime: CMTime = .zero
    var onDismiss: ((CMTime) -> Void)?
    var tagVoucher: TagVoucher?
    
    public init(feedId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.feedId = feedId
        //        self.onToolbarUpdated = onToolbarUpdated
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.type = .hot
        
        TGKeyboardToolbar.share.theme = .white
        TGKeyboardToolbar.share.setStickerNightMode(isNight: false)
        TGKeyboardToolbar.share.keyboardToolbarDelegate = self
        setRightBarButton()
        setupTableView()
        setBottomView()
        loadFeedDetailData()
    }
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        TGKeyboardToolbar.share.keyboarddisappear()
        TGKeyboardToolbar.share.keyboardStopNotice()
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        TGKeyboardToolbar.share.keyboardstartNotice()
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    private func setupTableView() {
        self.customNavigationBar.title = "动态详情"
        backBaseView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(-(TSBottomSafeAreaHeight + 30))
        }
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60;
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 75))
        tableView.mj_header = SCRefreshHeader(refreshingTarget: self, refreshingAction: #selector(loadFeedDetailData))
        //        tableView.mj_footer = SCRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        tableView.tableHeaderView = headerView
     
    }
    
    private func setHeader() {
        guard let model = model else { return }
        
        let likeItem = self.bottomToolBarView.toolbar.getItemAt(0)
        reactionHandler = TGReactionHandler(reactionView: likeItem, toAppearIn: self.view, currentReaction: model.reactionType, feedId: model.id ?? 0, feedItem: FeedListCellModel(from: model), reactions: [.heart,.awesome,.wow,.cry,.angry])
        
        likeItem.addGestureRecognizer(reactionHandler!.longPressGesture)
        reactionHandler?.onSelect = { [weak self] reaction in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.animate(for: reaction)
                self.reactionSelected = reaction
            }
        }
        reactionHandler?.onSuccess = { [weak self] message in
            guard let self = self, let feedId = model.id else { return }
            self.loadFeedDetailInfo()
        }
    }
    private func setBottomViewData() {
        guard let model = model else { return }
        bottomToolBarView.isHidden = false
        bottomToolBarView.loadToolbar(model: model, canAcceptReward: model.user?.extra?.canAcceptReward == 1 ? true : false, reactionType: model.reactionType)
    }
    private func setBottomView() {
        view.addSubview(bottomToolBarView)
        //        bottomToolBarView.isHidden = true
        bottomToolBarView.onCommentAction = { [weak self] in
            guard let self = self else { return }
            TGKeyboardToolbar.share.keyboardBecomeFirstResponder()
            if let tagVoucher = self.tagVoucher {
                TGKeyboardToolbar.share.setTagVoucher(tagVoucher)
            }
        }
        bottomToolBarView.onToolbarItemTapped = { [weak self] toolbarIndex in
            guard let self = self else {
                return
            }
            switch toolbarIndex {
            case 0:
                self.reactionHandler?.onTapReactionView()
            case 1:
                TGKeyboardToolbar.share.keyboardBecomeFirstResponder()
            case 2:
                self.navigationController?.presentPopVC(target: "", type: .share, delegate: self)
            default: break
            }
        }
        bottomToolBarView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.bottom.equalTo(-(TSBottomSafeAreaHeight + 30))
            make.height.equalTo(70)
        }
    }
    // MARK: - 设置导航栏部分
    //    private func setupNavHeaderView() {
    //
    //        let titleView = UIBarButtonItem(customView: navView)
    //        self.navigationItem.leftBarButtonItems = [titleView]
    //
    //        primaryButton.addTap { [weak self] (_) in
    ////            guard let self = self else { return }
    ////            self.followUserClicked()
    //        }
    //        primaryButton.snp.makeConstraints {
    //            $0.width.equalTo(70)
    //            $0.height.equalTo(25)
    //        }
    //        let followView = UIBarButtonItem(customView: primaryButton)
    //        moreButton.addAction {
    ////            guard let id = CurrentUserSessionInfo?.userIdentity else {
    ////                return
    ////            }
    ////            guard let model = self.model else { return }
    ////
    ////            self.navigationController?.presentPopVC(target: model, type: model.userId == id ? .moreMe : .moreUser , delegate: self)
    //        }
    //        let moreView = UIBarButtonItem(customView: moreButton)
    //        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    //        space.width = 12
    //        //等数据加载成功再显示按钮
    //        primaryButton.isHidden = true
    //        moreButton.isHidden = true
    //        self.navigationItem.rightBarButtonItems = [moreView, space ,followView]
    //    }
    func setRightBarButton() {
        self.addPostButton.addTarget(self, action: #selector(addPostButtonClick), for: .touchUpInside)
        self.miniVideoButton.addTarget(self, action: #selector(miniVideoButtonClick), for: .touchUpInside)
        self.moreButton.addTarget(self, action: #selector(moreButtonClick), for: .touchUpInside)
        customNavigationBar.setRightViews(views: [addPostButton, miniVideoButton, moreButton])
    }
    @objc func addPostButtonClick() {
        var data = [TGToolModel]()
        let titles = ["photo".localized, "mini_video".localized]
        let images = ["ic_rl_feed_photo", "ic_rl_feed_video"]
        let types = [TGToolType.photo, TGToolType.miniVideo]
        for i in 0 ..< titles.count {
            let model = TGToolModel(title: titles[i], image: images[i], type: types[i])
            data.append(model)
        }
        let preference = TGToolChoosePreferences()
        preference.drawing.bubble.color = .white
        preference.drawing.message.color = .lightGray
        preference.drawing.button.color = .lightGray
        preference.drawing.background.color = .clear
        self.addPostButton.showToolChoose(identifier: "", data: data, arrowPosition: .none, preferences: preference, delegate: self, isMessage: true)
    }
    @objc func miniVideoButtonClick() {
        let vc = TGMiniVideoPageViewController(type: .hot, videos: [], focus: 0, onToolbarUpdate: self.onToolbarUpdated, avPlayer: nil, tagVoucher: nil)
        
//        vc.onPassPlayer = { [weak self] player, time in
//            DispatchQueue.main.async {
//                guard let player = player, let time = time else { return }
//                self?.currentCell?.feedContentView.videoPlayer.setPlayer(player, at: time)
//                self?.isViewVideo = false
//            }
//        }
//        if isGlobalSearch {
//            _parentVC?.present(TSNavigationController(rootViewController: vc).fullScreenRepresentation, animated: true, completion: nil)
//        } else {
//            vc.isControllerPush = true
            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    @objc func moreButtonClick(){
        
    }
    @objc private func loadFeedDetailData() {
        loadFeedDetailInfo()
        loadFeedContentList()
    }
    
    private func loadFeedDetailInfo() {
        TGFeedNetworkManager.shared.fetchFeedDetailInfo(withFeedId: "\(feedId)") { feedInfo, error in
            guard let feedInfo = feedInfo else { return }
            self.tableView.mj_header.endRefreshing()
            self.tableView.reloadData()
            self.headerView.setData(data: feedInfo)
            if let tagVoucher = feedInfo.tagVoucher {
                self.tagVoucher = tagVoucher
            }
            self.model = feedInfo
            self.headerView.setCommentLabel(count: self.model?.feedCommentCount, isCommentDisabled: false)
            self.headerView.onTapPictureClickCall = { [weak self] in
                guard let self = self else { return }
//                guard let userID = TSCurrentUserInfo.share.userInfo?.userIdentity else { return }
                guard let model = self.model else { return }
                let cellModel = FeedListCellModel(from: model)
                let dest = TGFeedDetailImagePageController(config: .list(data: [cellModel], tappedIndex: 0, mediaType: .image, listType: self.type ?? .user(userId: cellModel.userId), transitionId: transitionId, placeholderImage: UIImage(), isClickComment: false, isTranslateText: false), completeHandler: nil, onToolbarUpdated: onToolbarUpdated, translateHandler: nil, tagVoucher: nil)
                dest.isControllerPush = true
                dest.afterTime = self.afterTime
                
                self.navigationController?.pushViewController(dest, animated: true)
            }
            self.headerView.setNeedsLayout()
            self.headerView.layoutIfNeeded()
            self.tableView.tableHeaderView = self.headerView
        }
    }
    private func loadFeedContentList() {
        TGFeedNetworkManager.shared.fetchFeedCommentsList(withFeedId: "\(feedId)", afterId: nil, limit: 20) { contentListResponse, error in
            guard let feedIcontentListResponsenfo = contentListResponse else { return }
            self.commentDatas = feedIcontentListResponsenfo.comments ?? []
            self.tableView.reloadData()
            
        }
    }
    
    private func animate(for reaction: ReactionTypes?) {
        let toolbaritem = self.bottomToolBarView.toolbar.getItemAt(0)
        
        if let reaction = reaction {
            UIView.transition(with: toolbaritem.imageView, duration: 0.3) {
                toolbaritem.imageView.image = reaction.image
                toolbaritem.titleLabel.text = reaction.title
                toolbaritem.titleLabel.textColor = RLColor.share.theme
            }
        } else {
            UIView.transition(with: toolbaritem.imageView, duration: 0.3) {
                toolbaritem.imageView.image = UIImage(named: "IMG_home_ico_love")
                toolbaritem.titleLabel.text = "love_reaction".localized
                toolbaritem.titleLabel.textColor = .black
            }
        }
    }
    
    private func getCommentList() {
        
    }
    
    private func postComment(message: String, contentType: CommentContentType) {
        guard let currentUserId = RLCurrentUserInfo.shared.uid, let feedId = model?.id else { return }
        let commentType = TGCommentType(type: .feed)
        
        //        self.showLoading()
        //上报动态评论事件
        //        EventTrackingManager.instance.trackEvent(
        //            itemId: feedId.stringValue,
        //            itemType: model?.feedType == .miniVideo ? ItemType.shortvideo.rawValue   : ItemType.image.rawValue,
        //            behaviorType: BehaviorType.comment,
        //            moduleId: ModuleId.feed.rawValue,
        //            pageId: PageId.feed.rawValue)
        
        
        TGFeedNetworkManager.shared.submitComment(for: commentType, content: message, sourceId: feedId, replyUserId: self.commentModel?.user?.id, contentType: contentType) { [weak self] (commentModel, message, result) in
            
            defer {
                DispatchQueue.main.async {
                    //                    self?.dismissLoading()
                }
            }
            
            guard result == true, let data = commentModel, let wself = self else {
                UIViewController.showBottomFloatingToast(with: message ?? "please_retry_option".localized, desc: "", displayDuration: 4.0)
                return
            }
            //            var simpleModel = data.simpleModel()
            //            simpleModel.userInfo = CurrentUserSessionInfo?.toType(type: UserInfoModel.self)
            //            switch wself.sendCommentType {
            //            case .send:
            //                simpleModel.replyUserInfo = nil
            //            case .replySend:
            //                simpleModel.replyUserInfo = wself.commentModel?.userInfo?.toType(type: UserInfoModel.self)
            //            default:
            //                simpleModel.replyUserInfo = wself.commentModel?.replyUserInfo?.toType(type: UserInfoModel.self)
            //            }
            
            if let lastPinnedIndex = wself.commentDatas.lastIndex(where: { $0.pinned == true }) {
                wself.commentDatas.insert(data, at: lastPinnedIndex + 1)
            } else {
                wself.commentDatas.insert(data, at: 0)
            }
            if var count = wself.model?.feedCommentCount {
                count += 1
                //                wself.model?.feedCommentCount = count
            }
            DispatchQueue.main.async {
                //                wself.tableView.removePlaceholderViews()
                wself.headerView.setCommentLabel(count: wself.model?.feedCommentCount, isCommentDisabled: false)
                wself.bottomToolBarView.toolbar.setTitle((wself.model?.feedCommentCount).orZero.abbreviated, At: 1)
                wself.headerView.layoutIfNeeded()
                wself.tableView.reloadData()
                guard let model = wself.model else { return }
                //                wself.onToolbarUpdated?(model)
            }
        }
    }
    
    private func setTSKeyboard(placeholderText: String, cell: FeedDetailCommentTableViewCell?) {
        TGKeyboardToolbar.share.keyboardBecomeFirstResponder()
        TGKeyboardToolbar.share.keyboardSetPlaceholderText(placeholderText: placeholderText)
    }
}


// Table View Delegate
extension TGFeedInfoDetailViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedDetailCommentTableViewCell.cellIdentifier, for: indexPath) as! FeedDetailCommentTableViewCell
        cell.selectionStyle = .none
        let feedCommentModel = self.commentDatas[indexPath.row]
        cell.setData(data: feedCommentModel)
        cell.setAsPinned(pinned: self.commentDatas[indexPath.row].pinned, isDarkMode: false)
        //
        //        cell.likeButtonClickCall = {[weak self] in
        //            guard let self = self else {return}
        //            //是否点赞
        //            let isLiking = feedCommentModel.relevanceId > 0
        //            if isLiking {
        //                self.handleLikeAction(feedModel: feedCommentModel, indexPath: indexPath, likeValue: 1, countChange: -1)
        //            } else {
        //                self.handleLikeAction(feedModel: feedCommentModel, indexPath: indexPath, likeValue: 0, countChange: 1)
        //            }
        //        }
        //
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentDatas.count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? FeedDetailCommentTableViewCell
        
        let comment = self.commentDatas[indexPath.row]
        
        guard let userInfo = comment.user else {
            //            needShowError()
            return
        }
        guard !userInfo.isMe() else { return }
        
        TGKeyboardToolbar.share.keyboarddisappear()
        
        self.sendCommentType = .replySend
        self.commentModel = comment
        if let isCommentDisabled = model?.disableComment, isCommentDisabled == 0 {
            setTSKeyboard(placeholderText: "reply_with_string".localized + "\((userInfo.name ?? "")!)", cell: cell)
        }
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension TGFeedInfoDetailViewController: TGKeyboardToolbarDelegate {
    func keyboardToolbarSendTextMessage(message: String, bundleId: String?, inputBox: AnyObject?, contentType: CommentContentType) {
        //        if TSCurrentUserInfo.share.isLogin == false {
        //            TSRootViewController.share.guestJoinLandingVC()
        //            return
        //        }
        
        if message == "" {
            return
        }
        sendText = message
        self.postComment(message: message, contentType: contentType)
    }
    
    func keyboardToolbarFrame(frame: CGRect, type: keyboardRectChangeType) {
        
    }
    
    func keyboardWillHide() {
        if sendText != nil {
            sendText = nil
            if self.commentDatas.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
            return
        } else {
            if TGKeyboardToolbar.share.isEmojiSelected() == false {
                TGKeyboardToolbar.share.removeToolBar()
            }
        }
        
        if self.tableView.contentOffset.y > self.tableView.contentSize.height - self.tableView.bounds.height {
            if self.tableView.contentSize.height < self.tableView.bounds.size.height {
                self.tableView.setContentOffset(CGPoint.zero, animated: true)
                return
            }
            self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.bounds.height), animated: true)
        }
    }
}
extension TGFeedInfoDetailViewController: CustomPopListProtocol {
    func customPopList(itemType: TGPopUpItem) {
        self.handlePopUpItemAction(itemType: itemType)
    }
    
    func handlePopUpItemAction(itemType: TGPopUpItem) {
        switch itemType {
        case .message:
            // 记录转发数
            //self.forwardFeed()
            
            if let model = self.feedModel {
                let messageModel = TGmessagePopModel(momentModel: model)
                let vc = TGContactsPickerViewController(model: messageModel, configuration: TGContactsPickerConfig.shareToChatConfig(), finishClosure: nil)
                if #available(iOS 11, *) {
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let navigation = TGNavigationController(rootViewController: vc).fullScreenRepresentation
                    self.navigationController?.present(navigation, animated: true, completion: nil)
                }
            }
            break
        case .shareExternal:
            // 记录转发数
            //            self.forwardFeed()
            
            if let model = self.feedModel {
                let messagePopModel = TGmessagePopModel(momentModel: model)
                //"https://preprod-web-rewardslink.getyippi.cn/feeds/839248"
                let fullUrlString = "" //"\(TSUtil.getWebServerAddress())feeds/\(String(messagePopModel.feedId))"
                // By Kit Foong (Hide Yippi App from share)
                let items: [Any] = [URL(string: fullUrlString), messagePopModel.titleSecond, ShareExtensionBlockerItem()]
                let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view
                self.present(activityVC, animated: true, completion: nil)
            }
            break
        case .save(isSaved: let isSaved):
//            if let data = self.model {
//                let isCollect = (data.toolModel?.isCollect).orFalse ? false : true
//                TSMomentNetworkManager().colloction(isCollect ? 1 : 0, feedIdentity: data.idindex, feedItem: data) { [weak self] (result) in
//                    if result == true {
//                        self?.model?.toolModel?.isCollect = isCollect
//                        DispatchQueue.main.async {
//                            if isCollect {
//                                self?.showTopFloatingToast(with: "success_save".localized, desc: "")
//                            }
//                        }
//                    }
//                }
//            }
            break
        case .reportPost:
            //            if let model = self.model {
            //                guard let reportTarget: ReportTargetModel = ReportTargetModel(feedModel: model) else { return }
            //                let reportVC: ReportViewController = ReportViewController(reportTarget: reportTarget)
            //                self.present(TSNavigationController(rootViewController: reportVC).fullScreenRepresentation,
            //                             animated: true,
            //                             completion: nil)
            //            }
            break
        case .edit:
            //            guard let model = self.model, let avatarInfo = self.model?.avatarInfo else {
            //                return
            //            }
            //           let pictures =  model.pictures.map{ RejectDetailModelImages(fileId: $0.file, imagePath: $0.url ?? "", isSensitive: false, sensitiveType: "")   }
            //            var vc = TSReleasePulseViewController(isHiddenshowImageCollectionView: false)
            //
            //            vc.selectedModelImages = pictures
            //
            //            vc.preText = model.content
            //
            //            vc.feedId = model.idindex.stringValue
            //            vc.isFromEditFeed = true
            //
            //            vc.tagVoucher = tagVoucher
            //
            //            if let extenVC = self.configureReleasePulseViewController(detailModel: model, viewController: vc) as? TSReleasePulseViewController{
            //                vc = extenVC
            //            }
            //
            //            let navigation = TSNavigationController(rootViewController: vc).fullScreenRepresentation
            //            self.present(navigation, animated: true, completion: nil)
            break
        case .deletePost:
            //            guard let model = model else { return }
            //            self.showRLDelete(title: "rw_delete_action_title".localized, message: "rw_delete_action_desc".localized, dismissedButtonTitle: "delete".localized, onDismissed: { [weak self] in
            //                guard let self = self else { return }
            //                TSMomentNetworkManager().deleteMoment(self.model?.idindex ?? 0) { [weak self] (result) in
            //                    guard let self = self else { return }
            //                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "feedDelete"), object: nil, userInfo: ["feedId": feedId])
            //                    self.navigationController?.popViewController(animated: true)
            //                }
            //            }, cancelButtonTitle: "cancel".localized)
            break
        case .pinTop(isPinned: let isPinned):
            //            guard let feedId = self.model?.idindex else { return }
            //
            //            let networkManager: (Int, @escaping (String, Int, Bool?) -> Void) -> Void = isPinned ? FeedListNetworkManager.unpinFeed: FeedListNetworkManager.pinFeed
            //
            //            networkManager(feedId) { [weak self] (errMessage, statusCode, status) in
            //
            //                guard let self = self else { return }
            //                guard status == true else {
            //                    if statusCode == 241 {
            //                        self.showDialog(image: nil, title: isPinned ? "fail_to_pin_title".localized : "fail_to_unpin_title".localized, message: isPinned ? "fail_to_pin_desc".localized : "fail_to_unpin_desc".localized, dismissedButtonTitle: "ok".localized, onDismissed: nil, onCancelled: nil)
            //                    } else {
            //                        self.showError(message: errMessage)
            //                    }
            //                    return
            //                }
            //                let newPined = !isPinned
            //
            //                self.model?.isPinned = newPined
            //                self.showError(message: newPined ? "feed_pinned".localized : "feed_unpinned".localized)
            //                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPinnedFeed"), object: nil, userInfo: ["isPinned": !isPinned, "feedId": feedId])
            //            }
            break
        case .comment(isCommentDisabled: let isCommentDisabled):
            //            guard let feedId = self.model?.idindex else { return }
            //
            //            let newValue = self.model?.toolModel?.isCommentDisabled ?? true ? 0 : 1
            //            TSMomentNetworkManager().commentPrivacy(newValue, feedIdentity: feedId) { [weak self] success in
            //                guard let self = self else { return }
            //                if success {
            //                    self.model?.toolModel?.isCommentDisabled = newValue == 1
            //                    DispatchQueue.main.async {
            //                        if newValue == 1 {
            //                            self.showTopIndicator(status: .success, "disable_comment_success".localized)
            //                        } else {
            //                            self.showTopIndicator(status: .success, "enable_comment_success".localized)
            //                        }
            //                        self.setBottomViewData()
            //                    }
            //                }
            //            }
            break
        case .deleteComment(model: let model):
            //            guard let feedModel = model.model as? FeedCommentListCellModel else { return }
            //            self.showRLDelete(title: "delete_comment".localized, message: "rw_delete_comment_action_desc".localized, dismissedButtonTitle: "delete".localized, onDismissed: { [weak self] in
            //                guard let self = self else { return }
            //                self.deleteComment(with: feedModel)
            //            }, cancelButtonTitle: "cancel".localized)
            break
        case .reportComment(model: let model):
            //            guard let feedModel = model.model as? FeedCommentListCellModel else { return }
            //            let reportTarget = ReportTargetModel(feedCommentModel: feedModel)
            //            let reportVC = ReportViewController(reportTarget: reportTarget)
            //            self.present(TSNavigationController(rootViewController: reportVC).fullScreenRepresentation, animated: true, completion: nil)
            break
        case .livePinComment(model: let model):
            //            guard let cell = model.target as? TSDetailCommentTableViewCell, let model = model.model as? FeedCommentListCellModel else { return }
            //            DispatchQueue.main.async {
            //                self.pinComment(in: cell, comment: model)
            //            }
            break
        case .liveUnPinComment(model: let model):
            //            guard let cell = model.target as? TSDetailCommentTableViewCell, let model = model.model as? FeedCommentListCellModel else { return }
            //            DispatchQueue.main.async {
            //                self.unpinComment(in: cell, comment: model)
            //            }
            break
        case .copy(model: let model):
            //            guard let model = model.model as? FeedCommentListCellModel else { return }
            //            UIPasteboard.general.string = model.content
            //            UIViewController.showBottomFloatingToast(with: "rw_copy_to_clipboard".localized, desc: "")
            break
        default:
            break
        }
    }
}
extension TGFeedInfoDetailViewController: TGToolChooseDelegate {
    func didSelectedItem(type: TGToolType, title: String) {
        switch type {
        case .photo:
            self.presentPostPhoto()
        case .miniVideo, .video:
            self.presentPostMiniVideo()
        default:
            break
        }
    }
    
    
    func presentPostPhoto() {
//        guard TSCurrentUserInfo.share.isLogin == true else { return }
        self.showCameraVC(true, onSelectPhoto: { [weak self] (assets, _, _, _, _) in
            let releasePulseVC = TGReleasePulseViewController(type: .photo)
            releasePulseVC.selectedPHAssets = assets
            let navigation = TGNavigationController(rootViewController: releasePulseVC).fullScreenRepresentation
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + (self?.launchScreenDismissWithDelay() ?? 0.0)) {
                self?.present(navigation, animated: true, completion: nil)
            }
        })
    }
    func presentPostMiniVideo() {
//        guard TSCurrentUserInfo.share.isLogin == true else { return }
        self.showMiniVideoRecorder { [weak self] (url) in
            let asset = AVURLAsset(url: url)
            let coverImage = FileUtils.generateAVAssetVideoCoverImage(avAsset: asset)
            let releasePulseVC = TGReleasePulseViewController(type: .miniVideo)
            releasePulseVC.shortVideoAsset = ShortVideoAsset(coverImage: coverImage, asset: nil, videoFileURL: url)
            let navigation = TGNavigationController(rootViewController: releasePulseVC).fullScreenRepresentation
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + (self?.launchScreenDismissWithDelay() ?? 0.0)) {
                self?.present(navigation, animated: true, completion: nil)
            }
        }
        
    }
    
}
