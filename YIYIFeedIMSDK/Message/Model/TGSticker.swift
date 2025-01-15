//
//  File.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2024/12/23.
//

import Foundation

class StickerList: NSObject, Decodable {
    let items: [Sticker]?
    let totalSize: Int

    enum CodingKeys: String, CodingKey {
        case items
        case totalSize
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decode([Sticker]?.self , forKey: .items) {
            items = value
        } else {
            items = nil
        }
        totalSize = Int(try container.decodeIfPresent(String.self , forKey: .totalSize) ?? "0") ?? 0
    }
}
enum MetadataType: Codable {
    case int(Int)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = try .int(container.decode(Int.self))
        } catch DecodingError.typeMismatch {
            do {
                self = try .string(container.decode(String.self))
            } catch DecodingError.typeMismatch {
                throw DecodingError.typeMismatch(MetadataType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let int):
            try container.encode(int)
        case .string(let string):
            try container.encode(string)
        }
    }
}

struct Sticker: Decodable {
    let bundleIDType: MetadataType?
    let bundleIcon: String?
    let bundleName, description: String?
    let isOfficial, status, isGIF: Int?
    let isEvent: Int?
    let addedTimestamp: String?
    let downloadCount: Int?
    let bannerURL: String?
    let price: String?
    let slug: String?
    let voteCount: Int?
    let artist: Artist?
    let stickerList: [StickerList]?
    let stickers: [Sticker]?
    let todayStats: SOTDStats?
    let tipsCount: Int?
    let coverSize, bannerSize, stickerSize, backgroundColor: String?
    let stickerCreatedBy: String?
    // new artist
    let uid: Int?
    let hideViewMoment: Int?
    // recommend artist
    let artistID: Int?
    let artistName: String?
    let icon, banner: String?
    let stickerSet, totalPoints: Int?
    // category
    let id: Int?
    let name: String?
    let catID: Int?
    let image: String?
    
    var bundleID: Int? {
        guard let bundleid = bundleIDType else { return nil }
        switch bundleid {
        case .int(let val):
            return val
        case .string(let val):
            return Int(val)!
        }
    }
    
    struct SOTDStats: Codable {
        let bundleID, downloadCount, tipsCount, downloadPoints: Int
        let tipsAmount, amountPoints, totalPoints: Int

        enum CodingKeys: String, CodingKey {
            case bundleID = "bundle_id"
            case downloadCount = "download_count"
            case tipsCount = "tips_count"
            case downloadPoints = "download_points"
            case tipsAmount = "tips_amount"
            case amountPoints = "amount_points"
            case totalPoints = "total_points"
        }
    }
    
    struct StickerList: Codable {
        let stickerID, bundleID: Int
        let stickerIcon: String
        let stickerName: String
        let position: Int
        
        enum CodingKeys: String, CodingKey {
            case stickerID = "sticker_id"
            case bundleID = "bundle_id"
            case stickerIcon = "sticker_icon"
            case stickerName = "sticker_name"
            case position
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case bundleIDType = "bundle_id"
        case bundleIcon = "bundle_icon"
        case bundleName = "bundle_name"
        case description = "description"
        case isOfficial, status, isEvent
        case isGIF = "isGif"
        case catID = "cat_id"
        case addedTimestamp = "added_timestamp"
        case downloadCount = "download_count"
        case bannerURL = "banner_url"
        case price
        case artistID = "artist_id"
        case slug
        case voteCount = "vote_count"
        case tipsCount = "tips_count"
        case coverSize, bannerSize, stickerSize, backgroundColor
        case stickerCreatedBy = "sticker_created_by"
        case artist
        case todayStats = "today_statistics"
        case artistName = "artist_name"
        case icon, banner
        case stickerSet = "sticker_set"
        case totalPoints = "total_points"
        case uid
        case hideViewMoment = "hide_view_moment"
        case stickerList, stickers, id, name, image
    }
}

struct StickerLandingResponse: Decodable {
    var data: StickerHome?
}

struct StickerHome: Decodable {
    var stickers: [StickerCollectionSection]
    var banner: StickerHomeBannerSection?
}

enum StickerListingType: String, Codable {
    case grid, list, featured, unknown
    init(from decoder: Decoder) throws {
        self = try StickerListingType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

enum StickerType: String, Codable {
    case hot_stickers, stickers_of_the_day, new_sticker, recomended_artist, new_artist, featured_category, stickerByCategory, unknown
    init(from decoder: Decoder) throws {
        self = try StickerType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}


struct StickerCollectionSection: Decodable {
    let title: String
    let listingType: StickerListingType
    let type: StickerType
    let row: Int?
    let bgColor: String?
    var data: [Sticker]
    let titleStyle : String?
    let showScore: Bool
    let hasMoreData: Bool
    
    enum CodingKeys: String, CodingKey {
        case title, type
        case listingType = "listing_type"
        case data, row
        case bgColor = "bg_color"
        case titleStyle = "title_style"
        case showScore = "show_score"
        case hasMoreData = "load_more"
    }
}

struct StickerHomeBannerSection: Decodable {
    let title: String?
    let bannerList: [StickerBanner]?
    let delayMillisecond: Int

    enum CodingKeys: String, CodingKey {
        case bannerList = "banner_list"
        case delayMillisecond = "delay_milis"
        case title
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bannerList = try container.decodeIfPresent([StickerBanner].self, forKey: .bannerList)
        do {
            delayMillisecond = try container.decodeIfPresent(Int.self, forKey: .delayMillisecond) ?? 3000
        } catch {
            let delay = try container.decodeIfPresent(String.self, forKey: .delayMillisecond) ?? "3000"
            delayMillisecond = Int(delay)!
        }
        title = try container.decodeIfPresent(String.self, forKey: .title)
    }
}

enum StickerBannerActionType: String, Codable {
    case url, sticker, unknown
    init(from decoder: Decoder) throws {
        self = try StickerBannerActionType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

struct StickerBanner: Decodable {
    let bannerName: String
    let bundleId: Int?
    let bannerSequence: Int
    let bannerUrl: String?
    let actionType: StickerBannerActionType?
    let actionValue: String?

    enum CodingKeys: String, CodingKey {
        case bannerName = "banner_name"
        case bannerSequence = "banner_sequence"
        case bundleId = "bundle_id"
        case bannerUrl = "banner_url"
        case actionType = "action_type"
        case actionValue = "action_value"
    }
}

struct StickerListModel: Decodable {
    let data: StickerCollectionSection
}

struct StickerRankSection: Decodable {
    let title: String
    let data: [Sticker]
    
    enum CodingKeys: String, CodingKey {
        case title
        case data
    }
}

struct StickerPaidSection: Decodable {
    let title, listingType: String
    let type: StickerType
    let data: [Sticker]
    
    enum CodingKeys: String, CodingKey {
        case title
        case listingType = "listing_type"
        case type = "type"
        case data
    }
}

struct StickerDetail: Decodable {
    let bundle: Sticker
    let artist: Artist
    let stickers: [StickerItem]
    let isDownloaded: Bool

    enum CodingKeys: String, CodingKey {
        case bundle = "bundle"
        case artist = "artist"
        case stickers = "stickers"
        case isDownloaded = "is_downloaded"
    }
}

struct Artist: Codable {
    let artistIDType: MetadataType
    let artistName, description: String?
    let icon, banner: String?
    let uid: Int?
    
    var artistID: Int {
        switch artistIDType  {
        case .int(let val):
            return val
        case .string(let val):
            return Int(val)!
        }
    }
    
    
    enum CodingKeys: String, CodingKey {
        case artistIDType = "artist_id"
        case artistName = "artist_name"
        case description, icon, banner
        case uid
    }
}

@objcMembers
class StickerItem: NSObject, Decodable {
    let stickerID, bundleID: String
    let stickerIcon: String
    let stickerName, position: String
    
    enum CodingKeys: String, CodingKey {
        case stickerID = "sticker_id"
        case bundleID = "bundle_id"
        case stickerIcon = "sticker_icon"
        case stickerName = "sticker_name"
        case position
    }
    
    init(id: String, bundleId: String, icon: String, name: String, position: String) {
        self.stickerID = id
        self.bundleID = bundleId
        self.stickerIcon = icon
        self.position = position
        self.stickerName = name
    }
}

struct ArtistDetail: Decodable {
    var bundle: ArtistBundle
    let artist: [Artist]
}

struct ArtistBundle: Decodable {
    let title: String
    var data: [Sticker]
}

class UserBundleData: NSObject, Codable {
    var data: [UserBundle]
    enum CodingKeys: String, CodingKey {
        case data
    }
}

class UserBundle: NSObject, Codable {
    let uid, userID: String
    let bundleID: Int
    let bundleIcon: String
    let bundleName: String
    
    enum CodingKeys: String, CodingKey {
        case uid
        case userID = "user_id"
        case bundleID = "bundle_id"
        case bundleIcon = "bundle_icon"
        case bundleName = "bundle_name"
    }
    @objc func asJSON()->String?{
        do{
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)
        }catch{
            return nil
        }
    }
    
    required init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
            userID = try container.decode(String.self, forKey: .userID)
            bundleID = try container.decode(Int.self, forKey: .bundleID)
            bundleIcon = try container.decode(String.self, forKey: .bundleIcon)
            bundleName = try container.decode(String.self, forKey: .bundleName)
            uid = (try container.decodeIfPresent(String.self, forKey: .uid)) ?? "Unknown"
    }
    
}

@objcMembers
class CustomerStickerItem: NSObject, Decodable {
    let Typename: String?
    let customStickerId: String?
    let stickerUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case Typename = "__typename"
        case customStickerId = "custom_sticker_id"
        case stickerUrl = "sticker_url"
      
    }
    
    init(customStickerId: String, Typename: String, stickerUrl: String) {
        self.customStickerId = customStickerId
        self.Typename = Typename
        self.stickerUrl = stickerUrl
     
    }
}

@objcMembers
class CreateCustomerStickerItem: NSObject, Decodable {
    let data: CreateStickerItem
 
    enum CodingKeys: String, CodingKey {
        case data = "data"
   
    }
    
    init(data: CreateStickerItem) {
        self.data = data

    }
    
    class CreateStickerItem: NSObject, Decodable {
        let uploadCustomSticker: CustomerStickerItem
      
        enum CodingKeys: String, CodingKey {
            case uploadCustomSticker = "uploadCustomSticker"
          
          
        }
        
        init(uploadCustomSticker: CustomerStickerItem) {
            self.uploadCustomSticker = uploadCustomSticker
            
         
        }
    }
}

@objcMembers
class CreateCustomerMaxError: NSObject, Decodable {
    let errors: [ErrorItem]
 
    enum CodingKeys: String, CodingKey {
        case errors = "errors"
   
    }
    
    init(errors: [ErrorItem]) {
        self.errors = errors

    }
    
    class ErrorItem: NSObject, Decodable {
        let message: String
      
        enum CodingKeys: String, CodingKey {
            case message = "message"
          
        }
        
        init(message: String) {
            self.message = message
            
        }
    }
}


@objcMembers
class FetchCustomStickersItem: NSObject, Decodable {
    let __typename: String
    let cursor: String
    let node: CustomerStickerItem
    enum CodingKeys: String, CodingKey {
        case __typename = "__typename"
        case cursor = "cursor"
        case node = "node"
    }
    init(__typename: String, cursor: String, node: CustomerStickerItem) {
        self.__typename = __typename
        self.cursor = cursor
        self.node = node
        
     
    }
}
