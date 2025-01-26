//
//  TGChatMediaViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/8.
//

import UIKit
import NIMSDK

class TGChatMediaViewController: TGViewController {
    
    /// 头部可滑动的标签选择视图
    var tagScrollView: ChatMediaTagScrollView? = nil
    /// 主视图
    var rootScrollView: UIScrollView? = nil
    
    var photoVideoObjects: [MediaPreviewObject] = []
    var filesMessages: [V2NIMMessage] = []
    
    let conversationId: String
    
    init(conversationId: String) {
        self.conversationId = conversationId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.backItem.setTitle("photo_video_files".localized, for: .normal)

        /// 顶部可滑动的标签栏
        self.tagScrollView = ChatMediaTagScrollView(frame: CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: 44))
        self.tagScrollView?.delegate = self
        self.backBaseView.addSubview(self.tagScrollView!)
        
        /// 左右滑动的列表根视图
        let navigationBarHeight = (self.navigationController?.navigationBar.frame.height)! + 20
        self.rootScrollView = UIScrollView(frame: CGRect(x: 0, y: (self.tagScrollView?.frame.maxY)!, width: ScreenSize.ScreenWidth, height: ScreenSize.ScreenHeight - navigationBarHeight - (self.tagScrollView?.frame.maxY)!))
        self.rootScrollView?.backgroundColor = RLColor.inconspicuous.background
        self.rootScrollView?.delegate = self
        self.rootScrollView?.isPagingEnabled = true
        self.rootScrollView?.showsHorizontalScrollIndicator = false
        self.backBaseView.addSubview(self.rootScrollView!)
        
        let grayLine = UIView(frame: CGRect(x: 0, y: (self.tagScrollView?.frame.maxY)! - 1, width: ScreenSize.ScreenWidth, height: 1))
        grayLine.backgroundColor = RLColor.inconspicuous.disabled
        self.backBaseView.addSubview(grayLine)
        
        self.backBaseView.bringSubviewToFront(self.rootScrollView!)
        self.backBaseView.bringSubviewToFront(grayLine)
        
        self.tagScrollView?.updateTags(WithTags: ["Photos & Video","Files"])
        self.getPhotoVideoFile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func addChildVC() {
        let navigationBarHeight = (self.navigationController?.navigationBar.frame.height)! + 20
        let height = ScreenSize.ScreenHeight - navigationBarHeight - (self.tagScrollView?.frame.maxY ?? 44)
        
        let mediaVC = TGMediaPreviewViewController.init(objects: self.photoVideoObjects, focusObject:MediaPreviewObject(), conversationId: self.conversationId)
        mediaVC.view.frame = CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: rootScrollView?.frame.size.height ?? height)
        self.addChild(mediaVC)
        self.rootScrollView?.addSubview(mediaVC.view)
        
        let vc = TGFilesPreviewTableViewController.init(filesMessages: self.filesMessages)
        vc.view.frame = CGRect(x: ScreenSize.ScreenWidth, y: 0, width: ScreenSize.ScreenWidth, height: rootScrollView?.frame.size.height ?? height)
        self.addChild(vc)
        self.rootScrollView?.addSubview(vc.view)
        
        self.rootScrollView?.contentSize = CGSize(width: ScreenSize.ScreenWidth * 2, height: 0)
    }
    
    func getPhotoVideoFile() {

        let opt = V2NIMMessageListOption()
        opt.limit = 100
        opt.messageTypes = [V2NIMMessageType.MESSAGE_TYPE_IMAGE.rawValue,  V2NIMMessageType.MESSAGE_TYPE_VIDEO.rawValue, V2NIMMessageType.MESSAGE_TYPE_FILE.rawValue]
        opt.anchorMessage = nil
        opt.conversationId = conversationId
        opt.direction = .QUERY_DIRECTION_ASC
        
        NIMSDK.shared().v2MessageService.getMessageList(opt) {[weak self] messages in
            guard let self = self else { return }
            var photoVideoObjects: [MediaPreviewObject] = []
            var filesObjects: [V2NIMMessage] = []
            //显示的时候新的在前老的在后，逆序排列
            //如果需要微信的显示顺序，则直接将这段代码去掉即可
            let array: [V2NIMMessage] = NSMutableArray(array: messages).reverseObjectEnumerator().allObjects as! [V2NIMMessage]
            for message in array {
                switch message.messageType {
                case .MESSAGE_TYPE_VIDEO:
                    if let object = MessageUtils.previewImageVideoMedia(by: message) {
                        photoVideoObjects.append(object)
                    }
                    
                case .MESSAGE_TYPE_IMAGE:
                    if let object =  MessageUtils.previewImageVideoMedia(by: message) {
                        photoVideoObjects.append(object)
                    }
                    
                case .MESSAGE_TYPE_FILE:
                    filesObjects.append(message)
                    
                default:
                    break
                }
            }
            DispatchQueue.main.async {
                self.photoVideoObjects = photoVideoObjects
                self.filesMessages = filesObjects
                self.addChildVC()
            }
            
            
        } failure: { error in
            
        }
    }
    
    
}

// MARK: - ChatMediaTagScrollViewDelegate
extension TGChatMediaViewController: ChatMediaTagScrollViewDelegate {
    func selectedTag(WithTagIndex index: Int) {
        self.rootScrollView?.setContentOffset(CGPoint(x: ScreenSize.ScreenWidth * CGFloat(index), y: 0), animated: false)
    }
}

// MARK: - scrollviewDelegate
extension TGChatMediaViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tagScrollView?.setTitleButtonStyle(WithContentOffSetXPoint: scrollView.contentOffset.x)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.tagScrollView?.setButtonOffSet(scrollViewContentOffSetX: scrollView.contentOffset.x)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let VCIndex = (self.rootScrollView?.contentOffset.x)! / ScreenSize.ScreenWidth
        /**
         * 注意：在添加列表子控制器前添加了tagSettingVC这个子控制器 所以这里
         * 的懒加载数组序号应该整体右移，且当子控制器为tagSettingVC的时候不执行添加
         * 操作
         **/
        let childVC = self.children[Int(VCIndex + 1)]
        if childVC.view.superview != nil {
            return
        }
        /// tagSettingVC 的view tag值
        if childVC.view.tag == 9_999 {
            return
        }
        childVC.view.frame = (self.rootScrollView?.bounds)!
        childVC.view.tag = -1 /// 添加标记 用于重新刷新界面的时候清空以前的视图
        self.rootScrollView?.addSubview(childVC.view)
    }
}
