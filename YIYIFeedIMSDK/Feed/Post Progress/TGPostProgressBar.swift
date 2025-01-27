//
//  TGPostProgressBar.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/13.
//

import UIKit
import MobileCoreServices
import Photos

struct ShortVideoAsset {
    let coverImage: UIImage?
    let asset: PHAsset?
//    let recorderSession: SCRecordSession?
    let videoFileURL: URL?
}
struct PostVideoExtension {
    var data: Data?
}
enum VideoType: Int {
    case normalVideo = 1
    case miniVideo = 2
    
    var path: String {
        switch self {
        case .normalVideo:
            return TGURLPathV2.path.rawValue + TGURLPathV2.Feed.feeds.rawValue
        case .miniVideo:
            return TGURLPathV2.path.rawValue + TGURLPathV2.Feed.miniVideo.rawValue
        }
    }
}
enum TGPostReleaseType: Int{
    case campaign = 0 //活动
    case normalType  //其他
}
enum TGPostProgressStatus {
    case posting
    case finishingUp
    case complete
    case fail
    case rejectPostFail
    
    var text: String {
        switch self {
        case .complete: return "feed_upload_verify_title".localized
        case .posting: return  "feed_upload_posting".localized
        case .finishingUp : return "feed_upload_post_done".localized
        case .fail: return "feed_upload_fail".localized
        case .rejectPostFail: return "posting_sensitive_message".localized
        }
    }
}
class TGPostProgressBar: UIView {

    private var convertedVideoURL: String = ""
    
    private var status: TGPostProgressStatus = .posting {
        didSet {
          
            switch status {
            case .posting:
                print("=======  准备发布")
            case .finishingUp:
                print("======= 发布中")
            case .complete:
                print("======= 发布完成")
            case .fail:
                print("======= 发布失败")
                
            case .rejectPostFail:
                print("======= 被拒绝帖子重新发布失败")
            }
        }
    }
    var isComplete: Bool {
        return status == .complete
    }
    var isRejectFail: Bool {
        return status == .rejectPostFail
    }
    var type: TGPostReleaseType = .normalType
    
    func add(post: TGPostModel) {
        
        releaseStart(object: post)
    }
    
    private func releaseStart(object: TGPostModel) {
        if object.phAssets?.count ?? 0 > 0 || object.images?.count ?? 0 > 0 {
            if object.isEditFeed == true {
                self.postPhotosWithRejectFeed(object: object)
            } else {
                self.postPhotos(object: object)
            }
        } else if object.postPhoto?.isEmpty == false && object.phAssets?.isEmpty == true {
            self.postPhotosWithData(object: object)
        } else if object.rejectNeedsUploadVideo == false {
            self.postVideoLocally(object: object)
        }
//        else if object.rejectNeedsUploadVideo != nil && object.videoCoverId != nil && object.videoDataId != nil {
//            self.postVideoLocally(object: object)
//        }
        else if object.video != nil && object.postVideo == nil {
            self.postVideo(object: object)
        } else if object.postVideo != nil {
            self.postVideoWithData(object: object)
        } else {
            if object.isEditFeed == true {
                self.postPhotosWithRejectFeed(object: object)
            } else {
                TGFeedNetworkManager.shared.releasePost(feedContent: object.feedContent, feedId: object.feedMark, privacy: object.privacy, images: nil, feedFrom: 3, topics: object.topics, repostType: object.repostType, repostId: object.repostModel?.id, customAttachment: object.shareModel, location: object.taggedLocation, isHotFeed: object.isHotFeed, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (feedId, error) in
                    DispatchQueue.main.async {
                        if error != nil {
                            self?.status = .fail
                        } else {
                            self?.status = .finishingUp
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self?.status = .complete
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    
    private func postPhotosWithRejectFeed(object: TGPostModel) {
       
        if (object.phAssets?.count == 0 && object.images?.count == 0) || (object.phAssets == nil && object.images == nil) {
            
            TGFeedNetworkManager.shared.editRejectFeed(feedID: object.feedId ?? "", feedContent: object.feedContent, feedId: object.feedMark, privacy: object.privacy, images: nil, feedFrom: 3, topics: object.topics, repostType: object.repostType, repostId: object.repostModel?.id, customAttachment: object.shareModel, location: object.taggedLocation, isHotFeed: object.isHotFeed, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (feedId, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        self?.status = .rejectPostFail
                    } else {
                        self?.status = .finishingUp
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self?.status = .complete
                        }
                    }
                }
            }
            return
        }

        // Continue with the rest of the code if phAssetsCount == 0 && imagesCount == 0
        
        let option = PHImageRequestOptions()
        var imageMimeType: [String] = []
        var uploadDatas: [Data] = []
        option.isSynchronous = true
        if let assets = object.phAssets {
            for asset in assets {
                
                PHImageManager.default().requestImageDataAndOrientation(for: asset, options: option) { [weak self] imageData, type, orientation, info in
                    
                    guard let self = self, let data = imageData, let image = UIImage(data: data) else {
                        return
                    }
                    switch type {
                    case String(kUTTypeGIF):
                        imageMimeType.append("image/gif")
                        let compressedData = ImageCompress.compressImageData(data, limitDataSize: 500 * 1024) ?? Data()
                        uploadDatas.append(compressedData)
                    case "public.heic":
                        imageMimeType.append("image/jpeg")
                        if #available(iOS 10.0, *) {
                            guard let ciImage = CIImage(data: data), let imageData = CIContext().jpegRepresentation(of: ciImage, colorSpace: CGColorSpaceCreateDeviceRGB(), options: [:]), let image = UIImage(data: imageData) else {
                                return
                            }
                            let compressedData = image.jpegData(compressionQuality: 1.0) ?? Data()
                            uploadDatas.append(compressedData)
                        }
                    default:
                        imageMimeType.append("image/jpeg")
                        let compressedData = image.jpegData(compressionQuality: 1.0) ?? Data()
                        uploadDatas.append(compressedData)
                    }
                }
            }
            
        }
        //这里上传需要注意判断originalImageIds 已有的图片ID
        var originalImageIds: [Int] = []
        if let images = object.images {
            var thumbnailSet = false // 用于跟踪是否已经设置了缩略图
            for (index, image) in images.enumerated() {
                if let imageItem = image as? UIImage {
                    // 只在第一个元素上设置缩略图
                    if index == 0 && !thumbnailSet {
                        thumbnailSet = true // 设置为true，表示已经设置了缩略图
                    }
                    imageMimeType.append("image/jpeg")
                    let compressedData = imageItem.jpegData(compressionQuality: 1.0) ?? Data()
                    uploadDatas.append(compressedData)
                }
                if let imageModel = image as? RejectDetailModelImages {
                    // 只在第一个元素上设置缩略图
                    if index == 0 && !thumbnailSet {
                        thumbnailSet = true // 设置为true，表示已经设置了缩略图
                    }
                    originalImageIds.append(imageModel.fileId)
                }
            }
        }
        //如果用户不需要上传任何图片
        if uploadDatas.count == 0 && originalImageIds.count > 0 {
            TGFeedNetworkManager.shared.editRejectFeed(feedID: object.feedId ?? "", feedContent: object.feedContent, feedId: object.feedMark, privacy: object.privacy, images: originalImageIds, feedFrom: 3, topics: object.topics, repostType: object.repostType, repostId: object.repostModel?.id, customAttachment: object.shareModel, location: object.taggedLocation, isHotFeed: object.isHotFeed, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (feedId, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        self?.status = .rejectPostFail
                    } else {
                        self?.status = .finishingUp
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self?.status = .complete
                        }
                    }
                }
            }
        }else {
            TGUploadNetworkManager().uploadFileToOBS(fileDatas: uploadDatas) {[weak self] progress in
                guard let self = self else { return }
                print("======= progress ： \(progress)")
            } complete: { [weak self] imageFileds in
                if imageFileds.isEmpty == false && imageFileds.count > 0 {
                    self?.status = .finishingUp
                    TGFeedNetworkManager.shared.releasePost(feedContent: object.feedContent, feedId: object.feedMark, privacy: object.privacy, images: imageFileds, feedFrom: 3, topics: object.topics, repostType: object.repostType, repostId: object.repostModel?.id, customAttachment: object.shareModel, location: object.taggedLocation, isHotFeed: object.isHotFeed, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (feedId, error) in
                        DispatchQueue.main.async {
                            self?.status = .complete
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.status = .fail
                    }
                }
            
            }

        }
  
    }
    
    private func postPhotos(object: TGPostModel) {
 
        guard let assets = object.phAssets else {
            self.status = .fail
            return
        }
        let option = PHImageRequestOptions()
        var imageMimeType: [String] = []
        var uploadDatas: [Data] = []
        option.isSynchronous = true
        for asset in assets {
            
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: option) { [weak self] imageData, type, orientation, info in
                guard let data = imageData, let image = UIImage(data: data) else {
                    return
                }
                
                switch type {
                case String(kUTTypeGIF):
                    imageMimeType.append("image/gif")
                    let compressedData = ImageCompress.compressImageData(data, limitDataSize: 500 * 1024) ?? Data()
                    uploadDatas.append(compressedData)
                case "public.heic":
                    imageMimeType.append("image/jpeg")
                    if #available(iOS 10.0, *) {
                        guard let ciImage = CIImage(data: data), let imageData = CIContext().jpegRepresentation(of: ciImage, colorSpace: CGColorSpaceCreateDeviceRGB(), options: [:]), let image = UIImage(data: imageData) else {
                            return
                        }
                        let compressedData = image.jpegData(compressionQuality: 1.0) ?? Data()
                        uploadDatas.append(compressedData)
                    }
                default:
                    imageMimeType.append("image/jpeg")
                    let compressedData = image.jpegData(compressionQuality: 1.0) ?? Data()
                    uploadDatas.append(compressedData)
                }
            }
        }
        TGUploadNetworkManager().uploadFileToOBS(fileDatas: uploadDatas) {[weak self] progress in
            guard let self = self else { return }
            print("======= progress ： \(progress)")
        } complete: { [weak self] imageFileds in
            if imageFileds.isEmpty == false && imageFileds.count > 0 {
                self?.status = .finishingUp
                TGFeedNetworkManager.shared.releasePost(feedContent: object.feedContent, feedId: object.feedMark, privacy: object.privacy, images: imageFileds, feedFrom: 3, topics: object.topics, repostType: object.repostType, repostId: object.repostModel?.id, customAttachment: object.shareModel, location: object.taggedLocation, isHotFeed: object.isHotFeed, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (feedId, error) in
                    DispatchQueue.main.async {
                        if error != nil {
                            self?.status = .fail
                        } else {
                            self?.status = .complete
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.status = .fail
                }
            }
        
        }

    }
    private func postPhotosWithData(object: TGPostModel) {
    
        let option = PHImageRequestOptions()
        var imageMimeType: [String] = []
        var uploadDatas: [Data] = []
        option.isSynchronous = true
        
        for postPhoto in object.postPhoto ?? [] {
            let image = UIImage(data: postPhoto.data!)
            
            switch postPhoto.type {
            case String(kUTTypeGIF):
                imageMimeType.append("image/gif")
                let compressedData = ImageCompress.compressImageData(postPhoto.data!, limitDataSize: 500 * 1024) ?? Data()
                uploadDatas.append(compressedData)
            case "public.heic":
                imageMimeType.append("image/jpeg")
                if #available(iOS 10.0, *) {
                    guard let ciImage = CIImage(data: postPhoto.data!), let imageData = CIContext().jpegRepresentation(of: ciImage, colorSpace: CGColorSpaceCreateDeviceRGB(), options: [:]), let image = UIImage(data: imageData) else {
                        return
                    }
                    let compressedData = image.jpegData(compressionQuality: 1.0) ?? Data()
                    uploadDatas.append(compressedData)
                }
            default:
                imageMimeType.append("image/jpeg")
                let compressedData = image?.jpegData(compressionQuality: 1.0) ?? Data()
                uploadDatas.append(compressedData)
            }
        }
        TGUploadNetworkManager().uploadFileToOBS(fileDatas: uploadDatas) { [weak self] progress in
            guard let self = self else { return }
            print("======= progress ： \(progress)")
        } complete: { [weak self] imageFileds in
            if imageFileds.isEmpty == false && imageFileds.count > 0 {
                self?.status = .finishingUp
                TGFeedNetworkManager.shared.releasePost(feedContent: object.feedContent, feedId: object.feedMark, privacy: object.privacy, images: imageFileds, feedFrom: 3, topics: object.topics, repostType: object.repostType, repostId: object.repostModel?.id, customAttachment: object.shareModel, location: object.taggedLocation, isHotFeed: object.isHotFeed, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (feedId, error) in
                    DispatchQueue.main.async {
                        if error != nil {
                            self?.status = .fail
                        } else {
                            self?.status = .complete
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.status = .fail
                }
            }
        
        }
    
    }
    private func postVideoLocally(object: TGPostModel) {
        //处理视频本地操作，而不进行上传
        TGFeedNetworkManager.shared.editRejectShortVideo(feedID: object.feedId ?? "" , shortVideoID: object.videoDataId ?? 0, coverImageID: object.videoCoverId ?? 0, feedMark: object.feedMark, feedContent: object.feedContent, privacy: object.privacy, feedFrom: 3, topics: object.topics, location: object.taggedLocation, isHotFeed: object.isHotFeed, soundId: object.soundId, videoType: object.videoType ?? .normalVideo, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (myFeedId, myErrMsg) in
            DispatchQueue.main.async {
                if myFeedId == nil {
                    self?.status = .rejectPostFail
                } else {
                    self?.status = .finishingUp
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self?.status = .complete
                    }
                }
            }
        }
        
    }
    private func postVideoWithData(object: TGPostModel){

        guard let coverImage = object.video?.coverImage else {
            self.status = .fail
            return
        }
        
        var videoData = Data()
        if let postVideo = object.postVideo {
            for item in postVideo {
                videoData = item.data!
            }
        }
        
        let coverData: Data = coverImage.jpegData(compressionQuality: 1.0) ?? Data()
        
        let videoSize = CGSize(width: coverImage.size.width, height: coverImage.size.height)
            
        DispatchQueue.global(qos: .background).async {
            var videoFileID: Int? = nil
            var imageFildID: Int? = nil
            let requestGroup = DispatchGroup()
            requestGroup.enter()
            TGUploadNetworkManager().uploadFileToOBS(fileDatas: [videoData], isImage: false, progressHandler: {[weak self] progress in
//                DispatchQueue.main.async {
//                    self?.progressBar.setProgress(Float(progress.fractionCompleted) * 0.5 + 0.5, animated: true)
//                }
            }) { fileIDs in
                defer {
                    requestGroup.leave()
                }
                guard  let fileID =  fileIDs.first else {
                    return
                }
                videoFileID = fileID
            }
            
            requestGroup.enter()
            TGUploadNetworkManager().uploadFileToOBS(fileDatas: [coverData], isImage: true, videoSize: videoSize) { fileIDs in
                defer {
                    requestGroup.leave()
                }
                guard  let fileID =  fileIDs.first else {
                    return
                }
                imageFildID = fileID
            }
            
            
            requestGroup.notify(queue: DispatchQueue.main) {
                //本地视频存在就删除
                if let url = object.video?.videoFileURL {
                    let path = url.relativeString.replacingOccurrences(of: "file:///", with: "")
                    TGUtil.deleteFile(atPath: path)
                }
                
                if let videoFileID = videoFileID, let imageFildID = imageFildID {
                    self.status = .finishingUp
                    TGFeedNetworkManager.shared.postShortVideo(shortVideoID: videoFileID, coverImageID: imageFildID, feedMark: object.feedMark, feedContent: object.feedContent, privacy: object.privacy, feedFrom: 3, topics: object.topics, location: object.taggedLocation, isHotFeed: object.isHotFeed, soundId: object.soundId, videoType: object.videoType ?? .normalVideo, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (myFeedId, myErrMsg) in
                        if myFeedId != nil {
                            self?.status = .complete
                        } else {
                            self?.status = .fail
                        }
                    }
                } else {
                    self.status = .fail
                }
            }
        }
    }
    
    private func postVideo(object: TGPostModel) {
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        if let url = object.video?.videoFileURL {
            convertedVideoURL = url.relativeString
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            guard let url = URL(string: self.convertedVideoURL), let coverImage = object.video?.coverImage else {
                self.status = .fail
                return
            }
            
            let session = URLSession.shared
            let task: Void = session.dataTask(with: url) { (data, response, error) in
            
                // 处理网络请求的响应
                if let error = error {
                    // 处理错误
                    DispatchQueue.main.async {
                        self.status = .fail
                    }
                    print("Error: \(error)")
                    return
                }
                if let videoData = data {
                    // 成功获取到视频数据，可以在这里进行后续操作
                    print("upload video size: \(videoData.count)")
                    
                    let coverData: Data = coverImage.jpegData(compressionQuality: 1.0) ?? Data()
                    
                    let videoSize = CGSize(width: coverImage.size.width, height: coverImage.size.height)
                    
                    DispatchQueue.global(qos: .background).async {
                        var videoFileID: Int? = nil
                        var imageFildID: Int? = nil
                        let requestGroup = DispatchGroup()
                        requestGroup.enter()
                       
                        TGUploadNetworkManager().uploadFileToOBS(fileDatas: [videoData], isImage: false, videoSize: videoSize, progressHandler: {[weak self] progress in
                            guard let self = self else { return }
                            print("=======  progress:\(progress)")
                        }) { fileIDs in
                            defer {
                                requestGroup.leave()
                            }
                            guard  let fileID =  fileIDs.first else {
                                return
                            }
                            videoFileID = fileID
                        }
                       
                        requestGroup.enter()
                        TGUploadNetworkManager().uploadFileToOBS(fileDatas: [coverData], isImage: true) { fileIDs in
                            defer {
                                requestGroup.leave()
                            }
                            guard  let fileID =  fileIDs.first else {
                                return
                            }
                            imageFildID = fileID
                        }

                        requestGroup.notify(queue: DispatchQueue.main) {
                            
                            if let videoFileID = videoFileID, let imageFildID = imageFildID {
                                self.status = .finishingUp
                                if object.isEditFeed == true {
                                    TGFeedNetworkManager.shared.editRejectShortVideo(feedID: object.feedId ?? "" , shortVideoID: videoFileID, coverImageID: imageFildID, feedMark: object.feedMark, feedContent: object.feedContent, privacy: object.privacy, feedFrom: 3, topics: object.topics, location: object.taggedLocation, isHotFeed: object.isHotFeed, soundId: object.soundId, videoType: object.videoType ?? .normalVideo, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (myFeedId, myErrMsg) in
                                        DispatchQueue.main.async {
                                            if myFeedId == nil {
                                                self?.status = .rejectPostFail
                                            } else {
                                                self?.status = .finishingUp
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                    self?.status = .complete
                                                }
                                            }
                                        }
                                    }
                                }else{
                                    TGFeedNetworkManager.shared.postShortVideo(shortVideoID: videoFileID, coverImageID: imageFildID, feedMark: object.feedMark, feedContent: object.feedContent, privacy: object.privacy, feedFrom: 3, topics: object.topics, location: object.taggedLocation, isHotFeed: object.isHotFeed, soundId: object.soundId, videoType: object.videoType ?? .normalVideo, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (myFeedId, myErrMsg) in
                                        //if myFeedId != nil {
                                        self?.status = .complete
                                        if FileManager.default.fileExists(atPath: url.path) {
                                            do {
                                                try FileManager.default.removeItem(at: url)
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                        }
                                        // } else {
                                        //     self?.status = .fail
                                        // }
                                    }
                                }
                                
                            } else {
                                self.status = .fail
                            }
                        }
                    }
                }
            }.resume()
            
            
        }
        
    }
}


struct TGPostModel {
    let feedMark: Int
    let isHotFeed: Bool
    let feedContent: String
    let privacy: String
    let repostModel: TGRepostModel?
    let shareModel: SharedViewModel?
    let topics: [TGTopicCommonModel]?
    let taggedLocation: TGLocationModel?
    
    // photo
    let phAssets: [PHAsset]?
    let postPhoto: [PostPhotoExtension]?

    // video
    let video: ShortVideoAsset?
    let soundId: String?
    let videoType: VideoType?
    let postVideo: [PostVideoExtension]?
    
    var repostType: String? {
        return repostModel == nil ? nil : "feeds"
    }
    
    var hasCover: Bool {
        if let assets = phAssets, assets.count > 0 {
            return true
        }else if let imgs = images, imgs.count > 0 {
            return true
        }
        else if video?.coverImage != nil {
            return true
        }
        return false
    }
    //是否提交被驳回的动态
    let isEditFeed: Bool
    //动态id
    let feedId: String?
    //图片资源
    let images: [Any]?
    //是否需要重新上传视频资源
    let rejectNeedsUploadVideo: Bool?
    //视频封面Id
    let videoCoverId: Int?
    //视频Id
    let videoDataId: Int?
    //记录发布动态时标记的用户IDs
    let tagUsers: [UserInfoModel]?
    //记录发布动态时标记的商家IDs
    let tagMerchants: [UserInfoModel]?
    //记录发布动态时标记的代金券ID
    let tagVoucher: TagVoucherModel?
}

class TGPostTaskManager {
    
    static let shared = TGPostTaskManager()
    
    init() {}
    
    func addTask(_ task: TGPostModel, type: TGPostReleaseType = .normalType) {
  
        let postView = TGPostProgressBar()
        postView.type = type
        postView.add(post: task)
       

    }
    
    
}
    
