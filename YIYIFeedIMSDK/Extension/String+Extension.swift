//
//  String+Extension.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司 on 2023/12/22.
//

import Foundation
import NaturalLanguage
import UIKit
import Regex
extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }
    
    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }
    
    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}

extension String {
    init(deviceToken: Data) {
        self = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
    }
    
    static var empty: String {
        return ""
    }
    
    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }
    
    func toInt() -> Int {
        return Int(self) ?? 0
    }
    
    func toDouble() -> Double {
        return Double(self) ?? 0
    }
    //获取emoji表情数组
    var emojis: [Character] {
        return filter{$0.isEmoji}
    }
    
    var firstLetter: String {
        let latinString = self.applyingTransform(StringTransform.toLatin, reverse: false) ?? "#"
        let noDiacriticString = latinString.applyingTransform(StringTransform.stripDiacritics, reverse: false) ?? "#"
        
        let firstLetter = noDiacriticString.prefix(1).uppercased()
        
        return String(firstLetter)
    }
    
    func toBdayDate(by format:String) -> Date {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = format
        dateFormatterGet.timeZone = TimeZone(abbreviation: "UTC")
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatterGet.date(from: self) {
            return (date)
        } else {
            return (Date())
        }
    }
    
    func toDate(from fromFormat: String = "yyyy-MM-dd HH:mm:ss", to toFormat: String) -> String {
        let df = DateFormatter()
        df.dateFormat = fromFormat
        df.timeZone = TimeZone(abbreviation: "UTC")
        if let date = df.date(from: self) {
            df.dateFormat = toFormat
            df.timeZone = TimeZone.current
            return df.string(from: date)
        } else {
            return ""
        }
    }
    
    func toUTCDate(from fromFormat: String = "yyyy-MM-dd HH:mm:ss", to toFormat: String) -> String {
        let df = DateFormatter()
        df.dateFormat = fromFormat
        df.timeZone = TimeZone.current
        if let date = df.date(from: self) {
            df.dateFormat = toFormat
            df.timeZone = TimeZone(abbreviation: "UTC")
            return df.string(from: date)
        } else {
            return ""
        }
    }
    
    func convertDateFromString(timeType: Int) -> String {
        let data = Date(timeIntervalSince1970: TimeInterval(self) ?? 0.0)
        let df = DateFormatter()
        if(timeType == 0) {
            df.dateFormat = "yyyy-MM-dd HH:mm"
        } else if(timeType == 1) {
            df.dateFormat = NSLocalizedString("dateformat4", comment: "")
        } else if(timeType == 2) {
            df.dateFormat = "yyyy-MM-dd"
        } else if(timeType == 3) {
            df.dateFormat = NSLocalizedString("dateformat5", comment: "")
        }
        let date = df.string(from: data)
        return date
    }
    
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                
            }
        }
        return nil
    }
    
    
    var urlValue: URL? {
        return URL(string: self)
    }
    
    // By Kit Foong (Same as checkFileIsExist, just add paremeter for appended name for file checking)
    func checkFileIsExistSpecial(appendname: String) -> String? {
        var theFileName : String?
        let url = URL(fileURLWithPath: self)
        theFileName = url.deletingPathExtension().lastPathComponent + "_" + appendname.replacingOccurrences(of: " ", with: "") + "." + url.pathExtension
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let filePath = documentsUrl!.appendingPathComponent(theFileName!.removingPercentEncoding!)
        if FileManager.default.fileExists(atPath: filePath.path) {
            return filePath.path
        } else {
            return nil
        }
    }
    
    func checkFileIsExist() -> String? {
        let theFileName = URL(fileURLWithPath: self).lastPathComponent
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let filePath = documentsUrl!.appendingPathComponent(theFileName.removingPercentEncoding!)
        if FileManager.default.fileExists(atPath: filePath.path) {
            return filePath.path
        } else {
            return nil
        }
    }
    
    func getUrlStringFromString() -> String? {
        let tempStrArray = self.components(separatedBy: "\n")
        var urlString: String? = nil
        for i in 0 ..< tempStrArray.count {
            if tempStrArray[i].isURL() {
                urlString = getURLStringFromSubstring(text: tempStrArray[i])
            }
        }
        return  urlString
    }
    
    func getURLStringFromSubstring(text: String) -> String? {
        let pattern = "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)"
        var match = ""
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .init(rawValue: 0))
            let nsstr = text as NSString
            let all = NSRange(location: 0, length: nsstr.length)
            regex.enumerateMatches(in: text, options: .init(rawValue: 0), range: all, using: { (result, flags, _) in
                match = nsstr.substring(with: result!.range)
            })
        } catch {
            return ""
        }
        return match
    }
    
    func isURL() -> Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
            for match in matches {
                guard let _ = Range(match.range, in: self) else { continue }
                return true
            }
        } catch let error {
            assert(false, error.localizedDescription)
            return false
        }
        return false
    }
    static func format(strings: [String], boldFont: UIFont = UIFont(name: "PingFangTC-Regular", size: 11.0) ?? UIFont.boldSystemFont(ofSize: 14), boldColor: UIColor = UIColor(red: 74.0/255.0, green: 144.0/255.0, blue: 226.0/255.0, alpha: 1.0), inString string: String, font: UIFont = UIFont.systemFont(ofSize: 11), color: UIColor = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color])
        let boldFontAttribute = [NSAttributedString.Key.font: boldFont, NSAttributedString.Key.foregroundColor: boldColor]
        for bold in strings {
            attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: bold))
        }
        return attributedString
    }
    /// 获取字符宽度
    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size
    }
}

// MARK: - 正则表达式判断
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    /// 正则匹配判断
    /// TODO: - 这里的正则判断似乎有问题。下面地方一起使用时就会出问题。待研究解决
    //    /// 判断是否含有图片
    //    func ts_isContainImageNode() -> Bool {
    //        let imgRegex = "@!\\[(.*)]\\(([0-9]+)\\)"
    //        return self.isMatchRegex(imgRegex)
    //    }
    func isMatchRegex(_ regex: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    func replacingFirstOccurrence(of target: String, with replacement: String) -> String {
        guard let range = self.range(of: target) else { return self }
        return self.replacingCharacters(in: range, with: replacement)
    }
    
    func replacingLastOccurrenceOfString(of searchString: String,
                                         with replacementString: String,
                                         caseInsensitive: Bool = true) -> String {
        let options: String.CompareOptions
        if caseInsensitive {
            options = [.backwards, .caseInsensitive]
        } else {
            options = [.backwards]
        }
        
        if let range = self.range(of: searchString,
                                  options: options,
                                  range: nil,
                                  locale: nil) {
            
            return self.replacingCharacters(in: range, with: replacementString)
        }
        return self
    }
}

// MARK: - 字符串与时间的相互转换

extension String {
    /// 将字符串转换为Date
    @available(*, deprecated, message: "服务器提供的时间格式不允许再使用该方式转换,查看 TransformType")
    func date(format: String = "yyyy-MM-dd HH:mm:ss", timeZone: TimeZone? = TimeZone(identifier: "GMT")) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        return date
    }
    
    /// 将时间格式转换为 date
    @available(*, deprecated, message: "服务器提供的时间格式不允许再使用该方式转换,查看 TransformType")
    func convertToDate() -> NSDate {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var date = dateFormatter.date(from: self)
        if date == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            date = dateFormatter.date(from: self)
        }
        let nDate = date ?? Date()
        return NSDate(timeIntervalSince1970: nDate.timeIntervalSince1970)
    }
    
    func toDate(_ dateFormat: String? = "yyyy-MM-dd HH:mm:ss") -> Date {
        let df = DateFormatter()
        df.dateFormat = dateFormat
        df.timeZone = TimeZone(identifier: "GMT")
        df.locale = Locale(identifier: "en_US_POSIX")
        return df.date(from: self) ?? Date()
    }
}

// MARK: - 字符串长宽计算

extension String {
    
    func size(maxSize: CGSize, font: UIFont, lineMargin: CGFloat = 0) -> CGSize {
        let options: NSStringDrawingOptions = NSStringDrawingOptions.usesLineFragmentOrigin
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineMargin // 行间距
        var attributes = [NSAttributedString.Key: Any]()
        attributes[NSAttributedString.Key.font] = font
        attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        let str = self as NSString
        let textBounds = str.boundingRect(with: maxSize, options: options, attributes: attributes, context: nil)
        return textBounds.size
    }
    
    /// 计算属性文本的高度
    /// 注意： 使用此方法计算高度之前请保证你的属性文本是否设置了正确的属性 否则计算结果不准确概不负责
    ///
    /// - Parameters:
    ///   - attributeString: 待计算的文本
    ///   - maxWidth: 最大宽度
    ///   - maxHeight: 最大高度
    /// - Returns: 文本高度
    static func getAttributeStringHeight(attributeString: NSMutableAttributedString, maxWidth: CGFloat, maxHeight: CGFloat) -> CGFloat {
        let strSize = attributeString.boundingRect(with:CGSize(width: maxWidth, height: maxHeight), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        return strSize.height
    }
    
    /// 获取固定宽度的字符串高度
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    // MARK: - 计算字符串宽高
    func heightWithConstrainedWidth(width: CGFloat, height: CGFloat, font: UIFont) -> CGSize {
        let constraintRect = CGSize(width: width, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.size
    }
}

// MARK: - 其他杂项

extension String {
    
    /// 本地化字符串
    /// - note 请前往 infoPlist.strings 手动添加各语言信息
    var localized: String {
        let value = NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
        if !value.isEmpty {
            return value
        }
        guard let path = Bundle.main.path(forResource: "en", ofType: "lproj"), let enBundle = Bundle(path: path) else {
            return value
        }
        return NSLocalizedString(self, tableName: nil, bundle: enBundle, value: "", comment: "")
    }
    /// 截取字符串
    func subString(with range: NSRange) -> String {
        guard let swiftRange = Range(range, in: self) else {
            return ""
        }
        return String(self[swiftRange])
    }
    /// 将字符串数组转为 数组
    /// 例如 "1,2,3" -> [1, 2, 3]
    @available(*, deprecated, message: "服务器提供的时间格式不允许再使用该方式转换,查看 TransformType")
    func convertNumberArray() -> Array<Int>? {
        let stringArray = self.components(separatedBy: ",")
        var uids: Array<Int> = []
        if stringArray.isEmpty {
            return nil
        }
        for string in stringArray {
            if string == "" {
                continue
            }
            uids.append(Int(string)!)
        }
        return uids
    }
    
    /// 快速返回一个缓存目录的路径
    func cacheDir() -> String {
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
        return (cachePath as NSString).appendingPathComponent((self as NSString).pathComponents.last!)
    }
}

// MARK: - NSMutableAttributedString

extension String {
    // Remark: - 哪个无聊的人写的下面的方法
    /// 返回自定义属性文本 【字号、行间距】
    ///
    /// - Parameters:
    ///   - string: 原文本
    ///   - font: 字号
    ///   - lineSpacing: 行间距
    ///   - textAlignment: 文本对齐方式
    /// - Returns: 格式化后的属性文本
    static func setStyleAttributeString(string: String, font: UIFont, lineSpacing: CGFloat, textAlignment: NSTextAlignment) -> NSMutableAttributedString {
        let attributeSring = NSMutableAttributedString(string: string)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineSpacing = lineSpacing
        attributeSring .addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font: font], range: NSRange(location: 0, length: CFStringGetLength(string as CFString)))
        return attributeSring
    }
}

extension NSMutableAttributedString {
    
    /// 两种颜色和尺寸的字体
    ///
    /// - Parameters:
    ///   - first: 第一段文字的各种参数
    ///   - second: 第二段文字的各种参数
    /// - Returns: 返回拼接好的文字
    func differentColorAndSizeString(first : (firstString: NSString, firstColor: UIColor, font: UIFont), second : (secondString: NSString, secondColor: UIColor, font: UIFont)) -> NSMutableAttributedString {
        let noteStr = NSMutableAttributedString(string: "\(first.firstString)"+"\(second.secondString)")
        let fStr: NSString = (noteStr.string as NSString?)!
        let fRange: NSRange = (fStr.range(of: first.firstString as String))
        
        let rangeOne = NSRange(location: fRange.location, length: fRange.length)
        noteStr.addAttribute(NSAttributedString.Key.foregroundColor, value: first.firstColor, range: rangeOne)
        
        let sRange: NSRange = (fStr.range(of: second.secondString as String))
        let rangetwo = NSRange(location: sRange.location, length: sRange.length)
        noteStr.addAttribute(NSAttributedString.Key.foregroundColor, value: second.secondColor, range: rangetwo)
        
        noteStr.addAttribute(NSAttributedString.Key.font, value: first.font, range: rangeOne)
        noteStr.addAttribute(NSAttributedString.Key.font, value: second.font, range: rangetwo)
        
        return noteStr
    }
    
    // 便利构造
    class func attString(str: String, font: UIFont, color: UIColor) -> NSMutableAttributedString {
        let attString = NSMutableAttributedString(string: str)
        let allRange = NSRange(location: 0, length: attString.length)
        attString.addAttributes([NSAttributedString.Key.foregroundColor: color], range: allRange)
        attString.addAttributes([NSAttributedString.Key.font: font], range: allRange)
        return attString
    }
    convenience init(str: String, font: UIFont?, color: UIColor?) {
        self.init(string: str)
        let allRange = NSRange(location: 0, length: self.length)
        if let font = font {
            self.addAttribute(NSAttributedString.Key.font, value: font, range: allRange)
        }
        if let color = color {
            self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: allRange)
        }
    }
    
    /// 设置全部文字字体
    ///
    /// - Parameter font: 字体
    /// - Returns: 富文本
    func setAllTextFont(font: UIFont) -> NSMutableAttributedString {
        let attributeString = self
        attributeString.addAttributes([NSAttributedString.Key.font: font], range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }
    /// 设置文字字体大小
    ///
    /// - Parameter font: 字体大小
    /// - Returns: 文字
    func setTextFont(_ font: CGFloat, isFeed: Bool = false) -> NSMutableAttributedString {
        let attributeString = self
        if isFeed {
            attributeString.addAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font)], range: NSRange(location: 0, length: attributeString.length))
        } else {
            attributeString.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: font)], range: NSRange(location: 0, length: attributeString.length))
        }
        return attributeString
    }

    /// 给文字添加行间距
    ///
    /// - Parameters:
    ///   - lineSpacing: 行间距
    /// - Returns: 格式后的文字
    func setlineSpacing(_ lineSpacing: CGFloat) -> NSMutableAttributedString {
        let attributeString = self
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = lineSpacing / 2.0
        paragraphStyle.headIndent = 0.000_1
        paragraphStyle.tailIndent = -0.000_1
        paragraphStyle.alignment = .left
        attributeString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }

    /// 给文字添加字间距
    ///
    /// - Parameter kerning: 字间距
    /// - Returns: 文字
    func setKerning(_ kerning: CGFloat) -> NSMutableAttributedString {
        let attributeString = self
        attributeString.addAttributes([NSAttributedString.Key.kern: kerning], range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }
    
    func attributedKeyDictionry(with stringKeyDictionary: [String: Any]) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        for (key, value) in stringKeyDictionary {
            attributes[NSAttributedString.Key(key)] = value
        }
        return attributes
    }
    
    func setUnderlinedAttributedText() -> NSMutableAttributedString {
        let attributeString = self
        let textRange = NSMakeRange(0, self.length)
        attributeString.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
        return attributeString
    }
}

extension Dictionary {
    /// 转换字典为 JSON 字符串
    var toJSON: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted]) else {
            return nil
        }
        return String(data: theJSONData, encoding: .utf8)
    }
}

extension String {
    /// 转换 JSON 字符串为字典
    var toDictionary: [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                // 处理错误
            }
        }
        return nil
    }
}
extension String {
    /// 获取自定义markdown格式的图片正则表达式
    static func ts_customImageMarkdownRegexString() -> String {
        // ".*?" 懒惰匹配
        return "@!\\[(.*?)\\]\\((\\d+)\\)"
    }

    /// 获取标准markdown格式的图片的正则表达式
    static func ts_standardImageMarkdownRegexString() -> String {
        // ".*?" 懒惰匹配
        return "!\\[(.*?)\\]\\((.*?)\\)"
    }
    
    /// 获取图片的Regex
    static func ts_customImageMarkdownRegex() -> Regex {
        return Regex("@!\\[(.*?)\\]\\((\\d+)\\)")
    }

    static func ts_standardImageMarkdownRegex() -> Regex {
        return Regex("!\\[(.*?)\\]\\((.*?)\\)")
    }
    
    /// 自定义的markdown格式的内容转展示的内容：将自定义格式的图片转换成 ""
    /// 比如帖子列表中内容的自定义标签处理
    func ts_customMarkdownToClearString() -> String {
        var string: String = self
        let imgRegex = String.ts_customImageMarkdownRegex()
        string.replaceAll(matching: imgRegex, with: "")
        return string
    }
    
    func removeNewLineChar() -> String? {
        return self.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "\n\r", with: "\n").replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\n", with: "                                                                                            ")
    }
    
    func isValidURL() -> Bool {
        var escapedString = self.removingPercentEncoding
        
        let head = "((http|https)://)?([(w|W)]{3}+\\.)?"
        let tail = "\\.+[A-Za-z]{2,3}+(\\.)?+(/(.)*)?"
        let urlRegEx = head + "+(.)+" + tail
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[urlRegEx])
        return predicate.evaluate(with: escapedString)
    }
}

extension String {
    func attributonString() -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self)
    }
}

extension String {
    
    func transformToPinYin() ->String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let string = String(mutableString)
        return string.replacingOccurrences(of: " ", with: "").uppercased()
    }
    
    func isNotLetter()-> Bool {
        if self.count == 0 {
            return false
        }
        let upperCaseStr: String = self.uppercased()
        let c = Character(upperCaseStr)
        if  c >= "A", c <= "Z"{
            return false
        } else {
            return true
        }
    }
}

extension String {
    //给html string 添加<span style="font-family: -apple-system; font-size: 18.0px; color: #000000;">Hello, <b>World</b>!</span>
    func toHTMLString(size: String, color: String = "#000000") -> NSMutableAttributedString?{
        
        let text = "<span style=\"font-family: -apple-system; font-size: \(size)px; color: \(color);\">" + self + "</span>"
        print("HTMLString = \(text)")
        if let data = text.data(using: .utf8) {
            let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue)], documentAttributes: nil)
                return attributedString
        }else{
            return nil
        }
    }
    
    //移除<b> <\b>
    func toRemoveHTMLString(size: CGFloat, color: String = "#000000") -> NSMutableAttributedString?{
        // 设置字体、字体颜色和大小
        let font = UIFont.systemFont(ofSize: size)
        let fontColor = UIColor(hex: color, alpha: 1)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: fontColor
        ]
        if let data = self.data(using: .utf8) {
            let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue)], documentAttributes: nil)
            attributedString?.addAttributes(attributes,range: NSRange(location: 0, length: attributedString?.length ?? 0))
            return attributedString
        }else{
            return nil
        }
    }
    
    /// 将 HTML 字符串转换为富文本
    func htmlStringToAttributedString() -> NSAttributedString? {
        guard let data = self.data(using: .utf8) else { return nil }
        
        do {
            let attributedString = try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            return attributedString
        } catch {
            print("加载 HTML 富文本失败: \(error)")
            return nil
        }
    }

}
