//
//  TGMiniProgramShareModel.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/2.
//

import Foundation
import ObjectMapper

class TGMiniProgramShareModel: Mappable {
    var title: String?
    var desc: String?
    var thumbnail: String?
    var appId: String?
    var path: String?

    init?( ) { }

    required init?(map: Map) { }

    func mapping(map: Map) {
        title <- map["params.title"]
        desc <- map["params.desc"]
        thumbnail <- map["params.imageUrl"]
        appId <- map["appId"]
        path <- map["params.path"]

        if title == nil {
            title <- map["appTitle"]
        }
        if desc == nil {
            desc <- map["appDescription"]
        }
        if thumbnail == nil {
            thumbnail <- map["appAvatar"]
        }
        if appId == nil {
            appId <- map["appId"]
        }

    }
}

struct PinnedMessageModel:  Mappable{
    var content: String?
    var id: Int = 0
    var im_group_id: String = ""
    var im_msg_id: String = ""
    var created_at: String?
    var updated_at: String?
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        content <- map["content"]
        id <- map["id"]
        im_group_id <- map["im_group_id"]
        im_msg_id <- map["im_msg_id"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
    }
    
}
