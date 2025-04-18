//
//  ColorExtension.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/20.
//

import SwiftUI
import Foundation


extension Color {
    
    static func generate(r: Int, g: Int, b: Int) -> Color {
        return Color.init(red: Double(r)/255.0, green: Double(g)/255.0, blue: Double(b)/255.0)
    }
    
}

extension UIColor {

    func toColor(_ color: UIColor, percentage: CGFloat) -> UIColor {
        let percentage = max(min(percentage, 100), 0) / 100
        switch percentage {
        case 0: return self
        case 1: return color
        default:
            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            guard self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return self }
            guard color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return self }

            return UIColor(red: CGFloat(r1 + (r2 - r1) * percentage),
                    green: CGFloat(g1 + (g2 - g1) * percentage),
                    blue: CGFloat(b1 + (b2 - b1) * percentage),
                    alpha: CGFloat(a1 + (a2 - a1) * percentage))
        }
    }
}
