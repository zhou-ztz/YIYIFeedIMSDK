//
//  TGRepostModel.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/2.
//

import UIKit
import ObjectMapper
import ObjectBox
public enum TGRepostType: String {
    /// 动态
    case postWord
    case postImage
    case postVideo
    case postLive
    case postSticker
    case postURL
    case postUser
    case postMiniProgram
    case postMiniVideo
    /// 资讯
    case news
    /// 问题
    case question
    /// 回答
    case questionAnswer
    /// 已删除
    case delete
}
public class TGRepostModel {
    /// 分享最大内容数量
    public let maxContenWord = 60
    /// 类型
    public var type: TGRepostType = .postWord
    /// 用于object传递,优先使用该字段
    public var typeStr: String?
    /// 基本ID
    public var id: Int = 0
    /// 附加ID,比如帖子需要的圈子ID
    public var subId: Int = 0
    /// 标题内容
    public var title: String?
    /// 正文内容
    public var content: String?
    /// 封面
    public var coverImage: String?

    public var extra: String?
    
    init(type: TGRepostType) {
        self.type = type
        self.typeStr = type.rawValue
    }
    
    init(feed: FeedListModel) {
        self.id = feed.id
        self.title = feed.user?.name
        self.content = feed.content
        
        if let video = feed.feedVideo, feed.liveModel == nil {
            self.type = video.type == 2 ? .postMiniVideo : .postVideo
            self.coverImage = video.videoCoverID.imageUrl()
        } else if let images = feed.images, images.count > 0 {
            self.type = .postImage
            self.coverImage = images.first?.file.imageUrl()
        } else if let live = feed.liveModel {
            self.content = live.liveDescription
            self.type = live.status == 1 ? .postLive : .postVideo
        } else if let sharedModel = feed.sharedModel {
            self.title = sharedModel.title
            self.content  = sharedModel.desc
            self.coverImage = sharedModel.thumbnail
            
            switch sharedModel.type {
            case .sticker:
                self.type = .postSticker
            case .metadata:
                self.type = .postURL
                self.content = sharedModel.url
            case .user:
                self.type = .postUser
                self.content = sharedModel.desc
            case .live:
                self.type = .postLive
                self.subId = sharedModel.extra?.toInt() ?? 0
                self.content = sharedModel.title
            case .miniProgram:
                self.type = .postMiniProgram
                self.extra = sharedModel.extra
            default:
                self.type = .postWord
                self.coverImage = feed.user?.avatarUrl
                self.content = feed.content
                break
            }
        }
    }

    /// 根据typeStr更新type
    func updataModelType() {
        if let typeStr = self.typeStr {
            if typeStr == "postWord" {
                self.type = .postWord
            } else if typeStr == "postVideo" {
                self.type = .postVideo
            } else if typeStr == "postImage" {
                self.type = .postImage
            } else if typeStr == "postURL" {
                self.type = .postURL
            } else if typeStr == "postUser" {
                self.type = .postUser
            } else if typeStr == "postSticker" {
                self.type = .postSticker
            } else if typeStr == "postLive" {
                self.type = .postLive
            } else if typeStr == "postMiniProgram" {
                self.type = .postMiniProgram
            } else if typeStr == "news" {
                self.type = .news
            } else if typeStr == "postMiniVideo" {
                self.type = .postMiniVideo
            } else {
                /// 已经删除
                self.type = .delete
            }
        }
    }
    
    init(model: FeedListCellModel) {
        if model.repostType == nil {
            self.id = model.id["feedId"] ?? 0
            self.title = model.userName
            self.content = model.content
            self.coverImage = model.avatarInfo?.avatarURL
            if let live = model.liveModel, live.status != YPLiveStatus.finishProcess.rawValue {
                self.coverImage = model.pictures.first?.url
                self.type = .postLive
            } else if model.videoURL.count > 0 {
                self.coverImage = model.pictures.first?.url
                self.type = model.videoType == 2 ? .postMiniVideo : .postVideo
            } else if model.pictures.count > 0 {
                self.type = .postImage
                self.coverImage = model.pictures.first?.url
            } else if let sharedModel = model.sharedModel {
                self.title = sharedModel.title
                self.content  = sharedModel.desc
                self.coverImage = sharedModel.thumbnail
                
                switch sharedModel.type {
                case .sticker:
                    self.type = .postSticker
                case .metadata:
                    self.type = .postURL
                    self.content = sharedModel.url
                case .user:
                    self.type = .postUser
                    self.content = sharedModel.desc
                case .live:
                    self.type = .postLive
                    self.subId = sharedModel.extra?.toInt() ?? 0
                    self.content = sharedModel.title
                case .miniProgram:
                    self.type = .postMiniProgram
                    self.extra = sharedModel.extra
                default:
                    self.type = .postWord
                    self.coverImage = model.userInfo?.avatarUrl
                    self.content = model.content
                    break
                }
            } else {
                self.type = .postWord
            }
        } else {
            self.id = model.repostId
            self.type = model.repostModel?.type ?? .postWord
            self.content = model.repostModel?.content
            self.coverImage = model.repostModel?.coverImage
            self.title = model.repostModel?.title
        }
    }

    // MARK: - 统一的MarkDown格式的内容处理,比如帖子、资讯、问答等内容都需要统一处理
//    fileprivate class func getShareContentFromMarkdown(markDownContent: String) -> String {
//        /// 移除html标签以及\n等符号 -> 转标准markdown(如果是TS的markdown格式) -> 将图片样式转换为[图片]
//        return markDownContent.ts_filterMarkdownTagsToPlainText().ts_customMarkdownToStandard().ts_standardMarkdownToNormal()
//    }
    
//    static func retrieveRepost(_ repostId: Int) -> TGRepostModel? {
//        return FeedsStoreManager().fetchById(id: repostId)
//    }
}


public class LiveEntityModel: Mappable {
    
    // objectbox: id = { "assignable": true }
    public var feedId: Id = 0
    public var streamName: String? = nil
    public var liveDescription: String = ""
    var pushUrl = ""
    var rtmp = ""
    public var status = -1
    public var roomId: String = ""
    
    var rtmpSD = ""
    var rtmpLD = ""
    var rtmpHD = ""
    var flvSD = ""
    var flvLD = ""
    var flvHD = ""
    
    var frameIcon: String?
    var frameTint: String?
    var sorting: Int = 0
    
    var rtmpHost: String = ""
    var rtmpAuth: String = ""
    
    var host: String?
    var hostName: String?
    var hostIconUrl: String?
    var hostUsername: String?
    var hostAvatarUrl: String?

    var profileFrameIcon: String?
    var profileFrameTint: String?
    
    required init() {}
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        var key: Int?
        key <- map["feed_id"]
        
        feedId = Id(key.orZero)
        
        streamName <- map["stream_name"]
        liveDescription <- map["description"]
        pushUrl <- map["push_url"]
        rtmp <- map["rtmp"]
        status <- map["status"]
        roomId <- map["room_id"]
        
        rtmpSD <- map["rtmp_sd"]
        rtmpHD <- map["rtmp_hd"]
        rtmpLD <- map["rtmp_ld"]
        flvSD <- map["flv_sd"]
        flvHD <- map["flv_hd"]
        flvLD <- map["flv_ld"]
        
        frameIcon <- map["live_frame.icon_url"]
        frameTint <- map["live_frame.color_code"]
        sorting <- map["live_frame.sort"]
        
        host <- map["users.user_id"]
        hostIconUrl <- map["users.verified.icon"]
        hostAvatarUrl <- map["users.avatar.url"]
        hostUsername <- map["users.username"]
        hostName <- map["users.name"]
        
        profileFrameIcon <- map["users.profile_frame.frame.icon_url"]
        profileFrameTint <- map["users.profile_frame.frame.color_code"]
        
        rtmpHost <- map["rtmp_host"]
        rtmpAuth <- map["rtmp_auth"]
    }
}


extension LiveEntityModel {
    static func convert(_ object: LiveEntityModel?) -> String? {
        guard let object = object else { return nil }
        return object.toJSONString()
    }
    
    static func convert(_ json: String?) -> LiveEntityModel? {
        guard let json = json else { return nil }
        return LiveEntityModel(JSONString: json)
    }

    func avatarInfo() -> TGAvatarInfo {
//        let verifiedInfo = TSUserVerifiedModel(type: hostIconUrl, icon: hostIconUrl)
//        let info = TGAvatarInfo(avatarURL: hostAvatarUrl.orEmpty, verifiedInfo: verifiedInfo)
//        info.frameColor = self.frameTint ?? self.profileFrameTint
//        info.frameIcon = self.frameIcon ?? self.profileFrameIcon
//        info.liveId = self.feedId.intValue
        let info = TGAvatarInfo()
        return info
    }
}

