//
//  TGUtil.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2024/12/25.
//

import Foundation

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
    
}
