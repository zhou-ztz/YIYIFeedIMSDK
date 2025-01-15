//
//  RLSDKManager.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/22.
//

import UIKit

public enum TGQRType {
    case group, user, transfer, web, merchant, restNGo
}

public protocol TGMessageDelegate: AnyObject {
    /// 跳转贴纸主页
    func didPressAdd(_ sender: Any?)
    /// 跳转贴纸设置页面
    func didPressMySticker(_ sender: Any?)
    /// 跳转贴纸详情页面
    func didPressStickerDetail(bundleId: String)
    /// 跳转个人中心
    func didPressNameCard(memberId: String)
    /// 跳转扫一扫
    func didPressQRScan()
    /// 跳转通讯录
    func didPressContacts()
    /// 跳转附附近的人
    func didPressNearByPeople()
    /// 跳转搜索
    func didPressNewAddContact()
    /// 跳转二维码
    func didPressQRCodeVC(qrType: TGQRType, qrContent: String, descStr: String)
    /// 跳转优惠券详情 urlString - deeplink url
    func didPressVoucher(urlString: String)
    /// 跳转动态详情 urlString - deeplink url
    func didPressSocialPost(urlString: String)
    /// 跳转小程序
    func didPressMiniProgrom(appId: String, path: String)
}

public class RLSDKManager: NSObject {

    public static let shared = RLSDKManager()
    
    var loginParma: RLLoginParma?
    
    public weak var imDelegate: TGMessageDelegate?
    
    public func initSDK(){
        RLNIMSDKManager.shared.setupNIMSDK()
        IMNotificationCenter.sharedCenter.start()
        setupIQKeyboardManager()
    }
    
    public func loginIM(parma: RLLoginParma, success: @escaping ()->Void, failure: @escaping ()->Void){
        self.loginParma = parma
        RLNIMSDKManager.shared.imLogin(with: self.loginParma?.imAccid ?? "", imToken: self.loginParma?.imToken ?? "") {
            success()
        } failure: {
            failure()
        }
        
        predownloadSticker()
    }
    ///下载贴纸
    func predownloadSticker(){
        guard let userID = RLSDKManager.shared.loginParma?.uid else { return }
        TGStickerNetworkManager.getStickerListV2(userId: "\(userID)") { _ in
            
        }
    }
    
    func setupIQKeyboardManager() {
        TGKeyboardToolbar.share.configureKeyboard()
        TGKeyboardToolbar.share.keyboardStopNotice()
    }
    
    /// 获取所有会话 未读数
    public func getConversationAllUnreadCount() -> Int {
        return TGIMUnreadCountManager.shared.getConversationAllUnreadCount()
    }
    
}
