//
//  TGComment.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/3/28.
//

import UIKit
import ObjectMapper

/// 评论应用场景/评论类型
typealias TGCommentSituation = TGCommentType
enum TGCommentType: String {
    case momment = "feeds"
    case album = "music_specials"
    case song = "musics"
    case post = "group-posts"
    case news = "news"

    init(type: ReceiveInfoSourceType) {
        self.init(rawValue: type.rawValue)!
    }
}


/// 评论通用模型
class TGCommentModel: Mappable {

    var id: Int = 0
    var userId: Int = 0
    var targetUserId: Int = 0
    var replyUserId: Int?
    var body: String = ""
    var commentTableId: Int = 0
    var commentTableType: String = ""
    var updateDate: Date?
    var createDate: Date?

    var contentType: String = ""
    var subscribing: Bool = false
    var isTop: Bool = false

    var type: TGCommentType? {
        return TGCommentType(rawValue: self.commentTableType)
    }
    
    var user: TGUserInfoModel?
    var targetUser: TGUserInfoModel?
    var replyUser: TGUserInfoModel?

    // MARK: - Mappable
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["user_id"]
        targetUserId <- map["target_user"]
        replyUserId <- map["reply_user"]
        body <- map["body"]
        commentTableId <- map["commentable_id"]
        commentTableType <- map["commentable_type"]
        updateDate <- (map["updated_at"], DateTransformer)
        createDate <- (map["updated_at"], DateTransformer)
        contentType <- map["content_type"]
        subscribing <- map["subscribing"]
    }

}

// MARK: - 构建TSSimpleCommentModel

extension TGCommentModel {
    func simpleModel() -> TSSimpleCommentModel {
        var simpleModel = TSSimpleCommentModel()
        simpleModel.content = self.body
        if let date = self.createDate {
            simpleModel.createdAt = NSDate(timeIntervalSince1970: date.timeIntervalSince1970)
        }
        simpleModel.status = 0
        simpleModel.isTop = false
        simpleModel.id = self.id
        simpleModel.commentMark = Int64(self.id)
        simpleModel.userInfo = self.user
        simpleModel.replyUserInfo = self.replyUser
        simpleModel.isTop = self.isTop
        simpleModel.contentType = CommentContentType(rawValue: self.contentType) ?? .text
        return simpleModel
    }
}

// MARK: - 构建TSCommentViewModel

extension TGCommentModel {
    func viewModel() -> TGCommentViewModel? {
        guard let type = self.type else {
            return nil
        }
        let viewModel = TGCommentViewModel(id: self.id, userId: self.userId, type: type, user: self.user, replyUser: self.replyUser, content: self.body, createDate: self.createDate, status: .normal, isTop: self.isTop, contentType: CommentContentType(rawValue: self.contentType) ?? .text)
        return viewModel
    }
}

