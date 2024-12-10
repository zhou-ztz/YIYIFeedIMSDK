//
//  TSPostLocationModel.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/28.
//

import Foundation
import ObjectMapper

class TSPostLocationModel: Mappable {
    
    var locationID:String = ""
    var locationName: String = ""
    var locationLatitude:Float = 0
    var locationLongtitude:Float = 0
    var address:String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
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
