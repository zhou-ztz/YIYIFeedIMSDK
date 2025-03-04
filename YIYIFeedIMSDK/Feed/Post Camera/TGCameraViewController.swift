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

typealias CameraHandler = (([PHAsset], [UIImage]?, String?, Bool, Bool) -> Void)
class TGCameraViewController: TGBaseCameraViewController {
    
    var onSelectPhoto: CameraHandler? = nil
    var enableMultiplePhoto: Bool = false
    var allowPickingVideo: Bool = false
    var selectedAsset: [PHAsset] = []
    var selectedImage: [Any] = []
    var onDismiss: EmptyClosure? = nil
    var allowCrop: Bool = false //剪切
    var allowEdit: Bool = false //编辑
    
    fileprivate lazy var buttonsContainer: TGCameraContainer = {
        let container = TGCameraContainer()
        container.delegate = self
        return container
    }()
    
    
    override var mediaType: TGMediaType { return .camera }
    public override var shouldAutorotate: Bool { return false }
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return [.portrait] }
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { return .portrait }
    
    override func viewDidLoad() {
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
    

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var maxPhoto: Int {
        return enableMultiplePhoto ? 9 : 1
    }
    
    deinit {
        print("deinit CameraViewController")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addObserver()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    private func addObserver() {
 
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        if #available(iOS 14.0, *) {
            // 获取照片库的授权状态
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            switch status {
            case .limited:
                handleLimitedAccess()
            case .authorized:
                presentPHPicker()
            default:
                print("未授权相册")
            }
            
        } else {
            
        }
        
//        guard let vc = TZImagePickerController(maxImagesCount: maxPhoto - self.selectedAsset.count - self.selectedImage.count, columnNumber: 4, delegate: self, mainColor: TSColor.main.red) else { return }
//        vc.allowCrop = allowCrop
//        vc.allowTakePicture = false
//        vc.allowTakeVideo = false
//        vc.allowPickingImage = true
//        vc.allowPickingVideo = allowPickingVideo
//        vc.allowPickingGif = true
//        vc.allowPickingMultipleVideo = false
//        vc.photoSelImage =  UIImage(named: "ic_rl_checkbox_selected")
//        vc.previewSelectBtnSelImage = UIImage(named: "ic_rl_checkbox_selected")
//        vc.navigationBar.tintColor = .black
//        vc.navigationItem.titleView?.tintColor = .black
//        vc.navigationBar.barTintColor = .black
//        vc.barItemTextColor = .black
//        vc.backImage = UIImage(named: "iconsArrowCaretleftBlack")
//        vc.allowPreview = true
//        var dic = [NSAttributedString.Key: Any]()
//        dic[NSAttributedString.Key.foregroundColor] = UIColor.black
//        vc.navigationBar.titleTextAttributes = dic
//        self.present(vc.fullScreenRepresentation, animated: true, completion: nil)
    }
  
    /// 处理受限访问模式下的逻辑
    private func handleLimitedAccess() {
        
        self.showAlert(message: "rw_limited_feed_photo_tip".localized, buttonTitle: "ok".localized) { action in
            if #available(iOS 15, *) {
                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self) { ids in
                    var selectedAssets: [PHAsset] = []
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                        selectedAssets = self.fetchAllLimitedAssets()
                        self.handleSelectedPhotos(photos: [UIImage()], imageAsset: selectedAssets, isGifImage: false)
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        }
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
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
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
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
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
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
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
    var dismissHandler: EmptyClosure?
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
