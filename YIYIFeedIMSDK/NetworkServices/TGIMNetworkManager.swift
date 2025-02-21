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
        let path = "api/v2/user/pinned_message/\(id.stringValue)"
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
            ///处理数据不需要解析情况
            if data.bytes.count == 0 {
                completion(nil, nil)
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
    
    ///  获取 个人请求添加好友消息列表
    class func getRequestMessage(limit: Int = 20, after: Int = 0, completion: @escaping (_ requestList: [TGMessageRequestModel]?, _ error: Error?) ->Void ) {
        let path = "api/v2/user/message/pendingRequest?limit=\(limit)&after=\(after)"
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
                let pinned = Mapper<TGMessageRequestModel>().mapArray(JSONString: jsonString)
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
    
    ///  关注好友
    class func followFriend(userId: Int, completion: @escaping (_ error: Error?) ->Void ) {
        let path = "api/v2/user/message/addFriend"
        let parameters: [String: Any] = ["user_id": userId]
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: parameters,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                completion(error)
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    completion(nil)
                }
            } else {
                let nserror = NSError(domain: "TGIMNetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "json 解析失败"])
                DispatchQueue.main.async {
                    completion( nserror)
                }
            }
        }
    }

    ///  关注好友
    class func deleteMessageRequest(requestId: Int, completion: @escaping (_ error: Error?) ->Void ) {
        let path = "api/v2/user/message/pendingRequest"
        let parameters: [String: Any] = ["delete_type": "single", "request_id": requestId]
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .DELETE,
            params: parameters,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                completion(error)
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    completion(nil)
                }
            } else {
                let nserror = NSError(domain: "TGIMNetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "json 解析失败"])
                DispatchQueue.main.async {
                    completion( nserror)
                }
            }
        }
    }
    
    /// 获取会议列表
    class func getMeetingList(perPage: String = "15", page: String, completion: @escaping (_ requestList: QuertMeetingListModel?, _ error: Error?) ->Void ) {
        let path = "api/v2/meeting/list?perPage=\(perPage)&page=\(page)"
        
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
                let model = Mapper<QuertMeetingListModel>().map(JSONString: jsonString)
                DispatchQueue.main.async {
                    completion(model, nil)
                }
            } else {
                let nserror = NSError(domain: "TGIMNetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "json 解析失败"])
                DispatchQueue.main.async {
                    completion(nil, nserror)
                }
            }
        }
    }
    
    ///获取用户会议付费信息
    class func quertUserMeetingPayInfo(completion: @escaping (_ requestList: MeetingPayInfo?, _ error: Error?) ->Void) {
        let path = "api/v2/meeting/paid/info"
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
                let model = Mapper<MeetingPayInfo>().map(JSONString: jsonString)
                DispatchQueue.main.async {
                    completion(model, nil)
                }
            } else {
                let nserror = NSError(domain: "TGIMNetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "json 解析失败"])
                DispatchQueue.main.async {
                    completion(nil, nserror)
                }
            }
        }
    }
    
    ///创建会议  CreateMeetingResponse
    class func createMeeting(param: [String: Any], completion: @escaping (_ requestdata: CreateMeetingResponse?, _ error: Error?) ->Void) {
        let path = "api/v2/meeting/create"
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: param,
            headers: nil
        ) { data, _, error1 in
            guard let data = data, error1 == nil else {
                completion(nil, error1)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(CreateMeetingResponse.self, from: data)
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
    /// 加入会议
    class func joinMeeting(meetingNum: String, completion: @escaping (_ requestdata: JoinMeetingResponse?, _ error: Error?) ->Void) {
        let path = "api/v2/meeting/member/join"
        let param: [String: Any] = ["meetingNum" : meetingNum]
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: param,
            headers: nil
        ) { data, _, error1 in
            guard let data = data, error1 == nil else {
                completion(nil, error1)
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(JoinMeetingResponse.self, from: data)
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
    /// 获取会议账号 "netease/meeting"
    class func quertMeetingKitAccount(completion: @escaping (_ requestdata: MeetingKitAccountModel?, _ error: Error?) ->Void) {
        let path = "api/v2/netease/meeting"
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                let model = Mapper<MeetingKitAccountModel>().map(JSONString: jsonString)
                DispatchQueue.main.async {
                    completion(model, nil)
                }
            } else {
                let nserror = NSError(domain: "TGIMNetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "json 解析失败"])
                DispatchQueue.main.async {
                    completion(nil, nserror)
                }
            }
        }
    }
    
    ///会议支付 
    class func meetingPayment(pin: String, completion: @escaping (_ requestdata: MeetingPayment?, _ error: Error?) ->Void) {
        let path = "api/v2/meeting/payment?pin=\(pin)"
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                let model = Mapper<MeetingPayment>().map(JSONString: jsonString)
                DispatchQueue.main.async {
                    completion(model, nil)
                }
            } else {
                let nserror = NSError(domain: "TGIMNetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "json 解析失败"])
                DispatchQueue.main.async {
                    completion(nil, nserror)
                }
            }
        }
    }
    
    /// OpenEgg 打开红包
    /**case .personal: return "/wallet/api/eggs/personal"
     case .group: return "/wallet/api/eggs/group"
     case .live: return "/wallet/api/eggs/live/v1"*/
    class func openEgg(eggId: Int, isGroup: Bool, completion: @escaping (ClaimEggResponse?, Error?) -> Void) {
        let path: String = isGroup == true ? "wallet/api/eggs/group" : "wallet/api/eggs/personal"
        let param: [String: Any] = ["red_packet_id" : eggId]
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .PATCH,
            params: param,
            headers: nil
        ) { data, _, error1 in
            guard let data = data, error1 == nil else {
                completion(nil, error1)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ClaimEggResponse.self, from: data)
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
    
    ///语音翻译
    class func translateTexts(message: String, completion: @escaping (IMTranslateModel?, Error?) -> Void) {
        let path = "/api/v2/translates/text"
        let param: [String: Any] = ["text" : message]
        
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: param,
            headers: nil
        ) { data, _, error1 in
            guard let data = data, error1 == nil else {
                completion(nil, error1)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(IMTranslateModel.self, from: data)
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
}
