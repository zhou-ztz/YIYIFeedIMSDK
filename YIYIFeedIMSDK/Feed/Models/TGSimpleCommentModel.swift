//
//  TGSimpleCommentModel.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/3/28.
//

import UIKit

struct TSSimpleCommentModel {
    
    var userInfo: TGUserInfoModel?
    var replyUserInfo: TGUserInfoModel?
    var content: String = ""
    var createdAt: NSDate? = nil
    var id: Int = 0
    var commentMark: Int64 = 0
    var status = 0 // 状态 0：已成功的 1：未成功的 2 : 正在发送中
    var isTop = false
    var contentType: CommentContentType = .text
    var userId: Int = 0
    var createDate: Date?

    init() {  }
    
    init(content: String, replyUserId: Int?, status: Int, contentType: CommentContentType) {
        self.content = content
        self.createdAt = NSDate(timeIntervalSince1970: Date().timeIntervalSince1970)
//        self.userInfo = CurrentUser
        if let replyUserId = replyUserId {
            self.replyUserInfo = TGUserInfoModel.retrieveUser(userId: replyUserId)
        }
        self.status = status
        self.contentType = contentType
    }
    
    init(userInfo: TGUserInfoModel?, replyUserInfo: TGUserInfoModel?, content: String, createdAt: NSDate?,
         id: Int, commentMark: Int64, status: Int, isTop: Bool, contentType: CommentContentType) {
        self.userInfo = userInfo
        self.replyUserInfo = replyUserInfo
        self.content = content
        self.createdAt = createdAt
        self.id = id
        self.commentMark = commentMark
        self.status = status
        self.isTop = isTop
        self.contentType = contentType
    }
}
