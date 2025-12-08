//
//  TGMessageRequestModel.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/16.
//

import Foundation
import ObjectMapper

class TGMessageRequestModel: Mappable {
    var requestID: Int = 0
    var fromUserID: Int = 0
    var toUserID: Int = 0
    var isBlock: Int = 0
    var total: Int = 0
    var createdAt = Date()
    var updatedAt = Date()
    var deletedAt = Date()
    var syncAt = Date()
    var after: Int = 0
    var user: TGUserInfoModel?
    var messageDetail: MessageDetailModel?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        fromUserID <- map["from_user_id"]
        toUserID <- map["to_user_id"]
        isBlock <- map["is_block"]
        total <- map["total"]
        createdAt <- (map["created_at"], DateTransformer)
        updatedAt <- (map["updated_at"], DateTransformer)
        deletedAt <- (map["deleted_at"], DateTransformer)
        syncAt <- (map["sync_at"], DateTransformer)
        requestID <- map["request_id"]
        after <- map["after"]
        user <- map["user"]
        messageDetail <- map["message_detail"]
    }
    
    
    /// 从数据库模型转换
//    init(object: MessageRequestObject) {
//        self.fromUserID = object.fromUserID
//        self.toUserID = object.toUserID
//        self.isBlock = object.isBlock ? 1 : 0
//        self.total = object.total
//        self.createdAt = object.createdAt
//        self.updatedAt = object.updatedAt
//        self.deletedAt = object.deletedAt
//        self.syncAt = object.syncAt
//        self.requestID = object.requestID
//        self.after = object.after
//        
//        let userobj = TGUserInfoModel.retrieveUser(userId: object.userId.orEmpty.toInt())
//        self.user = userobj
//        
//        if nil != object.messageDetail, object.isInvalidated == false {
//            self.messageDetail = MessageDetailModel(previewMessageObject: object.messageDetail!)
//        }
//    }
//    
//    /// 转换为数据库对象
//    func object() -> MessageRequestObject {
//        let object = MessageRequestObject()
//        object.requestID = self.requestID
//        object.fromUserID = self.fromUserID
//        object.toUserID = self.toUserID
//        object.isBlock = (self.isBlock == 1)
//        object.total = self.total
//        object.createdAt = self.createdAt
//        object.updatedAt = self.updatedAt
//        object.deletedAt = self.deletedAt
//        object.syncAt = self.syncAt
//        object.after = self.after
//        object.userId = (self.user?.userIdentity).orZero.stringValue
//        object.messageDetail = self.messageDetail?.previewMsgObject()
//        return object
//    }
}

// MARK: - MessageDetailModel
// sourcery: RealmEntityConvertible
class MessageDetailModel: Mappable {
    var requestID: Int = 0
    var fromUserID: Int = 0
    var toUserID: Int = 0
    var id: Int = 0
    var content = ""
    var isRead = 0
    var createdAt = Date()
    var updatedAt = Date()
    var deletedAt = Date()
    var readAt = Date()
    var user: TGUserInfoModel?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        requestID <- map["request_id"]
        fromUserID <- map["from_user_id"]
        toUserID <- map["to_user_id"]
        content <- map["content"]
        isRead <- map["is_read"]
        createdAt <- (map["created_at"], DateTransformer)
        updatedAt <- (map["updated_at"], DateTransformer)
        deletedAt <- (map["deleted_at"], DateTransformer)
        readAt <- (map["read_at"], DateTransformer)
        user <- map["user"]
    }
    
//    /// 从数据库模型转换
//    init(object: MessageDetailObject) {
//        self.id = object.id
//        self.requestID = object.requestID
//        self.fromUserID = object.fromUserID
//        self.toUserID = object.toUserID
//        self.content = object.content
//        self.isRead = object.isRead ? 1 : 0
//        self.createdAt = object.createdAt
//        self.updatedAt = object.updatedAt
//        self.deletedAt = object.deletedAt
//        self.readAt = object.readAt
//        
//        
//        let userobj = TGUserInfoModel.retrieveUser(username: object.username)
//        self.user = userobj
//    }
//    
//    /// 从数据库模型转换
//    init(previewMessageObject: PreviewMessageObject) {
//        self.id = previewMessageObject.id
//        self.requestID = previewMessageObject.requestID
//        self.fromUserID = previewMessageObject.fromUserID
//        self.toUserID = previewMessageObject.toUserID
//        self.content = previewMessageObject.content
//        self.isRead = previewMessageObject.isRead ? 1 : 0
//        self.createdAt = previewMessageObject.createdAt
//        self.updatedAt = previewMessageObject.updatedAt
//        self.deletedAt = previewMessageObject.deletedAt
//        self.readAt = previewMessageObject.readAt
//    }
//    
//    /// 转换为数据库对象
//    func object() -> MessageDetailObject {
//        let object = MessageDetailObject()
//        object.id = self.id
//        object.requestID = self.requestID
//        object.fromUserID = self.fromUserID
//        object.toUserID = self.toUserID
//        object.content = self.content
//        object.isRead = (self.isRead == 1)
//        object.createdAt = self.createdAt
//        object.updatedAt = self.updatedAt
//        object.deletedAt = self.deletedAt
//        object.readAt = self.readAt
//        object.username = self.user?.username
//        return object
//    }
//    
//    /// 转换为数据库对象
//    func previewMsgObject() -> PreviewMessageObject {
//        let object = PreviewMessageObject()
//        object.id = self.id
//        object.requestID = self.requestID
//        object.fromUserID = self.fromUserID
//        object.toUserID = self.toUserID
//        object.content = self.content
//        object.isRead = (self.isRead == 1)
//        object.createdAt = self.createdAt
//        object.updatedAt = self.updatedAt
//        object.deletedAt = self.deletedAt
//        object.readAt = self.readAt
//        return object
//    }
}

class TGMessageRequestCountModel: Mappable {
    var count: Int = 0
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        count <- map["count"]
    }
}
