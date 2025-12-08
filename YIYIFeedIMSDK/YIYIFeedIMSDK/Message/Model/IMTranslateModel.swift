//
//  IMTranslateModel.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/19.
//

import Foundation


struct IMTranslateModel : Codable {
    let text : String?

    enum CodingKeys: String, CodingKey {
        case text = "message"
    }
}

struct IMRevokeModel : Codable {
    let code : Int?
    let desc : String?

    enum CodingKeys: String, CodingKey {
        case code = "code"
        case desc = "desc"
    }
}
