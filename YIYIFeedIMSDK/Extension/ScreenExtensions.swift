//
//  ScreenExtensions.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/2/7.
//

import Foundation
import UIKit

extension CGRect {
    var minEdge: CGFloat {
        return min(width, height)
    }
}

extension UIScreen {
    var minEdge: CGFloat {
        return UIScreen.main.bounds.minEdge
    }
}
