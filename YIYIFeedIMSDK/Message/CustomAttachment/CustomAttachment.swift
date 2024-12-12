//
//  CustomAttachment.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/11.
//

import UIKit
import NIMSDK

class CustomAttachment: NSObject {
    ///
    class func decodeAttachment(_ content: String?) -> (CustomMessageType?, NSDictionary?) {
        guard let _content = content, let data = _content.data(using: .utf8) else { return (nil, nil) }
        do {
            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                print(dict)
                let tt = dict.object(forKey: CMType) as? Int ?? Int(dict.object(forKey: CMType) as? String ?? "-1")
                let type = CustomMessageType(rawValue: tt ?? -1)
                let data = dict.object(forKey: CMData) as? NSDictionary ?? NSDictionary()
                return (type, data)

            }
        } catch let error {
            print(error.localizedDescription)
        }
        return (nil, nil)
    }
    
    /// 自定义白板
    class func WhiteBoardEncode(channel: String, creator: String) -> String {
        let dictContent: [String : Any] = [CMWhiteBoardChannel : channel,
                                           CMWhiteBoardCreator: creator]
        
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
    /// 音视频通话
    class func audioVideoEncode(callType: V2NIMSignallingChannelType, eventType: CallingEventType, duration: TimeInterval) -> String {
        let dictContent: [String : Any] = [CMCallType : callType.rawValue,
                                           CMEventType: eventType.rawValue,
                                           CMCallDuration: duration]
        
        let dict: [String : Any] = [CMType: CustomMessageType.VideoCall.rawValue,
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
