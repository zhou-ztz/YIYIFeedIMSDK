//
//  TGMiniVideoRecorderViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/2.
//

import Foundation
import AVFoundation
import Photos
import PhotosUI

public typealias MiniVideoRecorderHandler = ((URL) -> Void)

public class TGMiniVideoRecorderViewController: TGBaseCameraViewController {
    
    public var onSelectMiniVideo: MiniVideoRecorderHandler? = nil
    override var mediaType: TGMediaType { return .miniVideo }
    public override var shouldAutorotate: Bool { return false }
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return [.portrait] }
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { return .portrait }
    
    ///campaign 活动 商家 hashtag信息
    public var campaignDict: [String: Any]?
    public override func viewDidLoad() {
        super.viewDidLoad()
        //设置代理
        self.delegate = self
        self.modalPresentationCapturesStatusBarAppearance = true
        self.view.backgroundColor = .black
        
        //  录制视频基本设置
        self.setupAVFoundationSettings()
        //  加载功能面板
        self.initContainer()
        //  预获取视频相册，解决录制完成权限弹窗异步问题
        PHAsset.fetchAssets(with: .video, options: nil)
    }
    
    func initContainer() {
        self.view.addSubview(self.videoButtonsContainer)
        self.videoButtonsContainer.delegate = self
        self.videoButtonsContainer.snp.makeConstraints {
            if RLUserInterfacePrinciples.share.hasNotch() {
                $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                $0.height.equalTo(self.view.snp.width).multipliedBy(1.888)
            } else {
                $0.top.equalToSuperview()
            }
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).priority(.low)
        }
        self.videoButtonsContainer.flashButton.isHidden = false
        
    }
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        print("deinit MiniVideoRecorderViewController")
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
        if self.videoButtonsContainer.isHidden == true{
            self.videoButtonsContainer.isHidden = false
        }
    }
}


extension TGMiniVideoRecorderViewController: MiniVideoRecordContainerDelegate {
    func editButtonDidTapped() {
        
    }
    
    
    // MARK: - 关闭页面
    func closebuttonDidTapped(_ isShowSheet: Bool) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: { [weak self] in
                guard let self = self else { return }
                self.stopRecord()
            })
        }
    }
    // MARK: - 录制按钮点击事件
    func recorderButtonDidTapped() {
        
        if self.videoButtonsContainer.timer > 0 && self.isRecording == false {
            self.videoButtonsContainer.countdownTimerChecker { [weak self] in
                guard let self = self else { return }
                self.videoButtonsContainer.recordButton.isHidden = true
                self.videoButtonsContainer.enterRecordingState()
            } countDownEnd: { [weak self] in
                guard let self = self else { return }
                self.videoButtonsContainer.recordButton.isHidden = false
                self.startRecord()
                DispatchQueue.global(qos: .background).async {
                    self.captureSession.startRunning()
                }
                
            }
            
        }else{
            self.startRecord()
        }
        
        
    }
    
    // MARK: - 切换摄像头
    func flipButtonDidTapped() {
        self.flipCamera()
        self.videoButtonsContainer.flashButton.isHidden = self.isFront
    }
    // MARK: - 闪光灯按钮点击事件
    func flashButtonDidTapped() {
        self.videoButtonsContainer.flashButton.isSelected = !self.videoButtonsContainer.flashButton.isSelected
        self.flashOpen()
    }
    // MARK: - 录制时长点击事件
    func durationButtonDidTapped() {
        print("设置录制时长 ： \(self.videoButtonsContainer.maxDuration)")
    }
    // MARK: - 相册
    func albumButtonDidTapped() {
        TGUtil.checkAuthorizeStatusByType(type: .cameraAlbum, isShowBottom: true, viewController: self, completion: {
            if #available(iOS 14.0, *) {
                // 获取授权状态
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
    
    func focusbuttonDidTapped(_ point: CGPoint) {
        
    }
    /// 处理受限访问模式下的逻辑
    private func handleLimitedAccess() {
        guard let vc = TZImagePickerController(maxImagesCount: 9, columnNumber: 4, delegate: self, mainColor: RLColor.main.red) else { return }
        vc.allowCrop = false
        vc.allowTakePicture = false
        vc.allowTakeVideo = false
        vc.allowPickingImage = false
        vc.allowPickingVideo = true
        vc.allowPickingGif = false
        vc.allowPickingMultipleVideo = true
        vc.showPhotoCannotSelectLayer = true
        vc.maxImagesCount = 1
        vc.photoSelImage =  UIImage(named: "ic_rl_checkbox_selected")
        vc.previewSelectBtnSelImage = UIImage(named: "ic_rl_checkbox_selected")
        vc.navigationBar.tintColor = UIColor.black
        vc.navigationItem.titleView?.tintColor = UIColor.black
        vc.navigationBar.barTintColor = UIColor.black
        vc.barItemTextColor = UIColor.black
        vc.backImage = UIImage(named: "iconsArrowCaretleftBlack")
        var dic = [NSAttributedString.Key: Any]()
        dic[NSAttributedString.Key.foregroundColor] = UIColor.black
        vc.navigationBar.titleTextAttributes = dic
        
        
        vc.didFinishPickingPhotosHandle = { photos, assets, isSelectOriginalPhoto in
            if let assets = assets as? [PHAsset] {
                self.getResource(asset: assets[0])
            }
        }
        
        vc.didFinishPickingVideoHandle = { coverImage, asset in
            if let asset = asset {
                self.getResource(asset: asset)
            }
        }
        self.present(vc.fullScreenRepresentation, animated: true, completion: nil)
    }
    // 显示 PHPicker
    @available(iOS 14.0, *)
    func presentPHPicker() {
        var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
        phPickerConfig.selectionLimit = 1
        phPickerConfig.filter = .videos
        
        let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
        phPickerVC.delegate = self
        present(phPickerVC, animated: true)
    }
    // MARK: - 获取受限模式下的所有已选资源
    private func handleCurrentLimitedAssets() {
        let options = PHFetchOptions()
        options.includeAssetSourceTypes = [.typeUserLibrary]
        
        let limitedAssets = PHAsset.fetchAssets(with: options)
        var videoAsset: PHAsset?
        
        limitedAssets.enumerateObjects { asset, _, stop in
            if asset.mediaType == .video {
                videoAsset = asset
                stop.pointee = true // 停止遍历，一旦找到视频
            }
        }
        
        if let videoAsset = videoAsset {
            //当前受限模式下找到视频资源
            getResource(asset: videoAsset)
        }
    }
    /// 根据 ids 获取 PHAsset 列表
    private func fetchAssets(for ids: [String]) -> [PHAsset] {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: ids, options: nil)
        var result: [PHAsset] = []
        
        assets.enumerateObjects { asset, _, _ in
            result.append(asset)
        }
        
        return result
    }
   
}

extension TGMiniVideoRecorderViewController: PHPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: .none)
        
        for result in results {
            // Handle PHAsset extraction
            if let assetIdentifier = result.assetIdentifier {
                let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject
                if let phAsset = asset {
                    getResource(asset: phAsset)
                }
            }
        }
        
    }
}

extension TGMiniVideoRecorderViewController: TZImagePickerControllerDelegate {
    func getResource(asset: PHAsset) {
        DispatchQueue.main.async {
            
            PHImageManager.default().requestExportSession(forVideo: asset, options: self.getVideoRequestOptions(), exportPreset: AVAssetExportPresetPassthrough) { [weak self] exportSession, info in
                let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let date = dateFormatter.string(from: Date())
                let fileName = date.filter { "0123456789".contains($0) }
                
                let url = URL(fileURLWithPath: documentDirectory).appendingPathComponent("\(fileName).mp4")
                
                exportSession?.outputURL = url
                exportSession?.outputFileType = .mp4
                exportSession?.shouldOptimizeForNetworkUse = true
                
                exportSession?.exportAsynchronously {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        if exportSession?.status == .completed {
                            if self.onSelectMiniVideo != nil {
                                self.dismiss(animated: true) {
                                    self.onSelectMiniVideo?(url)
                                }
                            }else{
                                
                                let avAsset = AVURLAsset(url: url)
                                let coverImage = FileUtils.generateAVAssetVideoCoverImage(avAsset: avAsset)
                                let vc = TGReleasePulseViewController(type: .miniVideo)
                                vc.shortVideoAsset = TGShortVideoAsset(coverImage: coverImage, asset: nil, videoFileURL: url)
                                vc.campaignDict = self.campaignDict
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        } else {
                            
                            // 处理导出失败的情况
                            print("Video export failed: \(exportSession?.error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                    
                    
                }
            }
            
        }
        
    }
    private func getVideoRequestOptions() -> PHVideoRequestOptions {
        let options = PHVideoRequestOptions()
        //        options.deliveryMode = .automatic
        options.version = .current
        options.isNetworkAccessAllowed = true
        return options
    }
}

extension TGMiniVideoRecorderViewController: TGBaseCameraViewControllerDelegate {
    func finishRecordingTo(outputFileURL: URL) {
        let avAsset = AVURLAsset(url: outputFileURL)
        let coverImage = FileUtils.generateAVAssetVideoCoverImage(avAsset: avAsset)
        //拍摄视频转换为MP4
        DispatchQueue.global(qos: .default).async(execute: {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
            }) { [weak self] (saved, error) in
                if saved {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                    if let result = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject {
                        
                        let option = PHVideoRequestOptions()
                        option.version = .current
                        option.deliveryMode = .automatic
                        option.isNetworkAccessAllowed = true
                        
                        PHImageManager.default().requestExportSession(forVideo: result, options: option, exportPreset: AVAssetExportPreset960x540) { [weak self] (exportSession, info) in
                            
                            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                            let date = String(dateFormatter.string(from: Date()))
                            let fileName = String(date.filter { String($0).rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789")) != nil })
                            
                            let url = URL(fileURLWithPath: documentDirectory).appendingPathComponent("\(fileName).mp4")
                            
                            if FileManager.default.fileExists(atPath: outputFileURL.absoluteString) {
                                do {
                                    try FileManager.default.removeItem(atPath: outputFileURL.absoluteString)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            exportSession?.outputURL = url
                            exportSession?.outputFileType = .mp4
                            exportSession?.shouldOptimizeForNetworkUse = true
                            exportSession?.exportAsynchronously {
                                DispatchQueue.main.async {
                                    
                                    guard let self = self else { return }
                                    if exportSession?.status == .completed {
                                        if self.onSelectMiniVideo != nil {
                                            self.dismiss(animated: true) {
                                                self.onSelectMiniVideo?(url)
                                            }
                                        }else{
                                            self.navigateToPostShortVideoViewController(coverImage: coverImage, asset: nil, videoFileURL: url)
                                            
                                        }} else {
                                            // 处理导出失败的情况
                                            print("Video export failed: \(exportSession?.error?.localizedDescription ?? "Unknown error")")
                                        }
                                }
                                
                            }
                        }
                    }
                }
            }
        })
    }
    
    private func navigateToPostShortVideoViewController(coverImage: UIImage?, asset: PHAsset?, videoFileURL: URL) {
        DispatchQueue.main.async {
            let vc = TGReleasePulseViewController(type: .miniVideo)
            vc.shortVideoAsset = TGShortVideoAsset(coverImage: coverImage, asset: asset, videoFileURL: videoFileURL)
            vc.campaignDict = self.campaignDict
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
