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
    
    public func initSDK(){
        RLNIMSDKManager.shared.setupNIMSDK()
        IMNotificationCenter.sharedCenter.start()
    }
    
    public func loginIM(parma: RLLoginParma, success: @escaping ()->Void, failure: @escaping ()->Void){
        self.loginParma = parma
        RLNIMSDKManager.shared.imLogin(with: self.loginParma?.imAccid ?? "", imToken: self.loginParma?.imToken ?? "") {
            success()
        } failure: {
            failure()
        }
    }

}
