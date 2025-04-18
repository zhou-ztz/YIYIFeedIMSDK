//
//  RLLoginParma.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/22.
//

import UIKit

public class RLLoginParma: NSObject {

    public var themeColor: Int = 0xED1A3B

    public var apiBaseURL: String!
    // 文件上传url
    public var uploadFileURL: String!
    // LokaliseProjectID
    public var lokaliseProjectID: String!
    // LokaliseSDKToken
    public var lokaliseSDKToken: String!
    //imAccid
    public var imAccid: String!
    // imToken
    public var imToken: String!
    // 用户id
    public var uid: UInt!
    // 用户 Token
    public var xToken: String!
    
    public var countryCode: String = "MY"
    
    public var languageCode: String = "en"
    /// 请求头 appname
    public var appName: String = ""
    /// 个人信息 json
    public var userInfoJson: String = ""
    /// webServerAddress
    public var webServerAddress: String = ""
}
