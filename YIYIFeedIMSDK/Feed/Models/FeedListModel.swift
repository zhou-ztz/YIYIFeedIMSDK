//
//  FeedListModel.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/28.
//

import Foundation
import UIKit
import ObjectMapper
import ObjectBox

/// 批量获取动态 网络数据模型
public class FeedListResultsModel: Mappable {

    /// 置顶动态列表
    public var pinned: [FeedListModel] = []
    /// 普通动态列表
    public var feeds: [FeedListModel] = []
    
    public init() {
    }

    required public init?(map: Map) {
    }

    public func mapping(map: Map) {
        pinned <- map["pinned"]
        feeds <- map["feeds"]
    }
}

/// 动态列表数据模型
public class FeedListModel: Mappable, Entity {
    /// 动态数据id
    // objectbox: id = { "assignable": true }
    public var feedId: Id = 0
    public var id = 0
    /// index 话题动态列表分页
    public var index = 0
    /// 发布者id
    public var userId = 0
    /// 动态内容
    public var content = ""
    /// 动态来源 1:pc 2:h5 3:ios 4:android 5:其他
    public var from = 0
    /// 点赞数
    public var likeCount = 0
    /// 查看数
    public var viewCount = 0
    /// 评论数
    public var commentCount = 0
    /// 打赏数
    public var rewardCount = 0
    /// 纬度
    public var latitude = ""
    /// 经度
    public var longtitude = ""
    /// GEO
    public var geo = ""
    /// 标记
    public var feedMark: Int64 = 0
    ///    置顶标记
    public var pinned = 0
    /// 创建时间
    public var create = Date()
    /// 删除时间
    public var delete = Date()
    /// 是否已收藏
    public var hasCollect = false
    /// 是否已赞
    public var hasLike = false
    /// 发布者信息，需要请求用户信息接口来获取
    // objectbox: transient
    var user: TGUserInfoModel? = nil
    /// 转发的类型
    public var repostType: String? = nil
    /// 转发的ID
    public var repostId: Int = 0
    /// 热门标识
    public var hot: Int = 0
    /// 是否已赞
    public var hasReward = false
    /// 是否禁止留言
    public var hasDisabled = false

    public var privacy: String = ""

    public var editedAt: String = ""

    public var isEdited: Bool {
        return (editedAt.isEmpty == false)
    }

    public var topReactions: String? = nil
    
    public var reactType: String? = nil
    
    public var isSponsored = false
    
    public var feedType: String = "" //empty = no type, hot = "hot", following= "follow", user = "username"
    
    /// 图片信息 同单条动态数据结构一致
    // objectbox: convert = { "dbType": "String", "converter": "FeedImageModel" }
    public var images: [FeedImageModel]? = nil
    /// 视频数据
    // objectbox: convert = { "dbType": "String", "converter": "FeedVideoModel" }
    public var feedVideo: FeedVideoModel? = nil
    /// 分享信息
    // objectbox: convert = { "dbType": "String", "converter": "SharedViewModel" }
    public var sharedModel: SharedViewModel? = nil
    // objectbox: convert = { "dbType": "String", "converter": "TSPostLocationModel" }
    public var location: TSPostLocationModel? = nil
    /// 话题，为空则不显示评论
    // objectbox: convert = { "dbType": "String", "converter": "TopicListModel" }
    var topics: [TopicListModel]? = nil
    /// 动态评论 列表中返回五条
    // objectbox: convert = { "dbType": "String", "converter": "FeedListCommentModel" }
    public var comments: [FeedListCommentModel]? = nil
    /// 直播
    // objectbox: convert = { "dbType": "String", "converter": "LiveEntityModel" }
    public var liveModel: LiveEntityModel? = nil
    /// 商户信息
    // objectbox: convert = { "dbType": "String", "converter": "TSRewardsLinkMerchantUserModel" }
    var rewardsMerchantUsers: [TGRewardsLinkMerchantUserModel]? = nil
    
    /// @用户信息
    // objectbox: convert = { "dbType": "String", "converter": "TGUserInfoModel" }
    var tagUsers: [TGUserInfoModel]? = nil
    /// @商户信息
    // objectbox: convert = { "dbType": "String", "converter": "TGUserInfoModel" }
    var rewardsLinkMerchantUsers : [TGUserInfoModel]? = nil
    
    /// 转发数
    public var feedForwardCount: Int = 0
    
    /// 用做查询条件的时间参数
    public var afterTime: String = ""
    
    public var isPinned: Bool = false
    
    // objectbox: convert = { "dbType": "String", "converter": "TagVoucherModel" }
    public var tagVoucher: TagVoucherModel? = nil
    
    /// 活动动态是否可以编辑
    public var campaignIsEdite: Bool = false
    init() {}
    required public init?(map: Map) {
    }
    public init(
         id: Int,
         userId: Int,
         content: String,
         from: Int,
         likeCount: Int,
         viewCount: Int,
         commentCount: Int,
         rewardCount: Int,
         create: Date,
         hasCollect: Bool,
         hasLike: Bool
     ) {
         self.id = id
         self.userId = userId
         self.content = content
         self.from = from
         self.likeCount = likeCount
         self.viewCount = viewCount
         self.commentCount = commentCount
         self.rewardCount = rewardCount
         self.create = create
         self.hasCollect = hasCollect
         self.hasLike = hasLike
     }

    public func mapping(map: Map) {
        id <- map["id"]
        feedId = UInt64(id)
        index <- map["index"]
        userId <- map["user_id"]
        content <- map["feed_content"]
        // 自定义的image标签替换为空字符串
        content = content.ts_customMarkdownToClearString()
        from <- map["feed_from"]
        likeCount <- map["like_count"]
        viewCount <- map["feed_view_count"]
        commentCount <- map["feed_comment_count"]
        rewardCount <- map["feed_reward_count"]
        latitude <- map["feed_latitude"]
        longtitude <- map["feed_longtitude"]
        geo <- map["feed_geohash"]
        feedMark <- map["feed_mark"]
        pinned <- map["pinned"]
        create <- (map["created_at"], DateTransformer)
        delete <- (map["deleted_at"], DateTransformer)
        topics <- map["topics"]
        hasReward <- map["has_reward"]
        hasDisabled <- map["disable_comment"]

        comments <- map["comments"]
        // 手动写入动态ID
        comments?.forEach({ item in
            item.feedid = id
        })
        hasCollect <- map["has_collect"]
        hasLike <- map["has_like"]
        
        images <- map["images"]
        
        feedVideo <- map["video"]
        user <- map["user"]
        
        // 转发
        repostId <- map["repostable_id"]
        repostType <- map["repostable_type"]
        // 转发的信息需要单独的接口去获取
        // 热门标识
        hot <- map["hot"]
        location <- map["location"]
        
        sharedModel <- map["custom_attachment"]
//        liveModel <- map["live"]

        privacy <- map["privacy"]
        editedAt <- map["edited_at"]

        topReactions <- (map["top_reactions"], StringArrayTransformer)
        reactType <- map["reaction_type"]
        
        isSponsored <- map["is_sponsored"]
        
        rewardsMerchantUsers <- map["rewards_link_merchant_yippi_users"]
        
        feedForwardCount <- map["feed_forward_count"]
        
        afterTime <- map["after_time"]
        
        isPinned <- map["is_pinned"]
        
        tagUsers <- map["tag_users"]
        
        rewardsLinkMerchantUsers <- map["tag_merchant_users"]
        
        tagVoucher <- map["tag_voucher"]
        
        campaignIsEdite <- map["is_edit"]
    }
    static public func convert(_ object: FeedListModel?) -> String? {
        guard let object = object else { return nil }
        return object.toJSONString()
    }
    
    static public func convert(_ json: String?) -> FeedListModel? {
        guard let json = json else { return nil }
        return Mapper<FeedListModel>().map(JSONString: json)
    }
}

extension FeedListModel {
    // objectbox: transient
    public var reactionType: ReactionTypes? {
        return ReactionTypes.initialize(with: reactType.orEmpty)
    }
    // objectbox: transient
    public var topReactionList: [ReactionTypes]? {
        return StringArrayTransformer.transformToJSON(topReactions)?.compactMap { ReactionTypes.initialize(with: $0) }
    }
    // objectbox: transient
    public var userInfo: TGUserInfoModel {
        return self.user ?? TGUserInfoModel.retrieveUser(userId: userId) ?? TGUserInfoModel()
    }
    /// 转发信息
    // objectbox: transient
//    var repostModel: TGRepostModel? {
//        guard repostId > 0 else {
//            return nil
//        }
//        return TGRepostModel.retrieveRepost(repostId)
//    }
    /// 动态相关用户的 id
    public func userIds() -> [Int] {
        var ids: [Int] = [userId]
        
        comments?.forEach({ comment in
            ids.append(contentsOf: comment.userIds())
        })
        return Set(ids).filter { $0 != 0 }
    }

    /// 添加用户信息
    public func set(userInfos: [Int: TGUserInfoModel]) {
        // 设置动态用户信息
        if let userInfo = userInfos[userId] {
            self.user = userInfo
        }
        // 设置评论用户信息
        comments?.forEach({ comment in
            comment.set(userInfos: userInfos)
        })
    }
    
    public func save() {
        guard let json = FeedListModel.convert(self) else { return }
        RLSDKManager.shared.feedDelegate?.saveFeedListModel(json: json)
    }
}

/// 动态列表 评论模型
/// - Note: 当用户不存在时，用户 id 为 0
public class FeedListCommentModel: Mappable {
    /// 动态id
    public var feedid = 0
    /// 评论 id
    public var id = 0
    /// 评论者id
    public var userId = 0
    /// 资源作者 id
    public var targetId = 0
    /// 被回复者 id（坑：如果没有被回复者，后台会返回 0）
    public var replyId = 0
    /// 评论内容
    public var body = ""
    /// 创建时间
    public var create = Date()
    /// 更新时间
    public var update = Date()
    /// 后台文档注释没有写
    public var commentableId = 0
    /// 后台文档注释没有写
    public var commentableType = ""
    /// 是否置顶
    public var pinned = false
    /// sticker/text
    public var contentType = ""
    /// 评论者信息，需要请求用户信息接口来获取
    public var userInfo = TGUserInfoModel()
    /// 资源作者信息，需要请求用户信息接口来获取
    public var targetInfo = TGUserInfoModel()
    /// 被回复者信息，需要请求用户信息接口来获取
    public var replyInfo: TGUserInfoModel? = nil
    
    public var subscribing: Bool = false
    
    public var subscribingBadge: String?

    required public init?(map: Map) {
    }

    public func mapping(map: Map) {
        id <- map["id"]
        userId <- map["user_id"]
        targetId <- map["target_user"]
        replyId <- map["reply_user"]
        body <- map["body"]
        commentableId <- map["commentable_id"]
        commentableType <- map["commentable_type"]
        create <- (map["created_at"], DateTransformer)
        update <- (map["updated_at"], DateTransformer)
        pinned <- map["pinned"]
        userInfo <- map["user"]
        replyInfo <- map["reply"]
        contentType <- map["content_type"]
        subscribing <- map["subscribing"]
        subscribingBadge <- map["subscribing_badge"]
    }

    /// 评论相关用户的 id
    func userIds() -> [Int] {
        return [userId, targetId, replyId].filter { $0 != 0 }
    }

    /// 添加用户信息
    func set(userInfos: [Int: TGUserInfoModel]) {
        if let userInfo = userInfos[userId] {
            self.userInfo = userInfo
        }
        if let targetInfo = userInfos[targetId] {
            self.targetInfo = targetInfo
        }
        if let replyInfo = userInfos[replyId] {
            self.replyInfo = replyInfo
        }
    }
    
    static func convert(_ object: [FeedListCommentModel]?) -> String? {
        guard let object = object else { return nil }
        return object.toJSONString()
    }
    
    static func convert(_ json: String?) -> [FeedListCommentModel]? {
        guard let json = json else { return nil }
        return Mapper<FeedListCommentModel>().mapArray(JSONString: json)
    }
}

/// 动态商家信息
public class TGRewardsLinkMerchantUserModel: Mappable {
    public var desc: String = ""
    public var merchantId: Int = 0
    public var rating: String = ""
    public var userName: String = ""
    public var nickName: String = ""
    public var avatar: String = ""
    public var certificationIconUrl: String = ""
    public var wantedPath: String = ""
    public var wantedMid: Int = 0
    // Rebate || Offset
    public var merchantRebate: String?
    public var merchantOffset: String?
    
    required public init?(map: Map) {}

    public func mapping(map: Map) {
        desc       <- map["desc"]
        merchantId <- map["id"]
        rating     <- map["rating"]
        nickName   <- map["name"]
        userName   <- map["username"]
        avatar     <- map["avatar"]
        certificationIconUrl  <- map["certification_icon_url"]
        wantedPath  <- map["path"]
        wantedMid  <- map["yipps_wanted_mid"]
        
        // 如果 name 不为空，则使用 name，否则使用 username
        if nickName.isEmpty {
            userName <- map["username"]
        } else {
            userName <- map["name"]
        }
        merchantRebate <- map["merchant_rebate"]
        merchantOffset <- map["merchant_offset"]
    }
  
    static func convert(_ object: [TGRewardsLinkMerchantUserModel]?) -> String? {
        guard let object = object else { return nil }
        return object.toJSONString()
    }
    
    static func convert(_ json: String?) -> [TGRewardsLinkMerchantUserModel]? {
        guard let json = json else { return nil }
        return Mapper<TGRewardsLinkMerchantUserModel>().mapArray(JSONString: json)
    }
}
/// 可付费图片 数据模型
public class FeedImageModel: Mappable {
    /// 文件 file_with 标识 不收费图片只存在 file 这一个字段。
    public var file = 0
    /// 图像尺寸，非图片为 null，图片没有尺寸也为 null
    // objectbox: transient
    public var size = CGSize.zero
    /// 图片类型 miniType
    public var mimeType: String = ""

    required public init?(map: Map) {
    }

    public func mapping(map: Map) {
        file <- map["file"]
        size <- (map["size"], CGSizeTransform())
        mimeType <- map["mime"]
    }
    
    static func convert(_ object: [FeedImageModel]?) -> String? {
        guard let object = object else { return nil }
        return object.toJSONString()
    }
    
    static func convert(_ json: String?) -> [FeedImageModel]? {
        guard let json = json else { return nil }
        return Mapper<FeedImageModel>().mapArray(JSONString: json)
    }
}

/// 短视频 数据模型
public class FeedVideoModel: Mappable {
    /// 文件 file_with 标识 不收费图片只存在 file 这一个字段。
    public var videoID = 0
    /// 视频宽度
    public var width = 0
    /// 视频高度
    public var height = 0
    /// 封面文件id
    public var videoCoverID = 0

    public var type = 0
    
    public var soundId: String?
    
    public var videoPath = ""
    
    required public init?(map: Map) {
    }

    public func mapping(map: Map) {
        videoID <- map["video_id"]
        width <- map["width"]
        height <- map["height"]
        videoCoverID <- map["cover_id"]
        type <- map["type"]
        soundId <- map["extra"]["sound_id"]
        videoPath <- map["video_path"]
    }
    
    static func convert(_ object: FeedVideoModel?) -> String? {
        guard let object = object else { return nil }
        return object.toJSONString()
    }
    
    static func convert(_ json: String?) -> FeedVideoModel? {
        guard let json = json else { return nil }
        return FeedVideoModel(JSONString: json)
    }
}

public enum YPLiveStatus: Int {
    // 直播中
    case onlive = 1
    // 直播结束视频处理中
    case processing = 2
    // 视频完成
    case finishProcess = 3
}


public class FeedStoreModel: Mappable, Entity {
    /// 动态数据id
    // objectbox: id = { "assignable": true }
    public var feedId: Id = 0
    public var id = 0
    /// 图片信息 同单条动态数据结构一致
    // objectbox: convert = { "dbType": "String", "converter": "FeedImageModel" }
    public var images: [FeedImageModel]? = nil
    /// 视频数据
    // objectbox: convert = { "dbType": "String", "converter": "FeedVideoModel" }
    public var feedVideo: FeedVideoModel? = nil
    
    public init(){}
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
       
    }
    static public func convert(_ object: FeedStoreModel?) -> String? {
        guard let object = object else { return nil }
        return object.toJSONString()
    }
    
    static public func convert(_ json: String?) -> FeedStoreModel? {
        guard let json = json else { return nil }
        return Mapper<FeedStoreModel>().map(JSONString: json)
    }
}

public class TagVoucherModel: Mappable {

    public var taggedVoucherId: Int = 0
    public var taggedVoucherTitle: String = ""
    
    init(taggedVoucherId: Int, taggedVoucherTitle: String) {
        self.taggedVoucherTitle = taggedVoucherTitle
        self.taggedVoucherId = taggedVoucherId
    }
    
    required public init?(map: Map) {}

    public func mapping(map: Map) {
        taggedVoucherId <- map["tagged_voucher_id"]
        taggedVoucherTitle <- map["tagged_voucher_title"]
    }
    
    static func convert(_ object: TagVoucherModel?) -> String? {
        guard let object = object else { return nil }
        return object.toJSONString()
    }
    
    static func convert(_ json: String?) -> TagVoucherModel? {
        guard let json = json else { return nil }
        return TagVoucherModel(JSONString: json)
    }
}

