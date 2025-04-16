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
        
        let path = "api/v2/feeds/\(sourceId)/comments/\(commentId)/pinned"
        
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard error == nil else {
                complete(nil, false)
                return
            }
            complete("", true)
        }
    }
    
    func unpinComment(for commentId: Int, sourceId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        
        
        let path = "api/v2/feeds/\(sourceId)/comments/\(commentId)/unpinned"
        
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .DELETE,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard error == nil else {
                complete(nil, false)
                return
            }
            complete("", true)
            
        }
    }
    
    func deleteComment(for type: TGCommentType, commentId: Int, sourceId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        let path = "api/v2/feeds/\(sourceId)/comments/\(commentId)"
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .DELETE,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard error == nil else {
                complete(nil, false)
                return
            }
            complete("", true)
        }
    }
    
}
