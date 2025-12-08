//
//  TGInteractivePanTransitionHandler.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/10/27.
//

import UIKit

class TGInteractivePanTransitionHandler: NSObject {
    private weak var navigationController: UINavigationController?
    private weak var viewController: UIViewController?
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    private var interactionController: UIPercentDrivenInteractiveTransition?
    
    private var pushProvider: (() -> UIViewController?)?
    private var customPopHandler: (() -> Void)?
    
    private var isPushing = false
    private var hasStarted = false
    
    private var panStartTime: CFTimeInterval = 0
    private let requiredHoldDuration: CFTimeInterval = 0.2
    private var hasTriggeredHoldPan = false
    // 通过present方式打开的页面有可能和原有dismiss手势冲突，所以这里加个属性判断是否需要启用dismiss
    private var allowDismiss: Bool
    
    init(
        attachTo view: UIView,
        navigationController: UINavigationController?,
        viewController: UIViewController?,
        pushProvider: (() -> UIViewController?)? = nil,
        customPopHandler: (() -> Void)? = nil,
        allowDismiss: Bool = true
    ) {
        self.allowDismiss = allowDismiss
        super.init()
        self.navigationController = navigationController
        self.viewController = viewController
        self.pushProvider = pushProvider
        self.customPopHandler = customPopHandler
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
        
        navigationController?.delegate = self
        viewController?.transitioningDelegate = self
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }

        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        let now = CACurrentMediaTime()

        switch gesture.state {
        case .began:
            panStartTime = now
            hasTriggeredHoldPan = false
            hasStarted = false

        case .changed:
            // 🕒 Wait for hold before beginning
            if !hasTriggeredHoldPan && (now - panStartTime) >= requiredHoldDuration {
                hasTriggeredHoldPan = true
                isPushing = translation.x < 0
                hasStarted = true
                interactionController = UIPercentDrivenInteractiveTransition()

                if isPushing {
                    if let vc = pushProvider?() {
                        navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    if let nav = navigationController, nav.viewControllers.count > 1 {
                        nav.popViewController(animated: true, completion: {
                            self.customPopHandler?()
                        })
                    } else if allowDismiss, let vc = viewController, vc.presentingViewController != nil {
                        vc.dismiss(animated: true, completion: {
                            self.customPopHandler?()
                        })
                    } else {
                        customPopHandler?()
                    }
                }
            }

            if hasTriggeredHoldPan {
                let progress = isPushing
                    ? min(max(-translation.x / view.bounds.width, 0), 1)
                    : min(max(translation.x / view.bounds.width, 0), 1)
                interactionController?.update(progress)
            }

        case .ended, .cancelled:
            if hasTriggeredHoldPan {
                let shouldFinish = isPushing
                    ? (-translation.x > view.bounds.width * 0.3 || velocity.x < -1000)
                    : (translation.x > view.bounds.width * 0.3 || velocity.x > 1000)

                if shouldFinish {
                    interactionController?.finish()
                } else {
                    interactionController?.cancel()
                }
            }

            hasStarted = false
            hasTriggeredHoldPan = false
            interactionController = nil

        default:
            break
        }
    }

    private func findChildScrollView(in view: UIView) -> UIScrollView? {
        if let scrollView = view as? UIScrollView {
            return scrollView
        }
        for subview in view.subviews {
            if let found = findChildScrollView(in: subview) {
                return found
            }
        }
        return nil
    }
}

// MARK: - UIGestureRecognizerDelegate
extension TGInteractivePanTransitionHandler: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer,
              let view = pan.view else { return false }

        let velocity = pan.velocity(in: view)
        let translation = pan.translation(in: view)

        let isHorizontalPan = abs(velocity.x) > abs(velocity.y)
        if !isHorizontalPan { return false }

        // ✅ Ignore fast flicks (normal scrolls)
        if abs(velocity.x) > 400 {
            return false
        }

        // ✅ Ignore accidental tiny drags
        if abs(translation.x) < 10 {
            return false
        }

        // ✅ Only begin if held long enough
        let now = CACurrentMediaTime()
        if now - panStartTime < requiredHoldDuration {
            return false
        }

        // ✅ Only trigger if at scrollView edge
        guard let scrollView = findChildScrollView(in: view) else { return true }

        if scrollView.isDragging || scrollView.isDecelerating { return false }

        let offsetX = scrollView.contentOffset.x
        let maxOffsetX = scrollView.contentSize.width - scrollView.bounds.width
        let edgeMargin: CGFloat = 2.0

        if velocity.x > 0 {
            return offsetX <= edgeMargin // pop
        } else {
            return offsetX >= maxOffsetX - edgeMargin // push
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let view = gestureRecognizer.view else { return false }

        if gestureRecognizer == panGestureRecognizer,
           let scrollView = findChildScrollView(in: view),
           otherGestureRecognizer.view?.isDescendant(of: scrollView) == true {
            return true
        }
        return false
    }
}

// MARK: - UINavigationControllerDelegate
extension TGInteractivePanTransitionHandler: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning)
    -> UIViewControllerInteractiveTransitioning? {
        hasStarted ? interactionController : nil
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController)
    -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push: return PushAnimator()
        case .pop: return PopAnimator()
        default: return nil
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate (for modal)
extension TGInteractivePanTransitionHandler: UIViewControllerTransitioningDelegate {
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning)
    -> UIViewControllerInteractiveTransitioning? {
        hasStarted ? interactionController : nil
    }
    
    func animationController(forDismissed dismissed: UIViewController)
    -> UIViewControllerAnimatedTransitioning? {
        PopAnimator()
    }
}

// MARK: - Push Animator
class PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval { 0.35 }
    
    func animateTransition(using context: UIViewControllerContextTransitioning) {
        guard let fromVC = context.viewController(forKey: .from),
              let toVC = context.viewController(forKey: .to) else {
            context.completeTransition(false)
            return
        }
        
        let container = context.containerView
        let finalFrame = context.finalFrame(for: toVC)
        toVC.view.frame = finalFrame.offsetBy(dx: container.bounds.width, dy: 0)
        container.addSubview(toVC.view)
        
        UIView.animate(withDuration: 0.35, animations: {
            toVC.view.frame = finalFrame
            fromVC.view.alpha = 0.8
        }) { _ in
            fromVC.view.alpha = 1.0
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
}

// MARK: - Pop/Dismiss Animator
class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval { 0.35 }
    
    func animateTransition(using context: UIViewControllerContextTransitioning) {
        guard let fromVC = context.viewController(forKey: .from),
              let toVC = context.viewController(forKey: .to) else {
            context.completeTransition(false)
            return
        }

        let container = context.containerView
        let finalFrame = context.finalFrame(for: toVC)

        // ✅ Force tab bar hidden during transition
        toVC.tabBarController?.tabBar.isHidden = true

        toVC.view.frame = finalFrame
        container.insertSubview(toVC.view, belowSubview: fromVC.view)

        UIView.animate(withDuration: transitionDuration(using: context), animations: {
            fromVC.view.frame = fromVC.view.frame.offsetBy(dx: container.bounds.width, dy: 0)
        }) { _ in
            // ✅ Restore tab bar state
            if let nav = toVC.navigationController,
                toVC == nav.viewControllers.first {
                toVC.tabBarController?.tabBar.isHidden = false
            }
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
}
extension TGInteractivePanTransitionHandler {
    
    func attach(to view: UIView, navigationController: UINavigationController?, viewController: UIViewController?) {
        // 先确保不重复
        panGestureRecognizer.view?.removeGestureRecognizer(panGestureRecognizer)
        self.navigationController = navigationController
        self.viewController = viewController
        view.addGestureRecognizer(panGestureRecognizer)
        navigationController?.delegate = self
        viewController?.transitioningDelegate = self
    }
}
