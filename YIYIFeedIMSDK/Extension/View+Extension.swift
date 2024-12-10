//
//  View+Extension.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/28.
//

import Foundation
import SnapKit

extension UIFont {
    /// 自定义文字
    class func systemMediumFont(ofSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Medium", size: ofSize)!
    }
    
    class func systemRegularFont(ofSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Regular", size: ofSize)!
    }
}

extension UILabel {
    
    enum FontWeight {
        case norm, medium, bold, italic
    }
    
    @discardableResult
    func wordWrapped(limit: Int = 0) -> UILabel {
        self.numberOfLines = 0
        return self
    }
    
    @discardableResult
    func setFontSize(with size: CGFloat, weight: FontWeight) -> UILabel {
        switch weight {
        case .norm: self.font = UIFont.systemFont(ofSize: size)
        case .medium: self.font = UIFont.systemMediumFont(ofSize: size)
        case .bold: self.font = UIFont.boldSystemFont(ofSize: size)
        case .italic: self.font = UIFont.italicSystemFont(ofSize: size)
        }
        
        return self
    }
    
    func applyCurrency(_ price: String, code: String) {
        let symbol = Locale(identifier: "en_" + code).currencySymbol.orEmpty
        let price = " \(price.toDouble().yippsAbbreviate)"
        let symbolAttributes = NSMutableAttributedString(string: symbol, attributes: [.font: UIFont.systemFont(ofSize: 28), .foregroundColor: UIColor.lightGray])
        let priceAttributes = NSAttributedString(string: price, attributes: [.font: UIFont.boldSystemFont(ofSize: 45), .foregroundColor: UIColor.black])
        
        symbolAttributes.append(priceAttributes)
        
        self.attributedText = symbolAttributes
    }
    
    func applyCurrencyString(_ price: String, currency: String) {
        let currencyAttributes = NSMutableAttributedString(string: currency, attributes: [.font: UIFont.systemFont(ofSize: 22), .foregroundColor: UIColor.lightGray])
        let priceAttributes = NSAttributedString(string: " " + price, attributes: [.font: UIFont.boldSystemFont(ofSize: 36), .foregroundColor: UIColor.black])
        
        currencyAttributes.append(priceAttributes)
        
        self.attributedText = currencyAttributes
    }
    
    func applyCurrencyInt(_ price: Int, currency: String) {
        let currencyAttributes = NSMutableAttributedString(string: currency, attributes: [.font: UIFont.systemFont(ofSize: 22), .foregroundColor: UIColor.lightGray])
        let priceAttributes = NSAttributedString(string: " " + String(price), attributes: [.font: UIFont.boldSystemFont(ofSize: 36), .foregroundColor: UIColor.black])
        
        currencyAttributes.append(priceAttributes)
        
        self.attributedText = currencyAttributes
    }
    
}

extension UIView {
    
    private func animate(start: Bool, margin:Bool = false, background:Bool = false, duration: Double = 2.0) {
        if background {
            
            let colorLayer = CALayer()
            colorLayer.backgroundColor = UIColor(white: 0.90, alpha: 1).cgColor
            if margin {
                colorLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height-5)
            } else {
                colorLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
            }
            colorLayer.name = "colorLayer"
            self.layer.addSublayer(colorLayer)
            self.autoresizesSubviews = true
            self.clipsToBounds = true
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor(white: 0.90, alpha: 1).cgColor,
                                    UIColor(white: 0.94, alpha: 1).cgColor,
                                    UIColor(white: 0.90, alpha: 1).cgColor]
            gradientLayer.locations = [0,0.4,0.8, 1]
            gradientLayer.name = "loaderLayer"
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            if margin {
                gradientLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height-5)
            } else {
                gradientLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
            }
            self.layer.addSublayer(gradientLayer)
            
            let animation = CABasicAnimation(keyPath: "transform.translation.x")
            animation.duration = duration
            animation.fromValue = -self.frame.width
            animation.toValue = self.frame.width
            animation.repeatCount = Float.infinity
            gradientLayer.add(animation, forKey: "smartLoader")
            
        } else {
            
            let light = UIColor(white: 0, alpha: 0.6).cgColor
            let dark = UIColor.black.cgColor
            
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.colors = [dark, light, dark]
            gradient.frame = CGRect(x: -self.bounds.size.width, y: 0, width: 3*self.bounds.size.width, height: self.bounds.size.height)
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.525)
            gradient.locations = [0.3, 0.5, 0.7]
            gradient.name = "shimmerLayer"
            self.layer.mask = gradient
            
            let animation: CABasicAnimation = CABasicAnimation(keyPath: "locations")
            animation.fromValue = [0.0, 0.1, 0.2]
            animation.toValue = [0.8, 0.9, 1.0]
            
            animation.duration = 1.5
            animation.repeatCount = Float.infinity
            animation.isRemovedOnCompletion = false
            
            gradient.add(animation, forKey: "shimmer")
        }
    }
    
}

