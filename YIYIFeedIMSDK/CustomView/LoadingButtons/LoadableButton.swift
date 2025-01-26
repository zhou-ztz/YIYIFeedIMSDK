//
//  LoadingButton.swift
//  LoadingButtons
//
//  Created by Ho, Tsung Wei on 8/7/19.
//  Copyright © 2019 Ho, Tsungwei. All rights reserved.
//

import UIKit

 class LoadableButton: UIButton {
    // MARK: -  variables
    /**
     Current loading state.
     */
     var isLoading: Bool = false
    /**
     The flag that indicate if the shadow is added to prevent duplicate drawing.
     */
     var shadowAdded: Bool = false
    // MARK: - Package-protected variables
    /**
     The loading indicator used with the button.
     */
     var indicator: UIView & IndicatorProtocol = MaterialLoadingIndicator(color: .white)
    /**
     Set to true to add shadow to the button.
     */
     var withShadow: Bool = false
    /**
     The corner radius of the button
     */
     var cornerRadius: CGFloat = 12.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
     lazy var _textColor: UIColor? = {
        indicator.color = self.titleLabel?.textColor ?? .white
        return self.titleLabel?.textColor
    }()
    /**
     Shadow view.
     */
     var shadowLayer: UIView?
    /**
     Get all views in the button. Views include the button itself and the shadow.
     */
     var entireViewGroup: [UIView] {
        var views: [UIView] = [self]
        if let shadow = self.shadowLayer {
            views.append(shadow)
        }
        return views
    }
    /**
     Button style for light mode and dark mode use. Only available on iOS 13 or later.
     */
    @available(iOS 13.0, *)
     enum ButtonStyle {
        case fill
        case outline
    }
    // Private properties
    lazy var bgColor: UIColor = {
        if self.backgroundColor == nil {
            return .clear
        }
        return self.backgroundColor!
    }()
    private var loaderWorkItem: DispatchWorkItem?
    // Init
     override init(frame: CGRect) {
        super.init(frame: frame)
    }
    /**
     Convenience init of theme button with required information
     
     - Parameter icon:      the icon of the button, it is be nil by default.
     - Parameter text:      the title of the button.
     - Parameter textColor: the text color of the button.
     - Parameter textSize:  the text size of the button label.
     - Parameter bgColor:   the background color of the button, tint color will be automatically generated.
     */
     init(
        frame: CGRect = .zero,
        icon: UIImage? = nil,
        text: String? = nil,
        textColor: UIColor? = .white,
        font: UIFont? = nil,
        bgColor: UIColor = .black,
        cornerRadius: CGFloat = 12.0,
        withShadow: Bool = false
    ) {
        super.init(frame: frame)
        // Set the icon of the button
        if let icon = icon {
            self.setImage(icon)
        }
        // Set the title of the button
        if let text = text {
            self.setTitle(text)
            self.setTitleColor(textColor, for: .normal)
            self.titleLabel?.adjustsFontSizeToFitWidth = true
        }
        // Set button contents
        self.titleLabel?.font = font
        self.bgColor = bgColor
        self.backgroundColor = bgColor
        self.setBackgroundImage(UIImage(.lightGray), for: .disabled)
        self.contentEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 4)
        self.setCornerBorder(cornerRadius: cornerRadius)
        self.withShadow = withShadow
        self.cornerRadius = cornerRadius
    }
    /**
     Convenience init of material design button using system default colors. This initializer
     reflects dark mode colors on iOS 13 or later platforms. However, it will ignore any custom
     colors set to the button.
     
     - Parameter icon:         the icon of the button, it is be nil by default.
     - Parameter text:         the title of the button.
     - Parameter font:         the font of the button label.
     - Parameter cornerRadius: the corner radius of the button. It is set to 12.0 by default.
     - Parameter withShadow:   set true to show the shadow of the button.
     - Parameter buttonStyle:  specify the button style. Styles currently available are fill and outline.
    */
    @available(iOS 13.0, *)
     convenience init(icon: UIImage? = nil, text: String? = nil, font: UIFont? = nil,
                            cornerRadius: CGFloat = 12.0, withShadow: Bool = false, buttonStyle: ButtonStyle) {
        switch buttonStyle {
        case .fill:
            self.init(icon: icon, text: text, textColor: .label, font: font,
                      bgColor: .systemFill, cornerRadius: cornerRadius, withShadow: withShadow)
        case .outline:
            self.init(icon: icon, text: text, textColor: .label, font: font,
                      bgColor: .clear, cornerRadius: cornerRadius, withShadow: withShadow)
            self.setCornerBorder(color: .label, cornerRadius: cornerRadius)
        }
        self.indicator.color = .label
    }
    // draw
     override func draw(_ rect: CGRect) {
        super.draw(rect)
        if shadowAdded || !withShadow { return }
        shadowAdded = true
        // Set up shadow layer
        shadowLayer = UIView(frame: self.frame)
        guard let shadowLayer = shadowLayer else { return }
        shadowLayer.setAsShadow(bounds: bounds, cornerRadius: self.cornerRadius)
        self.superview?.insertSubview(shadowLayer, belowSubview: self)
    }
    // Required init
    required  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /**
     Display the loader inside the button.
     
     - Parameter userInteraction: Enable the user interaction while displaying the loader.
     - Parameter completion:      The completion handler.
     */
     func showLoader(userInteraction: Bool, _ completion: LBCallback = nil) {
        showLoader([titleLabel, imageView], userInteraction: userInteraction, completion)
    }
    /**
     Show a loader inside the button with image.
     
     - Parameter userInteraction: Enable user interaction while showing the loader.
     */
     func showLoaderWithImage(userInteraction: Bool = false) {
        showLoader([self.titleLabel], userInteraction: userInteraction)
    }
    /**
     Display the loader inside the button.
     
     - Parameter viewsToBeHidden: The views such as titleLabel, imageViewto be hidden while showing loading indicator.
     - Parameter userInteraction: Enable the user interaction while displaying the loader.
     - Parameter completion:      The completion handler.
    */
     func showLoader(_ viewsToBeHidden: [UIView?], userInteraction: Bool = false, _ completion: LBCallback = nil) {
        guard !self.subviews.contains(indicator) else { return }
        // Set up loading indicator and update loading state
        isLoading = true
        self.isUserInteractionEnabled = userInteraction
        indicator.radius = min(0.7*self.frame.height/2, indicator.radius)
        indicator.alpha = 0.0
        self.addSubview(self.indicator)
        // Clean up
        loaderWorkItem?.cancel()
        loaderWorkItem = nil
        // Create a new work item
        loaderWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self, let item = self.loaderWorkItem, !item.isCancelled else { return }
            UIView.transition(with: self, duration: 0.2, options: .curveEaseOut, animations: {
                viewsToBeHidden.forEach {
                    $0?.alpha = 0.0
                }
                self.setTitleColor(UIColor.clear, for: .normal)
                self.indicator.alpha = 1.0
            }) { _ in
                guard !item.isCancelled else { return }
                self.isLoading ? self.indicator.startAnimating() : self.hideLoader()
                completion?()
            }
        }
        loaderWorkItem?.perform()
    }
    
     override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        switch state {
        case .normal:
            if color == .clear {
                _textColor = self.titleLabel?.textColor
            }
            
        default: break
        }

        super.setTitleColor(color, for: .normal)
    }
    /**
     Hide the loader displayed.
     
     - Parameter completion: The completion handler.
     */
     func hideLoader(_ completion: LBCallback = nil) {
        guard self.subviews.contains(indicator) else { return }
        // Update loading state
        isLoading = false
        self.isUserInteractionEnabled = true
        indicator.stopAnimating()
        // Clean up
        indicator.removeFromSuperview()
        loaderWorkItem?.cancel()
        loaderWorkItem = nil
        // Create a new work item
        loaderWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self, let item = self.loaderWorkItem, !item.isCancelled else { return }
            UIView.transition(with: self, duration: 0.2, options: .curveEaseIn, animations: {
                self.titleLabel?.alpha = 1.0
                self.imageView?.alpha = 1.0
                self.setTitleColor(self._textColor, for: .normal)
            }) { _ in
                guard !item.isCancelled else { return }
                completion?()
            }
        }
        loaderWorkItem?.perform()
    }
    /**
     Make the content of the button fill the button.
     */
     func fillContent() {
        self.contentVerticalAlignment = .fill
        self.contentHorizontalAlignment = .fill
    }
    // layoutSubviews
     override func layoutSubviews() {
        super.layoutSubviews()
        indicator.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
    }
    
    // MARK: Touch
    // touchesBegan
//     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        if isLoading == false {
//            self.bgColor = self.backgroundColor ?? .clear
//        }
//        self.backgroundColor = self.bgColor == UIColor.clear ? .clear : self.bgColor.getColorTint()
//    }
    // touchesEnded
//     override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesEnded(touches, with: event)
//        self.backgroundColor = self.bgColor
//    }
//    // touchesCancelled
//     override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesCancelled(touches, with: event)
//        self.backgroundColor = self.bgColor
//    }
    // touchesMoved
//     override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesMoved(touches, with: event)
//        self.backgroundColor = self.bgColor == UIColor.clear ? .clear : self.bgColor.getColorTint()
//    }
}
// MARK: - UIActivityIndicatorView
extension UIActivityIndicatorView: IndicatorProtocol {
     var radius: CGFloat {
        get {
            return self.frame.width/2
        }
        set {
            self.frame.size = CGSize(width: 2*newValue, height: 2*newValue)
            self.setNeedsDisplay()
        }
    }
    
     var color: UIColor {
        get {
            return self.tintColor
        }
        set {
            let ciColor = CIColor(color: newValue)
            self.style = newValue.RGBtoCMYK(red: ciColor.red, green: ciColor.green, blue: ciColor.blue).key > 0.5 ? .gray : .white
            self.tintColor = newValue
        }
    }
    // unused
     func setupAnimation(in layer: CALayer, size: CGSize) {}
}
