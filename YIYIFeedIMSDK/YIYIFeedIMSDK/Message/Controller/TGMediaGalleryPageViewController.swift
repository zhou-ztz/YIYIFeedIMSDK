//
//  TGMediaGalleryPageViewController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/17.
//

import UIKit
import NIMSDK

class TGMediaGalleryPageViewController: TGViewController {

    var scollToFocus: Bool = false
    var calendar: Calendar? = nil
    var titles: [AnyHashable]?
    var contents: [String : Any]?
    
    var objects: [MediaPreviewObject]?
    var pageViewController: UIPageViewController?
    var focusObject: MediaPreviewObject?
    var conversationId: String
    var showMore = false
    
    init(objects: [MediaPreviewObject], focusObject: MediaPreviewObject, conversationId: String , showMore: Bool) {
        self.conversationId = conversationId
        self.objects = objects
        self.focusObject = focusObject
        self.showMore = showMore
        calendar = Calendar.current
        contents = [String : Any]()
        titles = [String]()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.backItem.setTitle("pic_video".localized, for: .normal)
        if showMore {
            self.setupRightNavItem()
        }
        
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController!.delegate = self
        self.pageViewController!.dataSource = self
                
        if let focusObject = focusObject, let objects = self.objects {
            let index = self.indexOf(object: focusObject)
            
            let object = objects[index]
            let initialViewController = self.viewControllerWithPageIndex(pageIndex: index, onPlayVideo: focusObject.objectId == object.objectId)
            initialViewController!.view.tag = index
            let viewControllers: [UIViewController] = [initialViewController!]

            self.pageViewController?.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)

            self.addChild(self.pageViewController!)
            self.backBaseView.addSubview(self.pageViewController!.view)
            self.pageViewController?.view.frame = self.backBaseView.bounds
            self.pageViewController?.didMove(toParent: self)
            self.edgesForExtendedLayout = .all
        
        }
    }
    
    func indexOf(object: MediaPreviewObject) -> Int {
        var row = 0
        if let objects = objects {
            row = objects.firstIndex(of: object) ?? 0
        }
        return row
    }
    
    func setupRightNavItem() {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(onMore), for: .touchUpInside)
        
        button.setImage(UIImage.set_image(named: "icon_gallery_more_normal"), for: .normal)
        button.setImage(UIImage.set_image(named: "icon_gallery_more_pressed"), for: .highlighted)
        button.sizeToFit()
        self.customNavigationBar.setRightViews(views: [button])
        
    }
    
    @objc func onMore() {
        let viewController = TGChatMediaViewController.init(conversationId: self.conversationId)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: Custom methods
    func viewControllerWithPageIndex(pageIndex: Int, onPlayVideo: Bool) -> UIViewController? {
        if pageIndex < 0 || pageIndex >= self.objects!.count {
            return nil
        }
        
        let object = self.objects![pageIndex]
        
        if object.type == MediaPreviewType.video {
            let item = VideoViewItem(videoObject: object)
            let viewController = TGChatMediaVideoPlayerViewController(url: item.url)
            viewController.view.tag = pageIndex
            return viewController
        } else {
            let item = GalleryItem()
            item.thumbPath = object.thumbPath!
            item.imageURL = object.url ?? ""
            item.name = object.displayName ?? ""
            item.itemId = object.objectId!
            item.size = object.imageSize
            
            let viewController = TGGalleryViewController(item: item, sessionId: nil)
            viewController.ext = NSString(string: object.thumbPath!).pathExtension as String
            viewController.view.tag = pageIndex
            return viewController
        }
    }
}

extension TGMediaGalleryPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = viewController.view.tag
        return self.viewControllerWithPageIndex(pageIndex: index + 1, onPlayVideo: false)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = viewController.view.tag
        return self.viewControllerWithPageIndex(pageIndex: index-1, onPlayVideo: false)
    }
}

class VideoViewItem: NSObject {
    let itemId: String = ""
    
    let path: String
    let url: String
    let coverUrl: String
    let session: NIMSession? = nil
    
    init(videoObject: NIMVideoObject) {
        self.path = videoObject.path!
        self.url = videoObject.url!
        self.coverUrl = videoObject.coverUrl!
    }
    
    init(videoObject: MediaPreviewObject) {
        self.path = videoObject.path!
        self.url = videoObject.url!
        self.coverUrl = videoObject.thumbUrl!
    }
}
