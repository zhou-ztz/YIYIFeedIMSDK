//
//  RejectDetailModelImages.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/7.
//

import Foundation
import ObjectMapper

struct RejectDetailModelImages: Mappable {
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

struct RejectDetailModelVideo: Mappable {
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

struct RejectDetailModelLocation: Mappable {
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

struct RejectDetailModelTopics: Mappable {
    var createdAt: String?
    var creatorUserId: Int = 0
    var desc: String?
    var feedsCount: Int = 0
    var followersCount: Int = 0
    var hotAt: String?
    var id: Int = 0
    var logo: RejectDetailModelTopicsLogo?
    var name: String?
    var pivot: RejectDetailModelTopicsPivot?
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

struct RejectDetailModelTopicsPivot: Mappable {
    var feedId: Int = 0
    var topicId: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        feedId   <- map["feed_id"]
        topicId  <- map["topic_id"]
    }
}

struct RejectDetailModelTopicsLogo: Mappable {
    var dimension: RejectDetailModelTopicsLogoDimension?
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

struct RejectDetailModelTopicsLogoDimension: Mappable {
    var height: Int = 0
    var width: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        height <- map["height"]
        width  <- map["width"]
    }
}

