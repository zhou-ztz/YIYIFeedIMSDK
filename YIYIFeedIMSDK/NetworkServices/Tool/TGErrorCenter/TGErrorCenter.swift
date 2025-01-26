//
//  TGErrorCenter.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/16.
//

import Foundation
import UIKit
public let errorNetworkInfo = "network_problem".localized

enum TGErrorCode: Int {
    /// 空的参数
    case emptyParameter = 0
    /// 未正常初始化
    case Uninitialized = 1
    /// 网络错误
    ///
    /// - Note: 数据格式错误,类型错误等底层错误
    case networkError = 999
    /// 失去了网络连接
    case lostNetWork = 10_000
    /// 不被识别的数据
    case unrecognizedData = 10_001
    /// 非法请求
    case illegalRequest = 10_002
    /// 登录超时
    case overTime = 20_000
    /// 发送消息,响应超时
    case imResponseOverTime = 20_001
    /// 聊天核心失去了服务器链接
    case imLostNetWork = 20_002
}

class TGErrorCenter: NSObject {

    class func create(With errorCode: TGErrorCode) -> (NSError) {
        switch errorCode {
            case .emptyParameter:
                return NSError(domain: "TGNormalErrorDomain", code: errorCode.rawValue, userInfo: ["NSLocalizedDescription":  "param_empty".localized])
            case .Uninitialized:
                return NSError(domain: "TGNormalErrorDomain", code: errorCode.rawValue, userInfo: ["NSLocalizedDescription":  "error_uninitalized".localized])
            case .networkError:
                return NSError(domain: "TGNormalErrorDomain", code: errorCode.rawValue, userInfo: ["NSLocalizedDescription":  "placeholder_network_error".localized])
            case .lostNetWork:
                return NSError(domain: "TGNetworkErrorDomain", code: errorCode.rawValue, userInfo: ["NSLocalizedDescription":  "connect_lost_check".localized])
            case .unrecognizedData:
                return NSError(domain: "TGNetworkErrorDomain", code: errorCode.rawValue, userInfo: ["NSLocalizedDescription":  "error_unrecognized_data".localized])
            case .illegalRequest:
                return NSError(domain: "TGNetworkErrorDomain", code: errorCode.rawValue, userInfo: ["NSLocalizedDescription":  "error_illegal_request".localized])
            case .overTime:
                return NSError(domain: "TGIMErrorDomain", code: errorCode.rawValue, userInfo: ["NSLocalizedDescription":  "error_overtime".localized])
            case .imResponseOverTime:
                return NSError(domain: "TGIMErrorDomain", code: errorCode.rawValue, userInfo: ["NSLocalizedDescription":  "error_response_overtime".localized])
            case .imLostNetWork:
                return NSError(domain: "TGIMErrorDomain", code: errorCode.rawValue, userInfo: ["NSLocalizedDescription":  "error_im_lost_network".localized])
        }
    }
}
