//
//  TGCommentModel.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2024/12/26.
//

import Foundation
import ObjectMapper
// MARK: - Response Model
struct TGBaseModelResponse: Codable {
    var message: String?
    var code: Int?
}


class BaseModelResponse: Mappable {
    var message: String?
    var code: Int?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        message <- map["message"]
        code <- map["code"]
    }
}
