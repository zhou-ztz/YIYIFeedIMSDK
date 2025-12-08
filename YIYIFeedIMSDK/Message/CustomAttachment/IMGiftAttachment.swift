//
//  IMGiftAttachment.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/6/19.
//

import UIKit

class IMGiftAttachment: CustomAttachment {

    var message: String = ""
    var serviceTransactionId: String = ""
    var voucherId: String = ""
    var imageName: String = ""
    override func encode() -> String {
        var dictContent: [String : Any] = [:]
        
        dictContent = [CMGiftTransactionId:  self.serviceTransactionId,
                           CMGiftVoucherId: self.voucherId,
                    CMGiftImageName:  self.imageName]
        
        let dict: [String : Any] = [CMType: CustomMessageType.Gift.rawValue,
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
