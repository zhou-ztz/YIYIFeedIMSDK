//
//  LabelLineText.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/7.
//

import Foundation
import UIKit
import CoreText

class RangeModel {
    var locations: Int = 0
    var lengths: Int = 0
}

class LabelLineText {

    // 获取 UILabel 分割行文本
    static func getSeparatedLines(from label: UILabel) -> [String] {
        let text = label.text ?? ""
        let font = label.font
        let rect = label.frame
        let myFont: CTFont
        if let font = font {
            myFont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        } else {
            // 使用默认字体和大小（比如系统字体）
            myFont = CTFontCreateWithName("Helvetica" as CFString, 12.0, nil)
        }
        let attStr = NSMutableAttributedString(string: text)
        attStr.addAttribute(kCTFontAttributeName as NSAttributedString.Key, value: myFont, range: NSRange(location: 0, length: attStr.length))
        
        let frameSetter = CTFramesetterCreateWithAttributedString(attStr as CFAttributedString)
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: rect.size.width, height: 100000))
        
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        
        let lines = (CTFrameGetLines(frame) as NSArray) as! [Any]
        var linesArray: [String] = []
        
        for line in lines {
            let lineRef = line as! CTLine
            let lineRange = CTLineGetStringRange(lineRef)
            let range = NSRange(location: lineRange.location, length: lineRange.length)
            
            let lineString = (text as NSString).substring(with: range)
            linesArray.append(lineString)
        }
        
        return linesArray
    }

    // 获取 UILabel 分割行范围
    static func getSeparatedLinesRange(from label: UILabel) -> [RangeModel] {
        let text = label.text ?? ""
        let font = label.font
        let rect = label.frame
        
        let myFont: CTFont
        if let font = font {
            myFont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        } else {
            // 使用默认字体和大小（比如系统字体）
            myFont = CTFontCreateWithName("Helvetica" as CFString, 12.0, nil)
        }
        let attStr = NSMutableAttributedString(string: text)
        attStr.addAttribute(kCTFontAttributeName as NSAttributedString.Key, value: myFont, range: NSRange(location: 0, length: attStr.length))
        
        let frameSetter = CTFramesetterCreateWithAttributedString(attStr as CFAttributedString)
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: rect.size.width, height: 100000))
        
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        
        let lines = (CTFrameGetLines(frame) as NSArray) as! [Any]
        var linesArray: [RangeModel] = []
        
        for line in lines {
            let lineRef = line as! CTLine
            let lineRange = CTLineGetStringRange(lineRef)
            let range = NSRange(location: lineRange.location, length: lineRange.length)
            
            let model = RangeModel()
            model.locations = range.location
            model.lengths = range.length
            linesArray.append(model)
        }
        
        return linesArray
    }

    // 获取 NSAttributedString 分割行文本
    static func getSeparatedLines(from labelString: NSAttributedString, frame labelFrame: CGRect) -> [NSAttributedString] {
        let rect = labelFrame
        let attStr = NSMutableAttributedString(attributedString: labelString)
        
        let frameSetter = CTFramesetterCreateWithAttributedString(attStr as CFAttributedString)
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: rect.size.width, height: 100000))
        
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        
        let lines = (CTFrameGetLines(frame) as NSArray) as! [Any]
        var linesArray: [NSAttributedString] = []
        
        for line in lines {
            let lineRef = line as! CTLine
            let lineRange = CTLineGetStringRange(lineRef)
            let range = NSRange(location: lineRange.location, length: lineRange.length)
            
            let lineString = labelString.attributedSubstring(from: range)
            linesArray.append(lineString)
        }
        
        return linesArray
    }

    // 获取 NSAttributedString 分割行文本，附加属性
    static func getSeparatedLines(from labelString: NSAttributedString, frame labelFrame: CGRect, attribute: [NSAttributedString.Key: Any]) -> [NSAttributedString] {
        let rect = labelFrame
        let attStr = NSMutableAttributedString(attributedString: labelString)
        attStr.addAttributes(attribute, range: NSRange(location: 0, length: attStr.length))
        
        let frameSetter = CTFramesetterCreateWithAttributedString(attStr as CFAttributedString)
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: rect.size.width, height: 100000))
        
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        
        let lines = (CTFrameGetLines(frame) as NSArray) as! [Any]
        var linesArray: [NSAttributedString] = []
        
        for line in lines {
            let lineRef = line as! CTLine
            let lineRange = CTLineGetStringRange(lineRef)
            let range = NSRange(location: lineRange.location, length: lineRange.length)
            
            let lineString = labelString.attributedSubstring(from: range)
            linesArray.append(lineString)
        }
        
        return linesArray
    }

    // 获取 NSAttributedString 分割行范围
    static func getSeparatedLinesRange(from labelString: NSAttributedString, frame labelFrame: CGRect) -> [RangeModel] {
        let rect = labelFrame
        let attStr = NSMutableAttributedString(attributedString: labelString)
        
        let frameSetter = CTFramesetterCreateWithAttributedString(attStr as CFAttributedString)
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: rect.size.width, height: 100000))
        
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        
        let lines = (CTFrameGetLines(frame) as NSArray) as! [Any]
        var linesArray: [RangeModel] = []
        
        for line in lines {
            let lineRef = line as! CTLine
            let lineRange = CTLineGetStringRange(lineRef)
            let range = NSRange(location: lineRange.location, length: lineRange.length)
            
            let model = RangeModel()
            model.locations = range.location
            model.lengths = range.length
            linesArray.append(model)
        }
        
        return linesArray
    }

    // 获取 NSAttributedString 分割行范围，附加属性
    static func getSeparatedLinesRange(from labelString: NSAttributedString, frame labelFrame: CGRect, attribute: [NSAttributedString.Key: Any]) -> [RangeModel] {
        let rect = labelFrame
        let attStr = NSMutableAttributedString(attributedString: labelString)
        attStr.addAttributes(attribute, range: NSRange(location: 0, length: attStr.length))
        
        let frameSetter = CTFramesetterCreateWithAttributedString(attStr as CFAttributedString)
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: rect.size.width, height: 100000))
        
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        
        let lines = (CTFrameGetLines(frame) as NSArray) as! [Any]
        var linesArray: [RangeModel] = []
        
        for line in lines {
            let lineRef = line as! CTLine
            let lineRange = CTLineGetStringRange(lineRef)
            let range = NSRange(location: lineRange.location, length: lineRange.length)
            
            let model = RangeModel()
            model.locations = range.location
            model.lengths = range.length
            linesArray.append(model)
        }
        
        return linesArray
    }

    // 查找字符串中某一子串的所有 range
    static func rangeOfSubString(_ subStr: String, in string: String) -> [String] {
        var rangeArray: [String] = []
        var i = 0
        
        while i + subStr.count <= string.count {
            let temp = (string as NSString).substring(with: NSRange(location: i, length: subStr.count))
            if temp == subStr {
                let range = NSRange(location: i, length: subStr.count)
                rangeArray.append(NSStringFromRange(range))
                i += subStr.count
            } else {
                i += 1
            }
        }
        return rangeArray
    }
}
