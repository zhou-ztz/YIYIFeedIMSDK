//
//  TSPostLocationModel.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/28.
//

import Foundation
import ObjectMapper

public class TSPostLocationModel: Mappable {
    
    public var locationID:String = ""
    public var locationName: String = ""
    public var locationLatitude:Float = 0
    public var locationLongtitude:Float = 0
    public var address:String?
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        locationID <- map["lid"]
        locationName <- map["name"]
        locationLatitude <- map["lat"]
        locationLongtitude <- map["lng"]
        address <- map["address"]
    }
    
    static func convert(_ object: TSPostLocationModel?) -> String? {
        guard let object = object else { return nil }
        return object.toJSONString()
    }
    
    static func convert(_ json: String?) -> TSPostLocationModel? {
        guard let json = json else { return nil }
        return TSPostLocationModel(JSONString: json)
    }
}

class TGPostLocationModel: Codable {
    
    var locationID: String?
    var locationName: String?
    var locationLatitude: Float?
    var locationLongtitude: Float?
    var address: String?

    enum CodingKeys: String, CodingKey {
        case locationID = "lid"
        case locationName = "name"
        case locationLatitude = "lat"
        case locationLongtitude = "lng"
        case address = "address"
    }
}
