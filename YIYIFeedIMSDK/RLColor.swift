//
//  RLColor.swift
//
//
//  Created by 深圳壹艺科技有限公司-zhi on 2023/12/11.
//

import Foundation
import UIKit

let rl_defalut_placeholder_image = UIImage.set_image(named: "rl_placeholder")

class RLColor {
    static let share = RLColor()
    //主题色  136 64 242
    var theme: UIColor {
        return UIColor(hex: 0xED1A3B)
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
    
    class var headerTitleGrey: UIColor {
        return UIColor(red: 128, green: 128, blue: 128)
    }
    
    /// 主要颜色
    class var main: MainColor {
        return MainColor()
    }
    /// 常规颜色
    class var normal: NormalColor {
        return NormalColor()
    }
    /// 角落色
    class var inconspicuous: InconspicuousColor {
        return InconspicuousColor()
    }
    /// 特殊色 (非常少使用)
    class var small: SmallColor {
        return SmallColor()
    }
    /// 按钮相关颜色
    class var button: ButtonColor {
        return ButtonColor()
    }
    
    class var theme: ThemeColor {
        return ThemeColor()
    }
}

class MainColor {
    /// 主题色
    ///
    /// - 需要特别强调的文字、icon、按钮
    /// - 例如底部导航栏高亮按钮、顶部标题栏右侧可点击状态文字按钮、文章标题、填充类色块按钮、粉丝/点赞/关注/喜欢数 等
    var theme: UIColor {
        return UIColor(hex: 0xED1A3B)
    }
    /// 蓝色按钮色
    ///
    /// - UIUX0707版本常用的蓝色按钮背景色
    var blue: UIColor {
        return UIColor(hex: 0x19AAFE)
    }
    
    var red: UIColor {
        return UIColor(hex: 0xED1A3B)
    }
    
    /// 正文, 内容以及标题颜色
    ///
    /// - 重要的列表标题文字、正文内容
    /// - 例如标题栏标题、个人中心类列表项文字、用户昵称、聊天详情页聊天内容、弹窗内重要文字、详情页正文文字 等
    var content: UIColor {
        return UIColor(hex: 0x333333)
    }
    /// 警示色
    ///
    /// - 点赞心形图标高亮、新消息提示、警告
    var warn: UIColor {
        return UIColor(hex: 0xf4504d)
    }
    /// 白色
    var white: UIColor {
        return UIColor.white
    }
    /// bar颜色
    var barTitle: UIColor {
        return UIColor(hex: 0x707c81)
    }
    
    /// 主要颜色
    class var main: MainColor {
        return MainColor()
    }
    /// 常规颜色
    class var normal: NormalColor {
        return NormalColor()
    }
    /// 角落色
    class var inconspicuous: InconspicuousColor {
        return InconspicuousColor()
    }
    /// 特殊色 (非常少使用)
    class var small: SmallColor {
        return SmallColor()
    }
    /// 按钮相关颜色
    class var button: ButtonColor {
        return ButtonColor()
    }
    
    class var theme: ThemeColor {
        return ThemeColor()
    }
    
}

class NormalColor {
    /// 正文, 内容以及标题颜色
    var content: UIColor {
        return UIColor(hex: 0x666666)
    }
    /// 常用黑色标题颜色
    var blackTitle: UIColor {
        return UIColor(hex: 0x333333)
    }
    /// 辅助色
    ///
    ///- 例如用户列表页用户简介、个人中心/主页 简介、评论内容、不重要的按钮（取消）、消息列表消息内容、粉丝/关注列表 粉丝数、相册列表照片张数 等
    var minor: UIColor {
        return UIColor(hex: 0x999999)
    }
    /// 次要色
    ///
    ///- 浏览量、点赞图标及其文字、动态详情页底部操作栏图标及文字、不可点击状态下文字按钮等
    var secondary: UIColor {
        return UIColor(hex: 0xb2b2b2)
    }
    /// 缺陷色
    ///
    /// - 时间、提示文字、色块类按钮不可点击状态
    var disabled: UIColor {
        return UIColor(hex: 0xcccccc)
    }
    /// 文本框占位符颜色
    var placeholder: UIColor {
        return UIColor(hex: 0xebebeb)
    }
    /// 输入框占位符颜色
    var textFieldPlaceholder: UIColor {
        return UIColor(hex: 0x9B9B9B)
    }
    /// 刷新字体色
    var refreshText: UIColor {
        return UIColor(hex: 0xb3b3b3)
    }

    /// 键盘文本工具栏顶部分割线颜色
    var keyboardTopCutLine: UIColor {
        return UIColor(hex: 0xd9d9d9)
    }

    /// 图片占位色
    var imagePlaceholder: UIColor {
        return UIColor(hex: 0xdedede)
    }
    /// 统计字数颜色
    var statisticsNumberOfWords: UIColor {
        return UIColor(hex: 0xee2727)
    }

    /// 背景颜色
    var background: UIColor {
        return UIColor(hex: 0xffffff)
    }

    /// 透明的背景
    var transparentBackground: UIColor {
        return UIColor(hex: 0x000000, alpha: 0.2)
    }
    
    var gold: UIColor {
        return UIColor(hex: 0xfed757)
    }
}

class InconspicuousColor {
    /// 突出的分割色
    ///
    /// - 顶部标题栏、底部操作栏灰色分割线、键盘升起的分割线、拍照框的描边
    var highlight: UIColor {
        return UIColor(hex: 0xdedede)
    }
    /// 残缺的分割色
    ///
    /// - 页面内的浅色分割线
    var disabled: UIColor {
        return UIColor(hex: 0xededed)
    }
    /// 背景色
    var background: UIColor {
        return UIColor(hex: 0xf4f5f5)
    }
    /// 标签栏色
    var tabBar: UIColor {
        return UIColor(hex: 0xFFFFFF)
    }
    /// 导航栏标题色
    var navTitle: UIColor {
        return UIColor(hex: 0x333333)
    }
    /// 导航栏标题色
    var navHighlightTitle: UIColor {
        return UIColor(hex: 0x000000)
    }
}

class SmallColor {
    /// 聊天收到消息气泡背景色
    var incomingBubble: UIColor {
        return UIColor(hex: 0xffffff)
    }
    /// 聊天发送消息气泡背景色
    var outgoingBubble: UIColor {
        return UIColor(hex: 0x3bb3ff)
    }
    /// 聊天收到消息气泡边框色
    var incomingBubbleBorderAround: UIColor {
        return UIColor(hex: 0xdee1e2)
    }
    /// 聊天发送消息气泡边框色
    var outgoingBubbleBorderAround: UIColor {
        return UIColor(hex: 0x87c6dd)
    }
    /// 键盘输入框背景色
    var toolBarBackground: UIColor {
        return UIColor(hex: 0xfafafa)
    }
    /// 打赏金额颜色
    var rewardText: UIColor {
        return UIColor(hex: 0xf76c69)
    }
    /// 发布按钮字体颜色
    var releaseBtnTitle: UIColor {
        return UIColor(hex: 0x575757)
    }
    /// 置顶图标颜色
    var topLogo: UIColor {
        return UIColor(hex: 0x4bb893)
    }
    /// 转发卡片颜色
    var repostBackground: UIColor {
        return UIColor(hex: 0xf7f7f7)
    }
}

class ButtonColor {
    /// 普通状态
    var normal: UIColor {
        return UIColor(hex: 0x59b6d7)
    }
    
    var sunflowerYellow: UIColor {
        return UIColor(hex: 0xfedc00)
    }
    
    var warmBlue: UIColor {
        return UIColor(hex: 0x1360b9)
    }
    
    /// 高亮状态
    var highlighted: UIColor {
        return UIColor(hex: 0x42b2ce)
    }
    /// 不可交互状态
    var disabled: UIColor {
        return UIColor(hex: 0xb3b3b3)
    }
    /// 橙子金
    var orangeGold: UIColor {
        return UIColor(hex: 0xff9400)
    }
    
    var greyBorder: UIColor {
        return UIColor(hex: 0xe8e8e8)
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

class ThemeColor {
    
    var yellowOrange: UIColor {
        return UIColor(hex: 0xf7b500)
    }
}

