//
//  IMEggAttachment.swift
//  Yippi
//
//  Created by Tinnolab on 08/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class IMEggAttachment: CustomAttachment {

    var message: String = ""
    var eggId: String = ""
    var senderId: String = ""
    var tid: String = ""
    var uids: NSArray = []
    
    override func encode() -> String {
        var dictContent: [String : Any] = [:]
        
        if tid == "" {
            dictContent = [CMEggMessage:  self.message,
                           CMEggId:  self.eggId,
                           CMEggSendId: self.senderId]
        } else {
            dictContent = [CMEggMessage:  self.message,
                           CMEggId:  self.eggId,
                           CMEggSendId: self.senderId,
                           CMEggOpenId: self.tid]
        }
        
        if self.uids.count > 0 {
            dictContent[CMEggUIDs] = self.uids
        }
        
        let dict: [String : Any] = [CMType: CustomMessageType.Egg.rawValue,
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
    
    
}
