//
//  EggModel.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/12.
//

import Foundation

enum TransferType: Int {
    case personal
    case group
    case reward
    case transfer
}

class ClaimEggResponse: NSObject, Decodable {
    let header: EggHeader
    let sender: EggUser
    let receivers: [EggReceivers]
    let eggInfo: ClaimEggInfo

    enum CodingKeys: String, CodingKey {
        case header
        case sender
        case receivers
        case eggInfo = "egg_info"
    }

    class EggHeader: NSObject, Decodable {
        let wishes: String
        let amount: String?
        let yippsMsg: String?
        let messages: String?
        let needSubscribe: Bool

        enum CodingKeys: String, CodingKey {
            case wishes = "wishes_message"
            case amount
            case yippsMsg = "yipps_messages"
            case messages
            case needSubscribe = "need_subscribe"
        }
    }

    class EggUser: NSObject, Decodable {
        let uid: Int
        let name: String
        let username: String
        let avatar: Avatar?

        enum CodingKeys: String, CodingKey {
            case uid = "id"
            case name
            case username
            case avatar
        }
    }

    class EggReceivers: NSObject, Decodable {
        let user: EggUser
        let amount: String
        let redeemTime: String
        var luckyStar: Int? = 0

        enum CodingKeys: String, CodingKey {
            case user
            case amount
            case redeemTime = "redeemed_time"
            case luckyStar = "lucky_star"
        }
    }

    class ClaimEggInfo:  NSObject, Decodable {
        let amount: String?
        let amountRemaining: String?
        let quantity: Int?
        let quantityRemaining: Int?
        let isRandom: Int?
        let eggId: Int
        let treasureTheme: TreasureTheme?
        let type: Int?
        let subscriberOnly: Bool?

        enum CodingKeys: String, CodingKey {
            case amount
            case amountRemaining = "amount_remaining"
            case quantity
            case quantityRemaining = "quantity_remaining"
            case isRandom = "is_random_amount"
            case eggId = "redpacket_id"
            case treasureTheme
            case type
            case subscriberOnly = "subscriber_only"
        }

        class TreasureTheme: NSObject, Decodable {
            let id: Int?
            let title, boxImage, backgroundImagePortrait, backgroundImageLandscape: String?

            enum CodingKeys: String, CodingKey {
                case title, id
                case boxImage = "treasure_box_open_url"
                case backgroundImagePortrait = "treasure_box_background_portrait_url"
                case backgroundImageLandscape = "treasure_box_background_landscape_url"
            }
        }
    }

}


class EggResponseModel: NSObject, Decodable {
    let isGroup: Bool?
    let owner: Owner
    let egg: Egg
    let liveEgg: LiveEgg?
    let receiver: [Owner]?
    let isFirstAttempt: Bool?
    
    enum CodingKeys: String, CodingKey {
        case isGroup = "is_group"
        case owner, receiver, egg, liveEgg
        case isFirstAttempt = "first_attempt"
    }
    
    class Owner: NSObject, Decodable {
        let id: Int
        let ownerID: Int?
        let title, body: String
        let type: Int
        let targetType:String?
        let targetID: String?
        let currency: Int
        let amount: String
        let state: Int
        let redpacketID: Int
        let amountRemaining: String
        let quantity, isRandomAmount, quantityRemaining: Int
        let groupID: String?
        let user: User
        let createdAt: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case ownerID = "owner_id"
            case title, body, type
            case targetType = "target_type"
            case targetID = "target_id"
            case currency, amount, state
            case redpacketID = "redpacket_id"
            case amountRemaining = "amount_remaining"
            case quantity
            case isRandomAmount = "is_random_amount"
            case quantityRemaining = "quantity_remaining"
            case groupID = "group_id"
            case user
            case createdAt = "created_at"
        }
    }
    
    // MARK: - User
    class User: NSObject, Decodable {
        let id: Int
        let name: String
        let avatar: Avatar?
        let official: Int
        let extra: Extra
        
        enum CodingKeys: String, CodingKey {
            case id, name, official, extra, avatar
        }
    }
    
    class Egg: Codable {
        let yipps: String?
        let yippsMessage: String
        let msg: String
        let isExpired: Bool
        
        enum CodingKeys: String, CodingKey {
            case yipps, msg
            case yippsMessage = "yipps_message"
            case isExpired = "is_expired"
        }
    }
    
    class Avatar: Codable {
        let url: String
        let size: Int
        
        enum CodingKeys: String, CodingKey {
            case url, size
        }
    }
    
    // MARK: - Extra
    class Extra: NSObject, Decodable {
        let userID, likesCount, commentsCount, followersCount: Int
        let followingsCount: Int
        let updatedAt: String
        let feedsCount, questionsCount, answersCount, checkinCount: Int
        let lastCheckinCount: Int
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case likesCount = "likes_count"
            case commentsCount = "comments_count"
            case followersCount = "followers_count"
            case followingsCount = "followings_count"
            case updatedAt = "updated_at"
            case feedsCount = "feeds_count"
            case questionsCount = "questions_count"
            case answersCount = "answers_count"
            case checkinCount = "checkin_count"
            case lastCheckinCount = "last_checkin_count"
        }
    }

    class LiveEgg: Codable {
        let treasureTheme: TreasureTheme?
        
        enum CodingKeys: String, CodingKey {
            case treasureTheme
        }
    }
    
    class TreasureTheme: Codable {
        let id: Int?
        let title, boxImage, backgroundImagePortrait, backgroundImageLandscape: String?
        
        enum CodingKeys: String, CodingKey {
            case title, id
            case boxImage = "treasure_box_open_url"
            case backgroundImagePortrait = "treasure_box_background_portrait_url"
            case backgroundImageLandscape = "treasure_box_background_landscape_url"
        }
    }
}





class EggInfo: NSObject {
    let nickname, points, headsmall, remarks: String
    
    init(nickname: String, points: String, headsmall: String, remarks: String)
    {
        self.nickname = nickname
        self.points = points
        self.headsmall = headsmall
        self.remarks = remarks
    }
}


class Detail: NSObject, Codable {
    let headsmall: String?
    let uid, username, nickname, points, opentime : String
    let fuid, friend, fnickname, fheadsmall, is_open: String?

    init(uid: String, username: String, nickname: String, headsmall: String?, points: String, opentime: String, fuid: String, friend: String, fnickname: String, fheadsmall: String, is_open: String) {
        self.uid = uid
        self.username = username
        self.nickname = nickname
        self.headsmall = headsmall
        self.points = points
        self.opentime = opentime
        self.fuid = fuid
        self.friend = friend
        self.fnickname = fnickname
        self.fheadsmall = fheadsmall
        self.is_open = is_open
    }
}

class GroupEgg: NSObject, Codable {
    let rid, uid, username, tid: String
    let points, pointsrmng, qty, remaining, timecreated: String
    let isRand, isRefund: String
    
    
    enum CodingKeys: String, CodingKey {
        case uid="uid", username="username", tid="tid", points="points", pointsrmng="pointsrmng", qty="qty", remaining="remaining"
        case isRefund = "is_refund"
        case isRand = "is_rand"
        case timecreated = "timecreated"
        case rid = "id"
    }
}

class PersonalEggData: NSObject, Decodable {
    let eggs: [PersonalEgg]?
    
    enum CodingKeys: String, CodingKey {
        case eggs = "eggs"
    }
}

class GroupEggData: NSObject, Decodable {
    let eggs: [GroupEgg]?
    let detail: [Detail]?
    
    enum CodingKeys: String, CodingKey {
        case eggs = "eggs"
        case detail = "detail"
    }
}

class PersonalEgg: NSObject, Codable {
    let uid: String
    let username: String
    var nickname: String?
    let headsmall: String
    let fuid: String
    let friend: String
    let fnickname: String
    let fheadsmall: String?
    let points: String
    let remarks: String
    let isOpen: String
    let isRefund: String
    let timecreated: String?

    
    enum CodingKeys: String, CodingKey {
        case uid
        case username = "user"
        case nickname = "nickname"
        case headsmall = "headsmall"
        case fuid = "fuid"
        case friend = "friend"
        case fnickname = "fnickname"
        case fheadsmall = "fheadsmall"
        case points = "points"
        case remarks = "remarks"
        case isOpen = "is_open"
        case isRefund = "is_refund"
        case timecreated = "timecreated"
    }
}

class ApiState: NSObject,Codable {
    let code: Int
    let msg, debugMsg, url: String
    
    enum CodingKeys: String, CodingKey {
        case code
        case msg
        case debugMsg
        case url
    }
}

struct Avatar: Codable {
    let size: Int?
    let vendor: String?
    let url: String?
    let mime: String?
    let dimension: Dimension?
}

struct Dimension: Codable {
    let width: Int?
    let height: Int?
}
