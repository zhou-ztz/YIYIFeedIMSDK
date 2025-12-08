//
//  IMMiniProgramAttachment.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/15.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

class IMMiniProgramAttachment: CustomAttachment{
    
    var imageURL: String = ""
    var title: String = ""
    var desc: String = ""
    var appId: String = ""
    var path: String = ""
    var contentType: String = ""
    
    override func encode() -> String {
        
        let dictContent: [String : Any] = [CMAppId: self.appId,
                                           CMPath: self.path,
                                           CMMPTitle: self.title,
                                           CMMPDesc: self.desc,
                                           CMMPAvatar : self.imageURL,
                                           CMMPType: self.contentType]
        
        let dict: [String : Any] = [CMType: CustomMessageType.MiniProgram.rawValue,
                                    CMData: dictContent]
        
        var stringToReturn = "{}"
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
