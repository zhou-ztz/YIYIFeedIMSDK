//
//  AuthorizeStatusUtils.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司 on 2024/1/11.
//

import Foundation
import UIKit
import Photos

enum SCPermissionType {
    case album
    case camera
    case cameraAlbum
    case audio
    case videoCall
    case location
    case contacts
}
class AuthorizeStatusUtils {
    
    /// 检查App权限,提示弹窗在方法内处理
    class func showPermissionAlert(title: String = "", message: String = "", viewController: UIViewController?) {
      
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "设置", style: UIAlertAction.Style.default, handler: { action in
                let url = URL(string: UIApplication.openSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil))
            
            guard let viewController = viewController else {
                return
            }
            
            viewController.present(alert, animated: true, completion: nil)
        
    }
    
    
    class func checkAuthorizeStatusByType(type: SCPermissionType, viewController: UIViewController?, completion: @escaping EmptyClosure) {
        let photoStatus = PHPhotoLibrary.authorizationStatus()
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        let audioStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        let locationStatus = CLLocationManager.authorizationStatus()
     
        
        switch type {
        case .album:
            if photoStatus == .notDetermined {
                PHPhotoLibrary.requestAuthorization({ (newState) in
                    if #available(iOS 14, *) {
                        guard newState == .authorized || newState == .limited else {
                            return
                        }
                    } else {
                        guard newState == .authorized else {
                            return
                        }
                    }
                    
                    completion()
                })
                return
            }
            
            switch photoStatus {
            case .denied, .restricted:
                // 2.取消了授权
                showPermissionAlert(title: "相册权限设置" , message: "请允许读写相册访问权限", viewController: viewController)
            case .notDetermined:
                break
            case .authorized, .limited:
                completion()
            default: break
            }
            break
        case .camera:
            if cameraStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                    guard granted == true else {
                        return
                    }
                    completion()
                })
                return
            }
            
            switch cameraStatus {
            case .denied, .restricted:
                // 2.取消了授权
                showPermissionAlert(title:  "相机权限设置", message:  "请启用以访问您的相机", viewController: viewController)
            case .notDetermined:
                break
            case .authorized:
                completion()
            default: break
            }
            break
        case .cameraAlbum:
            if cameraStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                    PHPhotoLibrary.requestAuthorization({ (newState) in
                        if #available(iOS 14, *) {
                            if newState == .authorized || newState == .limited && granted {
                                completion()
                            }
                        } else {
                            if newState == .authorized && granted {
                                completion()
                            }
                        }
                    })
                })
            }
            
            switch cameraStatus {
            case .denied, .restricted:
                // 2.取消了授权
                showPermissionAlert(title:  "相机权限设置", message:  "请启用以访问您的相机", viewController: viewController)
            case .notDetermined:
                break
            case .authorized:
                if photoStatus == .notDetermined {
                    PHPhotoLibrary.requestAuthorization({ (newState) in
                        if #available(iOS 14, *) {
                            guard newState == .authorized || newState == .limited else {
                                return
                            }
                        } else {
                            guard newState == .authorized else {
                                return
                            }
                        }
                        
                        completion()
                    })
                    return
                }
                
                switch photoStatus {
                case .denied, .restricted:
                    // 2.取消了授权
                    showPermissionAlert(title:  "保存失败,没有相册权限", message:  "请允许读写相册访问权限", viewController: viewController)
                case .notDetermined:
                    break
                case .authorized, .limited:
                    completion()
                default: break
                }
            default: break
            }
            break
        case .audio:
            if audioStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (granted) in
                    guard granted == true else {
                        return
                    }
                    completion()
                })
                return
            }
            
            switch audioStatus {
            case .denied, .restricted:
                // 2.取消了授权
                showPermissionAlert(title: "麦克风权限设置", message: "请允许麦克风访问权限" , viewController: viewController)
            case .notDetermined:
                break
            case .authorized:
                completion()
            default: break
            }
            break
        case .videoCall:
            if cameraStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (cameraGranted) in
                    AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (audioGranted) in
                        if audioGranted && cameraGranted {
                            completion()
                        }
                    })
                })
            }
            
            switch cameraStatus {
            case .denied, .restricted:
                // 2.取消了授权
                showPermissionAlert(title: "相机权限设置", message: "请启用以访问您的相机", viewController: viewController)
            case .notDetermined:
                break
            case .authorized:
                if audioStatus == .notDetermined {
                    AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (granted) in
                        guard granted == true else {
                            return
                        }
                        completion()
                    })
                    return
                }
                
                switch audioStatus {
                case .denied, .restricted:
                    // 2.取消了授权
                    showPermissionAlert(title: "麦克风权限设置", message: "请允许麦克风访问权限", viewController: viewController)
                case .notDetermined:
                    break
                case .authorized:
                    completion()
                @unknown default:
                    break
                }
            default: break
            }
            break
     
        default:
            break
        }
    }
}
