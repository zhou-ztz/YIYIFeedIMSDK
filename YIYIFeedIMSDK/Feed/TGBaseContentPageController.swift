//
//  TGBaseContentPageController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/20.
//

import UIKit

class TGBaseContentPageController: UIPageViewController, UIGestureRecognizerDelegate {

    var currentIndex = 0
    var isLast = false
    let refreshView = TGRefreshView(frame: .zero)
    let refreshThreshold: CGFloat = 80.0
    let pullupThreshold: CGFloat = 80.0
    private(set) lazy var refreshGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleRefreshPanGesture))
        return gesture
    }()
    var onRefresh: EmptyClosure?
    var onLoadMore: EmptyClosure?
    var interactionController: UIPercentDrivenInteractiveTransition?
    var pushDestination: (() -> UIViewController?)?
    var beginPoint: CGPoint = .zero
    var isVerticalDragging: Bool = false
    var isDragging: Bool = false
    var disablePanAtBottom: Bool = false
    private let tutorialView = TGTutorialView()
    
    var loadGestureEnabled: Bool = true {
        willSet {
            if newValue {
                view.addGestureRecognizer(refreshGesture)
                refreshGesture.delegate = self
            } else {
                view.gestureRecognizers?.forEach({ (g) in
                    if refreshGesture == g {
                        view.removeGestureRecognizer(refreshGesture)
                    }
                })
                refreshGesture.delegate = nil
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard currentIndex == 0 || isLast else { return }
        view.addSubview(refreshView)
        refreshView.snp.makeConstraints { v in
            v.centerX.equalToSuperview()
            v.width.equalToSuperview()
            v.top.equalToSuperview().inset(RLUserInterfacePrinciples.share.getTSStatusBarHeight() + 12)
        }

        if loadGestureEnabled {
            view.addGestureRecognizer(refreshGesture)
            refreshGesture.delegate = self
        }
        
        if UserDefaults.isInnerFeedTutorialHide == false {
            view.addSubview(tutorialView)
            tutorialView.bindToEdges()
            tutorialView.onDismiss = {
                UserDefaults.isInnerFeedTutorialHide = true
            }
        }
        
        self.navigationController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.tutorialView.play()
        }
    }
    
    @objc func handleRefreshPanGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        if tutorialView.superview != nil {
            tutorialView.stop()
        }
        
        if !isDragging {
            isDragging = true
            isVerticalDragging = abs(velocity.y) > abs(velocity.x)
        }
        
        if isVerticalDragging {
            guard translation.y >= 0 else {
                if isLast {
                    handlePullUp(sender: sender, translation: translation)
                }
                return
            }

            handleRefreshGesture(sender: sender, translation: translation)
        } else {
            // zhi  处理关闭小视频右滑进入个人主页
            if velocity.x >= 0 {
                return
            }
            handleProfileGesture(sender: sender, translation: translation)
        }
    }

    private func handlePullUp(sender: UIPanGestureRecognizer,translation: CGPoint) {
        let percentage = translation.y / refreshThreshold * 100.0
        let progressRatio = max(min(percentage, 100), 0) / 100.0

        switch sender.state {
        case .began: break
        case .changed: break
        case .ended:
            isDragging = false
            isVerticalDragging = false
            if progressRatio < 0.8 {
                onLoadMore?()
            }
        default: break
        }
    }

    private func handleRefreshGesture(sender: UIPanGestureRecognizer, translation: CGPoint) {
        let percentage = translation.y / refreshThreshold * 100.0
        let progressRatio = max(min(percentage, 100), 0) / 100.0

        switch sender.state {
        case .began:
            refreshView.isHidden = false
            
        case .changed:
            refreshView.setProgress(percentage: progressRatio)
            refreshViewOnChanged(progressRatio: progressRatio)

        case .ended:
            self.refreshView.lottieView.play()
            isDragging = false
            isVerticalDragging = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if progressRatio < 0.8 {
                    self.finishRefresh()
                } else {
                    self.onRefresh?()
                }
            }

        default: break
        }
    }

    private func handleProfileGesture(sender: UIPanGestureRecognizer, translation: CGPoint) {
        guard let pushDestination = pushDestination else { return }

        let position = sender.translation(in: nil)
        let percentComplete = min(-position.x / sender.view!.bounds.width, 1.0)
        
        if disablePanAtBottom {
            let point = sender.location(in: nil)
            if point.y > UIScreen.main.bounds.height * 0.7 {
                self.onPanAtBottom(sender: sender)
                return
            }
        }
        
        switch sender.state {
        case .began:
            self.beginPoint = position
            interactionController = UIPercentDrivenInteractiveTransition()
            guard let controller = pushDestination() else { fatalError("No push destination") }
            guard self.navigationController?.viewControllers.contains(controller) == false else {
                return
            }
            self.navigationController?.pushViewController(controller, animated: true)
            interactionController?.pause()

        case .changed:
            let dx = abs(beginPoint.x - position.x)
            let dy = abs(beginPoint.y - position.y) * 1.2
            
            if dx > dy {
                interactionController?.update(percentComplete)
            }

        case .ended, .cancelled:
            let dx = abs(beginPoint.x - position.x)
            let dy = abs(beginPoint.y - position.y) * 1.2
            let speed = sender.velocity(in: sender.view)
            if (speed.x < 0 || (speed.x == 0 && percentComplete > 0.5)) && dx > dy {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
            isDragging = false

        default:
            break
        }
    }
    
    func startPagination() {

    }

    func refreshViewOnChanged(progressRatio: CGFloat) {}

    func finishRefresh() {}

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == refreshGesture {
            let translation = (gestureRecognizer as! UIPanGestureRecognizer).translation(in: view)
            guard translation.y < 0 || isLast else {
                return false
            }
        }
        return true
    }

    func onPanAtBottom(sender: UIPanGestureRecognizer) {}
}

extension TGBaseContentPageController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomNavigationAnimator(transitionType: operation)
    }
}

extension TGBaseContentPageController {
    
    /// 处理对于动态的一些配置
    /// - Parameters:
    ///   - detailModel: 动态内容
    ///   - releasePulseVC: vc视图
    /// - Returns:
    func configureReleasePulseViewController(detailModel: FeedListCellModel, releasePulseVC: TGReleasePulseViewController) -> TGReleasePulseViewController{
        //分享类型 - 所有人、朋友、我
        if let privacyType = PrivacyType(rawValue: detailModel.privacy) {
            releasePulseVC.rejectPrivacyType = privacyType
        }
        //话题
        if detailModel.topics.count > 0 {
            let topic = TGTopicCommonModel()
            topic.id = detailModel.topics[0].topicId
            topic.name = detailModel.topics[0].topicTitle
            releasePulseVC.topics = [topic]
        }
        //位置签到
        if let loc = detailModel.location {
            let location = TGLocationModel()
            location.locationID = loc.locationID
            location.locationName = loc.locationName
            location.locationLatitude = loc.locationLatitude
            location.locationLongtitude = loc.locationLongtitude
            location.address = loc.address ?? ""
            releasePulseVC.rejectLocation = location
        }
        // Tagged 用户
        let users = detailModel.tagUsers
        releasePulseVC.selectedUsers = users
        
        // 标记 merchant 用户
        let tagMerchants = detailModel.rewardsLinkMerchantUsers
        releasePulseVC.selectedMerchants = tagMerchants
        
        return releasePulseVC
    }
    
}
