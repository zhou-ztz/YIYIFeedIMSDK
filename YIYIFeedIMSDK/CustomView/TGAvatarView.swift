//
//  TGAvatarView.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/28.
//

import UIKit
import SDWebImage
import SnapKit
import YYCategories

// MARK: - 头像初始化方法
extension TGAvatarView {

    convenience init() {
        self.init(frame: CGRect(origin: .zero, size: AvatarType.width33(showBorderLine: false).size))
        setUI()
    }
    
    convenience init(origin: CGPoint = .zero, type: AvatarType, animation: Bool = false, isFromReactionList: Bool = false) {
        self.init(frame: CGRect(origin: origin, size: type.size))
        self.showBoardLine = type.showBorderLine
        self.showLiveIcon = animation
        self.isFromReactionList = isFromReactionList
        setUI()
    }
}
public class TGAvatarView: UIView {

    var shouldAnimate = false
    public enum PlaceholderType: String {

        case unknown = "IMG_pic_default_secret"
        case group = "ic_rl_default_group"
        
        init(sexNumber: Int?) {
            guard let number = sexNumber else {
                self = .unknown
                return
            }
            switch number {
            case 3:
                self = .group
            default:
                self = .unknown
            }
        }
    }

    /// 头像信息
    var avatarInfo = TGAvatarInfo() {
        didSet {
            if avatarInfo.avatarPlaceholderType != .unknown {
                    avatarPlaceholderType = avatarInfo.avatarPlaceholderType
            }
            // 加载头像
            loadAvatar()
            // 加载认证图标
            loadVerifiedIcon()
            // 加载点击事件
            loadTouchEvent()
            loadLiveAnimation()
            
            bringSubviewToFront(liveIcon)
            bringSubviewToFront(buttonForVerified)
        }
    }

    /// 头像边框
    var borderWidth: CGFloat = 2
    /// 头像边框颜色
    var borderColor = UIColor.white
    /// 是否显示边框
    var showBoardLine = false

    /// 头像按钮
    var buttonForAvatar = UIButton(type: .custom)
    /// 认证图标按钮
    var buttonForVerified = UIButton(type: .custom)

    /// 头像占位图类型
    var avatarPlaceholderType = PlaceholderType.unknown
    /// 头像占位图
    var avatarPlaceholderImage: UIImage {
        return UIImage.set_image(named: avatarPlaceholderType.rawValue) ?? UIImage()
    }
    /// able to custom placeholder image
    var customAvatarPlaceholderImage: UIImage?
    
    /// 屏幕比例
    let scale = UIScreen.main.scale
    /// 重绘大小的配置
//    var resizeProcessor: ResizingImageProcessor {
//        let avatarImageSize = CGSize(width: avatarFrame.width * scale, height: avatarFrame.width * scale)
//        return ResizingImageProcessor(referenceSize: avatarImageSize, mode: .aspectFill)
//    }
    /// 头像 frame
    var avatarFrame: CGRect {
        return bounds
    }
    var showLiveIcon: Bool = false
    var isFromReactionList: Bool = false
    var onImageLoaded: (() -> Void)?

    private var liveIcon: UIImageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 1, height: 1))).configure {
        $0.contentMode = .scaleAspectFit
    }
    
    private var shapeLayer: CAShapeLayer?
    
    private let loadingProcessView = UILabel()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer?.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        buttonForAvatar.applyBorder(color: borderColor, width: showBoardLine ? borderWidth : 0)
        buttonForAvatar.circleCorner()
        let frameWidth = max(frame.width, 1.0)

        if buttonForAvatar.frame.width == 0 {
            buttonForAvatar.layer.cornerRadius = frameWidth / 2
        }
        buttonForAvatar.clipsToBounds = true
        buttonForAvatar.imageView?.contentMode = .scaleAspectFill
    }
     
    // MARK: - Public

    // MARK: - UI
    private func setUI() {
        addSubview(buttonForAvatar)
        addSubview(buttonForVerified)
        addSubview(liveIcon)
        liveIcon.isHidden = !showLiveIcon
        liveIcon.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(-8)
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.4)
        }
        
        buttonForAvatar.snp.makeConstraints { (make) in
            make.width.height.equalToSuperview()
            make.edges.equalToSuperview()
        }
        
        buttonForVerified.snp.makeConstraints { (make) in
            make.width.height.equalToSuperview().multipliedBy(0.35)
            make.right.bottom.equalToSuperview().offset(1.5)
        }
        
        loadingProcessView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        loadingProcessView.isHidden = true
        loadingProcessView.isUserInteractionEnabled = false
        loadingProcessView.textColor = .white
        loadingProcessView.textAlignment = .center
        addSubview(loadingProcessView)
        loadingProcessView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        bringSubviewToFront(buttonForVerified)
        bringSubviewToFront(liveIcon)
    }

}

// MARK: - 头像加载
extension TGAvatarView {
    /// 加载头像
    fileprivate func loadAvatar() {
        // 2.加载头像图片
//        buttonForAvatar.sd_setImage(with: URL(string: avatarInfo.avatarURL.orEmpty), for: .normal, placeholderImage: avatarPlaceholderImage, options: [.lowPriority, .scaleDownLargeImages])
        buttonForAvatar.sd_setImage(
            with: URL(string: avatarInfo.avatarURL.orEmpty),
            for: .normal,
            placeholderImage: avatarPlaceholderImage ?? UIImage(named: avatarPlaceholderType.rawValue),
            options: [.lowPriority, .scaleDownLargeImages]
        ) { [weak self] image, error, cacheType, url in
            // 👇 notify CommonSharedUIView or trigger your share flow
            self?.onImageLoaded?()
        }

    }
}

// MARK: - 认证图标加载
extension TGAvatarView {

    /// 加载认证图标
    fileprivate func loadVerifiedIcon() {
        // 1.判断是否显示认证图标，并配置显示设置
        buttonForVerified.isHidden = avatarInfo.verifiedType.isEmpty
        buttonForVerified.isUserInteractionEnabled = false // 暂不开放认证图标点击事件
        buttonForVerified.imageView?.contentMode = .scaleToFill
        
        buttonForVerified.clipsToBounds = true
        let frameHeight = max(self.frame.height, 1.0)
        self.buttonForVerified.layer.cornerRadius = frameHeight * 0.35 / 2

        // 2.根据认证 icon，加载认证图片
        guard !avatarInfo.verifiedType.isEmpty else {
            return
        }
        /*
         这里的逻辑为：
         1.后台返回了图标图片 url，就加载后台返回的图标图片。
         2.后台没有返回图标图片 url，就加载本地的图标图片。
         */
        // 使用本地图片
        if avatarInfo.verifiedIcon.isEmpty {
            // 使用本地图片
            var imageName: String?
            switch avatarInfo.verifiedType {
            case "user":
                imageName = "IMG_pic_identi_individual"
            case "org":
                imageName = "IMG_pic_identi_company"
            default:
                imageName = ""
            }
            if let name = imageName {
                let localImage = UIImage(named: name)
                buttonForVerified.setImage(localImage, for: .normal)
                buttonForVerified.imageView?.isHidden = false
            } else {
                buttonForVerified.imageView?.isHidden = true
            }
        } else {
            // 加载后台返回图标
            if let iconURL = URL(string: self.avatarInfo.verifiedIcon) {
                self.buttonForVerified.sd_setImage(with: iconURL, for: .normal, placeholderImage: nil, options: [.refreshCached], completed: nil)
            } else {
                self.buttonForVerified.imageView?.isHidden = true
            }

        }
    }
}

// MARK: - 头像点击事件
extension TGAvatarView {

    /// 设置点击事件
    func loadTouchEvent() {
        // 1. 清空所有点击事件
        buttonForAvatar.removeAllTargets()

        // 2. 根据头像类型，加载不同的头像
        switch avatarInfo.type {
        case .unknow:
            buttonForAvatar.addTarget(self, action: #selector(unknowUserTaped), for: .touchUpInside)
        case .normal(let userId):
            if userId != nil {
                buttonForAvatar.addTarget(self, action: #selector(normalUserTaped), for: .touchUpInside)
            }
        }
    }

    /// 点击了未知用户
    @objc func unknowUserTaped() {

    }

    /// 点击了普通用户
    @objc func normalUserTaped() {
        // 如果没有设置 userId，就认为 coder 选择不使用默认点击事件
        //guard let userId = avatarInfo.type.userId, userId != CurrentUserSessionInfo?.userIdentity else {
        guard let userId = avatarInfo.type.userId else {
            return
        }
        RLSDKManager.shared.imDelegate?.didPressUerProfile(uid: userId)

    }
}

extension TGAvatarView {
    func showLoadingOverlay() {
        loadingProcessView.layer.masksToBounds = true
        loadingProcessView.roundCorner(frame.height / 2.0)
        loadingProcessView.text = "0%"
        loadingProcessView.isHidden = false
    }
    func hideLoading() {
        loadingProcessView.isHidden = true
    }
    func updateLoadingProcess(completedFraction:Double) {
        if completedFraction > 0.99 {
            loadingProcessView.isHidden = true
            return
        }
        let percentage = String(format: "%.0f", completedFraction * 100)
        loadingProcessView.text = "\(percentage)%"
    }
}

extension TGAvatarView {
    
    func loadLiveAnimation() {
        if self.shapeLayer != nil {
            self.shapeLayer?.removeFromSuperlayer()
            self.shapeLayer = nil
        }
        guard showLiveIcon && avatarInfo.hasLive() else {
            liveIcon.isHidden = true
            return
        }
        
        if let color = avatarInfo.frameColor {
            let lineWidth:CGFloat = 1.0
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = UIBezierPath(ovalIn: self.bounds).cgPath
            shapeLayer.lineWidth = lineWidth
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = UIColor(hex: color).cgColor

            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.duration = 0.5
            scaleAnimation.fromValue = 1.05
            scaleAnimation.toValue = 1.2
            scaleAnimation.repeatCount = .infinity
            scaleAnimation.autoreverses = true
            scaleAnimation.isRemovedOnCompletion = false
            
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.duration = 0.5
            opacityAnimation.fromValue = 1
            opacityAnimation.toValue = 0.4
            opacityAnimation.repeatCount = .infinity
            opacityAnimation.autoreverses = true
            opacityAnimation.isRemovedOnCompletion = false
            
            shapeLayer.add(opacityAnimation, forKey: "opacity")
            shapeLayer.add(scaleAnimation, forKey: "scale")
            
            shapeLayer.bounds = self.bounds
            shapeLayer.frame = self.layer.bounds
            shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            shapeLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)

            self.layer.addSublayer(shapeLayer)
            self.shapeLayer = shapeLayer
        }
        
        if let icon = avatarInfo.frameIcon {
            liveIcon.sd_setImage(with: URL(string: icon), placeholderImage: nil, options: [.scaleDownLargeImages], completed: nil)
            liveIcon.isHidden = false
        } else {
            liveIcon.isHidden = true
        }
    }
}


// 常用头像类型
enum AvatarType {

    case custom(avatarWidth: CGFloat, showBorderLine: Bool)

    /// 头像 size
    var size: CGSize {
        switch self {
        case .custom(avatarWidth: let width, showBorderLine: _):
            return CGSize(width: width, height: width)
        }
    }

    /// 头像宽度
    var width: CGFloat {
        return size.width
    }

    /// 是否显示白边
    var showBorderLine: Bool {
        switch self {
        case .custom(avatarWidth: _, showBorderLine: let showBorderLine):
            return showBorderLine
        }
    }
}

// MARK: - 常用的头像类型
extension AvatarType {

    static func width100(showBorderLine: Bool) -> AvatarType {
        return AvatarType.custom(avatarWidth: 100, showBorderLine: showBorderLine)
    }
    
    static func width70(showBorderLine: Bool) -> AvatarType {
        return AvatarType.custom(avatarWidth: 70, showBorderLine: showBorderLine)
    }

    static func width60(showBorderLine: Bool) -> AvatarType {
        return AvatarType.custom(avatarWidth: 60, showBorderLine: showBorderLine)
    }
    
    static func width48(showBorderLine: Bool) -> AvatarType {
        return AvatarType.custom(avatarWidth: 48, showBorderLine: showBorderLine)
    }

    static func width43(showBorderLine: Bool) -> AvatarType {
        return AvatarType.custom(avatarWidth: 43, showBorderLine: showBorderLine)
    }

    static func width38(showBorderLine: Bool) -> AvatarType {
        return AvatarType.custom(avatarWidth: 38, showBorderLine: showBorderLine)
    }

    static func width33(showBorderLine: Bool) -> AvatarType {
        return AvatarType.custom(avatarWidth: 33, showBorderLine: showBorderLine)
    }
    
    static func width26(showBorderLine: Bool) -> AvatarType {
        return AvatarType.custom(avatarWidth: 26, showBorderLine: showBorderLine)
    }

    static func width20(showBorderLine: Bool) -> AvatarType {
        return AvatarType.custom(avatarWidth: 20, showBorderLine: showBorderLine)
    }
    
    static func width05(showBorderLine: Bool) -> AvatarType {
        return AvatarType.custom(avatarWidth: 5, showBorderLine: showBorderLine)
    }
}

public class TGAvatarInfo {

    /// 用户头像类型
    public enum UserAvatarType {
        /// 未知用户
        case unknow
        /// 普通用户，如果 userId 不为 nil 点击头像会 push 到对应用户的个人主页
        case normal(userId: Int?)

        public var userId: Int? {
            switch self {
            case .normal(let userId):
                return userId
            default:
                return nil
            }
        }
    }

    /// 头像类型
    public var type = UserAvatarType.normal(userId: nil)
    /// 头像 url
    public var avatarURL: String?
    /// 认证信息，为空表示没有
    public var verifiedType = ""
    /// 认证图标，为空表示没有
    public var verifiedIcon = ""
    /// 头像占位图类型,性别相关
    public var avatarPlaceholderType = TGAvatarView.PlaceholderType.unknown
    /// 性别 0 - Unknown, 1 - Man, 2 - Woman.
    public var sex: Int = 0
    
    public var username: String?
    
    public var nickname: String?

    public var frameIcon: String?
    public var frameColor: String?
    public var liveId: Int?
    
    public init() {
    }

    /// 初始化
    init(userModel model: TGUserInfoModel) {
        avatarURL =  model.avatarUrl.orEmpty.smallPicUrl(showingSize: CGSize(width: 150, height: 150))
        verifiedType = model.verificationIcon.orEmpty
        verifiedIcon = model.verificationIcon.orEmpty
        sex = model.sex
        avatarPlaceholderType = TGAvatarView.PlaceholderType(sexNumber: sex)
        type = .normal(userId: model.userIdentity)
        username = model.username
        nickname = model.name
        frameIcon = model.profileFrameIcon
        frameColor = model.profileFrameColorHex
        liveId = model.liveFeedId
    }

    public init(avatarURL: String) {
        self.avatarURL = avatarURL
    }
    
    init(model: UserInfoType) {
        avatarURL =  model.avatarUrl.orEmpty.smallPicUrl(showingSize: CGSize(width: 150, height: 150))
        verifiedType = model.verificationType.orEmpty
        verifiedIcon = model.verificationIcon.orEmpty
        sex = model.sex
        avatarPlaceholderType = TGAvatarView.PlaceholderType(sexNumber: sex)
        type = .normal(userId: model.userIdentity)
        username = model.username
        nickname = model.name
        frameIcon = model.profileFrameIcon
        frameColor = model.profileFrameColorHex
        liveId = model.liveFeedId
    }
}

extension TGAvatarInfo {
    
    func hasLive() -> Bool {
        return liveId != nil
    }
}
