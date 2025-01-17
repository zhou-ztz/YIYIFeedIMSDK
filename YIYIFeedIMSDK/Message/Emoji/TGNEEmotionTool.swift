
// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit

class TGNEEmotionTool: NSObject {
    class func getAttWithStr(str: String, font: UIFont,
                             _ offset: CGPoint = CGPoint(x: 0, y: -3), color: UIColor = RLColor.share.black3) -> NSMutableAttributedString {
        let regular = "\\[[^\\[|^\\]]+\\]"
        
        var reExpression: NSRegularExpression?
        do {
            reExpression = try NSRegularExpression(pattern: regular, options: .caseInsensitive)
        } catch {}
        // 找出所有符合正则的位置集合
        let regularArr = reExpression?.matches(
            in: str,
            options: .reportProgress,
            range: NSRange(location: 0, length: str.utf16.count)
        )
        
        let emoticons = TGNIMInputEmoticonManager.shared
            .emoticonCatalog(catalogID: NIMKit_EmojiCatalog)?.emoticons
        let attStr = NSMutableAttributedString(string: str, attributes: [
            NSAttributedString.Key.font: font,
            .foregroundColor: color,
        ])
        return attStr
    }
    
    class func getAttWithStr(str: String, font: UIFont, color: UIColor, _ offset: CGPoint = CGPoint(x: 0, y: -3)) -> NSMutableAttributedString {
        let att = getAttWithStr(str: str, font: font, offset)
        att.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: att.length))
        return att
    }
    
    
}
