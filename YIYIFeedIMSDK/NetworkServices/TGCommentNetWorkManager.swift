//
//  TGCommentNetWorkManager.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/3/28.
//

import UIKit
import ObjectMapper

class TGCommentNetWorkManager: NSObject {
    
    static let shared = TGCommentNetWorkManager()
    private override init() {}
    
    func pinComment(for commentId: Int, sourceId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        
        let path = "feeds/\(sourceId)/comments/\(commentId)/pinned"
        
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                complete(nil, false)
                return
            }
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    let comment = Mapper<BaseModelResponse>().map(JSONObject: jsonDict)
                    complete(comment?.message, true)
                }
            } catch {
                print("JSON 解析失败: \(error)")
                complete("error_data_server_return".localized, false)
            }
            
        }
    }
    
    func unpinComment(for commentId: Int, sourceId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        
        
        let path = "feeds/\(sourceId)/comments/\(commentId)/unpinned"
        
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                complete(nil, false)
                return
            }
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    let comment = Mapper<BaseModelResponse>().map(JSONObject: jsonDict)
                    complete(comment?.message, true)
                }
            } catch {
                print("JSON 解析失败: \(error)")
                complete("error_data_server_return".localized, false)
            }
            
        }
    }
    
    func deleteComment(for type: TGCommentType, commentId: Int, sourceId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        let path = "feeds/\(sourceId)/comments/\(commentId)"
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .DELETE,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                complete(nil, false)
                return
            }
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    let comment = Mapper<BaseModelResponse>().map(JSONObject: jsonDict)
                    complete(comment?.message, true)
                }
            } catch {
                print("JSON 解析失败: \(error)")
                complete("error_data_server_return".localized, false)
            }
            
        }
    }
    
}
