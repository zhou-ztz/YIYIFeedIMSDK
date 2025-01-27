//
//  TGIMNetworkManager.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/10.
//

import UIKit
import ObjectMapper

class TGIMNetworkManager: NSObject {
    
    ///创建白板房间
    class func createWhiteboard(roomName: String, completion: @escaping ((_ resultModel: WhiteBoardModel?, _ error: Error?) ->Void)) {
        let path = "api/v2/whiteboard/g2"
        let parameter = ["channel_name": roomName]
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
                let decoder = JSONDecoder()
                let response = try decoder.decode(WhiteBoardModel.self, from: data)
                DispatchQueue.main.async {
                    completion(response, nil)
                }
            } catch {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
            
        }
    }
    
    ///获取白板房间鉴权
    class func getwhiteboardAuth(completion: @escaping ((_ resultModel: WhiteBoardAuth?, _ error: Error?) ->Void)) {
        let path = "api/v2/auth/whiteboard"
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
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(WhiteBoardAuth.self, from: data)
                DispatchQueue.main.async {
                    completion(response, nil)
                }
            } catch {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
            
        }
    }
    
    /// 获取当前坐标的地址列表
    class func locationSearchList(queryString: String,
                                  lat: Double = 0.0,
                                  lng: Double = 0.0,
                                  completion: @escaping (([TGLocationModel]?, Error?) -> Void)) {
        let path = "api/v2/feeds/location?query=\(queryString)&lat=\(lat)&lng=\(lng)"
        
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
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(FourSquareLocationModel.self, from: data)
                DispatchQueue.main.async {
                    completion(response.locations, nil)
                }
            } catch {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
            
        }
        
    }
    /// delete pinned message
//    let deletePinnedMessage = Request<PinnedMessageModel>(method: .delete, path: "user/pinned_message/{id}", replacers: ["{id}"])
//    
//    /// store pinned message
//    let storePinnedMessage = Request<PinnedMessageModel>(method: .post, path: "user/pinned_message", replacers: [])
//    
//    /// update pinned message
//    let updatePinnedMessage = Request<PinnedMessageModel>(method: .put, path: "user/pinned_message", replacers: [])
    /// 群组pinned list
    class func showGroupPinnedMessage(group_id: String, completion: @escaping ((_ resultModel: [PinnedMessageModel]?, _ error: Error?) -> Void)){
        let path = "api/v2/user/pinned_message/group/\(group_id)"
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
                let pinneds = Mapper<PinnedMessageModel>().mapArray(JSONString: jsonString)
                DispatchQueue.main.async {
                    completion(pinneds, nil)
                }
            } else {
                let nserror = NSError(domain: "TGIMNetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "json 解析失败"])
                DispatchQueue.main.async {
                    completion(nil, nserror)
                }
            }
            
        }
 
    }
    
    // store pinned message list
    class func storePinnedMessage(imMsgId: String, imGroupId: String = "", content: String = "", deleteFlag: Bool = false, completion: @escaping ((_ resultModel: PinnedMessageModel?, _ error: Error?) -> Void)){
        let path = "api/v2/user/pinned_message"
        let parameter: [String: Any] = ["im_msg_id": "\(imMsgId)", "im_group_id": "\(imGroupId)", "content": "\(content)", "delete_flag": deleteFlag]
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
            if let jsonString = String(data: data, encoding: .utf8) {
                let pinned = Mapper<PinnedMessageModel>().map(JSONString: jsonString)
                DispatchQueue.main.async {
                    completion(pinned, nil)
                }
            } else {
                let nserror = NSError(domain: "TGIMNetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "json 解析失败"])
                DispatchQueue.main.async {
                    completion(nil, nserror)
                }
            }

            
        }
    }
    // delete pinned message
    class func deletePinnedMessage(id: Int, completion: @escaping ((_ resultModel: PinnedMessageModel?, _ error: Error?) -> Void)){
        let path = "api/v2/user/pinned_message/\(id)"
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .DELETE,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                let pinned = Mapper<PinnedMessageModel>().map(JSONString: jsonString)
                DispatchQueue.main.async {
                    completion(pinned, nil)
                }
            } else {
                let nserror = NSError(domain: "TGIMNetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "json 解析失败"])
                DispatchQueue.main.async {
                    completion(nil, nserror)
                }
            }

            
        }
    }

}
