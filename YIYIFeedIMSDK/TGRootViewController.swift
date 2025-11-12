//
//  TGRootViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/10/23.
//

import UIKit

class TGRootViewController: TGViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    static let share = TGRootViewController()
    /// 游客进入登录视图
    func verifyGuestModeOrNoLogin(vc: UIViewController? = nil, reOpenMP: Bool = false, success: (() -> Void)? = nil, failure: (() -> Void)? = nil) {
        // MARK: 如果是yippi 这样不需要做游客验证的app，直接return success
//         success?()
        
        RLSDKManager.shared.feedDelegate?.didVerifyGuestModeOrNoLogin(
            vc: vc,
            reOpenMP: reOpenMP,
            success: success,
            failure: failure
        )
    }
//    
//    func guestJoinLandingVC(vc: UIViewController? = nil, isGuestBtnHidden: Bool = true, reOpenMP: Bool = false) {
//        landingVC = presentAuthentication(vc: vc, isDismissBtnHidden: false, isGuestBtnHidden: isGuestBtnHidden, reOpenMP: reOpenMP)
//    }

}
