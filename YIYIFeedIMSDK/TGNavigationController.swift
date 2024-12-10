//
//  SCNavigationController.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2023/12/7.
//

import UIKit

public class TGNavigationController: UINavigationController {

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let navigationBar = UINavigationBar.appearance()
        let navigationBarTitleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]
        navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        navigationBar.titleTextAttributes = navigationBarTitleAttributes
        navigationBar.barTintColor = UIColor.white
        navigationBar.tintColor = .blue
        navigationBar.isTranslucent = false
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.shadowColor = .clear
            appearance.shadowImage = UIImage()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }

        interactivePopGestureRecognizer?.delegate = self
        self.navigationBar.isHidden = true
    }
    
  

    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if self.viewControllers.isEmpty == false {
            let backBarItem = UIBarButtonItem(image: UIImage(named: "iconleftBlack")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popBack))
            viewController.navigationItem.leftBarButtonItem = backBarItem
            viewController.hidesBottomBarWhenPushed = true
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    public override func popViewController(animated: Bool) -> UIViewController? {
        if super.popViewController(animated: animated) == nil {
            self.visibleViewController?.dismiss(animated: true, completion: nil)
        }
        return nil
    }

    @objc func popBack() {
        let _ = self.popViewController(animated: true)
    }
    
   
}
// 遵循UIGestureRecognizerDelegate协议
extension TGNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 允许侧滑返回手势
        return true
    }
}

