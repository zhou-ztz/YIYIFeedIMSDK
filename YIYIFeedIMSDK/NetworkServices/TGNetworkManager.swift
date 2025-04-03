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
    case PATCH = "PATCH"
}

class TGNetworkManager {
    static let shared = TGNetworkManager()
    
    var baseUrl: String = RLSDKManager.shared.loginParma?.apiBaseURL ?? "https://preprod-api-rewardslink.getyippi.cn/"
    var defaultHeaders: [String: String] = {
        let accessToken = UserDefaults.standard.string(forKey: "TG_ACCESS_TOKEN") ?? ""
        return [
            "Authorization" : "Bearer \(accessToken)",
            "X-Client-App-Name": RLSDKManager.shared.loginParma?.appName ?? "rewards_link",
            "X-Client-Type": "iOS",
            "X-Device-Language": TGLocalizationManager.getCurrentLanguage(),
            "Accept": "application/json",
            "X-Client-Version": "2.1.8",
            "Content-Type": "application/json",
            "X-Device-OS": UIDevice.current.systemVersion,
            "IOS_DEVICE": "ios",
            "X-Device-Model": TGDevice.modelName,
            "Accept-Language": TGLocalizationManager.getCurrentLanguage(),
            "X-Device-Country": UserDefaults.standard.string(forKey: "selected-country-code") ?? "MY",
            "X-App-Favor": "ios"
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
        var fullUrl = (url ?? baseUrl) + urlPath
        
        if method == .GET, let params = params {
            var queryItems = [URLQueryItem]()
            for (key, value) in params {
                queryItems.append(URLQueryItem(name: key, value: "\(value)"))
            }
            var components = URLComponents(string: fullUrl)
            components?.queryItems = queryItems
            if let urlWithParams = components?.url {
                fullUrl = urlWithParams.absoluteString
            }
        }
        
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
                print("requestUrl: \(String(describing: request.url?.absoluteString))")
                print("params: \(String(describing: params))")
                print("httpBody: \(String(describing: request.httpBody))")
                
                if (200...299).contains(statusCode) {
                    print("Request was successful")
                    ///数据不需要解析
                    if  data.bytes.count == 0 {
                        completion(data, response, nil)
                        return
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
                    
                    
                } else {
                   
                    guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        let noDataError = NSError(domain: "TGNetworkManager", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                        DispatchQueue.main.async {
                            completion(nil, response, noDataError)
                        }
                        return
                    }
 
                    if let message = dictionary["message"] as? String, let code = dictionary["code"] as? Int {
                        let noDataError = NSError(domain: "TGNetworkManager", code: code, userInfo: [NSLocalizedDescriptionKey: message])
                        DispatchQueue.main.async {
                            completion(nil, response, noDataError)
                        }
                    } else if let message = dictionary["message"] as? String {
                        let noDataError = NSError(domain: "TGNetworkManager", code: statusCode, userInfo: [NSLocalizedDescriptionKey: message])
                        DispatchQueue.main.async {
                            completion(nil, response, noDataError)
                        }
                    } else if let code = dictionary["code"] as? Int {
                        let noDataError = NSError(domain: "TGNetworkManager", code: code, userInfo: [NSLocalizedDescriptionKey: ""])
                        DispatchQueue.main.async {
                            completion(nil, response, noDataError)
                        }
                    }
                    else {
                        let noDataError = NSError(domain: "TGNetworkManager", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                        DispatchQueue.main.async {
                            completion(nil, response, noDataError)
                        }
                    }
                    
                }
            } else {
                let noDataError = NSError(domain: "TGNetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                DispatchQueue.main.async {
                    completion(nil, response, noDataError)
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

enum ErrorCode: Int {
    case offTransactionException = 1
    case settingNotFoundException = 2
    case userVerifyException = 3
    case invalidTransactionException = 4
    case invalidPasswordException = 5
    case invalidAmountException = 6
    case invalidPhoneException = 7
    case customValidationException = 8
    case transactionFreezeException = 9
    case dailyLimitException = 10
    case loginFailedAttemptsException = 11
    case restrictionException = 12
    case otpWaitException = 13
    case otpVerifyException = 14
    case invalidSecurityPinException = 15
    case securityPinNotSetException = 16
    case pinIsLockedException = 17
    case suspiciousActivity = 18
    
    ///
    case transactionIdMissingException = 201
    case insufficientBalanceException = 202
    case aeropayException = 203
    case partnerFailException = 204
    case purchaseFailException = 205
    case invalidCountryException = 207
    case orderClaimedException = 208
    case rewardFinishException = 209
    case tipsException = 210
    case redPacketClaimException = 211
    case eggExpiredException = 212
    case liveEggCountingDownException = 213
    case userNotEligibleException = 214
    case userRewardFinishException = 215
    
    case socialTokenRedeemRefunded = 217
    case socialTokenRedeemReachedLimit = 218
    case socialTokenRedeemUserNotKYC = 219
    case socialTokenRedeemSoldOut = 220
    
    case objectNotFoundException = 404
    
    case socialAccountException = 452
    
    case timeoutException = 1001
    case signExpiredException = 1002
    case transactionRefIdExistsException = 1003
    
    //会议不存在或已结束
    case meetingEndOrInexistence = 1012
    //会议人数已满
    case meetingNumberLimit = 1013
}

