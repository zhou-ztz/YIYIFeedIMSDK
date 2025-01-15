//
//  TGTextButton.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/3.
//

import UIKit

private struct TGTextButtonUX {

    // 初始大小（可无视）
    static let InitialFrame = CGRect(x: 0, y: 0, width: 10, height: 44)

    static let ButtonHeight: CGFloat = 44
    /// 按钮左右两边的间距
    static let ButtonSpacing: CGFloat = 10

    static let TitleNormalColor = RLColor.main.theme
    static let TitleDisabledColor = RLColor.normal.disabled

    static let TitleFontTop = UIFont.systemFont(ofSize: 16)
    static let TitleFontNormal = UIFont.systemFont(ofSize: 14)
}


class TGTextButton: UIButton {

    enum TextButtonPutAreaType {
        case top
        case normal
    }

    private var _putAreaType: TextButtonPutAreaType?
    /// 按钮位置类型
    /// - 有 .top (位于顶部标题栏) 和 .normal (其他位置) 两种类型
    var putAreaType: TextButtonPutAreaType? {
        get {
            return _putAreaType
        }
        set(newValue) {
            _putAreaType = newValue
            let buttonTitleFont: UIFont
            if let newValue = newValue {
                switch newValue {
                case .top:
                    buttonTitleFont = TGTextButtonUX.TitleFontTop
                case .normal:
                    buttonTitleFont = TGTextButtonUX.TitleFontNormal
                }
                self.titleLabel?.font = buttonTitleFont
            }
        }
    }

    // MARK: Lifecycle
    /// 初始化方法
    ///
    /// - Parameter putAreaType: 按钮位置类型，有 .top (位于顶部标题栏) 和 .normal (其他位置) 两种类型
    class func initWith(putAreaType: TextButtonPutAreaType) -> TGTextButton {
        let button = TGTextButton(type: .system)
        button.putAreaType = putAreaType
        return button
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = TGTextButtonUX.InitialFrame
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.frame = TGTextButtonUX.InitialFrame
    }

    override func draw(_ rect: CGRect) {
        assert(self._putAreaType != nil, "TSTextButton.swift 55, \(self), TSTextButton 的 putAreaType 不能为 nil")
        updateUX()
        super.draw(rect)
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        updateUX()
    }

    func updateUX() {
        self.setTitleColor(TGTextButtonUX.TitleNormalColor, for: .normal)
        self.setTitleColor(TGTextButtonUX.TitleDisabledColor, for: .disabled)
        // 更新按钮的 size
        if let font = self.titleLabel?.font, let text = self.titleLabel?.text {
            let width = text.sizeOfString(usingFont: font).width
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: width + TGTextButtonUX.ButtonSpacing * 2, height: TGTextButtonUX.ButtonHeight)
        }
    }
}
