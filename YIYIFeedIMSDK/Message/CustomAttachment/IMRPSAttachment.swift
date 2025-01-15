//
//  IMRPSAttachment.swift
//  Yippi
//
//  Created by Tinnolab on 08/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class IMRPSAttachment: CustomAttachment {

    var value: Int = 0
    
    override func encode() -> String {
        
        let dictContent: [String : Int] = [CMValue: self.value]
        let dict: [String : Any] = [CMType: CustomMessageType.RPS.rawValue,
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
