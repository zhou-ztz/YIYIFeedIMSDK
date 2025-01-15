//
//  ImageMessageCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/5.
//

import UIKit
import SDWebImage
import NIMSDK
import AVFoundation

enum DownloadState: Int {
  case Success = 1
  case Downalod
}
class ImageMessageCell: BaseMessageCell {
    
    var state = DownloadState.Success
    var progress: UInt = 0
    
    lazy var displayImage: SDAnimatedImageView = {
        let view = SDAnimatedImageView()
        view.backgroundColor = UIColor(hex: 0xF5F5F5)
        view.contentMode = .scaleToFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 6
        return view
    }()
    lazy var playImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.set_image(named: "ico_video_play_list")
        view.isHidden = true
        return view
    }()
    
    lazy var overlayImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.set_image(named: "bubblecell_overlay")
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.setupUI()
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI(){
        self.bubbleImage.addSubview(displayImage)
        self.bubbleImage.addSubview(playImage)
        self.bubbleImage.addSubview(overlayImage)
        self.bubbleImage.addSubview(timeTickStackView)
        displayImage.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview().inset(8)
        }
        playImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }
        overlayImage.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(60)
            make.bottom.equalTo(displayImage.snp.bottom)
        }
        timeTickStackView.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview().inset(10)
        }
      
    }
    
    override func setData(model: TGMessageData) {
        super.setData(model: model)
        guard let message = model.nimMessageModel else { return }
        var finalImageSize: CGSize = .zero
        if message.messageType == .MESSAGE_TYPE_IMAGE, let imageObject = message.attachment as? V2NIMMessageImageAttachment {
            playImage.isHidden = true
            finalImageSize = MessageUtils.imageSize(imageObject)
            self.loadWebImage(imageView: displayImage, loadingView: nil, url: imageObject.url.orEmpty, placeholderImage: imageObject.path, isVideo: false)
        } else if let videoObject = message.attachment as? V2NIMMessageVideoAttachment{
            playImage.isHidden = false
            finalImageSize = MessageUtils.videoSize(videoObject)
            let v2size: V2NIMSize = V2NIMSize(width: Int(finalImageSize.width), height: Int(finalImageSize.height))
            NIMSDK.shared().v2StorageService.getVideoCoverUrl(videoObject, thumbSize: v2size) {[weak self] result in
                DispatchQueue.main.async {
                    self?.displayImage.sd_setImage(with: URL(string: result.url), placeholderImage: UIImage.set_image(named: "IMG_icon"))
                }
            } failure: {[weak self] _ in
                DispatchQueue.main.async {
                    self?.displayImage.image = UIImage.set_image(named: "IMG_icon")
                }
            }

        }
        displayImage.snp.remakeConstraints { make in
            make.left.bottom.right.top.equalToSuperview().inset(8)
            make.width.equalTo(finalImageSize.width)
            make.height.equalTo(finalImageSize.height)
        }
    }
    
    
    
    private func loadWebImage(imageView: UIImageView, loadingView: UIView?, url: String, placeholderImage: String?, isVideo: Bool) {
        if isVideo  {
            self.playImage.isHidden = false
        } else {
            imageView.sd_setImage(with: URL(string: url), placeholderImage: placeholderImage == nil ? UIImage.set_image(named: "IMG_icon") : UIImage(contentsOfFile: placeholderImage!))
        }
        
        
    }
    
    func getFirstFrame(from videoURL: URL, completion: @escaping (UIImage?) -> Void) {
        // 创建 AVAsset 实例
        let asset = AVAsset(url: videoURL)
        
        // 创建 AVAssetImageGenerator 实例
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        // 设置图像生成器的时间戳为视频的起始时间（第一帧）
        let time = CMTimeMake(value: 0, timescale: 1) // 第一帧的时间
        imageGenerator.appliesPreferredTrackTransform = true // 自动处理视频方向
        
        // 使用生成器获取第一帧
        imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { (requestedTime, image, actualTime, result, error) in
            if let error = error {
                print("Error generating image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let image = image {
                // 将生成的 CGImage 转换为 UIImage
                let uiImage = UIImage(cgImage: image)
                completion(uiImage)
            } else {
                completion(nil)
            }
        }
    }
    
    /// 设置（视频、文件）消息模型（上传、下载）进度
    /// - Parameters:
    ///   - progress:（上传、下载）进度
    public func setModelProgress(_ progress: UInt) {
      if progress == 100 {
        state = .Success
      } else {
        state = .Downalod
      }

      //cell?.uploadProgress(progress)
    }

}

extension UIImage {
    
    class func nim_sizeWithImage(originSize: CGSize, minSize: CGSize, maxSize: CGSize) -> CGSize {
        var size = CGSize()
        let imageWidth = originSize.width, imageHeight = originSize.height
        let imageMinWidth = minSize.width, imageMinHeight = minSize.height
        let imageMaxWidth = maxSize.width, imageMaxHeight = maxSize.height
        
        if imageWidth > imageHeight { // 宽图
            size.height = imageMinHeight // 高度取最小高度
            size.width = imageWidth * imageMinHeight / imageHeight
            if size.width > imageMaxWidth {
                size.width = imageMaxWidth
            }
        } else if imageWidth < imageHeight { // 高图
            size.width = imageMinWidth
            size.height = imageHeight * imageMinWidth / imageWidth
            if size.height > imageMaxHeight {
                size.height = imageMaxHeight
            }
        } else { // 方图
            if imageWidth > imageMaxWidth {
                size.width = imageMaxWidth
                size.height = imageMaxHeight
            } else if imageWidth > imageMinWidth {
                size.width = imageWidth
                size.height = imageHeight
            } else {
                size.width = imageMinWidth
                size.height = imageMinHeight
            }
        }
        
        return size
    }

}
