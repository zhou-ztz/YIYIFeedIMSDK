//
//  TGCommentViewModel.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/3/28.
//

import UIKit

/// 评论发送状态
enum TGCommentSendtatus: Int {
    /// 发送成功
    case normal = 0
    /// 发送失败
    case faild
    /// 发送中
    case sending
}
class TGCommentViewModel: NSObject {
    
    var id: Int = 0
    var userId: Int = 0
    var user: TGUserInfoModel?
    var replyUser: TGUserInfoModel?
    var content: String = ""
    var createDate: Date?
    var isTop = false
    var status: TGCommentSendtatus = .normal
    var type: TGCommentType

    var contentType: CommentContentType = .text
    
    init(type: TGCommentType) {
        self.type = type
        self.userId = Int(RLSDKManager.shared.loginParma?.uid ?? 0 )
    }
    init(type: TGCommentType, content: String, replyUserId: Int?, status: TGCommentSendtatus, contentType: CommentContentType) {
        self.type = type
        self.content = content
        self.userId = Int(RLSDKManager.shared.loginParma?.uid ?? 0 )
        self.user = TGUserInfoModel.retrieveUser(userId: self.userId)
        if let replyUserId = replyUserId {
            self.replyUser = TGUserInfoModel.retrieveUser(userId: replyUserId)
        }
        self.status = status
        self.contentType = contentType
    }
    init(id: Int, userId: Int, type: TGCommentType, user: TGUserInfoModel?, replyUser: TGUserInfoModel?, content: String, createDate: Date?, status: TGCommentSendtatus, isTop: Bool = false, contentType: CommentContentType) {
        self.id = id
        self.userId = userId
        self.type = type
        self.user = user
        self.replyUser = replyUser
        self.content = content
        self.createDate = createDate
        self.status = status
        self.isTop = isTop
        self.contentType = contentType
    }

}
