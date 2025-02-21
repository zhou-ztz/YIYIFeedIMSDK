//
//  TGIMSearchLocalHistoryObject.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/17.
//

import UIKit
import NIMSDK

enum TGIMSearchLocalHistoryType: Int {
    case entrance
    case content
}

protocol TGIMSearchObjectRefresh: AnyObject {
    func refresh(_ object: TGIMSearchLocalHistoryObject)
}


class TGIMSearchLocalHistoryObject: NSObject {
    var content: String = ""
    var uiHeight: CGFloat = 0
    var type: TGIMSearchLocalHistoryType = .entrance
    let message: V2NIMMessage
    
    init(message: V2NIMMessage) {
        self.message = message
        self.content = message.text ?? ""
        self.uiHeight = 0
        super.init()
        self.calculateHistoryItemHeight()
    }
    
    private func calculateHistoryItemHeight() {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: SearchCellContentFontSize)
        label.text = content
        
        let itemTextSize = content.boundingRect(
            with: CGSize(width: SearchCellContentMaxWidth * UIScreen.main.bounds.width / 375.0, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin],
            attributes: [.font: label.font],
            context: nil
        ).size
        
        let labelHeight = max(SearchCellContentMinHeight, itemTextSize.height)
        let height = labelHeight + SearchCellContentTop + SearchCellContentBottom
        uiHeight = height
    }
}
