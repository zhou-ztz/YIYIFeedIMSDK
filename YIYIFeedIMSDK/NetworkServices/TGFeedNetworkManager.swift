//
//  TGFeedNetworkManager.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/29.
//

import UIKit

class TGFeedNetworkManager: NSObject {
    static let shared = TGFeedNetworkManager()
    private override init() {}
    
    /// 获取动态详情
      /// - Parameters:
      ///   - feedId: Feed ID
      ///   - completion: 回调，返回动态详情模型
    func fetchFeedDetailInfo(with feedId: String, completion: @escaping (TGFeedResponse?, Error?) -> Void) {
     
        let path = "/api/v2/feeds/\(feedId)"
        TGNetworkManager.shared.request(
              urlPath: path,
              method: .GET,
              params: nil,
              headers: nil
          ) { data, _, error in
              guard let data = data, error == nil else {
                  completion(nil, error)
                  return
              }
              do {
                  let decoder = JSONDecoder()
                  let feedResponse = try decoder.decode(TGFeedResponse.self, from: data)
                  DispatchQueue.main.async {
                      completion(feedResponse, nil)
                  }
              } catch {
                  // 解析失败，返回错误
                  DispatchQueue.main.async {
                      completion(nil, error)
                  }
              }
       
          }
      }

}
