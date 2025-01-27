//
//  TGFeedType.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/20.
//

import Foundation

/// 动态列表的类型
enum TGFeedListType: Equatable {
    case new
    case hot
    case recommend
    case follow
    case teen
    case intelligent
    case tagged(userId: Int)
    case save(userId: Int)
    case user(userId: Int)
    case detail(feedId: Int)
    case bizCampaign
    
    var trendingLiveFilter: String {
        switch self {
        case .hot:
            return "pinned"
        case .recommend:
            return "recommend"
        case .follow:
            return "follow"
        case .intelligent:
            return "intelligent"
        case .bizCampaign:
            return "biz_campaign"
            
        default:
            return ""
        }
    }
    
    var rawValue: String {
        switch self {
        case .teen: return "teen"
        case .new: return "new"
        case .follow: return "follow"
        case .recommend: return "recommend"
        case .hot: return "hot"
        case .intelligent: return "intelligent"
        case .user: return "user"
        case .tagged: return "tagged"
        case .save: return "collect"
        case .bizCampaign: return "biz_campaign"
        default: return ""
        }
    }
    
    var boxFilterType: String {
        switch self {
        case .user(let userId):
            return userId.stringValue
        default:
            return self.rawValue
        }
    }
    
    static func ==(lhs: TGFeedListType, rhs: TGFeedListType) -> Bool {
        switch (lhs, rhs) {
        case (.hot, .hot), (.follow, .follow), (.new, .new):
            return true
        case (.user(let a), .user(let b)):
            return a == b
        case (.detail(let a), .detail(let b)):
            return a == b
        default:
            return false
        }
    }
}

enum PostType {
    case photo
    case video
    case text
    case live
    case miniVideo
    
}

enum filterButtonType {
    case feed
    case live
}

enum FeedContentType {
    case normalText
    case picture
    case video
    case live
    case miniVideo
    case share
    case repost
}

