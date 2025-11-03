//
//  TGFeedDetailInteractiveView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/20.
//

import Foundation
import UIKit

class TGFeedDetailInteractiveView: UIView {
    
    @IBOutlet weak var topGradientView: Gradient!
    @IBOutlet weak var bottomGradientView: Gradient!
    
    @IBOutlet weak var pageCounterLabel: UILabel!
    @IBOutlet weak var avatarView: TGAvatarView!
    @IBOutlet weak var avatarLabel: UILabel!
    @IBOutlet weak var sponsorLabel: UILabel!
    @IBOutlet weak var followButton: TGFollowButton!
    @IBOutlet weak var readMoreLabel: TGTruncatableLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var separatorLine: UIView!
    @IBOutlet weak var viewCountLabel: UILabel!

    @IBOutlet weak var contentStack: UIStackView!
    @IBOutlet weak var viewsAndTimeView: UIStackView!
   
    @IBOutlet var view: UIView!
    @IBOutlet weak var bottomToolStackView: UIStackView!
    @IBOutlet weak var bottomVerticalStackView: UIStackView!
    
    private var aiFeedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0x000000).withAlphaComponent(0.1)
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    let moreButton = UIButton(type: .custom).configure {
        $0.setImage(UIImage(named: "IMG_topbar_more_white"), for: .normal)
    }
    private var commentView: UIView = {
        let lineV = UIView()
        return lineV
    }()
    
    private var commentButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = InconspicuousColor().disabled
        button.setTitle("rw_placeholder_comment".localized, for: .normal)
        button.setTitleColor(UIColor(hex: 0xB4B4B4), for: .normal)
        button.titleLabel?.font = UIFont.systemRegularFont(ofSize: 14)
        button.roundCorner(17.0)
        return button
    }()
    let toolbar = TGToolbarView()
    
    private lazy var locationAndMerchantScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.isPagingEnabled = false // 根据需要调整是否启用分页
        scrollView.alwaysBounceHorizontal = true // 允许水平滚动时始终弹性滚动
        return scrollView
    }()
    //地理位置信息和商户信息
    private lazy var locationAndMerchantView: UIStackView = {
        let stackview = UIStackView()
        stackview.axis = .horizontal
        stackview.alignment = .fill
        stackview.spacing = 8.0
        return stackview
    }()
    //商家类目
    private var feedShopView = TGFeedCommentDetailShopView(frame: .zero, shopSubViewType: .darkPicture, isDarkBackground: true, isInnerFeed: true)
    //商家名称类目
    private var feedMerchantNamesView = TGFeedDetailMerchantNamesView(frame: .zero)
    
    private var originalTexts: String = ""
    private var translatedTexts: String = ""
    
    private var translateButton: LoadableButton = LoadableButton(frame: .zero, icon: nil,
                                                                 text: "text_translate".localized, textColor: TGAppTheme.primaryBlueColor,
                                                                 font: UIFont.systemMediumFont(ofSize: 12), bgColor: .clear, cornerRadius: 0,
                                                                 withShadow: false).build { translateButton in
                                                                    translateButton.setTitle("button_original".localized, for: .selected)
                                                                    translateButton.setTitle("text_translate".localized, for: .normal)
                                                                 }
    
    private lazy var dateDotView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.roundCorner(1)
        return view
    }()
    
    private lazy var translateDotView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.roundCorner(1)
        return view
    }()

    var feedId: Int = 0 {
        willSet {
            reactionHandler?.feedId = newValue
        }
    }
    
    var feedItem: FeedListCellModel? {
        willSet {
            reactionHandler?.feedItem = newValue
        }
    }
    
    var reactionType: ReactionTypes? {
        willSet {
            reactionHandler?.currentReaction = newValue
        }
    }
    
    let reactionView = TGUserReactionView()
    var voucherBottomView = VoucherBottomView()

    var onCommentTouched: TGEmptyClosure?
    var onGiftTouched: TGEmptyClosure?
    var onAITouched: TGEmptyClosure?
    var onMoreTouched: TGEmptyClosure?
    var onFollowTouched: TGEmptyClosure?
    var onForwardTouched: TGEmptyClosure?
    var onVoucherTouched: TGEmptyClosure?
    var onReadMoreLabelStyleUpdate: ((Bool) -> Void)?
    var reactionHandler: TGReactionHandler?
    var onLocationViewTapped: ((String, String) -> Void)?
    var onTopicViewTapped: ((Int) -> Void)?
    var reactionSuccess: TGEmptyClosure?
    var onTapReactionList: ((Int) -> Void)?
    var translateHandler: ((Bool) -> Void)?
    var onTapHiddenUpdate: ((Bool) -> Void)?
    var userIdList: [String] = []
    var merchantIdList: [String] = []
    var merchantAppIdList: [String] = []
    var merchantDealPathList: [String] = []
    var htmlAttributedText: NSMutableAttributedString?
    var onSearchPageTapped: ((String) -> Void)?
    var hasLocation: Bool = false
    var hasMerchants: Bool = false
    
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }

    // MARK: - Lifecycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        reactionHandler?.reset()
    }
    
    func updatePageCount(cur: Int, max: Int) {
        pageCounterLabel.text = "\(cur+1)/\(max)"
    }

    func updateTopicsView(with list: [TopicListModel]) {
        guard list.count > 0 else { return }
        let paddingContainer = UIView()
        let stackView = UIStackView().configure {
            $0.axis = .horizontal
            $0.alignment = .leading
        }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        for topic in list {
            let tagLabel: UIButton = UIButton(type: .custom)
            tagLabel.backgroundColor = UIColor(hexString: "#BAE6FF")
            tagLabel.setTitleColor(UIColor(hexString: "#19AAFE"), for: .normal)
            tagLabel.layer.cornerRadius = 8.5
            tagLabel.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            tagLabel.contentEdgeInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
            tagLabel.setTitle(" " + topic.topicTitle + " ", for: .normal)
            tagLabel.isUserInteractionEnabled = true
            tagLabel.addTap { [weak self] (_) in
                self?.onTopicViewTapped?(topic.topicId)
            }
            stackView.addArrangedSubview(tagLabel)
        }
        guard stackView.subviews.count > 0 else { return }
        stackView.addArrangedSubview(UIView())
        contentStack.insertArrangedSubview(paddingContainer, at: 1)

        paddingContainer.addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.left.top.centerX.centerY.equalToSuperview()
        }
    }

    func setBottomToolView() {
        bottomVerticalStackView.addArrangedSubview(voucherBottomView)
        bottomVerticalStackView.addArrangedSubview(bottomToolStackView)
        voucherBottomView.snp.makeConstraints {
            $0.right.left.equalToSuperview()
            $0.height.equalTo(44)
        }
        voucherBottomView.voucherOnTapped = { [weak self] in
            self?.onVoucherTouched?()
        }
        
        bottomToolStackView.addArrangedSubview(commentView)
        commentView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width * 0.5)
        }
        commentView.addSubview(commentButton)
        commentButton.addAction {
            self.onCommentTouched?()
        }
        commentButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(35)
            $0.centerY.equalToSuperview()
        }
      
        toolbar.backgroundColor = .clear
        toolbar.set(items: [TGToolbarItemModel(image: ["IMG_home_ico_love_white"] , title: "", index: 0, titleShouldHide: false), TGToolbarItemModel(image: ["IMG_home_ico_comment_normal_white"], title: "", index: 1, titleShouldHide: false), TGToolbarItemModel(image: ["IMG_home_ico_forward_normal_white"], title: "", index: 2, titleShouldHide: false) ])
        
        commentButton.backgroundColor = UIColor(hex: 0x3A3A3A)
        commentButton.setTitleColor(UIColor(hex: 0xB4B4B4), for: .normal)
        toolbar.setTitleColor(.white, At: 0)
        toolbar.setTitleColor(.white, At: 1)
        toolbar.setTitleColor(.white, At: 2)
    
        bottomToolStackView.addArrangedSubview(toolbar)
        toolbar.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width * 0.48)
        }
        bottomToolStackView.addArrangedSubview(UIView())
        
    }

    func updateLocationAndMerchantNameView(location: TSPostLocationModel?, rewardsMerchantUsers: [TGRewardsLinkMerchantUserModel]) {
        hasLocation = location != nil
        hasMerchants = !rewardsMerchantUsers.isEmpty
        
        // 设置 feedMerchantNamesView 的数据
        feedMerchantNamesView.setData(merchantList: rewardsMerchantUsers)
        feedMerchantNamesView.momentMerchantDidClick = { merchantData in
//               NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": merchantData.merchantId.stringValue])
            RLSDKManager.shared.imDelegate?.didPressUerProfile(uid: merchantData.merchantId)
        }
        // 如果有商家，则显示 feedMerchantNamesView，否则隐藏
        feedMerchantNamesView.isHidden = !hasMerchants
        
        // 如果有 location 或者有商家，则显示 locationAndMerchantView，否则隐藏
        locationAndMerchantView.isHidden = !(hasLocation || hasMerchants)
        
        // 清空 locationAndMerchantView 中的子视图
        locationAndMerchantView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 如果有 location，则添加 location 视图
        if let model = location {
            let icon = UIImageView().configure {
                $0.image = UIImage(named: "ic_location")
                $0.size = CGSize(width: 25, height: 14)
            }
            icon.snp.makeConstraints { make in
                make.width.equalTo(20)
            }

            let label = UILabel()
            label.text = model.locationName
            label.applyStyle(.regular(size: 12, color: .white))
            label.snp.makeConstraints { make in
                make.height.equalTo(20)
            }

            let stackView = UIStackView().configure {
                $0.axis = .horizontal
                $0.spacing = 5.0
            }
            stackView.addArrangedSubview(icon)
            stackView.addArrangedSubview(label)
            stackView.addTap(action: { [weak self] (_) in
                self?.onLocationViewTapped?(model.locationID, model.locationName)
            })
            locationAndMerchantView.addArrangedSubview(stackView)
        }
        
        // 添加 feedMerchantNamesView 到 locationAndMerchantView
        locationAndMerchantView.addArrangedSubview(feedMerchantNamesView)
        
        // 如果有 location 或者有商家，则将 locationAndMerchantView 添加到 contentStack 中
        if hasLocation || hasMerchants {
            contentStack.insertArrangedSubview(locationAndMerchantScrollView, at: 1)
            locationAndMerchantScrollView.addSubview(locationAndMerchantView)
            locationAndMerchantView.bindToEdges()
            locationAndMerchantScrollView.snp.makeConstraints {  (m) in
                m.height.equalTo(20)
            }
        }
    }
    
    func updateMerchantView(with rewardsMerchantUsers: [TGRewardsLinkMerchantUserModel]) {
        
        contentStack.insertArrangedSubview(feedShopView, at: 2)
        
        feedShopView.setData(merchantList: rewardsMerchantUsers)
        
        feedShopView.momentMerchantDidClick = { [weak self] merchantData in
            guard let self = self else { return }
            
            let appId = merchantData.wantedMid
            var path = merchantData.wantedPath
            path = path + "?id=\(appId)"
            RLSDKManager.shared.imDelegate?.didPressMiniProgrom(appId: "localInfo.mpExtras", path: path)
        }
        feedShopView.isHidden = true
        
        feedShopView.snp.updateConstraints { (m) in
            m.height.equalTo(rewardsMerchantUsers.count > 1 ? 125 : 110)
        }
        
    }
    
    func updateUser(user: TGUserInfoModel?) {
        guard let user = user else {
            avatarLabel.text = ""
            return
        }
        avatarView.showLiveIcon = true
        avatarView.avatarInfo = TGAvatarInfo(userModel: user)
        avatarLabel.text = user.remarkName ?? user.name
    }
    
    func updateUserAvatar(avatar: TGAvatarInfo?) {
        guard let avatar = avatar else {
            avatarLabel.text = ""
            return
        }
        avatarView.showLiveIcon = true
        
        avatarView.avatarInfo = avatar
        avatarLabel.text = avatar.username ?? avatar.nickname
    }
    
    func updateSponsorStatus(_ isShow: Bool) {
        if UserDefaults.sponsoredEnabled {
            sponsorLabel.text = "sponsored".localized
            sponsorLabel.setFontSize(with: 12.0, weight: .norm)
            sponsorLabel.isHidden = !isShow
        } else {
            sponsorLabel.isHidden = true
        }
    }

    func updateAIFeedView(isShow: Bool) {
        aiFeedView.isHidden = !isShow
    }

    
    func updateInfo(caption: String?, isExpand: Bool = false) {
        HTMLManager.shared.removeHtmlTag(htmlString: caption.orEmpty, completion: { [weak self] (content, userIdList, merchantIdList, merchantAppIdList, merchantDealPathList) in
            guard let self = self else { return }
            self.userIdList = userIdList
            self.merchantIdList = merchantIdList
            self.merchantAppIdList = merchantAppIdList
            self.merchantDealPathList = merchantDealPathList
            self.originalTexts = content
            self.htmlAttributedText = content.attributonString()
            if let attributedText = self.htmlAttributedText {
                self.htmlAttributedText = HTMLManager.shared.formAttributeText(attributedText, self.userIdList, self.merchantIdList, self.merchantAppIdList, self.merchantDealPathList)
            }
            self.readMoreLabel.isExpand = isExpand
            self.onReadMoreLabelStyleUpdate?(!isExpand)
            self.readMoreLabel.numberOfLines = 2
            self.updateContentLabel(content: content, original: caption.orEmpty)
            self.readMoreLabel.onHeightChanged = { [weak self] in
                guard let self = self else { return }
    //            self.bottomGradientView.layoutIfNeeded()
            }
            
            self.readMoreLabel.onHashTagTapped = { [weak self] hashtag in
                self?.onSearchPageTapped?(hashtag)
            }
            
            self.readMoreLabel.onUsernameTapped = { name in
                HTMLManager.shared.handleMentionTap(name: name, attributedText: self.htmlAttributedText, currentVC: self.parentViewController)
            }
            
            self.readMoreLabel.onHttpTagTapped = {[weak self] url in
                RLSDKManager.shared.feedDelegate?.didOpenDeepLink(deepLink: url)
            }
            
            readMoreLabel.onTextNumberOfLinesTapped = {[weak self] showLinesStyle in
                self?.onReadMoreLabelStyleUpdate?(showLinesStyle == .TruncatableLabelShowLess)
                guard let self = self, let model = self.feedItem, model.rewardsMerchantUsers.count > 0 else { return }
                self.feedShopView.isHidden = showLinesStyle == .TruncatableLabelShowLess
                self.feedMerchantNamesView.isHidden = showLinesStyle == .TruncatableLabelShowMore
                
                if showLinesStyle == .TruncatableLabelShowMore && hasLocation {
                    locationAndMerchantScrollView.snp.makeConstraints { m in
                        m.height.equalTo(20)
                    }
                } else if showLinesStyle != .TruncatableLabelShowMore {
                    locationAndMerchantScrollView.snp.makeConstraints { m in
                        m.height.equalTo(20)
                    }
                } else {
                    contentStack.removeArrangedSubview(locationAndMerchantScrollView)
                }
            }
            
//            translateButton.isHidden = !TSCurrentUserInfo.share.isLogin || self.originalTexts.isEmpty || self.originalTexts.containsOnlyEmoji
            translateButton.isHidden = self.originalTexts.isEmpty || self.originalTexts.containsOnlyEmoji
            translateDotView.isHidden = translateButton.isHidden
        })
    }
    
    func updateTranslateText() {
        TGFeedNetworkManager.shared.translateFeed(feedId: self.feedId) { [weak self] (translates, msg, status) in
            guard let self = self else { return }
            self.translatedTexts = translates ?? ""
            HTMLManager.shared.removeHtmlTag(htmlString: translates ?? "", completion: { [weak self] (content, userIdList, merchantIdList, merchantAppIdList, merchantDealPathList) in
                self?.userIdList = userIdList
                self?.merchantIdList = merchantIdList
                self?.merchantAppIdList = merchantAppIdList
                self?.merchantDealPathList = merchantDealPathList
                DispatchQueue.main.async {
                    self?.updateContentLabel(content: content, original: translates ?? "")
                    self?.translateButton.isSelected = true
                }
            })
        }
    }

    func updateFollowButton(_ status: FollowStatus) {
        followButton.isHidden = status != .unfollow
    }

    func updateTimeAndView(date: Date?, views: Int, isEdit: Bool = false) {
        viewCountLabel.text = views.abbreviated + "number_of_browsed".localized
        guard let date = date else {
            timeLabel.text = ""
            return
        }
    
        timeLabel.text = date.timeAgoDisplay(dateFormat: "MMMM dd")
        viewCountLabel.sizeToFit()
        timeLabel.sizeToFit()

        dateDotView.removeFromSuperview()
        translateDotView.removeFromSuperview()
        
        viewsAndTimeView.insertArrangedSubview(dateDotView, at: 1)
        dateDotView.snp.makeConstraints {
            $0.width.height.equalTo(2)
        }
        
        translateDotView.snp.makeConstraints {
            $0.width.height.equalTo(2)
        }
        
        if !isEdit {
            viewsAndTimeView.insertArrangedSubview(translateDotView, at: 3)
            
            let existingTranslateContainer = viewsAndTimeView.arrangedSubviews.first { view in
                return view.subviews.contains { $0 === translateButton }
            }
            
            if existingTranslateContainer == nil {
                let leftAligned = UIView()
                leftAligned.addSubview(translateButton)
                translateButton.contentHorizontalAlignment = .left
                translateButton.snp.makeConstraints { (v) in
                    v.top.left.bottom.right.equalToSuperview()
                    v.right.lessThanOrEqualToSuperview()
                }
                
                viewsAndTimeView.addArrangedSubview(leftAligned)
            }
        }
        // By Kit Foong (Added checking when no text or only emoji will hide translate button)
        translateButton.isHidden =  self.originalTexts.isEmpty || self.originalTexts.containsOnlyEmoji
        translateDotView.isHidden = translateButton.isHidden
        
        translateButton.addTap { [weak self] (button) in
            guard let self = self, let button = button as? LoadableButton else { return }
            guard button.isSelected == false else {
                self.htmlAttributedText = self.originalTexts.attributonString().setTextFont(14).setlineSpacing(0)
                self.readMoreLabel.isExpand = self.readMoreLabel.currentLabelShowStyle == .TruncatableLabelShowMore
                if let attributedText = self.htmlAttributedText {
                    self.htmlAttributedText = HTMLManager.shared.formAttributeText(attributedText, userIdList, merchantIdList, merchantAppIdList, merchantDealPathList)
                    self.readMoreLabel.setAttributeText(attString: attributedText, allowTruncation: true)
                } else {
                    self.readMoreLabel.setText(text:  self.originalTexts, allowTruncation: true)
                }
                button.isSelected = false
                self.translateHandler?(button.isSelected)
                return
            }
            
            
            button.showLoader(userInteraction: false)
            
            TGFeedNetworkManager.shared.translateFeed(feedId: self.feedId) { [weak self] (translates, msg, status) in
                guard let self = self else { return }
                defer { button.hideLoader() }
                DispatchQueue.main.async {
                    if status == true {
                        self.translatedTexts = translates ?? ""
                        self.readMoreLabel.setText(text: self.translatedTexts,
                                                   textColor: self.readMoreLabel.label.textColor,
                                                   allowTruncation: true)
                        button.isSelected = true
                    }else {
                        button.isSelected = false
                    }
                    self.translateHandler?(button.isSelected)
                }
            }
            
        }
        
        viewsAndTimeView.layoutIfNeeded()
    }
    
    func updateContentLabel(content: String, original: String) {
        htmlAttributedText = content.attributonString().setTextFont(14).setlineSpacing(0)
        if let attributedText = htmlAttributedText {
            htmlAttributedText = HTMLManager.shared.formAttributeText(attributedText, userIdList, merchantIdList, merchantAppIdList, merchantDealPathList)
            readMoreLabel.setAttributeText(attString: attributedText, allowTruncation: true)
        } else {
            readMoreLabel.setText(text: original,
                                       textColor: readMoreLabel.label.textColor,
                                       allowTruncation: true)
        }
    }
    
    func updateCount(comment: Int, like: Int, forwardCount: Int) {
        
        // 设置点赞数量
        toolbar.setTitle(like.abbreviated, At: 0)
        // 设置评论按钮
        toolbar.setTitle(comment.abbreviated, At: 1)
        // 设置转发按钮
        toolbar.setTitle(forwardCount.abbreviated, At: 2)
        toolbar.delegate = self
        
      
        
    }

    func updateCommentStatus(isCommentDisabled: Bool?) {
        guard let isCommentDisabled = isCommentDisabled  else {
            return
        }
        if isCommentDisabled == true {
            toolbar.item(isHidden: true, at: 1)
            commentView.isHidden = true
        } else {
            toolbar.item(isHidden: false, at: 1)
            commentView.isHidden = false
        }
    }
    
    func updateGiftImage(canAcceptReward: Bool, imageName: String) {

    }
    func updateReactionButton(reactionType: ReactionTypes?) {
        
        let reactionMapping: [ReactionTypes: ReactionTypes] = [
            .heart: .heart,
            .like: .heart,
            .angry: .angry,
            .awesome: .awesome,
            .cry: .cry,
            .wow: .wow
        ]
        
        let blackReactionMapping: [ReactionTypes: ReactionTypes] = [
            .heart: .blackHeart,
            .like: .blackHeart,
            .angry: .blackAngry,
            .awesome: .blackAwesome,
            .cry: .blackCry,
            .wow: .blackWow
        ]
        
        if let reaction = reactionType {
            if !reaction.imageName.contains("black"), let selectedReaction = blackReactionMapping[reaction] {
                toolbar.setImage([selectedReaction.imageName], At: 0)
            } else {
                toolbar.setImage([reaction.imageName], At: 0)
            }
        } else {
            toolbar.setImage(["IMG_home_ico_love_white"] , At: 0)
        }
    }

    func updateUserReactionView(topReactionList: [ReactionTypes?], totalReactions: Int) {
        guard topReactionList.count > 0 else {
            if reactionView.superview != nil {
                reactionView.removeFromSuperview()
            }
            return
        }
        reactionView.setData(reactionIcon: topReactionList, totalReactionCount: totalReactions, labelTextColor: UIColor.white, isInnerFeed: true)
        
        if reactionView.superview == nil {
            let paddingView = UIView()
            paddingView.addSubview(reactionView)
            reactionView.snp.makeConstraints {
                $0.top.left.right.bottom.equalToSuperview()
            }
            contentStack.addArrangedSubview(paddingView)
        }
    }

    func updateUserReacitonData(topReactionList: [ReactionTypes?], totalReactions: Int) {
        reactionView.setData(reactionIcon: topReactionList, totalReactionCount: totalReactions, labelTextColor: UIColor.white, isInnerFeed: true)
    }

    func fadeOut() {
        UIView.animate(withDuration: 0.15, animations: { () -> () in
            self.alpha = 0
        }, completion: { _ in
            self.isHidden = true
        })
        self.onTapHiddenUpdate?(true)
    }

    func fadeIn() {
        self.isHidden = false
        UIView.animate(withDuration: 0.15, animations: { () -> () in
            self.alpha = 1
        })
        self.onTapHiddenUpdate?(false)
    }

    private func commonInit() {
//        UINib(nibNaÔme: "TGFeedDetailInteractiveView", bundle: nil).instantiate(withOwner: self, options: nil)
        loadNib()
        
        view.frame = self.bounds
        self.addSubview(view)
        
        setBottomToolView()
        
        addSubview(moreButton)
        moreButton.addAction {
            self.onMoreTouched?()
        }
        moreButton.snp.makeConstraints { make in
            make.centerY.equalTo(pageCounterLabel)
            make.right.equalTo(-15)
        }
        addSubview(aiFeedView)
        aiFeedView.addAction {
            self.onAITouched?()
        }
        aiFeedView.snp.makeConstraints { make in
            make.centerY.equalTo(moreButton)
            make.right.equalTo(moreButton.snp.left).offset(-10)
            make.width.equalTo(60)
            make.height.equalTo(28)
        }
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_rl_aifeed_full")
        
        aiFeedView.addSubview(imageView)
        imageView.bindToEdges()
        
        aiFeedView.makeHidden()
        
        separatorLine.backgroundColor = UIColor(red: 84, green: 84, blue: 84)
        followButton.addTap { [weak self] (v) in
            self?.onFollowTouched?()
        }
        
    
        let likeItem = toolbar.getItemAt(0)
        reactionHandler = TGReactionHandler(reactionView: likeItem, toAppearIn: self, currentReaction: reactionType, feedId: feedId, feedItem: feedItem, theme: .white, reactions: [.heart,.awesome,.wow,.cry,.angry], isInnerFeed: true)
        reactionHandler?.onError = { [weak self] (fallback, message) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.updateReactionButton(reactionType: fallback)

                UIViewController.showBottomFloatingToast(with: "error".localized, desc: message)
            }
        }

        reactionHandler?.onSelect = { [weak self] reaction in
            TGRootViewController.share.verifyGuestModeOrNoLogin(success: {
                guard let self = self else { return }
                self.updateReactionButton(reactionType: reaction)
            })
        }

        reactionHandler?.onSuccess = { [weak self] message in
            self?.reactionSuccess?()
            let feedId = self?.feedId ?? 0
            TGFeedNetworkManager.shared.fetchFeedDetailInfo(withFeedId: "\(feedId)") { feedInfo, error in
                guard let feedInfo = feedInfo else { return }
                DispatchQueue.main.async {
                    // 确保 self.toolbar 不为 nil
                    if let toolbar = self?.toolbar {
                        toolbar.setTitle(feedInfo.likeCount.abbreviated, At: 0)
                    }
                }
            }
        }

        likeItem.addGestureRecognizer(reactionHandler!.longPressGesture)

        reactionView.addTap { [weak self] v in
            guard let self = self else { return }
            self.onTapReactionList?(self.feedId)
        }
        
        
    }
  
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Get the hit view we would normally get with a standard UIView
        let hitView = super.hitTest(point, with: event)

        // If the hit view was ourself (meaning no subview was touched),
        // return nil instead. Otherwise, return hitView, which must be a subview.
        return hitView == view ? nil : hitView
    }
}

extension TGFeedDetailInteractiveView: TGToolbarViewDelegate {
    func toolbar(_ toolbar: TGToolbarView, DidSelectedItemAt index: Int) {
        switch index {
        case 0:
            self.reactionHandler?.onTapReactionView()
        case 1:
            self.onCommentTouched?()
        case 2:
            self.onForwardTouched?()
        default:
            break
        }
    }
}
