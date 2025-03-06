//
//  TGBaseCameraViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/2.
//

import Foundation
import UIKit
import AVFoundation

public enum TGMediaType {
    case camera
    case miniVideo
}
public enum TGMediaPageType {
    case IMPage
    case feedPage
}

protocol TGBaseCameraViewControllerDelegate: AnyObject {
    func finishRecordingTo(outputFileURL: URL)
}

public class TGBaseCameraViewController: TGViewController {

    var mediaType: TGMediaType {
        return .camera
    }
    var mediaPageType: TGMediaPageType {
        return .feedPage
    }
    weak var delegate: TGBaseCameraViewControllerDelegate?
    
    // MARK: - Variables
    lazy var videoButtonsContainer: TGMiniVideoRecorderContainer = {
        let container = TGMiniVideoRecorderContainer()
        return container
    }()
    
    //摄像头设置默认为后置
    var isFront: Bool = false
    
    //新版照片拍摄
    let captureSession = AVCaptureSession()
    var camera: AVCaptureDevice?
    var previewLayer: AVCaptureVideoPreviewLayer!
    let stillImageOutput = AVCapturePhotoOutput()
    
    //  音频输入设备
    let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
    
    //  将捕获到的视频输出到文件
    let fileOut = AVCaptureMovieFileOutput()
    //  录制时间Timer
    var timer: Timer?
    var totalDuration = 0.0
    //  表示当时是否在录像中
    var isRecording = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        isHiddenNavigaBar = true
    }
    public func setupAVFoundationSettings() {
  
        camera = cameraWithPosition(position: AVCaptureDevice.Position.back)
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        if let camera = camera, let videoInput = try? AVCaptureDeviceInput(device: camera) {
            captureSession.addInput(videoInput)
        }
    
        if self.mediaType == .camera {
            captureSession.addOutput(stillImageOutput)
        } else {
            //  添加音频输出
            if audioDevice != nil,
                let audioInput = try? AVCaptureDeviceInput(device: audioDevice!) {
                captureSession.addInput(audioInput)
            }
            captureSession.addOutput(fileOut)
        }
        
        let videoLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        videoLayer.frame = view.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(videoLayer)
        
        previewLayer = videoLayer
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    public func changeMediaType(mediaType: TGMediaType = .camera) {
        // 在此方法中，根据传入的 mediaType 来做相应的操作
        if mediaType == .camera {
            // 切换为拍照模式
            if captureSession.outputs.contains(fileOut) {
                captureSession.removeOutput(fileOut)
            }
            if !captureSession.outputs.contains(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
            
        } else if mediaType == .miniVideo {
            // 切换为录制视频模式
            if captureSession.outputs.contains(stillImageOutput) {
                captureSession.removeOutput(stillImageOutput)
            }
            if !captureSession.outputs.contains(fileOut) {
                captureSession.addOutput(fileOut)
            }
        }
    }
    // MARK: - 开始录制
    public func startRecord() {
        if !isRecording {
            //  开启计时器
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(videoRecordingTotolTime), userInfo: nil, repeats: true)
            //  记录状态： 录像中 ...
            self.videoButtonsContainer.recordButton.startRecordingAnimation()
            self.videoButtonsContainer.enterRecordingState()
            isRecording = true
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
            //  设置录像保存地址
            let documentDirectory =  FileUtils.getDocumentsDirectory()
            let filePath = FileUtils.videoRecordCachePath()
            let fileUrl: URL? = URL(fileURLWithPath: filePath)
            //  启动视频编码输出
            fileOut.startRecording(to: fileUrl!, recordingDelegate: self)
        }else{
            self.endRecord()
        }
        
    }
    // MARK: - 结束录制
    public func endRecord() {
        //  关闭计时器
        timer?.invalidate()
        timer = nil
        totalDuration = 0
        self.videoButtonsContainer.recordButton.endRecordingAnimation()
        self.videoButtonsContainer.exitRecordingState()
        if isRecording {
            //  停止视频编码输出
            captureSession.stopRunning()
            
            //  记录状态： 录像结束 ...
            isRecording = false
        }
    }
    // MARK: - 结束录制
    public func stopRecord() {
        //  关闭计时器
        timer?.invalidate()
        timer = nil
        totalDuration = 0
        
        if isRecording {
            //  停止录制
            fileOut.stopRecording()
            
            //  记录状态： 录像结束 ...
            isRecording = false
        }
    }
    //闪光灯按钮点击事件
    public func flashOpen() {
        guard let device = camera else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = device.torchMode == .on ? .off : .on
                device.unlockForConfiguration()
            } catch {
                print("Error toggling flash: \(error)")
            }
        }
    }
    //切换摄像头
    func flipCamera() {
   
        self.isFront = !self.isFront
        //  首先移除所有的 input
        if let  allInputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in allInputs {
                captureSession.removeInput(input)

            }
        }
        changeCameraAnimate()
        if self.mediaType == .miniVideo {
            //  添加音频输出
            if audioDevice != nil,
                let audioInput = try? AVCaptureDeviceInput(device: audioDevice!) {
                self.captureSession.addInput(audioInput)
            }
        }
     
        if self.isFront {
            camera = cameraWithPosition(position: .front)
            if let input = try? AVCaptureDeviceInput(device: camera!) {
                captureSession.addInput(input)
            }
            
        } else {
            camera = cameraWithPosition(position: .back)
            if let input = try? AVCaptureDeviceInput(device: camera!) {
                captureSession.addInput(input)
            }
        }
    }
    
    public func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        // 使用 AVCaptureDeviceDiscoverySession 查找设备
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera], // 设备类型（广角摄像头）
            mediaType: .video,                     // 媒体类型（视频）
            position: .unspecified                 // 查找所有位置的摄像头
        )
        
        // 遍历设备，找到匹配的摄像头位置
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    // MARK: - 切换动画
    public func changeCameraAnimate() {
        let changeAnimate = CATransition()
        changeAnimate.delegate = self
        changeAnimate.duration = 0.4
        changeAnimate.type = CATransitionType(rawValue: "oglFlip")
        changeAnimate.subtype = CATransitionSubtype.fromRight
        previewLayer.add(changeAnimate, forKey: "changeAnimate")
    }
}
extension TGBaseCameraViewController {
    // MARK: - 录制时间
    @objc private func videoRecordingTotolTime() {
        totalDuration += 1
        
        let progress = totalDuration / self.videoButtonsContainer.maxDuration
        self.videoButtonsContainer.progressBar.progress = Float(progress)
        self.videoButtonsContainer.editStackView.isHidden = !self.videoButtonsContainer.progressBar.hasProgress

        //  判断是否录制超时
        if totalDuration >= self.videoButtonsContainer.maxDuration {
            timer?.invalidate()
            self.videoButtonsContainer.recordButton.endRecordingAnimation()
            self.endRecord()
        }
        self.videoButtonsContainer.videoDurationLabel.text = TimeInterval(totalDuration).toFormat()
    }
}
// MARK: - CAAnimationDelegate
extension TGBaseCameraViewController: CAAnimationDelegate {
    /// 动画开始
    public func animationDidStart(_ anim: CAAnimation) {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    /// 动画结束
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension TGBaseCameraViewController: AVCaptureFileOutputRecordingDelegate {
    /// 开始录制
    public func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
    }
    
    /// 结束录制
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        let avAsset = AVURLAsset(url: outputFileURL)
        let coverImage = FileUtils.generateAVAssetVideoCoverImage(avAsset: avAsset)
        self.delegate?.finishRecordingTo(outputFileURL: outputFileURL)
    }
}
