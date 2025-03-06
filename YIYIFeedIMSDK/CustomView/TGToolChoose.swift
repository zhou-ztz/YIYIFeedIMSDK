//
//  TGToolChoose.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/13.
//

import UIKit
import NIMSDK

enum TGToolType: Int {
    ///IM
    case scan          = 1 //扫码
    case nearBy        = 2 //附近的人
    case contact       = 3 //通讯录
    case groupInvate   = 4 //群聊邀请
    case note          = 5 //留言
    case collection    = 6 //收藏信息
    ///feed
    case text          = 7 //文字
    case photo         = 8 //图片
    case live          = 9 //直播
    case video         = 20//视频
    case miniVideo     = 10 //小视频
    ///profile
    case system        = 11 //系统通知
    case level         = 12 //我的等级
    case support       = 13 //直播
    case referAndEarn  = 14 //推荐有礼
    case rejected      = 17 //被拦截的帖子
    case settings      = 18 //设定
    case share         = 19 //分享
    
    
    //RewardsLink 添加
    
    case sendMsg       = 21 // Send to Message
    case invite        = 22 // Invite Friends
    case report        = 23 // Report
    case blackList     = 24 // blackList
    
    case newChat        = 15
    case meeting        = 16
}

class TGToolModel: NSObject {
    var title: String
    var image: String
    var type:  TGToolType
    var isShowRedPiont = false
    
    init(title: String, image: String, type: TGToolType) {
        self.title = title
        self.image = image
        self.type  = type
        super.init()
        setShowRedPiont()
    }
    
    func setShowRedPiont(){
        switch type {
        case .groupInvate:
//            let filter = NIMSystemNotificationFilter()
//            filter.notificationTypes = [NSNumber(nonretainedObject: NIMSystemNotificationType.teamInvite), NSNumber(nonretainedObject: NIMSystemNotificationType.teamApply)]
//            var notif = NIMSDK.shared().systemNotificationManager.fetchSystemNotifications(nil, limit: 20, filter: filter) ?? []
//            notif = notif.filter { $0.type.rawValue == 0 || $0.type.rawValue == 2 }
//            let groupInvateCount = notif.count
//            if groupInvateCount > 0 {
//                isShowRedPiont = true
//            } else {
//                isShowRedPiont = false
//            }
            isShowRedPiont = false
        case .note:
            // Personal Request
//            let msgCount = ChatMessageManager.shared.requestCount()
//            let requestList = MessageRequestRealmManager().getChatRequest()
//            let count = msgCount > 0 ? msgCount : requestList.count
//            
//            // Group Request
//            let filter = NIMSystemNotificationFilter()
//            filter.notificationTypes = [NSNumber(nonretainedObject: NIMSystemNotificationType.teamInvite), NSNumber(nonretainedObject: NIMSystemNotificationType.teamApply)]
//            var notif = NIMSDK.shared().systemNotificationManager.fetchSystemNotifications(nil, limit: 20, filter: filter) ?? []
//            notif = notif.filter { $0.type.rawValue == 0 || $0.type.rawValue == 2 }
//            let groupInvateCount = notif.count
            
            isShowRedPiont = false//count + groupInvateCount > 0 ? true : false
        case .system:
            isShowRedPiont = false//TSCurrentUserInfo.share.unreadCount.system > 0 ? true : false
        case .rejected:
            isShowRedPiont = true //TSCurrentUserInfo.share.unreadCount.reject > 0 ? true : false
        default:
            isShowRedPiont = false
        }
    }
}


// MARK: methods extensions

extension TGToolChoose {
    func dismissToolTips() {
        self.dismissWithAnimation()
    }
}

extension UIView {
    @discardableResult
    func showToolChoose(identifier: String, data: [TGToolModel], arrowPosition: TGToolChoose.ArrowPosition, preferences: TGToolChoosePreferences = TGToolChoosePreferences(), delegate: TGToolChooseDelegate? = nil, isMessage: Bool) -> TGToolChoose {
        let tooltip = TGToolChoose(view: self, identifier: identifier, data: data, arrowPosition: arrowPosition, preferences: preferences, delegate: delegate)
        tooltip.isMessage = isMessage
        tooltip.calculateFrame()
        tooltip.show()
        //TSRootViewController.share.toolTip = tooltip
        return tooltip
    }
}

protocol TGToolChooseDelegate: AnyObject {
    func didSelectedItem(type: TGToolType, title: String)
}

// MARK: Preferences

class TGToolChoosePreferences: NSObject {
    class Drawing: NSObject {
        class Arrow: NSObject {
            var tip: CGPoint = .zero
            var size: CGSize = CGSize(width: 20, height: 10)
            var tipCornerRadius: CGFloat = 5
        }
        
        class Bubble: NSObject {
            class Border: NSObject {
                var color: UIColor? = nil
                var width: CGFloat = 1
            }
            
            var inset: CGFloat = 15
            var spacing: CGFloat = 5
            var cornerRadius: CGFloat = 5
            var maxWidth: CGFloat = 210
            var color: UIColor = UIColor.clear {
                didSet {
                    gradientColors = [color]
                    gradientLocations = []
                }
            }
            var gradientLocations: [CGFloat] = [0.05, 1.0]
            var gradientColors: [UIColor] = [UIColor(red: 0.761, green: 0.914, blue: 0.984, alpha: 1.000), UIColor(red: 0.631, green: 0.769, blue: 0.992, alpha: 1.000)]
            var border: Border = Border()
        }
        
        class Title: NSObject {
            var font: UIFont = UIFont.systemFont(ofSize: 12, weight: .bold)
            var color: UIColor = .white
        }
        
        class Message: NSObject {
            var font: UIFont = UIFont.systemFont(ofSize: 12, weight: .regular)
            var color: UIColor = .white
        }
        
        class Button: NSObject {
            var font: UIFont = UIFont.systemFont(ofSize: 12, weight: .regular)
            var color: UIColor = .white
        }
        
        class Background: NSObject {
            var color: UIColor = UIColor.clear {
                didSet {
                    gradientColors = [UIColor.clear, color]
                }
            }
            var gradientLocations: [CGFloat] = [0.05, 1.0]
            var gradientColors: [UIColor] = [UIColor.clear, UIColor.black.withAlphaComponent(0.4)]
        }
        
        var arrow: Arrow = Arrow()
        var bubble: Bubble = Bubble()
        var title: Title = Title()
        var message: Message = Message()
        var button: Button = Button()
        var background: Background = Background()
        var rowHeight: CGFloat = 45.0
        var rowMax: Int = 8
    }
    
    class Animating: NSObject {
        var dismissTransform: CGAffineTransform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        var showInitialTransform: CGAffineTransform = CGAffineTransform(scaleX: 0, y: 0)
        var showFinalTransform: CGAffineTransform = .identity
        var springDamping: CGFloat = 0.7
        var springVelocity: CGFloat = 0.7
        var showInitialAlpha: CGFloat = 0
        var dismissFinalAlpha: CGFloat = 0
        var showDuration: TimeInterval = 0.7
        var dismissDuration: TimeInterval = 0.7
    }
    
    var drawing: Drawing = Drawing()
    var animating: Animating = Animating()
    
    override init() {}
}


// MARK: TGToolChoose class implementation
class TGToolChoose: UIView, UIGestureRecognizerDelegate {
    enum ArrowPosition: Int {
        case top
        case right
        case bottom
        case left
        case topRight
        case topRightWithButtonHeight
        case none
    }
    
    // MARK: Variables
    
    let controller = ToolTipViewController()
    
    private var arrowPosition: ArrowPosition = .top
    private var bubbleFrame: CGRect = .zero
    
    private var containerWindow: UIWindow?
    private weak var presentingView: UIView?
    
    private var id: String
    
    private weak var delegate: TGToolChooseDelegate?
    
    private var viewDidAppearDate: Date = Date()
    
    private var preferences: TGToolChoosePreferences
    var data = [TGToolModel]()
    var isMessage: Bool = false
    
    // MARK: Lazy variables
    
    private lazy var gradient: CGGradient = { [unowned self] in
        let colors = self.preferences.drawing.bubble.gradientColors.map { $0.cgColor } as CFArray
        let locations = self.preferences.drawing.bubble.gradientLocations
        return CGGradient(colorsSpace: nil, colors: colors, locations: locations)!
    }()
    
    private lazy var bubbleSize: CGSize = { [unowned self] in
        var height = min(preferences.drawing.rowHeight * CGFloat(data.count), preferences.drawing.rowHeight * CGFloat(preferences.drawing.rowMax))
        return CGSize(width: 182, height: height)
    }()
    
    private lazy var contentSize: CGSize = { [unowned self] in
        var height: CGFloat = 0
        var width: CGFloat = 0
        
        switch self.arrowPosition {
        case .top, .bottom, .topRight, .topRightWithButtonHeight, .none:
            height = self.preferences.drawing.arrow.size.height + self.bubbleSize.height
            width = self.bubbleSize.width
        case .right, .left, .none:
            height = self.bubbleSize.height
            width = self.preferences.drawing.arrow.size.height + self.bubbleSize.width
        }
        
        return CGSize(width: width, height: height)
    }()
    
    lazy private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 0
        tableView.rowHeight = preferences.drawing.rowHeight
        tableView.backgroundColor = .clear
        tableView.register(TGChooseViewCell.self, forCellReuseIdentifier: TGChooseViewCell.cellIdentifier)
        tableView.bounces = false
        
        return tableView
    }()
    
    // MARK: Initializer
    
    init(view: UIView, identifier: String,  data: [TGToolModel], arrowPosition: ArrowPosition, preferences: TGToolChoosePreferences, delegate: TGToolChooseDelegate? = nil) {
        self.presentingView = view
        self.id = identifier
        self.data = data
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
            tableView.frame = CGRect(x: 0, y: preferences.drawing.arrow.size.height, width: bubbleSize.width, height: bubbleSize.height)
        case .topRight:
            xOrigin = UIScreen.main.bounds.width - (contentSize.width + spacingForBorder * 2) - preferences.drawing.bubble.inset
            yOrigin = refViewFrame.y + refViewFrame.height
            bubbleFrame = CGRect(x: spacingForBorder, y: preferences.drawing.arrow.size.height + spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: bubbleFrame.x + bubbleFrame.width - preferences.drawing.arrow.size.width - 10 , y: 0)
            tableView.frame = CGRect(x: 0, y: preferences.drawing.arrow.size.height, width: bubbleSize.width, height: bubbleSize.height)
        case .top:
            xOrigin = refViewFrame.center.x - contentSize.width / 2
            yOrigin = refViewFrame.y + refViewFrame.height
            preferences.drawing.arrow.tip = CGPoint(x: refViewFrame.center.x - xOrigin, y: 0)
            bubbleFrame = CGRect(x: spacingForBorder, y: preferences.drawing.arrow.size.height + spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            tableView.frame = CGRect(x: 0, y: preferences.drawing.arrow.size.height, width: bubbleSize.width, height: bubbleSize.height)
        case .right:
            xOrigin = refViewFrame.x - contentSize.width
            yOrigin = refViewFrame.center.y - contentSize.height / 2
            preferences.drawing.arrow.tip = CGPoint(x: bubbleSize.width + preferences.drawing.arrow.size.height + spacingForBorder, y: refViewFrame.center.y - yOrigin)
            bubbleFrame = CGRect(x: spacingForBorder, y: spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            tableView.frame = CGRect(x: 0, y: 0, width: bubbleSize.width, height: bubbleSize.height)
        case .bottom:
            xOrigin = refViewFrame.center.x - contentSize.width / 2
            yOrigin = refViewFrame.y - contentSize.height
            preferences.drawing.arrow.tip = CGPoint(x: refViewFrame.center.x - xOrigin, y: bubbleSize.height + preferences.drawing.arrow.size.height)
            bubbleFrame = CGRect(x: spacingForBorder, y: spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            tableView.frame = CGRect(x: 0, y: 0, width: bubbleSize.width, height: bubbleSize.height)
        case .left:
            xOrigin = refViewFrame.x + refViewFrame.width
            yOrigin = refViewFrame.center.y - contentSize.height / 2
            preferences.drawing.arrow.tip = CGPoint(x: spacingForBorder, y: refViewFrame.center.y - yOrigin)
            bubbleFrame = CGRect(x: preferences.drawing.arrow.size.height + spacingForBorder, y: spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            tableView.frame = CGRect(x: 0, y: 0, width: bubbleSize.width, height: bubbleSize.height)
        case .none:
            xOrigin = refViewFrame.center.x - contentSize.width / 2
            yOrigin = refViewFrame.y + refViewFrame.height
            preferences.drawing.arrow.tip = CGPoint(x: refViewFrame.center.x - xOrigin, y: 0)
            bubbleFrame = CGRect(x: spacingForBorder, y: preferences.drawing.arrow.size.height + spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            tableView.frame = CGRect(x: 0, y: preferences.drawing.arrow.size.height, width: bubbleSize.width, height: bubbleSize.height)
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
        
        if isMessage {
            isMessage = false
            layer.shadowColor = UIColor.lightGray.cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize.zero
            layer.shadowRadius = 5
        }
        
        createWindow(with: controller)
        addTapGesture(for: controller)
        addSubview(self.tableView)
        self.tableView.reloadData()
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
        tap.delegate = self
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
            DispatchQueue.main.async {
                self.transform = self.preferences.animating.dismissTransform
                self.alpha = self.preferences.animating.dismissFinalAlpha
                self.containerWindow?.rootViewController?.view.alpha = 0
            }
        }) { (finished) -> Void in
            self.viewDidDisappear()
            self.removeFromSuperview()
            self.transform = CGAffineTransform.identity
            self.containerWindow?.resignKey()
            self.containerWindow = nil
        }
    }
    
    override open func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        drawBackgroundLayer()
        drawBubble(context)
    }
    
    private func viewDidAppear() {
        self.viewDidAppearDate = Date()
    }
    
    private func viewDidDisappear() {
        let viewDidDisappearDate = Date()
        let timeInterval = viewDidDisappearDate.timeIntervalSince(self.viewDidAppearDate)
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
        case .none:
            let startingPoint = CGPoint(x: preferences.drawing.arrow.tip.x - preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y)
            path.move(to: startingPoint)
            addTopArc(to: path)
            addLeftArc(to: path)
            addBottomArc(to: path)
            addRightArc(to: path)
            path.addLine(to: CGPoint(x: preferences.drawing.arrow.tip.x + preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y))
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let tview = touch.view, NSStringFromClass(type(of: tview.self)) == "UITableViewCellContentView" {
            return false
        }
        return true
    }
}

extension TGToolChoose: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TGChooseViewCell.cellIdentifier, for: indexPath) as! TGChooseViewCell
        cell.selectionStyle = .none
        let model = self.data[indexPath.row]
        cell.titleLab.text = model.title
        cell.titleLab.textColor = .black
        cell.icon.image = UIImage.set_image(named: model.image)
        cell.icon.image?.withRenderingMode(.alwaysTemplate)
        cell.icon.tintColor = .lightGray
        cell.redLab.isHidden = !model.isShowRedPiont
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.data[indexPath.row]

        switch model.type {
        case .photo, .video, .miniVideo:
            //            TSUtil.checkAuthorizeStatusByType(type: .cameraAlbum, isShowBottom: true, viewController: nil, completion: {
            self.handleTap()
            self.delegate?.didSelectedItem(type: model.type, title: model.title)
            //            })
            break
        case .live:
            //            TSUtil.checkAuthorizeStatusByType(type: .videoCall, isShowBottom: true, viewController: nil, completion: {
            self.handleTap()
            self.delegate?.didSelectedItem(type: model.type, title: model.title)
//            })
//            
            break
        default:
            handleTap()
            self.delegate?.didSelectedItem(type: model.type, title: model.title)
            break
        }
    }
}


extension TSIMToolChoose {
    func dismissToolTips() {
        self.dismissWithAnimation()
    }
}

extension UIView {
    @discardableResult
    func showIMToolChoose(identifier: String, data: [GroupIMActionItem], arrowPosition: TSIMToolChoose.ArrowPosition, preferences: TGToolChoosePreferences = TGToolChoosePreferences(), delegate: IMToolChooseDelegate? = nil, dismissCompletion: TGEmptyClosure? = nil) -> TSIMToolChoose {
        let tooltip = TSIMToolChoose(view: self, identifier: identifier, data: data, arrowPosition: arrowPosition, preferences: preferences, delegate: delegate, dismissCompletion: dismissCompletion)
        tooltip.calculateBubbleSize()
        tooltip.calculateFrame()
        tooltip.show()
        return tooltip
    }
}
protocol IMToolChooseDelegate: AnyObject {
    func didSelectedItem(model: IMActionItem)
}

// MARK: TSIMToolChoose class implementation
class TSIMToolChoose: UIView, UIGestureRecognizerDelegate {
    enum ArrowPosition: Int {
        case top
        case right
        case bottom
        case left
        case topRight
        case topLeft
        case bottomLeft
        case bottomRight
        case topRightWithButtonHeight
        case none
    }
    
    // MARK: Variables
    
    public let controller = ToolTipViewController()
    
    private var arrowPosition: ArrowPosition = .top
    private var bubbleFrame: CGRect = .zero
    
    private var containerWindow: UIWindow?
    private weak var presentingView: UIView?
    
    private var id: String
    
    private weak var delegate: IMToolChooseDelegate?
    
    private var viewDidAppearDate: Date = Date()
    
    private var preferences: TGToolChoosePreferences
    var data = [GroupIMActionItem]()
    let noOfCellsInRow = 4
    
    private var dismissCompletion: TGEmptyClosure?
    
    // MARK: Lazy variables
    private lazy var gradient: CGGradient = { [unowned self] in
        let colors = self.preferences.drawing.bubble.gradientColors.map { $0.cgColor } as CFArray
        let locations = self.preferences.drawing.bubble.gradientLocations
        return CGGradient(colorsSpace: nil, colors: colors, locations: locations)!
    }()
    
    private lazy var bubbleSize: CGSize = { [unowned self] in
        var height = min(preferences.drawing.rowHeight * CGFloat(data.count), preferences.drawing.rowHeight * CGFloat(preferences.drawing.rowMax))
        return CGSize(width: ScreenWidth * 0.85, height: height)
    }()
    
    private lazy var contentSize: CGSize = { [unowned self] in
        var height: CGFloat = 0
        var width: CGFloat = 0
        
        switch self.arrowPosition {
        case .top, .bottom, .topRight, .topLeft, .bottomRight, .bottomLeft, .topRightWithButtonHeight, .none:
            height = self.preferences.drawing.arrow.size.height + self.bubbleSize.height
            width = self.bubbleSize.width
        case .right, .left:
            height = self.bubbleSize.height
            width = self.preferences.drawing.arrow.size.height + self.bubbleSize.width
        }
        
        return CGSize(width: width, height: height)
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(TGChooseCollectionViewCell.self, forCellWithReuseIdentifier: TGChooseCollectionViewCell.cellIdentifier)
        collection.register(TGChooseFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: TGChooseFooterView.cellIdentifier)
        collection.dataSource = self
        collection.delegate = self
        collection.isScrollEnabled = false
        collection.isUserInteractionEnabled = true
        collection.backgroundColor = .clear
        return collection
    }()
    
    // MARK: Initializer
    init(view: UIView, identifier: String,  data: [GroupIMActionItem], arrowPosition: ArrowPosition, preferences: TGToolChoosePreferences, delegate: IMToolChooseDelegate? = nil, dismissCompletion: TGEmptyClosure? = nil) {
        self.presentingView = view
        self.id = identifier
        self.data = data
        self.arrowPosition = arrowPosition
        self.preferences = preferences
        self.delegate = delegate
        self.dismissCompletion = dismissCompletion
        super.init(frame: .zero)
        self.backgroundColor = .clear
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Gesture methods
    @objc func handleTap() {
        dismissCompletion?()
        dismissWithAnimation()
    }
    
    // MARK: Private methods
    fileprivate func calculateBubbleSize() {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            //let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
            let size = Int((ScreenWidth * 0.85) / CGFloat(noOfCellsInRow))
            //let totalPages = Int(ceil(Double(self.data.count) / Double(noOfCellsInRow)))
            var height = CGFloat(size * self.data.count)
            
            var paddingHeight: CGFloat = self.data.count >= 2 ? 10 : 0
            
            for var item in self.data {
                for var sub in item.items {
                    var textSize = sub.title.sizeOfString(usingFont: UIFont.systemFont(ofSize: 10))
                    if textSize.width > (CGFloat(size) * 0.6) {
                        paddingHeight += 10
                        break
                    }
                }
            }
            
            if self.data.count == 1 && (self.data.first?.items.count ?? 0) < 4 {
                bubbleSize = CGSize(width: CGFloat(size * (self.data.first?.items.count ?? 0)) + 20, height: height + paddingHeight)
                return
            }
            
            bubbleSize = CGSize(width: ScreenWidth * 0.85, height: height + paddingHeight)
        }
    }
    
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
            bubbleFrame = CGRect(x: spacingForBorder, y: preferences.drawing.arrow.size.height + spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: spacingForBorder + contentSize.width - 18, y: 0)
            collectionView.frame = CGRect(x: 0, y: preferences.drawing.arrow.size.height, width: bubbleSize.width, height: bubbleSize.height)
        case .top:
            xOrigin = refViewFrame.center.x - contentSize.width / 2
            yOrigin = refViewFrame.y + refViewFrame.height
            bubbleFrame = CGRect(x: spacingForBorder, y: preferences.drawing.arrow.size.height + spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: refViewFrame.center.x - xOrigin, y: 0)
            collectionView.frame = CGRect(x: 0, y: preferences.drawing.arrow.size.height, width: bubbleSize.width, height: bubbleSize.height)
        case .topLeft:
            xOrigin = refViewFrame.x + 50
            yOrigin = refViewFrame.y + refViewFrame.height
            bubbleFrame = CGRect(x: spacingForBorder, y: preferences.drawing.arrow.size.height + spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: bubbleFrame.x + preferences.drawing.arrow.size.width + 10, y: 0)
            collectionView.frame = CGRect(x: 0, y: preferences.drawing.arrow.size.height, width: bubbleSize.width, height: bubbleSize.height)
        case .topRight:
            xOrigin = UIScreen.main.bounds.width - (contentSize.width + spacingForBorder * 2) - preferences.drawing.bubble.inset
            yOrigin = refViewFrame.y + refViewFrame.height
            bubbleFrame = CGRect(x: spacingForBorder, y: preferences.drawing.arrow.size.height + spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x:  bubbleSize.width - (preferences.drawing.arrow.size.width + 10), y: 0)
            collectionView.frame = CGRect(x: 0, y: preferences.drawing.arrow.size.height, width: bubbleSize.width, height: bubbleSize.height)
        case .right:
            xOrigin = refViewFrame.x - contentSize.width
            yOrigin = refViewFrame.center.y - contentSize.height / 2
            bubbleFrame = CGRect(x: spacingForBorder, y: spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: bubbleSize.width + preferences.drawing.arrow.size.height + spacingForBorder, y: refViewFrame.center.y - yOrigin)
            collectionView.frame = CGRect(x: 0, y: 0, width: bubbleSize.width, height: bubbleSize.height)
        case .bottom:
            xOrigin = refViewFrame.center.x - contentSize.width / 2
            yOrigin = refViewFrame.y - contentSize.height
            bubbleFrame = CGRect(x: spacingForBorder, y: spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: refViewFrame.center.x - xOrigin, y: bubbleSize.height + preferences.drawing.arrow.size.height)
            collectionView.frame = CGRect(x: 0, y: 0, width: bubbleSize.width, height: bubbleSize.height)
        case .bottomLeft:
            xOrigin = refViewFrame.x + 50
            yOrigin = refViewFrame.y - contentSize.height
            bubbleFrame = CGRect(x: spacingForBorder, y: spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: bubbleFrame.x + preferences.drawing.arrow.size.width + 10, y: bubbleSize.height + preferences.drawing.arrow.size.height)
            collectionView.frame = CGRect(x: 0, y: 0, width: bubbleSize.width, height: bubbleSize.height)
        case .bottomRight:
            xOrigin = UIScreen.main.bounds.width - (contentSize.width + spacingForBorder * 2) - preferences.drawing.bubble.inset
            yOrigin = refViewFrame.y - contentSize.height
            bubbleFrame = CGRect(x: spacingForBorder, y: spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: bubbleSize.width - (preferences.drawing.arrow.size.width + 10), y: bubbleSize.height + preferences.drawing.arrow.size.height)
            collectionView.frame = CGRect(x: 0, y: 0, width: bubbleSize.width, height: bubbleSize.height)
        case .left:
            xOrigin = refViewFrame.x + refViewFrame.width
            yOrigin = refViewFrame.center.y - contentSize.height / 2
            bubbleFrame = CGRect(x: preferences.drawing.arrow.size.height + spacingForBorder, y: spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: spacingForBorder, y: refViewFrame.center.y - yOrigin)
            collectionView.frame = CGRect(x: 0, y: 0, width: bubbleSize.width, height: bubbleSize.height)
        case .none:
            xOrigin = refViewFrame.center.x - contentSize.width / 2
            yOrigin = refViewFrame.y + refViewFrame.height
            bubbleFrame = CGRect(x: spacingForBorder, y: preferences.drawing.arrow.size.height + spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: refViewFrame.center.x - xOrigin, y: 0)
            collectionView.frame = CGRect(x: 0, y: preferences.drawing.arrow.size.height, width: bubbleSize.width, height: bubbleSize.height)
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
        addSubview(collectionView)
        addCollectionTapGesture()
        showWithAnimation()
    }
    
    private func addCollectionTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCollectionTap(_:)))
        collectionView.addGestureRecognizer(tap)
    }
    
    @objc func handleCollectionTap(_ sender: UITapGestureRecognizer) {
        if let indexPath = collectionView.indexPathForItem(at: sender.location(in: collectionView)) {
            let model = self.data[indexPath.section].items[indexPath.row]
            self.handleTap()
            self.delegate?.didSelectedItem(model: model)
       }
    }
    
    private func createWindow(with viewController: UIViewController) {
        self.containerWindow = UIWindow(frame: UIScreen.main.bounds)
        self.containerWindow!.rootViewController = viewController
        self.containerWindow!.windowLevel = UIWindow.Level.alert + 1;
        self.containerWindow!.makeKeyAndVisible()
    }
    
    private func addTapGesture(for viewController: UIViewController) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.delegate = self
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
    
    override open func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        drawBackgroundLayer()
        drawBubble(context)
    }
    
    private func viewDidAppear() {
        self.viewDidAppearDate = Date()
    }
    
    private func viewDidDisappear() {
        let viewDidDisappearDate = Date()
        let timeInterval = viewDidDisappearDate.timeIntervalSince(self.viewDidAppearDate)
        
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
        case .topLeft:
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
        case .bottomRight:
            let startingPoint = CGPoint(x: preferences.drawing.arrow.tip.x + preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y + bubbleFrame.height)
            path.move(to: startingPoint)
            addBottomArc(to: path)
            addRightArc(to: path)
            addTopArc(to: path)
            addLeftArc(to: path)
            path.addLine(to: CGPoint(x: preferences.drawing.arrow.tip.x - preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y + bubbleFrame.height))
            addArrowTipArc(with: startingPoint, to: path)
        case .bottomLeft:
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
        case .none:
            let startingPoint = CGPoint(x: preferences.drawing.arrow.tip.x - preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y)
            path.move(to: startingPoint)
            addTopArc(to: path)
            addLeftArc(to: path)
            addBottomArc(to: path)
            addRightArc(to: path)
            path.addLine(to: CGPoint(x: preferences.drawing.arrow.tip.x + preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y))
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let tview = touch.view, NSStringFromClass(type(of: tview.self)) == "UITableViewCellContentView" {
            return false
        }
        return true
    }
}

extension TSIMToolChoose: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        //let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        let size = Int(((ScreenWidth * 0.85) - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TGChooseCollectionViewCell.cellIdentifier, for: indexPath) as! TGChooseCollectionViewCell
        let model = self.data[indexPath.section].items[indexPath.row]
        cell.iconTitleLabel.text = model.title
        cell.iconTitleLabel.textColor = preferences.drawing.message.color
        cell.iconImageView.image = UIImage(named: model.image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section != self.data.count - 1 {
            return CGSize(width: bubbleSize.width, height: 1)
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            if indexPath.section != self.data.count - 1 {
                let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TGChooseFooterView.cellIdentifier, for: indexPath)
                footerView.width =  bubbleSize.width * 0.94
                
                return footerView
            }
        }
        /// Normally should never get here
        return UICollectionReusableView()
    }
}
