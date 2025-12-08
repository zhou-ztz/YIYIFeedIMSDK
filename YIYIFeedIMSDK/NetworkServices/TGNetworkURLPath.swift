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
    
    /// 动态
    enum Feed: String {
        case feeds
        
        case translate = "feeds/{feed_id}/translation"
        /// 编辑
        case editFeed = "feeds/"
        /// 评论
        case comments = "/comments"
        /// 收藏
        case collection = "/collections"
        /// 取消收藏
        case uncollect = "/uncollect"
        /// 动态置顶
        case pinneds = "/currency-pinneds"
        
        case disableComment = "/comments/disable"
        
        case react = "feeds/{feed_id}/react"
        
        case reactions = "feeds/{feed_id}/reactions"
        /// 直播
        case live = "feeds/live"
        
        case miniVideo = "feeds/mini-video"
        
        /// 修改动态
        case editRejectFeeds = "feeds/reject/{feed_id}"
        
    }
}
