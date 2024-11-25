//
//  String+Extension.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司 on 2023/12/22.
//

import Foundation
import NaturalLanguage
import UIKit

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

public extension String {
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
