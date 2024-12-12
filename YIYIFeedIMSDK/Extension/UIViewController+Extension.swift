//
//  UIViewController+Extension.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司 on 2024/1/5.
//

import Foundation
import UIKit
import Photos

typealias EmptyClosure = () -> Void


extension UIViewController {
    
    
    /// 打开照相机视图
    /// - Parameters:
    ///   - enableMultiplePhoto: 是否多图
    ///   - selectedAssets: 已选图片资源数组Assets
    ///   - selectedImages:已选图片资源数组UIIMage
    ///   - allowEdit: 是否编辑
    ///   - onSelectPhoto: 返回选中图片
    ///   - onDismiss: 关闭页面
//    @objc func showCameraVC(_ enableMultiplePhoto: Bool = false,
//                            selectedAssets: [PHAsset] = [],
//                            selectedImages: [Any] = [],
//                            allowEdit: Bool = false,
//                            onSelectPhoto: CameraHandler? = nil,
//                            onDismiss: EmptyClosure? = nil) {
//        DispatchQueue.main.async {
//            let camera = CameraViewController()
//            camera.enableMultiplePhoto = enableMultiplePhoto
//            camera.selectedAsset = selectedAssets
//            camera.selectedImage = selectedImages
//            camera.onSelectPhoto = onSelectPhoto
//            camera.onDismiss = onDismiss
//            camera.allowEdit = allowEdit
//            let nav = SCNavigationController(rootViewController: camera).fullScreenRepresentation
//            self.present(nav, animated: true)
//        }
//    }
//    
//    /// 打开小视频录制
//    /// - Parameter onSelectVideo:
//    @objc func showMiniVideoRecorder(onSelectVideo: MiniVideoRecorderHandler? = nil) {
//        DispatchQueue.main.async {
//            let videoVC = MiniVideoRecorderViewController()
//            let nav = SCNavigationController(rootViewController: videoVC)
//            videoVC.onSelectMiniVideo = onSelectVideo
//            self.present(nav.fullScreenRepresentation, animated: true, completion: nil)
//        }
//    }
    
    /// 弹出确认框
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 内容
    ///   - buttonTitle: 确认按钮内容
    ///   - defaultAction: 确认按钮点击事件
    ///   - cancelTitle: 取消按钮内容
    ///   - cancelAction: 取消按钮点击事件
    func showAlert(title: String? = nil, message: String, buttonTitle: String, defaultAction: @escaping ((UIAlertAction) -> Void), cancelTitle: String? = nil, cancelAction: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: defaultAction))
        
        if let canceltitle = cancelTitle {
            alert.addAction(UIAlertAction(title: canceltitle, style: .cancel, handler: cancelAction))
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
