//
//  TGViewController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/22.
//

import UIKit
import SDWebImage
import NEMeetingKit
import NIMSDK
import SnapKit
import IQKeyboardManagerSwift


public class TGViewController: UIViewController {

    let customNavigationBar: SCCustomNavigationBar = SCCustomNavigationBar(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: TSNavigationBarHeight))
    var backBaseView = UIView()
    lazy var allStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    public var isHiddenNavigaBar: Bool = false {
        didSet {
            customNavigationBar.isHidden = isHiddenNavigaBar
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = .white
        setupIQKeyboardManager()
        setNavigationBar()
    }
    
    var placeholder = TGPlaceholder()
    
    private lazy var loadingIndicator: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        var images: [UIImage] = []
        for index in 0..<30 {
            let imageName = "RL_IMG_default_center_000\(index)"
            let image = UIImage(named: imageName)!
            images.append(image)
        }
        imageView.animationImages = images
        imageView.contentMode = .center
        return imageView
    }()
    
    //记录页面进入开始时间
    var stayBeginTimestamp: String = ""
    //记录页面离开时间
    var stayEndTimestamp: String = ""
    
    var stayTimer : Timer?
    var eventStartTime : Int = 0
    
    func setNavigationBar(){
        
        view.addSubview(allStackView)
        allStackView.bindToEdges()
        allStackView.addArrangedSubview(customNavigationBar)
        allStackView.addArrangedSubview(backBaseView)
        customNavigationBar.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(TSNavigationBarHeight)
        }
        backBaseView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        backBaseView.setNeedsLayout()
        backBaseView.layoutIfNeeded()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        customNavigationBar.backItem.addTarget(self, action: #selector(backAtcion), for: .touchUpInside)
    }
    
    
    func setupIQKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }

    @objc func backAtcion(){
       // self.navigationController?.popViewController(animated: true)
        if self.navigationController?.popViewController(animated: true) == nil {
            self.dismiss(animated: true)
        }
    }
    
    deinit {
        print("\(self) will deinit")
    }
    
    
    func launchScreenDismissWithDelay() -> Double {
//        return (launchScreenVC != nil ? 1.2 : 0.3)
        return 0.3
    }

    func setCloseButton(backImage: Bool = false, titleStr: String? = nil, customView: UIView? = nil, completion: (() -> Void)? = nil, needPop: Bool = true, color: UIColor = .black, backWhiteCircle: Bool = false) {
        let image: UIImage
        if backImage == false {
            image = UIImage(named: "IMG_topbar_close")!
        } else {
            image = UIImage(named: "iconsArrowCaretleftBlack")!
        }
        
        var barButton = UIBarButtonItem()
        let backButtonView = UIView()
        backButtonView.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
        
        let imageView = UIImageView(image: image)
        
        backButtonView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        if backWhiteCircle {
            backButtonView.backgroundColor = .white

            backButtonView.layer.masksToBounds = true
            backButtonView.clipsToBounds = true
            backButtonView.layer.cornerRadius = 15
        } else {
            backButtonView.backgroundColor = .clear
        }

        barButton = UIBarButtonItem(customView: backButtonView)
        backButtonView.addTap(action: { [weak self] (_) in
            if needPop {
                let _ = self?.navigationController?.popViewController(animated: true, completion: {
                    completion?()
                })
            } else {
                completion?()
            }
        })
        
        barButton.tintColor = color
        
        if let titleStr = titleStr {
            let btn = UIButton(type: .custom)
            btn.setTitle(titleStr, for: .normal)
            btn.setTitleColor(RLColor.share.black, for: .normal)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            btn.titleLabel?.lineBreakMode = .byTruncatingTail
            let titleButton = UIBarButtonItem(customView: btn)
            self.navigationItem.leftBarButtonItems = [barButton, titleButton]
            return
        }
        if let customView = customView {
            let titleButton = UIBarButtonItem(customView: customView)
            self.navigationItem.leftBarButtonItems = [barButton, titleButton]
            return
        }
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func show(placeholder type: PlaceholderViewType, theme: Theme = .white, topPadding: CGFloat? = nil) {
        if placeholder.superview == nil {
            backBaseView.addSubview(placeholder)
            if let topPadding = topPadding {
                placeholder.bindToEdges(topPadding: topPadding)
            } else {
                placeholder.bindToEdges()
            }
            placeholder.onTapActionButton = {
                self.placeholderButtonDidTapped()
            }
        }
        placeholder.set(type)
        placeholder.theme = theme
    }
    
    func removePlaceholderView() {
        placeholder.removeFromSuperview()
    }
    
    func placeholderButtonDidTapped() { }
    
    func showLoadingAnimation() {
        self.view.addSubview(loadingIndicator)
        loadingIndicator.bindToEdges()
        loadingIndicator.startAnimating()
    }
    
    func dismissLoadingAnimation() {
        self.loadingIndicator.stopAnimating()
        self.loadingIndicator.removeFromSuperview()
    }
    
}

extension UIViewController {
    
    
    static var topMostController: UIViewController? {
        var topMostController: UIViewController?
        topMostController = UIApplication.shared.keyWindow?.rootViewController
        
        while topMostController?.presentedViewController != nil {
            topMostController = topMostController?.presentedViewController
        }
        if topMostController is UITabBarController {
            let tabBarController = topMostController as? UITabBarController
            return tabBarController?.selectedViewController
        }
        if topMostController is UINavigationController {
            let navigationController = topMostController as? UINavigationController
            return navigationController?.visibleViewController == nil ? navigationController : navigationController?.visibleViewController
        }
        
        if let topMostController1 = topMostController {
            
            if NSStringFromClass(type(of: topMostController1).self).hasSuffix("TSRootViewController") && topMostController1.children.count > 0 {
                topMostController = topMostController1.children.last
                if topMostController is UITabBarController {
                    let tabBarController = topMostController as? UITabBarController
                    topMostController = tabBarController?.selectedViewController
                    if topMostController is UINavigationController {
                        let navigationController = topMostController as? UINavigationController
                        topMostController = navigationController?.visibleViewController == nil ? navigationController : navigationController?.visibleViewController
                    }
                } else if topMostController is UINavigationController{
                    let navigationController = topMostController as? UINavigationController
                    topMostController = navigationController?.visibleViewController == nil ? navigationController : navigationController?.visibleViewController
                }
            }
            
        }
        
        return topMostController
    }

    
}
