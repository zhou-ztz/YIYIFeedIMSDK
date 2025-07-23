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
    func fetchFeedDetailInfo(withFeedId feedId: String, completion: @escaping (FeedListModel?, Error?) -> Void) {
        
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
            if let jsonString = String(data: data, encoding: .utf8) {
                let model = Mapper<FeedListModel>().map(JSONString: jsonString)
                guard let originalModel = model else {
                    return
                }
                let group = DispatchGroup()
                group.enter()
                self.requestUserInfo(to: [originalModel]) { (datas, message, status) in
                    group.leave()
                }
                // 动态转发，好像移除了，暂时注释
//                if originalModel.repostId > 0 {
//                    group.enter()
//                    FeedListNetworkManager.requestRepostFeedInfo(feedIDs: [originalModel.repostId]) { models in
//                        group.leave()
//                    }
//                }
                
                originalModel.save()
                group.notify(queue: .main) {
                    completion(originalModel, nil)
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
                  hashtagId: String?, completion: @escaping ([FeedListCellModel]?, Error?) -> Void) {
        
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
            if let jsonString = String(data: data, encoding: .utf8), let models = Mapper<FeedListModel>().mapArray(JSONString: jsonString) {
                
                self.requestUserInfo(to: models) { (result, message, status) in
                    
                    guard let result = result else {
                        completion(nil, nil)
                        return
                    }
                
                    completion(result.compactMap { FeedListCellModel(feedListModel: $0) }, nil)
                }
            } else {
                let nserror = NSError(domain: "TGFeedNetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "json 解析失败"])
                DispatchQueue.main.async {
                    completion(nil, nserror)
                }
            }
        }
    }
    
     func requestUserInfo(to feeds: [FeedListModel], complete: @escaping ([FeedListModel]?, String?, Bool) -> Void) {
        // 1.取出所有用户信息，过滤重复信息
        let userIds = Array(Set(feeds.flatMap { $0.userIds() }))
        // 2.发起网络请求
        TGUserNetworkingManager.shared.getUserInfo(userIds) { (_, models, _) in
            guard let models = models else {
                // TODO: 错误信息应该使用后台返回信息，但由于这个 API 没有处理用户信息接口错误信息。
                // 当然更不应该在调用 API 的地方处理后台返回错误信息。
                // 就先写一个假的数据，等这 API 更新后再替换
                complete(nil,  "network_problem".localized, false)
                return
            }
            // 3.将用户信息和动态信息匹配
            let userDic = models.toDictionary { $0.userIdentity }
            for feed in feeds {
                feed.set(userInfos: userDic)
            }
            
            DispatchQueue.global().async {
                models.forEach { user in
                    user.save()
                }
            }
            
            complete(feeds, nil, true)
        }
    }
    
    func fetchFeedCommentsList(withFeedId feedId: String, afterId: Int?, limit: Int, completion: @escaping ([FeedCommentListCellModel]?, Error?) -> Void) {
        
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
                if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    var comments: [FeedListCommentModel] = []
                    var commentList: [FeedListCommentModel] = []
                    
                    if let topCommentList = Mapper<FeedListCommentModel>().mapArray(JSONObject: jsonDict["pinneds"]) {
                        for topComment in topCommentList {
                            topComment.pinned = true
                        }
                        commentList += topCommentList
                    }
                    
                    if var normalCommentList = Mapper<FeedListCommentModel>().mapArray(JSONObject: jsonDict["comments"]) {
                        let topComment = commentList
                        if topComment.isEmpty {
                            commentList += normalCommentList
                        } else {
                            normalCommentList = normalCommentList.filter { comment in
                                !topComment.contains { $0.id == comment.id }
                            }
                            commentList += normalCommentList
                        }
                    }
                    
                    comments = commentList
                    let returnComments = comments.map { FeedCommentListCellModel(feedListCommentModel: $0) }
                    completion(returnComments, nil)
                } else {
                    completion(nil, nil)
                }
            } catch {
                print("JSON 解析失败: \(error)")
                completion(nil, error)
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
    func submitComment(for type: TGCommentType, content: String, sourceId: Int, replyUserId: Int?, contentType: CommentContentType, complete: @escaping ((_ comment: TGCommentModel?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        
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
                if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let comment = Mapper<TGCommentModel>().map(JSONObject: jsonDict["comment"])
                    complete(comment, "", true)
                }
            } catch {
                print("JSON 解析失败: \(error)")
                complete(nil, "error_data_server_return".localized, false)
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
                let response = try decoder.decode(TGBaseModelResponse.self, from: data)
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
            guard error == nil else {
                complete("network_problem".localized, false)
                return
            }
            complete(nil, true)
            
        }
    }
    
    func unpinFeed(feedId: Int, completion: @escaping (String, Int, Bool?) -> Void) {
        let path = "api/v2/feeds/\(feedId)/unpinned"
        var parameters : [String : Any] = [:]
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .DELETE,
            params: parameters,
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
        var parameters : [String : Any] = [:]
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: parameters,
            headers: nil
        ) { data, _, error in
            guard error == nil else {
                completion("network_problem".localized, 0, false)
                return
            }
            completion("", 0 , true)
           
        }
        
    }
    
    func forwardFeed(feedId: Int, completion: @escaping (String, Int, Bool?) -> Void) {
        let path = "api/v2/feeds/\(feedId)/forward/record"
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard error == nil else {
                completion("network_problem".localized, 0, false)
                return
            }
            completion("", 0 , true)
           
        }
    }
    
    func colloction(_ newState: Int, feedIdentity: Int, feedItem: FeedListCellModel?, complete: @escaping ((_ result: Bool) -> Void)) -> Void {
        
        let collectPath = newState == 1 ? "/collections" : "/uncollect"
        let path = "api/v2/feeds/" + "\(feedIdentity)" +  collectPath
        
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
        
        let path = "api/v2/feeds/\(feedIdentity)/comments/disable"
        let parametars: [String : Any] = ["disable": newCommentState == 1 ? "1" : "0"]
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: parametars,
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
    
    
    func releasePost(feedContent: String, feedId: Int, privacy: String, images: [Int]?, feedFrom: Int, topics: [TGTopicCommonModel]?, repostType: String?, repostId: Int?, customAttachment: SharedViewModel?, location: TGLocationModel?, isHotFeed: Bool, tagUsers: [TGUserInfoModel]?, tagMerchants: [TGUserInfoModel]?, tagVoucher: TagVoucherModel?, complete: @escaping ((_ feedId: Int?, _ error: NSError?) -> Void)) -> Void {
        
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
        if let tagVoucher = tagVoucher {
            let tagVoucherObjc: [String: Any] = [
                "tagged_voucher_id" : tagVoucher.taggedVoucherId,
                "tagged_voucher_title": tagVoucher.taggedVoucherTitle,
            ]
            params["tag_voucher"] = tagVoucherObjc
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
    
    
    
    func editRejectFeed(feedID: String, feedContent: String, feedId: Int, privacy: String, images: [Int]?, feedFrom: Int, topics: [TGTopicCommonModel]?, repostType: String?, repostId: Int?, customAttachment: SharedViewModel?, location: TGLocationModel?, isHotFeed: Bool, tagUsers: [TGUserInfoModel]?, tagMerchants: [TGUserInfoModel]?, tagVoucher: TagVoucherModel?, complete: @escaping ((_ feedId: Int?, _ error: NSError?) -> Void)) -> Void {
        
        let path = "api/v2/feeds/reject/\(feedID)"
        
        var params: [String: Any] = Dictionary()

        params["feed_content"] = feedContent
        params["language"] = feedContent.detectLanguages()
        params["feed_mark"] = feedId
        params["privacy"] = privacy
        params["feed_from"] = 3
        params["hot_feed"] = "\(isHotFeed)"
        
        if let arrImg = images, arrImg.isEmpty == false {
            params["images"] = arrImg
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
        if let tagVoucher = tagVoucher {
            let tagVoucherObjc: [String: Any] = [
                "tagged_voucher_id" : tagVoucher.taggedVoucherId,
                "tagged_voucher_title": tagVoucher.taggedVoucherTitle,
            ]
            params["tag_voucher"] = tagVoucherObjc
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
    
    
    func editRejectShortVideo(feedID: String, shortVideoID: Int, coverImageID: Int, feedMark: Int, feedContent: String?, privacy: String, feedFrom: Int, topics: [TGTopicCommonModel]?, location: TGLocationModel?, isHotFeed: Bool, soundId: String?, videoType: TGVideoType, tagUsers: [TGUserInfoModel]?, tagMerchants: [TGUserInfoModel]?, tagVoucher: TagVoucherModel?, complete: @escaping ((_ feedId: Int?, _ error: NSError?) -> Void)) -> Void {
        
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
        if let tagVoucher = tagVoucher {
            let tagVoucherObjc: [String: Any] = [
                "tagged_voucher_id" : tagVoucher.taggedVoucherId,
                "tagged_voucher_title": tagVoucher.taggedVoucherTitle,
            ]
            params["tag_voucher"] = tagVoucherObjc
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
    
    func postShortVideo(shortVideoID: Int, coverImageID: Int, feedMark: Int, feedContent: String?, privacy: String, feedFrom: Int, topics: [TGTopicCommonModel]?, location: TGLocationModel?, isHotFeed: Bool, soundId: String?, videoType: TGVideoType, tagUsers: [TGUserInfoModel]?, tagMerchants: [TGUserInfoModel]?, tagVoucher: TagVoucherModel?, complete: @escaping((_ feedId: Int?, _ error: NSError?) -> Void)) {
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
    
    //
    func getReportTypes(completion: @escaping (_ model: TGReportIncidentTypeModel?, _ msg: String?, _ status: Bool) -> Void ) {
        let path = "api/v2/report/type"
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .GET,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, "network_problem".localized, false)
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                let model = Mapper<TGReportIncidentTypeModel>().map(JSONString: jsonString)
                DispatchQueue.main.async {
                    completion(model, nil, true)
                }
            } else {
                let nserror = NSError(domain: "TGIMNetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "json 解析失败"])
                DispatchQueue.main.async {
                    completion(nil, nserror.localizedDescription, false)
                }
            }
           
        }
    }
    
    func report(type: ReportTargetType, reportTargetId: Int, reportType: Int, reason: String, files: [Int], completion: @escaping (_ msg: String?, _ status: Bool) -> Void) {
        var path = ""
        switch type {
        case .Comment(commentType: let commentType, sourceId: _, groupId: _):
            path = "api/v2/report/comments/\(reportTargetId.stringValue)"
            if commentType == .post {
                path = "api/v2/plus-group/reports/comments/\(reportTargetId.stringValue)"
            }
        case .Post:
            path = "api/v2/plus-group/reports/posts/\(reportTargetId.stringValue)"
        case .Moment, .Live:
            path = "api/v2/feeds/\(reportTargetId.stringValue)/reports"
        case .User:
            path = "api/v2/report/users/\(reportTargetId.stringValue)"
        case .Group:
            path = "api/v2/plus-group/groups/\(reportTargetId.stringValue)/reports"
        case .Topic:
            path = "api/v2/user/report-feed-topics/\(reportTargetId.stringValue)"
        case .News:
            path = "api/v2/news/\(reportTargetId.stringValue)/reports"
        }
        // 2.配置参数
        var parameters: [String: Any] = [String: Any]()
        // 有的地方传的参数叫content，有的地方传的参数叫reason，topic：message，不用判断的解决方案
        parameters.updateValue(reason, forKey: "reason")
        parameters.updateValue(reason, forKey: "content")
        parameters.updateValue(reason, forKey: "message")
        // By Kit Foong (New added report type and images params)
        parameters.updateValue(reportType, forKey: "report_type")
        if files.isEmpty == false && files.count > 0 {
            parameters.updateValue(files, forKey: "images")
        }
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: parameters,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                completion("network_problem".localized, false)
                return
            }
            completion("" , true)
           
        }
        
    }
    
    
    func fetchFeedRejectList(withPage page: String, limit: Int, completion: @escaping (TGRejectModel?, Error?) -> Void) {
        
        let path = "api/v2/feeds/reject/list"
        var params: [String: Any] = [:]
        params.updateValue(limit, forKey: "limit")
        params.updateValue(page, forKey: "page")
        
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
            if let jsonString = String(data: data, encoding: .utf8) {
                let model = Mapper<TGRejectModel>().map(JSONString: jsonString)
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
    
    func fetchFeedRejectDetail(withFeedId feedId: String, completion: @escaping (TGRejectDetailModel?, Error?) -> Void) {
        
        let path = "api/v2/feeds/reject/\(feedId)"
        let params: [String: Any] = [:]
        
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
            if let jsonString = String(data: data, encoding: .utf8) {
                let model = Mapper<TGRejectDetailModel>().map(JSONString: jsonString)
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
    
    func readAllNoti(completion: @escaping (BaseModelResponse?, Error?) -> Void) {
        
        let path = "api/v2/user/notifications?type=feed_reject"
        let params: [String: Any] = [:]
        
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .PATCH,
            params: params,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                let model = Mapper<BaseModelResponse>().map(JSONString: jsonString)
                completion(model, nil)
            } else {
                let nserror = NSError(domain: "TGIMNetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "json 解析失败"])
                DispatchQueue.main.async {
                    completion(nil, nserror)
                }
            }
        }
    }
    
    
    
    
}
