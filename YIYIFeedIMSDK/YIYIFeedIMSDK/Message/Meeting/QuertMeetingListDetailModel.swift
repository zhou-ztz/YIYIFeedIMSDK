//
//  QuertMeetingListDetailModel.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/22.
//

import Foundation
import ObjectMapper

struct QuertMeetingListModel:  Mappable{
    var data: MeetingSettingModel?
    var massage: String = ""
    
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        data <- map["data"]
        massage <- map["massage"]
    }
}

struct MeetingSettingModel:  Mappable{
    var data: [QuertMeetingListDetailModel]?
    var currentPage: Int = 0
    
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        data <- map["data"]
        currentPage <- map["current_page"]
    }
}



struct QuertMeetingListDetailModel:  Mappable{
    var id: Int = 0
    var type: Int = 0
    var meetingId: Int = 0
    var password: String = ""
    var meetingNum: Int = 0
    var subject: String = ""
    var startTime: String = ""
    var endTime: String = ""
    //var settings: MeetingSettingModel?
    var roleBinds: [String : Any] = [:]
    var status: String = ""
    var meetingShortNum: String = ""
    var deletedAt: String?
    var created_at: String = ""
    var updated_at: String = ""
    var ownerUserUuid: String = ""
    var ownerNickname: String = ""
    var roomArchiveId: String = ""
    var meeting_start_at: String?
    var meeting_end_at: String?
    var members_count: Int = 0
    var members: [MeetingMemberModel]?
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        type <- map["type"]
        meetingId <- map["meetingId"]
        password <- map["password"]
        meetingNum <- map["meetingNum"]
        subject <- map["subject"]
        startTime <- map["startTime"]
        endTime <- map["endTime"]
        //settings <- map["settings"]
        roleBinds <- map["roleBinds"]
        status <- map["status"]
        meetingShortNum <- map["meetingShortNum"]
        deletedAt <- map["deleted_at"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        ownerUserUuid <- map["ownerUserUuid"]
        ownerNickname <- map["ownerNickname"]
        roomArchiveId <- map["roomArchiveId"]
        meeting_start_at <- map["meeting_start_at"]
        meeting_end_at <- map["meeting_end_at"]
        members_count <- map["members_count"]
        members <- map["members"]
    }
}

struct MeetingRoleBindsModel:  Mappable{
    
    var currentPage: Int = 0
    
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        
        currentPage <- map["current_page"]
    }
}

struct MeetingMemberModel:  Mappable{
    var id: Int = 0
    var meeting_id: Int = 0
    var userUuid: String = ""
    var role_type: String = ""
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        meeting_id <- map["meeting_id"]
        userUuid <- map["userUuid"]
        role_type <- map["role_type"]
    }
}

struct JoinMeetingResponse: Decodable {
    //let massage: String = ""
    let data: JoinInfo
    enum CodingKeys: String, CodingKey {
        //case massage
        case data
    }
}
struct JoinInfo: Decodable{
    var meetingLevel: Int = 0
    var meetingTimeLimit: Int = 0
    var meetingMemberLimit: Int = 0
    var roomUuid: Int = 0
    var meetingInfo: MeetingInfo?
    enum CodingKeys: String, CodingKey {
        case meetingLevel = "meeting_level"
        case meetingTimeLimit = "meeting_time_limit"
        case meetingMemberLimit = "meeting_member_limit"
        case roomUuid
        case meetingInfo = "meeting_info"
    }
}

struct MeetingInfo: Decodable{
    var startTime: String = ""
    var endTime: String = ""
    var isPrivate: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case startTime
        case endTime
        case isPrivate
    }
}



struct MeetingPayInfo:  Mappable{
    
    var data: PayInfo?
    var massage: String = ""
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        data <- map["data"]
        massage <- map["massage"]
    }
    
    
}

struct PayInfo: Mappable {
    var level: Int = 0 // 0 未付费 ，1 付过年费
    var meetingTimeLimit: String = ""
    var meetingMemberLimit: String = ""
    var meetingVipAt: String? = ""
    var meetingPrice: String = ""
    var freeMemberLimit: String = ""
    var freeTimeLimit: String = ""
    //var vipMeetingTimeLimit: String = ""
    var vipMeetingMemberLimit: String = ""
    
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        level <- map["meeting_level"]
        meetingTimeLimit <- map["meeting_time_limit"]
        meetingMemberLimit <- map["meeting_member_limit"]
        meetingVipAt <- map["meeting_vip_at"]
        meetingPrice <- map["meeting_price"]
        freeMemberLimit <- map["free_member_limit"]
        freeTimeLimit <- map["free_time_limit"]
        //vipMeetingTimeLimit <- map["vip_time_limit"]
        vipMeetingMemberLimit <- map["vip_member_limit"]
    }
}

struct MeetingPayment:  Mappable{
    var data: Payment?
    var code: Int = 0
    var message: String = ""
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        data <- map["data"]
        code <- map["code"]
        message <- map["message"]
    }
    
}
struct Payment:  Mappable{
    var expiredAt: String?
    var residue: Int?
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        expiredAt <- map["expired_at"]
        residue <- map["residue"]
    }
}


struct MeetingInvitedResponse: Decodable {
    var code: Int?
    enum CodingKeys: String, CodingKey {
        case code
    }
}

struct CreateMeetingResponse: Decodable {
    let data: CreateMeetingInfo
    enum CodingKeys: String, CodingKey {
        case data
    }
}
struct CreateMeetingInfo: Decodable {
    let subject: String
    let meetingId: Int
    let meetingNum: String
    var meetingShortNum: String
    var password: String
    var status: Int
    var type: Int = 0
    var roomArchiveId: String
    var roomUuid: String = ""
    var settings: SettingsInfo?
    enum CodingKeys: String, CodingKey {
        case subject
        case meetingId
        case meetingNum
        case meetingShortNum
        case password
        case type
        case status
        case roomArchiveId
        case roomUuid
        case settings
    }
    
   
}
struct SettingsInfo: Decodable {
    var roomInfo: RoomInfo?
    enum CodingKeys: String, CodingKey {
        case roomInfo
    }
}
struct RoomInfo: Decodable {
    var password: String?
    enum CodingKeys: String, CodingKey {
        case password
    }
}

struct MeetingKitAccountModel: Mappable {
    
    var appKey: String = ""
    var createdAt: String = ""
    var id: Int = 0
    var privateMeetingNum: Int = 0
    var settings: String = ""
    var shortMeetingNum: Int = 0
    var updatedAt: String = ""
    var userToken: String = ""
    var userUuid: String = ""
    var userId: String = ""
   
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        appKey <- map["app_key"]
        createdAt <- map["created_at"]
        privateMeetingNum <- map["privateMeetingNum"]
        settings <- map["settings"]
        shortMeetingNum <- map["shortMeetingNum"]
        updatedAt <- map["updated_at"]
        userToken <- map["userToken"]
        userUuid <- map["userUuid"]
        userId <- map["user_id"]
    }
}

