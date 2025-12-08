//
//  TGLocalizationManager.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/19.
//

import UIKit
import SwiftyUserDefaults

var bundleKey: UInt8 = 0

enum TGLanguageIdentifier: String, CaseIterable {
    case english = "en"
    case chineseSimplified = "zh-Hans"
    case chineseTraditional = "zh-Hant"
    case korean = "ko"
    case filipino = "fil"
    case indonesian = "id"
    case japanese = "ja"
    case malay = "ms"
    case thai = "th"
    case vietnamese = "vi"
    
    var twoLetterCode: String {
        switch self {
        case .english: return "en"
        case .chineseSimplified: return "cn"
        case .chineseTraditional: return "cn"
        case .korean: return "ko"
        case .filipino: return "ph"
        case .indonesian: return "in"
        case .japanese: return "ja"
        case .malay: return "my"
        case .thai: return "th"
        case .vietnamese: return "vi"
        }
    }
    
    var txtLanguageCode: String {
        switch self {
        case .english: return "en"
        case .chineseSimplified: return "zh"
        case .chineseTraditional: return "zh"
        case .korean: return "kr"
        case .filipino: return "ph"
        case .indonesian: return "id"
        case .japanese: return "jp"
        case .malay: return "ms"
        case .thai: return "th"
        case .vietnamese: return "vi"
        }
    }
    
    var txtTranslateTwoLetterCode: String {
        switch self {
        case .english: return "en"
        case .chineseSimplified: return "zh"
        case .chineseTraditional: return "zh-TW"
        case .korean: return "kr"
        case .filipino: return "ph"
        case .indonesian: return "id"
        case .japanese: return "jp"
        case .malay: return "ms"
        case .thai: return "th"
        case .vietnamese: return "vi"
        }
    }
    
    var txtISOCode: String {
        switch self {
        case .english: return "en"
        case .chineseSimplified: return "zh-CN"
        case .chineseTraditional: return "zh-TW"
        case .korean: return "kr"
        case .filipino: return "ph"
        case .indonesian: return "id"
        case .japanese: return "jp"
        case .malay: return "ms"
        case .thai: return "th"
        case .vietnamese: return "vi"
        }
    }
}


class TGLocalizationManager: NSObject {

    private static let defaultLanguage = "en"
    
    private static var preferredLanguageCode: String {
        guard let preferredLanguage = Locale.preferredLanguages.first else {
            return defaultLanguage
        }
        return preferredLanguage
    }
    
    class func availableLanugages() -> [String] {
        return [TGLanguageIdentifier.english.rawValue, TGLanguageIdentifier.chineseSimplified.rawValue, TGLanguageIdentifier.chineseTraditional.rawValue, TGLanguageIdentifier.korean.rawValue, TGLanguageIdentifier.indonesian.rawValue, TGLanguageIdentifier.malay.rawValue, TGLanguageIdentifier.japanese.rawValue, TGLanguageIdentifier.filipino.rawValue, TGLanguageIdentifier.thai.rawValue, TGLanguageIdentifier.vietnamese.rawValue]
    }
    
    class func getDisplayNameForLanguageIdentifier(identifier: String) -> String {
        switch identifier {
        case TGLanguageIdentifier.chineseSimplified.rawValue:
            return "简体中文"
        case TGLanguageIdentifier.chineseTraditional.rawValue:
            return "繁体中文"
        case TGLanguageIdentifier.korean.rawValue:
            return "한국어f"
        case TGLanguageIdentifier.filipino.rawValue:
            return "Tagalog"
        case TGLanguageIdentifier.indonesian.rawValue:
            return "Bahasa Indonesian"
        case TGLanguageIdentifier.japanese.rawValue:
            return "日本語"
        case TGLanguageIdentifier.malay.rawValue:
            return "Bahasa Malaysia"
        case TGLanguageIdentifier.thai.rawValue:
            return "ไทย"
        case TGLanguageIdentifier.vietnamese.rawValue:
            return "Tiếng Việt"
        default:
            return "English"
        }
    }
    
    class func getDefaultLanguage() -> String {
        var langCode = preferredLanguageCode
        let splitArray = langCode.components(separatedBy: "-")
        
        if splitArray.count > 1 {
            if let index = langCode.lastIndex(of: "-") {
                let substring = langCode[..<index]
                langCode = String(substring)
            }
        }
        
        setCurrentLanguage(identifier: langCode)
        return langCode
    }
    
    class func getISOLanguageCode() -> String {
        let TGLanguageIdentifier = TGLanguageIdentifier(rawValue: getCurrentLanguage()) ?? .english
        return TGLanguageIdentifier.txtISOCode
    }
    
    class func getShortLanguageCode() -> String {
        let TGLanguageIdentifier = TGLanguageIdentifier(rawValue: getCurrentLanguage()) ?? .english
        return TGLanguageIdentifier.twoLetterCode
    }
    
    class func getTxtTranslateShortLanguageCode() -> String {
        let TGLanguageIdentifier = TGLanguageIdentifier(rawValue: getCurrentLanguage()) ?? .english
        return TGLanguageIdentifier.txtTranslateTwoLetterCode
    }
    
    class func getCurrentLanguage() -> String {
        guard let currentLanguage = Defaults.currentLanguage else {
            return getDefaultLanguage()
        }
        
        return currentLanguage == "" ? getDefaultLanguage() : currentLanguage
    }
    
    class func getCurrentLanguageCode() -> String {
        guard let currentLanguage = Defaults.currentLanguage else {
            return getDefaultLanguage()
        }
        let lang = currentLanguage.components(separatedBy: "-")
        if lang.count > 0 {
            return lang[0]
        }
        return currentLanguage == "" ? getDefaultLanguage() : currentLanguage
    }
    
    class func getCurrentISOLanguageCode() -> String {
        guard let currentLanguage = Defaults.currentLanguage else {
            return getDefaultLanguage()
        }
        
        return currentLanguage == "" ? getDefaultLanguage() : currentLanguage
    }
    
    class func setCurrentLanguage(identifier: String) {
        let selectedLanguage = availableLanugages().contains(identifier) ? identifier : defaultLanguage
        
        Defaults.currentLanguage = selectedLanguage
        
        if identifier == TGLanguageIdentifier.english.rawValue {
            UserDefaults.standard.set([TGLanguageIdentifier.english.rawValue, TGLanguageIdentifier.chineseSimplified.rawValue], forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.set([selectedLanguage, TGLanguageIdentifier.english.rawValue], forKey: "AppleLanguages")
        }
        UserDefaults.standard.synchronize()
    }
    
    class func applyAppLanguage() {
        Bundle.setLanguage(getCurrentLanguage())
    }
    
    class func isUsingChinese() -> Bool {
        return [TGLanguageIdentifier.chineseSimplified.rawValue, TGLanguageIdentifier.chineseTraditional.rawValue].contains(getCurrentLanguage())
    }
}

class BundleEx: Bundle {
    override func localizedString(forKey key: String,
                                  value: String?,
                                  table tableName: String?) -> String {
        
        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
            let bundle = Bundle(path: path) else {
                
                return super.localizedString(forKey: key, value: value, table: tableName)
        }
        
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    class func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, BundleEx.self)
        }
        
        objc_setAssociatedObject(Bundle.main, &bundleKey,    Bundle.main.path(forResource: language, ofType: "lproj"), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

extension DefaultsKeys {
    var currentLanguage: DefaultsKey<String?> { .init("yippi.app.currentLanguage") }
}

