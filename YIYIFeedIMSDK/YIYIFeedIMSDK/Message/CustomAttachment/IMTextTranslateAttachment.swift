//
//  IMTextTranslateAttachment.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/20.
//

import UIKit

class IMTextTranslateAttachment: CustomAttachment {

    var oriMessageId: String = ""
    var originalText: String = ""
    var translatedText: String = ""
    var isOutgoingMsg: Bool = true
    
    override func encode() -> String {
        let dictContent: [String : Any] = [ CMOriginalMessageId: self.oriMessageId,
                                            CMOriginalMessage: self.originalText,
                                            CMTranslatedMessage : self.translatedText,
                                            CMTranslatedMessageIsOutgoing : self.isOutgoingMsg]
        let dict: [String : Any] = [CMType: CustomMessageType.Translate.rawValue,
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
