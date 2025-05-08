//
//  TGPostProgressBar.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/13.
//

import UIKit
import MobileCoreServices
import Photos

public struct TGShortVideoAsset {
    public let coverImage: UIImage?
    public let asset: PHAsset?
//    let recorderSession: SCRecordSession?
    public let videoFileURL: URL?
    public init(coverImage: UIImage? = nil, asset: PHAsset? = nil, videoFileURL: URL? = nil) {
        self.coverImage = coverImage
        self.asset = asset
        self.videoFileURL = videoFileURL
    }
}
public struct TGPostVideoExtension {
    var data: Data?
}
public enum TGVideoType: Int {
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
public enum TGPostReleaseType: Int{
    case campaign = 0 //活动
    case normalType  //其他
}
public enum TGPostProgressStatus {
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
public class TGPostProgressBar: UIView {

    public lazy var progressBar: UIProgressView = {
        let progress = UIProgressView()
        progress.trackTintColor = TGAppTheme.red.withAlphaComponent(0.35)
        progress.progressTintColor = TGAppTheme.red
        return progress
    }()
    
    public lazy var thumbnailView: UIImageView = {
        let imageView = UIImageView()
        imageView.roundCorner(4)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    public lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.numberOfLines = 2
        textLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textLabel.textColor = .darkGray
        return textLabel
    }()
    
    public lazy var stackview: UIStackView = {
        let stackview = UIStackView()
        stackview.alignment = .center
        stackview.axis = .horizontal
        stackview.distribution = .fillProportionally
        stackview.spacing = 10
        return stackview
    }()
    
    public lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    public lazy var retryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "ic_reload_post_task"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    public lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "ic_cancel_post_task"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    public lazy var doneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.applyBorder(color: UIColor(hex: "#E5E6EB", alpha: 1), width: 1)
        button.setTitle("done".localized, for: .normal)
        button.setTitleColor(UIColor(hex: "#333333", alpha: 1), for: .normal)
        button.isHidden = true
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return button
    }()
    
    public lazy var viewButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("view post".localized, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.isHidden = true
        button.backgroundColor = UIColor(hex: "#ED1A3B", alpha: 1)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        return button
    }()
    
    var doneCallBack: (()->Void)?
    
    public var status: TGPostProgressStatus = .posting {
        didSet {
            self.textLabel.text = status.text
            switch status {
            case .posting:
                progressBar.trackTintColor = TGAppTheme.red.withAlphaComponent(0.35)
                progressBar.progressTintColor = TGAppTheme.red
                progressBar.setProgress(0, animated: false)
                if type == .campaign {
                    self.textLabel.text = "rw_campaign_hash_post".localized
                }
                setbuttonLayer(isPosting:true)
            case .finishingUp:
                if type == .campaign {
                    self.textLabel.text = "rw_campaign_hash_post".localized
                }
                self.progressBar.setProgress(1, animated: true)
            case .complete:
                if type == .campaign {
                    progressBar.isHidden = true
                    self.textLabel.text = "rw_campaign_hash_post_completed".localized
                    ///成功发送事件通知小程序刷新
                    let dict = ["eventName": "cpFeedPubSuccess", "feedId": ""]
                    RLSDKManager.shared.feedDelegate?.sendEventToMiniProgram(detail: dict, miniProgramType: "campaign")
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.removeFromSuperview()
                        self.onRemoveTask?()
                    }
                }
            case .fail:
                progressBar.progressTintColor = .red
                progressBar.trackTintColor = .red.withAlphaComponent(0.35)
                progressBar.setProgress(1, animated: true)
                
            case .rejectPostFail:
                progressBar.progressTintColor = TGAppTheme.red
                progressBar.trackTintColor = TGAppTheme.red.withAlphaComponent(0.35)
                progressBar.setProgress(1, animated: true)
            }
            
            if status == .finishingUp {
                loadingIndicator.startAnimating()
            } else {
                loadingIndicator.stopAnimating()
            }
            
            switch status {
            case .fail:
                if type == .campaign {
                    doneButton.isHidden = false
                    viewButton.isHidden = false
                    doneButton.setTitle("cancel".localized, for: .normal)
                    viewButton.setTitle("retry".localized, for: .normal)
                    setbuttonLayer()
                } else {
                    retryButton.isHidden = false
                    cancelButton.isHidden = false
                }
            case .rejectPostFail:
                if type == .campaign {
                    doneButton.isHidden = false
                    viewButton.isHidden = false
                    doneButton.setTitle("cancel".localized, for: .normal)
                    viewButton.setTitle("meeting_retry".localized, for: .normal)
                    setbuttonLayer()
                } else {
                    retryButton.isHidden = true
                    cancelButton.isHidden = false
                }
            case .complete:
                if type == .campaign {
                    doneButton.isHidden = false
                    viewButton.isHidden = false
                    doneButton.setTitle("done".localized, for: .normal)
                    viewButton.setTitle("rw_campaign_view_post".localized, for: .normal)
                    setbuttonLayer()
                }
            default:
                retryButton.isHidden = true
                cancelButton.isHidden = true
                doneButton.isHidden = true
                viewButton.isHidden = true
            }
        }
    }
    
    public var thumbnail: UIImage?
    public var onRemoveTask: TGEmptyClosure?
    public var isComplete: Bool {
        return status == .complete
    }
    public var isRejectFail: Bool {
        return status == .rejectPostFail
    }
    public var convertedVideoURL: String = ""
    
    var singleImg: Float = 0
    var arrProgress = [Progress]()
    
    public var type: TGPostReleaseType = .normalType
    
    public func add(post: TGPostModel) {
        self.backgroundColor = .white
        self.addSubview(stackview)
        self.addSubview(progressBar)
        
        if type == .campaign {
            self.addSubview(doneButton)
            self.addSubview(viewButton)
            textLabel.numberOfLines = 3
            stackview.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(14)
                $0.top.bottom.equalToSuperview().inset(18)
                $0.height.equalTo(65)
            }
            if post.hasCover {
                stackview.addArrangedSubview(thumbnailView)
                thumbnailView.snp.makeConstraints {
                    $0.width.height.equalTo(65)
                }
                self.addSubview(loadingIndicator)
                loadingIndicator.snp.makeConstraints {
                    $0.center.width.height.equalTo(thumbnailView)
                }
            } else {
                stackview.addArrangedSubview(loadingIndicator)
                loadingIndicator.snp.makeConstraints {
                    $0.width.height.equalTo(65)
                }
            }
            stackview.addArrangedSubview(textLabel)

            textLabel.text = status.text
            if type == .campaign {
                textLabel.text = "rw_campaign_hash_post".localized
            }
            textLabel.textColor = UIColor(hex: "#242424", alpha: 1)
            progressBar.snp.makeConstraints {
                $0.leading.equalTo(94)
                $0.right.equalTo(-15)
                $0.height.equalTo(3)
                $0.top.equalTo(textLabel.snp.bottom).offset(10)
            }
            
            
            viewButton.addAction { [weak self] in
                guard let self = self else { return }
                
                if self.status == .complete {
                    self.removeFromSuperview()
                    RLSDKManager.shared.imDelegate?.didPressUerProfile(uid: Int(RLSDKManager.shared.loginParma?.uid ?? 0))
                    self.onRemoveTask?()
                    self.doneCallBack?()
                } else if self.status == .fail {
                    self.status = .posting
                    self.releaseStart(object: post)
                    self.layoutIfNeeded()
                }
                
            }
            doneButton.addAction {[weak self] in
                
                self?.removeFromSuperview()
                self?.onRemoveTask?()
                self?.doneCallBack?()
                
            }
            
            retryButton.addAction { [weak self] in
                guard let self = self else { return }
                self.status = .posting
                self.releaseStart(object: post)
                self.layoutIfNeeded()
            }
            cancelButton.addAction { [weak self] in
                guard let self = self else {
                    return
                }
                self.removeFromSuperview()
                if let videoURL = URL(string: self.convertedVideoURL), FileManager.default.fileExists(atPath: videoURL.path) {
                    do {
                        try FileManager.default.removeItem(atPath: videoURL.path)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                self.onRemoveTask?()
            }
            
        } else {
            stackview.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(14)
                $0.top.bottom.equalToSuperview()
            }
            progressBar.snp.makeConstraints {
                $0.leading.bottom.trailing.equalToSuperview()
                $0.height.equalTo(2)
            }
            if post.hasCover {
                stackview.addArrangedSubview(thumbnailView)
                thumbnailView.snp.makeConstraints {
                    $0.width.height.equalTo(37)
                }
                self.addSubview(loadingIndicator)
                loadingIndicator.snp.makeConstraints {
                    $0.center.width.height.equalTo(thumbnailView)
                }
            } else {
                stackview.addArrangedSubview(loadingIndicator)
                loadingIndicator.snp.makeConstraints {
                    $0.width.height.equalTo(37)
                }
            }
            stackview.addArrangedSubview(textLabel)
            stackview.addArrangedSubview(retryButton)
            stackview.addArrangedSubview(cancelButton)
            
            retryButton.snp.makeConstraints {
                $0.width.height.equalTo(25)
            }
            cancelButton.snp.makeConstraints {
                $0.width.height.equalTo(25)
            }
            
            textLabel.text = status.text
            retryButton.addAction { [weak self] in
                guard let self = self else { return }
                self.status = .posting
                self.releaseStart(object: post)
                self.layoutIfNeeded()
            }
            cancelButton.addAction { [weak self] in
                guard let self = self else {
                    return
                }
                self.removeFromSuperview()
                if let videoURL = URL(string: self.convertedVideoURL), FileManager.default.fileExists(atPath: videoURL.path) {
                    do {
                        try FileManager.default.removeItem(atPath: videoURL.path)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                self.onRemoveTask?()
            }
        }
        
        releaseStart(object: post)
    }
    
    func setbuttonLayer(isPosting: Bool = false){
        let height: CGFloat = isPosting ? 101 : 101 + 60
        self.snp.remakeConstraints {
            $0.height.equalTo(height)
        }
        
        if !isPosting {
            stackview.snp.remakeConstraints {
                $0.leading.trailing.equalToSuperview().inset(14)
                $0.top.equalToSuperview().inset(18)
                $0.height.equalTo(65)
            }
            
            doneButton.snp.remakeConstraints {
                $0.bottom.equalTo(-18)
                $0.top.equalTo(stackview.snp.bottom).offset(24)
                $0.left.equalTo(14)
                $0.width.equalTo((ScreenWidth - 60 - 20 - 28) / 2)
                $0.height.equalTo(42)
            }
            viewButton.snp.remakeConstraints {
                $0.bottom.equalTo(-18)
                $0.top.equalTo(stackview.snp.bottom).offset(24)
                $0.right.equalTo(-14)
                $0.width.equalTo((ScreenWidth - 60 - 20 - 28) / 2)
                $0.height.equalTo(42)
            }
        } else {
            stackview.snp.remakeConstraints {
                $0.leading.trailing.equalToSuperview().inset(14)
                $0.top.bottom.equalToSuperview().inset(18)
                $0.height.equalTo(65)
            }
        }

        self.layoutIfNeeded()
    }
    private func setThumbnail(_ image: UIImage?) {
        guard thumbnail == nil else {
            return
        }
        thumbnail = image
        thumbnailView.image = image
    }
    private func setThumbnail(_ imageUrl: String?) {
        guard let imageUrl = imageUrl else {
            return
        }
        thumbnailView.sd_setImage(with: URL(string: imageUrl))
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
                    self.setThumbnail(image)
                    
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
                        self.setThumbnail(imageItem)
                        thumbnailSet = true // 设置为true，表示已经设置了缩略图
                    }
                    imageMimeType.append("image/jpeg")
                    let compressedData = imageItem.jpegData(compressionQuality: 1.0) ?? Data()
                    uploadDatas.append(compressedData)
                }
                if let imageModel = image as? TGRejectDetailModelImages {
                    // 只在第一个元素上设置缩略图
                    if index == 0 && !thumbnailSet {
                        self.setThumbnail(imageModel.imagePath)
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
                if progress.fractionCompleted == 1 {
                    self.arrProgress.append(progress)
                }
                DispatchQueue.main.async {
                    if uploadDatas.count > 1 {
                        
                        var currentProg: Float = 0.1
                        let max: Float = 0.8
                        
                        self.singleImg = max / Float(uploadDatas.count)
                        currentProg += self.singleImg * Float(self.arrProgress.count)
                        self.progressBar.setProgress(currentProg, animated: true)
                    } else {
                        self.progressBar.setProgress(Float(progress.fractionCompleted) * 0.5, animated: true)
                    }
                }
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
                
                self?.setThumbnail(image)
                
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
        if let images = object.images, images.count == 1, let image = images.first as? UIImage {
            self.setThumbnail(image)
            imageMimeType.append("image/jpeg")
            let compressedData = image.jpegData(compressionQuality: 1.0) ?? Data()
            uploadDatas.append(compressedData)
        }
      
        TGUploadNetworkManager().uploadFileToOBS(fileDatas: uploadDatas) {[weak self] progress in
            guard let self = self else { return }
            if progress.fractionCompleted == 1 {
                self.arrProgress.append(progress)
            }
            DispatchQueue.main.async {
                if uploadDatas.count > 1 {
                    
                    var currentProg: Float = 0.1
                    let max: Float = 0.8
                    
                    self.singleImg = max / Float(uploadDatas.count)
                    currentProg += self.singleImg * Float(self.arrProgress.count)
                    self.progressBar.setProgress(currentProg, animated: true)
                } else {
                    self.progressBar.setProgress(Float(progress.fractionCompleted) * 0.5, animated: true)
                }
            }
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
            self.setThumbnail(image)
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
            if progress.fractionCompleted == 1 {
                self.arrProgress.append(progress)
            }
            DispatchQueue.main.async {
                if uploadDatas.count > 1 {
                    
                    var currentProg: Float = 0.1
                    let max: Float = 0.8
                    
                    self.singleImg = max / Float(uploadDatas.count)
                    currentProg += self.singleImg * Float(self.arrProgress.count)
                    self.progressBar.setProgress(currentProg, animated: true)
                } else {
                    self.progressBar.setProgress(Float(progress.fractionCompleted) * 0.5, animated: true)
                }
            }
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
        self.setThumbnail(object.video?.coverImage)
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
        self.setThumbnail(object.video?.coverImage)
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
                DispatchQueue.main.async {
                    self?.progressBar.setProgress(Float(progress.fractionCompleted) * 0.5 + 0.5, animated: true)
                }
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
        self.setThumbnail(object.video?.coverImage)
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


public struct TGPostModel {
    public let feedMark: Int
    public let isHotFeed: Bool
    public let feedContent: String
    public let privacy: String
    let repostModel: TGRepostModel?
    let shareModel: SharedViewModel?
    let topics: [TGTopicCommonModel]?
    let taggedLocation: TGLocationModel?
    
    // photo
    public let phAssets: [PHAsset]?
    let postPhoto: [TGPostPhotoExtension]?

    // video
    public let video: TGShortVideoAsset?
    public let soundId: String?
    let videoType: TGVideoType?
    let postVideo: [TGPostVideoExtension]?
    
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
    public let isEditFeed: Bool
    //动态id
    public let feedId: String?
    //图片资源
    public let images: [Any]?
    //是否需要重新上传视频资源
    public let rejectNeedsUploadVideo: Bool?
    //视频封面Id
    public let videoCoverId: Int?
    //视频Id
    public let videoDataId: Int?
    //记录发布动态时标记的用户IDs
    let tagUsers: [TGUserInfoModel]?
    //记录发布动态时标记的商家IDs
    let tagMerchants: [TGUserInfoModel]?
    //记录发布动态时标记的代金券ID
    let tagVoucher: TagVoucherModel?
}

public class TGPostTaskManager {
    
    public let taskProgressView = UIStackView().configure {
        $0.axis = .vertical
        $0.spacing = 0
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }

    
    public static let UpdateViewNotification = Notification.Name("UpdateViewNotification")
    
    public static let PopViewNotification = Notification.Name("PopViewNotification")

    public static let shared = TGPostTaskManager()
    
    public var onUpdateView: TGEmptyClosure?
    
    public var updateColor: Bool? = false
    public var progressIsHidden: Bool = true
    public var arrProgressView = [TGPostProgressBar]()
    
    public var doneCallBack: (()->Void)?
    
    init() {}
    public func addTask(_ task: TGPostModel, type: TGPostReleaseType = .normalType) {
        self.progressIsHidden = false
        let postView = TGPostProgressBar()
        postView.type = type
        postView.add(post: task)
        arrProgressView.append(postView)
        self.taskProgressView.addArrangedSubview(postView)
        if type == .campaign {
            postView.snp.makeConstraints {
                $0.height.equalTo(101)
            }
        } else {
            postView.snp.makeConstraints {
                $0.height.equalTo(46)
            }
        }
        postView.onRemoveTask = {
            self.taskProgressView.layoutIfNeeded()
            self.progressIsHidden = self.arrProgressView.count == 0
            self.onUpdateView?()
            NotificationCenter.default.post(name: TGPostTaskManager.UpdateViewNotification, object: nil)
            self.doneCallBack?()
        }
        postView.addAction {
            if postView.isComplete {
//                NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": RLSDKManager.shared.loginParma?.uid ?? 0])
                RLSDKManager.shared.imDelegate?.didPressUerProfile(uid: Int(RLSDKManager.shared.loginParma?.uid ?? 0))
            }
            if postView.isRejectFail {
                DispatchQueue.main.async {
                    postView.removeFromSuperview()
                }
                NotificationCenter.default.post(name: NSNotification.Name.CommentChange.editModel, object: nil, userInfo: ["post_model": task])
                
            }
        }
        if self.updateColor! {
            updateColor = false
            postView.textLabel.textColor = .white
            postView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.15)
        }
        self.taskProgressView.layoutIfNeeded()
        self.onUpdateView?()
        NotificationCenter.default.post(name: TGPostTaskManager.UpdateViewNotification, object: nil)
    }
    public func updateTextColor() {
        for view in arrProgressView {
            if updateColor! {
                view.textLabel.textColor = .white
                view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.15)
            } else {
                view.textLabel.textColor = .darkGray
                view.backgroundColor = .white
            }
            self.taskProgressView.layoutIfNeeded()
        }
    }
    
    public func isAbleToPost() -> Bool {
        return self.taskProgressView.arrangedSubviews.count < 3
    }
    
    public func clear() {
        for subview in taskProgressView.arrangedSubviews {
               taskProgressView.removeArrangedSubview(subview)
               subview.removeFromSuperview()
           }
    }
}
    
