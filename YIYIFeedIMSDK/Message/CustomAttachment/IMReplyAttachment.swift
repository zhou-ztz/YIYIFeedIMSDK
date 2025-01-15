//
//  IMReplyAttachment.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2024/12/26.
//

import UIKit

class IMReplyAttachment: CustomAttachment {

    var content: String = ""
    var message: String = ""
    var name: String = ""
    var username: String = ""
    var image: String = ""
    var messageID: String = ""
    var messageType: String = ""
    var videoURL: String = ""
    var messageCustomType: String = ""
    
    override func encode() -> String {
        let dictContent: [String : Any] = [CMReplyContent : self.content,
                                           CMReplyMessage : self.message,
                                           CMReplyName : self.name,
                                           CMReplyUserName : self.username,
                                           CMReplyImageURL : self.image,
                                           CMReplyMessageID : self.messageID,
                                           CMReplyMessageType : self.messageType,
                                           CMReplyThumbURL : self.videoURL,
                                           CMReplyMessageCustomType : self.messageCustomType]
        let dict: [String : Any] = [CMType: CustomMessageType.Reply.rawValue,
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
