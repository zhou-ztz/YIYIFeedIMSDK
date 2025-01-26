//
//  TGPostLocationObject.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/6.
//

import UIKit
//import RealmSwift
import ObjectMapper

class TGPostLocationObject: Mappable {
    
    @objc dynamic var locationID: String = ""
    @objc dynamic var locationName: String = ""
    @objc dynamic var locationLatitude: Float = 0
    @objc dynamic var locationLongtitude: Float = 0
    @objc dynamic var address: String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    func mapping(map: Map) {
        locationID <- map["lid"]
        locationName <- map["name"]
        locationLatitude <- map["lat"]
        locationLongtitude <- map["lng"]
        address <- map["address"]
    }
    
}
