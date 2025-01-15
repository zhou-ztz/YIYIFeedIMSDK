//
//  IMStickerAttachment.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2024/12/24.
//

import UIKit

class IMStickerAttachment: CustomAttachment {
    var chartletId: String = "" // id
    var stickerId: String = ""
    var chartletCatalog: String = ""
    
    override func encode() -> String {
        let dictContent: [String : Any] = [CMChartlet: self.chartletId,
                                           CMCatalog: self.chartletCatalog,
                                           CMStickerId: self.stickerId]
        let dict: [String : Any] = [CMType: CustomMessageType.Sticker.rawValue,
                                    CMData: dictContent]
        
        var stringToReturn = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            stringToReturn = String(data: jsonData, encoding: .utf8) ?? ""
        } catch let error {
            print(error.localizedDescription)
        }
        return stringToReturn
    }
    
    override func canBeForwarded() -> Bool {
        return false
    }
}
