//
//  RLCurrentUserInfo.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/25.
//

import UIKit

let TOKEN_KEY = "x-token"
let APP_TYPE_KEY = "app_type"
let NETEASE_TOKEN = "netease_token"
let NETEASE_ACCID = "netease_accid"
let APP_UID = "app-uid"

class RLCurrentUserInfo: NSObject {
    
    static let shared = RLCurrentUserInfo()
    override init() {
        
    }
    
    var appType: String {
        set {
            UserDefaults.standard.set(newValue, forKey: APP_TYPE_KEY)
        }
        get {
            return UserDefaults.standard.string(forKey: APP_TYPE_KEY) ?? "app"
        }
        
    }

    var token: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: TOKEN_KEY)
        }
        get {
            return UserDefaults.standard.string(forKey: TOKEN_KEY)
        }
        
    }
    var uid: Int? {
        set {
            UserDefaults.standard.set(newValue, forKey: APP_UID)
        }
        get {
            return UserDefaults.standard.integer(forKey: APP_UID)
        }
        
    }
    
    //云信accid
    var accid: String {
        set {
            UserDefaults.standard.set(newValue, forKey: NETEASE_ACCID)
        }
        get {
            return UserDefaults.standard.string(forKey: NETEASE_ACCID) ?? ""
        }
        
    }
    //云信token
    var netease_token: String {
        set {
            UserDefaults.standard.set(newValue, forKey: NETEASE_TOKEN)
        }
        get {
            return UserDefaults.standard.string(forKey: NETEASE_TOKEN) ?? ""
        }
        
    }

}
