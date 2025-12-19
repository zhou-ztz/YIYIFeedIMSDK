//
//  TGReleasePulseViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/3.
//

import UIKit
import KMPlaceholderTextView
import Photos
import CoreLocation
import SDWebImage
import MobileCoreServices
import SwiftLinkPreview
import ObjectBox

typealias FoursquareLocation = TGLocationModel

public class TGReleasePulseViewController: UIViewController, UITextViewDelegate, didselectCellDelegate, TGCustomAcionSheetDelegate, UIGestureRecognizerDelegate {
    /// 主承载视图
    @IBOutlet weak var mainView: UIView!
    // 滚动视图高度
    @IBOutlet weak var scrollContentSizeHeight: NSLayoutConstraint!
    
    // 图片查看器的高度
    @IBOutlet weak var releaseDynamicCollectionViewHeight: NSLayoutConstraint!
    // 发布内容
    @IBOutlet weak var contentTextView: KMPlaceholderTextView!
    @IBOutlet weak var atView: UIView!
    @IBOutlet weak var atArrowImgView: UIImageView!
    /// 修饰后的发布内容
    var releasePulseContent: String {
        return contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var apiPulseContent: String = ""
    // 展示图片CollectionView
    @IBOutlet weak var showImageCollectionView: TGReleasePulseCollectionView!
    @IBOutlet weak var showVideoView: UIView!
    @IBOutlet weak var previewVideoIconImageView: UIImageView!
    @IBOutlet weak var videoPreviewView: UIView!
    @IBOutlet weak var selectCoverBtn: UIButton!
    @IBOutlet weak var previewImageLoadingOverlay: UILabel!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var previewBtn: UIButton!
    @IBOutlet weak var recordIconImageView: UIImageView!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var recordBtnView: UIView!
    @IBOutlet weak var rerecordLabel: UILabel!
    // 滚动视图
    @IBOutlet weak var mainScrollView: UIScrollView!
    // 展示文本字数
    @IBOutlet weak var showWordsCountLabel: UILabel!
    @IBOutlet weak var topicView: UIView!
    @IBOutlet weak var topicViewHeight: NSLayoutConstraint!
    @IBOutlet weak var repostBgView: UIView!
    @IBOutlet weak var repostBgViewHeight: NSLayoutConstraint!
    /// Permission
    @IBOutlet weak var privacyView: UIView!
    @IBOutlet weak var privacyValueLabel: UILabel!
    @IBOutlet weak var privacyTitleLabel: UILabel!
    @IBOutlet weak var privacyArrowImgView: UIImageView!
    
    @IBOutlet weak var tagTitleLabel: UILabel!
    
    @IBOutlet weak var checkInView: UIView!
    @IBOutlet weak var checkInArrowImgView: UIImageView!
    @IBOutlet weak var checkInLabel: UILabel!
    @IBOutlet weak var checkInLocationLabel: UILabel!
    @IBOutlet weak var contentStackView: UIStackView!
    //文本内容展开/收起 按钮
    @IBOutlet weak var expandCollapseButton: UIButton!
    @IBOutlet weak var voucherView: UIView!
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var voucherLabel: UILabel!
    @IBOutlet weak var addVoucher: UILabel!
    @IBOutlet weak var contentTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var voucherConstantH: NSLayoutConstraint!
    @IBOutlet weak var voucherInfoView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!
    private var isVideoDataChanged = false
    var privacyType: PrivacyType = .everyone {
        didSet {
            self.privacyValueLabel.text = privacyType.localizedString
        }
    }
    // cell个数
    let cellCount: CGFloat = 4.0
    // cell行间距
    let spacing: CGFloat = 5.0
    // 最大标题字数
    let maxtitleCount: Int = 30
    // 最大内容字数
    let maxContentCount: Int = 255
    // 显示字数时机
    let showWordsCount: Int = 200
    // contentTextView是否滚动的行数
    let contentTextViewScrollNumberLine = 7
    // 发布按钮（还没判断有无图片时的点击逻辑）
    // 最大图片张数
    let maxPhotoCount: Int = 9
    private let slp = SwiftLinkPreview()
    
    var releaseButton = TGTextButton.initWith(putAreaType: .top)
    // 记录collection高度
    var releaseDynamicCollectionViewSourceHeight: CGFloat = 0.0
    /// 选择图片数据对应数据
    public var selectedPHAssets: [PHAsset] = []
    /// 选择图片数据对应数据
    public var selectedModelImages: [Any] = []
    
    public var shortVideoAsset: TGShortVideoAsset? {
        didSet {
            reloadShortVideoAsset()
        }
    }
    
    public var selectedText: String = ""
    
    // 是否隐藏CollectionView
    var type:  TGToolType = .photo
    // 键盘高度
    var currentKbH: CGFloat = 0
    
    ///从话题进入的发布页面自带一个不能删除的话题
    var chooseModel: TGTopicCommonModel?
    
    /// 话题信息
    var topics: [TGTopicCommonModel] = []
    /// 转发信息
    public var repostModel: TGRepostModel?
    
    var sharedModel: SharedViewModel?
    
    /// 从被拒绝动态传来的位置对象
    var rejectLocation: FoursquareLocation?
    /// 从被拒绝动态传来的隐私类型对象
    var rejectPrivacyType: PrivacyType?
    
    /// 选中的动态关联用户
    var selectedUsers: [TGUserInfoModel] = []
    /// 选中的动态关联商家
    var selectedMerchants: [TGTaggedBranchData] = []
    /// 输入框顶部工具栏
    // 整个容器
    var toolView = UIView()
    // 下分割线
    var bottomLine = UIView()
    // 上分割线
    var topLine = UIView()
    /// 表情按钮
    var smileButton = UIButton(type: .custom)
    /// 收起按钮
    var packUpButton = UIButton(type: .custom)
    /// 选择Emoji的视图
    var emojiView: TSSystemEmojiSelectorView!
    var toolHeight: CGFloat = 145 + TSBottomSafeAreaHeight + 41
    
    // By Kit Foong (Check is it mini program)
    public var isMiniProgram: Bool = false
    public var isFromShareExtension: Bool = false
    public var postPhotoExtension =  [TGPostPhotoExtension]()
    //动态ID
    public var feedId: String?
    //是否从(驳回动态/编辑)页面来
    public var isFromEditFeed: Bool = false
    
    public var isPost: Bool = false
    
    
    var rewardsMerchantUsers: [TGRewardsLinkMerchantUserModel] = []
    
    private let beanErrorLabel: UILabel = {
        let label = UILabel()
        label.applyStyle(.regular(size: 12, color: UIColor(red: 209, green: 77, blue: 77)))
        label.text = "socialtoken_post_hot_feed_alert".localized
        label.textAlignment = .right
        
        return label
    }()
    var isTapOtherView = false
    var isPriceTextFiledTap = false
    var isReposting = false
    public var isText = false
    var currentIndex = 0
    private var taggedLocation: FoursquareLocation? {
        willSet  {
            guard let checkedIn = newValue else {
                checkInLocationLabel.text = ""
                return
            }
            checkInLocationLabel.text = checkedIn.locationName
        }
    }
    public var preText: String? = nil
    
    //封面ID
    public var coverId: Int?
    //视频ID
    public var videoId: Int?
    
    public var campaignDict: [String: Any]?

    public var voucherId: Int?
    public var voucherName: String?
    public var tagVoucher: TagVoucherModel?
    public var isVoucherRemoved: Bool = false
    var isMiniVideo: Bool = false
    public var aiFeedParams: [String: Any] = [:]
    let loadingView = TGLoadingView()
    var aiStatusMessage : [String] = []
    
    private var videoType: TGVideoType {
        return isMiniVideo ? .miniVideo : .normalVideo
    }
//    var type:  TGToolType
   public init(type: TGToolType, isText: Bool = false, isReposting: Bool = false) {
           let frameworkBundle = Bundle(identifier: "com.yiyi.feedimsdk") ?? Bundle.main
           var resourceBundle: Bundle?

           if let resourceBundleURL = frameworkBundle.url(forResource: "SDKResource", withExtension: "bundle"),
              let bundle = Bundle(url: resourceBundleURL) {
               resourceBundle = bundle
           }
           let nibName = "TGReleasePulseViewController"

           // 检查是否存在 .nib 文件
          if (resourceBundle?.path(forResource: nibName, ofType: "nib")) != nil {
               super.init(nibName: nibName, bundle: resourceBundle)
           } else {
               super.init(nibName: nibName, bundle: frameworkBundle)
           }
        
           self.isText = isText
           self.isReposting = isReposting
           self.type = type
           self.isMiniVideo = type == .miniVideo
       }
    func reloadShortVideoAsset() {
        guard let previewImageView = self.previewImageView else {
            return
        }
        guard let shortVideoAsset = shortVideoAsset else {
            videoPreviewView.makeHidden()
            self.releaseButton.isEnabled = false
            if isFromEditFeed {
                recordBtnView.makeVisible()
            }
            return
        }
        
        videoPreviewView.makeVisible()
        self.releaseButton.isEnabled = true
        if let coverImage = shortVideoAsset.coverImage {
            previewImageView.image = coverImage
        }
    }
    
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShowNotificationProcess(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHideNotificationProcess(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fieldBeginEditingNotificationProcess(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fieldEndEditingNotificationProcess(_:)), name: UITextField.textDidEndEditingNotification, object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(topicChooseNotice(notice:)), name: NSNotification.Name(rawValue: "passPublishTopicData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateContentTextViewTag(_:)), name: NSNotification.Name(rawValue: "isTaggingPost"), object: nil)
        self.navigationController?.isNavigationBarHidden = false
        if selectedText != "" {
            self.contentTextView.insertText(selectedText)
            contentTextView.delegate?.textViewDidChange!(contentTextView)
        }
        reloadShortVideoAsset()
        if isFromEditFeed == false {
            isVideoDataChanged = true
        }
    }
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        //        NotificationCenter.default.addObserver(self, selector: #selector(topicChooseNotice(notice:)), name: NSNotification.Name(rawValue: "passPublishTopicData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateContentTextViewTag(_:)), name: NSNotification.Name(rawValue: "isTaggingPost"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - setUI
    fileprivate func setUI() {
        
        previewVideoIconImageView.image = UIImage(named: "ico_video_recordings_white")
        recordIconImageView.image = UIImage(named: "ico_video_recordings")
        selectCoverBtn.setTitle("mv_posting_select_cover".localized, for: .normal)
        if !isFromEditFeed {
            recordBtnView.isHidden = true
        }
        previewImageLoadingOverlay.isHidden = true
        previewImageLoadingOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        previewImageLoadingOverlay.numberOfLines = 2
        previewImageLoadingOverlay.applyStyle(.regular(size: 10, color: .white))
        rerecordLabel.text = "video_remake".localized
        
        previewImageView.contentScaleFactor = UIScreen.main.scale
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        previewImageView.clipsToBounds = true
        
        /// 初始化键盘顶部工具视图
        toolView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: toolHeight)
        toolView.backgroundColor = UIColor.white
        self.view.addSubview(toolView)
        toolView.isHidden = true
        
        topLine.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 0.5)
        topLine.backgroundColor = RLColor.normal.keyboardTopCutLine
        toolView.addSubview(topLine)
        
        packUpButton.frame = CGRect(x: 25, y: 0, width: 22, height: 22)
        packUpButton.setImage(UIImage(named: "ic_black_arrow_down"), for: .normal)
        packUpButton.centerY = 41 / 2.0
        toolView.addSubview(packUpButton)
        packUpButton.addTarget(self, action: #selector(packUpKey), for: UIControl.Event.touchUpInside)
        
        smileButton.frame = CGRect(x: ScreenWidth - 50, y: 0, width: 25, height: 25)
        smileButton.setImage(UIImage(named: "ico_chat_keyboard_expression"), for: .normal)
        smileButton.setImage(UIImage(named: "ico_chat_keyboard"), for: .selected)
        smileButton.centerY = packUpButton.centerY
        toolView.addSubview(smileButton)
        smileButton.addTarget(self, action: #selector(emojiBtnClick), for: UIControl.Event.touchUpInside)
        
        emojiView = TSSystemEmojiSelectorView(frame: CGRect(x: 0, y: 41, width: ScreenWidth, height: 0))
        emojiView.delegate = self
        toolView.addSubview(emojiView)
        emojiView.frame = CGRect(x: 0, y: 41, width: ScreenWidth, height: toolHeight - 41)
        
        bottomLine.frame = CGRect(x: 0, y: 40, width: ScreenWidth, height: 1)
        bottomLine.backgroundColor = UIColor(hex: 0x667487)
        toolView.addSubview(bottomLine)
        
        /// 限制输入文本框字数
        contentTextView.placeholder = "placeholder_post_status".localized
        contentTextView.returnKeyType = .default    // 键盘的return键为换行样式
        contentTextView.font = UIFont.systemFont(ofSize: RLFont.ContentText.text.rawValue)
        //允许非焦点状态下仍然可以滚动
        contentTextView.isScrollEnabled = true
        //显示垂直滚动条
        contentTextView.showsVerticalScrollIndicator = true
        contentTextView.placeholderColor = RLColor.normal.disabled
        contentTextView.placeholderFont = UIFont.systemFont(ofSize: RLFont.ContentText.text.rawValue)
        contentTextView.delegate = self
        contentTextView.textAlignment = .left
        showImageCollectionView.didselectCellDelegate = self
        releaseDynamicCollectionViewSourceHeight = (UIScreen.main.bounds.size.width - 40 - spacing * 3) / cellCount + 1
        releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight
        
        showImageCollectionView.isHidden = (self.type != .photo)
        showVideoView.isHidden = (self.type != .miniVideo)
        expandCollapseButton.setBackgroundImage(UIImage(named: "ic_rl_expand"), for: .normal)
        expandCollapseButton.setBackgroundImage(UIImage(named: "ic_rl_collapse"), for: .selected)
        expandCollapseButton.roundCorner(14)
        expandCollapseButton.backgroundColor = .lightGray.withAlphaComponent(0.4)
        expandCollapseButton.addTarget(self, action: #selector(expandCollapseButtonTapped(_:)), for: .touchUpInside)
        
        // set btns
        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("cancel".localized, for: .normal)
        cancelButton.setTitleColor(RLColor.share.black, for: .normal)
        cancelButton.contentHorizontalAlignment = .left
        cancelButton.addTarget(self, action: #selector(tapCancelButton), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        releaseButton.setTitle("publish".localized, for: .normal)
        releaseButton.addTarget(self, action: #selector(releasePulse), for: .touchUpInside)
        releaseButton.contentHorizontalAlignment = .right
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: releaseButton)
        releaseButton.isEnabled = false
        showImageCollectionView.maxImageCount = (maxPhotoCount - selectedModelImages.count)
        self.topicView.isHidden = true
        setTopicViewUI(showTopic: true, topicData: topics)
        let atViewTap = UITapGestureRecognizer(target: self, action: #selector(didTapAtView))
        atView.addGestureRecognizer(atViewTap)
        
        tagTitleLabel.text = "tag_title_ppl_merchant".localized
        
        self.privacyArrowImgView.image = UIImage(named: "IMG_ic_arrow_smallgrey.png")
        self.atArrowImgView.image = UIImage(named: "IMG_ic_arrow_smallgrey.png")
        self.arrowImageView.image = UIImage(named: "IMG_ic_arrow_smallgrey.png")
        self.checkInArrowImgView.image = UIImage(named: "IMG_ic_arrow_smallgrey.png")
        
        self.navigationController?.navigationBar.isHidden = false
        
        /// Privacy view setup
        setPrivacyView()
        
        setCheckInView()
        
        setVoucherView()
        
        // 有转发内容
//        if let model = self.repostModel {
//
//            let repostView = TGRepostView(frame: CGRect.zero)
//            repostBgView.addSubview(repostView)
//            repostView.cardShowType = .postView
//            repostView.bindToEdges()
//
//            repostView.updateUI(model: model, shouldShowCancelButton: true)
//            repostBgViewHeight.constant = 100
//            // 隐藏付费选择器
//            switchPayInfoView.isHidden = true
//            // 增加底部分割线
//            let topicBottomline = UIView(frame: CGRect(x: 0, y: 50, width: ScreenWidth, height: 0.5))
//            topicBottomline.backgroundColor = RLColor.inconspicuous.disabled
//            topicView.addSubview(topicBottomline)
//            topicBottomline.snp.makeConstraints { (make) in
//                make.top.left.right.equalToSuperview()
//                make.height.equalTo(0.5)
//            }
//
//        } else if let model = self.sharedModel {
//
//            let sharedView = TGRepostView(frame: .zero)
//            repostBgView.addSubview(sharedView)
//            sharedView.cardShowType = .postView
//            sharedView.updateUI(model: model)
//            repostBgViewHeight.constant = 100
//            sharedView.bindToEdges()
//            // 隐藏付费选择器
//            switchPayInfoView.isHidden = true
//            // 增加底部分割线
//            let topicBottomline = UIView(frame: CGRect(x: 0, y: 50, width: ScreenWidth, height: 0.5))
//            topicBottomline.backgroundColor = RLColor.inconspicuous.disabled
//            topicView.addSubview(topicBottomline)
//            topicBottomline.snp.makeConstraints { (make) in
//                make.top.left.right.equalToSuperview()
//                make.height.equalTo(0.5)
//            }
//
//        } else {
            // 普通发布
            repostBgView.makeHidden()
//        }
        setCampaignData()
        view.layoutIfNeeded()
    }
    func setCampaignData(){
        guard let dict = campaignDict else { return }
        if let content = dict["content"] as? String{
            do {
                let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                        .documentType: NSAttributedString.DocumentType.html,
                        .characterEncoding: String.Encoding.utf8.rawValue
                    ]
                let attributedString = try NSAttributedString(data: content.data(using: .utf8)!, options: options, documentAttributes: nil)
                // 设置到UITextView
                self.contentTextView.attributedText = attributedString
            } catch {
                print("Error converting HTML to NSAttributedString: \(error)")
            }
           
           
        }
        if let hashtags = dict["hashtag"] as? [String]  {
            var textStr: String = ""
            var branchIds: Int = 0
            if let user = dict["user"] as? [String: Any], let userId = user["yippiUserId"] as? Int,
                let branchId = user["wantedId"] as? Int, let branchName = user["branchName"] as? String {
             
                var merchantData = TGTaggedBranchData()
                merchantData.miniProgramBranchID = branchId
                merchantData.branchName = branchName
                merchantData.yippiUserID = userId

                self.selectedMerchants.append(merchantData)
                let dealPath: String = "/pages/detail/index"
                let mpExtras = RLSDKManager.shared.loginParma?.mpExtras ?? ""
                self.insertMerchantTagTextIntoContent(miniProgramBranchId: branchId, branchName: branchName, appId: mpExtras, dealPath: dealPath, isPostFeed: true, userId: userId)
                branchIds = branchId
            }
            if branchIds != 0 {
                textStr = "\n" + " "
            }
           
            for hashtag in hashtags {
                textStr = textStr + "#" + hashtag + " "
            }

            self.contentTextView.becomeFirstResponder()
            self.contentTextView.insertText(textStr)
            HTMLManager.shared.formatTextViewAttributeText(contentTextView, selectedMerchants: selectedMerchants)
        }
    }
    @IBAction func tapScrollView(_ sender: UITapGestureRecognizer) {
        textViewResignFirstResponder()
    }
    
    // By Kit Foong (Check is valid url)
    private func isReachable(url: URL, completion: @escaping (Bool) -> ()) {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        URLSession.shared.dataTask(with: request) { _, response, _ in
            completion((response as? HTTPURLResponse)?.statusCode == 200)
        }.resume()
    }
    
    private func checkLinkPreview(withText: String?) {
        self.repostBgView.removeAllSubViews()
        guard slp.extractURL(text: withText.orEmpty) != nil && (self.repostBgView.subviews.count == 0) else {
            self.sharedModel = nil
            return
        }
        
        var isValidUrl: Bool = false
        let url = slp.extractURL(text: withText.orEmpty)!
        
        let group = DispatchGroup()
        group.enter()
        

        self.isReachable(url: url, completion:  { success in
            isValidUrl = success
                
            group.leave()
        })
        group.notify(queue: .global(), execute: {
            if isValidUrl == false {
                return
            }
            DispatchQueue.main.async {
                self.sharedModel = SharedViewModel.getModel(title: nil, description: nil, thumbnail: nil, url: nil, type: .metadata)
                guard let sharedModel = self.sharedModel, let repostBgView = self.repostBgView , let topicView = self.topicView else { return }
                let sharedView = TGRepostView(frame: .zero)
                repostBgView.makeVisible()
                repostBgView.addSubview(sharedView)
                sharedView.cardShowType = .postView
                sharedView.updateUI(model: sharedModel, shouldShowCancelButton: true)
                self.repostBgViewHeight.constant = 100
                sharedView.bindToEdges()
                repostBgView.startShimmering(background: false)
                
        
                // 增加底部分割线
                let topicBottomline = UIView(frame: CGRect(x: 0, y: 50, width: ScreenWidth, height: 0.5))
                topicBottomline.backgroundColor = RLColor.inconspicuous.disabled
                topicView.addSubview(topicBottomline)
                self.slp.preview(withText.orEmpty,
                                 onSuccess: { [weak self] (result) in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.repostBgView.stopShimmering()
                        self.repostBgView.removeAllSubViews()
                        self.sharedModel = SharedViewModel.getModel(title: result.title, description: result.description, thumbnail: result.image, url: result.url?.absoluteString, type: .metadata)
                        guard let sharedModel = self.sharedModel, let repostBgView = self.repostBgView , let topicView = self.topicView else { return }
                        let sharedView = TGRepostView(frame: .zero)
                        repostBgView.addSubview(sharedView)
                        sharedView.cardShowType = .postView
                        sharedView.updateUI(model: sharedModel, shouldShowCancelButton: true)
                        self.repostBgViewHeight.constant = 100
                        sharedView.snp.makeConstraints {
                            $0.edges.equalToSuperview()
                            $0.height.equalTo(TGRepostViewUX.postUIPostVideoCardHeight + 15)
                        }
                        // 增加底部分割线
                        let topicBottomline = UIView(frame: CGRect(x: 0, y: 50, width: ScreenWidth, height: 0.5))
                        topicBottomline.backgroundColor = RLColor.inconspicuous.disabled
                        topicView.addSubview(topicBottomline)
                        topicBottomline.snp.makeConstraints { (make) in
                            make.top.left.right.equalToSuperview()
                            make.height.equalTo(0.5)
                        }
                        
                        self.view.layoutIfNeeded()
                    }
                },
                                 onError: { [weak self] error in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        defer {
                            self.view.layoutIfNeeded()
                        }
                        switch error {
                        case .cannotBeOpened(let error):
                            self.repostBgView.stopShimmering()
                            self.repostBgView.removeAllSubViews()
                            let imageUrl = error?.description
                            guard let url = URL(string: imageUrl.orEmpty) else {
                                self.sharedModel = nil
                                return
                            }
                            
                            self.sharedModel = SharedViewModel.getModel(title: "", description: url.host, thumbnail:imageUrl , url: imageUrl, type: .metadata)
                            guard let sharedModel = self.sharedModel, let repostBgView = self.repostBgView , let topicView = self.topicView else { return }
                            let sharedView = TGRepostView(frame: .zero)
                            repostBgView.addSubview(sharedView)
                            sharedView.cardShowType = .postView
                            sharedView.updateUI(model: sharedModel, shouldShowCancelButton: true)
                            self.repostBgViewHeight.constant = 100
                            sharedView.snp.makeConstraints {
                                $0.edges.equalToSuperview()
                                $0.height.equalTo(TGRepostViewUX.postUIPostVideoCardHeight + 15)
                            }
                            // 增加底部分割线
                            let topicBottomline = UIView(frame: CGRect(x: 0, y: 50, width: ScreenWidth, height: 0.5))
                            topicBottomline.backgroundColor = RLColor.inconspicuous.disabled
                            topicView.addSubview(topicBottomline)
                            topicBottomline.snp.makeConstraints { (make) in
                                make.top.left.right.equalToSuperview()
                                make.height.equalTo(0.5)
                            }
                        default:
                            self.sharedModel = nil
                            return
                        }
                    }
                })
            }
        })
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        isTapOtherView = true
        if !contentTextView.isFirstResponder && !toolView.isHidden {
            toolView.isHidden = true
        }
        if touch.view == mainScrollView || touch.view == showImageCollectionView {
            return true
        }
        return false
    }
    
    fileprivate func calculationCollectionViewHeight() {
        if isFromShareExtension {
            switch postPhotoExtension.count {
            case 0...3:
                releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight
            case 4...7:
                releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight * 2 + spacing
            case 8...9:
                releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight * 3 + 2 * spacing
            default:
                break
            }
        } else {
            switch selectedPHAssets.count + selectedModelImages.count {
            case 0...3:
                releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight
            case 4...7:
                releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight * 2 + spacing
            case 8...9:
                releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight * 3 + 2 * spacing
            default:
                break
            }
        }
        
    }
    
    private func setCheckInView() {
        checkInLocationLabel.text = String.empty
        checkInLabel.text = "check_in".localized
        
        let setLocationBlock = { [weak self] (location: TGLocationModel) -> Void in
            self?.taggedLocation = location
        }
        
        checkInView.addTap { [weak self] (_) in
            let searchVC = TGLocationPOISearchViewController()
            searchVC.onLocationSelected = setLocationBlock
            
            let presentingVC = TGNavigationController(rootViewController: searchVC).fullScreenRepresentation
            self?.navigationController?.present(presentingVC, animated: true, completion: nil)
        }
    }
    
    private func setVoucherView() {
        addVoucher.text = "rw_add_voucher".localized
        
        removeButton.addTap { [weak self] (_) in
            self?.voucherInfoView.isHidden = true
            self?.voucherConstantH.constant = 50
            self?.arrowImageView.isHidden = false
            self?.isVoucherRemoved = true
        }
        
        voucherView.addTap { [weak self] (_) in
            RLSDKManager.shared.feedDelegate?.openVoucherSelection(completion: { [weak self] voucherId, voucherName in
                guard let self = self else { return }
                self.voucherInfoView.isHidden = false
                self.arrowImageView.isHidden = true
                self.voucherConstantH.constant = 100
                self.voucherLabel.text = voucherName
                self.voucherId = voucherId
                self.voucherName = voucherName
                self.isVoucherRemoved = false
            })
        }
        
        if let tagVoucher = tagVoucher, tagVoucher.taggedVoucherId > 0 {
            self.voucherInfoView.isHidden = false
            self.arrowImageView.isHidden = true
            self.voucherConstantH.constant = 100
            self.voucherLabel.text = tagVoucher.taggedVoucherTitle
            self.voucherId = tagVoucher.taggedVoucherId
            self.voucherName = tagVoucher.taggedVoucherTitle
        }
    }
    private func updateVoucherContent(tagVoucher: TagVoucherModel) {
        self.voucherInfoView.isHidden = false
        self.arrowImageView.isHidden = true
        self.voucherConstantH.constant = 100
        self.voucherLabel.text = tagVoucher.taggedVoucherTitle
        self.voucherId = tagVoucher.taggedVoucherId
        self.voucherName = tagVoucher.taggedVoucherTitle
    }
    /// 发布按钮是否可点击
    fileprivate func setReleaseButtonIsEnabled() {
        if self.isReposting {
            releaseButton.isEnabled = true
        } else {
            if !releasePulseContent.isEmpty || !selectedPHAssets.isEmpty || !postPhotoExtension.isEmpty || !selectedModelImages.isEmpty{
                releaseButton.isEnabled = true
            } else {
                releaseButton.isEnabled = false
            }
        }
    }
    
    // MARK: - tapButton
    @objc fileprivate func tapCancelButton() {
        textViewResignFirstResponder()
        if !releasePulseContent.isEmpty || !selectedPHAssets.isEmpty || !postPhotoExtension.isEmpty {
            let actionsheetView = TGCustomActionsheetView(titles: ["warning_cancel_post_status".localized, "confirm".localized])
            actionsheetView.delegate = self
            actionsheetView.tag = 2
            actionsheetView.notClickIndexs = [0]
            actionsheetView.show()
        } else {
            if self.isMiniProgram {
                self.navigationController?.popViewController(animated: true)
            } else {
                let _ = self.navigationController?.dismiss(animated: true, completion: {})
            }
        }
    }
    
    func returnSelectTitle(view: TGCustomActionsheetView, title: String, index: Int) {
        if view.tag == 2 {
            let _ = self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - tapSend
    fileprivate  func textViewResignFirstResponder() {
        contentTextView.resignFirstResponder()
        packUpKey()
    }
    
    fileprivate  func setShowImages() {
        self.showImageCollectionView.imageDatas.removeAll()
        if isFromShareExtension {
            for item in postPhotoExtension {
                var image: UIImage!
                if item.type == kUTTypeGIF as String {
                    image = UIImage.gif(data: item.data!)
                } else {
                    image = UIImage(data: item.data!)
                }
//                image.TSImageMIMEType = item.type!
                self.showImageCollectionView.imageDatas.append(image ?? UIImage())
            }
            
            let pi: UIImage? = postPhotoExtension.count < maxPhotoCount ? UIImage(named: "img_edit_photo_frame_tg") : nil
            if let pi = pi {
                self.showImageCollectionView.imageDatas.append(pi)
            }
            self.showImageCollectionView.imageShare = self.postPhotoExtension
            self.showImageCollectionView.fromShare = true
            self.showImageCollectionView.reloadData()
            self.calculationCollectionViewHeight()
            
        }else {
            for item in selectedModelImages {
                if let imageItem = item as? TGRejectDetailModelImages {
                    self.showImageCollectionView.imageDatas.append(imageItem.imagePath ?? "")
                }
                if let image = item as? UIImage {
                    self.showImageCollectionView.imageDatas.append(image)
                }
            }
            for item in selectedPHAssets {
                
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                PHCachingImageManager.default().requestImageData(for: item, options: option) { [weak self] (data, type, orientation, info) in
                    guard let data = data, let type = type, let self = self else { return }
                    var image: UIImage!
                    if type == kUTTypeGIF as String {
                        image = UIImage.gif(data: data)
                    } else {
                        image = UIImage(data: data)
                    }
//                    image.TSImageMIMEType = type
                    self.showImageCollectionView.imageDatas.append(image)
//                    payinfos.append(item.payInfo)
                }
            }
            
            let pi: UIImage? = (selectedPHAssets.count + selectedModelImages.count) < maxPhotoCount ? UIImage.set_image(named: "img_edit_photo_frame_tg") : nil
            if let pi = pi {
                self.showImageCollectionView.imageDatas.append(pi)
            }
            self.showImageCollectionView.imagePHAssets = self.selectedPHAssets
            self.showImageCollectionView.reloadData()
            self.calculationCollectionViewHeight()
        }
    }
    
    // MARK: - 点击了相册按钮
    func didSelectCell(index: Int) {
        textViewResignFirstResponder()
        
        AuthorizeStatusUtils.checkAuthorizeStatusByType(type: .cameraAlbum, viewController: self, completion: {
            DispatchQueue.main.async {
                self.currentIndex = index
                if self.isFromShareExtension {
                    if index + 1 > self.postPhotoExtension.count { // 点击了相册选择器,进入图片查看器
                        self.showCameraVC(true, selectedAssets: self.selectedPHAssets) { [weak self] (assets, _, _, _, _) in
                            for asset in assets {
                                let manager = PHImageManager.default()
                                let options = PHImageRequestOptions()
                                
                                options.version = .original
                                options.isSynchronous = true
                                manager.requestImageData(for: asset, options: options) { data, uti, _, _ in
                                    if let data = data {
                                        self?.postPhotoExtension.append(TGPostPhotoExtension(data: data as Data, type: uti))
                                    }
                                }
                            }
                            self?.setShowImages()
                        }
                    } else {
                        
                        self.editPhotoVC(asset: nil, photo: self.postPhotoExtension[index])
                        
                    }
                } else {
                    if index + 1 > (self.selectedPHAssets.count + self.selectedModelImages.count) { // 点击了相册选择器,进入图片查看器
                        self.showCameraVC(true, selectedAssets: self.selectedPHAssets, selectedImages: self.selectedModelImages) { [weak self] (assets, _, _, _, _) in
                            self?.selectedPHAssets = assets
                            self?.setShowImages()
                        }
                    } else {
                        if index < self.selectedModelImages.count {
                            if let imageModel = self.selectedModelImages[index] as? TGRejectDetailModelImages {
                                self.editPhotoVC(imageURL: imageModel.imagePath ?? "", photo: nil)
                            }
                            if let image = self.selectedModelImages[index] as? UIImage {
                                self.editPhotoVC(image: image, photo: nil)
                            }
                        } else {
                            self.editPhotoVC(asset: self.selectedPHAssets[index - self.selectedModelImages.count], photo: nil)
                        }
                    }
                }
            }
        })
    }
    func didTapDeleteImageBtn(btn: UIButton) {
        let index = btn.tag
        releaseButton.isEnabled = true
        if isFromShareExtension {
            if postPhotoExtension.count > index {
                postPhotoExtension.remove(at: index)
            }
            
            if postPhotoExtension.count == 0 {
                textViewResignFirstResponder()
                self.navigationController?.dismiss(animated: true, completion: nil)
                return
            }
        } else {
            if index < selectedModelImages.count {
                self.selectedModelImages.remove(at: index)
            } else {
                if selectedPHAssets.count > index - selectedModelImages.count {
                    selectedPHAssets.remove(at: index - selectedModelImages.count)
                }
            }
            if selectedPHAssets.count == 0 && !self.isFromEditFeed {
                textViewResignFirstResponder()
                self.navigationController?.dismiss(animated: true, completion: nil)
                return
            }
        }
        if (selectedPHAssets.count + selectedModelImages.count) == 0 && self.isFromEditFeed {
            releaseButton.isEnabled = false
        }
        
        self.setShowImages()
    }
    @objc func emojiBtnClick() {
        smileButton.isSelected = !smileButton.isSelected
        if smileButton.isSelected {
            isTapOtherView = false
            contentTextView.resignFirstResponder()
        } else {
            contentTextView.becomeFirstResponder()
        }
    }
    @objc func packUpKey() {
        smileButton.isSelected = false
        contentTextView.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.toolView.isHidden = true
        }
    }
    
    func editPhotoVC(asset: PHAsset?, photo: TGPostPhotoExtension?){
        var image: UIImage!
        
        if isFromShareExtension {
            guard let data = photo?.data, let type = photo?.type else { return }
            if type == kUTTypeGIF as String {
                image = UIImage.gif(data: data)
            } else {
                image = UIImage(data: data)
            }
        } else {
            guard let asset = asset else { return }
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            PHCachingImageManager.default().requestImageData(for: asset, options: option) { [weak self] (data, type, orientation, info) in
                guard let data = data, let type = type, let self = self else { return }
                if type == kUTTypeGIF as String {
                    image = UIImage.gif(data: data)
                } else {
                    image = UIImage(data: data)
                }
                
            }
        }
        DispatchQueue.main.async{
            if let photoEditor = TGAppUtil.shared.createPhotoEditor(for: image) {
                photoEditor.photoEditorDelegate = self
                self.present(photoEditor.fullScreenRepresentation, animated: true, completion: nil)
            }
        }
    }
    func editPhotoVC(image: UIImage?, photo: TGPostPhotoExtension?){
        
        DispatchQueue.main.async{
            if let photoEditor = TGAppUtil.shared.createPhotoEditor(for: image) {
                photoEditor.photoEditorDelegate = self
                self.present(photoEditor.fullScreenRepresentation, animated: true, completion: nil)
            }
        }
    }
    func editPhotoVC(imageURL: String?, photo: TGPostPhotoExtension?){
        
        guard let imageURL = URL(string: imageURL ?? "") else {
//            printIfDebug("Failed to load image data from URL")
            return
        }
        
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else {
//                printIfDebug("Failed to load image data from URL")
                return
            }
            
            guard let image = UIImage(data: imageData) else {
//                printIfDebug("Failed to create UIImage from image data")
                return
            }
            
            DispatchQueue.main.async {
                if let photoEditor = TGAppUtil.shared.createPhotoEditor(for: image) {
                    photoEditor.photoEditorDelegate = self
                    self.present(photoEditor.fullScreenRepresentation, animated: true, completion: nil)
                }
            }
        }
    }
    // 按钮点击事件处理
    @objc func expandCollapseButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.contentTextViewHeight.constant = self.currentKbH == 0 ? 300 : self.currentKbH // 高度设置为展开状态时的高度
            let newHeight = ScreenHeight - self.currentKbH - TSNavigationBarHeight - TSBottomSafeAreaHeight - 90

            UIView.animate(withDuration: 0.6,
                           delay: 0,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseInOut,
                           animations: {
                self.contentTextViewHeight.constant = newHeight
                self.view.layoutIfNeeded()
            }, completion: nil)
             self.contentTextView.becomeFirstResponder() // 打开键盘
         } else {
             self.contentTextViewHeight.constant = 150 // 收起时的高度
             self.contentTextView.resignFirstResponder() // 关闭键盘
         }
    }
}


// MARK: - Release btn tap
extension TGReleasePulseViewController {
    @objc fileprivate func releasePulse() {
        textViewResignFirstResponder()
//        guard TSReachability.share.isReachable() != false else {
//            self.showError(message: "connect_lost_check".localized)
//            return
//        }
        var pulseContent = self.releasePulseContent
        
        if let attributedString = self.contentTextView.attributedText {
            pulseContent = HTMLManager.shared.formHtmlString(attributedString)
        }

        releaseButton.isEnabled = false
        let postPHAssets = selectedPHAssets
        let postPulseContent = pulseContent
        if self.sharedModel?.url == nil {
            self.sharedModel = nil
        }
        
        if isVoucherRemoved {
            tagVoucher = nil
        } else {
            if let voucherId = self.voucherId, let voucherName = self.voucherName {
                tagVoucher = TagVoucherModel(taggedVoucherId: voucherId, taggedVoucherTitle: voucherName)
            } else {
                tagVoucher = nil
            }
        }
        let branchId = aiFeedParams["branch_id"] as? String ?? ""
        if self.type == .miniVideo {
            let postModel = TGPostModel(feedMark: TGAppUtil.shared.createResourceID(), isHotFeed: false, feedContent: postPulseContent, privacy: self.privacyType.rawValue, repostModel: nil, shareModel: nil, topics: self.topics, taggedLocation: self.taggedLocation, phAssets: nil, postPhoto: nil, video: shortVideoAsset, soundId: nil, videoType: self.videoType, postVideo: nil, isEditFeed: isFromEditFeed, feedId: feedId, images: nil, rejectNeedsUploadVideo: isVideoDataChanged, videoCoverId: coverId, videoDataId: videoId, tagUsers: selectedUsers, tagMerchants: selectedMerchants, tagVoucher: tagVoucher, aiFeedTargetBranchId: nil)
            if campaignDict != nil {
                TGPostTaskManager.shared.addTask(postModel, type: .campaign)
            } else if !aiFeedParams.isEmpty {
                TGPostTaskManager.shared.addTask(postModel, type: .AIFeed)
            } else {
                TGPostTaskManager.shared.addTask(postModel, type: .normalType)
            }
        }else {
            let postModel = TGPostModel(feedMark: TGAppUtil.shared.createResourceID(), isHotFeed: false, feedContent: postPulseContent, privacy: privacyType.rawValue, repostModel: repostModel, shareModel: sharedModel, topics: topics, taggedLocation: taggedLocation, phAssets: postPHAssets, postPhoto: postPhotoExtension, video: nil, soundId: nil, videoType: nil, postVideo: nil, isEditFeed: isFromEditFeed, feedId: feedId, images: selectedModelImages, rejectNeedsUploadVideo: nil, videoCoverId: nil, videoDataId: nil, tagUsers: selectedUsers, tagMerchants: selectedMerchants, tagVoucher: tagVoucher, aiFeedTargetBranchId: nil)
            if campaignDict != nil {
                TGPostTaskManager.shared.addTask(postModel, type: .campaign)
            } else if !aiFeedParams.isEmpty {
                TGPostTaskManager.shared.addTask(postModel, type: .AIFeed)
            } else {
                TGPostTaskManager.shared.addTask(postModel, type: .normalType)
            }
        }
        DispatchQueue.main.async {
            if self.isFromEditFeed == true {
                RLSDKManager.shared.feedDelegate?.didPresentFeedHome()
            } else {
                self.isPost = true
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        // 活动的动态发布
        if campaignDict != nil {
            NotificationCenter.default.post(name: TGPostTaskManager.PopViewNotification, object: nil)
        }
    }
}

// MARK: - TextViewDelegate
extension TGReleasePulseViewController {
    public func textViewDidChange(_ textView: UITextView) {
        //only enable when post type = text
        if self.isText {
            checkLinkPreview(withText: textView.text)
        }
        
        setReleaseButtonIsEnabled()
        
        // At
        let selectedRange = textView.markedTextRange
        if selectedRange == nil {
            HTMLManager.shared.formatTextViewAttributeText(textView)
            return
        }
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        /// 整体不可编辑
        // 联想文字则不修改
        let range = textView.selectedRange
        if range.length > 0 {
            return
        }
        let matchs = TGUtil.findAllTSAt(inputStr: textView.text)
        for match in matchs {
            let newRange = NSRange(location: match.range.location + 1, length: match.range.length - 1)
            if NSLocationInRange(range.location, newRange) {
                textView.selectedRange = NSRange(location: match.range.location + match.range.length, length: 0)
                break
            }
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "" {
            let selectRange = textView.selectedRange
            if selectRange.length > 0 {
                return true
            }
            // 整体删除at的关键词，修改为整体选中
            var isEditAt = false
            var atRange = selectRange
            let matchs = TGUtil.findAllTSAt(inputStr: textView.text)
            for match in matchs {
                let newRange = NSRange(location: match.range.location + 1, length: match.range.length - 1)
                if NSLocationInRange(range.location, newRange) {
                    isEditAt = true
                    atRange = match.range
                    break
                }
            }
            
            if isEditAt {
                HTMLManager.shared.formatTextViewAttributeText(textView)
                textView.selectedRange = atRange
                return false
            }
        } else if text == "@" {
            // 跳转到at列表
            self.pushAtSelectedList()
            // 手动输入的at在选择了用户的block中会先移除掉,如果跳转后不选择用户就不做处理
            return true
        }else if text == "#" {
            // 跳转到#列表
            self.pushHashtagSelectedList()
            
            return true
        }
        return true
    }
}

// MARK: - Lifecycle
extension TGReleasePulseViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        // 初始化时创建配置信息都为空
        if !selectedModelImages.isEmpty {
            
        }
        if !selectedPHAssets.isEmpty {
            setShowImages()
        }
        if !selectedModelImages.isEmpty {
            setShowImages()
        }
        if !postPhotoExtension.isEmpty {
            setShowImages()
        }
        if let privacy = self.rejectPrivacyType {
            self.privacyType = privacy
            self.privacyValueLabel.text = privacy.localizedString
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            if let location = self.rejectLocation {
                self.taggedLocation = location
            }
        }
        
        beanErrorLabel.sizeToFit()
        self.contentStackView.addArrangedSubview(beanErrorLabel)
        beanErrorLabel.isHidden = true
     
        if let text = self.preText, text.count > 0 {
            HTMLManager.shared.removeHtmlTag(htmlString: "\(text) ", isPostFeed: true, completion: { [weak self] (content, userIdList, merchantIdList, merchantAppIdList, merchantDealPathList) in
                guard let self = self else { return }
                
                if self.isFromEditFeed && !self.rewardsMerchantUsers.isEmpty {
                    for (index, merchantId) in merchantIdList.enumerated() {
                        if let branchId = Int(merchantId), branchId > 0 {
                            let merchantData = TGTaggedBranchData()
                            merchantData.miniProgramBranchID = branchId
                            
                            if let matchingMerchant = self.rewardsMerchantUsers.first(where: { $0.wantedMid == branchId }) {
                                merchantData.yippiUserID = matchingMerchant.merchantId
                                merchantData.branchName = matchingMerchant.userName
                            }
                            
                            self.selectedMerchants.append(merchantData)
                        }
                    }
                }
                
                var htmlAttributedText = content.attributonString()
                htmlAttributedText = HTMLManager.shared.formAttributeText(htmlAttributedText, userIdList, merchantIdList, merchantAppIdList, merchantDealPathList, self.selectedMerchants)
                self.contentTextView.attributedText = htmlAttributedText
                self.contentTextView.delegate?.textViewDidChange!(contentTextView)
            })
        }
        
        if let branchId = aiFeedParams["branch_id"] {
            if let data = "ai_status_steps".localized.data(using: .utf8), let array = try? JSONDecoder().decode([String].self, from: data) {
                aiStatusMessage = array
            }
            
            loadingView.onCancel = { [weak self] in
                guard let self = self else { return }
                self.showImageCollectionView.imageDatas.append(UIImage(named: "IMG_edit_photo_frame"))
                self.showImageCollectionView.reloadData()
                self.calculationCollectionViewHeight()
                
                self.cancelNetworkRequest()
                self.loadingView.dismiss()
            }
            loadingView.onRetry = { [weak self] in
                guard let self = self else { return }
                self.loadingView.restartAnimation()
                self.getAIFeedContent(params: aiFeedParams)
            }
            loadingView.updateAnimationItems(items: aiStatusMessage)
            loadingView.show()
            getAIFeedContent(params: aiFeedParams)
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = "title_post_status".localized
        setReleaseButtonIsEnabled()
        if mainView.frame.size.height > mainScrollView.bounds.height {
        } else {
            scrollContentSizeHeight.constant = mainScrollView.bounds.size.height - mainView.bounds.size.height + 1
        }
        self.updateViewConstraints()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    private func showSocialTooltip() {
        let preference = ToolTipPreferences()
        preference.drawing.bubble.color = UIColor(red: 37, green: 37, blue: 37).withAlphaComponent(0.78)
        preference.drawing.message.color = .white
        preference.drawing.background.color = .clear
        
        UserDefaults.socialTokenToolTipShouldHide = true
    }
}

// MARK: - Notification
extension TGReleasePulseViewController {
    /// 键盘通知响应
    @objc fileprivate func kbWillShowNotificationProcess(_ notification: Notification) -> Void {
        guard let userInfo = notification.userInfo, let kbFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        self.currentKbH = kbFrame.size.height
        if isPriceTextFiledTap {
            self.toolView.isHidden = true
        } else {
            self.toolView.isHidden = false
            self.smileButton.isSelected = false
            self.toolView.top = kbFrame.origin.y - (TSBottomSafeAreaHeight + 41 + 64.0)
        }
        if expandCollapseButton.isSelected {
            let newHeight = ScreenHeight - self.currentKbH - TSNavigationBarHeight - TSBottomSafeAreaHeight - 90
            UIView.animate(withDuration: 0.6,
                           delay: 0,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseInOut,
                           animations: {
                self.contentTextViewHeight.constant = newHeight
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc fileprivate func kbWillHideNotificationProcess(_ notification: Notification) -> Void {
        self.kbProcessReset()
        self.toolView.top = ScreenHeight - toolHeight - 64.0 - TSBottomSafeAreaHeight
        self.smileButton.isSelected = true
        self.toolView.isHidden = isTapOtherView
        // 当键盘隐藏且按钮为选中状态，恢复原始高度
        if expandCollapseButton.isSelected {
            expandCollapseButton.isSelected = false
            UIView.animate(withDuration: 0.6,
                           delay: 0,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseInOut,
                           animations: {
                self.contentTextViewHeight.constant = 150
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        
    }
    
    @objc fileprivate func fieldBeginEditingNotificationProcess(_ notification: Notification) -> Void {
        isPriceTextFiledTap = true
        let kbH: CGFloat = self.currentKbH
        let bottomH: CGFloat = ScreenHeight - self.mainView.bounds.size.height - 64.0
        if kbH > bottomH {
            UIView.animate(withDuration: 0.25) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -(kbH - bottomH) - 20.0)
            }
        }
    }
    @objc fileprivate func fieldEndEditingNotificationProcess(_ notification: Notification) -> Void {
        isPriceTextFiledTap = false
        self.kbProcessReset()
    }
    
    /// 键盘相关的复原
    fileprivate func kbProcessReset() -> Void {
        UIView.animate(withDuration: 0.25) {
            self.view.transform = CGAffineTransform.identity
        }
    }
    
}

// MARK: - 话题板块儿
extension TGReleasePulseViewController {
    /// 布局话题板块儿
    func setTopicViewUI(showTopic: Bool, topicData: [TGTopicCommonModel]) {
        topicView.removeAllSubViews()
        if showTopic {
            let topLine = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 0.5))
            topLine.backgroundColor = RLColor.inconspicuous.disabled
            topicView.addSubview(topLine)
            
            if topicData.isEmpty {
                let addTopicLabel = UILabel(frame: CGRect(x: 25, y: 0.5, width: 100, height: 49))
                addTopicLabel.text = "post_add_topic".localized
                addTopicLabel.textColor = UIColor(hex: 0x333333)
                addTopicLabel.font = UIFont.systemFont(ofSize: 15)
                topicView.addSubview(addTopicLabel)
                
                let rightIcon = UIImageView(frame: CGRect(x: ScreenWidth - 15 - 10, y: 0, width: 10, height: 20))
                rightIcon.clipsToBounds = true
                rightIcon.contentMode = .scaleAspectFill
                rightIcon.image =  #imageLiteral(resourceName: "IMG_ic_arrow_smallgrey")
                rightIcon.centerY = addTopicLabel.centerY
                topicView.addSubview(rightIcon)
                
                /// 外加一个点击事件button
                let addButton = UIButton(type: .custom)
                addButton.backgroundColor = UIColor.clear
                addButton.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 50)
                addButton.addTarget(self, action: #selector(jumpToTopicSearchVC), for: UIControl.Event.touchUpInside)
                topicView.addSubview(addButton)
                topicViewHeight.constant = 50
                topicView.updateConstraints()
            } else {
                var XX: CGFloat = 15
                var YY: CGFloat = 14
                let labelHeight: CGFloat = 24
                let inSpace: CGFloat = 8
                let outSpace: CGFloat = 20
                let maxWidth: CGFloat = ScreenWidth - 30
                var tagBgViewHeight: CGFloat = 0
                for (index, item) in topicData.enumerated() {
                    var labelWidth = item.name.sizeOfString(usingFont: UIFont.systemFont(ofSize: 10)).width
                    labelWidth = labelWidth + inSpace * 2
                    if labelWidth > maxWidth {
                        labelWidth = maxWidth
                    }
                    let tagLabel: UIButton = UIButton(type: .custom)
                    let bgView: UIImageView = UIImageView()
                    tagLabel.frame = CGRect(x: XX, y: YY, width: labelWidth, height: labelHeight)
                    XX = tagLabel.right + outSpace
                    if tagLabel.right > maxWidth {
                        XX = 15
                        YY = tagLabel.bottom + outSpace
                        tagLabel.frame = CGRect(x: XX, y: YY, width: labelWidth, height: labelHeight)
                        XX = tagLabel.right + outSpace
                    }
                    tagLabel.backgroundColor = UIColor(hex: 0xe6e6e6)
                    tagLabel.setTitleColor(UIColor.white, for: .normal)
                    tagLabel.layer.cornerRadius = 3
                    tagLabel.setTitle(item.name, for: .normal)
                    tagLabel.titleLabel?.font = UIFont.systemFont(ofSize: 10)
                    tagLabel.tag = 666 + index
                    tagLabel.addTarget(self, action: #selector(deleteTopicButton(sender:)), for: UIControl.Event.touchUpInside)
                    topicView.addSubview(tagLabel)
                    
                    bgView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 16, height: 16))
                    bgView.center = CGPoint(x: tagLabel.origin.x + 3, y: tagLabel.origin.y + 3)
                    bgView.layer.cornerRadius = 8
                    bgView.image =  #imageLiteral(resourceName: "ico_topic_close")
                    bgView.tag = 999 + index
                    bgView.isUserInteractionEnabled = true
                    let deleteTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteTopic(tap:)))
                    bgView.addGestureRecognizer(deleteTap)
                    topicView.addSubview(bgView)
                    bgView.isHidden = false
                    if chooseModel != nil {
                        if item.id == chooseModel?.id {
                            bgView.isHidden = true
                        }
                    }
                    
                    if topicData.count < 1 {
                        if index == (topicData.count - 1) {
                            // 需要增加一个添加话题按钮
                            let addImage = UIImageView()
                            addImage.frame = CGRect(x: XX, y: YY, width: 42, height: 24)
                            if addImage.right > maxWidth {
                                XX = 15
                                YY = tagLabel.bottom + outSpace
                                addImage.frame = CGRect(x: XX, y: YY, width: 42, height: 24)
                                XX = addImage.right + outSpace
                            }
                            addImage.clipsToBounds = true
                            addImage.layer.cornerRadius = 3
                            addImage.contentMode = .scaleAspectFill
                            addImage.image =  #imageLiteral(resourceName: "ico_add_topic")
                            addImage.tintColor = RLColor.inconspicuous.disabled
                            addImage.isUserInteractionEnabled = true
                            let addTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(jumpToTopicSearchVC))
                            addImage.addGestureRecognizer(addTap)
                            topicView.addSubview(addImage)
                            tagBgViewHeight = addImage.bottom + 14
                        }
                    } else {
                        if index == (topicData.count - 1) {
                            tagBgViewHeight = tagLabel.bottom + 14
                        }
                    }
                }
                topicViewHeight.constant = tagBgViewHeight
                topicView.updateConstraints()
            }
        } else {
            topicViewHeight.constant = 0
            topicView.updateConstraints()
        }
    }
    
    // MARK: - 搜索话题页面选择话题之后发通知处理话题板块儿
    @objc func topicChooseNotice(notice: Notification) {
        let dict: NSDictionary = notice.userInfo! as NSDictionary
        let model: TopicListModel = dict["topic"] as! TopicListModel
        let changeModel: TGTopicCommonModel = TGTopicCommonModel(topicListModel: model)
        /// 先检测已选的话题里面是不是已经有了当前选择的那个话题，如果有，不作处理（不添加到 topics数组里面），如果没有，直接添加进去
        var hasTopic = false
        if !topics.isEmpty {
            for (_, item) in topics.enumerated() {
                if item.id == changeModel.id {
                    hasTopic = true
                    break
                }
            }
            if hasTopic {
                return
            } else {
                topics.append(changeModel)
                setTopicViewUI(showTopic: true, topicData: topics)
            }
        } else {
            topics.append(changeModel)
            setTopicViewUI(showTopic: true, topicData: topics)
        }
    }
    
    // MARK: - 话题板块儿选择话题跳转到搜索话题页面
    @objc func jumpToTopicSearchVC() {
//        let searchVC = TopicSearchVC.vc()
//        searchVC.jumpType = "post"
//        searchVC.onSelectTopic = { [weak self] model in
//            guard let self = self else { return }
//            let changeModel: TGTopicCommonModel = TGTopicCommonModel(topicListModel: model)
//            /// 先检测已选的话题里面是不是已经有了当前选择的那个话题，如果有，不作处理（不添加到 topics数组里面），如果没有，直接添加进去
//            var hasTopic = false
//            if !self.topics.isEmpty {
//                for (_, item) in self.topics.enumerated() {
//                    if item.id == changeModel.id {
//                        hasTopic = true
//                        break
//                    }
//                }
//                if hasTopic {
//                    return
//                } else {
//                    self.topics.append(changeModel)
//                    self.setTopicViewUI(showTopic: true, topicData: self.topics)
//                }
//            } else {
//                self.topics.append(changeModel)
//                self.setTopicViewUI(showTopic: true, topicData: self.topics)
//            }
//        }
//        let nav = TSNavigationController(rootViewController: searchVC).fullScreenRepresentation
//        self.present(nav, animated: true, completion: nil)
    }
    
    // MARK: - 话题板块儿删除话题按钮点击事件
    @objc func deleteTopic(tap: UIGestureRecognizer) {
        if !topics.isEmpty {
            topics.remove(at: (tap.view?.tag)! - 999)
            setTopicViewUI(showTopic: true, topicData: topics)
        }
    }
    
    // MARK: - 话题板块儿点击话题按钮删除话题
    @objc func deleteTopicButton(sender: UIButton) {
        if !topics.isEmpty {
            if chooseModel != nil {
                let model = topics[sender.tag - 666]
                if model.id == chooseModel?.id {
                    return
                }
            }
            topics.remove(at: sender.tag - 666)
            setTopicViewUI(showTopic: true, topicData: topics)
        }
    }
    
    // MARK: - 话题板块儿获取当前已选择的话题 id 然后组装成一个 id 数组（用于发布接口传值）
    /// 没选择话题的情况下发布接口对应的话题字段就不传，如果有就传话题 ID 数组
    func getCurrentTopicIdArray() -> NSArray {
        let pass = NSMutableArray()
        if !topics.isEmpty {
            for item in topics {
                pass.append(item.id)
            }
        }
        return pass
    }
}

// MARK: - at人
extension TGReleasePulseViewController {
    /// 点击了atView
    @objc func didTapAtView() {
        self.pushAtSelectedList()
    }
    /// 跳转到可选at人的列表
    func pushAtSelectedList() {
//        let atselectedListVC = TGAtPeopleAndMechantListVC()
//        let presentingVC = TGNavigationController(rootViewController: atselectedListVC).fullScreenRepresentation
//        self.present(presentingVC, animated: true, completion: nil)
//        atselectedListVC.selectedBlock = { [weak self] (userInfo, userInfoModelType) in
//            guard let self = self else { return }
//            atselectedListVC.dismiss(animated: true, completion: nil)
//            if let userInfo = userInfo {
//                /// 先移除光标所在前一个at
//                self.insertTagTextIntoContent(userId: userInfo.userIdentity, userName: userInfo.name)
//                if userInfoModelType == .merchant {
//                    self.selectedMerchants.append(userInfo)
//                } else {
//                    self.selectedUsers.append(userInfo)
//                }
//                return
//            }
//        }
        let atselectedListVC = TGAtPeopleAndMechantListVC()
        self.present(TGNavigationController(rootViewController: atselectedListVC).fullScreenRepresentation, animated: true, completion: nil)
        atselectedListVC.selectedBlock = { [weak self] (userInfo, appId, dealPath, userInfoModelType) in
            guard let self = self else { return }
            atselectedListVC.dismiss(animated: true, completion: nil)
            if let userInfo = userInfo {
                switch userInfoModelType {
                case .people:
                    if let userModel = userInfo as? TGUserInfoModel {
                        /// 先移除光标所在前一个at
                        self.insertTagTextIntoContent(userId: userModel.userIdentity, userName: userModel.name)
                        self.selectedUsers.append(userModel)
                    }
                case .merchant:
                    if let merchantModel = userInfo as? TGTaggedBranchData {
                        /// 先移除光标所在前一个at
                        self.insertMerchantTagTextIntoContent(miniProgramBranchId: merchantModel.miniProgramBranchID, branchName: merchantModel.branchName ?? "", appId: appId, dealPath: dealPath, isPostFeed: true, userId: merchantModel.yippiUserID)
                        // Note: merchant is already added to selectedMerchants in insertMerchantTagTextIntoContent
                    }
                }
                return
            }
        }
    }
    
    func pushHashtagSelectedList(){
//        let vc = HastagSearchResultVC()
//        self.present(TSNavigationController(rootViewController: vc).fullScreenRepresentation, animated: true, completion: nil)
//        vc.selectCall = { [weak self] text in
//            vc.dismiss(animated: true, completion: nil)
//            self?.insertHashTagTextIntoContent(hashTag: text ?? "")
//            self?.contentTextView.becomeFirstResponder()
//        }
//        vc.gobackCall = { [weak self] text in
//            if text.count > 0 {
//                self?.insertHashTagTextIntoContent(hashTag: text)
//                self?.contentTextView.becomeFirstResponder()
//
//            }else {
//                self?.contentTextView.becomeFirstResponder()
//                self?.contentTextView.insertText("#")
//            }
//
//        }
    }
    
    @objc func updateContentTextViewTag (_ noti: NSNotification) {
        
        if let userInfo = noti.userInfo as? Dictionary<String, Any>, userInfo["username"] != nil {
            let username = userInfo["username"] as! String
            /// 先移除光标所在前一个at
            insertTagTextIntoContent(userName: username)
        }
    }
    
    func insertTagTextIntoContent(userId: Int? = nil, userName: String) {
        self.contentTextView = TGCommonTool.atMeTextViewEdit(self.contentTextView) as! KMPlaceholderTextView
        
        let temp = HTMLManager.shared.addUserIdToTagContent(userId: userId, userName: userName)
        let newMutableString = self.contentTextView.attributedText.mutableCopy() as! NSMutableAttributedString
        newMutableString.append(temp)
        
        self.contentTextView.attributedText = newMutableString
        //self.contentTextView.insertText(insertStr)
        self.contentTextView.delegate?.textViewDidChange!(contentTextView)
        self.contentTextView.becomeFirstResponder()
        self.contentTextView.insertText("")
    }
    
    func insertMerchantTagTextIntoContent(miniProgramBranchId: Int? = nil, branchName: String? = nil, appId: String? = nil,
                                          dealPath: String? = nil, isPostFeed: Bool = false, userId: Int? = nil, userName: String? = nil) {
        self.contentTextView = TGCommonTool.atMeTextViewEdit(self.contentTextView) as! KMPlaceholderTextView
        
        if isPostFeed {
            let merchantName = branchName ?? ""
            let temp: NSAttributedString = HTMLManager.shared.addMerchantToTagContent(
                miniProgramBranchId: miniProgramBranchId,
                branchName: merchantName,
                appId: appId,
                dealPath: dealPath,
                yippiUserID: userId
            )
            
            let newMutableString = self.contentTextView.attributedText.mutableCopy() as! NSMutableAttributedString
            newMutableString.append(temp)
            
            self.contentTextView.attributedText = newMutableString
            
            // Add merchant to selectedMerchants array
            if let miniProgramBranchId = miniProgramBranchId, let branchName = branchName {
                let merchantData = TGTaggedBranchData()
                merchantData.miniProgramBranchID = miniProgramBranchId
                merchantData.branchName = branchName
                merchantData.yippiUserID = userId
                self.selectedMerchants.append(merchantData)
            }
        } else {
            // For user mentions
            let temp: NSAttributedString = HTMLManager.shared.addUserIdToTagContent(
                userId: userId,
                userName: userName ?? ""
            )
            
            let newMutableString = self.contentTextView.attributedText.mutableCopy() as! NSMutableAttributedString
            newMutableString.append(temp)
            
            self.contentTextView.attributedText = newMutableString
        }
        
        self.contentTextView.delegate?.textViewDidChange?(contentTextView)
        self.contentTextView.becomeFirstResponder()
        self.contentTextView.insertText("")
    }
    
}

extension TGReleasePulseViewController: TSSystemEmojiSelectorViewDelegate {
    func emojiViewDidSelected(emoji: String) {
        self.contentTextView.insertText(emoji)
        self.contentTextView.scrollRangeToVisible(self.contentTextView.selectedRange)
    }
}
extension TGReleasePulseViewController {
    @IBAction func previewBtnAction(_ sender: Any) {
        guard let shortVideoAsset = shortVideoAsset else {
            return
        }
        if let asset = shortVideoAsset.asset {
//            guard let manager = TZImageManager.default() else {
//                TSIndicatorWindowTop.showDefaultTime(state: .faild, title: "export_video_fail".localized)
//                return
//            }
//
//            manager.getVideoWith(asset) { [weak self] item, dictionary in
//                guard let `self` = self, let item = item else {
//                    return
//                }
//                DispatchQueue.main.async {
//                    let vc = PreviewVideoVC()
//                    vc.avasset = item.asset
//                    vc.delegate = self
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//            }
        } else if let url = shortVideoAsset.videoFileURL {
            let vc = TGPreviewVideoVC()
            vc.avasset = AVAsset(url: url)
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func selectCoverBtnTapped(_ sender: Any) {
        guard let shortVideoAsset = shortVideoAsset else {
            return
        }
        if let url = shortVideoAsset.videoFileURL {
            let vc = TGMiniVideoCoverPickerViewController(asset: AVAsset(url: url))
            vc.delegate = self
            self.present(vc.fullScreenRepresentation, animated: true, completion: nil)
        }
        
    }
    @IBAction func reRecorderBtnAction(_ sender: Any) {
        
        self.showMiniVideoRecorder { url in
            let asset = AVURLAsset(url: url)
            let coverImage = FileUtils.generateAVAssetVideoCoverImage(avAsset: asset)
            let releasePulseVC = TGReleasePulseViewController(type: .miniVideo)
            releasePulseVC.shortVideoAsset = TGShortVideoAsset(coverImage: coverImage, asset: nil, videoFileURL: url)
            let navigation = TGNavigationController(rootViewController: releasePulseVC).fullScreenRepresentation
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                self.present(navigation, animated: true, completion: nil)
            }
        }
    }
}
// MARK: AI Feed
extension TGReleasePulseViewController {
    private func cancelNetworkRequest() {
//        if let networkRequest = networkRequest {
//            RequestNetworkData.share.cancelCurrentRequest(request: networkRequest)
//            self.networkRequest = nil
//        }
    }
    
    private func getAIFeedContent(params: [String: Any]) {
        TGFeedNetworkManager.shared.getAIFeed(params: params, completion: { [weak self] msg, data in
            guard let self = self else { return }
        
            if let msg = msg {
                self.showError(message: msg)
                self.loadingView.updateContent(title: "rl_ai_feed_generate_error_title".localized, desc: "rl_ai_feed_generate_error_desc".localized)
                self.loadingView.retryButton.makeVisible()
                return
            }
            
            self.loadingView.dismiss()
            
            if let data = data {
                HTMLManager.shared.removeHtmlTag(htmlString: "\(data.content)\n\n", isPostFeed: true, completion: { [weak self] (content, userIdList, merchantIdList, merchantAppIdList, merchantDealPathList) in
                    guard let self = self else { return }
                    var htmlAttributedText = content.attributonString()
                    htmlAttributedText = HTMLManager.shared.formAttributeText(htmlAttributedText, userIdList, merchantIdList, merchantAppIdList,  merchantDealPathList, self.selectedMerchants)
                    self.contentTextView.attributedText = htmlAttributedText
                    self.contentTextView.delegate?.textViewDidChange!(contentTextView)
                    
                    for item in data.tagMerchant ?? [] {
                        let merchantData = TGTaggedBranchData()
                        merchantData.miniProgramBranchID = item.yippisWantedBranchId
                        merchantData.branchName = item.branchName
                        merchantData.yippiUserID = item.merchantYippiUserId
                        
                        self.selectedMerchants.append(merchantData)
                        
                        // Check if merchant mention already exists in the AI content
                        let currentText = self.contentTextView.attributedText.string
                        let merchantName = item.branchName ?? ""
                        let merchantNameWithAt = "@\(merchantName)"
                        
                        if currentText.contains(merchantNameWithAt) {
                            // Add attributes to the existing merchant mention
                            if let updatedAttributedText = HTMLManager.shared.addMerchantAttributesToExistingMention(
                                attributedText: self.contentTextView.attributedText,
                                merchantName: merchantName,
                                miniProgramBranchId: item.yippisWantedBranchId,
                                appId: data.miniProgramAppId,
                                dealPath: data.miniProgramDealPath
                            ) {
                                self.contentTextView.attributedText = updatedAttributedText
                            } else {
                                self.insertMerchantTagTextIntoContent(miniProgramBranchId: item.yippisWantedBranchId, branchName: item.branchName, appId: data.miniProgramAppId, dealPath: data.miniProgramDealPath, isPostFeed: true, userId: item.merchantYippiUserId)
                            }
                        } else {
                            self.insertMerchantTagTextIntoContent(miniProgramBranchId: item.yippisWantedBranchId, branchName: item.branchName, appId: data.miniProgramAppId, dealPath: data.miniProgramDealPath, isPostFeed: true, userId: item.merchantYippiUserId)
                        }
                    }
                })
                
                if !self.isMiniVideo {
                    self.selectedModelImages.append(contentsOf: data.images ?? [])
                    self.setShowImages()
                }
                
                if let tagVoucher = data.tagVoucher, tagVoucher.taggedVoucherId > 0 {
                    self.updateVoucherContent(tagVoucher: tagVoucher)
                }
            }
        })
    }
}
//// MARK: - permission
extension TGReleasePulseViewController {
    
    func setPrivacyView() {
        privacyTitleLabel.text = "post_privacy".localized
        privacyValueLabel.text = privacyType.localizedString
        
        privacyView.addAction {
            
            self.textViewResignFirstResponder()
            
            let sheet = TGCustomActionsheetView(titles: PrivacyType.allCases.map { $0.localizedString }, cancelText: "cancel".localized)
            sheet.finishBlock = { _, _, index in
                self.privacyType = PrivacyType.getType(for: index)
            }
            sheet.show()
        }
    }
}

extension TGReleasePulseViewController: PhotoEditorDelegate{
    public func doneEditing(image: UIImage) {
        DispatchQueue.global(qos: .default).async(execute: {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { [weak self] (saved, error) in
                guard let self = self else { return }
                if saved {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                    let result = PHAsset.fetchAssets(with: .image, options: fetchOptions).lastObject
                    
                    if self.isFromShareExtension {
                        if let result = result, self.postPhotoExtension.count > self.currentIndex {
                            let options = PHImageRequestOptions()
                            let manager = PHImageManager.default()
                            manager.requestImageData(for: result, options: options) { data, type, _, _ in
                                
                                if let data = data, let type = type {
                                    self.postPhotoExtension[self.currentIndex].data = data
                                    self.postPhotoExtension[self.currentIndex].type = type
                                }
                                DispatchQueue.main.async {
                                    self.setShowImages()
                                }
                            }
                        }
                    }else{
                        if self.selectedModelImages.count > 0 && self.currentIndex < self.selectedModelImages.count {
                            //编辑完的图片传回的时候 应该要怎么替换
                            self.selectedModelImages[self.currentIndex] = image
                        }else{
                            let index = self.currentIndex - self.selectedModelImages.count
                            if let result = result, self.selectedPHAssets.count > index {
                                let asset = self.selectedPHAssets[index]
                                self.selectedPHAssets[index] = result
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.setShowImages()
                        }
                    }
                }
            }
        })
        
    }
    
    public func canceledEditing() {
        
    }
}

public enum PrivacyType: String, CaseIterable {
    case everyone
    case friends
    case `self`
    
    static func getType(for index: Int) -> PrivacyType {
        switch index {
        case 0:
            return .everyone
        case 1:
            return .friends
        default:
            return .`self`
        }
    }
    
    var localizedString: String {
        switch self {
        case .everyone:
            return "everyone".localized
        case .friends:
            return "friends_only".localized
        case .`self`:
            return "me_only".localized
        }
    }
}
extension TGReleasePulseViewController: TGPreviewVideoVCDelegate {
    func previewDeleteVideo() {
        self.shortVideoAsset = nil
        self.isVideoDataChanged = false
    }
}
extension TGReleasePulseViewController: MiniVideoCoverPickerDelegate {
    func coverImageDidPicked(_ image: UIImage) {
        guard let asset = self.shortVideoAsset else {
            return
        }
        self.isVideoDataChanged = true
        self.shortVideoAsset = TGShortVideoAsset(coverImage: image, asset: asset.asset, videoFileURL: asset.videoFileURL)
    }
}
