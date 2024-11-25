//
//  RLColor.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2023/12/11.
//

import Foundation
import UIKit

class RLColor {
    static let share = RLColor()
    //主题色  136 64 242
    var theme: UIColor {
        return UIColor(red: 136, green: 64, blue: 242)
    }
    
    var lightGray: UIColor {
        return UIColor.lightGray
    }
    var backGroundGray: UIColor {
        return UIColor(hex: 0xEEEEEE)
    }
    
    var themeRed: UIColor {
        return UIColor(hex: 0xF28D6F)
    }
    
    var black3: UIColor {
        return UIColor(hex: 0x333333)
    }
    
    var black: UIColor {
        return .black
    }
    
    var backGray: UIColor {
        return UIColor(red: 245, green: 245, blue: 245)
    }
    
    var deepOrange: UIColor {
        return UIColor(red: 238, green: 116, blue: 71)
    }
    
    //主题渐变色[]
    var gradientColors: [CGColor] {
        return [UIColor(red: 228, green: 121, blue: 248).cgColor, UIColor(red: 139, green: 94, blue: 240).cgColor]
    }
    
    //淡淡的主题色
    var lightTheme: UIColor {
        return UIColor(hex: 0xF8F7FC)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(hex: Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }

    convenience init(hex: Int, alpha: CGFloat) {
        self.init(red: CGFloat((hex >> 16) & 0xff) / 255.0, green: CGFloat((hex >> 8) & 0xff) / 255.0, blue: CGFloat(hex & 0xff) / 255.0, alpha: alpha)
    }
    
    convenience init(hex: String, alpha: CGFloat = 1) {
        let chars = Array(hex.dropFirst())
        self.init(red:   .init(strtoul(String(chars[0...1]),nil,16))/255,
                  green: .init(strtoul(String(chars[2...3]),nil,16))/255,
                  blue:  .init(strtoul(String(chars[4...5]),nil,16))/255,
                  alpha: alpha)
        
    }
    
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1.0)
    }
}
