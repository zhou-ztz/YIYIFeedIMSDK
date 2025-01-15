//
//  IMSocialPostAttachment.swift
//  Yippi
//
//  Created by Tinnolab on 08/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class IMSocialPostAttachment: CustomAttachment{
    var postUrl: String = ""
    var title: String = ""
    var desc: String = ""
    var imageURL: String = ""
    var contentType: String = ""
    var contentUrl: String = ""
    var contentDescribed: String = ""
    
    override func encode() -> String {
        let dictContent: [String : Any] = [CMShareURL : self.postUrl,
                                           CMShareTitle: self.title,
                                           CMShareDescription: self.desc,
                                           CMShareImage: self.imageURL,
                                           CMShareContentType: self.contentType,
                                           CMShareContentUrl: self.contentUrl,
                                           CMCampaignContent: self.contentDescribed]
        
        let dict: [String : Any] = [CMType: CustomMessageType.SocialPost.rawValue,
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
