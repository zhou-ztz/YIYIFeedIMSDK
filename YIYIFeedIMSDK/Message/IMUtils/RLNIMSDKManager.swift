//
//  RLNIMSDKManager.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/22.
//

import UIKit
import NIMSDK

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
        
        #if DEBUG
        let appKey = "a64fb0d3c5d98a0f5af8532e8c255eb7"
        let apnsCername = ""
        let pkCername = ""
        #else
        let appKey  = "a64fb0d3c5d98a0f5af8532e8c255eb7"
        let apnsCername = ""
        let pkCername = ""
        #endif
        
        let option = NIMSDKOption(appKey: appKey)
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
    }
    
    public func logout() {
        NIMSDK.shared().v2LoginService.logout {
            print("im logout success")
        } failure: { error in
            print("im logout fail = \(error.detail), code = \(error.code)")
        }

    }
    
    public func imLogin(with accid: String, imToken: String){

        NIMSDK.shared().v2LoginService.login(accid, token: imToken, option: nil) {
            print("im login success")
        } failure: { error in
            print("im login fail = \(error.detail), code = \(error.code)")
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
