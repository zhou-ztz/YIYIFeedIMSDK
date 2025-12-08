//
//  TGUploadNetworkManager.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/16.
//

import Foundation
import OBS

class TGUploadNetworkManager {
    
    /// 默认图片压缩后最大物理体积200kb
    fileprivate static let postImageMaxSizeKb: CGFloat = 200
  

    // 文件上传华为OBS
    func uploadFileToOBS(fileDatas: [Data], isImage: Bool = true, videoSize: CGSize = .zero, progressHandler: ((Progress) -> Void)? = nil, complete: @escaping (_ fileIds: [Int]) -> Void){
        ///获取obs key
        getTemporaryKey { model, message, isLocal in
            if let access = model?.access, let secret = model?.secret, let securitytoken = model?.securityToken, let expirestimestamp = model?.expiresAtTimestamp {
                if !isLocal {
                    let dict: [String: Any] = ["access": access, "secret": secret, "securitytoken": securitytoken, "expirestimestamp": expirestimestamp]
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                        OBSHelper.shared.setOBSKey(data: jsonData)
                    } catch {
                        print("Error converting dictionary to JSON data: \(error)")
                    }
                }
                //aes 解密
                let deAccess = OBSHelper.shared.aesDecrypt(value: access)
                let desSecret = OBSHelper.shared.aesDecrypt(value: secret)
                ///初始化OBS
                OBSManager.shared.initializeOBS(accessKey: deAccess, secretKey: desSecret, securityToken: securitytoken)
                ///检查文件hash
                self.checkHash(datas: fileDatas) { models, datas  in
                    guard let datas = datas else {
                        complete([])
                        return
                    }
                    
                    var fileList: [[String: Any]] = []

                    let group = DispatchGroup()
                    var isUploadAll = true
                    for model in datas {
                        guard let data = model.data, let filePath = self.savePhotoToSandbox(data: data) else {
                            return
                        }
                        
                        let hash = TGUtil.md5(data)
                        let date = Date()
                        let dateStr = date.string(format: "YYYY/MM/dd/HHmm", timeZone: nil)
                        let objectKey = dateStr + "/" + UUID().uuidString + self.randomHex4Digits() + (isImage ? ".jpg" : ".mp4")
                        print("objectKey = \(objectKey)")
                        var dict: [String: Any] = ["hash": hash, "object_key": objectKey, "mime": (isImage ? "image/jpeg" : "video/mp4"), "width": "", "height": ""]
                        let filePath1 = filePath.replacingOccurrences(of: "file:///", with: "", options: NSString.CompareOptions.literal, range: nil)
                        if isImage{
                            if let image = UIImage(contentsOfFile: filePath1)  {
                                dict["width"] = "\(Int(image.size.width))"
                                dict["height"] = "\(Int(image.size.height))"
                            }
                        } else {
                            dict["width"] = "\(Int(videoSize.width))"
                            dict["height"] = "\(Int(videoSize.height))"
                        }
                        fileList.append(dict)
                        let request = OBSUploadFileRequest(bucketName: "yippi-social", objectKey: objectKey, uploadFilePath: filePath1)
                        // 分段大小为5MB
                        request?.partSize = NSNumber(integerLiteral: 5 * 1024 * 1024)
                        // 开启断点续传模式
                        request?.enableCheckpoint = true
                        // 指定checkpoint文件路径
                        request?.checkpointFilePath = ""
                        // 开启MD5校验
                        request?.enableMD5Check = true
                        // 访问策略
                        request?.objectACLPolicy = .publicRead
                        //contentType
                        request?.contentType = (isImage ? OBSContentType.JPEG : OBSContentType.MP4)
                        
                        request?.uploadProgressBlock = { [weak self]  bytesSent, totalBytesSent, totalBytesExpectedToSend in
                            guard let self = self else { return  }
                            let progress = floor(Double(totalBytesSent * 10000 / totalBytesExpectedToSend)) / 100
                            if !isImage {
                                let spro = Progress(totalUnitCount: totalBytesSent * 10000)
                                spro.completedUnitCount = totalBytesExpectedToSend
                                progressHandler?(spro)
                            }
                            print(String(format: "%.1f%%", progress))
                        }
                        group.enter()
                        DispatchQueue.global(qos: .background).async {
                            
                            let task = OBSManager.shared.client?.uploadFile(request) { [weak self] response, error in
                                guard let self = self else { return  }
                                if let error = error {
                                    // 再次上传
                                    print("OBS uploadFile-error == \(error)")
                                    isUploadAll = false
                                }else{
                                    if isImage {
                                        let spro = Progress(totalUnitCount: 1)
                                        spro.completedUnitCount = 1
                                        progressHandler?(spro)
                                    }
                                    print("OBS response == \(String(describing: response))")
                                    
                                }
                                group.leave()
                            }
                            
                            
                            
                        }
                        
                    }
                    
                    group.notify(queue: DispatchQueue.main){
                        //如果有图片上传失败，重新发布
                        if !isUploadAll  {
                            complete([])
                            return
                        }

                        var fieldIDs = [Int]()
                        if let models = models {
                            for model in models {
                                fieldIDs.append(model.existId)
                            }
                        }
                         
                        if fileList.isEmpty {
                            complete(fieldIDs)
                            return
                        }
                        
                        self.uploadFileSaveFile(for: fileList) { response, msg, status in
                            guard let response = response else {
                                complete([])
                                return
                            }
                            if let resultDatas = response.data {
                                
                                for resultData in resultDatas {
                                    fieldIDs.append(resultData.id ?? 0)
                                }
                                print("result===\(resultDatas)")
                                complete(fieldIDs)
                            }
                        }
                        
                    }
                    
                }
                
                
                
            }else {
                complete([])
            }
            
        }
       
     
    }
    
    func randomHex4Digits() -> String {
        let randomValue = Int.random(in: 0...65535)
        return String(format: "%04X", randomValue)
    }
    
    // 图片视频保存本地
    func savePhotoToSandbox(data: Data, isImage: Bool = true) -> String? {
       
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = documentsDirectory.appendingPathComponent("obsfile")

        var fileName = ""
        if isImage{
            fileName = "\(UUID().uuidString).jpg"
        }else {
            fileName = "\(UUID().uuidString).mp4"
        }
        
        if fileManager.fileExists(atPath: path.relativePath) == false {
            try! fileManager.createDirectory(atPath: path.relativePath, withIntermediateDirectories: true, attributes: nil)
        }
        let fileURL = path.appendingPathComponent(fileName)
        print("filepath = \(fileURL.absoluteString)")
        do {
            try data.write(to: fileURL)
            return fileURL.absoluteString
        } catch {
            return nil
        }
    }
    
    private func checkHash(datas: [Data], complete: @escaping (_ models: [UploadOBSModel]?, _ uploadDatas: [UploadOBSModel]?) -> Void){
        var hashs: [[String: Any]] = []
        var models: [UploadOBSModel] = []
        
        for data in datas {
            let hash = TGUtil.md5(data)
            let dict =  ["hash": hash]
            hashs.append(dict)
            let model = UploadOBSModel()
            model.data = data
            model.hashStr = hash
            models.append(model)
            
        }
        
//        var request = UploadFileCheckHashRequestType()
//        request.list = hashs
//        request.execute { [weak self] result in
//            var uploadDatas: [Data] = []
//            if let resultDatas = result?.data {
//                
//                var existLists: [UploadOBSModel] = []
//                
//                for resultData in resultDatas {
//                    if resultData.exists == true {
//                        let model = UploadOBSModel()
//                        model.existId = resultData.id ?? 0
//                        model.hashStr = resultData.hash ?? ""
//                        existLists.append(model)
//                        
//                        if let index = models.firstIndex(where: { uploadModel in
//                            uploadModel.hashStr == resultData.hash
//                        }){
//                            models.remove(at: index)
//                        }
//                    }
//                }
//               
//                complete(existLists, models)
//            }else {
//                
//                complete(nil, models)
//            }
//        } onError: { error in
//            complete(nil, nil)
//        }
        self.uploadFileCheckHash(for: hashs) { response, msg, status in
            guard let response = response else {
                complete(nil, models)
                return
            }
            if let resultDatas = response.data {
                
                var existLists: [UploadOBSModel] = []
                
                for resultData in resultDatas {
                    if resultData.exists == true {
                        let model = UploadOBSModel()
                        model.existId = resultData.id ?? 0
                        model.hashStr = resultData.hash ?? ""
                        existLists.append(model)
                        
                        if let index = models.firstIndex(where: { uploadModel in
                            uploadModel.hashStr == resultData.hash
                        }){
                            models.remove(at: index)
                        }
                    }
                }
                
                complete(existLists, models)
            }else {
                
                complete(nil, models)
            }
        }

    }
    ///获取 OBS  AK , SK
    private func getTemporaryKey(complete: @escaping (_ model: TemporaryKey?, _ message: String?, _ isLocal: Bool) -> Void){
   
        let timeStamp = Date().timeIntervalSince1970
        if let data = OBSHelper.shared.getOBSKey(), let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let expirestimestamp = dict["expirestimestamp"] as? String, let access = dict["access"] as? String, let secret = dict["secret"] as? String, let securitytoken = dict["securitytoken"] as? String, (TimeInterval(expirestimestamp) ?? 0.0) > (timeStamp + 60)  {
            
            let model = TemporaryKey(expiresAt: "", secret: secret, access: access, securityToken: securitytoken, expiresAtTimestamp: expirestimestamp)
            complete(model, nil, true)
        }else{
            self.uploadFileTemporaryKey { response, msg, status in
                guard let response = response else {
                    complete(nil, nil, false)
                    return
                }
                if let model = response.data {
                    complete(model, nil, false)
                }else{
                    complete(nil, nil, false)
                }
            }
        }

    }
    
    func uploadFileCheckHash(for list: [[String: Any]], complete: @escaping ((_ response: CheckHashDataResponse?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        
        let path = "/api/v2/files/segments_uploaded/check-hash"
        
        var params: [String: Any] = [String: Any]()
        params.updateValue(list, forKey: "hash_list")
   
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: params,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                complete(nil, "network_problem".localized, false)
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(CheckHashDataResponse.self, from: data)
                DispatchQueue.main.async {
                    complete(response, response.message,  true)
                }
            } catch {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    complete(nil, "error_data_server_return".localized, false)
                }
            }
            
        }
    }

    
    func uploadFileSaveFile(for list: [[String: Any]], complete: @escaping ((_ response: CheckHashDataResponse?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        
        let path = "api/v2/files/segments_uploaded/save-file"
        
        var params: [String: Any] = [String: Any]()
        params.updateValue(list, forKey: "file_list")
   
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .POST,
            params: params,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                complete(nil, "network_problem".localized, false)
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(CheckHashDataResponse.self, from: data)
                DispatchQueue.main.async {
                    complete(response, response.message,  true)
                }
            } catch {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    complete(nil, "error_data_server_return".localized, false)
                }
            }
            
        }
    }
    
    
    func uploadFileTemporaryKey(complete: @escaping ((_ response: TemporaryKeyResponse?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        
        let path = "api/v2/files/segments_uploaded/get_temporary_key"
        
        TGNetworkManager.shared.request(
            urlPath: path,
            method: .GET,
            params: nil,
            headers: nil
        ) { data, _, error in
            guard let data = data, error == nil else {
                complete(nil, "network_problem".localized, false)
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(TemporaryKeyResponse.self, from: data)
                DispatchQueue.main.async {
                    complete(response, response.message,  true)
                }
            } catch {
                // 解析失败，返回错误
                DispatchQueue.main.async {
                    complete(nil, "error_data_server_return".localized, false)
                }
            }
            
        }
    }
    
}

struct CheckHashDataResponse: Decodable {
    let data: [CheckHashResponse]?
    let message: String?
    enum CodingKeys: String, CodingKey {
        case data = "data"
        case message = "message"
    }
}

struct CheckHashResponse: Decodable {
    let exists: Bool?
    let id: Int?
    let hash: String?
    let saved: Bool?
    
    enum CodingKeys: String, CodingKey {
        case exists = "exists"
        case id = "id"
        case hash
        case saved
    }
}


class UploadOBSModel: NSObject {
    var hashStr: String = ""
    var existId: Int = 0
    var objectKey: String = ""
    var data: Data?
}
struct TemporaryKeyResponse: Codable {
    let data: TemporaryKey?
    let message: String?
    enum CodingKeys: String, CodingKey {
        case data = "data"
        case message = "message"
    }
}

struct TemporaryKey: Codable {
    let expiresAt: String?
    let secret: String?
    let access: String?
    let securityToken: String?
    let expiresAtTimestamp: String?
    
    enum CodingKeys: String, CodingKey {
        case expiresAt = "expires_at"
        case expiresAtTimestamp = "expires_at_timestamp"
        case secret, access
        case securityToken = "security_token"
    }
}
