//
//  TGFeedDetailImagePageController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/20.
//

import UIKit

public enum FeedMediaType: String {
    case image, video
    case miniVideo = "mini-video"
}
public enum InnerFeedConfig {
    case none
    case single(feedId: Int, transitionId: String?, placeholderImage: UIImage?, imageId: Int)
    case preLoadedSingle(data: FeedListCellModel, transitionId: String?, placeholderImage: UIImage?)
    case list(data: [FeedListCellModel], tappedIndex: Int, mediaType: FeedMediaType, listType: TGFeedListType, transitionId: String?, placeholderImage: UIImage?, isClickComment: Bool, isTranslateText: Bool)
}

public class TGFeedDetailImagePageController: UIPageViewController {

    private var verticalPageHandler = PageHandler()
    public var feedType: TGFeedListType {
        switch config {
        case .list(_, _, _, let listType, _, _, _, _): return listType
        default: return .hot
        }
    }
    private var mediaType: FeedMediaType {
        switch config {
        case .list(_, _, let mediaType, _, _, _, _, _): return mediaType
        default: return .image
        }
    }
    
    private var networkOngoing = false
    private var currentVC: TGFeedContentPageController? {
        return self.viewControllers?.first as? TGFeedContentPageController
    }
    
    private var config: InnerFeedConfig = .none
    
    /// (index, return transition id)
    var completeHandler: ((Int, String) -> Void)?
    var onToolbarUpdated: onToolbarUpdate?
    var translateHandler: ((Bool) -> Void)?
    public var onRefresh: TGEmptyClosure?
    public var userId: Int? = nil
    public var afterTime: String? = ""
    public var isControllerPush: Bool?
    public var campaignId: String = ""
    public var hashtagId: String = ""
    var tagVoucher: TagVoucherModel?
    var isExpand: Bool = false
    
    private(set) var datasource = [FeedListCellModel]()
    private var closeButton = UIImageView(image: UIImage(named: "iconsArrowCaretleftWhite")).configure { (v) -> () in
        v.contentMode = .scaleAspectFit
    }
    
//    private let loadPlaceholder = PlaceHolderView(
//        offset: TSUserInterfacePrinciples.share.getTSNavigationBarHeight(), heading: "", detail: "", lottieName: "feed-loading", theme: .dark).build { (v) in
//            v.isHidden = true
//        }
    let navigationDelegate = TGCustomNavigationDelegate()
    
    public override var prefersStatusBarHidden: Bool {
        // 返回当前状态栏的可见性
        return UIApplication.shared.isStatusBarHidden
    }
    
    public init(config: InnerFeedConfig, campaignId: String = "", hashtagId: String = "", completeHandler: ((Int, String) -> Void)? = nil, onToolbarUpdated: onToolbarUpdate?, translateHandler: ((Bool) -> Void)? = nil, tagVoucher: TagVoucherModel? = nil, isExpand: Bool = false) {
        
        super.init(transitionStyle: .scroll, navigationOrientation: .vertical)
        
        self.completeHandler = completeHandler
        self.config = config
        self.onToolbarUpdated = onToolbarUpdated
        self.translateHandler = translateHandler

        self.campaignId = campaignId
        self.hashtagId = hashtagId

        self.tagVoucher = tagVoucher

        self.isExpand = isExpand
        
        switch config {
        case .none: break
            
        case .single:
//            verticalPageHandler.controller = nil
            break
            
        case let .preLoadedSingle(data, transitionId, placeholderImage):
            weak var wself = self
            let dest = TGFeedContentPageController(currentIndex: 0,
                                                 dataModel: data,
                                                 imageIndex: 0, placeholderImage: placeholderImage,
                                                 transitionId: transitionId,
                                                 onRefresh: wself?.refresh,
                                                 onLoadMore: { [weak self] in
                self?.onLoadMore()
                self?.fetchPage()
            }, onToolbarUpdated: nil,
                                                 onIndexUpdate: { [weak self] (index, transitionId) in
                self?.completeHandler?(index, transitionId)
                self?.updateNavigationDelegate(index: index)
            }, onTapHiddenUpdate: { [weak self] (isHidden) in
                self?.toggleStatusBar(isHidden)
            }
                                                 
            )
            datasource = [data]
            dest.onDelete = {
            
                if self.isModal == true && self.isControllerPush == nil  {
                    self.onRefresh?()
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                }

            }
            dest.type = self.feedType
            dest.loadGestureEnabled = false
            self.setViewControllers([dest], direction: .forward, animated: false)
            verticalPageHandler.controller = nil
            
        case let .list(data, tappedIndex, _, _, transitionId, placeholderImage, isClickComment, isTranslateText):
            guard data.count > 0 else { return }
            weak var wself = self
            datasource = [data.last!]
            userId = data.last?.userId
            let dest = TGFeedContentPageController(currentIndex: 0,
                                                 dataModel: data.first!,
                                                 imageIndex: tappedIndex, placeholderImage: placeholderImage,
                                                 transitionId: transitionId,
                                                 isClickComment: isClickComment,
                                                 isTranslateText: isTranslateText,
                                                 onRefresh: wself?.refresh,
                                                 onLoadMore: { [weak self] in
                                                    self?.onLoadMore()
                                                    self?.fetchPage()
                                                 }, onToolbarUpdated: wself?.onToolbarUpdated,
                                                 onIndexUpdate: { [weak self] (index, transitionId) in
                                                    self?.completeHandler?(index, transitionId)
                                                    self?.updateNavigationDelegate(index: index)
                                                }, translateHandler: wself?.translateHandler, onTapHiddenUpdate: { [weak self] (isHidden) in
                                                    self?.toggleStatusBar(isHidden)
                                                })
            dest.type = self.feedType
            dest.loadGestureEnabled = true
            dest.onDelete = {
                if self.isModal == true && self.isControllerPush == nil  {
                    self.onRefresh?()
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            self.setViewControllers([dest], direction: .forward, animated: false)
            fetchPage()
            verticalPageHandler.controller = self
        }
    }
    
    func updateNavigationDelegate(index: Int) {
        guard let currentVC = currentVC else {
            return
        }
    }
    // 点击按钮时切换状态栏的可见性
    @objc func toggleStatusBar(_ isHidden: Bool) {
        self.closeButton.isHidden = isHidden
        UIApplication.shared.isStatusBarHidden.toggle()
     }
    func onLoadMore() {
        guard networkOngoing == false else { return }
//        let bottomView = ContentPageBottomView(bgColor: UIColor.darkGray.withAlphaComponent(0.5),
//                                               textColor: .white, text: "load_more".localized)
//        self.showBottomFloatingView(with: bottomView, displayDuration: 1.0, allowTouch: true)
//        bottomView.start()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        

        view.backgroundColor = .black
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { v in
            v.top.equalToSuperview().inset(RLUserInterfacePrinciples.share.getTSStatusBarHeight() + 16)
            v.left.equalToSuperview().inset(16)
            v.height.equalTo(32)
        }
        
        closeButton.addTap { [weak self] (_) in
            if self?.isModal == true && self?.isControllerPush == nil  {
                self?.dismiss(animated: true)
            } else {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
//        view.addSubview(loadPlaceholder)
//        loadPlaceholder.bindToEdges()
        
        switch config {
        case let .single(feedId, transitionId, placeholderImage, imageId):
            self.showLoading()
            self.loadPage(id: feedId, transitionId: transitionId, placeholderImage: placeholderImage) { [weak self] (data, error) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.hideLoading()
                    if let data = data {
                        let index = data.pictures.firstIndex(where: { $0.file == imageId })
                        let destination = TGFeedContentPageController(currentIndex: 0,
                                                                    dataModel: data,
                                                                    imageIndex: index.orZero,
                                                                    placeholderImage: placeholderImage,
                                                                    transitionId: transitionId,
                                                                    onRefresh: nil,
                                                                    onLoadMore: nil,
                                                                    onToolbarUpdated: nil, onIndexUpdate: { [weak self] (index, transitionId) in
                                                                        //                                                                        self?.completeHandler?(index, transitionId)
                                                                        self?.updateNavigationDelegate(index: index)
                                                                    }, onTapHiddenUpdate: { [weak self] (isHidden) in
                                                                        self?.toggleStatusBar(isHidden)
                                                                    })
                        destination.onDelete = {
                            if self.isModal == true && self.isControllerPush == nil  {
                                self.onRefresh?()
                                self.dismiss(animated: true, completion: nil)
                            } else {
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                        destination.loadGestureEnabled = false
                        self.datasource.append(data)
                        self.setViewControllers([destination], direction: .forward, animated: false, completion: nil)
                        self.updateNavigationDelegate(index: index.orZero)
                    }
                }
            }
            
        default: break
        }
        
        navigationController?.delegate = navigationDelegate
        navigationDelegate.addEdgePushInteractionController(to: self.view, delegate: self)
        
        if tagVoucher?.taggedVoucherId != nil && tagVoucher?.taggedVoucherId != 0 {
            self.currentVC?.interactiveView.voucherBottomView.isHidden = false
            self.currentVC?.interactiveView.voucherBottomView.voucherLabel.text = tagVoucher?.taggedVoucherTitle ?? ""
        } else {
            self.currentVC?.interactiveView.voucherBottomView.isHidden = true
        }
    }
    
    private func loadPage(id: Int, transitionId: String?, placeholderImage: UIImage?, complete: ((_ data: FeedListCellModel?, _ error: Error?) -> Void)?) {
        
        
        TGFeedNetworkManager.shared.fetchFeedDetailInfo(withFeedId: "\(id)") { (feedInfo, error) in
            guard let listModel = feedInfo else {
                complete?(nil, error)
                return
            }
            
            let cellModel = FeedListCellModel(feedListModel: listModel)
            print(cellModel)
            complete?(cellModel, error)
        }
    }
    
    private func showLoading() {
//        view.bringSubviewToFront(loadPlaceholder)
//        view.bringSubviewToFront(closeButton)
//        UIView.animate(withDuration: 0.2) {
//            self.loadPlaceholder.isHidden = false
//        }
//        loadPlaceholder.play()
    }
    
    private func hideLoading() {
//        view.bringSubviewToFront(loadPlaceholder)
//        UIView.animate(withDuration: 0.2) {
//            self.loadPlaceholder.isHidden = true
//        }
//
//        loadPlaceholder.play()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        if self.currentVC?.isClickComment == true {
            self.currentVC?.openCommentView()
        }
        
//        navigationDelegate.pushDestination = { [weak self] in
//            guard let self = self, let userId = self.currentVC?.dataModel.userId else {
//                return nil
//            }
//            let vc = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "HomePageViewController") as! HomePageViewController
//            vc.model = HomepageModel(userIdentity: userId)
//            return vc
//
//        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setClearNavBar()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        setWhiteNavBar()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func fetchPage(refresh: Bool = false) {
        guard networkOngoing == false else {
            return
        }
        networkOngoing = true
        verticalPageHandler.controller = nil
        
        let index = refresh == true ? nil : self.datasource.last?.idindex
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            TGFeedNetworkManager.shared.getFeeds(mediaType: self.mediaType, feedType: self.feedType, after: index, afterTime: afterTime, campaignId: campaignId, hashtagId: hashtagId) { [weak self] (resultsModel, errorMessage) in
                defer {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.networkOngoing = false
                    }
                    self?.verticalPageHandler.controller = self
                }
                guard let self = self else { return }
                guard let models = resultsModel else {
                    DispatchQueue.main.async {  self.refreshComplete() }
                    return
                }
                if refresh {
                    self.datasource = models
                } else {
                    self.datasource.append(contentsOf: models)
                }
                afterTime = models.last?.afterTime
                self.verticalPageHandler.resetPage()
                
                if refresh == true {
                    DispatchQueue.main.async {  self.refreshComplete() }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.currentVC?.isLast = false
                        
                        if self.currentVC?.isClickComment == false {
//                            self.dismisSwiftyEntry()
                        }
                    }
                }
            }
        }
        
        func onError(message: String) {
            UIViewController.showBottomFloatingToast(with: "error_occur".localized, desc: message)
        }
    }
    
    func refreshComplete() {
        guard datasource.count > 0 else { return }
        let vc = TGFeedContentPageController(currentIndex: 0,
                                           dataModel: datasource.first!,
                                           imageIndex: 0, placeholderImage: nil,
                                           onRefresh: refresh,
                                           onLoadMore: { [weak self] in
            self?.onLoadMore()
            self?.fetchPage()
            
        }, onToolbarUpdated: self.onToolbarUpdated, onIndexUpdate: { [weak self] (index, transitionId) in
            self?.completeHandler?(index, transitionId)
            self?.updateNavigationDelegate(index: index)}, onTapHiddenUpdate: { [weak self] (isHidden) in
                self?.toggleStatusBar(isHidden)
            }
        )
        vc.onDelete = {
            if self.isModal == true && self.isControllerPush == nil  {
                self.onRefresh?()
                self.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        self.setViewControllers([vc], direction: .forward, animated: false)
        fetchPage()
    }
    
    func refresh() {
        fetchPage(refresh: true)
    }

}
private class PageHandler: NSObject, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    weak var controller: TGFeedDetailImagePageController? {
        willSet {
            if newValue == nil {
                controller?.dataSource = nil
                controller?.delegate = nil
            }
        }
        didSet {
            controller?.delegate = self
            controller?.dataSource = self
        }
    }
    
    func resetPage() {
        controller?.dataSource = nil
        controller?.dataSource = self
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let controller = controller else { return nil }
        guard let currentVC = pageViewController.viewControllers?.first as? TGFeedContentPageController else { return nil }
        let index = currentVC.currentIndex
        let indexBefore = index - 1
        
        guard indexBefore >= 0 else { return nil }
        let dest = TGFeedContentPageController(currentIndex: indexBefore, dataModel: controller.datasource[indexBefore],
                                             placeholderImage: nil, onRefresh: controller.refresh,
                                             onLoadMore: {
            controller.onLoadMore()
            controller.fetchPage()
        }, onToolbarUpdated: controller.onToolbarUpdated, onIndexUpdate: { (index, transitionId) in
            controller.completeHandler?(index, transitionId)
            controller.updateNavigationDelegate(index: index)
        })
        dest.type = controller.feedType
        return dest
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let controller = controller else {
            return nil
        }
        guard let currentVC = pageViewController.viewControllers?.first as? TGFeedContentPageController else {
            return nil
        }
        let index = currentVC.currentIndex
        let indexAfter = index + 1
        
        guard indexAfter > 0, indexAfter < controller.datasource.count else {
            return nil
        }
        let nextPage = TGFeedContentPageController(currentIndex: indexAfter, dataModel: controller.datasource[indexAfter],
                                                 placeholderImage: nil, onRefresh: controller.refresh,
                                                 onLoadMore: {
                                                    controller.onLoadMore()
                                                    controller.fetchPage()
                                                 }, onToolbarUpdated: self.controller?.onToolbarUpdated, onIndexUpdate: { [weak self] (index, transitionId) in
                                                    self?.controller?.completeHandler?(index, transitionId)
                                                    self?.controller?.updateNavigationDelegate(index: index)
                                                 })
        nextPage.onDelete = {
            if controller.isModal == true && controller.isControllerPush == nil  {
                controller.onRefresh?()
                controller.dismiss(animated: true, completion: nil)
            } else {
                controller.navigationController?.popToRootViewController(animated: true)
            }
            
        }
        nextPage.type = controller.feedType
        nextPage.isLast = (indexAfter == controller.datasource.count - 1)
        return nextPage
    }
}

extension TGFeedDetailImagePageController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
