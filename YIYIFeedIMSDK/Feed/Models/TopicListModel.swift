//
//  TopicListModel.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/28.
//

import UIKit
import ObjectMapper
/// 话题列表 话题model

class TopicListModel: Mappable {
    var topicId: Int = 0
    var topicTitle: String = ""
//    var topicLogo: TSNetFileModel?
    var topicFollow = false

    required init?(map: Map) {}

    func mapping(map: Map) {
        topicId <- map["id"]
        topicTitle <- map["name"]
//        topicLogo <- map["logo"]
        topicFollow <- map["has_followed"]
    }

//    init(object: TopicListObject) {
//        self.topicId = object.topicId
//        self.topicTitle = object.topicTitle
//        self.topicFollow = object.topicFollow
//        if nil != object.topicLogo {
//            self.topicLogo = TSNetFileModel(object: object.topicLogo!)
//        }
//    }
//
//    func object() -> TopicListObject {
//        let object = TopicListObject()
//        object.topicId = self.topicId
//        object.topicTitle = self.topicTitle
//        object.topicLogo = self.topicLogo?.object()
//        object.topicFollow = self.topicFollow
//        return object
//    }
    
    static func convert(_ object: [TopicListModel]?) -> String? {
        guard let object = object else { return nil }
        return object.toJSONString()
    }
    
    static func convert(_ json: String?) -> [TopicListModel]? {
        guard let json = json else { return nil }
        return Mapper<TopicListModel>().mapArray(JSONString: json)
    }
}
