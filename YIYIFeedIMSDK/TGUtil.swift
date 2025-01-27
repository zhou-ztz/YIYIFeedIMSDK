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
    class func generateMatchingUserIDs(tagUsers: [UserInfoModel], atStrings: [String]) -> [Int] {
        
        var matchingUserIDs = Set<Int>()
        
        for atString in atStrings {
            if let matchedUser = tagUsers.first(where: { $0.name.removingSpecialCharacters() == atString.removingSpecialCharacters() }) {
                matchingUserIDs.insert(matchedUser.id.intValue)  // Insert into set, duplicates are automatically handled
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
}
