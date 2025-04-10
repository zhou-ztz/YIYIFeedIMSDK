//
//  TGRejectListModel.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/4/1.
//

import UIKit
import ObjectMapper

struct TGRejectModel: Mappable {
    var data:[TGRejectListModel] = []
    var links:[String:Any] = [:]
    var meta:[String:Any] = [:]
    
    init?(map: Map) {
    }
    init() {
    }
    mutating func mapping(map: Map) {
        data <- map["data"]
        links <- map["links"]
        meta <- map["meta"]
    }
}

struct TGRejectListModel: Mappable {
    
    var id: Int = 0
    var createdAt: Date = Date()
    var data: [String:Any] = [:]
    var sensitiveContent: String = ""
    var cover: String = ""
    var isVideo: Bool = false
    
    init?(map: Map) {
    }
    init() {
    }
    mutating func mapping(map: Map) {
        id <- map["id"]
        createdAt <- (map["created_at"], DateTransformer)
        sensitiveContent <- map["sensitiveContent"]
        cover <- map["cover"]
        isVideo <- map["is_video"]
    }
}


struct TGRejectDetailModel: Mappable {
    var images = [TGRejectDetailModelImages]()
    var textModel: TGRejectDetailModelText?
    var video: TGRejectDetailModelVideo?
    var at = [String]()
    var location: TGRejectDetailModelLocation?
    var privacy: String?
    var topics = [TGRejectDetailModelTopics]()
    var tagUsers: [TGUserInfoModel]?
    var rewardsLinkMerchantUsers : [TGUserInfoModel]?
    var tagVoucher: TagVoucherModel?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        at     <- map["at"]
        images <- map["images"]
        textModel   <- map["text"]
        video  <- map["video"]
        location <- map["location"]
        privacy  <- map["privacy"]
        topics   <- map["topics"]
        tagUsers   <- map["tag_users"]
        rewardsLinkMerchantUsers   <- map["rewards_link_merchant_yippi_users"]
        tagVoucher   <- map["tag_voucher"]
    }
}

struct TGRejectDetailModelText: Mappable {
    var feedContent: String?
    var isSensitive: Bool = false
    var sensitiveType: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        feedContent   <- map["feedContent"]
        isSensitive   <- map["isSensitive"]
        sensitiveType <- map["sensitiveType"]
    }
}

struct TGRejectDetailModelImages: Mappable {
    var fileId: Int = 0
    var imagePath: String?
    var isSensitive: Bool = false
    var sensitiveType: String?
    
    init?(map: Map) {}
    
    init(fileId: Int, imagePath: String?, isSensitive: Bool, sensitiveType: String?) {
         self.fileId = fileId
         self.imagePath = imagePath
         self.isSensitive = isSensitive
         self.sensitiveType = sensitiveType
    }
    mutating func mapping(map: Map) {
        fileId        <- map["imageId"]
        imagePath     <- map["imagePath"]
        isSensitive   <- map["isSensitive"]
        sensitiveType <- map["sensitiveType"]
    }
}

struct TGRejectDetailModelVideo: Mappable {
    var coverId: Int = 0
    var coverPath: String?
    var isSensitive: Bool = false
    var sensitiveType: String?
    var videoId: Int = 0
    var videoPath: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        coverId       <- map["coverId"]
        coverPath     <- map["coverPath"]
        isSensitive   <- map["isSensitive"]
        sensitiveType <- map["sensitiveType"]
        videoId       <- map["videoId"]
        videoPath     <- map["videoPath"]
    }
}

struct TGRejectDetailModelLocation: Mappable {
    var address: String?
    var lat: Float = 0.0
    var lid: String?
    var lng: Float = 0.0
    var name: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        address <- map["address"]
        lat     <- map["lat"]
        lid     <- map["lid"]
        lng     <- map["lng"]
        name    <- map["name"]
    }
}

struct TGRejectDetailModelTopics: Mappable {
    var createdAt: String?
    var creatorUserId: Int = 0
    var desc: String?
    var feedsCount: Int = 0
    var followersCount: Int = 0
    var hotAt: String?
    var id: Int = 0
    var logo: TGRejectDetailModelTopicsLogo?
    var name: String?
    var pivot: TGRejectDetailModelTopicsPivot?
    var status: String?
    var updatedAt: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        createdAt       <- map["created_at"]
        creatorUserId   <- map["creator_user_id"]
        desc            <- map["desc"]
        feedsCount      <- map["feeds_count"]
        followersCount  <- map["followers_count"]
        hotAt           <- map["hot_at"]
        id              <- map["id"]
        logo            <- map["logo"]
        name            <- map["name"]
        pivot           <- map["pivot"]
        status          <- map["status"]
        updatedAt       <- map["updated_at"]
    }
}

struct TGRejectDetailModelTopicsPivot: Mappable {
    var feedId: Int = 0
    var topicId: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        feedId   <- map["feed_id"]
        topicId  <- map["topic_id"]
    }
}

struct TGRejectDetailModelTopicsLogo: Mappable {
    var dimension: TGRejectDetailModelTopicsLogoDimension?
    var mime: String?
    var size: String?
    var url: String?
    var vendor: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        dimension <- map["dimension"]
        mime      <- map["mime"]
        size      <- map["size"]
        url       <- map["url"]
        vendor    <- map["vendor"]
    }
}

struct TGRejectDetailModelTopicsLogoDimension: Mappable {
    var height: Int = 0
    var width: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        height <- map["height"]
        width  <- map["width"]
    }
}


