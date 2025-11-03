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
    func getUserInfo(_ userIdentities: [Int], complete: @escaping ((_ info: Any?, _ userInfoModels: [TGUserInfoModel]?, _ error: NSError?) -> Void)) {
        //assert(!userIdentities.isEmpty, "查询用户信息数组为空")
        if userIdentities.isEmpty {
            complete(nil, nil, NSError(domain: "查询用户信息数组为空", code: -1, userInfo: nil))
            return
        }
        //这里需要进一步解析
        let path = "api/v2/users" + "?id=" + userIdentities.convertToString()! + "&limit=50"
      
        TGNetworkManager.shared.request(urlPath: path, method: .GET) { data, _, error in
            guard let data = data, error == nil else {
                let error = TGErrorCenter.create(With: .networkError)
                complete(nil, nil, error)
                return
            }
            var tempUserInfoModels = [TGUserInfoModel]()
            if let jsonString = String(data: data, encoding: .utf8), let datas = Mapper<TGUserInfoModel>().mapArray(JSONString: jsonString) {
                
                tempUserInfoModels.append(contentsOf: datas)
            }
            if let jsonString = String(data: data, encoding: .utf8), let userModel = Mapper<TGUserInfoModel>().map(JSONString: jsonString) {
                
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
    
    func taggedBranchList(offset: Int?, keyWordString: String?, limit: Int = TGNewFriendsNetworkManager.limit,
                          longitude: String = TGDevice.getLongitude(), latitude: String = TGDevice.getLatitude(),
                          complete: @escaping ((_ branchModel: TGTaggedBranchModel?, _ error: NSError?) -> Void)) {
        
        
        let path = "api/v2/user/merchant/taggedBranchList"
        var parameter: [String: Any] = ["offset": 1, "limit": limit]
        
        if let offset = offset {
            parameter["offset"] = offset
        }
        
        parameter["keyword"] = keyWordString
        parameter["longitude"] = longitude
        parameter["latitude"] = latitude

        TGNetworkManager.shared.request(urlPath: path, method: .GET) { data, _, error in
            guard let data = data, error == nil else {
                let error = TGErrorCenter.create(With: .networkError)
                complete(nil, error)
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                let model = Mapper<TGTaggedBranchModel>().map(JSONString: jsonString)
                DispatchQueue.main.async {
                    complete(model, nil)
                }
            } else {
                let nserror = NSError(domain: "TGUserNetworkingManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "json 解析失败"])
                DispatchQueue.main.async {
                    complete(nil, nserror)
                }
            }
            
        }
    }
}
