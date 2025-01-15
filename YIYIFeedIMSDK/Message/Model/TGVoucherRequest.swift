//
//  TGVoucherRequest.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/2.
//

import Foundation


struct VoucherDetailsResponse: Decodable {
    let id, gatewayId: Int?
    let name, description, descriptionLong: String?
    let accountType, type : String?
    let imageURL, logoURL: [String]?
    let videoURL: String?
    let redemptionOnlineInstruction, redemptionInstoreInstruction, cardTerms: String?
    let packages: [VoucherPackage]?
    let transactionFee: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case gatewayId = "gateway_id"
        case name, description
        case descriptionLong = "description_long"
        case accountType = "account_type"
        case type
        case imageURL = "image_url"
        case logoURL = "logo_url"
        case videoURL = "video_url"
        case redemptionOnlineInstruction = "redemption_online_instruction"
        case redemptionInstoreInstruction = "redemption_instore_instruction"
        case cardTerms = "card_terms"
        case packages
        case transactionFee = "transaction_fee"
    }
}

struct VoucherPackage: Decodable {
    let productID, providerID: Int?
    let price: String?
    let minAmount, maxAmount, offsetCurrency, originalCurrency: String?
    var title, description: String?
    var imageURL, logoURL: String?
    let sortOrder: Int?
    let offsetAmount, offsetYipps, offsetPercentage, rebatePercentage: String?
    var maxQuantity: Int?
    var quantity: Int = 0
    var selectedIndex: Int = 0
    var isDisable: Bool = false
    var isSelected: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case providerID = "provider_id"
        case price
        case minAmount = "min_amount"
        case maxAmount = "max_amount"
        case offsetCurrency = "offset_currency"
        case title, description
        case imageURL = "image_url"
        case sortOrder = "sort_order"
        case offsetAmount = "offset_amount"
        case offsetYipps = "offset_yipps"
        case offsetPercentage = "offset_percentage"
        case rebatePercentage = "rebate_percentage"
        case maxQuantity = "max_quantity"
        case originalCurrency = "original_currency"
    }
}
