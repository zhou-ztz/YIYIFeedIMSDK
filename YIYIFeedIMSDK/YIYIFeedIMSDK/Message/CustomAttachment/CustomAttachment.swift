//
//  CustomAttachment.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/11.
//

import UIKit
import NIMSDK

class CustomAttachment: NSObject {
    
    func canBeForwarded() -> Bool {
        return false
    }
    
    func encode() -> String {
        return ""
    }
    
}
