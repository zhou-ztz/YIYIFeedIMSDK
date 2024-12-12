//
//  TGIMNetworkManager.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/10.
//

import UIKit

class TGIMNetworkManager: NSObject {
    
    ///创建白板房间
    class func createWhiteboard(roomName: String, completion: @escaping ((_ resultModel: WhiteBoardModel?, _ error: Error?) ->Void)) {
        let path = "api/v2/whiteboard/g2"
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

}
