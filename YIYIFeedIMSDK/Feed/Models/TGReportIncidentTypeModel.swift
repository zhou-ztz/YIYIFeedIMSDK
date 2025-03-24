//
//  TGReportIncidentTypeModel.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/3/17.
//

import Foundation
import ObjectMapper

class TGReportIncidentTypeModel: Decodable, Mappable {
    var message : [String] = []
    var data : [ReportTypeEntity] = []

    init () {}

    required init?(map: Map){}

    func mapping(map: Map) {
        message <- map["message"]
        data <- map["data"]
    }

    enum CodingKeys: String, CodingKey {
        case message
        case data
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        message = try values.decode(Array.self, forKey: .message)
        data = try values.decode(Array<ReportTypeEntity>.self, forKey: .data)
    }
}

class ReportTypeEntity: Decodable, Mappable {
    var reportTypeId: Int = 0
    var localiseKey: String = ""
    var order: Int = 0
    var createdAt: String = ""
    var updatedAt: String = ""
    
    required init() { }
    
    required init?(map: Map){}

    func mapping(map: Map) {
        reportTypeId <- map["id"]
        localiseKey <- map["localise_key"]
        order <- map["order"]
        createdAt <- map["created_at"]
        updatedAt <- map["updated_at"]
    }

    enum CodingKeys: String, CodingKey {
        case reportTypeId
        case localiseKey = "localise_key"
        case order
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        reportTypeId = try values.decode(Int.self, forKey: .reportTypeId)
        localiseKey = try values.decodeIfPresent(String.self, forKey: .localiseKey) ?? ""
        order = try values.decode(Int.self, forKey: .order)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt) ?? ""
    }
}
