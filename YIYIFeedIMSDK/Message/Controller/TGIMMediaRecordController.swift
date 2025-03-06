//
//  TGIMMediaRecordController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/28.
//

import UIKit
import SVProgressHUD

import MobileCoreServices
import IQKeyboardManagerSwift
import PhotosUI

typealias MiniVideoHandler = ((String) -> Void)

enum IMMediaType {
    case photo
    case miniVideo
}

class TGIMMediaRecordController: TGBaseCameraViewController {

    override var mediaType: TGMediaType { return .camera }
    
    private lazy var photoBtn: MiniVideoTab = {
        let button = MiniVideoTab(title: "photo".localized)
        button.titleView.addAction { [weak self] in
            self?.buttonDidTapped(.photo)
        }
        return button
    }()

    private lazy var miniVideoBtn: MiniVideoTab = {
        let button = MiniVideoTab(title: "mini_video".localized)
        button.titleView.addAction { [weak self] in
            self?.buttonDidTapped(.miniVideo)
        }
        return button
    }()
    
    private let stackview = UIStackView().configure {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fillEqually
        
        $0.spacing = 5
    }

    //camera type 所需参数
    var onSelectPhoto: TGCameraHandler? = nil
    var enableMultiplePhoto: Bool = false
    var allowPickingVideo: Bool = false
    var selectedAsset: [PHAsset] = []
    var onDismiss: TGEmptyClosure? = nil
    var allowCrop: Bool = false //剪切
    var allowEdit: Bool = false //编辑
    
    //miniVideo type所需参数
    var onSelectMiniVideo: MiniVideoHandler? = nil
    
    private var resourceURLArray: [URL] = []
    private var resourceAssetArray: [AVURLAsset] = []
    private var resourceDurArray: [Float] = []

    
    private(set) var imType: IMMediaType = .photo
    
    public override var shouldAutorotate: Bool { return false }
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return [.portrait] }
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { return .portrait }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置代理
        self.delegate = self
        self.modalPresentationCapturesStatusBarAppearance = true
        self.view.backgroundColor = .black
        self.setupAVFoundationSettings()
        self.initContainer()
    }
    func initContainer() {
        //添加拍照模块视图
        self.view.addSubview(cameraButtonsContainer)
        cameraButtonsContainer.delegate = self
        self.cameraButtonsContainer.snp.makeConstraints {
            if RLUserInterfacePrinciples.share.hasNotch() {
                $0.top.equalTo(self.topLayoutGuide.snp.bottom)
                $0.height.equalTo(self.view.snp.width).multipliedBy(1.788)
            } else {
                $0.top.equalToSuperview()
            }
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.bottomLayoutGuide.snp.top).priority(.low)
        }
        self.cameraButtonsContainer.flashButton.isHidden = false
        
        
        //添加录制视频模块视图
        self.view.addSubview(videoButtonsContainer)
        videoButtonsContainer.isHidden = true
        videoButtonsContainer.delegate = self
        videoButtonsContainer.snp.makeConstraints {
            if RLUserInterfacePrinciples.share.hasNotch() {
                $0.top.equalTo(self.topLayoutGuide.snp.bottom)
                $0.height.equalTo(self.view.snp.width).multipliedBy(1.788)
            } else {
                $0.top.equalToSuperview()
            }
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.bottomLayoutGuide.snp.top).priority(.low)
        }
        self.videoButtonsContainer.flashButton.isHidden = false
        
        self.view.addSubview(stackview)
        stackview.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottomMargin).inset(16)
        }
        stackview.addArrangedSubview(photoBtn)
        stackview.addArrangedSubview(miniVideoBtn)

        photoBtn.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalTo(70)
        }

        miniVideoBtn.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalTo(70)
        }
        
        photoBtn.isSelected = true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var maxPhoto: Int {
        return enableMultiplePhoto ? 9 : 1
    }
    
    deinit {
        print("deinit TSIMMediaRecordController")
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
        
        if self.videoButtonsContainer.isHidden == true && self.imType == .miniVideo{
            self.videoButtonsContainer.isHidden = false
            self.stackview.isHidden = false
        }
        if self.cameraButtonsContainer.isHidden == true && self.imType == .photo{
            self.cameraButtonsContainer.isHidden = false
            self.stackview.isHidden = false
        }
  
    }
    // MARK: - Variables
    fileprivate lazy var cameraButtonsContainer: TGCameraContainer = {
        let container = TGCameraContainer()
        container.delegate = self
        return container
    }()
    
    private func buttonDidTapped(_ type: IMMediaType) {
        photoBtn.isSelected = type == .photo
        miniVideoBtn.isSelected = type == .miniVideo
        self.imType = type
        self.updateContainer()
        self.changeMediaType(mediaType: self.imType == .miniVideo ? .miniVideo : .camera)
    }

}

extension TGIMMediaRecordController {
    func updateContainer() {
        
        videoButtonsContainer.isHidden = self.imType == .photo
        cameraButtonsContainer.isHidden = self.imType == .miniVideo
        
        if self.imType == .photo {
            cameraButtonsContainer.recordButton.tapRecordingAnimationWithDuration(duration: 0.1)
            self.cameraButtonsContainer.flashButton.isHidden = self.isFront
            if videoButtonsContainer.timer > 0 {
                updateTimer(timer: videoButtonsContainer.timer, container: cameraButtonsContainer)
            }
        }else{
            videoButtonsContainer.recordButton.tapRecordingAnimationWithDuration(duration: 0.1)
            self.videoButtonsContainer.flashButton.isHidden = self.isFront
            if cameraButtonsContainer.timer > 0 {
                updateTimer(timer: cameraButtonsContainer.timer, container: videoButtonsContainer)
            }
        }
        
    }
    func updateTimer(timer: Int, container: TGBaseRecorderContainer) {
            switch timer {
            case 3:
                container.timer = 3
                container.timerButton.setImage(UIImage(named: "ic_timer_3s"), for: .normal)
            case 7:
                container.timer = 7
                container.timerButton.setImage(UIImage(named: "ic_timer_7s"), for: .normal)
            default:
                container.timer = 0
                container.timerButton.setImage(UIImage(named: "ic_timer_video"), for: .normal)
            }
    }
}

extension TGIMMediaRecordController: MiniVideoRecordContainerDelegate {

    func closebuttonDidTapped(_ isShowSheet: Bool) {
        self.dismiss(animated: true, completion: nil)
        self.onDismiss?()
    }
    // MARK: - 录制按钮
    func recorderButtonDidTapped() {
       
        if self.imType == .photo {
            let settings = AVCapturePhotoSettings()
            stillImageOutput.capturePhoto(with: settings, delegate: self)
        }else{
       
            if self.videoButtonsContainer.timer > 0 && self.isRecording == false{
                self.photoBtn.isHidden = true
                self.miniVideoBtn.isHidden = true
                self.videoButtonsContainer.countdownTimerChecker { [weak self] in
                    guard let self = self else { return }
                    self.videoButtonsContainer.recordButton.isHidden = true
                    self.videoButtonsContainer.enterRecordingState()
                } countDownEnd: { [weak self] in
                    guard let self = self else { return }
                    self.startRecord()
                    DispatchQueue.global(qos: .background).async {
                        self.captureSession.startRunning()
                    }
                    self.videoButtonsContainer.recordButton.isHidden = false
                }

            }else{
                self.photoBtn.isHidden = true
                self.miniVideoBtn.isHidden = true
                self.startRecord()
            }

        }
       
    }
    // MARK: - 拍照按钮
    func editButtonDidTapped() {
        if self.imType == .photo {
            let settings = AVCapturePhotoSettings()
            stillImageOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func flipButtonDidTapped() {
        self.flipCamera()
        self.imType == .photo ? (self.cameraButtonsContainer.flashButton.isHidden = self.isFront) : (self.videoButtonsContainer.flashButton.isHidden = self.isFront)
        
    }
    func flashButtonDidTapped() {
        self.videoButtonsContainer.flashButton.isSelected = !self.videoButtonsContainer.flashButton.isSelected
        self.cameraButtonsContainer.flashButton.isSelected = !self.cameraButtonsContainer.flashButton.isSelected
        self.flashOpen()
    }
    func durationButtonDidTapped() {

    }
 
    
    func albumButtonDidTapped() {
        
        guard let vc = TZImagePickerController(maxImagesCount: self.imType == .photo ? maxPhoto - self.selectedAsset.count : 1, columnNumber: 4, delegate: self, mainColor: RLColor.share.theme) else { return }
        vc.allowCrop = self.imType == .photo ? allowCrop : false
        vc.allowTakePicture = false
        vc.allowTakeVideo = false
        vc.allowPickingImage = self.imType == .photo ? true : false
        vc.allowPickingVideo = self.imType == .photo ? allowPickingVideo : true
        vc.allowPickingGif = self.imType == .photo ? true : false
        vc.allowPickingMultipleVideo = self.imType == .photo ? false : true
        vc.showPhotoCannotSelectLayer = self.imType == .photo ? false : true
        vc.maxImagesCount = self.imType == .photo ? maxPhoto - self.selectedAsset.count : 1
        vc.photoSelImage =  UIImage(named: "ic_rl_checkbox_selected")
        vc.previewSelectBtnSelImage = UIImage(named: "ic_rl_checkbox_selected")
        vc.navigationBar.tintColor = .black
        vc.navigationItem.titleView?.tintColor = .black
        vc.navigationBar.barTintColor = .black
        vc.barItemTextColor = .black
        vc.allowPreview = self.imType == .photo ? true : false
        vc.backImage = UIImage(named: "iconsArrowCaretleftBlack")
        var dic = [NSAttributedString.Key: Any]()
        dic[NSAttributedString.Key.foregroundColor] = UIColor.black
        vc.navigationBar.titleTextAttributes = dic
        self.present(vc.fullScreenRepresentation, animated: true, completion: nil)
    }
    
    func focusbuttonDidTapped(_ point: CGPoint) {

    }
}

extension TGIMMediaRecordController: TZImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
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
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingGifImage animatedImage: UIImage!, sourceAssets asset: PHAsset!) {
        self.selectedAsset.append(asset)
        self.dismiss(animated: true, completion: nil)
        self.onSelectPhoto?(self.selectedAsset, [animatedImage], nil, true, false)
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishEditVideoCover coverImage: UIImage!, videoURL: Any!) {
        guard let videoURL = videoURL as? NSURL, let path = videoURL.path else { return }
        self.dismiss(animated: true, completion: nil)
        self.onSelectMiniVideo?(path)
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingVideo asset: PHAsset!) {
        guard let asset = asset, asset.mediaType == .video else { return }
        
        SVProgressHUD.show(withStatus: "processing".localized)
        
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
                    
                    SVProgressHUD.dismiss()
                    if exportSession?.status == AVAssetExportSession.Status.completed {
                        self?.dismiss(animated: true, completion: nil)
                        self?.onSelectPhoto?([asset], nil, url.path, false, false)
                    }
                }
            }
        }
    }
    
}
extension TGIMMediaRecordController: PhotoEditorDelegate {
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

extension TGIMMediaRecordController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(),
           let image = UIImage(data: imageData) {
            DispatchQueue.main.async {
                let watermarkImage = image.addWatermark()
                let editor = PhotoEditorViewController(nibName: "PhotoEditorViewController", bundle: Bundle(for: PhotoEditorViewController.self))
                editor.photoEditorDelegate = self
                editor.image = watermarkImage
                self.navigationController?.pushViewController(editor, animated: true)
            }
        }
    }
}

extension TGIMMediaRecordController: TGBaseCameraViewControllerDelegate {
    func finishRecordingTo(outputFileURL: URL) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.dismiss(animated: true) {
                self.onSelectMiniVideo?(outputFileURL.path)
            }
        }
    }
}

