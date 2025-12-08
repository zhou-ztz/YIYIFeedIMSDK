//
//  IMSnapchatAttachment.swift
//  Yippi
//
//  Created by Tinnolab on 08/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class  IMSnapchatAttachment: CustomAttachment {

    var md5: String = ""
    var url: String = ""
    var filePath: String = ""
    var isFired: Bool = false

    var coverImage: UIImage?
    var isFromMe = false
    
    override func encode() -> String {
        let dictContent: [String : Any] = [CMMD5: self.md5,
                                           CMFIRE: self.isFired,
                                           CMURL: self.url]
        let dict: [String : Any] = [CMType: CustomMessageType.Snapchat.rawValue,
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
