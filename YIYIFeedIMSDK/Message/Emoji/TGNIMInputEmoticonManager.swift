
// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
enum NIMEmoticonType: NSInteger {
    case file = 0
    case unicode
}

class NIMInputEmoticon: NSObject {
    var type: NIMEmoticonType {
        if let ucode = unicode, ucode.count > 0 {
            return .unicode
        } else {
            return .file
        }
    }
    
    var emoticonID: String?
    var tag: String?
    var fileName: String?
    var unicode: String?
}

class NIMInputEmoticonLayout: NSObject {
    var rows: NSInteger = 0 // 行数
    var columes: NSInteger = 0 // 列数
    var itemCountInPage: NSInteger = 0 // 每页显示几项
    var cellWidth: CGFloat = 0 // 单个单元格宽
    var cellHeight: CGFloat = 0 // 单个单元格高
    var imageWidth: CGFloat = 0 // 显示图片的宽
    var imageHeight: CGFloat = 0 // 显示图片的高
    var emoji: Bool?
    
    init(width: CGFloat) {
        rows = NIMKit_EmojRows
        columes =
        ((Int(width) - NIMKit_EmojiLeftMargin - NIMKit_EmojiRightMargin) /
         Int(NIMKit_EmojImageWidth))
        itemCountInPage = rows * columes - 1
        cellWidth =
        CGFloat((Int(width) - NIMKit_EmojiLeftMargin - NIMKit_EmojiRightMargin) / columes)
        cellHeight = NIMKit_EmojCellHeight
        imageWidth = NIMKit_EmojImageWidth
        imageHeight = NIMKit_EmojImageHeight
        emoji = true
    }
}

class NIMInputEmoticonCatalog: NSObject {
    var layout: NIMInputEmoticonLayout?
    var catalogID: String?
    var title: String?
    var id2Emoticons: [String: NIMInputEmoticon]?
    var tag2Emoticons: [String: NIMInputEmoticon]?
    var emoticons: [NIMInputEmoticon]?
    /// 图标
    var icon: String?
    /// 小图标按下效果
    var iconPressed: String?
    /// 分页数
    var pagesCount: NSInteger = 0
}

class TGNIMInputEmoticonManager: NSObject {
    static let shared = TGNIMInputEmoticonManager()
    private var catalogs: [NIMInputEmoticonCatalog]?
    private var classTag = "TGNIMInputEmoticonManager"
    
    override init() {
        super.init()
        parsePlist()
        preloadEmoticonResource()
    }
    
    func parsePlist() {
        var catalogs = [NIMInputEmoticonCatalog]()
        let filePath = Bundle.nim_EmojiPlistFile()
        if let path = filePath {
            let array = NSArray(contentsOfFile: path)
            array?.forEach { dict in
                if let convertDict = (dict as? NSDictionary) {
                    let info = convertDict["info"] as? [String: Any]
                    let emotions = convertDict["data"] as? NSArray
                    let cataLog = catalogByInfo(
                        info: info as NSDictionary?,
                        emoticonsArray: emotions
                    )
                    catalogs.append(cataLog)
                }
            }
        }
        self.catalogs = catalogs
    }
    
    func catalogByInfo(info: NSDictionary?, emoticonsArray: NSArray?) -> NIMInputEmoticonCatalog {
        let cataLog = NIMInputEmoticonCatalog()
        
        guard let infoDict = info, let emotions = emoticonsArray else {
            return cataLog
        }
        cataLog.catalogID = infoDict["id"] as? String
        cataLog.title = infoDict["title"] as? String
        cataLog.icon = infoDict["normal"] as? String
        cataLog.iconPressed = infoDict["pressed"] as? String
        var tag2Emoticons = [String: NIMInputEmoticon]()
        var id2Emoticons = [String: NIMInputEmoticon]()
        var resultEmotions = [NIMInputEmoticon]()
        
        emotions.forEach { emoticonDict in
            if let dict = (emoticonDict as? NSDictionary) {
                let emotion = NIMInputEmoticon()
                emotion.emoticonID = dict["id"] as? String
                emotion.tag = dict["tag"] as? String
                emotion.unicode = dict["unicode"] as? String
                emotion.fileName = dict["file"] as? String
                
                if let id = emotion.emoticonID, id.count > 0 {
                    resultEmotions.append(emotion)
                    id2Emoticons[id] = emotion
                }
                if let tag = emotion.tag, tag.count > 0 {
                    tag2Emoticons[tag] = emotion
                }
            }
        }
        cataLog.emoticons = resultEmotions
        cataLog.id2Emoticons = id2Emoticons
        cataLog.tag2Emoticons = tag2Emoticons
        return cataLog
    }
    
    func preloadEmoticonResource() {}
    
    func emoticonCatalog(catalogID: String) -> NIMInputEmoticonCatalog? {
        guard let infos = catalogs else { return nil }
        
        for catalog in infos {
            if catalog.catalogID == catalogID {
                return catalog
            }
        }
        return nil
    }
    
    func emoticonByTag(tag: String) -> NIMInputEmoticon? {
        var emotion: NIMInputEmoticon?
        
        guard let clogs = catalogs else {
            return emotion
        }
        
        if tag.count > 0 {
            for catalog in clogs {
                if let tag2Emotions = catalog.tag2Emoticons {
                    emotion = tag2Emotions[tag]
                    if let _ = emotion {
                        break
                    }
                }
            }
        }
        return emotion
    }
    
    func emoticonByID(emoticonID: String) -> NIMInputEmoticon? {
        var emotion: NIMInputEmoticon?
        guard let clogs = catalogs else {
            return emotion
        }
        
        if emoticonID.count > 0 {
            for catalog in clogs {
                if let id2Emoticons = catalog.id2Emoticons {
                    emotion = id2Emoticons[emoticonID]
                    if let _ = emotion {
                        break
                    }
                }
            }
        }
        return emotion
    }
    
    func emoticonByCatalogID(catalogID: String, emoticonID: String) -> NIMInputEmoticon? {
        var emotion: NIMInputEmoticon?
        guard let clogs = catalogs else {
            return emotion
        }
        
        if catalogID.count > 0, emoticonID.count > 0 {
            for catalog in clogs {
                if catalog.catalogID == catalogID {
                    if let id2Emoticons = catalog.id2Emoticons {
                        emotion = id2Emoticons[emoticonID]
                        break
                    }
                }
            }
        }
        return emotion
    }
}

extension Bundle {
    class func nim_defaultEmojiBundle() -> Bundle? {
        let bundle = Bundle(for: TGNIMInputEmoticonManager.self)
        let url = bundle.url(forResource: "NIMKitEmoticon", withExtension: "bundle")
        var emojiBundle: Bundle?
        if let url = url {
            emojiBundle = Bundle(url: url)
        }
        return emojiBundle
    }
    
    class func nim_EmojiPlistFile() -> String? {
        let bundle = Bundle.nim_defaultEmojiBundle()
        
        let resource = "emoji_ios_cn"
        let filepath = bundle?.path(
            forResource: resource,
            ofType: "plist",
            inDirectory: NIMKit_EmojiPath
        )
        return filepath
    }
    
    class func nim_EmojiImage(imageName: String) -> String? {
        let bundle = Bundle.nim_defaultEmojiBundle()
        var ext = URL(fileURLWithPath: imageName).pathExtension
        if ext.count == 0 {
            ext = "png"
        }
        let name = URL(fileURLWithPath: imageName).deletingPathExtension().path
        let doubleImage = name + "@2x"
        let tribleImage = name + "@3x"
        var path: String?
        if UIScreen.main.scale == 3.0 {
            path = bundle?.path(
                forResource: tribleImage,
                ofType: ext,
                inDirectory: NIMKit_EmojiPath
            )
        }
        if let imagePath = path, imagePath.count > 0 {
        } else {
            path = bundle?.path(
                forResource: doubleImage,
                ofType: ext,
                inDirectory: NIMKit_EmojiPath
            )
        }
        return path
    }
}
extension UIImage {
    class func ne_imageNamed(name: String?) -> UIImage? {
        guard let imageName = name else {
            return nil
        }
        return UIImage.set_image(named: imageName)
    }
    
    class func ne_bundleImage(name: String) -> UIImage {
        // 图片放到 framework 的 bundle 中可使用
        let bundleName = "NIMKitEmoticon.bundle/Emoji/\(name)"
        if let image = UIImage.ne_imageNamed(name: bundleName) {
            return image
        }
        return UIImage()
    }
}
