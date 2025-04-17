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
import NIMSDK
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
    
    private let taskManager = TGPostTaskManager.shared
    
    lazy var tableView: RLTableView = {
        let tb = RLTableView(frame: CGRect.zero, style: .plain)
        tb.register(FeedDetailCommentTableViewCell.self, forCellReuseIdentifier: FeedDetailCommentTableViewCell.cellIdentifier)
        tb.showsVerticalScrollIndicator = false
        tb.backgroundColor = .white
        tb.tableFooterView = UIView()
        tb.separatorStyle = .none
        tb.delegate = self
        tb.dataSource = self
        return tb
    }()
    
    private let navView: TGMomentDetailNavTitle = TGMomentDetailNavTitle()
    
    var currentPrimaryButtonState: SocialButtonState = .follow
    
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
    var moreButton = UIButton(type: .custom).configure {
        $0.setImage(UIImage(named: "icMoreBlack"), for: .normal)
    }
    var backButton = UIButton(type: .custom).configure {
        $0.setImage(UIImage(named: "btn_back_normal"), for: .normal)
    }
    
    var dontTriggerObservers:Bool = false
    
    public var model: FeedListCellModel? {
        didSet {
            self.setHeader()
            self.setBottomViewData()
            self.getCommentList()
            self.navView.updateSponsorStatus(model?.isSponsored ?? false)
        }
    }
    
    public var transitionId = UUID().uuidString
    public var afterTime: String = ""
    
    private var commentModel: FeedCommentListCellModel?
    private var commentDatas: [FeedCommentListCellModel] = [FeedCommentListCellModel]()
    private var sendText: String?
    private var isTapMore = false
    private var isClickCommentButton = false
    
    private let commentInputView = UIView()
    private var feedId: Int = 0
    private var feedOwnerId: Int = 0
    private var afterId: Int?
    private var isFullScreen: Bool = false
    private var sendCommentType: TGSendCommentType = .send
    private var headerView: FeedCommentDetailTableHeaderView = FeedCommentDetailTableHeaderView()
    private var bottomToolBarView: TGFeedCommentDetailBottomView = TGFeedCommentDetailBottomView(frame: .zero, colorStyle: .normal)
    private var voucherBottomView: VoucherBottomView = VoucherBottomView()
    
    public var onToolbarUpdated: onToolbarUpdate?
    var reactionHandler: TGReactionHandler?
    public var reactionSelected: ReactionTypes?
    
    public var isHomePage: Bool = false
    // feed type
    public var type: TGFeedListType?
    
    public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return true
    }
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    
    var startPlayTime: CMTime = .zero
    var onDismiss: ((CMTime) -> Void)?
    var tagVoucher: TagVoucherModel?
    
    public init(feedId: Int, isTapMore: Bool = false, isClickCommentButton: Bool = false, isVideoFeed: Bool = false, onToolbarUpdated: onToolbarUpdate?) {
        super.init(nibName: nil, bundle: nil)
        self.feedId = feedId
        self.isTapMore = isTapMore
        self.isClickCommentButton = isClickCommentButton
        self.onToolbarUpdated = onToolbarUpdated
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        TGKeyboardToolbar.share.theme = .white
        TGKeyboardToolbar.share.setStickerNightMode(isNight: false)
        TGKeyboardToolbar.share.keyboardToolbarDelegate = self
        prepareNavItems()
        setupTableView()
        setBottomView()
        configurePrimaryButton()
        tableView.mj_header.beginRefreshing()
    }
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        TGKeyboardToolbar.share.keyboarddisappear()
        TGKeyboardToolbar.share.keyboardStopNotice()
        
        self.reactionHandler?.reset()
        
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        TGKeyboardToolbar.share.keyboardstartNotice()
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        NotificationCenter.default.add(observer: self, name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil) { [weak self] (noti) in
            guard let self = self else { return }
            guard let userInfo = noti.userInfo, let followStatus = userInfo["follow"] as? FollowStatus, let uid = userInfo["userid"] as? String else { return }
            guard var object = self.model?.userInfo else { return }
            
            if object.userIdentity == uid.toInt() {
                if followStatus == .unfollow {
                    object.follower = false
                } else if followStatus == .follow {
                    object.follower = true
                }
                self.model?.userInfo = object
                self.updatePrimaryButton()
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updatePinnedCell(notice:)), name: NSNotification.Name(rawValue: "newPinnedFeed"), object: nil)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refresh(true)
        //开始记录停留时间
        stayBeginTimestamp = Date().timeStamp
    }
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.behaviorUserFeedStayData()
    }
    private func setupTableView() {
        
        backBaseView.addSubview(tableView)
        tableView.bindToSafeEdges()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60;
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 75))
        tableView.mj_header = SCRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = SCRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.mj_footer.makeHidden()
        
        tableView.keyboardDismissMode = .onDrag
        tableView.translatesAutoresizingMaskIntoConstraints = false
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        tableView.tableHeaderView = headerView
    }
    
    private func setHeader() {
        guard let model = model else { return }
        self.headerView.setModel(model: model)
        
        self.primaryButton.isHidden = false
        self.moreButton.isHidden = false
        
        let likeItem = self.bottomToolBarView.toolbar.getItemAt(0)
        reactionHandler = TGReactionHandler(reactionView: likeItem, toAppearIn: self.view, currentReaction: model.reactionType, feedId: model.idindex, feedItem: model, reactions: [.heart,.awesome,.wow,.cry,.angry])
        
        likeItem.addGestureRecognizer(reactionHandler!.longPressGesture)
        reactionHandler?.onSelect = { [weak self] reaction in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.animate(for: reaction)
                self.reactionSelected = reaction
            }
        }
        reactionHandler?.onSuccess = { [weak self] message in
            guard let self = self else { return }
            self.refresh(true)
        }
        
        self.headerView.onTapPictureClickCall = { [weak self] tappedIndex, transitionId in
            
            guard let self = self else { return }
            let userID = Int(RLSDKManager.shared.loginParma?.uid ?? 0)
            guard let model = self.model else { return }
            
            let dest = TGFeedDetailImagePageController(config: .list(data: [model], tappedIndex: tappedIndex, mediaType: .image, listType: self.type ?? .user(userId: userID), transitionId: transitionId, placeholderImage: nil, isClickComment: false, isTranslateText: false), completeHandler: nil, onToolbarUpdated: onToolbarUpdated, translateHandler: nil, tagVoucher: self.tagVoucher)
            dest.isControllerPush = true
            dest.afterTime = self.afterTime
            
            self.navigationController?.pushViewController(dest, animated: true)
        }
        self.headerView.onTranslated = { [weak self] in
            guard let self = self else { return }
            self.headerView.setNeedsLayout()
            self.headerView.layoutIfNeeded()
            self.tableView.tableHeaderView = self.headerView
            // By Kit Foong (Remove place holder and update the header frame margin)
            self.tableView.removePlaceholderViews()
            if self.commentDatas.count <= 0 {
                self.tableView.show(placeholderView: .noComment, margin: self.headerView.frame.maxY, height: 350)
            }
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 350, right: 0)
            self.tableView.setNeedsLayout()
            self.tableView.layoutIfNeeded()
        }
        
        headerView.feedShopView.momentMerchantDidClick = { merchantData in
            
            let appId = merchantData.wantedMid
            var path = merchantData.wantedPath
            path = path + "?id=\(appId)"
            print("=path = \(path)")
            RLSDKManager.shared.imDelegate?.didPressMiniProgrom(appId: "localInfo.mpExtras", path: path)
        }
        
        self.headerView.setNeedsLayout()
        self.headerView.layoutIfNeeded()
        self.tableView.tableHeaderView = self.headerView
        
    }
    private func setBottomViewData() {
        guard let model = model else { return }
        bottomToolBarView.isHidden = false
        bottomToolBarView.loadToolbar(model: model.toolModel, canAcceptReward: model.canAcceptReward == 1 ? true : false, reactionType: model.reactionType)
    }
    private func setBottomView() {
        self.backBaseView.addSubview(bottomToolBarView)
        self.backBaseView.addSubview(voucherBottomView)
        
        bottomToolBarView.isHidden = true
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
        bottomToolBarView.snp.makeConstraints {
            $0.right.left.bottom.equalToSuperview()
            $0.height.equalTo(70)
        }
        
        voucherBottomView.isHidden = true
        voucherBottomView.isUserInteractionEnabled = true
        voucherBottomView.snp.makeConstraints {
            $0.bottom.equalTo(bottomToolBarView.snp.top).offset(0)
            $0.right.left.equalToSuperview()
            $0.height.equalTo(44)
        }
        voucherBottomView.voucherOnTapped = { [weak self] in
            RLSDKManager.shared.feedDelegate?.didVoucherTouched(voucherId: self?.tagVoucher?.taggedVoucherId ?? 0)
        }
    }
    // MARK: - 设置导航栏按钮
    private func prepareNavItems() {
        
        primaryButton.addTap { [weak self] (_) in
            guard let self = self else { return }
            self.followUserClicked()
        }
        primaryButton.snp.makeConstraints {
            $0.width.equalTo(70)
            $0.height.equalTo(25)
        }
        moreButton.addAction {
            guard let id = RLSDKManager.shared.loginParma?.uid else {
                return
            }
            guard let model = self.model else { return }
            
            self.navigationController?.presentPopVC(target: model, type: model.userId == id ? .moreMe : .moreUser , delegate: self)
        }
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 12
        //等数据加载成功再显示按钮
        primaryButton.isHidden = true
        moreButton.isHidden = true
        
        self.backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        self.moreButton.addTarget(self, action: #selector(moreButtonClick), for: .touchUpInside)
        customNavigationBar.setRightViews(views: [primaryButton, moreButton])
        customNavigationBar.setLeftViews(views: [backButton , navView])
    }
    @objc func backButtonClick () {
        self.view.endEditing(true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
            if self.isHomePage {
                self.navigationController?.popViewController(animated: true)
            } else {
                if self.isModal {
                    self.dismiss(animated: true)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    @objc func updatePinnedCell(notice: NSNotification) {
        guard let userInfo = notice.userInfo else { return }
        guard let isPinned = userInfo["isPinned"] as? Bool else { return }
        self.model?.isPinned = isPinned
    }
    
    
    @objc func moreButtonClick(){
        let id = Int(RLSDKManager.shared.loginParma?.uid ?? 0)
        
        guard let model = self.model else { return }
        
        self.presentPopVC(target: model, type: model.userId == id ? .moreMe : .moreUser , delegate: self)
    }
    
    override func placeholderButtonDidTapped() {
        self.tableView.mj_header.beginRefreshing()
    }
    @objc func refresh(_ dontTriggerObservers: Bool = false) {
        
        TGFeedNetworkManager.shared.fetchFeedDetailInfo(withFeedId: "\(feedId)") {[weak self] feedInfo, error in
            
            guard let feedInfo = feedInfo, let self = self else {
                self?.show(placeholder: .network)
                return
            }
            let cellModel = FeedListCellModel(feedListModel: feedInfo)
            self.feedOwnerId = cellModel.userId
            self.dontTriggerObservers = dontTriggerObservers
            self.tableView.mj_header.endRefreshing()
            
            self.model = cellModel
            
            if self.tagVoucher?.taggedVoucherId != nil && self.tagVoucher?.taggedVoucherId != 0 {
                self.voucherBottomView.isHidden = false
                self.voucherBottomView.voucherLabel.text = self.tagVoucher?.taggedVoucherTitle ?? ""
            } else {
                self.voucherBottomView.isHidden = true
            }
            
            if let tagVoucher = feedInfo.tagVoucher {
                self.tagVoucher = tagVoucher
            }
            DispatchQueue.main.async {
                self.removePlaceholderView()
                self.updatePrimaryButton()
                self.navView.update(model: cellModel.userInfo ?? TGUserInfoModel())
                self.setBottomViewData()
            }
        }
    }
    @objc func loadMore() {
        TGFeedNetworkManager.shared.fetchFeedCommentsList(withFeedId: "\(feedId)", afterId: afterId, limit: 20) {[weak self] contentListResponse, error in
            guard let feedIcontentListResponsenfo = contentListResponse, let self = self else {
                DispatchQueue.main.async {
                    self?.tableView.mj_footer.endRefreshingWithWeakNetwork()
                }
                return
            }
            let commentList = feedIcontentListResponsenfo
            self.commentDatas += commentList
            self.model?.comments = self.commentDatas
            self.afterId = commentList.last?.id["commentId"]
            
            DispatchQueue.main.async {
                if commentList.count < 20 {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self.tableView.mj_footer.endRefreshing()
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    private func animate(for reaction: ReactionTypes?) {
        let toolbaritem = bottomToolBarView.toolbar.getItemAt(0)
        
        //设置点赞状态
        if let reaction = reaction {
            if self.model?.topReactionList.contains(reaction) == false {
                self.model?.topReactionList.append(reaction)
            }
            
            if self.model?.reactionType == nil {
                self.model?.toolModel?.diggCount += 1
            }
            UIView.transition(with: toolbaritem.imageView, duration: 0.3) {
                toolbaritem.imageView.image = reaction.image
            }
        } else {
            self.model?.toolModel?.diggCount -= 1
            UIView.transition(with: toolbaritem.imageView, duration: 0.3) {
                toolbaritem.imageView.image = UIImage(named: "IMG_home_ico_love")
            }
        }
        if let count = self.model?.toolModel?.diggCount, count >= 0 {
            toolbaritem.titleLabel.text = count.stringValue
        }
    }
    
    private func getCommentList() {
        TGFeedNetworkManager.shared.fetchFeedCommentsList(withFeedId: "\(feedId)", afterId: nil, limit: 20) {[weak self] contentListResponse, error in
            guard let feedIcontentListResponsenfo = contentListResponse, let self = self else {
                self?.tableView.mj_header.endRefreshing()
                //                UIViewController.showBottomFloatingToast(with: errorMsg.orEmpty, desc: "")
                self?.tableView.show(placeholderView: .network)
                return
            }
            let commentList = feedIcontentListResponsenfo
            self.commentDatas = commentList
            self.model?.comments = self.commentDatas
            self.tableView.mj_footer.isHidden = self.commentDatas.count < 20
            self.afterId = commentList.last?.id["commentId"]
            self.tableView.mj_header.endRefreshing()
            self.checkEmptyComment()
            if self.isClickCommentButton == true {
                TGKeyboardToolbar.share.keyboardBecomeFirstResponder()
            }
            self.tableView.reloadData()
        }
    }
    private func checkEmptyComment() {
        if self.commentDatas.count <= 0 {
            self.tableView.show(placeholderView: .noComment, margin: self.headerView.frame.maxY, height: 100)
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 350, right: 0)
        } else {
            self.tableView.removePlaceholderViews()
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.tableView.mj_footer.height, right: 0)
            if self.isTapMore == true {
                self.isTapMore = false
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    private func updatePrimaryButton() {
        
        primaryButton.isHidden = false
        moreButton.isHidden = false
        
        guard let followStatus = self.model?.userInfo?.followStatus else { return }
        
        var followStatusDidChanged:Bool = false
        var actionTitle: String = "profile_follow".localized
        switch followStatus {
        case .eachOther:
            actionTitle = "profile_home_follow_mutual".localized
            currentPrimaryButtonState = .followMutually
            primaryButton.backgroundColor = UIColor(hex: 0xB4B4B4)
            
        case .follow:
            if currentPrimaryButtonState != .follow {
                followStatusDidChanged = true
            }
            actionTitle = "profile_home_follow".localized
            primaryButton.backgroundColor = UIColor(hex: 0xB4B4B4)
            currentPrimaryButtonState = .follow
            
        case .unfollow:
            if currentPrimaryButtonState != .unfollow {
                followStatusDidChanged = true
            }
            actionTitle = "display_follow".localized
            primaryButton.backgroundColor = TGAppTheme.primaryRedColor
            currentPrimaryButtonState = .unfollow
            
            
        case .oneself:
            actionTitle = "display_follow".localized
            primaryButton.backgroundColor = UIColor(hex: 0xB4B4B4)
            currentPrimaryButtonState = .follow
            primaryButton.isHidden = true
            
        }
        
        if followStatusDidChanged {
            UIView.transition(with: self.primaryButton, duration: 0.2, options: .transitionCrossDissolve, animations: { [weak self] in
                guard let self = self else { return }
                self.primaryButton.setTitle(actionTitle)
            }, completion: nil)
        } else {
            primaryButton.setTitle(actionTitle)
            
        }
    }
    private func configurePrimaryButton() {
        primaryButton.addTap { [weak self] (_) in
            guard let self = self else { return }
            
            primaryButton.setTitle("Loading...".localized, for: .normal)
            self.model?.userInfo?.updateFollow { [weak self] (success) in
                DispatchQueue.main.async {
                    if success {
                        guard let self = self  else { return }
                        guard let follower = self.model?.userInfo?.follower else { return }
                        guard let userIdentity = self.model?.userInfo?.userIdentity else { return }
                        // By Kit Foong (Trigger observer to update follow status)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil, userInfo: ["follow": follower, "userid": "\(userIdentity)"])
                        self.updatePrimaryButton()
                        self.refresh(true)
                    } else {
                        self?.updatePrimaryButton()
                    }
                }
            }
        }
    }
    private func followUserClicked() {
        
        guard var object = model?.userInfo else { return }
        
        guard let relationship = object.relationshipWithCurrentUser else {
            return
        }
        if relationship.status == .eachOther {
            let me: String = NIMSDK.shared().v2LoginService.getLoginUser() ?? ""
            let conversationId = "\(me)|1|\(object.username)"
            let vc = TGChatViewController(conversationId: conversationId, conversationType: 1)
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            object.updateFollow { (success) in
                DispatchQueue.main.async {
                    if success {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil, userInfo: ["follow": object.follower, "userid": "\(object.userIdentity)"])
                        self.updatePrimaryButton()
                        self.refresh(true)
                    }
                }
            }
        }
    }
    private func postComment(message: String, contentType: CommentContentType) {
        guard let currentUserId = RLCurrentUserInfo.shared.uid, let feedId = self.model?.idindex else { return }
        let commentType = TGCommentType(type: .feed)
        
        self.showLoading()
        //上报动态评论事件
        RLSDKManager.shared.feedDelegate?.onTrackEvent(itemId: feedId.stringValue, itemType: self.model?.feedType == .miniVideo ? TGItemType.shortvideo.rawValue : TGItemType.image.rawValue, behaviorType: TGBehaviorType.comment.rawValue, moduleId: TGModuleId.feed.rawValue, pageId: TGPageId.feed.rawValue, behaviorValue: nil, traceInfo: nil)
        
        
        TGFeedNetworkManager.shared.submitComment(for: commentType, content: message, sourceId: feedId, replyUserId: self.commentModel?.userInfo?.userIdentity, contentType: contentType) { [weak self] (commentModel, message, result) in
            guard let currentUserInfo = TGUserInfoModel.retrieveCurrentUserSessionInfo(), let feedId = self?.model?.index else { return }
            defer {
                DispatchQueue.main.async {
                    self?.dismissLoading()
                }
            }
            
            guard result == true, let data = commentModel, let wself = self else {
                UIViewController.showBottomFloatingToast(with: message ?? "please_retry_option".localized, desc: "", displayDuration: 4.0)
                return
            }
            var simpleModel = data.simpleModel()
            simpleModel.userInfo = currentUserInfo.toType(type: TGUserInfoModel.self)
            switch wself.sendCommentType {
            case .send:
                simpleModel.replyUserInfo = nil
            case .replySend:
                simpleModel.replyUserInfo = wself.commentModel?.userInfo?.toType(type: TGUserInfoModel.self)
            default:
                simpleModel.replyUserInfo = wself.commentModel?.replyUserInfo?.toType(type: TGUserInfoModel.self)
            }
            let newCommentModel = FeedCommentListCellModel(object: simpleModel, feedId: feedId)
            newCommentModel.userId = currentUserInfo.userIdentity
            if let lastPinnedIndex = wself.commentDatas.lastIndex(where: { $0.showTopIcon == true }) {
                wself.commentDatas.insert(newCommentModel, at: lastPinnedIndex + 1)
            } else {
                wself.commentDatas.insert(newCommentModel, at: 0)
            }
            wself.model?.comments = wself.commentDatas
            wself.model?.toolModel?.commentCount += 1
            DispatchQueue.main.async {
                wself.tableView.removePlaceholderViews()
                wself.bottomToolBarView.toolbar.setTitle((wself.model?.toolModel?.commentCount).orZero.abbreviated, At: 1)
                wself.headerView.setCommentLabel(count: wself.model?.toolModel?.commentCount, isCommentDisabled: false)
                wself.headerView.layoutIfNeeded()
                wself.tableView.reloadData()
                guard let model = wself.model else { return }
                wself.onToolbarUpdated?(model)
            }
        }
    }
    private func deleteComment(with cellModel: FeedCommentListCellModel) {
        guard let commentId = cellModel.id["commentId"], let feedId = model?.id["feedId"] else {
            return
        }
        TGCommentNetWorkManager.shared.deleteComment(for: .momment, commentId: commentId, sourceId: feedId) { [weak self] (message, status) in
            DispatchQueue.main.async {
                if status == true {
                    self?.commentDatas.removeAll(where: { $0.id["commentId"] == commentId })
                    self?.model?.toolModel?.commentCount -= 1
                    self?.headerView.setCommentLabel(count: self?.model?.toolModel?.commentCount, isCommentDisabled: false)
                    self?.bottomToolBarView.toolbar.setTitle((self?.model?.toolModel?.commentCount).orZero.abbreviated, At: 1)
                    self?.tableView.reloadData()
                    guard let model = self?.model else { return }
                    self?.onToolbarUpdated?(model)
                } else {
                    self?.showTopFloatingToast(with: "", desc: message.orEmpty)
                }
            }
        }
    }
    private func setTSKeyboard(placeholderText: String, cell: FeedDetailCommentTableViewCell?) {
        TGKeyboardToolbar.share.keyboardBecomeFirstResponder()
        TGKeyboardToolbar.share.keyboardSetPlaceholderText(placeholderText: placeholderText)
    }
    
    // MARK: - 记录转发
    private func forwardFeed() {
        guard let feedmodel = model else { return }
        let feedId = feedmodel.idindex
        self.showLoading()
        TGFeedNetworkManager.shared.forwardFeed(feedId: feedId) {[weak self] errMessage, statusCode, status in
            guard let self = self else { return }
            defer {
                DispatchQueue.main.async {
                    self.dismissLoading()
                    self.refresh(false)
                }
                //上报动态转发事件
                RLSDKManager.shared.feedDelegate?.onTrackEvent(itemId: feedId.stringValue, itemType: feedmodel.feedType == .miniVideo ? TGItemType.shortvideo.rawValue : TGItemType.image.rawValue, behaviorType: TGBehaviorType.forward.rawValue, moduleId: TGModuleId.feed.rawValue, pageId: TGPageId.feed.rawValue, behaviorValue: nil, traceInfo: nil)
                
            }
            guard status == true else {
                if statusCode == 241 {
                    self.showDialog(image: nil, title: "fail_to_pin_title".localized, message: "fail_to_pin_desc".localized, dismissedButtonTitle: "ok".localized, onDismissed: nil, onCancelled: nil)
                } else {
                    UIViewController.showBottomFloatingToast(with: errMessage, desc: "")
                }
                return
            }
        }
        
    }
}


// Table View Delegate
extension TGFeedInfoDetailViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedDetailCommentTableViewCell.cellIdentifier, for: indexPath) as! FeedDetailCommentTableViewCell
        let feedCommentModel = self.commentDatas[indexPath.row]
        cell.cellDelegate = self
        cell.setData(data: feedCommentModel)
        cell.setAsPinned(pinned: self.commentDatas[indexPath.row].showTopIcon, isDarkMode: false)
        
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
        
        guard let userInfo = comment.userInfo else {
            //            needShowError()
            return
        }
        guard !userInfo.isMe() else { return }
        
        TGKeyboardToolbar.share.keyboarddisappear()
        
        self.sendCommentType = .replySend
        self.commentModel = comment
        if model?.toolModel?.isCommentDisabled == false {
            setTSKeyboard(placeholderText: "reply_with_string".localized + "\((self.commentModel?.userInfo?.name)!)", cell: cell)
        }
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension TGFeedInfoDetailViewController: TGDetailCommentTableViewCellDelegate {
    func repeatTap(cell: FeedDetailCommentTableViewCell, commnetModel: FeedCommentListCellModel) {
        
    }
    
    func didSelectName(userId: Int) {
        RLSDKManager.shared.imDelegate?.didPressUerProfile(uid: userId)
    }
    
    func didSelectHeader(userId: Int) {
        RLSDKManager.shared.imDelegate?.didPressUerProfile(uid: userId)
    }
    
    func didLongPressComment(in cell: FeedDetailCommentTableViewCell, model: FeedCommentListCellModel) {
        guard  let currentUserInfo = TGUserInfoModel.retrieveCurrentUserSessionInfo() else {
            return
        }
        
        // 显示举报评论弹窗
        let isFeedOwner = currentUserInfo.userIdentity == self.feedOwnerId
        let isCommentOwner = currentUserInfo.userIdentity == model.userId
        
        if isCommentOwner {
            self.navigationController?.presentPopVC(target: LivePinCommentModel(target: cell, requiredPinMessage: isFeedOwner, model: model), type: .selfComment, delegate: self)
        } else {
            self.navigationController?.presentPopVC(target: LivePinCommentModel(target: cell, requiredPinMessage: isFeedOwner, model: model), type: .normalComment , delegate: self)
        }
    }
    
    func didTapToReplyUser(in cell: FeedDetailCommentTableViewCell, model: FeedCommentListCellModel) {
        
        let userId = model.userInfo?.userIdentity
        TGKeyboardToolbar.share.keyboarddisappear()
        if userId == (TGUserInfoModel.retrieveCurrentUserSessionInfo()?.userIdentity)! {
            let customAction = TGCustomActionsheetView(titles: ["choice_delete".localized])
            customAction.delegate = self
            customAction.tag = 250
            customAction.show()
            return
        }
        
        self.sendCommentType = .replySend
        self.commentModel = model
        setTSKeyboard(placeholderText: "reply_with_string".localized + "\((self.commentModel?.userInfo?.name)!)", cell: cell)
    }
    
    func needShowError() {
        self.showTopFloatingToast(with: "text_user_suspended", desc: "")
    }
    
    private func pinComment(in cell: FeedDetailCommentTableViewCell, comment: FeedCommentListCellModel) {
        guard let commentId = comment.id["commentId"], let cellIndex = self.commentDatas.firstIndex(where: { $0.id["commentId"] == commentId }) else {
            return
        }
        
        TGCommentNetWorkManager.shared.pinComment(for: commentId, sourceId: feedId) { [weak self] (message, status) in
            //            cell.hideLoading()
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard let commentIndex = self.commentDatas.firstIndex(where: { $0.id["commentId"] == commentId }) else { return }
                guard status == true else {
                    self.showTopFloatingToast(with: message.orEmpty, desc: message.orEmpty)
                    return
                }
                self.showTopFloatingToast(with: "feed_live_pinned_comment".localized, desc: message.orEmpty)
                self.commentDatas[cellIndex].showTopIcon = true
                cell.setAsPinned(pinned: true, isDarkMode: false)
                self.tableView.moveRow(at: IndexPath(row: cellIndex, section: 0), to: IndexPath(row: 0, section: 0))
                self.commentDatas.remove(at: cellIndex)
                self.commentDatas.insert(comment, at: 0)
            }
        }
    }
    
    private func unpinComment(in cell: FeedDetailCommentTableViewCell, comment: FeedCommentListCellModel) {
        guard let commentId = comment.id["commentId"], let cellIndex = self.commentDatas.firstIndex(where: { $0.id["commentId"] == commentId }) else {
            return
        }
        //        cell.showLoading()
        TGCommentNetWorkManager.shared.unpinComment(for: commentId, sourceId: feedId) { [weak self] (message, status) in
            //            cell.hideLoading()
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard let commentIndex = self.commentDatas.firstIndex(where: { $0.id["commentId"] == commentId }) else { return }
                guard status == true else {
                    self.showTopFloatingToast(with: message.orEmpty, desc: message.orEmpty)
                    return
                }
                self.showTopFloatingToast(with: "feed_live_unpinned_comment".localized, desc: message.orEmpty)
                self.commentDatas[cellIndex].showTopIcon = false
                cell.setAsPinned(pinned: false, isDarkMode: false)
                self.tableView.moveRow(at: IndexPath(row: cellIndex, section: 0), to: IndexPath(row: self.commentDatas.count - 1, section: 0))
                self.commentDatas.remove(at: cellIndex)
                self.commentDatas.append(comment)
            }
        }
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
            self.forwardFeed()
            
            if let model = self.model {
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
            self.forwardFeed()
            if let model = self.model, let webServerAddress = RLSDKManager.shared.loginParma?.webServerAddress {
                let messagePopModel = TGmessagePopModel(momentModel: model)
                let fullUrlString = "\(webServerAddress)feeds/\(String(messagePopModel.feedId))"
                // By Kit Foong (Hide Yippi App from share)
                guard let url = URL(string: fullUrlString) else { return }
                let items: [Any] = [url, messagePopModel.titleSecond, ShareExtensionBlockerItem()]
                let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view
                self.present(activityVC, animated: true, completion: nil)
            }
        case .save(isSaved: let isSaved):
            if let feedmodel = self.model {
                let isCollect = (feedmodel.toolModel?.isCollect).orFalse ? false : true
                TGFeedNetworkManager.shared.colloction(isCollect ? 1 : 0, feedIdentity: feedmodel.idindex, feedItem: feedmodel) {[weak self] result in
                    if result == true {
                        self?.model?.toolModel?.isCollect = isCollect
                        DispatchQueue.main.async {
                            if isCollect {
                                self?.showTopFloatingToast(with: "success_save".localized, desc: "")
                            }
                        }
                    }
                }
            }
            
            
            break
        case .reportPost:
            guard let feedmodel = model else {
                return
            }
            guard let reportTarget: ReportTargetModel = ReportTargetModel(feedModel: feedmodel) else { return }
            let reportVC: TGReportViewController = TGReportViewController(reportTarget: reportTarget)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.present(TGNavigationController(rootViewController: reportVC).fullScreenRepresentation,
                             animated: true,
                             completion: nil)
            }
            break
        case .edit:
            guard let model = model else {
                return
            }
            let pictures =  model.pictures.map{ TGRejectDetailModelImages(fileId: $0.file, imagePath: $0.url ?? "", isSensitive: false, sensitiveType: "")   }
            let vc = TGReleasePulseViewController(type: .photo)
            vc.selectedModelImages = pictures
            
            vc.preText = model.content
            
            vc.feedId = model.idindex.stringValue
            vc.isFromEditFeed = true
            
            vc.tagVoucher = model.tagVoucher
            
            _ = self.configureReleasePulseViewController(detailModel: model, releasePulseVC: vc)
            
            let navigation = TGNavigationController(rootViewController: vc).fullScreenRepresentation
            self.present(navigation, animated: true, completion: nil)
            break
        case .deletePost:
            guard let model = model else {
                return
            }
            self.showRLDelete(title: "rw_delete_action_title".localized, message: "rw_delete_action_desc".localized, dismissedButtonTitle: "delete".localized, onDismissed: { [weak self] in
                guard let self = self else { return }
                TGFeedNetworkManager.shared.deleteMoment(model.idindex) { [weak self] result in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "feedDelete"), object: nil, userInfo: ["feedId": self.feedId])
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
            }, cancelButtonTitle: "cancel".localized)
            
            break
        case .pinTop(isPinned: let isPinned):
            guard let model = model else {
                return
            }
            let feedId = model.idindex
            
            TGFeedNetworkManager.shared.pinFeed(feedId: feedId) {[weak self] errMessage, statusCode, status in
                guard let self = self else { return }
                guard status == true else {
                    if statusCode == 241 {
                        self.showDialog(image: nil, title: isPinned ? "fail_to_pin_title".localized : "fail_to_unpin_title".localized, message: isPinned ? "fail_to_pin_desc".localized : "fail_to_unpin_desc".localized, dismissedButtonTitle: "ok".localized, onDismissed: nil, onCancelled: nil)
                    } else {
                        UIViewController.showBottomFloatingToast(with: errMessage, desc: "")
                    }
                    return
                }
                
                let newPined = !isPinned
                
                self.model?.isPinned = newPined
                UIViewController.showBottomFloatingToast(with: newPined ? "feed_pinned".localized : "feed_unpinned".localized, desc: "")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPinnedFeed"), object: nil, userInfo: ["isPinned": !isPinned, "feedId": feedId])
            }
            
            break
        case .comment(isCommentDisabled: _):
            guard let model = model else {
                return
            }
            let feedId = model.idindex
            
            let newValue = model.toolModel?.isCommentDisabled ?? true ? 0 : 1
            TGFeedNetworkManager.shared.commentPrivacy(newValue, feedIdentity: feedId) {[weak self] success in
                guard let self = self else { return }
                if success {
                    self.model?.toolModel?.isCommentDisabled = newValue == 1
                    DispatchQueue.main.async {
                        if newValue == 1 {
                            self.showTopFloatingToast(with: "disable_comment_success".localized)
                        } else {
                            self.showTopFloatingToast(with: "enable_comment_success".localized)
                        }
                        self.setBottomViewData()
                    }
                }
            }
            
            break
        case .deleteComment(model: let model):
            let feedModel = model.model
            self.showRLDelete(title: "delete_comment".localized, message: "rw_delete_comment_action_desc".localized, dismissedButtonTitle: "delete".localized, onDismissed: { [weak self] in
                guard let self = self else { return }
                self.deleteComment(with: feedModel)
            }, cancelButtonTitle: "cancel".localized)
            break
        case .reportComment(model: let model):
            let feedModel = model.model
            let reportTarget = ReportTargetModel(feedCommentModel: feedModel)
            let reportVC = TGReportViewController(reportTarget: reportTarget)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.present(TGNavigationController(rootViewController: reportVC).fullScreenRepresentation, animated: true, completion: nil)
            }
            break
        case .livePinComment(model: let model):
            guard let cell = model.target as? FeedDetailCommentTableViewCell else { return }
            DispatchQueue.main.async {
                self.pinComment(in: cell, comment: model.model)
            }
            break
        case .liveUnPinComment(model: let model):
            guard let cell = model.target as? FeedDetailCommentTableViewCell else { return }
            DispatchQueue.main.async {
                self.unpinComment(in: cell, comment: model.model)
            }
            break
        case .copy(model: let model):
            let model = model.model
            UIPasteboard.general.string = model.content
            UIViewController.showBottomFloatingToast(with: "rw_copy_to_clipboard".localized, desc: "")
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
            releasePulseVC.shortVideoAsset = TGShortVideoAsset(coverImage: coverImage, asset: nil, videoFileURL: url)
            let navigation = TGNavigationController(rootViewController: releasePulseVC).fullScreenRepresentation
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + (self?.launchScreenDismissWithDelay() ?? 0.0)) {
                self?.present(navigation, animated: true, completion: nil)
            }
        }
        
    }
    
}

extension TGFeedInfoDetailViewController: TGCustomAcionSheetDelegate {
    func returnSelectTitle(view: TGCustomActionsheetView, title: String, index: Int) {
        
    }
}


extension TGFeedInfoDetailViewController {
    func behaviorUserFeedStayData() {
        if stayBeginTimestamp != "" {
            stayEndTimestamp = Date().timeStamp
            let stay = stayEndTimestamp.toInt()  - stayBeginTimestamp.toInt()
            if stay > 5 {
                self.stayBeginTimestamp = ""
                self.stayEndTimestamp = ""
                RLSDKManager.shared.feedDelegate?.onTrackEvent(itemId: self.model?.idindex.stringValue ?? "", itemType: TGItemType.image.rawValue, behaviorType: TGBehaviorType.stay.rawValue, moduleId: TGModuleId.feed.rawValue, pageId: TGPageId.feed.rawValue, behaviorValue: stay.stringValue, traceInfo: nil)
            }
        }
    }
}
