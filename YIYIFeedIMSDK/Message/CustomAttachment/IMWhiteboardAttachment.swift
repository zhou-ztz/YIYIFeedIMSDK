//
//  IMWhiteboardAttachment.swift
//  RewardsLink
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/3/15.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit

class IMWhiteboardAttachment: CustomAttachment  {

    var channel: String = ""
    var creator: String = ""
    override func encode() -> String {
        let dictContent: [String : Any] = [CMWhiteBoardChannel : self.channel,
                                           CMWhiteBoardCreator: self.creator]
        
        let dict: [String : Any] = [CMType: CustomMessageType.WhiteBoard.rawValue,
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
        return true
    }
}
