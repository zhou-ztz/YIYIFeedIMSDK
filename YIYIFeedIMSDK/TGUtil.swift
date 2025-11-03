//
//  TGUtil.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2024/12/25.
//

import Foundation
import CommonCrypto
import Contacts

enum TGPermissionType {
    case album
    case camera
    case cameraAlbum
    case audio
    case videoCall
    case location
    case contacts
}

enum TGPermissionStatus {
    case notDetermined
    case limited
    case authorized
    case firstDenied
    case denied
}

class TGUtil {
    
    
    class func findAllTSAt(inputStr: String) -> Array<NSTextCheckingResult> {
        let regx = try? NSRegularExpression(pattern: "\\u00ad(?:@[^/]+?)\\u00ad", options: NSRegularExpression.Options.caseInsensitive)
        //var strLength : Int = inputStr.endIndex.encodedOffset >= inputStr.count ? inputStr.count : inputStr.endIndex.encodedOffset
        return regx!.matches(in: inputStr, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSRange(inputStr.startIndex..., in: inputStr))
    }
    
    class func findAllHashtag(inputStr: String) -> Array<NSTextCheckingResult> {
        let reg = "(?<=^|\\s|$)#[\\p{L}\\p{Nd}_\\p{P}\\p{Emoji}]*"
        let regx = try? NSRegularExpression(pattern: reg, options: .caseInsensitive)
        
        return regx!.matches(in: inputStr, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSRange(inputStr.startIndex..., in: inputStr))
    }
    //动态根据tagUsers获取ids
    class func generateMatchingUserIDs(tagUsers: [TGUserInfoModel], atStrings: [String]) -> [Int] {
        
        var matchingUserIDs = Set<Int>()
        
        for atString in atStrings {
            if let matchedUser = tagUsers.first(where: { $0.name.removingSpecialCharacters() == atString.removingSpecialCharacters() }) {
                matchingUserIDs.insert(matchedUser.id.intValue)  // Insert into set, duplicates are automatically handled
            }
        }
        
        return Array(matchingUserIDs)
    }
    class func generateMatchingMerchantIDs(tagUsers: [TGTaggedBranchData], atStrings: [String]) -> [Int] {
        
        var matchingUserIDs = Set<Int>()
        
        for atString in atStrings {
            if let matchedUser = tagUsers.first(where: { $0.branchName?.removingSpecialCharacters() == atString.removingSpecialCharacters() }) {
                matchingUserIDs.insert(matchedUser.miniProgramBranchID ?? 0)  // Insert into set, duplicates are automatically handled
            }
        }
        
        return Array(matchingUserIDs)
    }
    //获取发布动态content里面所有的userIds
    class func findTSAtStrings(inputStr: String) -> [String] {
        let regx = try? NSRegularExpression(pattern: "@[^<]+?(?=</a>)", options: .caseInsensitive)
        let matches = regx!.matches(in: inputStr, options: [], range: NSRange(location: 0, length: inputStr.utf16.count))

        var atStrings = [String]()

        for match in matches {
            let range = match.range
            if let swiftRange = Range(range, in: inputStr) {
                let atString = String(inputStr[swiftRange])
                atStrings.append(atString)
            }
        }

        return atStrings
    }
    
    //获取发布动态content里面所有的HashtagString
    class func findAllHashtagStrings(inputStr: String) -> [String] {
        let regx = try? NSRegularExpression(pattern: "(?<=^|\\s|$)#[\\p{L}\\p{Nd}_\\p{P}\\p{Emoji}]*", options: .caseInsensitive)
        let matches = regx!.matches(in: inputStr, options: [], range: NSRange(location: 0, length: inputStr.utf16.count))

        var atStrings = [String]()

        for match in matches {
            let range = match.range
            if let swiftRange = Range(range, in: inputStr) {
                let atString = String(inputStr[swiftRange])
                atStrings.append(atString)
            }
        }

        return atStrings
    }
    public class func md5(_ data: Data) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        data.withUnsafeBytes {
            CC_MD5($0.baseAddress, UInt32(data.count), &digest)
        }
        return digest.map { String(format:"%02x", $0) }.joined()
    }
    
    public class func deleteFile(atPath filePath: String) {
         let fileManager = FileManager.default
         
         // 判断文件是否存在
         if fileManager.fileExists(atPath: filePath) {
             do {
                 // 尝试删除文件
                 try fileManager.removeItem(atPath: filePath)
                 print("文件删除成功")
             } catch {
                 print("文件删除失败: \(error.localizedDescription)")
             }
         } else {
             print("文件不存在")
         }
     }
    /// 跳转到用户中心
    class func pushUserHomeName(name: String) {
//        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uname": name])
        RLSDKManager.shared.imDelegate?.didPressNameCard(memberId: name)
    }
    
    class func pushUserHomeId(uid: String) {
//        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": uid])
        RLSDKManager.shared.imDelegate?.didPressUerProfile(uid: uid.toInt())
    }
    
    class func checkAuthorizeStatusByType(type: TGPermissionType, isShowBottom: Bool = false, viewController: UIViewController?, completion: @escaping TGEmptyClosure) {
        let photoStatus = PHPhotoLibrary.authorizationStatus()
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        let audioStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        let locationStatus = CLLocationManager.authorizationStatus()
        let contactStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
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
                showPermissionAlert(title: isShowBottom ? "album_permission".localized : "rw_photos_limited_permission_fail".localized, message: isShowBottom ? "rw_album_permission_read_write".localized : "", isShowBottom: isShowBottom, viewController: viewController)
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
                showPermissionAlert(title: isShowBottom ? "camera_permission".localized : "rw_camera_limited_video_chat_fail".localized, message: isShowBottom ? "rw_camera_allow_permission".localized : "", isShowBottom: isShowBottom, viewController: viewController)
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
                showPermissionAlert(title: isShowBottom ? "camera_permission".localized : "rw_camera_limited_video_chat_fail".localized, message: isShowBottom ? "rw_camera_allow_permission".localized : "", isShowBottom: isShowBottom, viewController: viewController)
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
                    showPermissionAlert(title: isShowBottom ? "album_permission".localized : "rw_photos_limited_permission_fail".localized, message: isShowBottom ? "rw_album_permission_read_write".localized : "", isShowBottom: isShowBottom, viewController: viewController)
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
                showPermissionAlert(title: isShowBottom ? "microphone_permission".localized : "rw_audio_limited_video_chat_fail".localized, message: isShowBottom ? "mircrophone_permission".localized : "", isShowBottom: isShowBottom, viewController: viewController)
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
                showPermissionAlert(title: isShowBottom ? "camera_permission".localized : "rw_camera_limited_video_chat_fail".localized, message: isShowBottom ? "rw_camera_allow_permission".localized : "", isShowBottom: isShowBottom, viewController: viewController)
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
                    showPermissionAlert(title: isShowBottom ? "microphone_permission".localized : "rw_audio_limited_video_chat_fail".localized, message: isShowBottom ? "mircrophone_permission".localized : "", isShowBottom: isShowBottom, viewController: viewController)
                case .notDetermined:
                    break
                case .authorized:
                    completion()
                }
            default: break
            }
            break
        case .location:
            if locationStatus == .notDetermined {
                TGLocationManager.shared.runLocationBlock {
                    completion()
                    return
                }
            }
            
            switch locationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                completion()
            case .denied, .restricted:
                showPermissionAlert(title: isShowBottom ? "location_permission".localized : "rw_location_limited_permission_fail".localized, message: isShowBottom ? "rw_location_limited_permission_fail".localized : "", isShowBottom: isShowBottom, viewController: viewController)
            case .notDetermined:
                break
            }
            break
        case .contacts:
            if contactStatus == .notDetermined {
                CNContactStore().requestAccess(for: .contacts, completionHandler: { (access, accessError) -> Void in
                    guard access == true else {
                        return
                    }
                    completion()
                })
                return
            }
            
            switch contactStatus {
            case .denied, .restricted:
                // 2.取消了授权
                showPermissionAlert(title: isShowBottom ?  "contact_permission".localized :"rw_contacts_limited_permission_fail".localized, message: isShowBottom ? "rw_contacts_limited_permission_fail".localized : "", isShowBottom: isShowBottom, viewController: viewController)
                break
            case .notDetermined:
                break
            case .authorized:
                completion()
                break
            @unknown default:
                // Check for iOS 18 specific 'limited' status
//                if #available(iOS 18, *) {
//                    if contactStatus == .limited {
//                        completion()
//                    }
//                }
                break
            }
            break
        default:
            break
        }
    }
    
    /// 检查App权限,提示弹窗在方法内处理
    class func showPermissionAlert(title: String = "", message: String = "", isShowBottom: Bool = false, viewController: UIViewController?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "settings".localized, style: UIAlertAction.Style.default, handler: { action in
            let url = URL(string: UIApplication.openSettingsURLString)
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized, style: UIAlertAction.Style.cancel, handler: nil))
        
        guard let viewController = viewController else {
            return
        }
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
struct TGReleasePulseData {
    var privacyType: PrivacyType?
    var topics: [TGTopicCommonModel]?
    var location: TGLocationModel?
    var tagUsers: [TGUserInfoModel]?
    var tagMerchants: [TGTaggedBranchData]?
    var rewardsMerchantUsers: [TGRewardsLinkMerchantUserModel]?
}

extension TGUtil {
   
    class func extractReleasePulseData(from model: Any) -> TGReleasePulseData {
        var data = TGReleasePulseData()

        if let postModel = model as? TGPostModel {
            data.privacyType = PrivacyType(rawValue: postModel.privacy)
            
            if let topics = postModel.topics, let first = topics.first {
                let topic = TGTopicCommonModel()
                topic.id = first.id
                topic.name = first.name
                data.topics = [topic]
            }
            
            if let loc = postModel.taggedLocation {
                let location = TGLocationModel()
                location.locationID = loc.locationID
                location.locationName = loc.locationName
                location.locationLatitude = loc.locationLatitude
                location.locationLongtitude = loc.locationLongtitude
                location.address = loc.address ?? ""
                data.location = location
            }
            
            data.tagUsers = postModel.tagUsers
            data.tagMerchants = postModel.tagMerchants
        } else if let detailModel = model as? FeedListCellModel {
            data.privacyType = PrivacyType(rawValue: detailModel.privacy)
            
            if let first = detailModel.topics.first {
                let topic = TGTopicCommonModel()
                topic.id = first.topicId
                topic.name = first.topicTitle
                data.topics = [topic]
            }
            
            if let loc = detailModel.location {
                let location = TGLocationModel()
                location.locationID = loc.locationID
                location.locationName = loc.locationName
                location.locationLatitude = loc.locationLatitude
                location.locationLongtitude = loc.locationLongtitude
                location.address = loc.address ?? ""
                data.location = location
            }
            
            data.tagUsers = detailModel.tagUsers
            data.tagMerchants = detailModel.rewardsLinkMerchantUsers
            data.rewardsMerchantUsers = detailModel.rewardsMerchantUsers
        } else if let rejectDetailModel = model as? TGRejectDetailModel {
            if let privacy = rejectDetailModel.privacy {
                data.privacyType = PrivacyType(rawValue: privacy)
            }

            if let first = rejectDetailModel.topics.first {
                let topic = TGTopicCommonModel()
                topic.id = first.id
                topic.name = first.name ?? ""
                data.topics = [topic]
            }

            if let loc = rejectDetailModel.location {
                let location = TGLocationModel()
                location.locationID = loc.lid ?? ""
                location.locationName = loc.name ?? ""
                location.locationLatitude = loc.lat
                location.locationLongtitude = loc.lng
                location.address = loc.address ?? ""
                data.location = location
            }

            data.tagUsers = rejectDetailModel.tagUsers
            data.tagMerchants = rejectDetailModel.rewardsLinkMerchantUsers
        }

        return data
    }

    public class func configureReleasePulseViewController(model: Any, releasePulseVC: TGReleasePulseViewController) -> TGReleasePulseViewController {
        let data = TGUtil.extractReleasePulseData(from: model)
        releasePulseVC.rejectPrivacyType = data.privacyType
        releasePulseVC.topics = data.topics ?? []
        releasePulseVC.rejectLocation = data.location
        releasePulseVC.selectedUsers = data.tagUsers ?? []
        releasePulseVC.selectedMerchants = data.tagMerchants ?? []
        releasePulseVC.rewardsMerchantUsers = data.rewardsMerchantUsers ?? []
        
        return releasePulseVC
    }
}
