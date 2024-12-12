//
//  WhiteBoardAuth.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/10.
//

import UIKit

class WhiteBoardAuth: NSObject, Codable {
    var nonce: String = ""
    var checksum: String = ""
    var curTime: String = ""
    
    enum CodingKeys: String, CodingKey {
        case nonce = "nonce"
        case checksum = "checksum"
        case curTime = "curTime"
    }
    
}

class WhiteBoardModel: NSObject, Codable {
    var message: String = ""
    var code: Int?
    var data: WhiteBoardRoom?
    enum CodingKeys: String, CodingKey {
        case message 
        case code
        case data
    }
}
class WhiteBoardRoom: NSObject, Codable{
    var cid: Int = 0
    enum CodingKeys: String, CodingKey {
        case cid
    }
}
