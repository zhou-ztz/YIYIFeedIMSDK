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
        return view
    }()
    lazy var playImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.set_image(named: "ic_feed_video_icon")
        view.isHidden = true
        return view
    }()
    
    lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .white.withAlphaComponent(0.8)
        label.text = "00:34"
        label.numberOfLines = 1
        label.backgroundColor = .black.withAlphaComponent(0.5)
        label.layer.cornerRadius = 3
        label.clipsToBounds = true
        label.isHidden = true
        label.textAlignment = .center
        return label
    }()
    
    var loadingView = IMCircularProgressView()

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
        self.bubbleImage.addSubview(durationLabel)
        displayImage.bindToEdges()
        playImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }
        durationLabel.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview().inset(4)
            make.width.equalTo(42)
            make.height.equalTo(17)
        }
//        loadingView = IMCircularProgressView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
//        loadingView.progressColor = RLColor.share.theme
//        loadingView.trackColor = UIColor(hex: 0xD9D9D9)
    //    displayImage.addSubview(loadingView)
      
    }
    
    override func setData(model: TGMessageData) {
        super.setData(model: model)
        guard let message = model.nimMessageModel else { return }
        var finalImageSize: CGSize = .zero
        if message.messageType == .MESSAGE_TYPE_IMAGE, let imageObject = message.attachment as? V2NIMMessageImageAttachment {
            playImage.isHidden = true
            durationLabel.isHidden = true
            finalImageSize = imageSize(imageObject)
            self.loadWebImage(imageView: displayImage, loadingView: loadingView, url: imageObject.url.orEmpty, placeholderImage: imageObject.path, isVideo: false)
        } else if let videoObject = message.attachment as? V2NIMMessageVideoAttachment{
            playImage.isHidden = false
            durationLabel.isHidden = false
            finalImageSize = videoSize(videoObject)
            self.loadWebImage(imageView: displayImage, loadingView: loadingView, url: videoObject.url.orEmpty, placeholderImage: videoObject.path, isVideo: true)
            durationLabel.text = Int(videoObject.duration).millisecondsToDuratioFormat()
        }
        displayImage.snp.remakeConstraints { make in
            make.left.bottom.right.top.equalToSuperview()
            make.width.equalTo(finalImageSize.width)
            make.height.equalTo(finalImageSize.height)
        }
    }
    
    private func imageSize(_ imageObject: V2NIMMessageImageAttachment) -> CGSize {
        var imageSize: CGSize = .zero
        imageSize = CGSize(width: CGFloat(imageObject.width), height: CGFloat(imageObject.height))
        
        let attachmentImageMinWidth  = (ScreenWidth / 4.0);
        let attachmentImageMinHeight = (ScreenWidth / 4.0);
        let attachmemtImageMaxWidth  = (ScreenWidth - 170);
        let attachmentImageMaxHeight = (ScreenWidth - 170);
        
        let minSize = CGSize(width: attachmentImageMinWidth, height: attachmentImageMinHeight)
        let maxSize = CGSize(width: attachmemtImageMaxWidth, height: attachmentImageMaxHeight)
        return  UIImage.nim_sizeWithImage(originSize: imageSize, minSize: minSize, maxSize: maxSize)
    }
    
    private func videoSize(_ videoObject: V2NIMMessageVideoAttachment?) -> CGSize {
        var imageSize: CGSize = .zero
        guard let messageObject = videoObject else { return .zero }
        imageSize = CGSize(width: CGFloat(messageObject.width), height: CGFloat(messageObject.height))
        imageSize = CGSize(width: CGFloat(messageObject.width), height: CGFloat(messageObject.height))
        
        let attachmentImageMinWidth  = (ScreenWidth / 4.0);
        let attachmentImageMinHeight = (ScreenWidth / 4.0);
        let attachmemtImageMaxWidth  = (ScreenWidth - 170);
        let attachmentImageMaxHeight = (ScreenWidth - 170);
        
        let minSize = CGSize(width: attachmentImageMinWidth, height: attachmentImageMinHeight)
        let maxSize = CGSize(width: attachmemtImageMaxWidth, height: attachmentImageMaxHeight)
        return  UIImage.nim_sizeWithImage(originSize: imageSize, minSize: minSize, maxSize: maxSize)
    }
    
    private func loadWebImage(imageView: UIImageView, loadingView: IMCircularProgressView?, url: String, placeholderImage: String?, isVideo: Bool) {
        if isVideo  {
            self.playImage.isHidden = false
            if let Url = URL(string: url) {
                self.getFirstFrame(from: Url) { image in
                    DispatchQueue.main.async {
                        if let image = image {
                            imageView.image = image
                        } else {
                            imageView.image = UIImage.set_image(named: "IMG_icon")
                        }
                    }
                }
            }
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



class IMCircularProgressView: UIView {

    fileprivate var progressLayer = CAShapeLayer()
    fileprivate var trackLayer = CAShapeLayer()
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircularPath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createCircularPath()
    }
    
    var progressColor = UIColor.white {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var trackColor = UIColor.white {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    fileprivate func createCircularPath() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.size.width/2
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: (frame.size.width - 1.5)/2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = 5.0
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = 5.0
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "animateprogress")
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
