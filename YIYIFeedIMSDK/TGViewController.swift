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
    var isHiddenNavigaBar: Bool = false {
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
