

import UIKit

struct ScreenSize {
    static let ScreenWidth = UIScreen.main.bounds.size.width
    static let ScreenHeight = UIScreen.main.bounds.size.height
    static let ScreenMaxlength = max(ScreenSize.ScreenWidth, ScreenSize.ScreenHeight)
}

public let fengeLineHeight: CGFloat = 0.5
public let ScreenWidth: CGFloat = UIScreen.main.bounds.size.width
public let ScreenHeight: CGFloat = UIScreen.main.bounds.size.height
public let stickerPerPage: Int = 8
public let emojiPerPage: Int = 32
public let stickerThumbHeight: Int = 40
public let stickerThumbWidth: Int = 45
public let stickerSize: Int = 115
public let emojiContainerHeight: CGFloat = 260
public let textToolbarHeight: CGFloat = 52
public let voucherHeight: CGFloat = 44

/// 状态栏高度
public var TSStatusBarHeight: CGFloat { return RLUserInterfacePrinciples.share.getTSStatusBarHeight() }
/// 刘海高度
public var TSLiuhaiHeight: CGFloat { return RLUserInterfacePrinciples.share.getTSLiuhaiHeight() }
/// RL tabbar高度
public var RLTabbarHeight: CGFloat { return RLUserInterfacePrinciples.share.getRLTabbarHeight() }
/// tabbar高度
public var TSTabbarHeight: CGFloat { return RLUserInterfacePrinciples.share.getTSTabbarHeight() }
/// 底部安全区域高度
public var TSBottomSafeAreaHeight: CGFloat { return RLUserInterfacePrinciples.share.getTSBottomSafeAreaHeight() }
/// 导航栏高度
public var TSNavigationBarHeight: CGFloat {
    return RLUserInterfacePrinciples.share.getTSNavigationBarHeight()
}
/// 自动布局顶部偏移量,部分页面贴顶布局在iPhoneX下需要向下移动20pt
public let TSTopAdjustsScrollViewInsets: CGFloat = RLUserInterfacePrinciples.share.getTSTopAdjustsScrollViewInsets()

class RLUserInterfacePrinciples: NSObject {
    static let share = RLUserInterfacePrinciples()

    private override init() {
        super.init()
    }
    
    // 判断是否为iPhoneX系列
    func hasNotch() -> Bool {
        if #available(iOS 11.0, *) {
            let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            return bottom > 0
        }
        
        return false
    }

    /// 获取状态栏高度
    func getTSStatusBarHeight() -> CGFloat {
        if self.hasNotch() == true {
            return 44.0
        } else {
            return 20.0
        }
    }
    /// 获取刘海高度
    func getTSLiuhaiHeight() -> CGFloat {
        if self.hasNotch() == true {
            return 30.0
        } else {
            return 0
        }
    }
    /// 获取RL tabbar高度
    func getRLTabbarHeight() -> CGFloat {
        return 70
    }
    /// 获取tabbar高度
    func getTSTabbarHeight() -> CGFloat {
        if self.hasNotch() == true {
            return 49.0 + 34.0
        } else {
            return 49.0
        }
    }
    /// 获取底部安全区域高度
    func getTSBottomSafeAreaHeight() -> CGFloat {
        guard let root = UIApplication.shared.keyWindow?.rootViewController else {
            return self.hasNotch() ? 34.0 : 0
        }
        if self.hasNotch() == true {
            if #available(iOS 11.0, *) {
                return root.view.safeAreaInsets.bottom
            } else {
                return root.bottomLayoutGuide.length
            }
        }

        return 0.0
    }
    /// 获取顶部导航条
    func getTSNavigationBarHeight() -> CGFloat {
        if self.hasNotch() == true {
            return 64.0 + 24.0
        } else {
            return 64.0
        }
    }
    /// 自动布局顶部偏移量,部分页面贴顶布局在iPhoneX下需要向下移动20pt
    func getTSTopAdjustsScrollViewInsets() -> CGFloat {
        if self.hasNotch() == true {
            return 20.0
        } else {
            return 0
        }
    }
}
