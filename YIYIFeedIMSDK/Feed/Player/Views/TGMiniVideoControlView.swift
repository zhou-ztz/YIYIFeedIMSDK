//
//  TGMiniVideoControlView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/23.
//

import UIKit
import Lottie

enum SocialButtonState {
    case followMutually, follow, unfollow, editProfile
}
protocol TGMiniVideoControlViewDelegate: AnyObject {
    func controlViewDidTapped(view: TGMiniVideoControlView)
    func commentDidTapped(view: TGMiniVideoControlView)
    func shareDidTapped(view: TGMiniVideoControlView)
    func rewardDidTapped(view: TGMiniVideoControlView)
    func followDidTapped(view: TGMiniVideoControlView)
    func profileDidTapped(view: TGMiniVideoControlView)
    func reactionsDidSelect(view: TGMiniVideoControlView)
    func reactionsListDidTap(view: TGMiniVideoControlView)
    func voucherDidTap(view: TGMiniVideoControlView)
    func sliderDidChanged(time: TimeInterval)
    
}


class TGMiniVideoControlView: UIView {

    weak var delegate: TGMiniVideoControlViewDelegate?
    var model: FeedListCellModel?
    private var originalTexts: String = ""
    private var translatedTexts: String = ""
    var videoDuration: TimeInterval = 0.0
    private var previousProgress: Float = 0.0
    private var currentPlayTime: TimeInterval = .zero {
        didSet {
            let playtime = currentPlayTime.isNaN ? "0:00" : currentPlayTime.toFormat().orEmpty
            let text = "\(playtime) / \(videoDuration.toFormat().orEmpty)"
            videoDurationLabel.attributedText = String.format(strings: [playtime], boldFont: UIFont.systemFont(ofSize: 20, weight: .semibold), boldColor: .white, inString: text, font: UIFont.systemFont(ofSize: 20, weight: .semibold), color: UIColor.lightGray)
        }
    }
    private var hideslider: DispatchWorkItem?
    
    var isDragging: Bool = false
    var translateHandler: ((Bool) -> Void)?
    var reactionSelected: ReactionTypes?
    var userIdList: [String] = []
    var htmlAttributedText: NSMutableAttributedString?
    
    private var translateButton: LoadableButton = LoadableButton(frame: .zero, icon: nil,
                                                                 text: "text_translate".localized, textColor: TGAppTheme.primaryBlueColor,
                                                                 font: UIFont.systemMediumFont(ofSize: 12), bgColor: .clear, cornerRadius: 0,
                                                                 withShadow: false).build { translateButton in
        translateButton.setTitle("button_original".localized, for: .selected)
        translateButton.setTitle("text_translate".localized, for: .normal)
    }
    
    var currentPrimaryButtonState: SocialButtonState = .follow
    
    init() {
        super.init(frame: .zero)
        
        setUI()
        
        setGestures()
        
 
        readMoreLabel.onHashTagTapped = { hashtag in
            RLSDKManager.shared.feedDelegate?.onSearchPageTapped(hashtag: hashtag.withHashtagPrefix())
        }
        
        readMoreLabel.onUsernameTapped = { name in
            HTMLManager.shared.handleMentionTap(name: name, attributedText: self.htmlAttributedText)
        }
        
        readMoreLabel.onHttpTagTapped = { url in
            RLSDKManager.shared.imDelegate?.didPressSocialPost(urlString: url)
        }
        
        readMoreLabel.onTextNumberOfLinesTapped = {[weak self] showLinesStyle in
            guard let self = self, let model = self.model, model.rewardsMerchantUsers.count > 0 else { return }
            self.feedShopView.isHidden = showLinesStyle == .TruncatableLabelShowLess
            self.expandCollapseButton.isHidden = showLinesStyle == .TruncatableLabelShowMore
            self.feedMerchantNamesView.isHidden = showLinesStyle == .TruncatableLabelShowMore
        }
        //        readMoreLabel.handleURLTap { url in
        //            TSDownloadNetworkNanger.share.getFinalUrl(for: url.absoluteString) { [weak self] (finalUrl) in
        //                guard let _url = URL(string: finalUrl) else { return }
        //                DispatchQueue.main.async {
        //                    self?.parentViewController?.navigation(navigateType: .pushURL(url: _url))
        //                }
        //            }
        //        }

        
        avatar.addTap { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.profileDidTapped(view: self)
        }
        nameLabel.addTap { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.profileDidTapped(view: self)
        }
        
        reactionList.addTap { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.reactionsListDidTap(view: self)
        }
        
        playBtn.addAction { [weak self] in
            guard let self = self else { return }
            self.delegate?.controlViewDidTapped(view: self)
        }
        
        voucherBottomView.voucherOnTapped = {
            self.delegate?.voucherDidTap(view: self)
        }
        
        
        videoSlider.addTarget(self, action: #selector(sliderDidChanged(_:event:)), for: .valueChanged)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(_:)))
        //将控制进度滑动手势给最底部的view,缩小操作范围
//        viewsAndTimeView.addGestureRecognizer(panGesture)
//        reactionList.addGestureRecognizer(panGesture)
        sliderTouchAreaView.addGestureRecognizer(panGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        hideslider?.cancel()
        hideslider = nil
        reactionHandler?.reset()
//        printIfDebug("deinit MiniVideoControlView")
    }
    
    func setFeed(_ feed: FeedListCellModel?, _ isTranslate: Bool, _ isExpand: Bool) {
        guard let feed = feed else { return }
        
        self.updateFeed(feed, isTranslate, isExpand)
        if let imageUrl = feed.pictures.first?.url, let url = URL(string: imageUrl) {
            // By Kit Foong (Update Image full screen by checking video height and width)
            var aspectRatio = feed.videoHeight / feed.videoWidth
            if aspectRatio >= 1.25 {
                coverImageView.contentMode = .scaleAspectFill
            } else {
                coverImageView.contentMode = .scaleAspectFit
            }
            coverImageView.sd_setImage(with: url, completed: nil)
        }
        setupReactions(feed)
        startLoading()
        
        playBtn.isHidden = true
    }
    
    
    func updateFeed(_ feed: FeedListCellModel?, _ isTranslate: Bool = false, _ isExpand: Bool = false) {
        guard let feed = feed else { return }
        
        self.model = feed
        
        readMoreLabel.numberOfLines = 2
        readMoreLabel.isExpand = isExpand
        if feed.content != originalTexts {
            translateButton.isSelected = false
            translatedTexts = ""
        }
        
        if translateButton.isSelected && translatedTexts.isEmpty == false {
            if let attributedText = htmlAttributedText {
                readMoreLabel.setAttributeText(attString: attributedText, allowTruncation: true)
            } else {
                readMoreLabel.setText(text: originalTexts, allowTruncation: true)
            }
        } else {
            HTMLManager.shared.removeHtmlTag(htmlString: feed.content, completion: { [weak self] (content, userIdList) in
                guard let self = self else { return }
                self.userIdList = userIdList
                self.originalTexts = content
                self.htmlAttributedText = content.attributonString()
                if let attributedText = self.htmlAttributedText {
                    self.htmlAttributedText = HTMLManager.shared.formAttributeText(attributedText, self.userIdList)
                }
                
                self.updateTranslateText(isTranslate)
            })
        }
        
        if let time = feed.time {
            dateLabel.text = TGDate().dateString(.normal, nDate: time, dateFormat: "MMMM dd")
        }
        
        if let userInfo = feed.userInfo {
            let avatarInfo = TGAvatarInfo(userModel: userInfo)
            avatarInfo.verifiedType = ""
            avatarInfo.verifiedIcon = ""
            avatar.avatarInfo = avatarInfo
            
            nameLabel.text = "@" + userInfo.displayName
        }
        
        let likeToolbaritem = bottomToolBarView.toolbar.getItemAt(0)
        let commentToolbaritem = bottomToolBarView.toolbar.getItemAt(1)
        let rewardToolbaritem = bottomToolBarView.toolbar.getItemAt(2)
        if let toolModel = feed.toolModel {
        
            viewCount.text = toolModel.viewCount.abbStartFrom5Digit.appending(" \("number_of_browsed".localized)")
            //添加转发数
            rewardToolbaritem.titleLabel.text = toolModel.forwardCount.stringValue
            //添加评论数
            commentToolbaritem.titleLabel.text = toolModel.commentCount.stringValue
            
            commentToolbaritem.isHidden = toolModel.isCommentDisabled
            //添加点赞数
            likeToolbaritem.titleLabel.text = toolModel.diggCount.stringValue
        }
        

        
        //        if feed.topics.count > 0 {
        //            topicView.setTopics(feed.topics)
        //            topicView.isHidden = false
        //        } else {
        //            topicView.isHidden = true
        //        }
        //Rewardslink hidden topic view
        topicView.isHidden = true
        
        if let feed = self.model, let count = feed.toolModel?.diggCount, count > 0 {
            reactionList.makeVisible()
            reactionList.setData(reactionIcon: feed.topReactionList, totalReactionCount: count, labelTextColor: UIColor.init(hex: 0x929292), isInnerFeed: true)
        } else {
            reactionList.makeHidden()
        }
        
        contentStackview.setNeedsLayout()
        contentStackview.layoutIfNeeded()
        
        // By Kit Foong (Added checking when no text or only emoji will hide translate button)
        translateButton.isHidden = self.originalTexts.isEmpty || self.originalTexts.containsOnlyEmoji
        translateDotView.isHidden = translateButton.isHidden
        
        translateButton.addTap { [weak self] (button) in
            guard let self = self, let button = button as? LoadableButton else { return }
            guard button.isSelected == false else {
                
                self.htmlAttributedText = self.originalTexts.attributonString().setTextFont(14).setlineSpacing(0)
                if let attributedText = self.htmlAttributedText {
                    self.htmlAttributedText = HTMLManager.shared.formAttributeText(attributedText, userIdList)
                    self.readMoreLabel.setAttributeText(attString: attributedText, allowTruncation: true)
                } else {
                    self.readMoreLabel.setText(text: self.originalTexts, allowTruncation: true)
                }
                
                button.isSelected = false
                self.translateHandler?(button.isSelected)
                return
            }
            
            button.showLoader(userInteraction: false)
            
            TGFeedNetworkManager.shared.translateFeed(feedId: self.model?.idindex ?? 0) { [weak self] (translates, msg, status) in
                guard let self = self else { return }
                defer { button.hideLoader() }
                if status == false {
                    UIViewController.showBottomFloatingToast(with: "", desc: msg ?? "")
                    return
                }
                self.translatedTexts = translates ?? ""
                self.readMoreLabel.setText(text: self.translatedTexts, allowTruncation: true)
                button.isSelected = true
                self.translateHandler?(button.isSelected)
            }
        }
        
        bottomToolBarView.onCommentAction = { [weak self] in
            guard let self = self else { return }
            //            TSKeyboardToolbar.share.keyboardBecomeFirstResponder()
            self.delegate?.commentDidTapped(view: self)
        }
        //设置商家信息相关内容
        updateLocationAndMerchantNameView(location: feed.location, rewardsMerchantUsers: feed.rewardsMerchantUsers)
        
        feedShopView.snp.makeConstraints { (m) in
            m.height.equalTo(feed.rewardsMerchantUsers.count > 1 ? 125 : 110)
        }
        
        //设置底部内容
        setBottomViewData()
        //设置关注按钮状态
        updatePrimaryButton()
        updateSponsorStatus(model?.isSponsored ?? false)
    }
    
    private func setBottomViewData() {
        guard let model = model else { return }
        
        bottomToolBarView.loadToolbar(model: model.toolModel, canAcceptReward: model.canAcceptReward == 1 ? true : false, reactionType: model.reactionType)

        let likeItem = bottomToolBarView.toolbar.getItemAt(0)
        reactionHandler = TGReactionHandler(reactionView: likeItem, toAppearIn: self.parentViewController?.view ?? UIView(), currentReaction: model.reactionType, feedId: model.idindex, feedItem: model, reactions: [.heart,.awesome,.wow,.cry,.angry], isInnerFeed: true)
        
        likeItem.addGestureRecognizer(reactionHandler!.longPressGesture)
        
        reactionHandler?.onSelect = { [weak self] reaction in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.updateReactionList(reaction: reaction)
                self.animate(for: reaction)
            }
        }
        
        reactionHandler?.onSuccess = { [weak self] message in
            guard let self = self else { return }
            let feedId = model.idindex
      
        }
        
        bottomToolBarView.onToolbarItemTapped = { [weak self] toolbarIndex in
            guard let self = self else {
                return
            }
//            if toolbarIndex != 3 && TSCurrentUserInfo.share.isLogin == false {
//                TSRootViewController.share.guestJoinLandingVC()
//                return
//            }
            
            switch toolbarIndex {
            case 0:
                self.reactionHandler?.onTapReactionView()
            case 1:
                self.delegate?.commentDidTapped(view: self)
            case 2:
                self.parentViewController?.navigationController?.presentPopVC(target: "", type: .share, delegate: self)
            default: break
            }
        }
        setVoucherBottomView(model)
    }
    
    private func setVoucherBottomView(_ model: FeedListCellModel) {
        if model.tagVoucher?.taggedVoucherId != nil && model.tagVoucher?.taggedVoucherId != 0 {
            voucherBottomView.voucherLabel.text  =  model.tagVoucher?.taggedVoucherTitle ?? ""
            voucherBottomView.isHidden = false
            voucherBottomView.snp.updateConstraints({ make in
                make.height.equalTo(44)
            })
        } else {
            voucherBottomView.isHidden = true
            voucherBottomView.snp.updateConstraints({ make in
                make.height.equalTo(1)
            })
        }
    }
    
    private func updateLocationAndMerchantNameView(location: TSPostLocationModel?, rewardsMerchantUsers: [TGRewardsLinkMerchantUserModel]) {
        
        let hasLocation = location != nil
        let hasMerchants = !rewardsMerchantUsers.isEmpty
        
        // 设置 feedMerchantNamesView 的数据
        feedMerchantNamesView.setData(merchantList: rewardsMerchantUsers)
        feedShopView.setData(merchantList: rewardsMerchantUsers)
        
        // 如果有商家，则显示 feedMerchantNamesView，否则隐藏
        feedMerchantNamesView.isHidden = !hasMerchants
        
        // 如果有 location 或者有商家，则显示 locationAndMerchantView，否则隐藏
        locationAndMerchantView.isHidden = !(hasLocation || hasMerchants)
       
        guard hasLocation || hasMerchants else { return }

        // 清空 locationAndMerchantView 中的子视图
        locationAndMerchantView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if let location = location {
            locationView.set(location)
            locationView.isHidden = false
            // By Kit Foong (Added action for location view)
            locationView.isUserInteractionEnabled = true
            
            locationView.addTap(action: { (_) in
                
                RLSDKManager.shared.feedDelegate?.onLocationViewTapped(locationID: location.locationID, locationName: location.locationName)
            })
            locationAndMerchantView.addArrangedSubview(locationView)
        }
        
         // 添加 feedMerchantNamesView 到 locationAndMerchantView
        locationAndMerchantView.addArrangedSubview(feedMerchantNamesView)
        
        feedMerchantNamesView.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
    }

    func updateTranslateText(_ isTranslate: Bool) {
        if isTranslate {
            TGFeedNetworkManager.shared.translateFeed(feedId: self.model?.idindex ?? 0) { [weak self] (translates, msg, status) in
                guard let self = self else { return }
                self.translatedTexts = translates ?? ""
                self.translateButton.isSelected = true
                self.readMoreLabel.setText(text: self.translatedTexts, allowTruncation: true)
            }
        } else {
            self.translateButton.isSelected = false
            if let attributedText = self.htmlAttributedText {
                readMoreLabel.setAttributeText(attString: attributedText, allowTruncation: true)
            } else {
                readMoreLabel.setText(text:  self.originalTexts, allowTruncation: true)
            }
            
        }
    }
    
    @objc func sliderDidChanged(_ slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .ended:
                self.videoDurationLabel.makeHidden()
                self.contentStackview.makeVisible()
                self.expandCollapseButton.makeVisible()
                self.currentPlayTime = TimeInterval(slider.value * Float(videoDuration))
                self.delegate?.sliderDidChanged(time: currentPlayTime)
            default:
                videoDurationLabel.makeVisible()
                contentStackview.makeHidden()
                expandCollapseButton.makeHidden()
                break
            }
        }
    }
    
    @objc func panGestureRecognizer(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            
            previousProgress = videoSlider.value
            isDragging = true
            DispatchQueue.main.async {
                self.videoDurationLabel.isHidden = false
                self.videoSlider.isHidden = false
                self.expandCollapseButton.isHidden = true
                self.contentStackview.isHidden = true
                self.progressView.isHidden = true
            }
            hideslider?.cancel()
            hideslider = nil
            
        case .ended:

            self.delegate?.sliderDidChanged(time: currentPlayTime)
            DispatchQueue.main.async {
                self.contentStackview.isHidden = false
                self.expandCollapseButton.isHidden = false
                self.videoDurationLabel.isHidden = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.isDragging = false
            }
            performHideSlider()
            
        case .changed:
            let translation = gesture.translation(in: self.contentStackview).x
            let d = translation / UIScreen.main.bounds.width
            let newProgress = min(max(previousProgress + Float(d), 0.0), 1)
            DispatchQueue.main.async {
                self.videoSlider.setValue(newProgress, animated: false)
            }
            self.currentPlayTime = TimeInterval(newProgress) * videoDuration
            
        default:
            break
        }
    }
    
    func startLoading() {
        loadingView.start()
        loadingView.isHidden = false
    }
    
    func stopLoading() {
        loadingView.stop()
        loadingView.isHidden = true
    }
    
    func showPlayBtn() {
        playBtn.isHidden = false
        playBtn.transform = CGAffineTransform(scaleX: 2, y: 2)
        UIView.animate(withDuration: 0.3/1.5) {
            self.playBtn.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.3/2) {
                self.playBtn.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            } completion: { _ in
                self.playBtn.transform = .identity
            }
        }
        videoSlider.isHidden = false
        progressView.isHidden = true
        hideslider?.cancel()
        hideslider = nil
    }
    
    func hidePlayBtn() {
        guard !playBtn.isHidden else {
            return
        }
        self.playBtn.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.3/1.5) {
            self.playBtn.transform = CGAffineTransform(scaleX: 2, y: 2)
        } completion: { _ in
            UIView.animate(withDuration: 0.3/2) {
                self.playBtn.transform = .identity
            } completion: { _ in
                self.playBtn.isHidden = true
                self.hideslider?.cancel()
                self.hideslider = nil
                self.performHideSlider()
            }
        }
    }
    
    func resetToDefault() {
        playBtn.isHidden = true
    }
    
    func updateCommentCount(_ count: Int) {
        model?.toolModel?.commentCount = count
        let commentToolbaritem = bottomToolBarView.toolbar.getItemAt(1)
        commentToolbaritem.titleLabel.text = count.stringValue
    }
    
    func updateFollowButton(_ status: FollowStatus) {
        self.updatePrimaryButton()
    }
    
    func onVideoStart() {
        stopLoading()
    }
    
    func setProgress(_ progress: Float) {
        if !isDragging {
            videoSlider.value = progress
            currentPlayTime = TimeInterval(progress * Float(videoDuration))
        }
        self.progressView.progress = progress
    }
    
    private func executeLike() {
        let likeAnimation = Animation.named("reaction-love")
        animateView.animation = likeAnimation
        
        animateView.isHidden = false
        animateView.play { finished in
            guard finished == true else { return }
            self.animateView.makeHidden()
        }
    }
    
    private func performHideSlider() {
        hideslider = DispatchWorkItem {
            guard self.hideslider?.isCancelled == false else {
                return
            }
            guard !self.isDragging && self.playBtn.isHidden else {
                return
            }
            self.videoSlider.isHidden = true
            self.progressView.isHidden = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: hideslider!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    // MARK: - lazy
    var previewView: UIView = UIView().configure {
        $0.backgroundColor = .clear
    }
    
    private lazy var loadingView: TSGradientView = {
        let view = TSGradientView(colors: [TGAppTheme.warmBlue, TGAppTheme.aquaBlue, TGAppTheme.aquaBlue.withAlphaComponent(0.2)], direction: .horizontal)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var gradientView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = self.bounds
        layer.colors = [UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
        layer.locations = [0, 0.2, 0.6, 1]
        return layer
    }()
    
    private lazy var progressView: UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = .gray
        progress.tintColor = .lightGray
        progress.transform = CGAffineTransform(scaleX: 1, y: 0.5)
        return progress
    }()
    
    private lazy var videoSlider: VideoSlider = {
        let slider = VideoSlider()
        slider.thumbTintColor = .white
        slider.tintColor = .white
        slider.isContinuous = true
        slider.isHidden = true
        slider.setThumbImage(UIImage(named: "ic_slider_dot"), for: .highlighted)
        slider.setThumbImage(UIImage(named: "ic_slider_dot"), for: .normal)
        return slider
    }()
    private lazy var sliderTouchAreaView: UIView = {
        let areaView = UIView()
        areaView.backgroundColor = .clear
        areaView.isUserInteractionEnabled = true
        return areaView
    }()
    public lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var avatar: TGAvatarView = {
        let imageView = TGAvatarView()
        return imageView
    }()
    
    private lazy var playBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "ic_play_video"), for: .normal)
        button.isHidden = true
        return button
    }()
    

    private lazy var readMoreLabel: TGTruncatableLabel = {
        return TGTruncatableLabel()
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.applyStyle(.semibold(size: 16, color: .white))
        return label
    }()
    
    private var sponsorLabel : UILabel = {
        let label = UILabel()
        label.applyStyle(.regular(size: 12.0, color: .white))
        label.text = "sponsored".localized
        return label
    }()
    
    private let primaryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("display_follow".localized, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = TGAppTheme.Font.regular(12)
        button.backgroundColor = TGAppTheme.primaryRedColor
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.roundCorner(10)
        return button
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.applyStyle(.regular(size: 12, color: UIColor.white.withAlphaComponent(4)))
        return label
    }()
    
    private lazy var viewCount: UILabel = {
        let label = UILabel()
        label.applyStyle(.regular(size: 12, color: .white))
        return label
    }()
    
    private lazy var videoDurationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.isHidden = true
        return label
    }()
    
    private lazy var nameAndFollowStackview: UIStackView = {
        let stackview = UIStackView()
        stackview.axis = .horizontal
        stackview.distribution = .fill
        stackview.alignment = .fill
        stackview.spacing = 10.0
        return stackview
    }()
    
    private let nameStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 0
        return stack
    }()
    
    private lazy var contentStackview: UIStackView = {
        let stackview = UIStackView()
        stackview.axis = .vertical
        stackview.distribution = .fill
        stackview.alignment = .fill
        stackview.spacing = 4.0
        return stackview
    }()
    
    private lazy var viewAndTimeContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.addSubview(viewsAndTimeView)
        viewsAndTimeView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
        return view
    }()
    
    private lazy var viewsAndTimeView: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [viewCount, dateDotView, dateLabel, translateDotView, translateButton])
        stackview.axis = .horizontal
        stackview.distribution = .fillProportionally
        stackview.alignment = .center
        stackview.spacing = 8.0
        return stackview
    }()
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
    
    private lazy var locationView: TGLocationView = {
        return TGLocationView()
    }()
    
    private lazy var topicView: TGTopicListView = {
        return TGTopicListView()
    }()
    
    private lazy var animateView = AnimationView()
    
    var onToolbarUpdated: onToolbarUpdate?
    private var reactionHandler: TGReactionHandler?
    
    private lazy var reactionList = TGUserReactionView()
    
    
    //底部操作框
    private var bottomToolBarView: TGFeedCommentDetailBottomView = TGFeedCommentDetailBottomView(frame: .zero, colorStyle: .dark)
    //商家类目
    private var feedShopView = TGFeedCommentDetailShopView(frame: .zero, shopSubViewType: .video, isDarkBackground: true)
    //商家名称类目
    private var feedMerchantNamesView = TGFeedDetailMerchantNamesView(frame: .zero)
    
    //展开/收起按钮
    private lazy var expandCollapseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "ic_rl_expand"), for: .normal)
        button.setBackgroundImage(UIImage(named: "ic_rl_collapse"), for: .selected)
        button.addTarget(self, action: #selector(expandCollapseButtonTapped(_:)), for: .touchUpInside)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 14
        button.backgroundColor = .lightGray.withAlphaComponent(0.4)
        return button
    }()
    
    var voucherBottomView: VoucherBottomView = VoucherBottomView()

}
// MARK: - Private

extension TGMiniVideoControlView {
    
    private func setUI() {
        
        self.backgroundColor = .black

        self.addSubViews([previewView, coverImageView, gradientView, bottomToolBarView, contentStackview, playBtn, videoDurationLabel, progressView, videoSlider, sliderTouchAreaView, voucherBottomView])
        
        nameAndFollowStackview.addArrangedSubview(avatar)
        contentStackview.addArrangedSubview(nameAndFollowStackview)
        
        nameStackView.addArrangedSubview(nameLabel)
        sponsorLabel.isHidden = true
        nameStackView.addArrangedSubview(sponsorLabel)
        
        nameAndFollowStackview.addArrangedSubview(nameStackView)
        
        locationAndMerchantView.addArrangedSubview(locationView)
        locationAndMerchantView.addArrangedSubview(feedMerchantNamesView)
        
        contentStackview.addArrangedSubview(readMoreLabel)
        contentStackview.addArrangedSubview(locationAndMerchantScrollView)
        contentStackview.addArrangedSubview(feedShopView)
        feedShopView.isHidden = true
        contentStackview.addArrangedSubview(topicView)
        contentStackview.addArrangedSubview(viewAndTimeContainer)
        contentStackview.addArrangedSubview(reactionList)
        
        locationAndMerchantScrollView.addSubview(locationAndMerchantView)
        
        coverImageView.bindToEdges()
        
        previewView.bindToEdges()
        
        gradientView.bindToEdges()
        
        gradientView.layer.addSublayer(gradientLayer)
        avatar.snp.makeConstraints {
            $0.width.height.equalTo(33)
        }
        contentStackview.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.bottom.equalTo(progressView.snp.top).offset(-16)
            $0.trailing.equalToSuperview().offset(-10)
        }
        locationAndMerchantScrollView.snp.makeConstraints {  (m) in
            m.height.equalTo(20)
        }
        
        locationAndMerchantView.bindToEdges()
        
        feedMerchantNamesView.momentMerchantDidClick = { merchantData in
//            NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": merchantData.merchantId.stringValue])
            RLSDKManager.shared.imDelegate?.didPressUerProfile(uid: merchantData.merchantId)
        }
        
        feedShopView.momentMerchantDidClick = { [weak self] merchantData in
            guard let self = self, let parentViewController = self.parentViewController else { return }
            
            let appId = merchantData.wantedMid
            var path = merchantData.wantedPath
            path = path + "?id=\(appId)"
            print("=path = \(path)")
            RLSDKManager.shared.imDelegate?.didPressMiniProgrom(appId: "localInfo.mpExtras", path: path)
        }

        readMoreLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
        }
        
        dateDotView.snp.makeConstraints {
            $0.width.height.equalTo(2)
        }
        
        translateDotView.snp.makeConstraints {
            $0.width.height.equalTo(2)
        }
        
        playBtn.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        bottomToolBarView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(TSBottomSafeAreaHeight + 60)
        }
        
        voucherBottomView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(bottomToolBarView.snp.top)
            $0.height.equalTo(44)
        }
        
        progressView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(12)
            $0.bottom.equalTo(voucherBottomView.snp.top)
        }
        videoSlider.snp.makeConstraints {
            $0.left.right.bottom.equalTo(progressView)
        }
        sliderTouchAreaView.snp.makeConstraints {
             $0.center.equalTo(videoSlider)
             $0.width.equalTo(videoSlider).offset(25)
             $0.height.equalTo(videoSlider).offset(25)
        }
        videoDurationLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(videoSlider.snp.top).offset(-75)
        }
        
        self.addSubview(animateView)
        animateView.snp.makeConstraints { v in
            v.width.height.equalTo(100)
            v.center.equalToSuperview()
        }
        animateView.isHidden = true
        
        //设置关注按钮
        self.prepareFollowButton()
        
        self.addSubview(expandCollapseButton)
        expandCollapseButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(15)
            $0.bottom.equalTo(progressView.snp.top).offset(-10)
            $0.size.equalTo(CGSizeMake(28, 28))
        }
    }
    // 按钮点击事件处理
    @objc func expandCollapseButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        // 添加按钮变大再变回原来大小的动画
        let originalSize = sender.bounds.size
        let newSize = CGSize(width: originalSize.width * 1.2, height: originalSize.height * 1.2)
        
        UIView.animate(withDuration: 0.1, animations: {
            sender.bounds.size = newSize
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.bounds.size = originalSize
            }
        }
        UIView.animate(withDuration: 0.15, animations: { () -> () in
            self.alpha = 1
            self.contentStackview.alpha = sender.isSelected ? 0 : 1
        })
    }

    // MARK: - 设置关注按钮
    private func prepareFollowButton() {
        
        primaryButton.addTap { [weak self] (_) in
            guard let self = self else { return }
//            guard TSCurrentUserInfo.share.isLogin == true else {
//                TSRootViewController.share.guestJoinLandingVC()
//                return
//            }
            primaryButton.setTitle("Loading...".localized, for: .normal)
            self.model?.userInfo?.updateFollow { [weak self] (success) in
                DispatchQueue.main.async {
                    if success {
                        guard let self = self  else { return }
                        
                        // By Kit Foong (Trigger observer to update follow status)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil, userInfo: ["follow": self.model?.userInfo?.follower, "userid": "\(self.model?.userInfo?.userIdentity)"])
                        self.updatePrimaryButton()
                    } else {
                        self?.updatePrimaryButton()
                    }
                }
            }
        }
        let followView = UIView()
        followView.addSubview(primaryButton)
        
        nameAndFollowStackview.addArrangedSubview(followView)
        let rightPaddingView = UIView()
        nameAndFollowStackview.addArrangedSubview(rightPaddingView)
        
        followView.snp.makeConstraints {
            $0.width.equalTo(75)
            $0.height.equalTo(33)
        }
        primaryButton.snp.makeConstraints {
            $0.width.equalTo(75)
            $0.height.equalTo(25)
            $0.center.equalToSuperview()
        }
        
    }
    private func setGestures() {
    
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapGestureRecogniser(_:)))
    
        doubleTap.numberOfTapsRequired = 2
        self.gradientView.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapGestureRecogniser(_:)))
    
        singleTap.numberOfTapsRequired = 1
        self.gradientView.addGestureRecognizer(singleTap)
        
//        let singleTap = UITapGestureRecognizer { [weak self] in
//            guard let self = self else { return }
//            self.delegate?.controlViewDidTapped(view: self)
//        }
//        singleTap.numberOfTapsRequired = 1
//        singleTap.require(toFail: doubleTap)
//        self.gradientView.addGestureRecognizer(singleTap)
        
    }
    @objc private func doubleTapGestureRecogniser(_ recognizer: UITapGestureRecognizer) {
        //            guard TSCurrentUserInfo.share.isLogin else {
        //                TSRootViewController.share.guestJoinLandingVC()
        //                return
        //            }
        self.executeLike()
        if self.model?.reactionType != nil {
            return
        }
        self.reactionHandler?.onSelect(reaction: .heart)
    }
    
    @objc private func singleTapGestureRecogniser(_ recognizer: UITapGestureRecognizer) {
        self.delegate?.controlViewDidTapped(view: self)
    }
    private func followUserClicked() {
        // 1.判断是否为游客模式
//        if !TSCurrentUserInfo.share.isLogin {
//            // 如果是游客模式，拦截操作显示登录界面
//            TSRootViewController.share.guestJoinLandingVC()
//            return
//        }
        
        guard var object = model?.userInfo else { return }
        
        guard let relationship = object.relationshipWithCurrentUser else {
//            TSRootViewController.share.guestJoinLandingVC()
            return
        }
        if relationship.status == .eachOther {
//            let session = NIMSession(object.username, type: .P2P)
//            let vc = IMChatViewController(session: session, unread: 0)
//            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        } else {
            object.updateFollow { (success) in
                DispatchQueue.main.async {
                    if success {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil, userInfo: ["follow": object.follower, "userid": "\(object.userIdentity)"])
                        self.updatePrimaryButton()
                    }
                }
            }
        }
    }
    
    func updateSponsorStatus(_ isShow: Bool) {
        if UserDefaults.sponsoredEnabled {
            sponsorLabel.isHidden = !isShow
        } else {
            sponsorLabel.isHidden = true
        }
    }
    
    private func updatePrimaryButton() {
        guard let relationship = self.model?.userInfo?.relationshipWithCurrentUser else { return }
        primaryButton.isHidden = false
        
        guard let followStatus = self.model?.userInfo?.followStatus else { return }
        
        var followStatusDidChanged:Bool = false
        var actionTitle: String = "profile_follow".localized
        switch followStatus {
        case .eachOther:
            actionTitle = "profile_home_follow_mutual".localized
            currentPrimaryButtonState = .followMutually
            primaryButton.backgroundColor = UIColor(hex: 0xB4B4B4)
            primaryButton.isHidden = true
            
        case .follow:
            if currentPrimaryButtonState != .follow {
                followStatusDidChanged = true
            }
            actionTitle = "profile_home_follow".localized
            primaryButton.backgroundColor = UIColor(hex: 0xB4B4B4)
            currentPrimaryButtonState = .follow
            primaryButton.isHidden = true
            
        case .unfollow:
            if currentPrimaryButtonState != .unfollow {
                followStatusDidChanged = true
            }
            actionTitle = "display_follow".localized
            primaryButton.backgroundColor = TGAppTheme.primaryRedColor
            currentPrimaryButtonState = .unfollow
            
            
        case .oneself:
            actionTitle = "display_follow".localized
            primaryButton.backgroundColor = UIColor(hex: 0xB4B4B4)
            currentPrimaryButtonState = .follow
            primaryButton.isHidden = true
            
        }
        
        if followStatusDidChanged {
            UIView.transition(with: self.primaryButton, duration: 0.2, options: .transitionCrossDissolve, animations: { [weak self] in
                guard let self = self else { return }
                self.primaryButton.setTitle(actionTitle)
            }, completion: nil)
        } else {
            primaryButton.setTitle(actionTitle)
            
        }
    }
    
    private func setupReactions(_ model: FeedListCellModel) {
        
        let toolbaritem = bottomToolBarView.toolbar.getItemAt(0)
        self.reactionHandler = TGReactionHandler(reactionView: toolbaritem, toAppearIn: self, currentReaction: model.reactionType, feedId: model.idindex, feedItem: model, reactions: [.heart,.awesome,.wow,.cry,.angry], isInnerFeed: true)

        toolbaritem.addGestureRecognizer(reactionHandler!.longPressGesture)
        
        reactionHandler?.onSelect = { [weak self] reaction in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.updateReactionList(reaction: reaction)
                self.animate(for: reaction)
            }
        }
        
        reactionHandler?.onSuccess = { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.reactionsDidSelect(view: self)
        }
    }
    
    private func animate(for reaction: ReactionTypes?) {
        let toolbaritem = bottomToolBarView.toolbar.getItemAt(0)
        //设置点赞状态
        if let reaction = reaction {
            toolbaritem.imageView.image = reaction.image
        } else {
            toolbaritem.imageView.image = UIImage(named: "IMG_home_ico_love_white_filled")
        }
    }
    
    private func updateReactionList(reaction: ReactionTypes?) {
        let toolbaritem = bottomToolBarView.toolbar.getItemAt(0)
        if let reaction = reaction {
            if self.model?.topReactionList.contains(reaction) == false {
                self.model?.topReactionList.append(reaction)
            }
            
            if self.model?.reactionType == nil {
                self.model?.toolModel?.diggCount += 1
            }
            
        } else {
            self.model?.toolModel?.diggCount -= 1
        }
        
        if let feed = self.model, let count = feed.toolModel?.diggCount, count > 0 {
            reactionList.makeVisible()
            reactionList.setData(reactionIcon: feed.topReactionList, totalReactionCount: count, labelTextColor: UIColor.init(hex: 0x929292), isInnerFeed: true)
            toolbaritem.titleLabel.text = count.stringValue
        } else {
            reactionList.makeHidden()
            let toolbaritem = bottomToolBarView.toolbar.getItemAt(0)
            toolbaritem.titleLabel.text = "0"
        }
        
        self.model?.reactionType = reaction
    }
    
    func updateReactionList(_ feed: FeedListCellModel) {
        self.model = feed
        if let feed = self.model, let count = feed.toolModel?.diggCount, count > 0 {
            reactionList.makeVisible()
            reactionList.setData(reactionIcon: feed.topReactionList, totalReactionCount: count, labelTextColor: UIColor.init(hex: 0x929292), isInnerFeed: true)
        } else {
            reactionList.makeHidden()
            let toolbaritem = bottomToolBarView.toolbar.getItemAt(0)
            toolbaritem.titleLabel.text = "0"
        }
    }
    // MARK: - 转发后获取最新转发数
    private func updateForwardCount(_ dontTriggerObservers: Bool = false) {
        guard let feedId = model?.idindex else { return }
        TGFeedNetworkManager.shared.fetchFeedDetailInfo(withFeedId: "\(feedId)") { [weak self] (feedInfo, error) in
        
            guard let feedInfo = feedInfo, let self = self else {
                return
            }
            self.model = FeedListCellModel(feedListModel: feedInfo)
            self.setBottomViewData()
        }
    }
    // MARK: - 记录转发
    private func forwardFeed() {
        guard let feedId = model?.idindex else { return }
//        self.parentViewController?.showLoading()
        TGFeedNetworkManager.shared.fetchFeedDetailInfo(withFeedId: "\(feedId)") { (feedInfo, error) in
            guard let listModel = feedInfo else {
                return
            }
            defer {
                DispatchQueue.main.async {
//                    self.parentViewController?.dismissLoading()
                    //调用查询动态详情方法
                    self.updateForwardCount()
                }
                //上报动态转发事件
                RLSDKManager.shared.feedDelegate?.onTrackEvent(itemId: feedId.stringValue, itemType: self.model?.feedType == .miniVideo ? TGItemType.shortvideo.rawValue : TGItemType.image.rawValue, behaviorType: TGBehaviorType.forward.rawValue, moduleId: TGModuleId.feed.rawValue, pageId: TGPageId.feed.rawValue, behaviorValue: nil, traceInfo: nil)
                
            }
//            guard status == true else {
//                if statusCode == 241 {
//                    self.parentViewController?.showDialog(image: nil, title: "fail_to_pin_title".localized, message: "fail_to_pin_desc".localized, dismissedButtonTitle: "ok".localized, onDismissed: nil, onCancelled: nil)
//                } else {
//                    self.parentViewController?.showError(message: errMessage)
//                }
//                return
//            }
        }
    }
}
extension TGMiniVideoControlView: CustomPopListProtocol{
    func customPopList(itemType: TGPopUpItem) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.handlePopUpItemAction(itemType: itemType)
        }
    }
    
    func handlePopUpItemAction(itemType: TGPopUpItem) {
        
        switch itemType {
        case .message:
            //记录转发数
            self.forwardFeed()
            if let model = self.model {
                let messageModel = TGmessagePopModel(momentModel: model)
                let vc = TGContactsPickerViewController(model: messageModel, configuration: TGContactsPickerConfig.shareToChatConfig(), finishClosure: nil)
                let navigation = TGNavigationController(rootViewController: vc).fullScreenRepresentation
                self.parentViewController?.navigationController?.present(navigation, animated: true, completion: nil)
                
            }
        case .shareExternal:
            //记录转发数
            self.forwardFeed()
            if let model = self.model, let webServerAddress = RLSDKManager.shared.loginParma?.webServerAddress {
                let messagePopModel = TGmessagePopModel(momentModel: model)
                let fullUrlString = "\(webServerAddress)feeds/\(String(messagePopModel.feedId))"
             
                // By Kit Foong (Hide Yippi App from share)
                guard let url = URL(string: fullUrlString) else { return }
                let items: [Any] = [url, messagePopModel.titleSecond, ShareExtensionBlockerItem()]
                let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.parentViewController?.view
                self.parentViewController?.present(activityVC, animated: true, completion: nil)
            }
        case .save(isSaved: _):
            if let data = self.model {
                let isCollect = (data.toolModel?.isCollect).orFalse ? false : true
                
                TGFeedNetworkManager.shared.colloction(isCollect ? 1 : 0, feedIdentity: data.idindex, feedItem: data) { [weak self] (result) in
                    if result == true {
                        self?.model?.toolModel?.isCollect = isCollect
                        DispatchQueue.main.async {
                            if isCollect {
                                self?.parentViewController?.showTopFloatingToast(with: "success_save".localized, desc: "")
                                
                            }
                        }
                    }
                }
            }
        case .reportPost:
            if let model = self.model {
                guard let reportTarget: ReportTargetModel = ReportTargetModel(feedModel: model) else { return }
                let reportVC: TGReportViewController = TGReportViewController(reportTarget: reportTarget)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.parentViewController?.present(TGNavigationController(rootViewController: reportVC).fullScreenRepresentation,
                                 animated: true,
                                 completion: nil)
                }
            }
        default:
            break
        }
    }
}
extension TGMiniVideoControlView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}


class MiniVideoButton: UIView {
    
    let imageView: UIImageView = UIImageView(frame: .zero).configure {
        $0.contentMode = .scaleAspectFit
    }
    let titleLabel: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 12, color: .white))
    }
    private let stackview = UIStackView().configure {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 3
    }
    
    init() {
        super.init(frame: .zero)
        addSubview(stackview)
        stackview.bindToEdges()
        
        stackview.addArrangedSubview(imageView)
        stackview.addArrangedSubview(titleLabel)
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(32)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class VideoSlider: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let point = CGPoint(x: bounds.minX, y: bounds.midY)
        return CGRect(origin: point, size: CGSize(width: bounds.width, height: 2))
    }
}


