//
//  TGFeedNetworkManager.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/29.
//

import UIKit
import ObjectMapper

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
    
    
    func getFeeds(mediaType: FeedMediaType = .image,
    feedType: TGFeedListType = .hot,
    limit: Int = 20,
    after: Int? = nil,
    afterTime: String? = nil,
    country: String? = RLSDKManager.shared.loginParma?.countryCode,
    language: String? = RLSDKManager.shared.loginParma?.languageCode,
    campaignId: String?,
    hashtagId: String?, completion: @escaping ([TGFeedResponse]?, Error?) -> Void) {
        
        let path = "api/v2/feeds/media"
        var params: [String: Any] = [:]
        params.updateValue(limit, forKey: "limit")
        params.updateValue(mediaType.rawValue, forKey: "content_type")
        params.updateValue(feedType.rawValue, forKey: "type")
        if let campaignId = campaignId, campaignId.count > 0 {
            params["campaign_id"] = campaignId
        }
        if let hashtagId = hashtagId, hashtagId.count > 0 {
            params["hashtag_id"] = hashtagId
        }
        if mediaType == .miniVideo {
            /// 每次返回不同的小视频
            let lid: Int = Int(arc4random() % 10)
            params["lid"] = lid
        }
        switch feedType {
        case .user(let userId):
            params["user_id"] = userId
        default:
            break
        }
        if let country = country {
            params["country_code"] = country
        }
        if let language = language {
            params["language"] = language
        }
        if let after = after {
            params["after"] = after
        }
        if let afterTime = afterTime {
            params["after_time"] = afterTime
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
                let feedResponse = try decoder.decode([TGFeedResponse].self, from: data)
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
    
    
    func translateFeed(feedId: Int, complete: @escaping ((_ object: String?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        
        let path = "api/v2/feeds/\(feedId)/translation"
    
   
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .GET,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                complete(nil, "network_problem".localized, false)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(TGCommentModelResponse.self, from: data)
                DispatchQueue.main.async {
                    if response.code == 31 {
                        complete(response.message, response.message, false)
                    }else{
                        complete(response.message, response.message, true)
                    }
                    
                }
            } catch {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    complete("error_data_server_return".localized, "error_data_server_return".localized, false)
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
    
    func unpinFeed(feedId: Int, completion: @escaping (String, Int, Bool?) -> Void) {
        let path = "api/v2/feeds/\(feedId)/unpinned"
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                completion("network_problem".localized, 0, false)
                return
            }
            completion("", 0 , true)
           
        }
    }
    
    func pinFeed(feedId: Int, completion: @escaping (String, Int, Bool?) -> Void) {
        let path = "api/v2/feeds/\(feedId)/pinned"
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                completion("network_problem".localized, 0, false)
                return
            }
            completion("", 0 , true)
           
        }
        
    }
    
    func colloction(_ newState: Int, feedIdentity: Int, feedItem: FeedListCellModel?, complete: @escaping ((_ result: Bool) -> Void)) -> Void {
        
        let collectPath = newState == 1 ? "/collections" : "/uncollect"
        let path = "api/v2/feeds/" + "/\(feedIdentity)" +  collectPath
        
        let method: HTTPMethod = newState == 1 ? .POST : .DELETE
        
        TGNetworkManager.shared.request(
            urlPath: path,
            method: method,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                complete(false)
                return
            }
            complete(true)
        }
    }
    
    func commentPrivacy(_ newCommentState: Int, feedIdentity: Int, complete: @escaping ((_ result: Bool) -> Void)) -> Void {
        
        let path = "api/v2/feeds/comments/disable"
        
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                complete(false)
                return
            }
            complete(true)
        }
    }
    
    func deleteMoment(_ feedIdentity: Int, complete: @escaping ((_ success: Bool) -> Void)) {
        
        let path = "api/v2/feeds/\(feedIdentity)/currency"
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .DELETE,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                complete(false)
                return
            }
            complete(true)
        }
    }

    
    func getReactionList(id: Int, reactionType: ReactionTypes?, limit: Int = 20, after: String? = nil, completion: @escaping (_ response: TGFeedReactionsModel?, _ error: Error?) ->Void ) {
        let path = "api/v2/feeds/\(id)/reactions"
        var parameters: [String: Any] = ["limit": limit]
        if let after = after {
            parameters.updateValue(after, forKey: "after")
        }
        
        if let type = reactionType?.apiName {
            parameters.updateValue(type, forKey: "reaction_type")
        }
        
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .GET,
            params: parameters,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                
                let pinned = Mapper<TGFeedReactionsModel>().map(JSONString: jsonString)
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
    
    
    func releasePost(feedContent: String, feedId: Int, privacy: String, images: [Int]?, feedFrom: Int, topics: [TGTopicCommonModel]?, repostType: String?, repostId: Int?, customAttachment: SharedViewModel?, location: TGLocationModel?, isHotFeed: Bool, tagUsers: [UserInfoModel]?, tagMerchants: [UserInfoModel]?, tagVoucher: TagVoucherModel?, complete: @escaping ((_ feedId: Int?, _ error: NSError?) -> Void)) -> Void {
        
        let path = "api/v2/feeds"
        
        var params: [String: Any] = Dictionary()

        params["feed_content"] = feedContent
        params["language"] = feedContent.detectLanguages()
        params["feed_mark"] = feedId
        params["privacy"] = privacy
        params["feed_from"] = 3
        params["hot_feed"] = "\(isHotFeed)"
        var arrayImages: Array<Dictionary<String, Any>> = []
        if let arrImg = images, arrImg.isEmpty == false {
            for id in arrImg {
                var dic: Dictionary<String, Any> = [:]
                dic["id"] = id
                arrayImages.append(dic)
            }
            params["images"] = arrayImages
        }

        if let topics = topics {
            let topicArr = NSMutableArray()
            for item in topics {
                topicArr.append(item.id)
            }
            params["topics"] = topicArr
        }

        if let repostType = repostType, let repostId = repostId, repostId > 0 {
            params["repostable_type"] = repostType
            params["repostable_id"] = repostId
        }

        if let location = location {
            let locationObj: [String: Any] = [
                "lid" : location.locationID,
                "name": location.locationName,
                "lat": location.locationLatitude,
                "lng": location.locationLongtitude,
                "address": location.address.orEmpty
            ]
            params["location"] = locationObj
        }

        if let attachment = customAttachment {
            params["custom_attachment"] = attachment.generateDictionary()
        }
        
        //拿到关联的用户信息
        var atStrings = TGUtil.findTSAtStrings(inputStr: feedContent)
        atStrings = atStrings.map({$0.replacingOccurrences(of: "@", with: "")})
        
        if let users = tagUsers, users.count > 0 {
            let userIDs = TGUtil.generateMatchingUserIDs(tagUsers: users, atStrings: atStrings)
            params["tag_users"] = userIDs
        }
        if let merchants = tagMerchants, merchants.count > 0 {
            let merchantIDs = TGUtil.generateMatchingUserIDs(tagUsers: merchants, atStrings: atStrings)
            params["feed_rewards_link_yippi_user_ids"] = merchantIDs
        }

        var hashtags = TGUtil.findAllHashtagStrings(inputStr: feedContent)
        hashtags = hashtags.map({$0.replacingOccurrences(of: "#", with: "")})
        hashtags = hashtags.map({$0.replacingOccurrences(of: " ", with: "")})
        if hashtags.count > 0 {
            params["hashtag_names"] = hashtags
        }
        
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: params,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                complete(nil, TGErrorCenter.create(With: TGErrorCode.networkError))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let feedReleaseResponse = try decoder.decode(TGFeedReleaseModelResponse.self, from: data)
                DispatchQueue.main.async {
                    complete(feedReleaseResponse.id, nil)
                }
            } catch {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    complete(nil, nil)
                }
            }
            
        }
    }
    
    
    
    func editRejectFeed(feedID: String, feedContent: String, feedId: Int, privacy: String, images: [Int]?, feedFrom: Int, topics: [TGTopicCommonModel]?, repostType: String?, repostId: Int?, customAttachment: SharedViewModel?, location: TGLocationModel?, isHotFeed: Bool, tagUsers: [UserInfoModel]?, tagMerchants: [UserInfoModel]?, tagVoucher: TagVoucherModel?, complete: @escaping ((_ feedId: Int?, _ error: NSError?) -> Void)) -> Void {
        
        let path = "api/v2/feeds/reject/\(feedID)"
        
        var params: [String: Any] = Dictionary()

        params["feed_content"] = feedContent
        params["language"] = feedContent.detectLanguages()
        params["feed_mark"] = feedId
        params["privacy"] = privacy
        params["feed_from"] = 3
        params["hot_feed"] = "\(isHotFeed)"
        var arrayImages: Array<Dictionary<String, Any>> = []
        if let arrImg = images, arrImg.isEmpty == false {
            for id in arrImg {
                var dic: Dictionary<String, Any> = [:]
                dic["id"] = id
                arrayImages.append(dic)
            }
            params["images"] = arrayImages
        }

        if let topics = topics {
            let topicArr = NSMutableArray()
            for item in topics {
                topicArr.append(item.id)
            }
            params["topics"] = topicArr
        }

        if let repostType = repostType, let repostId = repostId, repostId > 0 {
            params["repostable_type"] = repostType
            params["repostable_id"] = repostId
        }

        if let location = location {
            let locationObj: [String: Any] = [
                "lid" : location.locationID,
                "name": location.locationName,
                "lat": location.locationLatitude,
                "lng": location.locationLongtitude,
                "address": location.address.orEmpty
            ]
            params["location"] = locationObj
        }

        if let attachment = customAttachment {
            params["custom_attachment"] = attachment.generateDictionary()
        }
        
        //拿到关联的用户信息
        var atStrings = TGUtil.findTSAtStrings(inputStr: feedContent)
        atStrings = atStrings.map({$0.replacingOccurrences(of: "@", with: "")})
        
        if let users = tagUsers, users.count > 0 {
            let userIDs = TGUtil.generateMatchingUserIDs(tagUsers: users, atStrings: atStrings)
            params["tag_users"] = userIDs
        }
        if let merchants = tagMerchants, merchants.count > 0 {
            let merchantIDs = TGUtil.generateMatchingUserIDs(tagUsers: merchants, atStrings: atStrings)
            params["feed_rewards_link_yippi_user_ids"] = merchantIDs
        }

        var hashtags = TGUtil.findAllHashtagStrings(inputStr: feedContent)
        hashtags = hashtags.map({$0.replacingOccurrences(of: "#", with: "")})
        hashtags = hashtags.map({$0.replacingOccurrences(of: " ", with: "")})
        if hashtags.count > 0 {
            params["hashtag_names"] = hashtags
        }
        
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: params,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                complete(nil, TGErrorCenter.create(With: TGErrorCode.networkError))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let feedReleaseResponse = try decoder.decode(TGFeedReleaseModelResponse.self, from: data)
                DispatchQueue.main.async {
                    complete(feedReleaseResponse.id, nil)
                }
            } catch {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    complete(nil, nil)
                }
            }
            
        }
    }
    
    
    func editRejectShortVideo(feedID: String, shortVideoID: Int, coverImageID: Int, feedMark: Int, feedContent: String?, privacy: String, feedFrom: Int, topics: [TGTopicCommonModel]?, location: TGLocationModel?, isHotFeed: Bool, soundId: String?, videoType: VideoType, tagUsers: [UserInfoModel]?, tagMerchants: [UserInfoModel]?, tagVoucher: TagVoucherModel?, complete: @escaping ((_ feedId: Int?, _ error: NSError?) -> Void)) -> Void {
        
        let path = "api/v2/feeds/reject/\(feedID)"
        
        var params: [String: Any] = Dictionary()

        params["feed_content"] = feedContent
        params["language"] = feedContent?.detectLanguages()
        params["feed_mark"] = feedID
        params["privacy"] = privacy
        params["feed_from"] = 3
        params["hot_feed"] = "\(isHotFeed)"
        if shortVideoID != 0 && coverImageID != 0 {
            params["video_id"] = "\(shortVideoID)"
            params["video_cover_id"] = "\(coverImageID)"
        }

        if let topics = topics {
            let topicArr = NSMutableArray()
            for item in topics {
                topicArr.append(item.id)
            }
            params["topics"] = topicArr
        }
        
        if let location = location {
            let locationObj: [String: Any] = [
                "lid" : location.locationID,
                "name": location.locationName,
                "lat": location.locationLatitude,
                "lng": location.locationLongtitude,
                "address": location.address.orEmpty
            ]
            params["location"] = locationObj
        }
        
        //拿到关联的用户信息
        var atStrings = TGUtil.findTSAtStrings(inputStr: feedContent ?? "")
        atStrings = atStrings.map({$0.replacingOccurrences(of: "@", with: "")})
        
        if let users = tagUsers, users.count > 0 {
            let userIDs = TGUtil.generateMatchingUserIDs(tagUsers: users, atStrings: atStrings)
            params["tag_users"] = userIDs
        }
        if let merchants = tagMerchants, merchants.count > 0 {
            let merchantIDs = TGUtil.generateMatchingUserIDs(tagUsers: merchants, atStrings: atStrings)
            params["feed_rewards_link_yippi_user_ids"] = merchantIDs
        }

        var hashtags = TGUtil.findAllHashtagStrings(inputStr: feedContent ?? "")
        hashtags = hashtags.map({$0.replacingOccurrences(of: "#", with: "")})
        hashtags = hashtags.map({$0.replacingOccurrences(of: " ", with: "")})
        if hashtags.count > 0 {
            params["hashtag_names"] = hashtags
        }
        
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: params,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                complete(nil, TGErrorCenter.create(With: TGErrorCode.networkError))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let feedReleaseResponse = try decoder.decode(TGFeedReleaseModelResponse.self, from: data)
                DispatchQueue.main.async {
                    complete(feedReleaseResponse.id, nil)
                }
            } catch {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    complete(nil, nil)
                }
            }
            
        }
    }
    
    func postShortVideo(shortVideoID: Int, coverImageID: Int, feedMark: Int, feedContent: String?, privacy: String, feedFrom: Int, topics: [TGTopicCommonModel]?, location: TGLocationModel?, isHotFeed: Bool, soundId: String?, videoType: VideoType, tagUsers: [UserInfoModel]?, tagMerchants: [UserInfoModel]?, tagVoucher: TagVoucherModel?, complete: @escaping((_ feedId: Int?, _ error: NSError?) -> Void)) {
        var param: [String: Any] = Dictionary()

        if let content = feedContent {
            param["feed_content"] = content
            param["language"] = content.detectLanguages()
        }

        param["feed_from"] = feedFrom
        param["feed_mark"] = feedMark
        param["privacy"] = privacy
        param["hot_feed"] = "\(isHotFeed)"

        var videoParam: [String: Any] = ["video_id": shortVideoID, "cover_id": coverImageID]
        if let soundId = soundId {
            videoParam["sound_id"] = soundId
        }
        param["video"] = videoParam

        if let topics = topics {
            let topicArr = NSMutableArray()
            for item in topics {
                topicArr.append(item.id)
            }
            param["topics"] = topicArr
        }

        if let location = location {
            let locationObj: [String: Any] = [
                "lid" : location.locationID,
                "name": location.locationName,
                "lat": location.locationLatitude,
                "lng": location.locationLongtitude,
                "address": location.address.orEmpty
            ]
            param["location"] = locationObj
        }
        
        //拿到关联的用户信息
        var atStrings = TGUtil.findTSAtStrings(inputStr: feedContent ?? "")
        atStrings = atStrings.map({$0.replacingOccurrences(of: "@", with: "")})
        
        if let users = tagUsers, users.count > 0 {
            let userIDs = TGUtil.generateMatchingUserIDs(tagUsers: users, atStrings: atStrings)
            param["tag_users"] = userIDs
        }
        if let merchants = tagMerchants, merchants.count > 0 {
            let merchantIDs = TGUtil.generateMatchingUserIDs(tagUsers: merchants, atStrings: atStrings)
            param["feed_rewards_link_yippi_user_ids"] = merchantIDs
        }

        var hashtags = TGUtil.findAllHashtagStrings(inputStr: feedContent ?? "")
        hashtags = hashtags.map({$0.replacingOccurrences(of: "#", with: "")})
        hashtags = hashtags.map({$0.replacingOccurrences(of: " ", with: "")})
        if hashtags.count > 0 {
            param["hashtag_names"] = hashtags
        }

        if let tagVoucher = tagVoucher {
            let tagVoucherObjc: [String: Any] = [
                "tagged_voucher_id" : tagVoucher.taggedVoucherId,
                "tagged_voucher_title": tagVoucher.taggedVoucherTitle,
            ]
            param["tag_voucher"] = tagVoucherObjc
        }

        let path = videoType.path

        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: param,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                complete(nil, TGErrorCenter.create(With: TGErrorCode.networkError))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let feedReleaseResponse = try decoder.decode(TGFeedReleaseModelResponse.self, from: data)
                DispatchQueue.main.async {
                    complete(feedReleaseResponse.id, nil)
                }
            } catch {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    complete(nil, nil)
                }
            }
            
        }

    }
}
