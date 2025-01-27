//
//  TGFeedNetworkManager.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/29.
//

import UIKit

class TGFeedNetworkManager: NSObject {
    static let shared = TGFeedNetworkManager()
    private override init() {}
    
    /// 获取动态详情
      /// - Parameters:
      ///   - feedId: Feed ID
      ///   - completion: 回调，返回动态详情模型
    func fetchFeedDetailInfo(withFeedId feedId: String, completion: @escaping (TGFeedResponse?, Error?) -> Void) {
        
        let path = "api/v2/feeds/\(feedId)"
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
                let feedResponse = try decoder.decode(TGFeedResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(feedResponse, nil)
                }
            } catch {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
            
        }
    }
    
    func fetchFeedCommentsList(withFeedId feedId: String, afterId: Int?, limit: Int, completion: @escaping (TGFeedContentResponse?, Error?) -> Void) {
        
        let path = "api/v2/feeds/\(feedId)/comments"
        var params: [String: Any] = [:]
        params.updateValue(limit, forKey: "limit")
        if let afterId = afterId {
            params.updateValue(afterId, forKey: "after")
        }
        
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .GET,
            params: params,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                var feedContentResponse = try decoder.decode(TGFeedContentResponse.self, from: data)
                
                // 处理数据，合并评论
                var allComments: [TGFeedCommentListModel] = []
                
                // 处理置顶评论，设置 isPinned 为 true
                if let pinnedComments = feedContentResponse.pinneds {
                    for var comment in pinnedComments {
                        comment.pinned = true // 设置置顶标志
                        allComments.append(comment)
                    }
                }
                
                // 处理普通评论，设置 isPinned 为 false
                if let regularComments = feedContentResponse.comments {
                    for var comment in regularComments {
                        comment.pinned = false // 设置普通评论标志
                        allComments.append(comment)
                    }
                }
                
                // 更新合并后的评论列表
                feedContentResponse.comments = allComments
                
                DispatchQueue.main.async {
                    completion(feedContentResponse, nil)
                }
            } catch {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    /// 提交评论
    ///
    /// - Parameters:
    ///   - type: 评论的类型/场景(必填)
    ///   - content: 评论内容(必填)
    ///   - sourceId: 评论的对象的id(必填)
    ///   - replyUserId: 若该评论是回复别人，则需传入被回复的用户的id(选填)
    ///   - complete: 请求回调，请求成功则通过comment字段返回服务器上关于该评论的数据
    func submitComment(for type: TGCommentType, content: String, sourceId: Int, replyUserId: Int?, contentType: CommentContentType, complete: @escaping ((_ comment: TGFeedCommentListModel?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        
        let path = "api/v2/feeds/\(sourceId)/comments"
        
        // 2. params
        var params: [String: Any] = [String: Any]()
        params.updateValue(content, forKey: "body")
        if let replyUserId = replyUserId {
            params.updateValue(replyUserId, forKey: "reply_user")
        }
        params.updateValue(contentType.rawValue, forKey: "content_type")
        
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: params,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                complete(nil, "network_problem".localized, false)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let feedContentResponse = try decoder.decode(TGCommentModelResponse.self, from: data)
                DispatchQueue.main.async {
                    complete(feedContentResponse.comment, feedContentResponse.message,  true)
                }
            } catch {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    complete(nil, "error_data_server_return".localized, false)
                }
            }
            
        }
    }
    

    func reactToFeed(id: Int, reaction: ReactionTypes?, complete: @escaping ((_ message: String?, _ result: Bool) -> Void)) -> Void {
        
        let path = "api/v2/feeds/\(id)/react"
        
        let method: HTTPMethod = reaction == nil ? .DELETE : .POST
        let parameters: [String: Any]? = reaction == nil ? nil : ["reaction_type": reaction!.apiName]
           
        
        TGNetworkManager.shared.request(
            urlPath: path,
            method: method,
            params: parameters,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                complete("network_problem".localized, false)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let feedContentResponse = try decoder.decode(TGCommentModelResponse.self, from: data)
                DispatchQueue.main.async {
                    complete(feedContentResponse.message, true)
                }
            } catch {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    complete("error_data_server_return".localized, false)
                }
            }
            
        }
    }
    
}
