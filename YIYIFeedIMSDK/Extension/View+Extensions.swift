//
//  View+Extensions.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/2/7.
//

import Foundation
import UIKit
import SwiftEntryKit
import SnapKit

extension UIView {
    
    private func animate(start: Bool, margin:Bool = false, background:Bool = false, duration: Double = 2.0) {
        if background {
            
            let colorLayer = CALayer()
            colorLayer.backgroundColor = UIColor(white: 0.90, alpha: 1).cgColor
            if margin {
                colorLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height-5)
            } else {
                colorLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
            }
            colorLayer.name = "colorLayer"
            self.layer.addSublayer(colorLayer)
            self.autoresizesSubviews = true
            self.clipsToBounds = true
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor(white: 0.90, alpha: 1).cgColor,
                                    UIColor(white: 0.94, alpha: 1).cgColor,
                                    UIColor(white: 0.90, alpha: 1).cgColor]
            gradientLayer.locations = [0,0.4,0.8, 1]
            gradientLayer.name = "loaderLayer"
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            if margin {
                gradientLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height-5)
            } else {
                gradientLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
            }
            self.layer.addSublayer(gradientLayer)
            
            let animation = CABasicAnimation(keyPath: "transform.translation.x")
            animation.duration = duration
            animation.fromValue = -self.frame.width
            animation.toValue = self.frame.width
            animation.repeatCount = Float.infinity
            gradientLayer.add(animation, forKey: "smartLoader")
            
        } else {
            
            let light = UIColor(white: 0, alpha: 0.6).cgColor
            let dark = UIColor.black.cgColor
            
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.colors = [dark, light, dark]
            gradient.frame = CGRect(x: -self.bounds.size.width, y: 0, width: 3*self.bounds.size.width, height: self.bounds.size.height)
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.525)
            gradient.locations = [0.3, 0.5, 0.7]
            gradient.name = "shimmerLayer"
            self.layer.mask = gradient
            
            let animation: CABasicAnimation = CABasicAnimation(keyPath: "locations")
            animation.fromValue = [0.0, 0.1, 0.2]
            animation.toValue = [0.8, 0.9, 1.0]
            
            animation.duration = 1.5
            animation.repeatCount = Float.infinity
            animation.isRemovedOnCompletion = false
            
            gradient.add(animation, forKey: "shimmer")
        }
    }
    
    static var topToastAttributes: EKAttributes {
        var attributes = EKAttributes.topFloat
        attributes.hapticFeedbackType = .success
        attributes.entryBackground = .color(color: EKColor(UIColor.white))
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        attributes.displayDuration = 3
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        
        return attributes
    }
    
    static var topNoteAttributes: EKAttributes {
        var attributes = EKAttributes.topNote
        attributes.hapticFeedbackType = .success
        attributes.entryBackground = .color(color: EKColor(UIColor.white))
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        attributes.displayDuration = 3
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        
        return attributes
    }
    
    static var bottomToastAttributes: EKAttributes {
        var attributes = EKAttributes.bottomFloat
        attributes.hapticFeedbackType = .success
        attributes.entryBackground = .color(color: EKColor(UIColor.white))
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        //        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        attributes.scroll = .disabled
        attributes.displayDuration = 3
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        
        return attributes
    }
    
    static var alertAttributes: EKAttributes {
        var attributes = EKAttributes.centerFloat
        attributes.hapticFeedbackType = .success
        attributes.displayDuration = .infinity
        attributes.entryBackground = .color(color: EKColor(UIColor.white))
        attributes.screenBackground = .color(color: EKColor(RLColor.share.lightGray.withAlphaComponent(0.5)))
        attributes.shadow = .active(with: .init(color: EKColor(UIColor.black), opacity: 0.3, radius: 8))
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.roundCorners = .all(radius: 8)
        attributes.entranceAnimation = .init(translate: .init(duration: 0.7, spring: .init(damping: 0.7, initialVelocity: 0)),
                                             scale: .init(from: 0.7, to: 1, duration: 0.4, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.exitAnimation = .init(translate: .init(duration: 0.2))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.35)))
        attributes.positionConstraints.size = .init(width: .offset(value: 20), height: .intrinsic)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.minEdge), height: .intrinsic)
        attributes.statusBar = .dark
        
        return attributes
    }
    
    static var bottomAlertAttributes: EKAttributes {
        var attributes = EKAttributes.bottomFloat
        attributes.hapticFeedbackType = .success
        attributes.displayDuration = .infinity
        attributes.entryBackground = .color(color: .white)
        attributes.screenBackground = .color(color: EKColor(RLColor.share.lightGray.withAlphaComponent(0.5)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.roundCorners = .top(radius: 25)
        attributes.entranceAnimation = .init(translate: .init(duration: 0.7, spring: .init(damping: 1, initialVelocity: 0)),
                                             scale: .init(from: 1.05, to: 1, duration: 0.3, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.exitAnimation = .init(translate: .init(duration: 0.2))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.2)))
        attributes.positionConstraints.verticalOffset = 10
        attributes.positionConstraints.size = .init(width: .offset(value: 20), height: .constant(value: UIScreen.main.minEdge))
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.minEdge), height: .constant(value: UIScreen.main.minEdge))
        attributes.statusBar = .dark
        
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        
        return attributes
    }
}

fileprivate let overlayViewTag = 999
fileprivate let activityIndicatorTag = 1000

extension UIViewController {
    public func displayActivityIndicator(shouldDisplay: Bool) -> Void {
        if shouldDisplay {
            setActivityIndicator()
        } else {
            removeActivityIndicator()
        }
        self.view.layoutIfNeeded()
    }
    
    private func setActivityIndicator() -> Void {
        guard !isDisplayingActivityIndicatorOverlay() else { return }
        guard let parentViewForOverlay = navigationController?.view ?? view else { return }
        
        //configure overlay
        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.black
        overlay.alpha = 0.5
        overlay.tag = overlayViewTag
        
        //configure activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.tag = activityIndicatorTag
        
        //add subviews
        overlay.addSubview(activityIndicator)
        parentViewForOverlay.addSubview(overlay)
        
        //add overlay constraints
        overlay.heightAnchor.constraint(equalTo: parentViewForOverlay.heightAnchor).isActive = true
        overlay.widthAnchor.constraint(equalTo: parentViewForOverlay.widthAnchor).isActive = true
        
        //add indicator constraints
        activityIndicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor).isActive = true
        
        //animate indicator
        activityIndicator.startAnimating()
    }
    
    private func removeActivityIndicator() -> Void {
        let activityIndicator = getActivityIndicator()
        
        if let overlayView = getOverlayView() {
            UIView.animate(withDuration: 0.2, animations: {
                overlayView.alpha = 0.0
                activityIndicator?.stopAnimating()
            }) { (finished) in
                activityIndicator?.removeFromSuperview()
                overlayView.removeFromSuperview()
            }
        }
    }
    
    private func isDisplayingActivityIndicatorOverlay() -> Bool {
        if let _ = getActivityIndicator(), let _ = getOverlayView() {
            return true
        }
        return false
    }
    
    private func getActivityIndicator() -> UIActivityIndicatorView? {
        return (navigationController?.view.viewWithTag(activityIndicatorTag) ?? view.viewWithTag(activityIndicatorTag)) as? UIActivityIndicatorView
    }
    
    private func getOverlayView() -> UIView? {
        return navigationController?.view.viewWithTag(overlayViewTag) ?? view.viewWithTag(overlayViewTag)
    }
}
