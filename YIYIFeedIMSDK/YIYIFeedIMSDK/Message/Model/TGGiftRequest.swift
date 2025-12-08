//
//  TGGiftRequest.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/6/19.
//

import Foundation

// MARK: - PandaGiftStatusResponse
struct PandaGiftStatusResponse: Codable {
    let message: String?
    let purchase: GiftStatusResponse?
    
    enum CodingKeys: String, CodingKey {
        case message = "message"
        case purchase = "purchase"
    }
}

struct GiftStatusResponse: Codable {
    let id: Int?
    let imageUrl: [String]?
    let logoUrl: [String]?
    let voucherName: String?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case imageUrl = "image_url"
        case logoUrl = "logo_url"
        case voucherName = "voucher_name"
        case id
        case status
    }
}
