//
//  TGFeedCommentLabelModel.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/12/4.
//

import Foundation

struct TGFeedContentResponse: Codable {
    
    var pinneds: [TGFeedCommentListModel]?
    var comments: [TGFeedCommentListModel]?
}

struct TGFeedCommentListModel: Codable {
    var id: Int?
    var body: String?
    var targetUser: Int?
    var createdAt: String?
    var contentType: String?
    var userId: Int?
    var subscribingBadge: String?
    var msgidClient: String?
    var resourceable: Resourceable?
    var updatedAt: String?
    var replyUser: Int?
    var user: User?
    var subscribing: Bool?
    /// 是否置顶
    var pinned: Bool?
    
    struct Resourceable: Codable {
        var type: String?
        var id: Int?
    }

    struct User: Codable {
        var avatar: Avatar?
        var id: Int?
        var extra: Extra?
        var verified: Verified?
        var username: String?
        var profileFrame: String?
        var name: String?

        struct Avatar: Codable {
            var size: Int?
            var vendor: String?
            var url: String?
            var mime: String?
            var dimension: Dimension?

            struct Dimension: Codable {
                var width: Int?
                var height: Int?
            }
        }

        struct Extra: Codable {
            var feedsCount: Int?
            var likesCount: Int?
            var questionsCount: Int?
            var answersCount: Int?
            var isLiveEnable: Int?
            var isSubscribable: Int?
            var canAcceptReward: Int?
            var followingsCount: Int?
            var commentsCount: Int?
            var followersCount: Int?
        }

        struct Verified: Codable {
            var type: String?
            var icon: String?
            var description: String?
        }
    }
}
