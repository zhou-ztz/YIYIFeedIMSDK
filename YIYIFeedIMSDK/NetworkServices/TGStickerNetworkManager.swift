//
//  TGStickerNetworkManager.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2024/12/24.
//

import UIKit

class TGStickerNetworkManager: NSObject {
    ///预下载贴纸
    class func getStickerListV2(userId: String, completion: @escaping ((Bool) -> ())) {
        let path = "api/v2/user-sticker-list"
        let parameter = ["user_id": userId]
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: parameter,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(UserBundleData.self, from: data)
                let bundles = response.data
                let reversedBundles = bundles.reversed()
                let stickerManager = StickerManager.shared
                let group = DispatchGroup()
                
                reversedBundles.forEach({ (bundle) in
                    if stickerManager.isBundleDownloaded("\(bundle.bundleID)") == false {
                        group.enter()
                        stickerManager.downloadSticker(for: "\(bundle.bundleID)") {
                            group.leave()
                        } onError: { _ in
                            group.leave()
                            completion(false)
                        }
                    }
                })
                
                // save the bundle again with the correct order
                group.notify(queue: DispatchQueue.global()) {
                    var bundlesToStore = [Dictionary<String, String>]()
                    reversedBundles.forEach { (bundle) in
                        var bundleDictionary = Dictionary<String, String>()
                        bundleDictionary["bundle_id"] = "\(bundle.bundleID)"
                        bundleDictionary["bundle_icon"] = bundle.bundleIcon
                        bundleDictionary["bundle_name"] = bundle.bundleName
                        bundleDictionary["uid"] = userId
                        bundleDictionary["userId"] = userId
                        bundlesToStore.append(bundleDictionary)
                    }
                    stickerManager.saveDownloadedStickerBundle(bundlesToStore)
                    completion(true)
                }
                
            } catch {
                // 解析失败，返回错误
                completion(false)
                print("catch error = \(error)")
            }
            
        }
        
    }
}
