//
//  IMMeetingRoomAttachment.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/7.
//

import UIKit

class IMMeetingRoomAttachment: CustomAttachment {
    var meetingId: String = ""
    var meetingNum: String = ""
    var meetingShortNum: String = ""
    var meetingPassword: String = ""
    var meetingStatus: String = ""
    var meetingSubject: String = ""
    var meetingType: Int = 0
    var roomArchiveId: String = ""
    var roomUuid: String = ""
    
    override func encode() -> String {
        let dictContent: [String : Any] = [CMMeetingId : self.meetingId,
                                           CMMeetingNum : self.meetingNum,
                                           CMMeetingShortNum : self.meetingShortNum,
                                           CMMeetingPassword : self.meetingPassword,
                                           CMMeetingStatus : self.meetingStatus,
                                           CMMeetingSubject : self.meetingSubject,
                                           CMMeetingType : self.meetingType,
                                           CMRoomArchiveId : self.roomArchiveId,
                                           CMRoomUuid : self.roomUuid]
        
        let dict: [String : Any] = [CMType: CustomMessageType.MeetingRoom.rawValue,
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
