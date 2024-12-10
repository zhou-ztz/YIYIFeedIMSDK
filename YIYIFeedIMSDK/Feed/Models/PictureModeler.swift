//
//  PictureModeler.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/28.
//

import Foundation
import UIKit

class PictureModeler {

    var file: Int = 0
    /// 图片网络链接
    var url: String?
    /// 文件供应商
    var vendor: String = "local"
    /// 图片缓存地址
    var cache: String?
    /// 图片原始的大小
    var originalSize = CGSize.zero
    /// 加载图片时是否要清空旧的图片缓存
    var shouldClearCache = false
    /// 是否需要显示长图标识
    var shouldShowLongicon = false
    /// 没有被显示的图片的数量，小于 0 则不显示数量蒙层
    var unshowCount = 0
    /// 图片类型
    var mimeType: String = ""

    // MARK: Object
//    func object() -> PictureObject {
//        let object = PictureObject()
//        object.url = url
//        object.cache = cache
//        object.originalWidth = originalSize.width
//        object.originalHeight = originalSize.height
//        object.shouldClearCache = shouldClearCache
//        object.shouldShowLongicon = shouldShowLongicon
//        object.mimeType = mimeType
//        object.vendor = vendor
//        return object
//    }
}

class PaidPictureModel: PictureModeler {
    override init() {
        super.init()
    }
//    /// 初始化动态列表图片
//    init(feedImageModel model: TSNetFileModel) {
//        super.init()
//        url = TSUtil.praseTSNetFileUrl(netFile: model)
//        vendor = model.vendor
//        originalSize = TSUtil.praseTSNetFileImageSize(netFile: model)
//        shouldShowLongicon = true
//        mimeType = model.mime
//        vendor = model.vendor
//    }
    
    /// 初始化动态列表图片
    init(feedImageModel model: FeedImageModel) {
        super.init()
        assert(model.file >= 0)
        file = model.file
//        url = model.file.imageUrl()
        originalSize = model.size
        shouldShowLongicon = true
        mimeType = model.mimeType
    }

//    /// 初始化帖子列表图片
//    init(topicPostImageModel model: TopicPostImageModel) {
//        super.init()
//        file = model.id
//        url = model.id.imageUrl()
//        originalSize = model.size
//        shouldShowLongicon = true
//        mimeType = model.mimeType
//    }


//    // MARK: - 等我把 ImageObject 删了，就可以吧这两个方法也删了
//    func imageObject() -> TSImageObject {
//        let object = TSImageObject()
//        if let imageUrl = url {
//            object.netImageUrl = imageUrl
//            let subIndex = (TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue as NSString).length
//            if let fileId = Int((imageUrl as NSString).substring(from: subIndex + 1)) {
//                object.storageIdentity = fileId
//            }
//        }
//        object.cacheKey = cache ?? ""
//        object.width = Double(originalSize.width)
//        object.height = Double(originalSize.height)
//        object.mimeType = mimeType
//        object.paid.value = true
//        
//        return object
//    }
//
//    init(imageObject object: TSImageObject) {
//        super.init()
//        cache = object.cacheKey
//        originalSize = CGSize(width: object.width, height: object.height)
//        shouldClearCache = false
//        shouldShowLongicon = true
//        mimeType = object.mimeType
//        vendor = object.vendor
//        url = object.storageIdentity.imageUrl()
//    }
}

