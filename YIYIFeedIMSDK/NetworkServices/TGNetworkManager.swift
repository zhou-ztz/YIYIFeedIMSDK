//
//  TGNetworkManager.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/28.
//

import Foundation
import Apollo

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

class TGNetworkManager {
    static let shared = TGNetworkManager()
    
    var baseUrl: String = RLSDKManager.shared.loginParma?.apiBaseURL ?? "https://preprod-api-rewardslink.getyippi.cn/"
    var defaultHeaders: [String: String] = {
        let accessToken = UserDefaults.standard.string(forKey: "TG_ACCESS_TOKEN") ?? ""
        return [
            "Authorization" : "Bearer \(accessToken)",
            "X-Client-App-Name": "rewards_link",
            "X-Client-Type": "iOS",
            "X-Device-Language": "zh-CN",
            "Accept": "application/json",
            "X-Client-Version": "2.0.4",
            "Content-Type": "application/json",
            "Accept-Language": "zh-CN"
        ]
    }()
    
    private init() {}
    
    func request(urlPath: String,
                 url: String? = nil,
                 method: HTTPMethod,
                 params: [String: Any]? = nil,
                 headers: [String: String]? = nil,
                 completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        // 构建完整 URL
        let fullUrl = (url ?? baseUrl) + urlPath
        guard let requestURL = URL(string: fullUrl) else {
            let error = NSError(domain: "TGNetworkManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(nil, nil, error)
            return
        }
        
        // 更新默认 Headers 中的 Token
        if let accessToken = UserDefaults.standard.string(forKey: "Authorization") {
            defaultHeaders["Authorization"] = "Bearer \(accessToken)"
        }
        
        // 合并 Headers
        var requestHeaders = defaultHeaders
        if let additionalHeaders = headers {
            requestHeaders.merge(additionalHeaders) { _, new in new }
        }
        
        // 构建请求
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        for (key, value) in requestHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // 设置请求体（仅 POST、PUT、DELETE 支持）
        if method != .GET, let params = params {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            } catch {
                completion(nil, nil, error)
                return
            }
        }
        
        // 发起请求
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                let noDataError = NSError(domain: "TGNetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                DispatchQueue.main.async {
                    completion(nil, response, noDataError)
                }
                return
            }
            
            // 检查响应并获取状态码
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                print("Status Code: \(statusCode)")
                
                if (200...299).contains(statusCode) {
                    print("Request was successful")
                } else {
                    print("Request failed with status code: \(statusCode)")
                }
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("response json = \(json)")
                    DispatchQueue.main.async {
                        completion(data, response, nil)
                    }
                    
                } else if let jsonArr = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
                    print("response jsonArr = \(jsonArr)")
                    DispatchQueue.main.async {
                        completion(data, response, nil)
                    }
                    
                } else {
                    throw NSError(domain: "TGNetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])
                }
            } catch {
                DispatchQueue.main.async {
                    completion(data, response, error)
                }
            }
        }
        dataTask.resume()
    }
}

var YPApolloClient: ApolloClient {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 20.0
    configuration.timeoutIntervalForResource = 20.0

    let headers = YPCustomHeaders
    configuration.httpAdditionalHeaders = headers
    let url = URL(string: (RLSDKManager.shared.loginParma?.apiBaseURL ?? "") + "graphql/v1")!
    
    return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
}

var YPCustomHeaders: [String: String] {
    return TGNetworkManager.shared.defaultHeaders
}
