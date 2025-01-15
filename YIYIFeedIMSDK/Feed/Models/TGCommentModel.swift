//
//  TGCommentModel.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2024/12/26.
//

import Foundation

// MARK: - Response Model
struct TGCommentModelResponse: Codable {
    
    var message: String?
    var comment: TGFeedCommentListModel?
    
    
}
