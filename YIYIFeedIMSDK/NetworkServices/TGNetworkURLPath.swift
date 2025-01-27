//
//  TGNetworkURLPath.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/6.
//

import Foundation
// MARK: - V2 版本接口
enum TGURLPathV2: String {
    /// 默认路径
    case path = "api/v2/"
    
    case miniProgramPath = "api/"
    
    /// 下载文件
    enum Download: String {
        case files
    }
    
}
