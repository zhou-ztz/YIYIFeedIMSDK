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
let NIMAppKey: String = "cd2ce206e475a58c6d4c13e6931ad8df"
//"43cf17ab859f4c669349fd68e363d6db"

class RLNIMSDKManager: NSObject, NIMSDKConfigDelegate, V2NIMLoginListener {
    
    public static let shared = RLNIMSDKManager()
    
    override init() {
        super.init()
    }
    
    func setupNIMSDK() {
        
        NIMSDKConfig.shared().delegate = self
        NIMSDKConfig.shared().shouldSyncUnreadCount = true
        NIMSDKConfig.shared().maxAutoLoginRetryTimes = 10
        NIMSDKConfig.shared().customTag = String(NIMLoginClientType.typeiOS.rawValue)
        NIMSDKConfig.shared().shouldCountTeamNotification = true
        NIMSDKConfig.shared().maxAutoLoginRetryTimes = 3
        
        let apnsCername = ""
        let pkCername = ""
        
        let option = NIMSDKOption(appKey: NIMAppKey)
        option.apnsCername = apnsCername
        option.pkCername = pkCername
        /// 使用 v2 版本
        let v2Option = V2NIMSDKOption()
        v2Option.useV1Login = false
        NIMSDK.shared().register(withOptionV2: option, v2Option: v2Option)
        
        
        NIMSDKConfig.shared().teamReceiptEnabled = false
        
        let sceneDict: NSMutableDictionary = NSMutableDictionary(dictionary: ["nim_custom":1])
        NIMSDK.shared().sceneDict = sceneDict
        
        NIMSDK.shared().v2LoginService.add(self)
        
        ///用户信息
        NIMSDK.shared().v2UserService.add(self)
        /// 会议组件 初始化
        initMeetingkit()
    
    }
    
    func initMeetingkit() {
        let config = NEMeetingKitConfig()
        config.appKey = NIMAppKey
        config.appName = "RewardsLink"
//        let language =  LocalizationManager.getCurrentLanguage()
//        if language == LanguageIdentifier.chineseSimplified.rawValue || language == LanguageIdentifier.chineseTraditional.rawValue {
//            config.language = .CHINESE
//        } else if language == LanguageIdentifier.japanese.rawValue {
//            config.language = .JAPANESE
//        } else {
//            config.language = .ENGLISH
//        }
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

    }
    
    public func imLogin(with accid: String, imToken: String, success: @escaping ()->Void, failure: @escaping ()->Void){

        NIMSDK.shared().v2LoginService.login(accid, token: imToken, option: nil) {
            print("im login success")
            success()
        } failure: { error in
            print("im login fail = \(error.detail), code = \(error.code)")
            failure()
        }

    }
    
    /// V2NIMLoginListener
    func onLoginFailed(_ error: V2NIMError) {
        print("IM onLoginFailed")
    }
    
    func onLoginStatus(_ status: V2NIMLoginStatus) {
        print("IM onLoginStatus = \(status.rawValue)")
    }
    
    func onKickedOffline(_ detail: V2NIMKickedOfflineDetail) {
        print("IM onKickedOffline = \(detail.description)")
    }
    
    func onLoginClientChanged(_ change: V2NIMLoginClientChange, clients: [V2NIMLoginClient]?) {
        
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
