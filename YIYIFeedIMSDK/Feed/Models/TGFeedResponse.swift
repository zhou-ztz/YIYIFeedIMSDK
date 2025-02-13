//
//  TGFeedResponse.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/29.
//

import Foundation

// 主模型
struct TGFeedResponse: Codable {
    let createdAt: String?
    let id: Int?
    let coverImage: String?
    let repostableType: String?
    let isPublic: Int?
    let hot: Int?
    let customAttachment: String?
    let hasTagged: Bool?
    let location: TGPostLocationModel?
    let feedForwardCount: Int?
    let tagMerchantUsers: [TGFeedTagUserMerchant]?
    let privacy: String?
    let likeCount: Int?
    let hasLike: Bool?
    let lid: String?
    let editedAt: String?
    let hasReward: Bool?
    let live: String?
    let user: FeedUser?
    let reactType: String?
    let topReactions: [String]?
    let feedViewCount: Int?
    let feedCommentCount: Int?
    let feedFrom: Int?
    let images: [FeedImage]?
    let tagVoucher: TagVoucher?
    let video: TGFeedVideoModel?
    let topics: [String]?
    let repostableID: Int?
    let feedContent: String?
    let userID: Int?
    let updatedAt: String?
    let isSponsored: Int?
    let tagUsers: [TGFeedTagUserMerchant]?
    let disableComment: Int?
    let afterTime: String?
    let isPinned: Bool?
    let stickerParams: String?
    let feedMark: Int?
    let campaignHashtags: [String]?
    let feedRewardCount: Int?
    let rewardsLinkMerchantYippiUsers: [TGFeedTagUserMerchant]?
    let hasCollect: Bool?
    /// 活动动态是否可以编辑
    let campaignIsEdite: Bool?
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case id
        case coverImage = "cover_image"
        case repostableType = "repostable_type"
        case isPublic = "is_public"
        case hot
        case customAttachment = "custom_attachment"
        case hasTagged = "has_tagged"
        case location
        case feedForwardCount = "feed_forward_count"
        case tagMerchantUsers = "tag_merchant_users"
        case privacy
        case likeCount = "like_count"
        case hasLike = "has_like"
        case lid
        case editedAt = "edited_at"
        case hasReward = "has_reward"
        case live
        case user
        case reactType = "reaction_type"
        case topReactions = "top_reactions"
        case feedViewCount = "feed_view_count"
        case feedCommentCount = "feed_comment_count"
        case feedFrom = "feed_from"
        case images
        case tagVoucher = "tag_voucher"
        case video
        case topics
        case repostableID = "repostable_id"
        case feedContent = "feed_content"
        case userID = "user_id"
        case updatedAt = "updated_at"
        case isSponsored = "is_sponsored"
        case tagUsers = "tag_users"
        case disableComment = "disable_comment"
        case afterTime = "after_time"
        case isPinned = "is_pinned"
        case stickerParams = "sticker_params"
        case feedMark = "feed_mark"
        case campaignHashtags = "campaign_hashtags"
        case feedRewardCount = "feed_reward_count"
        case rewardsLinkMerchantYippiUsers = "rewards_link_merchant_yippi_users"
        case hasCollect = "has_collect"
        case campaignIsEdite = "is_edit"
//        case pinnedComments = "pinned_comments"
    }
}


// 嵌套的 User 对象
struct FeedUser: Codable {
    let avatar: Avatar?
    let id: Int?
    let extra: UserExtra?
    let verified: Verified?
    let username: String?
    let profileFrame: String?
    let name: String?
}

// 嵌套的 Avatar 对象
struct Avatar: Codable {
    let size: Int?
    let vendor: String?
    let url: String?
    let mime: String?
    let dimension: Dimension?
}

// 嵌套的 Dimension 对象
struct Dimension: Codable {
    let width: Int?
    let height: Int?
}

struct Verified: Codable {
    var type: String?
    var icon: String?
    var description: String?
}

// 嵌套的 UserExtra 对象
struct UserExtra: Codable {
    let feedsCount: Int?
    let likesCount: Int?
    let questionsCount: Int?
    let answersCount: Int?
    let isLiveEnable: Int?
    let isSubscribable: Int?
    let canAcceptReward: Int?
    let followingsCount: Int?
    let commentsCount: Int?
    let followersCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case feedsCount = "feeds_count"
        case likesCount = "likes_count"
        case questionsCount = "questions_count"
        case answersCount = "answers_count"
        case isLiveEnable = "is_live_enable"
        case isSubscribable = "is_subscribable"
        case canAcceptReward = "can_accept_reward"
        case followingsCount = "followings_count"
        case commentsCount = "comments_count"
        case followersCount = "followers_count"
    }
}

// 嵌套的 Image 对象
struct FeedImage: Codable {
    let mime: String?
    let file: Int?
    let size: String?
}


struct TagVoucher: Codable {
    
    var taggedVoucherId: Int?
    var taggedVoucherTitle: String?
    
    enum CodingKeys: String, CodingKey {
        case taggedVoucherId = "tagged_voucher_id"
        case taggedVoucherTitle = "tagged_voucher_title"
    }
    
    
}
extension TGFeedResponse {
    
    var reactionType: ReactionTypes? {
        return ReactionTypes.initialize(with: reactType.orEmpty)
    }
}


struct TGFeedTagUserMerchant: Codable {
    let id: Int?
    let username: String?
    let name: String?
    
}

struct TGFeedVideoModel: Codable {
    /// 文件 file_with 标识 不收费图片只存在 file 这一个字段。
    var videoID: Int
    /// 视频宽度
    var width: Int
    /// 视频高度
    var height: Int
    /// 封面文件id
    var videoCoverID: Int
    var type: Int
    var soundId: String?
    var videoPath: String
  
    enum CodingKeys: String, CodingKey {
        case videoID = "video_id"
        case width
        case height
        case videoCoverID = "cover_id"
        case type
        case soundId = "extra.sound_id"
        case videoPath = "video_path"
    }
    
}
