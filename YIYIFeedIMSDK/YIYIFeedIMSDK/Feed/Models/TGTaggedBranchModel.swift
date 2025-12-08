//
//  TGTaggedBranchModel.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/10/22.
//

import ObjectMapper
//import SwiftyJSON

class TGTaggedBranchModel: Mappable {
    var data: [TGTaggedBranchData]?
    var filter: TGTaggedBranchFilter?
    var pagination: TGTaggedBranchPagination?
    var miniProgramAppId: String?
    var miniProgramDealPath: String?
    
    required init?(map: Map){}
    
    func mapping(map: Map) {
        data <- map["data"]
        filter <- map["filter"]
        pagination <- map["pagination"]
        miniProgramAppId <- map["miniProgramAppId"]
        miniProgramDealPath <- map["miniProgramDealPath"]
    }
}
    
// MARK: - TGTaggedBranchData
class TGTaggedBranchData: Mappable {
    var branchID: String?
    var merchantID: Int?
    var distance: Double?
    var longitude, latitude, branchName, category: String?
    var miniProgramBranchID: Int?
    var businessLogo: String?
    var merchantName: String?
    var offset, rebate, miniProgramMerchantID, yippiUserID: Int?
    var yippiUsername, displayDistance, categoryLokaliseKey: String?
    
    required init?(map: Map){}

    convenience init() {
        self.init(map: Map(mappingType: .fromJSON, JSON: [:]))!
    }
    
    func mapping(map: Map) {
        branchID <- map["branchId"]
        merchantID <- map["merchantId"]
        distance <- map["distance"]
        longitude <- map["longitude"]
        latitude <- map["latitude"]
        branchName <- map["branchName"]
        category <- map["category"]
        miniProgramBranchID <- map["miniProgramBranchId"]
        businessLogo <- map["businessLogo"]
        merchantName <- map["merchantName"]
        offset <- map["offset"]
        rebate <- map["rebate"]
        miniProgramMerchantID <- map["miniProgramMerchantId"]
        yippiUserID <- map["yippiUserId"]
        yippiUsername <- map["yippiUsername"]
        displayDistance <- map["displayDistance"]
        categoryLokaliseKey <- map["categoryLokaliseKey"]
    }
    
    static func convert(_ object: [TGTaggedBranchData]?) -> String? {
        guard let object = object else { return nil }
        return object.toJSONString()
    }
    
    static func convert(_ json: String?) -> [TGTaggedBranchData]? {
        guard let json = json else { return nil }
        return Mapper<TGTaggedBranchData>().mapArray(JSONString: json)
    }
}

// MARK: - TGTaggedBranchFilter
class TGTaggedBranchFilter: Mappable {
    var keyword: String?
    var longitude, latitude: Double?
    var page, limit: Int?
    var countryCode: String?

    required init?(map: Map){}
    
    func mapping(map: Map) {
        keyword <- map["keyword"]
        longitude <- map["longitude"]
        latitude <- map["latitude"]
        page <- map["page"]
        limit <- map["limit"]
        countryCode <- map["countryCode"]
    }
}

// MARK: - TGTaggedBranchPagination
class TGTaggedBranchPagination: Mappable {
    var total, itemsCount, currentPage, offset: Int?
    var limit: Int?
    
    required init?(map: Map){}
    
    func mapping(map: Map) {
        total <- map["total"]
        itemsCount <- map["itemsCount"]
        currentPage <- map["currentPage"]
        offset <- map["offset"]
        limit <- map["limit"]
    }
}

