//
//  HTMLManager.swift
//  Yippi
//
//  Created by Kit Foong on 15/01/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import SwiftSoup

let TextViewBindingAttributeName = "TextViewBingDingFlagName"
let TextViewMerchantBindingAttributeName = "TextViewMerchantBingDingFlagName"
let TextViewMerchantAppIdAttributeName = "TextViewMerchantAppIdFlagName"
let TextViewMerchantDealPathAttributeName = "TextViewMerchantDealPathFlagName"

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
    
    func addMerchantToTagContent(miniProgramBranchId: Int? = nil, branchName: String, appId: String? = nil, dealPath: String? = nil, yippiUserID: Int? = nil) -> NSAttributedString {
        let spStr = String(data: ("\u{00ad}".data(using: String.Encoding.unicode))!, encoding: String.Encoding.unicode)
        var insertStr = spStr! + "@" + branchName + spStr! + " "
        
        if let miniProgramBranchId = miniProgramBranchId, let appId = appId, let dealPath = dealPath {
            let merchantIdString = miniProgramBranchId.stringValue
            let appIdString = appId
            let dealPathString = dealPath
            let yippiUserIdString = yippiUserID?.stringValue
            
            var attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.foregroundColor: TGAppTheme.blue,
                NSAttributedString.Key.font: UIFont.systemRegularFont(ofSize: RLFont.ContentText.text.rawValue),
                NSAttributedString.Key(rawValue: TextViewMerchantBindingAttributeName): merchantIdString,
                NSAttributedString.Key(rawValue: TextViewMerchantAppIdAttributeName): appIdString,
                NSAttributedString.Key(rawValue: TextViewMerchantDealPathAttributeName): dealPathString,
                NSAttributedString.Key(rawValue: TextViewBindingAttributeName): yippiUserIdString ?? "",
            ]
            
            let temp = NSAttributedString(string: insertStr, attributes: attributes)
            return temp
        } else {
            // If we don't have required merchant data, just return plain text
            let temp = NSAttributedString(string: insertStr, attributes: [
                NSAttributedString.Key.foregroundColor: TGAppTheme.blue,
                NSAttributedString.Key.font: UIFont.systemRegularFont(ofSize: RLFont.ContentText.text.rawValue)
            ])
            return temp
        }
    }
    
    func addHashTagContent(hashTag: String) -> NSAttributedString {
        var insertStr = "#" + hashTag + " "
        let temp = NSAttributedString(string: insertStr, attributes: [NSAttributedString.Key.foregroundColor: TGAppTheme.blue,
                                                                      NSAttributedString.Key.font: UIFont.systemRegularFont(ofSize: RLFont.ContentText.text.rawValue)])
        return temp
    }
    
    func formHtmlString(_ attributedString: NSAttributedString) -> String {
        var formattedString = attributedString.string
        var replacements: [(range: NSRange, replacement: String)] = []
        
        attributedString.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewMerchantBindingAttributeName),
                                            in: NSMakeRange(0, attributedString.length),
                                            options: .longestEffectiveRangeNotRequired) { value, range, _ in
            let textAtRange = attributedString.string.subString(with: range)
            if let merchantId = value as? String, !merchantId.isEmpty {
                let merchantName = textAtRange.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !merchantName.isEmpty else { return }
                                
                var appId: String = ""
                var dealPath: String = ""
                var yippiUserId: String = ""
                
                // Get appId from the same range
                attributedString.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewMerchantAppIdAttributeName),
                                                    in: range,
                                                    options: []) { appIdValue, _, _ in
                    if let appIdString = appIdValue as? String, !appIdString.isEmpty {
                        appId = appIdString
                    }
                }
                
                // Get dealPath from the same range
                attributedString.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewMerchantDealPathAttributeName),
                                                    in: range,
                                                    options: []) { dealPathValue, _, _ in
                    if let dealPathString = dealPathValue as? String, !dealPathString.isEmpty {
                        dealPath = dealPathString
                    }
                }
                
                attributedString.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewBindingAttributeName),
                                                    in: NSMakeRange(0, attributedString.length),
                                                    options: .longestEffectiveRangeNotRequired) { value, range, _ in
                    if let userId = value as? String, !userId.isEmpty {
                        yippiUserId = userId
                    }
                }
                
                guard !appId.isEmpty else {
                    printIfDebug("⚠️ Skipped merchant due to empty appId for id=\(merchantId), name=\(merchantName)")
                    return
                }
                
                let htmlTag = self.formMerchantHtmlTag(
                    appId: appId,
                    branchId: merchantId,
                    branchName: merchantName,
                    dealPath: dealPath.isEmpty ? nil : dealPath,
                    yippiUserId: yippiUserId
                )
                replacements.append((range: range, replacement: htmlTag))
            }
        }
        
        attributedString.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewBindingAttributeName),
                                            in: NSMakeRange(0, attributedString.length),
                                            options: .longestEffectiveRangeNotRequired) { value, range, _ in
            // Check if this range is already processed as a merchant
            let isAlreadyProcessed = replacements.contains { replacement in
                NSIntersectionRange(replacement.range, range).length > 0
            }
            
            if !isAlreadyProcessed, let userId = value as? String, !userId.isEmpty {
                let username = attributedString.string.subString(with: range)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                guard !username.isEmpty else { return }
                
                let htmlTag = self.formHtmlTag(userId: userId, userName: username)
                replacements.append((range: range, replacement: htmlTag))
            }
        }
        
        // Remove overlaps & sort
        replacements = removeOverlappingRanges(replacements)
        
        // Apply replacements in reverse order to avoid index issues
        let sortedReplacements = replacements.sorted { $0.range.location > $1.range.location }
        
        for replacement in sortedReplacements {
            
            // Use a simpler approach - find and replace the text directly
            let textToFind = replacement.replacement.contains("href") ?
            formattedString.subString(with: replacement.range) :
            replacement.replacement.components(separatedBy: ">").last?.components(separatedBy: "<").first ?? ""
            
            if let range = formattedString.range(of: textToFind) {
                let nsRange = NSRange(range, in: formattedString)
                formattedString = formattedString.replacingOccurrences(of: textToFind, with: replacement.replacement)
            } else {
                // Fallback: try to replace at the original range if it's valid
                if replacement.range.location < formattedString.count &&
                    replacement.range.location + replacement.range.length <= formattedString.count {
                    let startIndex = formattedString.index(formattedString.startIndex, offsetBy: replacement.range.location)
                    let endIndex = formattedString.index(startIndex, offsetBy: replacement.range.length)
                    let textToReplace = String(formattedString[startIndex..<endIndex])
                    formattedString.replaceSubrange(startIndex..<endIndex, with: replacement.replacement)
                }
            }
        }
        
        return formattedString
    }
    
    private func removeOverlappingRanges(_ replacements: [(range: NSRange, replacement: String)]) -> [(range: NSRange, replacement: String)] {
        var filteredReplacements: [(range: NSRange, replacement: String)] = []
        
        for replacement in replacements {
            var hasOverlap = false
            for existing in filteredReplacements {
                let intersection = NSIntersectionRange(replacement.range, existing.range)
                if intersection.length > 0 {
                    hasOverlap = true
                    break
                }
            }
            if !hasOverlap {
                filteredReplacements.append(replacement)
            } else {
                printIfDebug("Removing overlapping replacement: \(replacement)")
            }
        }
        
        return filteredReplacements
    }
    
    func formHtmlTag(userId: String,  userName: String) -> String {
        let spStr = String(data: ("\u{00ad}".data(using: String.Encoding.unicode))!, encoding: String.Encoding.unicode)
        let cleanUserName = userName.replacingOccurrences(of: "\u{00ad}", with: "")
        
        // Ensure the server address ends with a slash
        
        let serverAddress = RLSDKManager.shared.loginParma?.webServerAddress ?? ""
        let baseUrl = serverAddress.hasSuffix("/") ? serverAddress : serverAddress + "/"
        
        let htmlString = "\(spStr!)<a href=\"\(baseUrl)users/\(userId)\">\(cleanUserName)</a>\(spStr!) "
        return htmlString
    }
    
    func formMerchantHtmlTag(appId: String, branchId: String, branchName: String, dealPath: String? = nil, yippiUserId: String) -> String {
        let spStr = String(data: ("\u{00ad}".data(using: String.Encoding.unicode))!, encoding: String.Encoding.unicode)
        let cleanBranchName = branchName.replacingOccurrences(of: "\u{00ad}", with: "")
        
        // Ensure the server address ends with a slash
        let serverAddress = RLSDKManager.shared.loginParma?.webServerAddress ?? ""
        let baseUrl = serverAddress.hasSuffix("/") ? serverAddress : serverAddress + "/"
        
        // Use default path if dealPath is nil or empty
        let path = dealPath ?? "/pages/detail/index"
        
        let htmlString = "\(spStr!)<a href=\"\(baseUrl)mini-program/\(appId)\(path)?id=\(branchId)\">\(cleanBranchName)</a>\(spStr!) "
        return htmlString
    }
    
    func formatTextViewAttributeText(_ textView: UITextView, selectedMerchants: [TGTaggedBranchData]? = nil, completion: (() -> Void)? = nil) -> [TGTaggedBranchData]? {
        let range = textView.selectedRange
        var userIdList : [String] = []
        var merchantIdList : [String] = []
        var merchantAppIdList : [String] = []
        var merchantDealPathList : [String] = []
        
        if let attributedString = textView.attributedText {
            attributedString.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewBindingAttributeName),
                                                in:NSMakeRange(0, attributedString.length),
                                                options:.longestEffectiveRangeNotRequired) {
                value, range, stop in
                if let userId = value as? String {
                    userIdList.append(userId)
                }
            }
            
            attributedString.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewMerchantBindingAttributeName),
                                                in:NSMakeRange(0, attributedString.length),
                                                options:.longestEffectiveRangeNotRequired) {
                value, range, stop in
                if let merchantId = value as? String {
                    merchantIdList.append(merchantId)
                }
            }
            
            attributedString.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewMerchantAppIdAttributeName),
                                                in:NSMakeRange(0, attributedString.length),
                                                options:.longestEffectiveRangeNotRequired) {
                value, range, stop in
                if let appId = value as? String {
                    merchantAppIdList.append(appId)
                }
            }
            
            attributedString.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewMerchantDealPathAttributeName),
                                                in:NSMakeRange(0, attributedString.length),
                                                options:.longestEffectiveRangeNotRequired) {
                value, range, stop in
                if let dealPath = value as? String {
                    merchantDealPathList.append(dealPath)
                }
            }
        }
        
        let attString: NSMutableAttributedString
        if let existingAttributedText = textView.attributedText {
            attString = NSMutableAttributedString(attributedString: existingAttributedText)
        } else {
            attString = NSMutableAttributedString(string: textView.text)
            attString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], range: NSRange(location: 0, length: attString.length))
            attString.addAttributes([NSAttributedString.Key.font: UIFont.systemRegularFont(ofSize: RLFont.ContentText.text.rawValue)], range:  NSRange(location: 0, length: attString.length))
        }
        
        let matchs = TGUtil.findAllTSAt(inputStr: textView.text)
        
        // Create a mapping of ranges to their corresponding user/merchant data
        var rangeToUserData: [NSRange: String] = [:]
        var rangeToMerchantData: [NSRange: (String, String, String)] = [:] // (merchantId, appId, dealPath)
        
        // Map existing user attributes to ranges
        if let existingAttributedText = textView.attributedText {
            existingAttributedText.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewBindingAttributeName),
                                                      in: NSMakeRange(0, existingAttributedText.length),
                                                      options: .longestEffectiveRangeNotRequired) { value, range, stop in
                if let userId = value as? String {
                    rangeToUserData[range] = userId
                }
            }
            
            existingAttributedText.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewMerchantBindingAttributeName),
                                                      in: NSMakeRange(0, existingAttributedText.length),
                                                      options: .longestEffectiveRangeNotRequired) { value, range, stop in
                if let merchantId = value as? String {
                    var appId = ""
                    var dealPath = ""
                    
                    existingAttributedText.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewMerchantAppIdAttributeName),
                                                              in: range,
                                                              options: .longestEffectiveRangeNotRequired) { appIdValue, appIdRange, appIdStop in
                        if let appIdString = appIdValue as? String {
                            appId = appIdString
                        }
                    }
                    
                    existingAttributedText.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewMerchantDealPathAttributeName),
                                                              in: range,
                                                              options: .longestEffectiveRangeNotRequired) { dealPathValue, dealPathRange, dealPathStop in
                        if let dealPathString = dealPathValue as? String {
                            dealPath = dealPathString
                        }
                    }
                    
                    rangeToMerchantData[range] = (merchantId, appId, dealPath)
                }
            }
        }
        
        for (index, item) in matchs.enumerated() {
            let attributeRange = NSRange(location: item.range.location, length: item.range.length)
            attString.addAttributes([NSAttributedString.Key.foregroundColor: TGAppTheme.blue], range: attributeRange)
            
            // Get the mention text to help determine if it's a user or merchant
            let mentionText = textView.text.subString(with: item.range)
            let cleanMentionText = mentionText.replacingOccurrences(of: "\u{00ad}", with: "").replacingOccurrences(of: "@", with: "")
                        
            // Always prioritize selectedMerchants array over existing attributes
            var foundMatch = false
            
            if let selectedMerchants = selectedMerchants {
                // Try to find a merchant that matches this mention text
                if let matchingMerchant = selectedMerchants.first(where: { merchant in
                    guard let merchantName = merchant.branchName else { return false }
                    return cleanMentionText.contains(merchantName) || merchantName.contains(cleanMentionText)
                }) {
                    // Found a matching merchant
                    let merchantId = matchingMerchant.miniProgramBranchID.stringValue
                    attString.addAttributes([NSAttributedString.Key(rawValue: TextViewMerchantBindingAttributeName): merchantId], range: attributeRange)
                    
                    let yippiUserId = matchingMerchant.yippiUserID.stringValue
                    attString.addAttributes([NSAttributedString.Key(rawValue: TextViewBindingAttributeName): yippiUserId], range: attributeRange)
                    
                    foundMatch = true
                }
            }
            
            if !foundMatch {
                // Fallback to existing attributes if no match in selectedMerchants
                if let userId = rangeToUserData[attributeRange] {
                    attString.addAttributes([NSAttributedString.Key(rawValue: TextViewBindingAttributeName): userId], range: attributeRange)
                } else if let (merchantId, appId, dealPath) = rangeToMerchantData[attributeRange] {
                    attString.addAttributes([NSAttributedString.Key(rawValue: TextViewMerchantBindingAttributeName): merchantId], range: attributeRange)
                    if !appId.isEmpty {
                        attString.addAttributes([NSAttributedString.Key(rawValue: TextViewMerchantAppIdAttributeName): appId], range: attributeRange)
                    }
                    if !dealPath.isEmpty {
                        attString.addAttributes([NSAttributedString.Key(rawValue: TextViewMerchantDealPathAttributeName): dealPath], range: attributeRange)
                    }
                } else {
                    printIfDebug("🔍 No existing attributes found for '\(cleanMentionText)', will use index-based assignment")
                }
            }
            
            if !foundMatch {
                // Fallback to lists based on index (for backward compatibility)
                if let userId = userIdList[safe: index] {
                    attString.addAttributes([NSAttributedString.Key(rawValue: TextViewBindingAttributeName): userId], range: attributeRange)
                } else if let merchantId = merchantIdList[safe: index] {
                    attString.addAttributes([NSAttributedString.Key(rawValue: TextViewMerchantBindingAttributeName): merchantId], range: attributeRange)
                    if let appId = merchantAppIdList[safe: index] {
                        attString.addAttributes([NSAttributedString.Key(rawValue: TextViewMerchantAppIdAttributeName): appId], range: attributeRange)
                    }
                    if let dealPath = merchantDealPathList[safe: index] {
                        attString.addAttributes([NSAttributedString.Key(rawValue: TextViewMerchantDealPathAttributeName): dealPath], range: attributeRange)
                    }
                    
                    // Add yippiUserID for merchant if available in selectedMerchants
                    if let branchId = Int(merchantId), let selectedMerchants = selectedMerchants {
                        if let matchingMerchant = selectedMerchants.first(where: { $0.miniProgramBranchID == branchId }) {
                            if let yippiUserID = matchingMerchant.yippiUserID {
                                attString.addAttributes([NSAttributedString.Key(rawValue: TextViewBindingAttributeName): yippiUserID.stringValue], range: attributeRange)
                            }
                        }
                    }
                } else {
                    // No data available, try to determine type based on text content
                    if cleanMentionText.contains(" ") {
                        // Text contains spaces, likely a merchant - use first available merchant data
                        if let merchantId = merchantIdList.first, let appId = merchantAppIdList.first, let dealPath = merchantDealPathList.first {
                            attString.addAttributes([NSAttributedString.Key(rawValue: TextViewMerchantBindingAttributeName): merchantId], range: attributeRange)
                            attString.addAttributes([NSAttributedString.Key(rawValue: TextViewMerchantAppIdAttributeName): appId], range: attributeRange)
                            attString.addAttributes([NSAttributedString.Key(rawValue: TextViewMerchantDealPathAttributeName): dealPath], range: attributeRange)
                            
                            // Add yippiUserID for merchant if available in selectedMerchants
                            if let branchId = Int(merchantId), let selectedMerchants = selectedMerchants {
                                if let matchingMerchant = selectedMerchants.first(where: { $0.miniProgramBranchID == branchId }) {
                                    if let yippiUserID = matchingMerchant.yippiUserID {
                                        attString.addAttributes([NSAttributedString.Key(rawValue: TextViewBindingAttributeName): yippiUserID.stringValue], range: attributeRange)
                                    }
                                }
                            }
                        }
                    } else {
                        // Text doesn't contain spaces, likely a user - use first available user data
                        if let userId = userIdList.first {
                            attString.addAttributes([NSAttributedString.Key(rawValue: TextViewBindingAttributeName): userId], range: attributeRange)
                        }
                    }
                }
            }
        }
        
        let matchs1 = TGUtil.findAllHashtag(inputStr: textView.text)
        for (index, item) in matchs1.enumerated() {
            attString.addAttributes([NSAttributedString.Key.foregroundColor: TGAppTheme.blue], range: item.range)
        }
        
        textView.attributedText = attString
        textView.selectedRange = range
        
        // Extract merchant data from the updated attributed text
        var updatedMerchants: [TGTaggedBranchData] = []
        var processedRanges: [NSRange] = [] // Track processed ranges to avoid duplicates
        var processedMerchantIds: Set<Int> = [] // Track processed merchant IDs to avoid duplicates
        
        if let attributedText = textView.attributedText {
            attributedText.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewMerchantBindingAttributeName),
                                              in: NSMakeRange(0, attributedText.length),
                                              options: .longestEffectiveRangeNotRequired) { value, range, _ in
                if let merchantId = value as? String, let branchId = Int(merchantId) {
                    // Extract merchant name from the text
                    let text = attributedText.attributedSubstring(from: range).string
                    let cleanText = text.replacingOccurrences(of: "\u{00ad}", with: "").replacingOccurrences(of: "@", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Skip merchants with empty names or very short ranges (likely artifacts)
                    guard !cleanText.isEmpty && range.length > 1 else {
                        printIfDebug("🔍 Skipping merchant with empty name or short range: name='\(cleanText)', branchId=\(branchId), range=\(range)")
                        return
                    }
                    
                    // Skip if we've already processed this merchant ID
                    if processedMerchantIds.contains(branchId) {
                        printIfDebug("🔍 Skipping duplicate merchant ID: name='\(cleanText)', branchId=\(branchId), range=\(range)")
                        return
                    }
                    
                    // Check if we've already processed this range
                    let isAlreadyProcessed = processedRanges.contains { existingRange in
                        NSIntersectionRange(existingRange, range).length > 0
                    }
                    
                    if isAlreadyProcessed {
                        return
                    }
                    
                    let merchantData = TGTaggedBranchData()
                    merchantData.miniProgramBranchID = branchId
                    merchantData.branchName = cleanText
                                        
                    // Try to find yippiUserID from selectedMerchants if provided
                    if let selectedMerchants = selectedMerchants {
                        if let matchingMerchant = selectedMerchants.first(where: { $0.miniProgramBranchID == branchId }) {
                            merchantData.yippiUserID = matchingMerchant.yippiUserID
                        } else {
                            printIfDebug("🔍 No matching merchant found in selectedMerchants for branchId=\(branchId)")
                        }
                    }
                    
                    updatedMerchants.append(merchantData)
                    processedRanges.append(range)
                    processedMerchantIds.insert(branchId)
                }
            }
        }
        
        completion?()
        return updatedMerchants
    }
    
    // MARK: Display
    func removeHtmlTag(htmlString: String, completion: @escaping (String, [String], [String], [String]) -> ()) {
        removeHtmlTag(htmlString: htmlString) { content, userIdList, merchantIdList, merchantAppIdList, merchantDealPathList in
            completion(content, userIdList, merchantIdList, merchantAppIdList)
        }
    }
    
    func removeHtmlTag(htmlString: String, isPostFeed: Bool = false,  completion: @escaping (String, [String], [String], [String], [String]) -> ()) {
        var temp : String = htmlString
        
        if isPostFeed {
            temp = temp.replacingOccurrences(of: "\u{00ad}", with: "")
            temp = temp.replacingOccurrences(of: "&", with: "&amp;")
        }
        
        var userIdList: [String] = []
        var merchantIdList: [String] = []
        var merchantAppIdList: [String] = []
        var merchantDealPathList: [String] = []
                
        do {
            let doc: Document = try SwiftSoup.parse(temp)
            let links: Elements = try doc.select("a")
                        
            for (index, link) in links.enumerated() {
                let linkOuterH: String = try link.outerHtml()
                let linkHref: String = try link.attr("href")
                let linkText: String = try link.text()
                                
                // Check if it's a user link
                if linkHref.contains("/users/") {
                    if let id = linkHref.urlValue?.lastPathComponent {
                        userIdList.append(id)
                    }
                }
                // Check if it's a merchant link
                else if linkHref.contains("/mini-program/") {
                    // Extract appId, branchId, and dealPath from URL like: /mini-program/{appId}{dealPath}?id={branchId}
                    if let url = URL(string: linkHref),
                       let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                        
                        // Extract appId from path
                        let pathComponents = url.pathComponents
                        if pathComponents.count >= 3 && pathComponents[1] == "mini-program" {
                            let appId = pathComponents[2]
                            merchantAppIdList.append(appId)
                            
                            // Extract dealPath from the URL path
                            // The dealPath is everything after the appId in the path
                            let appIdIndex = pathComponents.firstIndex(of: appId) ?? 2
                            if appIdIndex + 1 < pathComponents.count {
                                // Reconstruct the dealPath from the remaining path components
                                let dealPathComponents = Array(pathComponents[(appIdIndex + 1)...])
                                let dealPath = "/" + dealPathComponents.joined(separator: "/")
                                merchantDealPathList.append(dealPath)
                            } else {
                                // Default dealPath if not found
                                merchantDealPathList.append("/pages/detail/index")
                            }
                        }
                        
                        // Extract branchId from query parameters
                        if let branchId = components.queryItems?.first(where: { $0.name == "id" })?.value {
                            merchantIdList.append(branchId)
                        }
                    }
                }
                
                // Format the mention text with invisible characters for proper detection
                let spStr = String(data: ("\u{00ad}".data(using: String.Encoding.unicode))!, encoding: String.Encoding.unicode)!
                let formattedMention = "\(spStr)\(linkText)\(spStr) "
                temp = temp.replacingOccurrences(of: linkOuterH, with: formattedMention)
            }
        } catch {
            printIfDebug("Unable to parse html string")
        }
        
        completion(temp, userIdList, merchantIdList, merchantAppIdList, merchantDealPathList)
    }
    
    func removeAllHtmlTaging(htmlString: String) -> String {
        var plainText: String = htmlString
        
        do {
            let doc: Document = try SwiftSoup.parse(htmlString)
            plainText = try doc.text()
        } catch {
            printIfDebug("Error parsing HTML: \(error)")
        }
        
        return plainText
    }
    
    func wrappedHTML(html: String) -> String {
        return """
        <html>
        <style>
            body {
                font-family: -apple-system, Helvetica, Arial, sans-serif;
                font-size: 12px;
            }
        </style>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body>
            \(html)
        </body>
        </html>
        """
    }
    
    func containsHTMLTags(text: String) -> Bool {
        let htmlRegex = "<[^>]+>"
        return text.range(of: htmlRegex, options: .regularExpression) != nil
    }
    
    func formAttributeText(_ attributedString: NSMutableAttributedString, _ userIdList: [String], _ merchantIdList: [String] = [], _ merchantAppIdList: [String] = [], _ merchantDealPathList: [String] = [], _ selectedMerchants: [TGTaggedBranchData]? = nil) -> NSMutableAttributedString {
        let attString = attributedString
        let matchs = TGUtil.findAllTSAt(inputStr: attString.string)
        
        // Debug: Show all mentions found
        for (index, match) in matchs.enumerated() {
            let mentionText = attString.string.subString(with: match.range)
            let cleanMentionText = mentionText.replacingOccurrences(of: "\u{00ad}", with: "").replacingOccurrences(of: "@", with: "")
        }
        
        // Create a mapping of mention names to their data
        var userDataMap: [String: String] = [:]
        var merchantDataMap: [String: (merchantId: String, appId: String, dealPath: String)] = [:]
        
        // Create a mapping based on the actual mention order and type
        var userIndex = 0
        var merchantIndex = 0
        
        for (index, mention) in matchs.enumerated() {
            let mentionText = attString.string.subString(with: mention.range)
            let cleanMentionText = mentionText.replacingOccurrences(of: "\u{00ad}", with: "").replacingOccurrences(of: "@", with: "")
            
            // Determine if this is likely a user or merchant based on text content
            let isLikelyUser = !cleanMentionText.contains(" ") && cleanMentionText.rangeOfCharacter(from: .init(charactersIn: "一-龯")) == nil
            let isLikelyMerchant = cleanMentionText.contains(" ") || cleanMentionText.rangeOfCharacter(from: .init(charactersIn: "一-龯")) != nil
            
            if isLikelyUser && userIndex < userIdList.count {
                let userId = userIdList[userIndex]
                userDataMap[cleanMentionText] = userId
                userIndex += 1
            } else if isLikelyMerchant && merchantIndex < merchantIdList.count {
                let merchantId = merchantIdList[merchantIndex]
                let appId = merchantAppIdList[safe: merchantIndex] ?? ""
                let dealPath = merchantDealPathList[safe: merchantIndex] ?? ""
                merchantDataMap[cleanMentionText] = (merchantId: merchantId, appId: appId, dealPath: dealPath)
                merchantIndex += 1
            } else {
                // If we don't have data for this mention, try to find it in selectedMerchants
                if isLikelyMerchant, let selectedMerchants = selectedMerchants {
                    if let matchingMerchant = selectedMerchants.first(where: { merchant in
                        guard let merchantName = merchant.branchName else { return false }
                        return cleanMentionText.contains(merchantName) || merchantName.contains(cleanMentionText)
                    }) {
                        let merchantId = matchingMerchant.miniProgramBranchID.stringValue
                        let appId = merchantAppIdList.first ?? ""
                        let dealPath = merchantDealPathList.first ?? ""
                        merchantDataMap[cleanMentionText] = (merchantId: merchantId, appId: appId, dealPath: dealPath)
                    }
                }
            }
        }
        
        // Assign attributes based on name matching
        for (index, item) in matchs.enumerated() {
            let mentionText = attString.string.subString(with: item.range)
            let cleanMentionText = mentionText.replacingOccurrences(of: "\u{00ad}", with: "").replacingOccurrences(of: "@", with: "")
            let attributeRange = NSRange(location: item.range.location, length: item.range.length - 1)
            
            // Check if it's a user first
            if let userId = userDataMap[cleanMentionText] {
                attString.addAttributes([
                    NSAttributedString.Key(rawValue: TextViewBindingAttributeName): userId,
                    NSAttributedString.Key.foregroundColor: TGAppTheme.primaryBlueColor
                ], range: attributeRange)
            }
            // Then check if it's a merchant
            else if let merchantData = merchantDataMap[cleanMentionText] {
                var merchantAttributes: [NSAttributedString.Key: Any] = [
                    NSAttributedString.Key(rawValue: TextViewMerchantBindingAttributeName): merchantData.merchantId,
                    NSAttributedString.Key.foregroundColor: TGAppTheme.primaryBlueColor
                ]
                
                if !merchantData.appId.isEmpty {
                    merchantAttributes[NSAttributedString.Key(rawValue: TextViewMerchantAppIdAttributeName)] = merchantData.appId
                }
                
                if !merchantData.dealPath.isEmpty {
                    merchantAttributes[NSAttributedString.Key(rawValue: TextViewMerchantDealPathAttributeName)] = merchantData.dealPath
                }
                
                attString.addAttributes(merchantAttributes, range: attributeRange)
            }
            // Fallback to index-based assignment if no name match
            else {
                if let userId = userIdList[safe: index] {
                    attString.addAttributes([
                        NSAttributedString.Key(rawValue: TextViewBindingAttributeName): userId,
                        NSAttributedString.Key.foregroundColor: TGAppTheme.primaryBlueColor
                    ], range: attributeRange)
                } else if let merchantId = merchantIdList[safe: index] {
                    attString.addAttributes([
                        NSAttributedString.Key(rawValue: TextViewMerchantBindingAttributeName): merchantId,
                        NSAttributedString.Key.foregroundColor: TGAppTheme.primaryBlueColor
                    ], range: attributeRange)
                    
                    if let appId = merchantAppIdList[safe: index] {
                        attString.addAttributes([NSAttributedString.Key(rawValue: TextViewMerchantAppIdAttributeName): appId], range: attributeRange)
                    }
                    
                    if let dealPath = merchantDealPathList[safe: index] {
                        attString.addAttributes([NSAttributedString.Key(rawValue: TextViewMerchantDealPathAttributeName): dealPath], range: attributeRange)
                    }
                }
            }
        }
        
        return attString
    }
    
    func getAttributeModel(attributedText: NSMutableAttributedString) -> [FeedAttributedModel] {
        var model: [FeedAttributedModel] = []
        
        // First, find all mentions in the text using TGUtil.findAllTSAt
        let mentions = TGUtil.findAllTSAt(inputStr: attributedText.string)
        
        // Collect all attributes with their ranges
        var rangeToAttributes: [NSRange: [(type: String, data: [String: String])]] = [:]
        
        // Collect user attributes
        attributedText.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewBindingAttributeName),
                                          in: NSMakeRange(0, attributedText.length),
                                          options: .longestEffectiveRangeNotRequired) { value, range, stop in
            if let userId = value as? String {
                if rangeToAttributes[range] == nil {
                    rangeToAttributes[range] = []
                }
                rangeToAttributes[range]?.append((type: "user", data: ["userId": userId]))
            }
        }
        
        // Collect merchant attributes
        attributedText.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewMerchantBindingAttributeName),
                                          in: NSMakeRange(0, attributedText.length),
                                          options: .longestEffectiveRangeNotRequired) { value, range, stop in
            if let branchId = value as? String {
                // Get the corresponding appId for this merchant
                var appId: String = ""
                var dealPath: String = ""
                
                attributedText.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewMerchantAppIdAttributeName),
                                                  in: range,
                                                  options: .longestEffectiveRangeNotRequired) { appIdValue, appIdRange, appIdStop in
                    if let appIdString = appIdValue as? String, !appIdString.isEmpty {
                        appId = appIdString
                    }
                }
                
                attributedText.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewMerchantDealPathAttributeName),
                                                  in: range,
                                                  options: .longestEffectiveRangeNotRequired) { dealPathValue, dealPathRange, dealPathStop in
                    if let dealPathString = dealPathValue as? String, !dealPathString.isEmpty {
                        dealPath = dealPathString
                    }
                }
                
                if rangeToAttributes[range] == nil {
                    rangeToAttributes[range] = []
                }
                rangeToAttributes[range]?.append((type: "merchant", data: ["branchId": branchId, "appId": appId, "dealPath": dealPath]))
            }
        }
        
        // Collect user attributes
        attributedText.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewBindingAttributeName),
                                          in: NSMakeRange(0, attributedText.length),
                                          options: .longestEffectiveRangeNotRequired) { value, range, stop in
            if let userId = value as? String {
                if rangeToAttributes[range] == nil {
                    rangeToAttributes[range] = []
                }
                rangeToAttributes[range]?.append((type: "user", data: ["userId": userId]))
            }
        }
        
        
        // Create a list of all available attributes sorted by range location
        var availableUserAttributes: [(range: NSRange, data: [String: String])] = []
        var availableMerchantAttributes: [(range: NSRange, data: [String: String])] = []
        
        for (range, attributes) in rangeToAttributes {
            for attribute in attributes {
                if attribute.type == "user" {
                    availableUserAttributes.append((range: range, data: attribute.data))
                } else if attribute.type == "merchant" {
                    availableMerchantAttributes.append((range: range, data: attribute.data))
                }
            }
        }
        
        // Sort by range location
        availableUserAttributes.sort { $0.range.location < $1.range.location }
        availableMerchantAttributes.sort { $0.range.location < $1.range.location }
        
        var userIndex = 0
        var merchantIndex = 0
        
        // Create models based on the actual mention positions
        for (mentionIndex, mention) in mentions.enumerated() {
            let mentionText = attributedText.string.subString(with: mention.range)
            let cleanMentionText = mentionText.replacingOccurrences(of: "\u{00ad}", with: "").replacingOccurrences(of: "@", with: "")
            
            // Check if this mention range has any attributes
            if let attributes = rangeToAttributes[mention.range] {
                if attributes.count == 1 {
                    // Only one attribute type, use it directly
                    let attribute = attributes[0]
                    if attribute.type == "user" {
                        let userId = attribute.data["userId"] ?? ""
                        model.append(FeedAttributedModel(userId: userId, range: mention.range, type: "user"))
                    } else if attribute.type == "merchant" {
                        let branchId = attribute.data["branchId"] ?? ""
                        let appId = attribute.data["appId"] ?? ""
                        let dealPath = attribute.data["dealPath"] ?? ""
                        model.append(FeedAttributedModel(range: mention.range, appId: appId, branchId: branchId, dealPath: dealPath, type: "merchant"))
                    }
                } else if attributes.count > 1 {
                    // Multiple attribute types for the same range, determine priority based on text content
                    let userAttribute = attributes.first { $0.type == "user" }
                    let merchantAttribute = attributes.first { $0.type == "merchant" }
                    
                    if cleanMentionText.contains(" ") {
                        // Text contains spaces, likely a merchant name
                        if let merchantAttr = merchantAttribute {
                            let branchId = merchantAttr.data["branchId"] ?? ""
                            let appId = merchantAttr.data["appId"] ?? ""
                            let dealPath = merchantAttr.data["dealPath"] ?? ""
                            model.append(FeedAttributedModel(range: mention.range, appId: appId, branchId: branchId, dealPath: dealPath, type: "merchant"))
                        }
                    } else {
                        // Text doesn't contain spaces, likely a username
                        if let userAttr = userAttribute {
                            let userId = userAttr.data["userId"] ?? ""
                            model.append(FeedAttributedModel(userId: userId, range: mention.range, type: "user"))
                        }
                    }
                }
            } else {
                // No attributes found for this mention range, try to find closest matching attribute range
                var bestMatch: (range: NSRange, attributes: [(type: String, data: [String: String])])? = nil
                var bestOverlap = 0
                
                for (attrRange, attributes) in rangeToAttributes {
                    let intersection = NSIntersectionRange(mention.range, attrRange)
                    if intersection.length > bestOverlap {
                        bestOverlap = intersection.length
                        bestMatch = (attrRange, attributes)
                    }
                }
                
                if let match = bestMatch, bestOverlap > 0 {
                    if match.attributes.count == 1 {
                        let attribute = match.attributes[0]
                        // Check if the attribute type matches the expected type based on text content
                        let isExpectedUser = !cleanMentionText.contains(" ")
                        let isExpectedMerchant = cleanMentionText.contains(" ")
                        
                        if attribute.type == "user" && isExpectedUser {
                            let userId = attribute.data["userId"] ?? ""
                            model.append(FeedAttributedModel(userId: userId, range: mention.range, type: "user"))
                        } else if attribute.type == "merchant" && isExpectedMerchant {
                            let branchId = attribute.data["branchId"] ?? ""
                            let appId = attribute.data["appId"] ?? ""
                            let dealPath = attribute.data["dealPath"] ?? ""
                            model.append(FeedAttributedModel(range: mention.range, appId: appId, branchId: branchId, dealPath: dealPath, type: "merchant"))
                        }
                        // If attribute type doesn't match expected type, fall through to proximity matching
                    } else if match.attributes.count > 1 {
                        // Multiple attributes, determine priority based on text content
                        let userAttribute = match.attributes.first { $0.type == "user" }
                        let merchantAttribute = match.attributes.first { $0.type == "merchant" }
                        
                        // Determine priority based on text content and available data
                        let hasUserData = userAttribute != nil && !(userAttribute?.data["userId"]?.isEmpty ?? true)
                        let hasMerchantData = merchantAttribute != nil && !(merchantAttribute?.data["branchId"]?.isEmpty ?? true)
                        
                        if hasMerchantData && (!hasUserData || cleanMentionText.contains(" ")) {
                            // Use merchant attributes if we have merchant data and either no user data or text contains spaces
                            if let merchantAttr = merchantAttribute {
                                let branchId = merchantAttr.data["branchId"] ?? ""
                                let appId = merchantAttr.data["appId"] ?? ""
                                let dealPath = merchantAttr.data["dealPath"] ?? ""
                                model.append(FeedAttributedModel(range: mention.range, appId: appId, branchId: branchId, dealPath: dealPath, type: "merchant"))
                            }
                        } else if hasUserData {
                            // Use user attributes if we have user data
                            if let userAttr = userAttribute {
                                let userId = userAttr.data["userId"] ?? ""
                                model.append(FeedAttributedModel(userId: userId, range: mention.range, type: "user"))
                            }
                        } else {
                            // No data available, default based on text content
                            if cleanMentionText.rangeOfCharacter(from: .init(charactersIn: "一-龯")) != nil {
                                // Contains Chinese characters, likely a merchant
                                model.append(FeedAttributedModel(range: mention.range, appId: "", branchId: "", dealPath: "", type: "merchant"))
                            } else {
                                // No Chinese characters, likely a user
                                model.append(FeedAttributedModel(userId: "", range: mention.range, type: "user"))
                            }
                        }
                    }
                }
                
                // If we didn't find a suitable match above, use proximity matching
                let wasModelAdded = !model.isEmpty && model.last?.range.location == mention.range.location
                if !wasModelAdded {
                    // Try to find the best matching attribute based on proximity and type
                    var bestUserMatch: (range: NSRange, data: [String: String])? = nil
                    var bestMerchantMatch: (range: NSRange, data: [String: String])? = nil
                    var bestUserDistance = Int.max
                    var bestMerchantDistance = Int.max
                    
                    // Find closest user attribute
                    for userAttr in availableUserAttributes {
                        let distance = abs(Int(mention.range.location) - Int(userAttr.range.location))
                        if distance < bestUserDistance {
                            bestUserDistance = distance
                            bestUserMatch = userAttr
                        }
                    }
                    
                    // Find closest merchant attribute
                    for merchantAttr in availableMerchantAttributes {
                        let distance = abs(Int(mention.range.location) - Int(merchantAttr.range.location))
                        if distance < bestMerchantDistance {
                            bestMerchantDistance = distance
                            bestMerchantMatch = merchantAttr
                        }
                    }
                    
                    // Determine if this is likely a merchant or user based on available attributes
                    // If we have both user and merchant attributes available, prefer the one with more data
                    let hasUserData = bestUserMatch != nil && !(bestUserMatch?.data["userId"]?.isEmpty ?? true)
                    let hasMerchantData = bestMerchantMatch != nil && !(bestMerchantMatch?.data["branchId"]?.isEmpty ?? true)
                    
                    if hasMerchantData && (!hasUserData || cleanMentionText.contains(" ")) {
                        // Use merchant attributes if we have merchant data and either no user data or text contains spaces
                        if let merchantMatch = bestMerchantMatch {
                            let branchId = merchantMatch.data["branchId"] ?? ""
                            let appId = merchantMatch.data["appId"] ?? ""
                            let dealPath = merchantMatch.data["dealPath"] ?? ""
                            model.append(FeedAttributedModel(range: mention.range, appId: appId, branchId: branchId, dealPath: dealPath, type: "merchant"))
                        } else {
                            // No merchant attributes available, create empty merchant model
                            model.append(FeedAttributedModel(range: mention.range, appId: "", branchId: "", dealPath: "", type: "merchant"))
                        }
                    } else if hasUserData {
                        // Use user attributes if we have user data
                        if let userMatch = bestUserMatch {
                            let userId = userMatch.data["userId"] ?? ""
                            model.append(FeedAttributedModel(userId: userId, range: mention.range, type: "user"))
                        } else {
                            // No user attributes available, create empty user model
                            model.append(FeedAttributedModel(userId: "", range: mention.range, type: "user"))
                        }
                    } else {
                        // No data available, default to merchant for Chinese text or user for English text
                        if cleanMentionText.rangeOfCharacter(from: .init(charactersIn: "一-龯")) != nil {
                            // Contains Chinese characters, likely a merchant
                            model.append(FeedAttributedModel(range: mention.range, appId: "", branchId: "", dealPath: "", type: "merchant"))
                        } else {
                            // No Chinese characters, likely a user
                            model.append(FeedAttributedModel(userId: "", range: mention.range, type: "user"))
                        }
                    }
                }
            }
        }
        
        // Sort by range location to maintain order
        model.sort { $0.range.location < $1.range.location }
        
        return model
    }
    
    // MARK: Mention on Tap
    func handleMentionTap(name: String, attributedText: NSMutableAttributedString?, currentVC: UIViewController? = nil) {
        var uname = String(name[..<name.index(name.startIndex, offsetBy: name.count - 1)]).replacingFirstOccurrence(of: "@", with: "").replacingOccurrences(of: "\u{00ad}", with: "")
        
        if let attributedText = attributedText {
            var models = getAttributeModel(attributedText: attributedText)
            
            for (index, item) in models.enumerated() {
                let itemText = attributedText.string.subString(with: item.range)
                let cleanItemText = itemText.replacingOccurrences(of: "\u{00ad}", with: "").replacingOccurrences(of: "@", with: "")
                let cleanUname = uname.replacingOccurrences(of: "\u{00ad}", with: "").replacingOccurrences(of: "@", with: "")
                
                if cleanItemText == cleanUname {
                    if let userId = item.userId, !userId.isEmpty,  let type = item.type, type == "user" {
                        // User mention
                        TGUtil.pushUserHomeId(uid: userId)
                        return
                    } else if let appId = item.appId, let branchId = item.branchId, !appId.isEmpty && !branchId.isEmpty, let type = item.type, type == "merchant" {
                        // Merchant mention
                        let dealPath = item.dealPath ?? "/pages/detail/index"
                        let serverAddress = RLSDKManager.shared.loginParma?.webServerAddress ?? ""
                        let extra = "\(serverAddress)mini-program/\(appId)\(dealPath)?id=\(branchId)"
                        guard let url = URL(string: extra) else {
                            return
                        }
                        if let currentVC = currentVC {
//                            TGUtil.pushURLDetail(url: url, currentVC: currentVC)
                        }
                        return
                    }
                }
            }
        } else {
            TGUtil.pushUserHomeName(name: uname)
        }
    }
    
    func addMerchantAttributesToExistingMention(attributedText: NSAttributedString, merchantName: String, miniProgramBranchId: Int?, appId: String?, dealPath: String?) -> NSAttributedString? {
        let mutableAttributedString = attributedText.mutableCopy() as! NSMutableAttributedString
        let text = mutableAttributedString.string
        
        // Try to find the merchant mention (with or without @)
        let merchantNameWithAt = "@\(merchantName)"
        var foundRange: NSRange?
        
        // First try with @ symbol
        if let range = text.range(of: merchantNameWithAt) {
            foundRange = NSRange(range, in: text)
        }
        // If not found, try without @ symbol
        else if let range = text.range(of: merchantName) {
            foundRange = NSRange(range, in: text)
        }
        // Try with invisible characters removed
        else {
            let cleanText = text.replacingOccurrences(of: "\u{00ad}", with: "")
            if let range = cleanText.range(of: merchantNameWithAt) {
                foundRange = NSRange(range, in: cleanText)
            } else if let range = cleanText.range(of: merchantName) {
                foundRange = NSRange(range, in: cleanText)
            }
        }
        
        guard let range = foundRange else {
            return nil
        }
        
        // Check if attributes already exist
        let existingAttributes = mutableAttributedString.attributes(at: range.location, effectiveRange: nil)
        if existingAttributes[NSAttributedString.Key(rawValue: TextViewMerchantBindingAttributeName)] != nil {
            return mutableAttributedString
        }
        
        // Add merchant attributes to the existing text
        let merchantId = String(miniProgramBranchId ?? 0)
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key(rawValue: TextViewMerchantBindingAttributeName): merchantId,
            NSAttributedString.Key(rawValue: TextViewMerchantAppIdAttributeName): appId ?? "",
            NSAttributedString.Key(rawValue: TextViewMerchantDealPathAttributeName): dealPath ?? ""
        ]
        
        mutableAttributedString.addAttributes(attributes, range: range)
        return mutableAttributedString
    }
}

class FeedAttributedModel: NSObject {
    var userId: String?
    var range: NSRange
    
    var appId: String?
    var branchId: String?
    var dealPath: String?
    var type: String?
    
    init(userId: String? = nil, range: NSRange, appId: String? = nil, branchId: String? = nil, dealPath: String? = nil, type: String) {
        self.userId = userId
        self.range = range
        self.appId = appId
        self.branchId = branchId
        self.dealPath = dealPath
        self.type = type
    }
}
class FeedHTMLModel: NSObject {
    var userId: String?
    var userName: String?
    
    var appId: String?
    var branchId: String?
    var branchName: String?
    
    init(userId: String? = nil, userName: String? = nil, appId: String? = nil, branchId: String? = nil, branchName: String? = nil) {
        self.userId = userId
        self.userName = userName
        self.appId = appId
        self.branchId = branchId
        self.branchName = branchName
    }
}

