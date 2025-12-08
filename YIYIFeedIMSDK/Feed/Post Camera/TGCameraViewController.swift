//
//  TGCameraViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/2.
//

import UIKit
import MobileCoreServices
import IQKeyboardManagerSwift
import PhotosUI
import Photos

public typealias TGCameraHandler = (([PHAsset], [UIImage]?, String?, Bool, Bool) -> Void)
public class TGCameraViewController: TGBaseCameraViewController {
    
    public var onSelectPhoto: TGCameraHandler? = nil
    public var enableMultiplePhoto: Bool = false
    public var allowPickingVideo: Bool = false
    public var selectedAsset: [PHAsset] = []
    public var selectedImage: [Any] = []
    public var onDismiss: TGEmptyClosure? = nil
    public var allowCrop: Bool = false //剪切
    public var allowEdit: Bool = false //编辑
    
    fileprivate lazy var buttonsContainer: TGCameraContainer = {
        let container = TGCameraContainer()
        container.delegate = self
        return container
    }()
    
    
    override var mediaType: TGMediaType { return .camera }
    public override var shouldAutorotate: Bool { return false }
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return [.portrait] }
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { return .portrait }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        self.modalPresentationCapturesStatusBarAppearance = true
        
        self.setupAVFoundationSettings()
        
        self.view.addSubview(buttonsContainer)

        buttonsContainer.snp.makeConstraints {
            if RLUserInterfacePrinciples.share.hasNotch() {
                $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                $0.height.equalTo(self.view.snp.width).multipliedBy(1.888)
            } else {
                $0.top.equalToSuperview()
            }
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).priority(.low)
        }
        self.buttonsContainer.flashButton.isHidden = false
        // Do any additional setup after loading the view.
    }
    

    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var maxPhoto: Int {
        return enableMultiplePhoto ? 9 : 1
    }
    
    deinit {
        print("deinit CameraViewController")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addObserver()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    private func addObserver() {
 
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.buttonsContainer.isHidden == true {
            self.buttonsContainer.isHidden = false
        }
    }

}

extension TGCameraViewController: MiniVideoRecordContainerDelegate {
    //退出
    func closebuttonDidTapped(_ isShowSheet: Bool) {
        self.dismiss(animated: true, completion: nil)
        self.onDismiss?()
    }
    //录制
    func recorderButtonDidTapped() {

    }
    //切换摄像头
    func flipButtonDidTapped() {
        self.flipCamera()
        self.buttonsContainer.flashButton.isHidden = self.isFront
    }

    //闪光灯按钮点击事件
    func flashButtonDidTapped() {
        self.buttonsContainer.flashButton.isSelected = !self.buttonsContainer.flashButton.isSelected
        self.flashOpen()
    }
    func durationButtonDidTapped() {
        
    }
    // MARK: - 相册
    func albumButtonDidTapped() {
        TGUtil.checkAuthorizeStatusByType(type: .cameraAlbum, isShowBottom: true, viewController: self, completion: {
            if #available(iOS 14.0, *) {
                // 获取照片库的授权状态
                let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
                switch status {
                case .limited:
                    self.handleLimitedAccess()
                case .authorized:
                    self.presentPHPicker()
                default:
                    print("未授权相册")
                }
                
            }
        })
    }
  
    /// 处理受限访问模式下的逻辑
    private func handleLimitedAccess() {
        
        guard let vc = TZImagePickerController(maxImagesCount: maxPhoto - self.selectedAsset.count, columnNumber: 4, delegate: self, mainColor: RLColor.main.red) else { return }
        vc.allowCrop = allowCrop
        vc.allowTakePicture = false
        vc.allowTakeVideo = false
        vc.allowPickingImage = true
        vc.allowPickingVideo = false
        vc.allowPickingGif = true
        vc.allowPickingMultipleVideo = false
        vc.showPhotoCannotSelectLayer = false
        vc.maxImagesCount = maxPhoto - self.selectedAsset.count
        vc.photoSelImage =  UIImage(named: "ic_rl_checkbox_selected")
        vc.previewSelectBtnSelImage = UIImage(named: "ic_rl_checkbox_selected")
        vc.navigationBar.tintColor = UIColor.black
        vc.navigationItem.titleView?.tintColor = UIColor.black
        vc.navigationBar.barTintColor = UIColor.black
        vc.barItemTextColor = UIColor.black
        vc.allowPreview = true
        vc.backImage = UIImage(named: "iconsArrowCaretleftBlack")
        var dic = [NSAttributedString.Key: Any]()
        dic[NSAttributedString.Key.foregroundColor] = UIColor.black
        vc.navigationBar.titleTextAttributes = dic
        self.present(vc.fullScreenRepresentation, animated: true, completion: nil)
    }

    /// 获取指定 IDs 的 PHAsset
    private func fetchAssets(for ids: [String]) -> [PHAsset] {
        var assets: [PHAsset] = []
        let fetchedAssets = PHAsset.fetchAssets(withLocalIdentifiers: ids, options: nil)
        fetchedAssets.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        return assets
    }

    /// 获取当前受限模式下的所有 PHAsset
    private func fetchAllLimitedAssets() -> [PHAsset] {
        var assets: [PHAsset] = []
         
         // 设置排序条件：按创建日期降序排列
         let fetchOptions = PHFetchOptions()
         fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
         
         let allAssets = PHAsset.fetchAssets(with: fetchOptions)
         allAssets.enumerateObjects { asset, _, _ in
             assets.append(asset)
         }
         return assets
    }

    /// 打开 PHPickerViewController
    private func presentPHPicker() {
        if #available(iOS 14.0, *) {
            var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
            phPickerConfig.selectionLimit = maxPhoto
            phPickerConfig.filter = allowPickingVideo ? PHPickerFilter.videos : .any(of: [.images, .livePhotos])
            
            let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
            phPickerVC.delegate = self
            present(phPickerVC, animated: true)
        } else {
            // Fallback on earlier versions
        }

    }
    func editButtonDidTapped() {
        let settings = AVCapturePhotoSettings()
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func focusbuttonDidTapped(_ point: CGPoint) {

    }
}

extension TGCameraViewController: PHPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: .none)
        
        var photos: [UIImage] = []
        var imageAsset: [PHAsset] = []
        var isGifImage = false
        
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            // Check if the item is a GIF
            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.gif.identifier) {
                isGifImage = true
            } else {
                isGifImage = false
            }
            
            // Handle UIImage extraction
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage {
                    photos.append(image)
                }
                dispatchGroup.leave()
            }
            
            // Handle PHAsset extraction
            if let assetIdentifier = result.assetIdentifier {
                let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject
                if let phAsset = asset {
                    imageAsset.append(phAsset)
                }
            }
        }
        
        // After all images are loaded
        dispatchGroup.notify(queue: .main) {
            self.handleSelectedPhotos(photos: photos, imageAsset: imageAsset, isGifImage: isGifImage)
        }
        
    
    }
    
    func handleSelectedPhotos(photos: [UIImage], imageAsset: [PHAsset], isGifImage: Bool) {
        // 如果没有选中任何照片，直接返回
        guard !photos.isEmpty else { return }
        
        // 移除视频文件，只保留图片文件
        let filteredImageAssets = imageAsset.filter { $0.mediaType == .image }

        if photos.count == 1 && allowEdit && !isGifImage {
            let editor = PhotoEditorViewController(nibName: "PhotoEditorViewController", bundle: Bundle(for: PhotoEditorViewController.self))
            editor.photoEditorDelegate = self
            editor.image = photos[0]
            self.present(editor.fullScreenRepresentation, animated: true, completion: nil)
            
        } else {
            // 使用过滤后的图片资源
            self.selectedAsset.append(contentsOf: filteredImageAssets)
            // 限制 selectedAsset 数量为最多 9 张
            if self.selectedAsset.count > 9 {
                self.selectedAsset = Array(self.selectedAsset.prefix(9))
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: {
                    guard !self.selectedAsset.isEmpty else { return }
                    self.onSelectPhoto?(self.selectedAsset, photos, nil, false, false)
                })
            }

        }
    }
    
}

extension TGCameraViewController: TZImagePickerControllerDelegate {
    
    public func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        guard let imageAsset = assets as? [PHAsset] else {
            return
        }
        //在这里加上判断，如果选择的图片为gif图片，不需要进入图片编辑页面
        var isGifImage = false
        if imageAsset.count > 0 {
            let phAsset = imageAsset[0]
            if let imageType = phAsset.value(forKey: "uniformTypeIdentifier") as? String {
                if imageType == String(kUTTypeGIF) {
                    isGifImage = true
                }
            }
        }
        if photos.count == 1 && allowEdit && !isGifImage {
            let editor = PhotoEditorViewController(nibName: "PhotoEditorViewController", bundle: Bundle(for: PhotoEditorViewController.self))
            editor.photoEditorDelegate = self
            editor.image = photos[0]
            self.present(editor.fullScreenRepresentation, animated: true, completion: nil)
            
        } else {
            self.selectedAsset.append(contentsOf: imageAsset)
            self.dismiss(animated: true, completion: nil)
            self.onSelectPhoto?(self.selectedAsset, photos, nil, false, false)
        }
        
    }
    
    public func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingGifImage animatedImage: UIImage!, sourceAssets asset: PHAsset!) {
        self.selectedAsset.append(asset)
        self.dismiss(animated: true, completion: nil)
        self.onSelectPhoto?(self.selectedAsset, [animatedImage], nil, true, false)
    }
    
    public func imagePickerController(_ picker: TZImagePickerController!, didFinishEditVideoCover coverImage: UIImage!, videoURL: Any!) {
        guard let videoURL = videoURL as? NSURL   else { return }
        
        let videoPath = videoURL.path ?? ""
        
        DispatchQueue.global(qos: .default).async(execute: {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: videoPath))
            }) { [weak self] (saved, error) in
                if saved {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                    if let result = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject {
                        
                        let option = PHVideoRequestOptions()
                        option.version = .current
                        option.deliveryMode = .automatic
                        option.isNetworkAccessAllowed = true
                        
                        PHImageManager.default().requestExportSession(forVideo: result, options: option, exportPreset: AVAssetExportPresetHighestQuality) { [weak self] (exportSession, info) in
                            
                            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                            let date = String(dateFormatter.string(from: Date()))
                            let fileName = String(date.filter { String($0).rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789")) != nil })
                            
                            let url = URL(fileURLWithPath: documentDirectory).appendingPathComponent("\(fileName).mp4")
                            
                            if FileManager.default.fileExists(atPath: videoPath) {
                                do {
                                    try FileManager.default.removeItem(atPath: videoPath)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            
                            exportSession?.outputURL = url
                            exportSession?.outputFileType = .mp4
                            exportSession?.shouldOptimizeForNetworkUse = true
                            exportSession?.exportAsynchronously {
                                DispatchQueue.main.async {
                                    if exportSession?.status == AVAssetExportSession.Status.completed {
                                        self?.dismiss(animated: true, completion: nil)
                                        self?.onSelectPhoto?([result], nil, url.path, false, false)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.dismiss(animated: true, completion: nil)
                        self?.onSelectPhoto?([], nil, videoURL.path ?? "", false, false)
                    }
                }
            }
        })
    }
    
    public func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingVideo asset: PHAsset!) {
        guard let asset = asset, asset.mediaType == .video else { return }
        
        let option = PHVideoRequestOptions()
        option.version = .current
        option.deliveryMode = .automatic
        option.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestExportSession(forVideo: asset, options: option, exportPreset: AVAssetExportPresetHighestQuality) { [weak self] (exportSession, info) in
            
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let date = String(dateFormatter.string(from: Date()))
            let fileName = String(date.filter { String($0).rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789")) != nil })
            
            let url = URL(fileURLWithPath: documentDirectory).appendingPathComponent("\(fileName).mp4")
            
            exportSession?.outputURL = url
            exportSession?.outputFileType = .mp4
            exportSession?.shouldOptimizeForNetworkUse = true
            exportSession?.exportAsynchronously {
                DispatchQueue.main.async {
                    
                    if exportSession?.status == AVAssetExportSession.Status.completed {
                        self?.dismiss(animated: true, completion: nil)
                        self?.onSelectPhoto?([asset], nil, url.path, false, false)
                    }
                }
            }
        }
    }
}

extension TGCameraViewController: PhotoEditorDelegate {
    public func doneEditing(image: UIImage) {
        
        DispatchQueue.global(qos: .default).async(execute: {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { (saved, error) in
                
                if saved {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                    let result = PHAsset.fetchAssets(with: .image, options: fetchOptions).lastObject
                    if let result = result {
                        self.selectedAsset.append(result)
                    }
                    
                    DispatchQueue.main.async {
                        self.dismiss(animated: true) {
                            self.onSelectPhoto?(self.selectedAsset, [image], nil, false, true)
                        }
                    }
                }
            }
        })
    }
    
    public func canceledEditing() {
        
    }
}

extension TGCameraViewController: UIViewControllerTransitioningDelegate {
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        buttonsContainer.isContainerHidden = true
        
        let controller = CustomSizePresentationController(presentedViewController: presented, presenting: presenting)
        
        controller.dismissHandler = { [weak self] in
            if self?.buttonsContainer.isContainerHidden == true {
                self?.buttonsContainer.isContainerHidden = false
            }
        }
        
        return controller
    }
}

extension TGCameraViewController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(),
           let image = UIImage(data: imageData) {
            let watermarkImage = image.addWatermark()
            DispatchQueue.main.async {
//                if let photoEditor = FileUtils.shared.createPhotoEditor(for: watermarkImage) {
//                    photoEditor.photoEditorDelegate = self
//                    self.navigationController?.pushViewController(photoEditor, animated: true)
//                }
                IQKeyboardManager.shared.shouldResignOnTouchOutside = false
                let editor = PhotoEditorViewController(nibName: "PhotoEditorViewController", bundle: Bundle(for: PhotoEditorViewController.self))
                editor.photoEditorDelegate = self
                editor.isCamera = true
                editor.image = watermarkImage
    //            self.present(editor.fullScreenRepresentation, animated: true, completion: nil)
                self.navigationController?.pushViewController(editor, animated: true)
            }

            
        }
    }
}


class TGCameraContainer: TGBaseRecorderContainer {
    override init() {
        super.init()
        
        container.addSubview(recordButton)
        
        stackview.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview()
        }
        
        stackview.snp.makeConstraints {
            $0.top.equalToSuperview().offset(TSStatusBarHeight)
            $0.trailing.equalToSuperview()
        }
        
        stackview.addArrangedSubview(flipButton)
        stackview.addArrangedSubview(timerButton)
        stackview.addArrangedSubview(flashButton)
        
        stackview.arrangedSubviews.forEach { (view) in
            view.snp.makeConstraints {
                $0.width.equalTo(45)
                $0.height.equalTo(50)
            }
        }
        
        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.top.equalToSuperview().offset(TSStatusBarHeight)
            $0.width.height.equalTo(40)
        }
        
        recordButton.snp.makeConstraints {
            $0.width.height.equalTo(73)
            $0.centerX.equalToSuperview()
            if RLUserInterfacePrinciples.share.hasNotch() {
                $0.bottom.equalToSuperview().offset(-30)
            } else {
                $0.bottom.equalToSuperview().offset(-60)
            }
        }

        albumButton.snp.makeConstraints {
            $0.leading.equalTo(recordButton.snp.trailing).offset(30)
            $0.centerY.equalTo(recordButton)
            $0.width.height.equalTo(60)
        }
        
        setupRecorder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    public lazy var recordButton: TGCameraButton = { [weak self] in
        let button = TGCameraButton(frame: CGRect(origin: .zero, size: CGSize(width: 73, height: 73)))
        button.delegate = self
        return button
    }()
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        self.delegate?.recorderButtonDidTapped()
    }
}


extension TGCameraContainer: TGRecordButtonDelegate {
    
    func capture() {
        countdownTimerChecker { [weak self] in
            self?.container.isHidden = true
        } countDownEnd: { [weak self] in
            self?.container.isHidden = false
            self?.delegate?.editButtonDidTapped()
        }
    }
}
public class CustomSizePresentationController : UIPresentationController {
    var heightPercent: CGFloat = 0.66
    var dismissHandler: TGEmptyClosure?
    private let background = UIView().configure {
        $0.backgroundColor = .clear
    }
    
    override public var frameOfPresentedViewInContainerView: CGRect {
        guard let parentView = containerView else {
            return .zero
        }
        if parentView.frame.width > parentView.frame.height {
            return CGRect(x: parentView.bounds.width/2, y: 0, width:  parentView.bounds.width/2, height: parentView.bounds.height)
        } else {
            return CGRect(x: 0, y: parentView.bounds.height * (1 - heightPercent), width: parentView.bounds.width, height: parentView.bounds.height * heightPercent)
        }
    }
    override public func presentationTransitionDidEnd(_ completed: Bool) {
        if let frame = containerView?.frame, completed {
            background.frame = frame
            background.addTap { [weak self] _ in
                self?.presentedViewController.dismiss(animated: true, completion: {
                    self?.dismissHandler?()
                })
            }
            containerView?.insertSubview(background, at: 0)
        }
    }
    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            background.removeFromSuperview()
        }
    }
    
    public override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}
