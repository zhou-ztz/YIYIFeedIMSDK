//
//  TGLocationModel.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/17.
//

import UIKit

class FourSquareLocationModel:  NSObject, Codable {
    var locations : [TGLocationModel]?
    
    enum CodingKeys: String, CodingKey {
        case locations = "locations"
    }

}

class TGLocationModel: NSObject, Codable{
    
    var locationID: String = ""
    var locationName: String = ""
    var locationLatitude: Float = 0
    var locationLongtitude: Float = 0
    var address: String?
    
    enum CodingKeys: String, CodingKey {
        case locationID = "lid"
        case locationName = "name"
        case locationLatitude = "lat"
        case locationLongtitude = "lng"
        case address = "address"
    }
}
