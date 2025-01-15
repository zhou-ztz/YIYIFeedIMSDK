//
//  TGDownloadNetworkNanger.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/8.
//

import UIKit
import Foundation

class TGDownloadNetworkNanger {
    static let share = TGDownloadNetworkNanger()
    private init() {
    }
    
    func getFinalUrl(for url: String, completion: ((_ url: String) -> Void)? = nil) {
        
        guard let url = URL(string: url) else {
            completion?("")
            return
        }
        
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10)
        
        request.httpMethod = "HEAD"
        URLSession.shared
            .dataTask(with: request) { (data, response, error) in
                guard let urlResponse: URLResponse? = response else {
                    completion?("")
                    return
                }
                completion?((urlResponse?.url?.absoluteString).orEmpty)
            }.resume()
    }

}
