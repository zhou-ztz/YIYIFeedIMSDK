//
//  UIViewController+Extension.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司 on 2024/1/5.
//

import Foundation
import UIKit
import Photos
import SwiftEntryKit

typealias EmptyClosure = () -> Void


extension UIViewController {
    
    
    /// 打开照相机视图
    /// - Parameters:
    ///   - enableMultiplePhoto: 是否多图
    ///   - selectedAssets: 已选图片资源数组Assets
    ///   - selectedImages:已选图片资源数组UIIMage
    ///   - allowEdit: 是否编辑
    ///   - onSelectPhoto: 返回选中图片
    ///   - onDismiss: 关闭页面
    @objc func showCameraVC(_ enableMultiplePhoto: Bool = false,
                            selectedAssets: [PHAsset] = [],
                            selectedImages: [Any] = [],
                            allowEdit: Bool = false,
                            onSelectPhoto: CameraHandler? = nil,
                            onDismiss: EmptyClosure? = nil) {
        DispatchQueue.main.async {
            let camera = TGCameraViewController()
            camera.enableMultiplePhoto = enableMultiplePhoto
            camera.selectedAsset = selectedAssets
            camera.selectedImage = selectedImages
            camera.onSelectPhoto = onSelectPhoto
            camera.onDismiss = onDismiss
            camera.allowEdit = allowEdit
            let nav = TGNavigationController(rootViewController: camera).fullScreenRepresentation
            self.present(nav, animated: true)
        }
    }
    
    /// 打开小视频录制
    /// - Parameter onSelectVideo:
    @objc func showMiniVideoRecorder(onSelectVideo: MiniVideoRecorderHandler? = nil) {
        DispatchQueue.main.async {
            let videoVC = TGMiniVideoRecorderViewController()
            let nav = TGNavigationController(rootViewController: videoVC)
            videoVC.onSelectMiniVideo = onSelectVideo
            self.present(nav.fullScreenRepresentation, animated: true, completion: nil)
        }
    }
    
    /// 弹出确认框
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 内容
    ///   - buttonTitle: 确认按钮内容
    ///   - defaultAction: 确认按钮点击事件
    ///   - cancelTitle: 取消按钮内容
    ///   - cancelAction: 取消按钮点击事件
    func showAlert(title: String? = nil, message: String, buttonTitle: String, defaultAction: @escaping ((UIAlertAction) -> Void), cancelTitle: String? = nil, cancelAction: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: defaultAction))
        
        if let canceltitle = cancelTitle {
            alert.addAction(UIAlertAction(title: canceltitle, style: .cancel, handler: cancelAction))
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentPopup(alert: TGAlertController, actions: [TGAlertAction] = []) {
        self.resignFirstResponder()
        
        for action in actions  {
            alert.addAction(action)
        }
        
        alert.modalPresentationStyle = .overFullScreen
        
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.fade
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeIn)
        
        if let window = self.view.window {
            window.layer.add(transition, forKey: kCATransition)
        }
        
        DispatchQueue.main.async {
            self.present(alert, animated: false, completion: nil)
        }
    }
    func presentPopVC(target: Any, type: TGPopUpType, delegate: CustomPopListProtocol? = nil) {
        var items: [TGPopUpItem] = []
        switch type {
        case .moreUser:
            guard let feedModel = target as? FeedListCellModel, let id = RLSDKManager.shared.loginParma?.uid else {
                return
            }
            //是否收藏
            let isCollect = (feedModel.toolModel?.isCollect).orFalse ? false : true
            items.append(.save(isSaved: isCollect))
            items.append(.reportPost)
        case .moreMe:
            guard let feedModel = target as? FeedListCellModel, let id = RLSDKManager.shared.loginParma?.uid else {
                return
            }
            if !UserDefaults.teenModeIsEnable && feedModel.campaignIsEdite{
                items = [.edit]
            }
            
            //是否Pin
            let isPinned = feedModel.isPinned ? true : false
            items.append(.pinTop(isPinned: isPinned))
      
            //是否收藏
            let isCollect = (feedModel.toolModel?.isCollect).orFalse ? false : true
            items.append(.save(isSaved: isCollect))
            
            //是否关闭评论
            let isCommentDisabled = (feedModel.toolModel?.isCommentDisabled).orFalse
            
            items.append(.comment(isCommentDisabled: isCommentDisabled))
            items.append(.deletePost)
        case .share:
            if !UserDefaults.teenModeIsEnable {
                items = [.message]
            }
            items.append(.shareExternal)
        case .selfComment:
            guard let target = target as? LivePinCommentModel else { return }
            let model = target.model
            if target.requiredPinMessage {
                items = [model.pinned == true ? .liveUnPinComment(model: target) : .livePinComment(model: target), .deleteComment(model: target), .copy(model: target)]
            } else {
                items = [.deleteComment(model: target), .copy(model: target)]
            }
        case .normalComment:
            guard let target = target as? LivePinCommentModel else { return }
            let model = target.model
            if target.requiredPinMessage {
                items = [model.pinned == true ? .liveUnPinComment(model: target) : .livePinComment(model: target), .reportComment(model: target), .copy(model: target)]
            } else {
                items = [.reportComment(model: target), .copy(model: target)]
            }
        case .post:
            items.append(.picture)
            items.append(.miniVideo)
        }
   
        let popVC = TGCustomPopListViewController(type: type, items: items)
        popVC.modalTransitionStyle = .crossDissolve
        popVC.modalPresentationStyle = .overCurrentContext
        popVC.delegate = delegate
//        rewardVC.defaultPageIndex = defaultPageIdx
        self.present(popVC, animated: true, completion: nil)
    }
    func showTopFloatingToast(with title: String, desc: String = "", background: UIColor? = nil, customView: UIView? = nil) {
        var attr = UIView.topToastAttributes
        attr.name = "toast"
        attr.displayDuration = 2.5
        
        var backgroundColor = background
        
        if backgroundColor == nil {
            backgroundColor = UIColor.black.withAlphaComponent(0.75)
        }
        
        attr.entryBackground = .color(color: EKColor(backgroundColor!))
        
        if let customView = customView {
            SwiftEntryKit.display(entry: customView, using: attr)
            return
        }
        
        let toastView = TGAlertContentView(for: title, desc: desc, background: backgroundColor!)
        
        SwiftEntryKit.display(entry: toastView, using: attr)
    }
    static func showBottomFloatingToast(with title: String, desc: String, background:UIColor? = nil, displayDuration: TimeInterval = 2.5) {
        guard SwiftEntryKit.isCurrentlyDisplaying == false else { return }
        
        var attr = UIView.bottomToastAttributes
        attr.name = "errors"
        attr.displayDuration = displayDuration
        attr.screenInteraction = .dismiss
        attr.entryInteraction = .absorbTouches
        
        var backgroundColor = background
        
        if backgroundColor == nil {
            backgroundColor = UIColor.black.withAlphaComponent(0.75)
        }
        
        attr.entryBackground = .color(color: EKColor(backgroundColor!))
        
        var message = (desc.isEmpty && title.isEmpty) ? "please_retry_option".localized : desc
        
        let toastView = TGAlertContentView(for: title, desc: message, background: backgroundColor!)
        
        SwiftEntryKit.display(entry: toastView, using: attr)
    }
    func showDialog(image: UIImage? = nil, title: String? = nil, message: String, dismissedButtonTitle: String, onDismissed: (()->())?, onCancelled: (()->())? = nil, cancelButtonTitle: String? = nil, isRedPacket: Bool? = false, isInsufficientBalance: Bool? = false, isFavouriteMessage: Bool? = false) {
        let alertViewContent = UIView(frame: .zero)
        alertViewContent.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width * 0.8)
        }
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.alignment = .center
        mainStackView.distribution = .fill
        mainStackView.spacing = 20
        
        if let img = image {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            mainStackView.addArrangedSubview(imageView)
            imageView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(30)
                $0.width.equalTo(120)
                $0.height.equalTo(imageView.snp.width)
            }
        }
        
        let contentLabelStackView = UIStackView()
        contentLabelStackView.axis = .vertical
        contentLabelStackView.alignment = .fill
        contentLabelStackView.distribution = .fill
        contentLabelStackView.spacing = 8
        
        if let titleString = title {
            let alertTitle = UILabel()
            alertTitle.applyStyle(.bold(size: 16, color: .black), setAdaptive: true)
            alertTitle.text = titleString
            alertTitle.textAlignment = .center
            alertTitle.numberOfLines = 1
            contentLabelStackView.addArrangedSubview(alertTitle)
            alertTitle.snp.makeConstraints {
                if isInsufficientBalance ?? false {
                    $0.top.equalToSuperview().offset(20)
                }
                $0.left.equalToSuperview()
                $0.right.equalToSuperview()
            }
        }
        
        let alertDescription = UILabel()
        alertDescription.applyStyle(.regular(size: 14, color: .black), setAdaptive: true)
        alertDescription.text = message
        alertDescription.textAlignment = .center
        alertDescription.numberOfLines = 0
        alertDescription.textColor = UIColor(red: 136.0/255.0, green: 136.0/255.0, blue: 136.0/255.0, alpha: 1.0)
        contentLabelStackView.addArrangedSubview(alertDescription)
        alertDescription.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        mainStackView.addArrangedSubview(contentLabelStackView)
        contentLabelStackView.snp.makeConstraints {
            if isFavouriteMessage ?? false {
                $0.top.equalToSuperview().offset(25)
            }
            $0.left.equalToSuperview().offset(25)
            $0.right.equalToSuperview().offset(-25)
        }
        let okButton = UIButton()
        let cancelButton = UIButton()
        
        if isRedPacket ?? false {
            let buttonStackView = UIStackView()
            buttonStackView.axis = .horizontal
            buttonStackView.alignment = .center
            buttonStackView.distribution = .fill
            buttonStackView.spacing = 8
            
            buttonStackView.snp.makeConstraints {
                $0.height.equalTo(70)
            }
            
            if let cancelTitle = cancelButtonTitle {
                if isFavouriteMessage ?? false {
                    cancelButton.applyStyle(.custom(text: cancelTitle, textColor: UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0) , backgroundColor: UIColor(hex: 0xF5F5F5), cornerRadius: 22.5))
                } else {
                    cancelButton.applyStyle(.custom(text: cancelTitle, textColor: UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0), backgroundColor: .clear, cornerRadius: 0))
                }
                buttonStackView.addArrangedSubview(cancelButton)
                cancelButton.snp.makeConstraints {
                    $0.height.equalTo(45)
                    $0.width.equalTo(145)
                }
            }
            
            if isFavouriteMessage ?? false {
                okButton.applyStyle(.custom(text: dismissedButtonTitle, textColor: .white, backgroundColor: UIColor(hex: 0xED2121), cornerRadius: 22.5))
            } else {
                okButton.applyStyle(.custom(text: dismissedButtonTitle, textColor: .white, backgroundColor: RLColor.main.red, cornerRadius: 22.5))
            }
            buttonStackView.addArrangedSubview(okButton)
            okButton.snp.makeConstraints {
                $0.height.equalTo(45)
                $0.width.equalTo(145)
            }
            
            mainStackView.addArrangedSubview(buttonStackView)
        }else {
            okButton.applyStyle(.custom(text: dismissedButtonTitle, textColor: .white, backgroundColor: RLColor.main.red, cornerRadius: 22.5))
            mainStackView.addArrangedSubview(okButton)
            okButton.snp.makeConstraints {
                $0.left.equalToSuperview().offset(59)
                $0.right.equalToSuperview().offset(-59)
                $0.height.equalTo(45)
            }
            
            if let cancelTitle = cancelButtonTitle {
                cancelButton.applyStyle(.custom(text: cancelTitle, textColor: UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0), backgroundColor: .clear, cornerRadius: 0))
                mainStackView.addArrangedSubview(cancelButton)
                cancelButton.snp.makeConstraints {
                    $0.left.equalToSuperview().offset(59)
                    $0.right.equalToSuperview().offset(-59)
                    $0.height.equalTo(20)
                }
            }
        }
        alertViewContent.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-15)
        }
        
        alertViewContent.setNeedsLayout()
        alertViewContent.layoutIfNeeded()
        
        var allowDismiss = Bool()
        if isRedPacket! {
            allowDismiss = false
        } else {
            allowDismiss = true
        }
        let popup = TGAlertController(style: .popup(customview: alertViewContent), hideCloseButton: true, allowBackgroundDismiss: allowDismiss)
        popup.modalPresentationStyle = .overFullScreen
        okButton.addTap { [weak self] (_) in
            guard let self = self else { return }
            popup.dismiss()
            onDismissed?()
        }
        cancelButton.addTap { [weak self] (_) in
            guard let self = self else { return }
            popup.dismiss()
            onCancelled?()
        }
        self.present(popup, animated: false)
    }
    
    
    func showRLDelete(title: String? = nil, message: String, dismissedButtonTitle: String, onDismissed: (()->())?, onCancelled: (()->())? = nil, cancelButtonTitle: String? = nil) {
        let alertViewContent = UIView(frame: .zero)
        alertViewContent.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width * 0.8)
        }
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.alignment = .center
        mainStackView.distribution = .fill
        mainStackView.spacing = 20
        
        let contentLabelStackView = UIStackView()
        contentLabelStackView.axis = .vertical
        contentLabelStackView.alignment = .fill
        contentLabelStackView.distribution = .fill
        contentLabelStackView.spacing = 15
        
        let actionStackView = UIStackView()
        actionStackView.axis = .horizontal
        actionStackView.alignment = .fill
        actionStackView.distribution = .fill
        actionStackView.spacing = 8
        
        if let titleString = title {
            let alertTitle = UILabel()
            alertTitle.applyStyle(.bold(size: 16, color: .black), setAdaptive: true)
            alertTitle.text = titleString
            alertTitle.textAlignment = .left
            alertTitle.numberOfLines = 1
            contentLabelStackView.addArrangedSubview(alertTitle)
            alertTitle.snp.makeConstraints {
                $0.left.equalToSuperview()
                $0.right.equalToSuperview()
            }
        }
        
        let alertDescription = UILabel()
        alertDescription.applyStyle(.regular(size: 14, color: .black), setAdaptive: true)
        alertDescription.text = message
        alertDescription.textAlignment = .left
        alertDescription.numberOfLines = 0
        alertDescription.textColor = UIColor(hex: 0x808080)
        contentLabelStackView.addArrangedSubview(alertDescription)
        alertDescription.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        mainStackView.addArrangedSubview(contentLabelStackView)
        contentLabelStackView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-25)
        }
        
        
        let okButton = UIButton()
        let cancelButton = UIButton()
        
        
        if let cancelTitle = cancelButtonTitle {
            cancelButton.applyStyle(.custom(text: cancelTitle, textColor: UIColor(hex: 0x808080), backgroundColor: .clear, cornerRadius: 0))
            actionStackView.addArrangedSubview(cancelButton)
        }
        
        
        okButton.applyStyle(.custom(text: dismissedButtonTitle, textColor: TGAppTheme.red, backgroundColor: .clear, cornerRadius: 0))
        actionStackView.addArrangedSubview(okButton)
        
        alertViewContent.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-15)
        }
        
        mainStackView.addArrangedSubview(actionStackView)
        actionStackView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-15)
            $0.width.equalToSuperview().multipliedBy(0.45)
        }
        
        alertViewContent.setNeedsLayout()
        alertViewContent.layoutIfNeeded()
        
        var allowDismiss = Bool()
     
        allowDismiss = true
        
        let popup = TGAlertController(style: .popup(customview: alertViewContent), hideCloseButton: true, allowBackgroundDismiss: allowDismiss)
        popup.modalPresentationStyle = .overFullScreen
        okButton.addTap { [weak self] (_) in
            guard let self = self else { return }
            popup.dismiss()
            onDismissed?()
        }
        cancelButton.addTap { [weak self] (_) in
            guard let self = self else { return }
            popup.dismiss()
            onCancelled?()
        }
        self.present(popup, animated: false)
    }
    var isModal: Bool {
        return presentingViewController != nil || navigationController?.presentingViewController?.presentedViewController == navigationController || tabBarController?.presentingViewController is UITabBarController
    }
    
}
extension UINavigationController {
    func popViewController(animated: Bool, completion: @escaping (() -> ())) {
        popViewController(animated: animated)
        
        if self.transitionCoordinator != nil && animated == true {
            self.transitionCoordinator!.animate(alongsideTransition: nil) { (_) in
                completion()
            }
        } else {
            completion()
        }
    }
    
    func pushViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        pushViewController(viewController, animated: animated)
        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
