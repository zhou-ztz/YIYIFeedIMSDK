//
//  RLNIMSDKManager.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/22.
//

import UIKit
import NIMSDK
import NEMeetingKit
//cd2ce206e475a58c6d4c13e6931ad8df
let NIMAppKey: String = "43cf17ab859f4c669349fd68e363d6db"
//"43cf17ab859f4c669349fd68e363d6db"

class RLNIMSDKManager: NSObject, NIMSDKConfigDelegate, V2NIMLoginListener {
    
    public static let shared = RLNIMSDKManager()
    
    override init() {
        super.init()
    }
    
    func setupNIMSDK(appKey: String) {
        
        NIMSDKConfig.shared().delegate = self
        NIMSDKConfig.shared().shouldSyncUnreadCount = true
        NIMSDKConfig.shared().maxAutoLoginRetryTimes = 10
        NIMSDKConfig.shared().customTag = String(NIMLoginClientType.typeiOS.rawValue)
        NIMSDKConfig.shared().shouldCountTeamNotification = true
        NIMSDKConfig.shared().maxAutoLoginRetryTimes = 3
        NIMSDKConfig.shared().teamReceiptEnabled = true
        
        let apnsCername = ""
        let pkCername = ""
        //appKey
        let option = NIMSDKOption(appKey: appKey)
        option.apnsCername = apnsCername
        option.pkCername = pkCername
        /// 使用 v2 版本
        let v2Option = V2NIMSDKOption()
        v2Option.useV1Login = false
        NIMSDK.shared().register(withOptionV2: option, v2Option: v2Option)
    
        
        let sceneDict: NSMutableDictionary = NSMutableDictionary(dictionary: ["nim_custom":1])
        NIMSDK.shared().sceneDict = sceneDict
        
        NIMSDK.shared().v2LoginService.add(self)
        
        ///用户信息
        NIMSDK.shared().v2UserService.add(self)
        
        /// 会议组件 初始化
        initMeetingkit(appKey: appKey)
    
    }
    
    func initMeetingkit(appKey: String) {
        let config = NEMeetingKitConfig()
        config.appKey = appKey
        //config.appName = "RewardsLink"
        let language =  TGLocalizationManager.getCurrentLanguage()
        if language == TGLanguageIdentifier.chineseSimplified.rawValue || language == TGLanguageIdentifier.chineseTraditional.rawValue {
            config.language = .CHINESE
        } else if language == TGLanguageIdentifier.japanese.rawValue {
            config.language = .JAPANESE
        } else {
            config.language = .ENGLISH
        }
        config.broadcastAppGroup = "group.com.togl.getyippi.share"
        NEMeetingKit.getInstance().initialize(config) { code, message, result in
            print("NEMeetingKit code = \(code)")
            print("NEMeetingKit message = \(message)")
        }
    }
    
    public func logout() {
        NIMSDK.shared().v2LoginService.logout {
            print("im logout success")
        } failure: { error in
            print("im logout fail = \(error.detail), code = \(error.code)")
        }
        NEMeetingKit.getInstance().getAccountService().logout { code, msg, result in
            
        }
        
    }
    
    func stopBroadcastExtension() {
        NEMeetingKit.getInstance().getMeetingService().stopBroadcastExtension()
    }
    
    
    public func imLogin(with accid: String, imToken: String, success: @escaping ()->Void, failure: @escaping (Error?)->Void){

        NIMSDK.shared().v2LoginService.login(accid, token: imToken, option: nil) {
            print("im login success")
            self.quertMeetingKitAccountInfo()
            success()
        } failure: { error in
            print("im login fail = \(error.detail), code = \(error.code)")
            failure(error.nserror)
        }

    }
    
    
    func quertMeetingKitAccountInfo() {
        TGIMNetworkManager.quertMeetingKitAccount { requestdata, error in
            if let model = requestdata {
                UserDefaults.standard.setValue(model.userUuid, forKey: "MeetingKit-userUuid")
                UserDefaults.standard.setValue(model.userToken, forKey: "MeetingKit-userToken")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    /// V2NIMLoginListener
    func onLoginFailed(_ error: V2NIMError) {
        print("IM onLoginFailed = \(error.nserror.localizedDescription)")
        RLSDKManager.shared.imDelegate?.onLoginFailed()
    }
    /** 登出状态，SDK初始化时，或调用logout接口后，或登录已终止（被踢下线或遇到无法继续登录的错误）。建议：在此状态时调用login接口。
    V2NIM_LOGIN_STATUS_LOGOUT                           = 0,
    /// 已登录
    V2NIM_LOGIN_STATUS_LOGINED                          = 1,
    /// 登录中（包括连接到服务器和与服务器进行登录鉴权）
    V2NIM_LOGIN_STATUS_LOGINING                         = 2,
    /// 未登录，但登录未终止，SDK会尝试重新登录。建议：不需要在此状态时调用login接口
    V2NIM_LOGIN_STATUS_UNLOGIN                          = 3,
    */
    func onLoginStatus(_ status: V2NIMLoginStatus) {
        print("IM onLoginStatus = \(status.rawValue)")
        RLSDKManager.shared.imDelegate?.onLoginStatus(status.rawValue)
    }
    /*V2NIM_KICKED_OFFLINE_REASON_CLIENT_EXCLUSIVE        = 1,  ///<被另外一个客户端踢下线 (互斥客户端一端登录挤掉上一个登录中的客户端)
     V2NIM_KICKED_OFFLINE_REASON_SERVER                  = 2,  ///<被服务器踢下线
     V2NIM_KICKED_OFFLINE_REASON_CLIENT                  = 3,  ///<被另外一个客户端手动选择踢下线
     */
    func onKickedOffline(_ detail: V2NIMKickedOfflineDetail) {
        print("IM onKickedOffline = \(detail.description)")
        RLSDKManager.shared.imDelegate?.onKickedOffline(clientType: detail.clientType.rawValue, reason: detail.reason.rawValue)
    }
    
    func onLoginClientChanged(_ change: V2NIMLoginClientChange, clients: [V2NIMLoginClient]?) {
        NotificationCenter.default.post(name: NSNotification.Name("checkWebIsOnline"), object: nil)
    }
}

extension RLNIMSDKManager: V2NIMUserListener {
    func onUserProfileChanged(_ users: [V2NIMUser]) {
        
    }
    
    func onBlockListAdded(_ user: V2NIMUser) {
        
    }
    
    func onBlockListRemoved(_ accountId: String) {
        
    }
    
    
}
