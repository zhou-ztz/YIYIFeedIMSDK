import Foundation
import UIKit

enum ButtonStyle {
    case textButton(text: String, textColor: UIColor)
    case stickerButton(text: String)
    case deleteSticker(image: UIImage?)
    case downloadSticker(image: UIImage?)
    case `default`(text: String, color: UIColor)
    case waveButton(text: String, backgroundColor: UIColor, textColor: UIColor, borderWidth: CGFloat)
    case custom(text: String, textColor: UIColor, backgroundColor: UIColor, cornerRadius: CGFloat, fontWeight: UIFont.Weight = .bold)
}

extension UIButton {
    
    func applyStyle(_ style: ButtonStyle) {
        setImage(nil, for: .normal)
        setTitle(nil, for: .normal)
        self.contentMode = .center
        self.imageView?.contentMode = .scaleAspectFit
        
        switch style {
        case .stickerButton(let text):
            setTitleColor(TGAppTheme.red, for: .normal)
            setTitle(text, for: .normal)
            applyBorder(color: TGAppTheme.red, width: 1)
            roundCorner()
            titleLabel?.font = TGAppTheme.Font.bold(14)
            
        case .deleteSticker(let image):
            applyBorder()
            setImage(image, for: .normal)
            
        case .downloadSticker(let image):
            applyBorder()
            setImage(image, for: .normal)
            
        case let .textButton(text, textColor):
            setTitle(text, for: .normal)
            setTitleColor(textColor, for: .normal)
            titleLabel?.font = TGAppTheme.Font.regular(13)
            
        case let .default(text, color):
            setTitle(text.uppercased(), for: .normal)
            setTitleColor(TGAppTheme.warmBlue, for: .normal)
            roundCorner(self.bounds.height/2)
            backgroundColor = color
            titleLabel?.font = TGAppTheme.Font.semibold(15)
        
        case let .waveButton(text, backgroundColor, textColor, borderWidth):
            setTitle(text, for: .normal)
            self.backgroundColor = backgroundColor
            setTitleColor(textColor, for: .normal)
            titleLabel?.font = TGAppTheme.Font.regular(14)
            if borderWidth > 0.0 {
                applyBorder(color: textColor, width: borderWidth)
            }
            
        case let .custom(text, textColor, backgroundColor, cornerRadius, fontWeight):
            setTitle(text, for: .normal)
            setTitleColor(textColor, for: .normal)
            titleLabel?.font = fontWeight == .bold ? TGAppTheme.Font.bold(14) : TGAppTheme.Font.regular(14)
            self.backgroundColor = backgroundColor
            contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            titleLabel?.lineBreakMode = .byWordWrapping
            roundCorner(cornerRadius)
        }
    }
    
    func setText(text: String, font: UIFont?, color: UIColor) {
        let attributedTitle = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: color
            ]
        )
        setAttributedTitle(attributedTitle, for: .normal)
    }
    
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: state)
        }
    }
    
    func setImageTintColor(_ color: UIColor) {
        let tintedImage = self.imageView?.image?.withRenderingMode(.alwaysTemplate)
        self.setImage(tintedImage, for: .normal)
        self.tintColor = color
    }
    
    func setTitle(_ text: String?) {
        for state : UIControl.State in [.normal, .highlighted, .disabled, .selected, .focused, .application, .reserved] {
            self.setTitle(text, for: state)
        }
    }

    func setTitleColor(_ color: UIColor?) {
        for state : UIControl.State in [.normal, .highlighted, .disabled, .selected, .focused, .application, .reserved] {
            self.setTitleColor(color, for: state)
        }
    }
    
}

extension UIButton {
    // MARK: - 替换 UIButton 的 setImage 和 setBackgroundImage 方法
    public static let swizzleButtonImageMethods: Void = {
        let originalSetImageSelector = #selector(setImage(_:for:))
        let swizzledSetImageSelector = #selector(customSetImage(_:for:))
        
        let originalSetBackgroundImageSelector = #selector(setBackgroundImage(_:for:))
        let swizzledSetBackgroundImageSelector = #selector(customSetBackgroundImage(_:for:))
        
        if let originalSetImageMethod = class_getInstanceMethod(UIButton.self, originalSetImageSelector),
           let swizzledSetImageMethod = class_getInstanceMethod(UIButton.self, swizzledSetImageSelector) {
            method_exchangeImplementations(originalSetImageMethod, swizzledSetImageMethod)
        }
        
        if let originalSetBackgroundImageMethod = class_getInstanceMethod(UIButton.self, originalSetBackgroundImageSelector),
           let swizzledSetBackgroundImageMethod = class_getInstanceMethod(UIButton.self, swizzledSetBackgroundImageSelector) {
            method_exchangeImplementations(originalSetBackgroundImageMethod, swizzledSetBackgroundImageMethod)
        }
    }()
    
    @objc private func customSetImage(_ image: UIImage?, for state: UIControl.State) {
        // 自定义加载逻辑
        let customImage = resolveCustomImage(image)
        // 调用原始的 setImage 方法
        customSetImage(customImage, for: state)
    }
    
    @objc private func customSetBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
        // 自定义加载逻辑
        let customImage = resolveCustomImage(image)
        // 调用原始的 setBackgroundImage 方法
        customSetBackgroundImage(customImage, for: state)
    }
    
    // MARK: - 自定义图片加载逻辑
    private func resolveCustomImage(_ originalImage: UIImage?) -> UIImage? {
        guard let originalImageName = originalImage?.accessibilityIdentifier else {
            return originalImage
        }
        
        let frameworkBundle = Bundle(identifier: "com.yiyi.feedimsdk") ?? Bundle.main
        if let resourceBundleURL = frameworkBundle.url(forResource: "SDKResource", withExtension: "bundle"),
           let resourceBundle = Bundle(url: resourceBundleURL) {
            // 尝试从自定义 Bundle 中加载图片
            if let image = UIImage(named: originalImageName, in: resourceBundle, compatibleWith: nil) {
                return image
            }
        }
        // 返回原始图片或 nil
        return originalImage
    }
}
