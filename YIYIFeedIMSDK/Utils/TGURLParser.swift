//
//  TGURLParser.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/8.
//

import UIKit
import SwiftLinkPreview

class TGURLParser: NSObject {
    static func parse(_ url: String, completion: ((String, String, String) -> Void)?) {
        SwiftLinkPreview().preview(url, onSuccess: { response in
            if let title = response.title, let desc = response.description, let image = response.image {
                completion?(title, desc, image)
            } else {
                completion?("", url, "")
            }
        }) { error in
            completion?("", url, "")
        }
    }
}
