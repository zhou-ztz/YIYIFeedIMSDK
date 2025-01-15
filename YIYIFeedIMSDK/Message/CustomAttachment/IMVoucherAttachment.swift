//
//  IMVoucherAttachment.swift
//  RewardsLink
//
//  Created by Kit Foong on 17/07/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation

class IMVoucherAttachment: CustomAttachment {
    var postUrl: String = ""
    var title: String = ""
    var desc: String = ""
    var imageURL: String = ""
    var contentType: String = ""
    var contentUrl: String = ""
    
    override func encode() -> String {
        let dictContent: [String : Any] = [CMShareURL : self.postUrl,
                                           CMShareTitle: self.title,
                                           CMShareDescription: self.desc,
                                           CMShareImage: self.imageURL,
                                           CMShareContentType: self.contentType,
                                           CMShareContentUrl: self.contentUrl]
        
        let dict: [String : Any] = [CMType: CustomMessageType.Voucher.rawValue,
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
