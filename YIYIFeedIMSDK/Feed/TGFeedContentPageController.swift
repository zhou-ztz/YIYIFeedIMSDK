//
//  TGFeedContentPageController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/20.
//

import UIKit
import Lottie

public typealias onToolbarUpdate = ((Any) -> Void)

public class TGFeedContentPageController: TGBaseContentPageController {
    private let animateView = AnimationView()
    private(set) var dataModel = FeedListCellModel()
    private var pageHandler = PageHandler()
    let interactiveView = TGFeedDetailInteractiveView()
    var onIndexUpdate: ((Int, String) -> Void)?
    var onToolbarUpdated: onToolbarUpdate?
    var translateHandler: ((Bool) -> Void)?
    var onTapHiddenUpdate: ((Bool) -> Void)?
    private var imageIndex: Int = 0
    var isClickComment: Bool = false
    var isTranslateText: Bool = false
    var onDelete: TGEmptyClosure?
    // feed type
    var type: TGFeedListType?
    var isExpand: Bool = false
    
    init(currentIndex: Int = 0, dataModel: FeedListCellModel,
         imageIndex: Int = 0, placeholderImage: UIImage?,
         transitionId: String? = nil, isClickComment: Bool = false,
         isTranslateText: Bool = false,
         onRefresh: TGEmptyClosure?, onLoadMore: TGEmptyClosure?,
         onToolbarUpdated: onToolbarUpdate?,
         onIndexUpdate: ((Int, String) -> Void)? = nil,
         translateHandler: ((Bool) -> Void)? = nil,
         onTapHiddenUpdate: ((Bool) -> Void)? = nil,
         isExpand: Bool = false
    ) { // require to update transition animation to correct trellis view
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        self.onIndexUpdate = onIndexUpdate
        self.currentIndex = currentIndex
        self.dataModel = dataModel
        self.onRefresh = onRefresh
        self.onLoadMore = onLoadMore
        self.pageHandler.controller = self
        self.imageIndex = min(imageIndex, max(0, dataModel.pictures.count - 1))
        self.isClickComment = isClickComment
        self.isTranslateText = isTranslateText
        self.onToolbarUpdated = onToolbarUpdated
        self.translateHandler = translateHandler
        self.onTapHiddenUpdate = onTapHiddenUpdate
        self.isExpand = isExpand
        
        if !dataModel.pictures.isEmpty {
            let imageController = TGFeedDetailImageController(
                imageUrlPath: (dataModel.pictures[self.imageIndex].url).orEmpty,
                imageIndex: self.imageIndex,
                model: dataModel,
                placeholderImage: placeholderImage,
                transitionId: transitionId,
                isExpand: isExpand
            )
            setGesture(for: imageController)
            self.setViewControllers([imageController], direction: .forward, animated: true)
        }
        
        
        updateInteractiveView()
        interactiveView.readMoreLabel.setAllowTruncation()
        interactiveView.alpha = 1
        
        interactiveView.onCommentTouched = { [unowned self] in
            self.openCommentView()
        }
        
//        interactiveView.onGiftTouched = { [unowned self] in
//
//        }
        
        interactiveView.onForwardTouched =  { [unowned self] in
//            if TSCurrentUserInfo.share.isLogin == false {
//                TSRootViewController.share.guestJoinLandingVC()
//                return
//            }
            self.navigationController?.presentPopVC(target: "", type: .share, delegate: self)
        }
        
        interactiveView.onMoreTouched = { [unowned self] in
            guard let id = RLSDKManager.shared.loginParma?.uid else {
                return
            }
            
            self.navigationController?.presentPopVC(target: self.dataModel, type: self.dataModel.userId == id ? .moreMe : .moreUser , delegate: self)
        }
        
        interactiveView.onFollowTouched = { [weak self] in
            guard var user = dataModel.userInfo else { return }
            user.updateFollow(completion: { [weak self] (success) in
                if success {
                    DispatchQueue.main.async {
                        self?.interactiveView.updateFollowButton(user.followStatus)
                    }
                }
            })
        }
        interactiveView.voucherBottomView.voucherOnTapped = {
            RLSDKManager.shared.feedDelegate?.didVoucherTouched(voucherId: dataModel.tagVoucher?.taggedVoucherId ?? 0)
        }
        
        interactiveView.translateHandler = self.translateHandler
        
        interactiveView.onTapHiddenUpdate = self.onTapHiddenUpdate
        
        interactiveView.onLocationViewTapped = { (locationID, locationName) in
            RLSDKManager.shared.feedDelegate?.onLocationViewTapped(locationID: locationID, locationName: locationName)
        }
        
        interactiveView.onTopicViewTapped = { topicID in
            RLSDKManager.shared.feedDelegate?.onTopicViewTapped(groupId: topicID)
        }
        
        interactiveView.reactionSuccess = { [weak self] in
            guard let self = self else {
                return
            }
            
            TGFeedNetworkManager.shared.fetchFeedDetailInfo(withFeedId: "\(dataModel.idindex)") { feedInfo, error in
                guard let feedInfo = feedInfo else { return }
               
                let cellModel = FeedListCellModel(feedListModel: feedInfo)
                
                self.dataModel = cellModel
                self.interactiveView.updateUserReactionView(topReactionList: cellModel.topReactionList, totalReactions: (cellModel.toolModel?.diggCount).orZero)
                self.onToolbarUpdated?(cellModel)
                self.view.layoutIfNeeded()
            }
        }
        
        interactiveView.onTapReactionList = { [unowned self] feedId in
            self.showReactionBottomSheet()
        }
        
        interactiveView.onSearchPageTapped =  { hashtagString in
            RLSDKManager.shared.feedDelegate?.onSearchPageTapped(hashtag: hashtagString)
        }
        
        if dataModel.tagVoucher?.taggedVoucherId != nil && dataModel.tagVoucher?.taggedVoucherId != 0 {
            if let title = dataModel.tagVoucher?.taggedVoucherTitle {
                interactiveView.voucherBottomView.isHidden = false
                interactiveView.voucherBottomView.voucherLabel.text = title
            }
        } else {
            interactiveView.voucherBottomView.isHidden = true

        }
    }
    
    func openCommentView() {
        defer {
            RLSDKManager.shared.feedDelegate?.track(event: TGEvent.innerFeedViewClicks, with: ["Clicked": "Comment Btn"])
        }
        TGKeyboardToolbar.share.theme = .white
        TGKeyboardToolbar.share.setStickerNightMode(isNight: false)
        let respondVC = TGResponsePageController(theme: .white, feed: self.dataModel) { [weak self] (feed) in
            
            guard let feed = feed as? FeedListCellModel, let toolbar = feed.toolModel else {
                return
            }
            self?.interactiveView.updateCount(comment: toolbar.commentCount, like: toolbar.diggCount, forwardCount: toolbar.forwardCount)
            self?.interactiveView.updateCommentStatus(isCommentDisabled: toolbar.isCommentDisabled)
            self?.onToolbarUpdated?(feed)
        }
        let nav = UINavigationController(rootViewController: respondVC)
        nav.modalPresentationStyle = .custom
        nav.transitioningDelegate = self
        nav.view.backgroundColor = .clear
        self.present(nav, animated: true, completion: nil)
    }
    
    private func updateInteractiveView(isEdit: Bool? = nil) {
        interactiveView.updateTimeAndView(date: dataModel.time , views: (dataModel.toolModel?.viewCount).orZero, isEdit: isEdit ?? false)
        interactiveView.updateUser(user: dataModel.userInfo)
        interactiveView.updateUserAvatar(avatar: dataModel.avatarInfo)
        interactiveView.updateSponsorStatus(dataModel.isSponsored)
        //Rewardslink hidden topic view
        //interactiveView.updateTopicsView(with: dataModel.topics)
        //        interactiveView.updateLocationView(with: dataModel.location)
        interactiveView.updateLocationAndMerchantNameView(location: dataModel.location, rewardsMerchantUsers: dataModel.rewardsMerchantUsers)
        interactiveView.updateInfo(caption: dataModel.content, isExpand: isExpand)
        //处理商家的显示逻辑
        interactiveView.updateMerchantView(with: dataModel.rewardsMerchantUsers)
        interactiveView.updateCount(comment: (dataModel.toolModel?.commentCount).orZero, like: (dataModel.toolModel?.diggCount).orZero, forwardCount: (dataModel.toolModel?.forwardCount).orZero)
        interactiveView.updateCommentStatus(isCommentDisabled: dataModel.toolModel?.isCommentDisabled)
        interactiveView.updateReactionButton(reactionType: dataModel.reactionType)
        interactiveView.updateUserReactionView(topReactionList: dataModel.topReactionList, totalReactions: (dataModel.toolModel?.diggCount).orZero)
        interactiveView.updateGiftImage(canAcceptReward: (dataModel.userInfo?.isRewardAcceptEnabled).orFalse ,imageName: dataModel.toolModel?.isRewarded == true ? "ic_reward" : "ic_feed_inner_tips")
        
        interactiveView.updatePageCount(cur: imageIndex, max: dataModel.pictures.count)
        
        interactiveView.feedId = dataModel.idindex
        interactiveView.feedItem = dataModel
        interactiveView.reactionType = dataModel.reactionType
        
        if isTranslateText {
            interactiveView.updateTranslateText()
        }
        
        if let user = TGUserInfoModel.retrieveUser(username: (dataModel.userInfo?.username).orEmpty) {
            interactiveView.updateFollowButton(user.followStatus)
        } else {
            interactiveView.updateFollowButton(dataModel.userInfo?.followStatus ?? .unfollow)
        }
        //评论按钮显示/隐藏逻辑
        if let isCommentDisabled = dataModel.toolModel?.isCommentDisabled {
            interactiveView.updateCommentStatus(isCommentDisabled: isCommentDisabled)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.insertSubview(interactiveView, belowSubview: refreshView)
        interactiveView.bindToEdges()
        
        view.addSubview(animateView)
        animateView.snp.makeConstraints { v in
            v.width.height.equalTo(250)
            v.center.equalToSuperview()
        }
        animateView.isHidden = true
        
        view.layoutIfNeeded()
        
        NotificationCenter.default.addObserver(self, selector: #selector(newChangeFollowStatus(_:)), name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showReactionBottomSheet), name: NSNotification.Name.Reaction.show, object: nil)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.setClearNavBar(shadowColor: .clear)
        self.loadFeedData()
        //进入页面时将状态栏的字体改为白色
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.setWhiteNavBar(normal: true)
        //离开页面还原
        if #available(iOS 13.0, *) {
            UIApplication.shared.setStatusBarStyle(.darkContent, animated: true)
        } else {
            UIApplication.shared.setStatusBarStyle(.default, animated: true)
        }
    }
    func loadFeedData() {
        TGFeedNetworkManager.shared.fetchFeedDetailInfo(withFeedId: self.dataModel.idindex.stringValue) {[weak self] feedInfo, error in
            guard let listModel = feedInfo, let self = self else {
                return
            }
            let cellModel = FeedListCellModel(feedListModel: listModel)
            self.dataModel = cellModel
            self.interactiveView.updateTimeAndView(date: dataModel.time, views: (dataModel.toolModel?.viewCount).orZero)
        }
    }

    @objc func newChangeFollowStatus(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let followStatus = userInfo["follow"] as? FollowStatus, let uid = userInfo["userid"] as? String else { return }
        guard var object = self.dataModel.userInfo else { return }
        
        if object.userIdentity == uid.toInt() {
            if followStatus == .unfollow {
                object.follower = false
            } else if followStatus == .follow {
                object.follower = true
            }
            self.dataModel.userInfo = object
            self.interactiveView.updateFollowButton(self.dataModel.userInfo!.followStatus)
        }
    }
    
    func setGesture(for controller: TGFeedDetailImageController) {
        controller.onSingleTapView = { [weak self] in self?.toggleInteractiveView() }
        controller.onDoubleTapView = { [weak self] in
            self?.executeLike()
            self?.interactiveView.reactionHandler?.didSelectIcon = ReactionTypes.heart.rawValue
            self?.interactiveView.reactionHandler?.onSelect(reaction: .heart)
        }
        
        controller.onZoomUpdate = { [weak self] in
            guard let self = self else { return }
            if self.interactiveView.isHidden == false {
                self.toggleInteractiveView()
            }
        }
    }
    
    func toggleInteractiveView() {
        guard let currentVC = self.viewControllers?.first as? TGFeedDetailImageController else { return }
        if interactiveView.isHidden == true {
            interactiveView.fadeIn()
            currentVC.state = .normal
        } else {
            interactiveView.fadeOut()
            currentVC.state = .zoomable
        }
    }
    
    private func executeLike() {
        let likeAnimation = Animation.named("reaction-love")
        animateView.animation = likeAnimation
        
        animateView.isHidden = false
        animateView.play { finished in
            guard finished == true else { return }
            self.animateView.makeHidden()
        }
    }
    
    // MARK: - 转发后获取最新转发数
    private func updateForwardCount(_ dontTriggerObservers: Bool = false) {
        let feedId = self.dataModel.idindex
        TGFeedNetworkManager.shared.fetchFeedDetailInfo(withFeedId: "\(feedId)") {  [weak self] (feedInfo, error) in
            guard let cellModel = feedInfo, let self = self else { return }
            self.dataModel = FeedListCellModel(feedListModel: cellModel)
            self.interactiveView.updateCount(comment: (self.dataModel.toolModel?.commentCount).orZero, like: (self.dataModel.toolModel?.diggCount).orZero, forwardCount: (self.dataModel.toolModel?.forwardCount).orZero)
            self.interactiveView.updateCommentStatus(isCommentDisabled: self.dataModel.toolModel?.isCommentDisabled)
        }
    }
    
    // MARK: - 记录转发
    private func forwardFeed() {
        let feedId = self.dataModel.idindex
        self.showLoading()
        TGFeedNetworkManager.shared.forwardFeed(feedId: feedId) {[weak self] errMessage, statusCode, status in
            guard let self = self else { return }
            defer {
                DispatchQueue.main.async {
                    self.dismissLoading()
                    self.updateForwardCount()
                }
                //上报动态转发事件
                RLSDKManager.shared.feedDelegate?.onTrackEvent(itemId: feedId.stringValue, itemType: self.dataModel.feedType == .miniVideo ? TGItemType.shortvideo.rawValue  : TGItemType.image.rawValue, behaviorType: TGBehaviorType.forward.rawValue, moduleId: TGModuleId.feed.rawValue, pageId: TGPageId.feed.rawValue, behaviorValue: nil, traceInfo: nil)
                
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
    
    override func finishRefresh() {
        UIView.animate(withDuration: 0.25) { () -> () in
            self.interactiveView.pageCounterLabel.alpha = 1
            
        }
        refreshView.reset()
    }
    
    override func refreshViewOnChanged(progressRatio: CGFloat) {
        interactiveView.pageCounterLabel.alpha = 1 - progressRatio
    }
    
    @objc func showReactionBottomSheet() {
        TGKeyboardToolbar.share.theme = .white
        TGKeyboardToolbar.share.setStickerNightMode(isNight: false)
        let respondVC = TGResponsePageController(theme: .white, feed: self.dataModel, defaultSegment: 1, onToolbarUpdate: self.onToolbarUpdated)
        respondVC.titleLabel.text = ""
        let nav = UINavigationController(rootViewController: respondVC)
        nav.modalPresentationStyle = .custom
        nav.transitioningDelegate = self
        nav.view.backgroundColor = .clear
        self.present(nav, animated: true, completion: nil)
    }
}

private class PageHandler: NSObject, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIGestureRecognizerDelegate {
    weak var controller: TGFeedContentPageController? {
        didSet {
            controller?.delegate = self
            controller?.dataSource = self
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard finished == true else { return }
        guard let controller = controller else { return }
        guard let currentVC = pageViewController.viewControllers?.first as? TGFeedDetailImageController else { return }
        let index = currentVC.imageIndex
        
        let transitionId = UUID().uuidString
//        currentVC.imageView.hero.id = transitionId
        controller.interactiveView.updatePageCount(cur: index, max: controller.dataModel.pictures.count)
        
        controller.onIndexUpdate?(index, transitionId)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let controller = controller else { return nil }
        guard let currentVC = pageViewController.viewControllers?.first as? TGFeedDetailImageController else { return nil }
        
        let newIndex = currentVC.imageIndex - 1
        guard newIndex >= 0 else { return nil }
        
        let newController = TGFeedDetailImageController(imageUrlPath: (controller.dataModel.pictures[newIndex].url).orEmpty, imageIndex: newIndex, model: controller.dataModel)
        controller.setGesture(for: newController)
        return newController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let controller = controller else { return nil }
        guard let currentVC = pageViewController.viewControllers?.first as? TGFeedDetailImageController else { return nil }
        
        let newIndex = currentVC.imageIndex + 1
        guard newIndex > 0, newIndex < (controller.dataModel.pictures.count) else { return nil }
        
        let newController = TGFeedDetailImageController(imageUrlPath: (controller.dataModel.pictures[newIndex].url).orEmpty, imageIndex: newIndex, model: controller.dataModel)
        controller.setGesture(for: newController)
        return newController
    }
}

extension TGFeedContentPageController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = CustomSizePresentationController(presentedViewController: presented, presenting: presenting)
        controller.heightPercent = 0.7
        return controller
    }
}

extension TGFeedContentPageController: CustomPopListProtocol {
    func customPopList(itemType: TGPopUpItem) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.handlePopUpItemAction(itemType: itemType)
        }
    }
    
    func handlePopUpItemAction(itemType: TGPopUpItem) {
        switch itemType {
        case .message:
            // 记录转发数
            self.forwardFeed()
            let messageModel = TGmessagePopModel(momentModel: self.dataModel)
            let vc = TGContactsPickerViewController(model: messageModel, configuration: TGContactsPickerConfig.shareToChatConfig(), finishClosure: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        case .shareExternal:
            // 记录转发数
            self.forwardFeed()
            let messagePopModel = TGmessagePopModel(momentModel: self.dataModel)
            let webServerAddress = RLSDKManager.shared.loginParma?.webServerAddress ?? ""
            let fullUrlString = "\(webServerAddress)feeds/\(String(messagePopModel.feedId))"
            // By Kit Foong (Hide Yippi App from share)
            guard let url = URL(string: fullUrlString) else { return }
            let items: [Any] = [url, messagePopModel.titleSecond, ShareExtensionBlockerItem()]
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        case .save(isSaved: _):
            let isCollect = (self.dataModel.toolModel?.isCollect).orFalse ? false : true
            TGFeedNetworkManager.shared.colloction(isCollect ? 1 : 0, feedIdentity: self.dataModel.idindex, feedItem: self.dataModel) {[weak self] result in
                if result == true {
                    self?.dataModel.toolModel?.isCollect = isCollect
                    DispatchQueue.main.async {
                        if isCollect {
                            self?.showTopFloatingToast(with: "success_save".localized, desc: "")
                        }
                    }
                }
            }

        case .reportPost:
            guard let reportTarget: ReportTargetModel = ReportTargetModel(feedModel: self.dataModel) else { return }
            let reportVC: TGReportViewController = TGReportViewController(reportTarget: reportTarget)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.present(TGNavigationController(rootViewController: reportVC).fullScreenRepresentation,
                             animated: true,
                             completion: nil)
            }
            break
        case .edit:
            let model = self.dataModel
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
            self.showRLDelete(title: "rw_delete_action_title".localized, message: "rw_delete_action_desc".localized, dismissedButtonTitle: "delete".localized, onDismissed: { [weak self] in
                guard let self = self else { return }
                TGFeedNetworkManager.shared.deleteMoment(self.dataModel.idindex) { [weak self] result in
                    guard let self = self else { return }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "feedDelete"), object: nil, userInfo: ["feedId": self.dataModel.idindex])
                    self.onDelete?()
                }

            }, cancelButtonTitle: "cancel".localized)
            break
        case .pinTop(isPinned: let isPinned):
            let feedId = self.dataModel.idindex
            
            let networkManager: (Int, @escaping (String, Int, Bool?) -> Void) -> Void = isPinned ? TGFeedNetworkManager.shared.unpinFeed : TGFeedNetworkManager.shared.pinFeed
            
            networkManager(feedId) {[weak self] errMessage, statusCode, status in
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
                
                self.dataModel.isPinned = newPined
                UIViewController.showBottomFloatingToast(with: newPined ? "feed_pinned".localized : "feed_unpinned".localized, desc: "")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPinnedFeed"), object: nil, userInfo: ["isPinned": !isPinned, "feedId": feedId])
            }
            
            break
        case .comment(isCommentDisabled: let isCommentDisabled):
            let feedId = self.dataModel.idindex
            
            let newValue = self.dataModel.toolModel?.isCommentDisabled ?? true ? 0 : 1
            TGFeedNetworkManager.shared.commentPrivacy(newValue, feedIdentity: feedId) {[weak self] success in
                guard let self = self else { return }
                if success {
                    self.dataModel.toolModel?.isCommentDisabled = newValue == 1
                    DispatchQueue.main.async {
                        if newValue == 1 {
                            self.showTopFloatingToast(with: "disable_comment_success".localized)
                        } else {
                            self.showTopFloatingToast(with: "enable_comment_success".localized)
                           // self.showTopIndicator(status: .success, "enable_comment_success".localized)
                        }
                        self.updateInteractiveView(isEdit: true)
                    }
                }
            }
            break
        default:
            break
        }
    }
}

