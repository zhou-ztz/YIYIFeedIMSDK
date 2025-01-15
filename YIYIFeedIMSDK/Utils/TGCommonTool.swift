//
//  TGCommonTool.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2024/12/25.
//

import Foundation
import UIKit

class TGCommonTool {
    
    // MARK: - 删除某个范围的字符串
    static func deleteString(from originalString: String, range: NSRange) -> String {
        guard let range = Range(range, in: originalString) else {
            return originalString
        }
        var mutableString = originalString
        mutableString.removeSubrange(range)
        return mutableString
    }
    
    // MARK: - 处理 @ 的输入框
    static func atMeTextViewEdit(_ textView: UITextView) -> UITextView {
        let selectedRange = textView.selectedRange
        if selectedRange.location > 0 {
            let editLeftChar = String(textView.text[textView.text.index(textView.text.startIndex, offsetBy: selectedRange.location - 1)])
            if editLeftChar == "@" {
                textView.text = deleteString(from: textView.text, range: NSRange(location: selectedRange.location - 1, length: 1))
                textView.selectedRange = NSRange(location: selectedRange.location - 1, length: 0)
            }
        }
        return textView
    }
    
    // MARK: - 处理 # 的输入框
    static func hashtagTextViewEdit(_ textView: UITextView) -> UITextView {
        let selectedRange = textView.selectedRange
        if selectedRange.location > 0 {
            let editLeftChar = String(textView.text[textView.text.index(textView.text.startIndex, offsetBy: selectedRange.location - 1)])
            if editLeftChar == "#" {
                textView.text = deleteString(from: textView.text, range: NSRange(location: selectedRange.location - 1, length: 1))
                textView.selectedRange = NSRange(location: selectedRange.location - 1, length: 0)
            }
        }
        return textView
    }
    
    // MARK: - 获取文件大小
    static func getFileSize(_ filePath: String) -> Int {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            if let attributes = try? fileManager.attributesOfItem(atPath: filePath),
               let fileSize = attributes[.size] as? NSNumber {
                return fileSize.intValue
            }
        }
        return 0
    }
    
    // MARK: - 向一个富文本中添加属性
    static func attributedString(_ orgString: NSAttributedString, appendAttrs attrs: [Dictionary<NSAttributedString.Key, Any>], strings: [String]) -> NSMutableAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: orgString)
        if attrs.isEmpty || attrs.count != strings.count {
            return NSMutableAttributedString(attributedString: orgString)
        }
        
        let replaceString = "œ"
        var waitFixString = orgString.string
        
        for i in 0..<strings.count {
            guard let range = waitFixString.range(of: strings[i]) else {
                continue
            }
            let nsRange = NSRange(range, in: waitFixString)
            
            // 替换匹配到的文本前所有内容，防止乱序
            for j in 0..<nsRange.location {
                if let replaceRange = Range(NSRange(location: j, length: 1), in: waitFixString) {
                    waitFixString.replaceSubrange(replaceRange, with: replaceString)
                }
            }
            
            // 替换匹配到的文本内容
            for j in 0..<nsRange.length {
                if let replaceRange = Range(NSRange(location: nsRange.location + j, length: 1), in: waitFixString) {
                    waitFixString.replaceSubrange(replaceRange, with: replaceString)
                }
            }
            
            // 设置属性
            mutableAttributedString.addAttributes(attrs[i], range: nsRange)
        }
        
        return mutableAttributedString
    }
}
