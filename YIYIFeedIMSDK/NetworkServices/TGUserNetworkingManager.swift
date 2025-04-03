//
//  TGUserNetworkingManager.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/3/27.
//

import UIKit
import ObjectMapper

class TGUserNetworkingManager: NSObject {
    static let shared = TGUserNetworkingManager()
    private override init() {}
    
    /// 获取用户信息
    ///
    /// - Parameters:
    ///   - userIdentities: 用户标识数组
    ///   - complete: 结果
    func getUserInfo(_ userIdentities: [Int], complete: @escaping ((_ info: Any?, _ userInfoModels: [UserInfoModel]?, _ error: NSError?) -> Void)) {
        //assert(!userIdentities.isEmpty, "查询用户信息数组为空")
        if userIdentities.isEmpty {
            complete(nil, nil, NSError(domain: "查询用户信息数组为空", code: -1, userInfo: nil))
            return
        }
        //这里需要进一步解析
        let path = "api/v2/users/" + "?id=" + userIdentities.convertToString()! + "&limit=50"
      
        TGNetworkManager.shared.request(urlPath: path, method: .GET) { data, _, error in
            guard let data = data, error == nil else {
                let error = TGErrorCenter.create(With: .networkError)
                complete(nil, nil, error)
                return
            }
            var tempUserInfoModels = [UserInfoModel]()
            if let jsonString = String(data: data, encoding: .utf8), let datas = Mapper<UserInfoModel>().mapArray(JSONString: jsonString) {
                
                tempUserInfoModels.append(contentsOf: datas)
            }
            if let jsonString = String(data: data, encoding: .utf8), let userModel = Mapper<UserInfoModel>().map(JSONString: jsonString) {
                
                tempUserInfoModels.append(userModel)
            }
            DispatchQueue.global().async {
                tempUserInfoModels.forEach { user in
                    user.save()
                }
            }
           
            complete(tempUserInfoModels, tempUserInfoModels, nil)
        }
    }
}
