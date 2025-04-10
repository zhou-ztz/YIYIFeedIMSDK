//
//  TGNewFriendsNetworkManager.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2024/12/30.
//

import UIKit
import ObjectMapper

class TGNewFriendsNetworkManager: NSObject {
    
    static let limit = 15
    /// 搜索已经加入 TS+ 的用户
    class func searchContacts(phones: [String], completion: @escaping ([TGUserInfoModel]?, Error?) -> Void){
        let path = "api/v2/user/find-by-phone"
        let parameter = ["phones": phones]
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: parameter,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            do {
               // let decoder = JSONDecoder()
                let users = Mapper<TGUserInfoModel>().mapArray(JSONString: "")
               // let response = try decoder.decode([TGUserInfoModel].self, from: data)
                DispatchQueue.main.async {
                    completion(users, nil)
                }
            } catch {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
            
        }
    }
    
    /// 搜索好友 user/follow-mutual
    class func searchMyFriend(offset: Int?, keyWordString: String?, extras:String = "", filterMerchants: String = "", completion: @escaping ((_ users: [TGUserInfoModel]?, _ error: Error?) -> Void)){
        let path = "api/v2/user/follow-mutual"
        var parameter: [String: Any] = ["offset": 0, "extras":extras]
        parameter["keyword"] = keyWordString
        if let offset = offset {
            parameter["offset"] = offset
        }
        if filterMerchants.count > 0 {
            parameter["filterMerchants"] = filterMerchants
        }
        let urlPath = TGAppUtil.shared.buildGetURL(path: path, parameters: parameter)
        
        TGNetworkManager.shared.request(
            urlPath: urlPath,
            method: .GET,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                let users = Mapper<TGUserInfoModel>().mapArray(JSONString: jsonString)
                DispatchQueue.main.async {
                    completion(users, nil)
                }
            } else {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
            
        }
    }
    
    /// 关注的商家用户
    class func searchMyMerchant(offset: Int?, keyWordString: String?, extras:String = "", filterMerchants: String = "", completion: @escaping ((_ users: [TGUserInfoModel]?, _ error: Error?) -> Void)){
        let path = "api/v2/user/followings"
        var parameter: [String: Any] = ["offset": 0, "extras":extras, "limit": TGNewFriendsNetworkManager.limit]
        parameter["keyword"] = keyWordString
        if let offset = offset {
            parameter["offset"] = offset
        }
        if filterMerchants.count > 0 {
            parameter["filterMerchants"] = filterMerchants
        }
        let urlPath = TGAppUtil.shared.buildGetURL(path: path, parameters: parameter)
        
        TGNetworkManager.shared.request(
            urlPath: urlPath,
            method: .GET,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                let users = Mapper<TGUserInfoModel>().mapArray(JSONString: jsonString)
                DispatchQueue.main.async {
                    completion(users, nil)
                }
            } else {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
            
        }
    }
    
    /// 获取指定的多个用户信息
    class func getUsersInfo(usersId: [Int], names: [String] = [], userNames: [String] = [], completion: @escaping (_ users: [TGUserInfoModel]?, _ error: Error?) -> Void) {
        
        let usersId = usersId.filter { $0 > 0 }
        let names = names.filter { return $0.isEmpty == false }
        let userNames = userNames.filter { return $0.isEmpty == false }
        if usersId.isEmpty && userNames.isEmpty && names.isEmpty {
            let error = NSError(domain: "TGNetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "usersId&userNames&names is empty"])
            completion(nil, error)
            return
        }
        
        // 应对usersId进行判断处理
        var path = ""
        if usersId.count > 0 {
            path = "api/v2/users" + "?id=" + (usersId.convertToString() ?? "")
        } else if names.count > 0 {
            path = "api/v2/users" + "?name=" + (names.convertToString() ?? "") + "&fetch_by=name"
            path = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        } else if userNames.count > 0 {
            path = "api/v2/users" + "?username=" + (userNames.convertToString() ?? "") + "&fetch_by=username&limit=\(userNames.count)"
            path = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        }
        
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .GET,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                let users = Mapper<TGUserInfoModel>().mapArray(JSONString: jsonString)
                DispatchQueue.main.async {
                    completion(users, nil)
                }
            } else {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
            
        }
    }

    /// 关注 、取消关注
    class func followUser(_ type: FollowStatus, userID: Int, completion: @escaping (_ status: Bool) -> Void) {
        let path = "api/v2/user/followings/\(userID.stringValue)"
        var method: HTTPMethod = .PUT
        if type == .follow {
            method = .PUT
        } else {
            method = .DELETE
        }
        
        TGNetworkManager.shared.request(
            urlPath: path,
            method: method,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    completion(true)
                }
            } else {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    completion(false)
                }
            }
            
        }
    }
}
