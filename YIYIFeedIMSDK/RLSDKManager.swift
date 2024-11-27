//
//  RLSDKManager.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/22.
//

import UIKit

public class RLSDKManager: NSObject {

    public static let shared = RLSDKManager()
    
    var loginParma: RLLoginParma?
    
    public func initSDK(parma: RLLoginParma){
        self.loginParma = parma
        RLNIMSDKManager.shared.setupNIMSDK()
    }
    
    public func loginIM(success: @escaping ()->Void, failure: @escaping ()->Void){
        RLNIMSDKManager.shared.imLogin(with: self.loginParma?.imAccid ?? "", imToken: self.loginParma?.imToken ?? "") {
            success()
        } failure: {
            failure()
        }
    }

}
