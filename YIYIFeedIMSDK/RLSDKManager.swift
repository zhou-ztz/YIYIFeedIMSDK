//
//  RLSDKManager.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/22.
//

import UIKit

public typealias TGTransactionFinishClosure = (_ id: Int, _ userId: [String]?, _ msg: String) -> Void

public enum TGQRType {
    case group, user, transfer, web, merchant, restNGo
}

public enum TGAuthMessageType {
    case egg, purchase
    
    var text: String {
        switch self {
        case .egg: return "text_send_egg_bio_auth".localized
        case .purchase: return "text_purchase_with_bio_auth".localized
        }
    }
}

public enum TGTransactionType {
    case personal, group, yippsTransfer
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
    func didPressUerProfile(uid: Int)
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
    ///  打开支付密码弹窗
    func showPin(type: TGAuthMessageType, _ completion: ((String) -> Void)?, cancel: (() -> Void)?, needDisplayError: Bool)
    /// 关键支付密码弹窗
    func dismissPin()
    /// 显示支付message
    func showPinError(message: String)
    /// 发送红包页面
    func openRedPackect(transactionType: TGTransactionType, fromUser: String, toUser: String, numberOfMember: Int, teamId: String?, completion: TGTransactionFinishClosure?)
    ///  openMsgRequestChat
    func openMsgRequestChat(userinfoJsonString: String)
    /// 被踢下线
    func onKickedOffline(clientType: Int, reason: Int)
    /// 登陆失败
    func onLoginFailed()
    /// 登陆状态
    func onLoginStatus(_ status: Int)
    /// 文件以web 形式打开
    func openFileWebview(url: URL, title: String)
}

public protocol TGFeedDelegate: AnyObject {
    /// 跳转优惠券详情
    func didVoucherTouched(voucherId: Int)
    /// 跳转 TSLocationDetailVC
    func onLocationViewTapped(locationID: String, locationName: String)
    /// 跳转 TopicPostListVC
    func onTopicViewTapped(groupId: Int)
    /// 跳转 搜索页面 RLSearchResultVC
    func onSearchPageTapped(hashtag: String)
    /// 跳转至动态首页
    func didPresentFeedHome()
    /// 上报埋点信息
    func onTrackEvent(itemId: String,
                      itemType: String,
                      behaviorType: String,
                      moduleId: String,
                      pageId: String,
                      behaviorValue: String?,
                      traceInfo: String?)
    
    func track(event: TGEvent, with: [String: String])
    /// 保存本地
    func saveUserInfoModel(json: String)
    /// 获取本地用户信息
    func getUserInfoModel(username: String?, userId: Int?, nickname: String?) -> String?
    
    /// 给小程序发送事件
    func sendEventToMiniProgram(detail: [String: Any], miniProgramType: String)
    
}

public class RLSDKManager: NSObject {

    public static let shared = RLSDKManager()
    
    var loginParma: RLLoginParma?
    var appKey: String = ""
    
    var currentUserInfo: UserInfoModel?
    
    public weak var imDelegate: TGMessageDelegate?
    public weak var feedDelegate: TGFeedDelegate?
    // 云信 appKey
    public func initSDK(appKey: String){
        RLNIMSDKManager.shared.setupNIMSDK(appKey: appKey)
        IMNotificationCenter.sharedCenter.start()
        setupIQKeyboardManager()
        UIImage.swizzleImageNamed
        UIButton.swizzleButtonImageMethods
        self.appKey = appKey
    }
    
    public func loginIM(parma: RLLoginParma, success: @escaping ()->Void, failure: @escaping ()->Void){
        self.loginParma = parma
        currentUserInfo = UserInfoModel.convert(parma.userInfoJson)?.first
        RLNIMSDKManager.shared.imLogin(with: self.loginParma?.imAccid ?? "", imToken: self.loginParma?.imToken ?? "") {
            if let xToken = self.loginParma?.xToken {
                UserDefaults.standard.setValue(xToken , forKey: "TG_ACCESS_TOKEN")
            }
            success()
        } failure: {
            failure()
        }
        getCurrentUserInfo()
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
    
    /// 获取所有Request未读数
    public func getRequestlistCountAllUnreadCount(completion: @escaping (_ count: Int) ->Void) {
        TGIMUnreadCountManager.shared.getRequestlistCountAllUnreadCount { count in
            completion(count)
        }
    }
    /// im 退出登陆
    public func outLoginIM() {
        RLNIMSDKManager.shared.logout()
    }
    /// 停止屏幕共享扩展进程
    public func stopBroadcastExtension() {
        RLNIMSDKManager.shared.stopBroadcastExtension()
    }
    
    private func getCurrentUserInfo() {
        guard let uid = self.loginParma?.uid else {return}
        TGNewFriendsNetworkManager.getUsersInfo(usersId: [Int(uid)], names: []) { users, error in
            if let model = users?.first {
                RLSDKManager.shared.currentUserInfo = model
            }
        }
    }
}
