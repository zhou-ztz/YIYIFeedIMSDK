//
//  TGFeedDetailImageController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/20.
//

import UIKit
import SnapKit
import SDWebImage
//import SDWebImageFLPlugin

enum FeedDetailImageControllerState {
    case normal
    case zoomable
}

public class TGFeedDetailImageController: TGViewController, UIGestureRecognizerDelegate {
    private let zoomView: TGImageScrollView = TGImageScrollView(frame: .zero)

    private(set) lazy var imageView = {
       return zoomView.imageView
    }()

    var state: FeedDetailImageControllerState = .normal
    private(set) var imageUrlPath: String = ""
    private(set) var imageIndex: Int = 0
    private(set) var model: FeedListCellModel?
    private let doubleTapGesture = UITapGestureRecognizer()
    private let singleTap = UITapGestureRecognizer()
    var onSingleTapView: TGEmptyClosure?
    var onDoubleTapView: TGEmptyClosure?
    var onZoomUpdate: TGEmptyClosure?

    init(imageUrlPath: String = "", imageIndex: Int, model: FeedListCellModel, placeholderImage: UIImage? = nil, transitionId: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.imageUrlPath = imageUrlPath
        self.imageIndex = imageIndex
        self.model = model
//        self.hero.isEnabled = true
//        if let transitionId = transitionId {
//            self.imageView.hero.id = transitionId
//        }

        let imageUrl = SDWebImageManager.shared.cacheKey(for: URL(string: imageUrlPath))
        if let imageData = SDImageCache.shared.diskImageData(forKey: imageUrl) {
            // Load image from cache
            let image = UIImage.sd_image(with: imageData)
            self.imageView.image = image
        } else {
            // Load image from URL
            self.imageView.sd_setImage(with: URL(string: imageUrlPath), placeholderImage:nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        reloadGifUrlPath()
        
        self.isHiddenNavigaBar = true
        
        self.backBaseView.backgroundColor = .black
        self.backBaseView.addSubview(zoomView)

//        self.hero.modalAnimationType = .selectBy(presenting: .fade, dismissing: .fade)

        doubleTapGesture.delegate = self
        singleTap.delegate = self

        doubleTapGesture.numberOfTapsRequired = 2
        self.backBaseView.addGestureRecognizer(doubleTapGesture)
        doubleTapGesture.addActionBlock { [weak self]_ in
            guard let self = self else { return }
            if case self.state = FeedDetailImageControllerState.zoomable {
                self.zoomView.toggleZoom()
            } else {
                self.onDoubleTapView?()
            }
        }

        self.backBaseView.addGestureRecognizer(singleTap)
        singleTap.addActionBlock { [weak self] _ in
            self?.zoomView.resetZoom()
            self?.onSingleTapView?()
        }

        zoomView.onZoomUpdate = onZoomUpdate
        self.backBaseView.layoutIfNeeded()
        
    }
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //开始记录停留时间
//        stayBeginTimestamp = Date().timeStamp
        
    }
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        self.behaviorUserFeedStayData()
    }
    func reloadGifUrlPath() {
//        guard let url = try? self.imageUrlPath.asURL() else { return }
//        let session = URLSession(configuration: .default)
//        let task = session.dataTask(with: url) { (data, response, error) in
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//
//            if let response = response as? HTTPURLResponse {
//                if let redirectUrl = response.url {
//                    print("Redirected URL: \(redirectUrl)")
//                    self.imageView.sd_setImage(with: redirectUrl, placeholderImage: nil, options: .highPriority)
//                }
//            }
//        }
//
//        task.resume()
        guard let url = URL(string: self.imageUrlPath) else { return }
        let imageUrl = SDWebImageManager.shared.cacheKey(for: url)
        
        if let imageData = SDImageCache.shared.diskImageData(forKey: imageUrl) {
            // Load image from cache
            let image = UIImage.sd_image(with: imageData)
            self.imageView.image = image
        } else {
            // Load image from URL
            self.imageView.sd_setImage(with: url, placeholderImage:nil)
        }
        
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/coordinating_multiple_gesture_recognizers/preferring_one_gesture_over_another
        if gestureRecognizer == self.singleTap && otherGestureRecognizer == self.doubleTapGesture {
            return true
        }
        return false
    }
}


extension TGFeedDetailImageController {
    func behaviorUserFeedStayData() {
        if stayBeginTimestamp != "" {
            stayEndTimestamp = Date().timeStamp
            let stay = stayEndTimestamp.toInt()  - stayBeginTimestamp.toInt()
            if stay > 5 {
                self.stayBeginTimestamp = ""
                self.stayEndTimestamp = ""
                RLSDKManager.shared.feedDelegate?.onTrackEvent(itemId: self.model?.idindex.stringValue ?? "", itemType: TGItemType.shortvideo.rawValue, behaviorType: TGBehaviorType.stay.rawValue, moduleId: TGModuleId.feed.rawValue, pageId: TGPageId.feed.rawValue, behaviorValue: stay.stringValue, traceInfo: nil)
            }
        }
    }
}
