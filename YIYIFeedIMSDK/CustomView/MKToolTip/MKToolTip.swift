//
//  MKToolTip.swift
//
// Copyright (c) 2018 Metin Kilicaslan
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

@objc protocol MKToolTipDelegate: class {
    func toolTipViewDidAppear(for identifier: String)
    func toolTipViewDidDisappear(for identifier: String, with timeInterval: TimeInterval)
}

// MARK: methods extensions

extension MKToolTip {
    func dismissToolTips() {
        self.dismissWithAnimation()
    }
}

extension UIView {

    @discardableResult
    @objc func showToolTip(identifier: String, title: String? = nil, message: String, button: String? = nil, arrowPosition: MKToolTip.ArrowPosition, preferences: ToolTipPreferences = ToolTipPreferences(), delegate: MKToolTipDelegate? = nil) -> MKToolTip {
        let tooltip = MKToolTip(view: self, identifier: identifier, title: title, message: message, button: button, arrowPosition: arrowPosition, preferences: preferences, delegate: delegate)
        tooltip.calculateFrame()
        tooltip.show()
        
        return tooltip
    }
    
}

extension UIBarItem {
    
    @discardableResult
    @objc func showToolTip(identifier: String, title: String? = nil, message: String, button: String? = nil, arrowPosition: MKToolTip.ArrowPosition, preferences: ToolTipPreferences = ToolTipPreferences(), delegate: MKToolTipDelegate? = nil) -> MKToolTip? {
        if let view = self.view {
            let toolTip = view.showToolTip(identifier: identifier, title: title, message: message, button: button, arrowPosition: arrowPosition, preferences: preferences, delegate: delegate)
            return toolTip
        }
        
        return nil
    }
    
}

// MARK: Preferences

@objc class ToolTipPreferences: NSObject {
    
    @objc class Drawing: NSObject {
        
        @objc class Arrow: NSObject {
            @objc fileprivate var tip: CGPoint = .zero
            @objc var size: CGSize = CGSize(width: 20, height: 10)
            @objc var tipCornerRadius: CGFloat = 5
        }
        
        @objc class Bubble: NSObject {
            @objc class Border: NSObject {
                @objc var color: UIColor? = nil
                @objc var width: CGFloat = 1
            }
            
            @objc var inset: CGFloat = 15
            @objc var spacing: CGFloat = 5
            @objc var cornerRadius: CGFloat = 5
            @objc var maxWidth: CGFloat = 210
            @objc var color: UIColor = UIColor.clear {
                didSet {
                    gradientColors = [color]
                    gradientLocations = []
                }
            }
            @objc var gradientLocations: [CGFloat] = [0.05, 1.0]
            @objc var gradientColors: [UIColor] = [UIColor(red: 0.761, green: 0.914, blue: 0.984, alpha: 1.000), UIColor(red: 0.631, green: 0.769, blue: 0.992, alpha: 1.000)]
            @objc var border: Border = Border()
        }
        
        @objc class Title: NSObject {
            @objc var font: UIFont = UIFont.systemFont(ofSize: 12, weight: .bold)
            @objc var color: UIColor = .white
        }
        
        @objc class Message: NSObject {
            @objc var font: UIFont = UIFont.systemFont(ofSize: 12, weight: .regular)
            @objc var color: UIColor = .white
        }
        
        @objc class Button: NSObject {
            @objc var font: UIFont = UIFont.systemFont(ofSize: 12, weight: .regular)
            @objc var color: UIColor = .white
        }
        
        @objc class Background: NSObject {
            @objc var color: UIColor = UIColor.clear {
                didSet {
                    gradientColors = [UIColor.clear, color]
                }
            }
            @objc fileprivate var gradientLocations: [CGFloat] = [0.05, 1.0]
            @objc fileprivate var gradientColors: [UIColor] = [UIColor.clear, UIColor.black.withAlphaComponent(0.4)]
        }
        
        @objc var arrow: Arrow = Arrow()
        @objc var bubble: Bubble = Bubble()
        @objc var title: Title = Title()
        @objc var message: Message = Message()
        @objc var button: Button = Button()
        @objc var background: Background = Background()
    }
    
    @objc class Animating: NSObject {
        @objc var dismissTransform: CGAffineTransform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        @objc var showInitialTransform: CGAffineTransform = CGAffineTransform(scaleX: 0, y: 0)
        @objc var showFinalTransform: CGAffineTransform = .identity
        @objc var springDamping: CGFloat = 0.7
        @objc var springVelocity: CGFloat = 0.7
        @objc var showInitialAlpha: CGFloat = 0
        @objc var dismissFinalAlpha: CGFloat = 0
        @objc var showDuration: TimeInterval = 0.7
        @objc var dismissDuration: TimeInterval = 0.7
    }
    
    @objc var drawing: Drawing = Drawing()
    @objc var animating: Animating = Animating()
    
    @objc override init() {}
    
}

// MARK: MKToolTip class implementation

class MKToolTip: UIView {
    
    @objc enum ArrowPosition: Int {
        case top
        case right
        case bottom
        case left
        case topRight
        case topRightWithButtonHeight
    }
    
    // MARK: Variables
    
    let controller = ToolTipViewController()
    
    private var arrowPosition: ArrowPosition = .top
    private var bubbleFrame: CGRect = .zero
    
    private var containerWindow: UIWindow?
    private weak var presentingView: UIView?
    
    private var id: String
    private var title: String?
    private var message: String
    private var button: String?
    
    private weak var delegate: MKToolTipDelegate?
    
    private var viewDidAppearDate: Date = Date()
    
    private var preferences: ToolTipPreferences
    
    // MARK: Lazy variables
    
    private lazy var gradient: CGGradient = { [unowned self] in
        let colors = self.preferences.drawing.bubble.gradientColors.map { $0.cgColor } as CFArray
        let locations = self.preferences.drawing.bubble.gradientLocations
        return CGGradient(colorsSpace: nil, colors: colors, locations: locations)!
        }()
    
    private lazy var titleSize: CGSize = { [unowned self] in
        var attributes = [NSAttributedString.Key.font : self.preferences.drawing.title.font]
        
        var textSize = CGSize.zero
        if self.title != nil {
            textSize = self.title!.boundingRect(with: CGSize(width: self.preferences.drawing.bubble.maxWidth - self.preferences.drawing.bubble.inset * 2, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
        }
        
        textSize.width = ceil(textSize.width)
        textSize.height = ceil(textSize.height)
        
        return textSize
        }()
    
    private lazy var messageSize: CGSize = { [unowned self] in
        var attributes = [NSAttributedString.Key.font : self.preferences.drawing.message.font]
        
        var textSize = self.message.boundingRect(with: CGSize(width: self.preferences.drawing.bubble.maxWidth - self.preferences.drawing.bubble.inset * 2, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
        
        textSize.width = ceil(textSize.width)
        textSize.height = ceil(textSize.height)
        
        return textSize
        }()
    
    private lazy var buttonSize: CGSize = { [unowned self] in
        var attributes = [NSAttributedString.Key.font : self.preferences.drawing.button.font]
        
        var textSize = CGSize.zero
        if self.button != nil {
            textSize = self.button!.boundingRect(with: CGSize(width: self.preferences.drawing.bubble.maxWidth - self.preferences.drawing.bubble.inset * 2, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
        }
        
        textSize.width = ceil(textSize.width)
        textSize.height = ceil(textSize.height)
        
        return textSize
        }()
    
    private lazy var bubbleSize: CGSize = { [unowned self] in
        var height = self.preferences.drawing.bubble.inset
        
        if self.title != nil {
            height += self.titleSize.height + self.preferences.drawing.bubble.spacing
        }
        
        height += self.messageSize.height
        
        if self.button != nil {
            height += self.preferences.drawing.bubble.spacing + self.buttonSize.height
        }
        
        height += self.preferences.drawing.bubble.inset
        
        let widthInset = self.preferences.drawing.bubble.inset * 2
        let width = min(self.preferences.drawing.bubble.maxWidth, max(self.titleSize.width + widthInset, self.messageSize.width + widthInset))
        return CGSize(width: width, height: height)
        }()
    
    private lazy var contentSize: CGSize = { [unowned self] in
        var height: CGFloat = 0
        var width: CGFloat = 0
        
        switch self.arrowPosition {
        case .top, .bottom, .topRight, .topRightWithButtonHeight:
            height = self.preferences.drawing.arrow.size.height + self.bubbleSize.height
            width = self.bubbleSize.width
        case .right, .left:
            height = self.bubbleSize.height
            width = self.preferences.drawing.arrow.size.height + self.bubbleSize.width
        }
        
        return CGSize(width: width, height: height)
        }()
    
    // MARK: Initializer
    
    init(view: UIView, identifier: String, title: String? = nil, message: String, button: String? = nil, arrowPosition: ArrowPosition, preferences: ToolTipPreferences, delegate: MKToolTipDelegate? = nil) {
        self.presentingView = view
        self.id = identifier
        self.title = title
        self.message = message
        self.button = button
        self.arrowPosition = arrowPosition
        self.preferences = preferences
        self.delegate = delegate
        super.init(frame: .zero)
        self.backgroundColor = .clear
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Gesture methods
    
    @objc func handleTap() {
        dismissWithAnimation()
    }
    
    // MARK: Private methods
    
    fileprivate func calculateFrame() {
        guard let presentingView = presentingView else { return }
        let refViewFrame = presentingView.convert(presentingView.bounds, to: UIApplication.shared.keyWindow);
        
        var xOrigin: CGFloat = 0
        var yOrigin: CGFloat = 0
        
        let spacingForBorder: CGFloat = (preferences.drawing.bubble.border.color != nil) ? preferences.drawing.bubble.border.width : 0
        
        switch arrowPosition {
        case .topRightWithButtonHeight:
            xOrigin = refViewFrame.center.x - contentSize.width / 2 + 15
            yOrigin = refViewFrame.y + refViewFrame.height + UIApplication.shared.statusBarFrame.height
            preferences.drawing.arrow.tip = CGPoint(x: spacingForBorder + contentSize.width - 18, y: 0)
            bubbleFrame = CGRect(x: spacingForBorder, y: preferences.drawing.arrow.size.height + spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            
        case .topRight:
            xOrigin = UIScreen.main.bounds.width - (contentSize.width + spacingForBorder * 2) - preferences.drawing.bubble.inset
            yOrigin = refViewFrame.y + refViewFrame.height
            bubbleFrame = CGRect(x: spacingForBorder, y: preferences.drawing.arrow.size.height + spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: bubbleFrame.x + bubbleFrame.width - preferences.drawing.arrow.size.width - 10 , y: 0)
        case .top:
            xOrigin = refViewFrame.center.x - contentSize.width / 2
            yOrigin = refViewFrame.y + refViewFrame.height
            preferences.drawing.arrow.tip = CGPoint(x: refViewFrame.center.x - xOrigin, y: 0)
            bubbleFrame = CGRect(x: spacingForBorder, y: preferences.drawing.arrow.size.height + spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
        case .right:
            xOrigin = refViewFrame.x - contentSize.width
            yOrigin = refViewFrame.center.y - contentSize.height / 2
            preferences.drawing.arrow.tip = CGPoint(x: bubbleSize.width + preferences.drawing.arrow.size.height + spacingForBorder, y: refViewFrame.center.y - yOrigin)
            bubbleFrame = CGRect(x: spacingForBorder, y: spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
        case .bottom:
            xOrigin = refViewFrame.center.x - contentSize.width / 2
            yOrigin = refViewFrame.y - contentSize.height
            preferences.drawing.arrow.tip = CGPoint(x: refViewFrame.center.x - xOrigin, y: bubbleSize.height + preferences.drawing.arrow.size.height)
            bubbleFrame = CGRect(x: spacingForBorder, y: spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
        case .left:
            xOrigin = refViewFrame.x + refViewFrame.width
            yOrigin = refViewFrame.center.y - contentSize.height / 2
            preferences.drawing.arrow.tip = CGPoint(x: spacingForBorder, y: refViewFrame.center.y - yOrigin)
            bubbleFrame = CGRect(x: preferences.drawing.arrow.size.height + spacingForBorder, y: spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
        }
        
        let calculatedFrame = CGRect(x: xOrigin, y: yOrigin, width: contentSize.width + spacingForBorder * 2, height: contentSize.height + spacingForBorder * 2)
        frame = adjustFrame(calculatedFrame)
    }
    
    private func adjustFrame(_ frame: CGRect) -> CGRect {
        let bounds: CGRect = UIScreen.main.bounds
        let restrictedBounds = CGRect(x: bounds.x + preferences.drawing.bubble.inset,
                                      y: bounds.y + preferences.drawing.bubble.inset,
                                      width: bounds.width - preferences.drawing.bubble.inset * CGFloat(2),
                                      height: bounds.height - preferences.drawing.bubble.inset * CGFloat(2))
        
        if !restrictedBounds.contains(frame) {
            var newFrame: CGRect = frame
            
            if frame.x < restrictedBounds.x {
                let diff: CGFloat = -frame.x + preferences.drawing.bubble.inset
                newFrame.x = frame.x + diff
                if arrowPosition == .top || arrowPosition == .bottom || arrowPosition == .topRight {
                    preferences.drawing.arrow.tip.x = max(preferences.drawing.arrow.size.width, preferences.drawing.arrow.tip.x - diff)
                }
            }
            
            if frame.x + frame.width > restrictedBounds.x + restrictedBounds.width {
                let diff: CGFloat = frame.x + frame.width - restrictedBounds.x - restrictedBounds.width
                newFrame.x = frame.x - diff
                if arrowPosition == .top || arrowPosition == .bottom || arrowPosition == .topRight {
                    preferences.drawing.arrow.tip.x = min(newFrame.width - preferences.drawing.arrow.size.width, preferences.drawing.arrow.tip.x + diff)
                }
            }
            
            return newFrame
        }
        
        return frame
    }
        
    fileprivate func show() {
        controller.view.alpha = 0
        controller.view.addSubview(self)
        
        createWindow(with: controller)
        addTapGesture(for: controller)
        showWithAnimation()
    }
    
    private func createWindow(with viewController: UIViewController) {
        self.containerWindow = UIWindow(frame: UIScreen.main.bounds)
        self.containerWindow!.rootViewController = viewController
        self.containerWindow!.windowLevel = UIWindow.Level.alert + 1;
        self.containerWindow!.makeKeyAndVisible()
    }
    
    private func addTapGesture(for viewController: UIViewController) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        viewController.view.addGestureRecognizer(tap)
    }
    
    private func showWithAnimation() {
        transform = preferences.animating.showInitialTransform
        alpha = preferences.animating.showInitialAlpha
        
        UIView.animate(withDuration: preferences.animating.showDuration, delay: 0, usingSpringWithDamping: preferences.animating.springDamping, initialSpringVelocity: preferences.animating.springVelocity, options: [.curveEaseInOut], animations: {
            self.transform = self.preferences.animating.showFinalTransform
            self.alpha = 1
            self.containerWindow?.rootViewController?.view.alpha = 1
        }, completion: { (completed) in
            self.viewDidAppear()
        })
    }
    
    private func dismissWithAnimation() {
        UIView.animate(withDuration: preferences.animating.dismissDuration, delay: 0, usingSpringWithDamping: preferences.animating.springDamping, initialSpringVelocity: preferences.animating.springVelocity, options: [.curveEaseInOut], animations: {
            self.transform = self.preferences.animating.dismissTransform
            self.alpha = self.preferences.animating.dismissFinalAlpha
            self.containerWindow?.rootViewController?.view.alpha = 0
        }) { (finished) -> Void in
            self.viewDidDisappear()
            self.removeFromSuperview()
            self.transform = CGAffineTransform.identity
            self.containerWindow?.resignKey()
            self.containerWindow = nil
        }
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        drawBackgroundLayer()
        drawBubble(context)
        drawTexts(to: context)
    }
    
    private func viewDidAppear() {
        self.viewDidAppearDate = Date()
        self.delegate?.toolTipViewDidAppear(for: self.id)
    }
    
    private func viewDidDisappear() {
        let viewDidDisappearDate = Date()
        let timeInterval = viewDidDisappearDate.timeIntervalSince(self.viewDidAppearDate)
        self.delegate?.toolTipViewDidDisappear(for: self.id, with: timeInterval)
    }
    
    // MARK: Drawing methods
    
    private func drawBackgroundLayer() {
        if let view = self.containerWindow?.rootViewController?.view, let presentingView = presentingView {
            let refViewFrame = presentingView.convert(presentingView.bounds, to: UIApplication.shared.keyWindow);
            let radius = refViewFrame.center.farCornerDistance()
            let frame = view.bounds
            let layer = RadialGradientBackgroundLayer(frame: frame, center: refViewFrame.center, radius: radius, locations: preferences.drawing.background.gradientLocations, colors: preferences.drawing.background.gradientColors)
            view.layer.insertSublayer(layer, at: 0)
        }
    }
    
    private func drawBubbleBorder(_ context: CGContext, path: CGMutablePath, borderColor: UIColor) {
        context.saveGState()
        context.addPath(path)
        context.setStrokeColor(borderColor.cgColor)
        context.setLineWidth(preferences.drawing.bubble.border.width)
        context.strokePath()
        context.restoreGState()
    }
    
    private func drawBubble(_ context: CGContext) {
        context.saveGState()
        let path = CGMutablePath()
        
        switch arrowPosition {
        case .topRight, .top, .topRightWithButtonHeight:
            let startingPoint = CGPoint(x: preferences.drawing.arrow.tip.x - preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y)
            path.move(to: startingPoint)
            addTopArc(to: path)
            addLeftArc(to: path)
            addBottomArc(to: path)
            addRightArc(to: path)
            path.addLine(to: CGPoint(x: preferences.drawing.arrow.tip.x + preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y))
            addArrowTipArc(with: startingPoint, to: path)
        case .right:
            let startingPoint = CGPoint(x: preferences.drawing.arrow.tip.x - preferences.drawing.arrow.size.height, y: preferences.drawing.arrow.tip.y - preferences.drawing.arrow.size.width / 2)
            path.move(to: startingPoint)
            addRightArc(to: path)
            addTopArc(to: path)
            addLeftArc(to: path)
            addBottomArc(to: path)
            path.addLine(to: CGPoint(x: preferences.drawing.arrow.tip.x - preferences.drawing.arrow.size.height, y: preferences.drawing.arrow.tip.y + preferences.drawing.arrow.size.width / 2))
            addArrowTipArc(with: startingPoint, to: path)
        case .bottom:
            let startingPoint = CGPoint(x: preferences.drawing.arrow.tip.x + preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y + bubbleFrame.height)
            path.move(to: startingPoint)
            addBottomArc(to: path)
            addRightArc(to: path)
            addTopArc(to: path)
            addLeftArc(to: path)
            path.addLine(to: CGPoint(x: preferences.drawing.arrow.tip.x - preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y + bubbleFrame.height))
            addArrowTipArc(with: startingPoint, to: path)
        case .left:
            let startingPoint = CGPoint(x: preferences.drawing.arrow.tip.x + preferences.drawing.arrow.size.height, y: preferences.drawing.arrow.tip.y + preferences.drawing.arrow.size.width / 2)
            path.move(to: startingPoint)
            addLeftArc(to: path)
            addBottomArc(to: path)
            addRightArc(to: path)
            addTopArc(to: path)
            path.addLine(to: CGPoint(x: preferences.drawing.arrow.tip.x + preferences.drawing.arrow.size.height, y: preferences.drawing.arrow.tip.y - preferences.drawing.arrow.size.width / 2))
            addArrowTipArc(with: startingPoint, to: path)
        }
        
        path.closeSubpath()
        
        context.addPath(path)
        context.clip()
        context.fillPath()
        context.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: 0, y: frame.height), options: [])
        context.restoreGState()
        
        if let borderColor = preferences.drawing.bubble.border.color {
            drawBubbleBorder(context, path: path, borderColor: borderColor)
        }
    }
    
    private func addTopArc(to path: CGMutablePath) {
        path.addArc(tangent1End: CGPoint(x: bubbleFrame.x, y:  bubbleFrame.y), tangent2End: CGPoint(x: bubbleFrame.x, y: bubbleFrame.y + bubbleFrame.height), radius: preferences.drawing.bubble.cornerRadius)
    }
    
    private func addRightArc(to path: CGMutablePath) {
        path.addArc(tangent1End: CGPoint(x: bubbleFrame.x + bubbleFrame.width, y: bubbleFrame.y), tangent2End: CGPoint(x: bubbleFrame.x, y: bubbleFrame.y), radius: preferences.drawing.bubble.cornerRadius)
    }
    
    private func addBottomArc(to path: CGMutablePath) {
        path.addArc(tangent1End: CGPoint(x: bubbleFrame.x + bubbleFrame.width, y: bubbleFrame.y + bubbleFrame.height), tangent2End: CGPoint(x: bubbleFrame.x + bubbleFrame.width, y: bubbleFrame.y), radius: preferences.drawing.bubble.cornerRadius)
    }
    
    private func addLeftArc(to path: CGMutablePath) {
        path.addArc(tangent1End: CGPoint(x: bubbleFrame.x, y: bubbleFrame.y + bubbleFrame.height), tangent2End: CGPoint(x: bubbleFrame.x + bubbleFrame.width, y: bubbleFrame.y + bubbleFrame.height), radius: preferences.drawing.bubble.cornerRadius)
    }
    
    private func addArrowTipArc(with startingPoint: CGPoint, to path: CGMutablePath) {
        path.addArc(tangent1End: preferences.drawing.arrow.tip, tangent2End: startingPoint, radius: preferences.drawing.arrow.tipCornerRadius)
    }
    
    private func drawTexts(to context: CGContext) {
        context.saveGState()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        let xOrigin = bubbleFrame.x + preferences.drawing.bubble.inset
        var yOrigin = bubbleFrame.y + preferences.drawing.bubble.inset
        
        if title != nil {
            let titleRect = CGRect(x: xOrigin, y: yOrigin, width: titleSize.width, height: titleSize.height)
            title!.draw(in: titleRect, withAttributes: [NSAttributedString.Key.font : preferences.drawing.title.font, NSAttributedString.Key.foregroundColor : preferences.drawing.title.color, NSAttributedString.Key.paragraphStyle : paragraphStyle])
            
            yOrigin = titleRect.y + titleRect.height + preferences.drawing.bubble.spacing
        }
        
        let messageRect = CGRect(x: xOrigin, y: yOrigin, width: messageSize.width, height: messageSize.height)
        message.draw(in: messageRect, withAttributes: [NSAttributedString.Key.font : preferences.drawing.message.font, NSAttributedString.Key.foregroundColor : preferences.drawing.message.color, NSAttributedString.Key.paragraphStyle : paragraphStyle])
        
        if button != nil {
            yOrigin += messageRect.height + preferences.drawing.bubble.spacing
            
            let buttonRect = CGRect(x: xOrigin, y: yOrigin, width: buttonSize.width, height: buttonSize.height)
            button!.draw(in: buttonRect, withAttributes: [NSAttributedString.Key.font : preferences.drawing.button.font, NSAttributedString.Key.foregroundColor : preferences.drawing.button.color, NSAttributedString.Key.paragraphStyle : paragraphStyle])
        }
        
    }
}

// MARK: RadialGradientBackgroundLayer
class RadialGradientBackgroundLayer: CALayer {
    
    private var _center: CGPoint = .zero
    private var radius: CGFloat = 0
    private var locations: [CGFloat] = [CGFloat]()
    private var colors: [UIColor] = [UIColor]()
    
    @available(*, unavailable)
    required override init(layer: Any) {
        super.init(layer: layer)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, center: CGPoint, radius: CGFloat, locations: [CGFloat], colors: [UIColor]) {
        super.init()
        needsDisplayOnBoundsChange = true
        self.frame = frame
        self._center = center
        self.radius = radius
        self.locations = locations
        self.colors = colors
    }
    
    override func draw(in ctx: CGContext) {
        ctx.saveGState()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = self.colors.map { $0.cgColor }
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)
        ctx.drawRadialGradient(gradient!, startCenter: center, startRadius: 0, endCenter: _center, endRadius: radius, options: [])
        ctx.restoreGState()
    }
}

class ToolTipViewController: UIViewController {
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
}
