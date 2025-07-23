//
//  TGMiniVideoControlVC.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/23.
//

import UIKit
import AliyunPlayer

class TGMiniVideoControlVC: TGViewController, NSURLConnectionDataDelegate {
    
    var control: TGMiniVideoControlView = TGMiniVideoControlView()
    private(set) var model: FeedListCellModel
    var index: Int = 0
    var type: TGFeedListType?
    var onDataChanged: ((FeedListCellModel) -> Void)?
    var isPausedWhenEnterBackground: Bool = false
    var isTranslateText: Bool = false
    var translateHandler: ((Bool) -> Void)?
    var isExpand: Bool = false
    
    init(model: FeedListCellModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.loadControlView()
        NotificationCenter.default.addObserver(self, selector: #selector(showReactionBottomSheet), name: NSNotification.Name.Reaction.show, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.control.coverImageView.setViewHidden(false)
        }
        self.loadFeedData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //开始记录停留时间
        stayBeginTimestamp = Date().timeStamp
        TGMiniVideoListPlayerManager.shared.setPlayerView(self.control.previewView)
        TGMiniVideoListPlayerManager.shared.playWithVideo(self.model)
        TGMiniVideoListPlayerManager.shared.onCurrentPlayStatusUpdateHandler = { [weak self] status in
            // 解决页面图片直接隐藏闪屏的问题
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self else { return }
                if status == AVPStatusError {
                    //音频源文件问题导致播放失败了
                    self.control.coverImageView.setViewHidden(false)
                }else{
                    self.control.coverImageView.setViewHidden(true)
                }
            }
            DispatchQueue.main.async {
                //播放器开始播放
                guard let self = self else { return }
                if status == AVPStatusError {
                    //音频源文件问题导致播放失败了
//                    self.showError(message: "error".localized)
                    self.control.setFeed(self.model,self.isTranslateText,self.isExpand)
                    self.control.hidePlayBtn()
                }
                if status == AVPStatusPaused {
                    self.control.showPlayBtn()
                }else{
                    self.control.hidePlayBtn()
                }
                
            }
        }
        TGMiniVideoListPlayerManager.shared.onCurrentPositionUpdateHandler = { [weak self] position,duration in
            guard let self = self else { return }
            let progress = Float(position)/Float(duration)
            DispatchQueue.main.async {
                if self.control.coverImageView.isHidden == false {
                    self.control.coverImageView.setViewHidden(true)
                }
                self.control.videoDuration = TimeInterval(duration)
                self.control.setProgress(progress)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        control.resetToDefault()
        self.behaviorUserFeedStayData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        print("deinit TGMiniVideoControlVC")
        control.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    var parentVC: TGMiniVideoPageViewController? {
        return (parent as? TGMiniVideoPageViewController)
    }
    func loadFeedData() {
        
        TGFeedNetworkManager.shared.fetchFeedDetailInfo(withFeedId: self.model.idindex.stringValue) {[weak self] feedInfo, error in
            guard let listModel = feedInfo, let self = self else {
                return
            }
            control.setFeed(FeedListCellModel(feedListModel: listModel),self.isTranslateText,self.isExpand)
        }
        
    }
    
    func loadControlView() {
        
        control = TGMiniVideoControlView()
        control.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        self.view.addSubview(control)
        
        //刷新用户关注状态
        if model.userId != RLSDKManager.shared.currentUserInfo?.userIdentity {
            TGUserNetworkingManager.shared.getUserInfo([model.userId]) { info, userInfoModels, error in
                if let status = userInfoModels?.first?.follower {
                    let followstatus: FollowStatus = status == true ? .follow : .unfollow
                    self.updateFollowStatus(followstatus, userId: self.model.userId.stringValue)
                }
            }
        }
        
        control.setFeed(model,self.isTranslateText,self.isExpand)
        control.delegate = self
        
    }
    
    func didEnterBackground() {
        if  TGMiniVideoListPlayerManager.shared.getPlayStatus() == AVPStatusStarted {
            TGMiniVideoListPlayerManager.shared.pause()
            isPausedWhenEnterBackground = true
        }
    }
    
    func enterForeground() {
        if isPausedWhenEnterBackground {
            TGMiniVideoListPlayerManager.shared.play()
            isPausedWhenEnterBackground = false
        }
    }
    
    func onPanAtBottom(sender: UIPanGestureRecognizer) {
        control.panGestureRecognizer(sender)
    }
    
    func updateFollowStatus(_ status: FollowStatus, userId: String) {
        guard userId.toInt() == model.userId else {
            return
        }
        model.userInfo?.follower = status == .follow ? true : false
        control.updateFollowButton(status)
    }
    
    @objc func showReactionBottomSheet() {
        let vc = TGResponsePageController(theme: .white, feed: model, defaultSegment: 1, onToolbarUpdate: self.parentVC?.onToolbarUpdate)
        vc.titleLabel.text = ""
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .custom
        nav.transitioningDelegate = self
        nav.view.backgroundColor = .clear
        self.present(nav, animated: true, completion: nil)
    }
}

extension TGMiniVideoControlVC {
    func behaviorUserFeedStayData() {
        if stayBeginTimestamp != "" {
            stayEndTimestamp = Date().timeStamp
            let stay = stayEndTimestamp.toInt()  - stayBeginTimestamp.toInt()
            if stay > 5 {
                self.stayBeginTimestamp = ""
                self.stayEndTimestamp = ""
                RLSDKManager.shared.feedDelegate?.onTrackEvent(itemId: self.model.idindex.stringValue, itemType: TGItemType.shortvideo.rawValue, behaviorType: TGBehaviorType.stay.rawValue, moduleId: TGModuleId.feed.rawValue, pageId: TGPageId.feed.rawValue, behaviorValue: stay.stringValue, traceInfo: nil)
            }
        }
    }
}

extension TGMiniVideoControlVC: TGMiniVideoControlViewDelegate {
    
    func commentDidTapped(view: TGMiniVideoControlView) {
        
        let vc = TGResponsePageController(theme: .white, feed: model) { [weak self] feed in
            guard let feed = feed as? FeedListCellModel else { return }
            if feed.idindex == self?.model.idindex {
                self?.model = feed
            }
            DispatchQueue.main.async {
                view.updateFeed(feed)
                self?.updateDataSouce(feed)
            }
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .custom
        nav.transitioningDelegate = self
        nav.view.backgroundColor = .clear
        self.present(nav, animated: true, completion: nil)
        RLSDKManager.shared.feedDelegate?.track(event: TGEvent.innerFeedViewClicks, with: ["Clicked": "Comment Btn"])
        
        //上报动态点击事件
        //sceneId: type?.rawValue ?? "",
        RLSDKManager.shared.feedDelegate?.onTrackEvent(itemId: model.idindex.stringValue, itemType: model.feedType == .miniVideo ? TGItemType.shortvideo.rawValue : TGItemType.image.rawValue, behaviorType: TGBehaviorType.click.rawValue, moduleId: TGModuleId.feed.rawValue, pageId: TGPageId.feed.rawValue, behaviorValue: nil, traceInfo: nil)
        
        self.stayBeginTimestamp = ""
        self.stayEndTimestamp = ""
        
    }
    
    func shareDidTapped(view: TGMiniVideoControlView) {
    }
    
    func rewardDidTapped(view: TGMiniVideoControlView) {
//        if model.userInfo?.isMe() == true {
//            let vc = PostTipHistoryTVC(feedId: model.idindex)
//            if let nav = self.navigationController {
//                nav.pushViewController(vc, animated: true)
//            } else {
//                let nav = TSNavigationController(rootViewController: vc)
//                nav.setCloseButton(backImage: true)
//                self.present(nav.fullScreenRepresentation, animated: true, completion: nil)
//            }
//        } else {
//            self.presentTipping(target: model.idindex, type: .moment, theme: .dark) { [weak self] (_, _) in
//                if let tool = self?.model.toolModel {
//                    self?.showSuccess(message: "tip_successful_title".localized)
//
//                    tool.rewardCount += 1
//                    tool.isRewarded = true
//                    self?.model.toolModel = tool
//
//                    if let feed = self?.model {
//                        self?.updateDataSouce(feed)
//                    }
//                }
//            }
//        }
    }
    
    func followDidTapped(view: TGMiniVideoControlView) {
        guard var user = model.userInfo else {
            return
        }
        user.updateFollow(completion: { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil, userInfo: ["follow": user.follower, "userid": "\(user.userIdentity)"])
                    view.updateFollowButton(user.followStatus)
                    if let feed = self?.model {
                        self?.updateDataSouce(feed)
                    }
                }
            }
        })
    }
    
    func profileDidTapped(view: TGMiniVideoControlView) {
//        switch self.type {
//        case .user:
//            if let liveId = model.userInfo?.liveFeedId {
//                self.navigationController?.navigateLive(feedId: liveId)
//            } else {
//                // By Kit Foong (Check if same navigation controller use pop, else use dismiss)
//                if let navController = self.navigationController {
//                    navController.popViewController(animated: true)
//                } else {
//                    // By Kit Foong (This mainly is for user profile gallery)
//                    self.dismiss(animated: true)
//                }
//                //self.navigationController?.popViewController(animated: true)
//            }
//
//        default:
//            guard let user = model.userInfo else {
//                return
//            }
//            if let liveId = user.liveFeedId {
//                self.navigationController?.navigateLive(feedId: liveId)
//            } else {
//                let vc = HomePageViewController(userId: user.userIdentity)
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        }
    }
    
    func reactionsDidSelect(view: TGMiniVideoControlView) {
        
        TGFeedNetworkManager.shared.fetchFeedDetailInfo(withFeedId: "\(model.idindex)") { [weak self] (feedInfo, error) in
          
            DispatchQueue.main.async {
                guard let feedInfo = feedInfo, let weakself = self else {
//                    self?.showTopIndicator(status: .faild, "system_error_msg".localized)
                    return
                }
                let cellModel = FeedListCellModel(feedListModel: feedInfo)
                view.updateReactionList(cellModel)
                
                if weakself.model.idindex == cellModel.idindex {
                    weakself.model = cellModel
                }
                weakself.updateDataSouce(cellModel)
            }
        }
    }
    
    func reactionsListDidTap(view: TGMiniVideoControlView) {
        showReactionBottomSheet()
    }
    
    func controlViewDidTapped(view: TGMiniVideoControlView) {
        if TGMiniVideoListPlayerManager.shared.getPlayStatus() == AVPStatusStarted {
            TGMiniVideoListPlayerManager.shared.pause()
            view.showPlayBtn()
        } else {
            TGMiniVideoListPlayerManager.shared.play()
            view.hidePlayBtn()
        }
    }
    
    func voucherDidTap(view: TGMiniVideoControlView) {
        RLSDKManager.shared.feedDelegate?.didVoucherTouched(voucherId: model.tagVoucher?.taggedVoucherId ?? 0)
    }
    
    func sliderDidChanged(time: TimeInterval) {
        TGMiniVideoListPlayerManager.shared.setSeek(Int64(time) * 1000)
    }
    private func updateDataSouce(_ model: FeedListCellModel) {
        self.parentVC?.onToolbarUpdate?(model)
        self.parentVC?.onDataChanged(model)
    }
    
}

extension TGMiniVideoControlVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = CommentListPresentationController(presentedViewController: presented, presenting: presenting)
        controller.heightPercent = 0.7
        return controller
    }
}
