//
//  TGmessagePopModel.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/2.
//

import UIKit
import NIMSDK

enum messageType {
    /// 纯文字
    case text
    /// 图片
    case pic
    /// 视频
    case video
    /// 圈子图片
    case groupPic
    /// 帖子纯文字
    case postText
    /// 帖子图片
    case postPic
    /// 资讯纯文字
    case newsText
    /// 资讯图片
    case newsPic
    /// 问题详情
    case question
    /// 回答详情
    case questionAnswer
    /// 表情
    case sticker
    /// 专业
    case officialPage
    
    case live
    
    case url

    case miniProgram
    
    case miniVideo
    
    case voucher
    
    case referral
    
    case referLink(url: String)
    
    case campaign(url: String)
    
    var path: String {
        switch self {
        case .officialPage:
            return "users"
        case .newsText, .newsPic:
            return "news"
        case .sticker:
            return "sticker"
        case .miniProgram:
            return "miniprogram"
        case .voucher:
            return "voucher"
        default:
            return "feeds"
        }
    }
    
    var messageTypeID: String {
        switch self {
        case .text:
            return "0"
        case .pic:
            return "1"
        case .video:
            return "dynamic_video"
        case .groupPic:
            return "3"
        case .postText:
            return "4"
        case .postPic:
            return "5"
        case .newsText:
            return "6"
        case .newsPic:
            return "7"
        case .question:
            return "8"
        case .questionAnswer:
            return "9"
        case .sticker:
            return "10"
        case .officialPage:
            return "11"
        case .live:
            return "live"
        case .miniProgram:
            return "mini_program"
        case .voucher:
            return "voucher"
        case .referral:
            return "referral"
        default:
            return "99"
        }
    }
}


class TGmessagePopModel {

    var titleFirst = "text_send_to".localized
    var titleSecond = ""
    /// 正文标题（用户名、圈子名称、帖子标题、资讯标题）
    var owner = ""
    var imageIcon: UIImage = #imageLiteral(resourceName: "ico_pic_disabled")
    /// 正文内容（圈子简介、帖子正文）
    var content = ""
    var contentType = messageType.text
    /// 动态id 帖子id 资讯id 圈子id（圈子类型的时候）
    var feedId = 0
    var coverImage = ""
    /// 帖子类型的时候圈子的id
    var groupId = 0
    /// 留言内容
    var noteContent = ""
    /// 链接
    var contentUrl: String {
        switch contentType {
        case .referLink(let url):
            return url
        case .campaign(let url):
            return url
        default:
            return "\(RLSDKManager.shared.loginParma?.apiBaseURL ?? "")\(contentType.path)/\(String(feedId))"
        }
    }
    /// Mini Program app id
    var appId = ""
    /// Mini Program path for open
    var path = ""
    /// QRCode
    var qrImage: UIImage = #imageLiteral(resourceName: "ico_pic_disabled")
    var isQRCode: Bool = false
    ///活动
    var campaignContent: String = ""
    init() {
    }

    init(momentModel: FeedListCellModel) {
        feedId = momentModel.id["feedId"] ?? 0
        owner = momentModel.userName
        contentType = .text
        content = momentModel.content
        coverImage = (momentModel.userInfo?.avatarUrl).orEmpty
        noteContent = "feed_click_text".localized
        if let repostModel = momentModel.repostModel, repostModel.id > 0 {
            owner = repostModel.title ?? momentModel.userName
            imageIcon = #imageLiteral(resourceName: "ico_pic_disabled")
            contentType = .pic
            switch repostModel.type {
            case .news:
                noteContent = "feed_click_article".localized
            case .postImage:
                noteContent = "feed_click_picture".localized
            case .postLive:
                noteContent = "feed_click_live".localized
            case .postSticker:
                noteContent = "feed_click_sticker".localized
            case .postVideo:
                noteContent = "feed_click_video".localized
            case .postMiniVideo:
                noteContent = "feed_click_mini_video".localized
            case .postWord:
                noteContent = "feed_click_text".localized
            case .postMiniProgram:
                noteContent = "view_mini_program".localized
                if let dict = repostModel.extra?.toDictionary, let appId = dict["appId"] as? String, let path = dict["path"] as? String {
                    self.appId = appId
                    self.path = path
                }
            case .postURL:
                contentType = .url
            default:
                break
            }
            content = repostModel.content ?? ""
            coverImage = repostModel.coverImage ?? ""
            return
        }
        if let shareModel = momentModel.sharedModel {
            owner = shareModel.title.orEmpty
            imageIcon = #imageLiteral(resourceName: "ico_video_disabled")
            content = shareModel.desc ?? momentModel.content
            switch shareModel.sharedType {
            case SharedType.metadata.rawValue:
                contentType = .url
                noteContent = "feed_click_article".localized
            case SharedType.sticker.rawValue:
                contentType = .sticker
                noteContent = "feed_click_sticker".localized
            case SharedType.live.rawValue:
                contentType = .live
                noteContent = "feed_click_live".localized
            case SharedType.miniVideo.rawValue:
                contentType = .miniVideo
                noteContent = "feed_click_mini_video".localized
            case SharedType.user.rawValue:
                contentType = .pic
                noteContent = "view_user".localized
            case SharedType.miniProgram.rawValue:
                contentType = .miniProgram
                noteContent = "view_mini_program".localized
                if let dict = shareModel.extra?.toDictionary, let appId = dict["appId"] as? String, let path = dict["path"] as? String {
                    self.appId = appId
                    self.path = path
                }
            default:
                noteContent = "feed_click_picture".localized
            }
            coverImage = shareModel.thumbnail.orEmpty
            return
        }
        if momentModel.pictures.count > 0 && momentModel.videoURL.isEmpty && momentModel.liveModel == nil {
            imageIcon = #imageLiteral(resourceName: "ico_pic_disabled")
            contentType = .pic
            content = momentModel.content
            coverImage = momentModel.pictures.first?.url ?? ""
            noteContent = "feed_click_picture".localized
            return
        }
        if !momentModel.videoURL.isEmpty && momentModel.liveModel == nil {
            imageIcon = #imageLiteral(resourceName: "ico_video_disabled")
            contentType = momentModel.videoType == 2 ? .miniVideo : .video
            content = momentModel.content
            coverImage = momentModel.pictures.first?.url ?? ""
            noteContent = momentModel.videoType == 2 ? "feed_click_mini_video".localized : "feed_click_video".localized
            return
        }
        if let live = momentModel.liveModel {
            imageIcon = #imageLiteral(resourceName: "ico_video_disabled")
            content = momentModel.content
            coverImage = momentModel.pictures.first?.url ?? ""
            if live.status == 1 {
                noteContent = "feed_click_live".localized
                contentType = .live
            } else {
                noteContent = "feed_click_video".localized
                contentType = .video
            }
            return
        }
    }

    @available(*, deprecated, message: "Please use init(momentModel:) instead")
    init(model: FeedListCellModel) {
        guard let userInfo = model.userInfo else { return }
        feedId = model.idindex
        self.owner = userInfo.name
        contentType = .text
        content = model.content
        coverImage = (userInfo.avatarUrl).orEmpty
        noteContent = "feed_click_text".localized
        if model.pictures.count > 0 && model.videoURL == nil && model.liveModel == nil {
            self.imageIcon = #imageLiteral(resourceName: "ico_pic_disabled")
            contentType = .pic
            coverImage = model.pictures.first?.url ?? ""
            noteContent = "feed_click_picture".localized
            return
        }
        if model.videoURL != nil && model.liveModel == nil {
            self.imageIcon = #imageLiteral(resourceName: "ico_video_disabled")
            contentType = .video
            if (model.liveModel?.status == 1) {
                contentType = .live
            }
            coverImage = model.pictures.first?.url ?? ""
            noteContent = "feed_click_video".localized
            return
        }
        if let live = model.liveModel {
            imageIcon = #imageLiteral(resourceName: "ico_video_disabled")
            coverImage = model.pictures.first?.url ?? ""
            if live.status == 1 {
                noteContent = "feed_click_live".localized
                contentType = .live
            } else {
                noteContent = "feed_click_video".localized
                contentType = .video
            }
            return
        }
        if let repostModel = model.repostModel {
            owner = repostModel.title ?? owner
            imageIcon = #imageLiteral(resourceName: "ico_pic_disabled")
            contentType = .pic
            switch repostModel.type {
            case .news:
                noteContent = "feed_click_article".localized
            case .postImage:
                noteContent = "feed_click_picture".localized
            case .postLive:
                noteContent = "feed_click_live".localized
            case .postSticker:
                noteContent = "feed_click_sticker".localized
            case .postVideo:
                noteContent = "feed_click_video".localized
            case .postWord:
                noteContent = "feed_click_text".localized
            case .postMiniProgram:
                noteContent = "view_mini_program".localized
            case .postURL:
                contentType = .url
            default:
                break
            }
            content = repostModel.content ?? ""
            coverImage = repostModel.coverImage ?? ""
            return
        }
        if let shareModel = model.sharedModel {
            owner = shareModel.title.orEmpty
            imageIcon = #imageLiteral(resourceName: "ico_video_disabled")
            content = shareModel.desc ?? content
            switch shareModel.sharedType {
            case SharedType.metadata.rawValue:
                contentType = .url
                noteContent = "feed_click_article".localized
            case SharedType.sticker.rawValue:
                contentType = .sticker
                noteContent = "feed_click_sticker".localized
            case SharedType.live.rawValue:
                contentType = .live
                noteContent = "feed_click_live".localized
            case SharedType.user.rawValue:
                contentType = .pic
                noteContent = "view_user".localized
            case SharedType.miniProgram.rawValue:
                contentType = .miniProgram
                noteContent = "view_mini_program".localized
            default:
                noteContent = "feed_click_picture".localized
            }
            coverImage = shareModel.thumbnail.orEmpty
            return
        }
    }

    /// Official page
//    init(homePage: HomepageModel) {
//        feedId = homePage.userIdentity
//        contentType = .officialPage
//        owner = homePage.userInfo.name
//        coverImage = homePage.userInfo.avatarUrl.orEmpty
//        content = homePage.userInfo.shortDesc
//    }
    
    /// UserSessionInfo
//    init(userInfo: UserSessionInfo, referalURL: String) {
//        feedId = userInfo.userIdentity
//        contentType = .referLink(url: referalURL)
//        owner = userInfo.name
//        coverImage = userInfo.avatarUrl.orEmpty
//        content = String(format: "rw_re_share_text".localized, referalURL)
//    }

    /// Mini Program
    init(mpModel: TGMiniProgramShareModel) {
        appId = mpModel.appId.orEmpty
        contentType = .miniProgram
        owner = mpModel.title.orEmpty
        coverImage = mpModel.thumbnail.orEmpty
        content = mpModel.desc.orEmpty
        path = mpModel.path.orEmpty
        noteContent = "view_mini_program".localized
    }
    
    /// Sticker
    init(stickerInfo: BundleInfo) {
        feedId = Int(stickerInfo.bundleId) ?? 0
        contentType = .sticker
        owner = stickerInfo.bundleName.orEmpty
        coverImage = stickerInfo.bundleIcon.orEmpty
        content = stickerInfo.description.orEmpty
        noteContent = "feed_click_sticker".localized
    }
    
    /// live
    init(live: LiveEntityModel, id: Int, hostName: String, thumbnail: String?) {
        feedId = id
        contentType = .live
        owner = hostName
        content = live.liveDescription
        coverImage = thumbnail ?? ""
        noteContent = "feed_click_live".localized
    }
    
    /// news
//    init(newsDetail: NewsDetailModel) {
//        contentType = .newsText
//        feedId = newsDetail.id
//        owner = newsDetail.title
//        content = newsDetail.subject?.ts_customMarkdownToNormal().ts_filterMarkdownTagsToPlainText() ?? newsDetail.content_markdown.ts_customMarkdownToNormal().ts_filterMarkdownTagsToPlainText()
//        noteContent = "feed_click_article".localized
//    }
    
    ///QRCode
    init(qrCodeImage: UIImage) {
        contentType = .pic
        qrImage = qrCodeImage
        isQRCode = true
    }
    
    ///Voucher
    init(voucherDetails: VoucherDetailsResponse) {
        contentType = .voucher
        feedId = voucherDetails.id ?? 0
        owner = voucherDetails.name ?? ""
        if let descriptionLong = voucherDetails.descriptionLong, !descriptionLong.isEmpty {
            content = descriptionLong
        } else if let descriptionShort = voucherDetails.description, !descriptionShort.isEmpty {
            content = descriptionShort
        }
        if let images = voucherDetails.imageURL, !images.isEmpty {
            coverImage = images.first ?? ""
        } else {
            coverImage = voucherDetails.logoURL?.first ?? ""
        }
    }
    
    init(referralImage: UIImage, text: String) {
        contentType = .referral
        content = text
        qrImage = referralImage
        coverImage = convertImageToURLString(referralImage)
    }
    
    init(image: UIImage, text: String) {
        contentType = .pic
        content = text
        qrImage = image
        isQRCode = true
    }

    /// 小程序分享campaign
    init(imageUrl: String, text: String, url: String, desc: String) {
        owner = text
        content = desc
        contentType = .campaign(url: url)
        coverImage = imageUrl
        campaignContent = "rw_campaign_miniprogram_share".localized
    }
    
    func convertImageToURLString(_ image: UIImage) -> String {
        // Convert UIImage to Data
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return ""
        }
        
        // Get the temporary directory
        let tempDirectory = FileManager.default.temporaryDirectory
        
        // Create a unique file name
        let fileName = UUID().uuidString + ".jpg"
        var fileURL = tempDirectory.appendingPathComponent(fileName).absoluteString
        let filePathTemp = fileURL
        
       // fileURL = fileURL.replacingOccurrences(of: "file:///", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        do {
            // Write image data to the file URL
            try imageData.write(to: URL(string: filePathTemp)!, options: .atomic)
            // Return the file URL as a string
            return fileURL
        } catch {
            print("Error saving image to URL: \(error)")
            return ""
        }
    }
}
