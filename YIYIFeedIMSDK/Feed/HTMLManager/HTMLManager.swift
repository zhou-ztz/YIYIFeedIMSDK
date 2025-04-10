//
//  HTMLManager.swift
//  Yippi
//
//  Created by Kit Foong on 15/01/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import UIKit
//import SwiftSoup

let TextViewBindingAttributeName = "TextViewBingDingFlagName"

class HTMLManager: NSObject {
    static let shared = HTMLManager()
    
    // MARK: Post
    func addUserIdToTagContent(userId: Int? = nil, userName: String) -> NSAttributedString {
        let spStr = String(data: ("\u{00ad}".data(using: String.Encoding.unicode))!, encoding: String.Encoding.unicode)
        var insertStr = spStr! + "@" + userName + spStr! + " "
        var userIdString = ""
        if let userId = userId {
            userIdString = userId.stringValue
        }

        let temp = NSAttributedString(string: insertStr, attributes: [NSAttributedString.Key.foregroundColor: RLColor.share.theme,
                                                                      NSAttributedString.Key.font: UIFont.systemFont(ofSize: RLFont.ContentText.text.rawValue),
                                                                      NSAttributedString.Key(rawValue: TextViewBindingAttributeName): userIdString])
        return temp
    }
    
    func addHashTagContent(hashTag: String) -> NSAttributedString {
        var insertStr = "#" + hashTag + " "
        let temp = NSAttributedString(string: insertStr, attributes: [NSAttributedString.Key.foregroundColor: RLColor.share.theme,
                                                                      NSAttributedString.Key.font: UIFont.systemFont(ofSize: RLFont.ContentText.text.rawValue)])
        return temp
    }
    
    func formHtmlString(_ attributedString: NSAttributedString) -> String {
        var formattedString = attributedString.string
        var oriList : [String] = []
        var updatedList : [String] = []
        var usernameList : [FeedHTMLModel] = []
        attributedString.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewBindingAttributeName),
                                            in:NSMakeRange(0, attributedString.length),
                                            options:.longestEffectiveRangeNotRequired) {
            value, range, stop in
            if let userId = value as? String {
                let username = attributedString.string.subString(with: range)
                usernameList.append(FeedHTMLModel(userId: userId, userName: username))
            }
        }
        
        attributedString.enumerateAttribute(.font,
                                            in:NSMakeRange(0, attributedString.length),
                                            options:.longestEffectiveRangeNotRequired) {
            value, range, stop in
            let temp = attributedString.string.subString(with: range)
            oriList.append(temp)
        }
        
        for item in oriList {
            var username : String = item
            if username != "\u{00ad}" {
                if let model = usernameList.first(where: { $0.userName == item }) {
                    username = self.formHtmlTag(userId: model.userId, userName: model.userName)
                }
                
                updatedList.append(username)
            }
        }
        
        formattedString = ""
        for item in updatedList {
            formattedString += item
        }
        return formattedString
    }
    
    func formHtmlTag(userId: String,  userName: String) -> String {
        let spStr = String(data: ("\u{00ad}".data(using: String.Encoding.unicode))!, encoding: String.Encoding.unicode)
        let baseUrl = RLSDKManager.shared.loginParma?.apiBaseURL ?? "https://preprod-api-rewardslink.getyippi.cn/"
        let htmlString = "\(spStr!)<a href=\"\(baseUrl)users/\(userId)\">\(userName.replacingOccurrences(of: "\u{00ad}", with: ""))</a>\(spStr!) "
        return htmlString
    }
    
    func formatTextViewAttributeText(_ textView: UITextView, completion: (() -> Void)? = nil) {
        let range = textView.selectedRange
        var userIdList : [String] = []
        
        if let attributedString = textView.attributedText {
            attributedString.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewBindingAttributeName),
                                                in:NSMakeRange(0, attributedString.length),
                                                options:.longestEffectiveRangeNotRequired) {
                value, range, stop in
                if let userId = value as? String {
                    userIdList.append(userId)
                }
            }
        }
        
        let attString = NSMutableAttributedString(string: textView.text)
        attString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], range: NSRange(location: 0, length: attString.length))
        attString.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: RLFont.ContentText.text.rawValue)], range:  NSRange(location: 0, length: attString.length))
        
        let matchs = TGUtil.findAllTSAt(inputStr: textView.text)
        
        for (index, item) in matchs.enumerated() {
            attString.addAttributes([NSAttributedString.Key.foregroundColor: RLColor.share.theme], range: NSRange(location: item.range.location, length: item.range.length - 1))
            if let userId = userIdList[safe: index] {
                attString.addAttributes([NSAttributedString.Key(rawValue: TextViewBindingAttributeName): userId], range: NSRange(location: item.range.location, length: item.range.length - 1))
            }
        }
         
        let matchs1 = TGUtil.findAllHashtag(inputStr: textView.text)
        for (index, item) in matchs1.enumerated() {
            attString.addAttributes([NSAttributedString.Key.foregroundColor: RLColor.share.theme], range: item.range)
            
        }
        
//        textView.text = attString.string
        textView.attributedText = attString
        textView.selectedRange = range
        
        completion?()
    }
    
    // MARK: Display
    func removeHtmlTag(htmlString: String, completion: @escaping (String, [String]) -> ()) {
        var temp: String = htmlString
            var userIdList: [String] = []

            // 正则表达式匹配 <a> 标签及其 href 属性
            let regexPattern = #"<a[^>]*href=["']([^"']+)["'][^>]*>(.*?)</a>"#
            
            do {
                let regex = try NSRegularExpression(pattern: regexPattern, options: [])
                let matches = regex.matches(in: temp, options: [], range: NSRange(temp.startIndex..., in: temp))

                for match in matches.reversed() {
                    if let hrefRange = Range(match.range(at: 1), in: temp),  // href 的范围
                       let textRange = Range(match.range(at: 2), in: temp) { // 文本内容的范围
                        
                        let href = String(temp[hrefRange])
                        let text = String(temp[textRange])
                        
                        // 提取用户 ID（假设用户 ID 是 href 的最后一个路径部分）
                        if let url = URL(string: href){
                            let userId = url.lastPathComponent
                            userIdList.append(userId)
                        }
                        
                        // 替换整个 <a> 标签为其文本内容
                        let fullTagRange = Range(match.range, in: temp)!
                        temp.replaceSubrange(fullTagRange, with: text)
                    }
                }
            } catch {
                print("正则表达式解析失败: \(error)")
            }

            completion(temp, userIdList)
    }
    
    func formAttributeText(_ attributedString: NSMutableAttributedString, _ userIdList: [String]) -> NSMutableAttributedString {
        let attString = attributedString
        let matchs = TGUtil.findAllTSAt(inputStr: attString.string)
        
        if userIdList.isEmpty == false {
            for (index, item) in matchs.enumerated() {
                if let userId = userIdList[safe: index] {
                    attString.addAttributes([NSAttributedString.Key(rawValue: TextViewBindingAttributeName): userId],
                                            range: NSRange(location: item.range.location, length: item.range.length - 1))
                }
            }
        }
        
        return attString
    }
    
    func getAttributeModel(attributedText: NSMutableAttributedString) -> [FeedAttributedModel] {
        var model: [FeedAttributedModel] = []
        
        attributedText.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewBindingAttributeName),
                                          in:NSMakeRange(0, attributedText.length),
                                          options:.longestEffectiveRangeNotRequired) {
            value, range, stop in
            if let userId = value as? String {
                model.append(FeedAttributedModel(userId: userId, range: NSRange(location: range.location + 1, length: range.length)))
            }
        }
        
        return model
    }
    
    // MARK: Mention on Tap
    func handleMentionTap(name: String, attributedText: NSMutableAttributedString?) {
        var uname = String(name[..<name.index(name.startIndex, offsetBy: name.count - 1)]).replacingFirstOccurrence(of: "@", with: "").replacingOccurrences(of: "\u{00ad}", with: "")
        
        if let attributedText = attributedText {
            var models = getAttributeModel(attributedText: attributedText)
            
            if models.isEmpty {
                RLSDKManager.shared.imDelegate?.didPressNameCard(memberId: uname)
            } else {
                for item in models {
                    var username = attributedText.string.subString(with: NSRange(location: item.range.location, length: item.range.length))
                    username = String(username[..<username.index(username.startIndex, offsetBy: username.count - 1)]).replacingFirstOccurrence(of: "@", with: "").replacingOccurrences(of: "\u{00ad}", with: "")
                    if uname == username {
                        RLSDKManager.shared.imDelegate?.didPressUerProfile(uid: item.userId.toInt())
                        break
                    }
                }
            }
        } else {
            RLSDKManager.shared.imDelegate?.didPressNameCard(memberId: uname)
        }
    }
}

class FeedAttributedModel: NSObject {
    var userId: String
    var range: NSRange
    
    init(userId: String, range: NSRange) {
        self.userId = userId
        self.range = range
    }
}

class FeedHTMLModel: NSObject {
    var userId: String
    var userName: String
    
    init(userId: String, userName: String) {
        self.userId = userId
        self.userName = userName
    }
}
