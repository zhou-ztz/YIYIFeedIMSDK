//
//  CollectionImageVideoMsgViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/19.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
import SDWebImage
import Photos


class CollectionImageVideoMsgViewController: TGViewController {
    
    var favoriteModel: FavoriteMsgModel?
    var collectionMsgCall: deleteCollectionMsgCall?
    var dictModel: SessionDictModel?
    var imageAttachment: IMImageCollectionAttachment?
    var videoAttachment: IMVideoCollectionAttachment?
    var pageViewController: UIPageViewController?
    
    init(model: FavoriteMsgModel) {
        self.favoriteModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        customNavigationBar.backItem.setTitle("title_favourite_msg_details".localized, for: .normal)
        self.setupRightNavItem()
        self.imageVideoAttachment(josnStr: self.favoriteModel?.data ?? "")
        self.setUI()
    }
    

    func setupRightNavItem() {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(onMore), for: .touchUpInside)
        button.setImage(UIImage(named: "buttonsMoreDotBlack"), for: .normal)
        button.sizeToFit()
        self.customNavigationBar.setRightViews(views: [button])
    }
    
    func setUI(){
        guard let model = self.favoriteModel else {
            return
        }
        if model.type == MessageCollectionType.image {
            
            let item = GalleryItem()
            item.thumbPath = ""
            item.imageURL = imageAttachment?.url ?? ""
            item.name =  ""
            item.itemId = ""
            item.size = CGSize(width: imageAttachment?.w ?? 0, height: imageAttachment?.h ?? 0)
            let viewController = TGGalleryViewController(item: item, sessionId: nil)
            viewController.ext = imageAttachment?.ext ?? ""
            viewController.view.tag = 1
            self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

            let viewControllers: [UIViewController] = [viewController]
            
            self.pageViewController?.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
            
            self.addChild(self.pageViewController!)
            self.backBaseView.addSubview(self.pageViewController!.view)
            self.pageViewController?.view.frame = self.backBaseView.bounds
            self.pageViewController?.didMove(toParent: self)
            self.edgesForExtendedLayout = .all
            
        }else if model.type == MessageCollectionType.video {
           
            let viewController = TGChatMediaVideoPlayerViewController(url: self.videoAttachment?.url ?? "")
            viewController.view.tag = 1
            self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

            let viewControllers: [UIViewController] = [viewController]
            
            self.pageViewController?.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
            
            self.addChild(self.pageViewController!)
            self.backBaseView.addSubview(self.pageViewController!.view)
            self.pageViewController?.didMove(toParent: self)
            self.edgesForExtendedLayout = .all
        }
        
    }
    
    @objc func onMore() {

        let items: [IMActionItem] = [.save, .collect_forward, .collect_delete]

        if (items.count > 0 ) {
            let view = IMActionListView(actions: items)
            view.delegate = self
        }
    }
    
    func imageVideoAttachment(josnStr: String) {
        guard let data = josnStr.data(using: .utf8) else {
            return
        }
        do {
            let model = try JSONDecoder().decode(SessionDictModel.self, from: data)
            dictModel = model

        } catch  {
            print("jsonerror = \(error.localizedDescription)")
        }
        
        guard let dataAttach = dictModel?.attachment!.data(using: .utf8) else {
            return
        }
        do {
            if self.favoriteModel!.type == .image {
                let attach = try JSONDecoder().decode(IMImageCollectionAttachment.self, from: dataAttach)
                imageAttachment = attach
            }else{
                let attach = try JSONDecoder().decode(IMVideoCollectionAttachment.self, from: dataAttach)
                videoAttachment = attach
            }
            

        } catch  {
            print("jsonerror = \(error.localizedDescription)")
        }
        
        
    }
    
    private func saveImageToAlbum(imageFile: UIImage) {
        AuthorizeStatusUtils.checkAuthorizeStatusByType(type: .album, viewController: self, completion: {
            DispatchQueue.main.async {
                UIImageWriteToSavedPhotosAlbum(imageFile, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        })
    }
    
    //MARK: - Add image to Library
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "success_unsave".localized, message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ok".localized, style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "success_save".localized, message: "photo_saved_success".localized, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ok".localized, style: .default))
            present(ac, animated: true)
        }
    }

}

extension CollectionImageVideoMsgViewController: ActionListDelegate {

    func forwardTextIM() {
        guard let messageId = self.favoriteModel?.uniqueId else {
            return
        }
        let messageIds: [String] = [messageId]
        let configuration = TGContactsPickerConfig(title: "select_contact".localized, rightButtonTitle: "done".localized, allowMultiSelect: true, enableTeam: true, enableRecent: true, enableRobot: false, maximumSelectCount: maximumSendContactCount, excludeIds: [], members: nil, enableButtons: false, allowSearchForOtherPeople: true)
        
        let picker = TGNewContactPickerViewController(configuration: configuration, finishClosure: { (contacts) in
            
            NIMSDK.shared().v2MessageService.getMessageList(byIds: messageIds) { messages in
                let accountId = NIMSDK.shared().v2LoginService.getLoginUser() ?? ""
                for contact in contacts {
                    for originalMessage in messages {
                        let conversationId = contact.isTeam ? "\(accountId)|2|\(contact.userName)" : "\(accountId)|1|\(contact.userName)"
                        
                        let message = V2NIMMessageCreator.createForwardMessage(originalMessage)
                        NIMSDK.shared().v2MessageService.send(message, conversationId: conversationId, params: nil) { _ in
                            
                        } failure: { _ in
                            
                        }
                    }
                }
                
            }
        })
        self.navigationController?.pushViewController(picker, animated: true)
    }

    func deleteTextIM() {
        
        var v2collections = [V2NIMCollection]()
        let collectInfo = V2NIMCollection()
        collectInfo.createTime = self.favoriteModel?.createTime ?? 0
        collectInfo.collectionId = String(self.favoriteModel?.Id ?? 0)
        v2collections.append(collectInfo)
        
        NIMSDK.shared().v2MessageService.remove(v2collections) { [weak self] total in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8 ) {
                self.navigationController?.popViewController(animated: true)
                if let collectMsgCall = self.collectionMsgCall {
                    collectMsgCall!(self.favoriteModel)
                }
                
            }
        } failure: { error in
            
        }
    }
    
    func saveMsgCollectionIM() {
        guard let model = self.favoriteModel else {
            return
        }
        if model.type == .image {
            weak var wself = self
            guard let imageURL = wself?.imageAttachment?.url else { return }
            SDWebImageManager.shared.imageCache.queryImage(forKey: imageURL, options: .fromCacheOnly, context: nil) { (image, data, cacheType) in
                guard let image = image else {
                    return
                }
                self.saveImageToAlbum(imageFile: image)
            }
        } else if model.type == .video {
           // SVProgressHUD.show(withStatus: "downloading...".localized)

            DispatchQueue.global(qos: .background).async { [self] in
                if let url = URL(string: videoAttachment?.url ?? ""), let urlData = NSData(contentsOf: url) {
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                    let filePath="\(documentsPath)/tempFile.mp4"
                    DispatchQueue.main.async {
                        urlData.write(toFile: filePath, atomically: true)
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                        }) { completed, error in
                            if completed {
                              //  SVProgressHUD.showSuccess(withStatus: "success_save".localized)
                            }
                            if (error != nil) {
                                print("💢💢💢", error!.localizedDescription)
                                //SVProgressHUD.showError(withStatus: "fail_save".localized)
                            }
                        }
                    }
                }
            }
        }
    }
   
}
