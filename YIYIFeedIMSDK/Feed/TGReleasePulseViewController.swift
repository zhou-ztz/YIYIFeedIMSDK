//
//  TGReleasePulseViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/3.
//

//import UIKit
//import KMPlaceholderTextView
//import Photos
//import CoreLocation
//import SDWebImage
//import MobileCoreServices
//import SwiftLinkPreview
//import ObjectBox
//
//enum PrivacyType: String, CaseIterable {
//    case everyone
//    case friends
//    case `self`
//    
//    static func getType(for index: Int) -> PrivacyType {
//        switch index {
//        case 0:
//            return .everyone
//        case 1:
//            return .friends
//        default:
//            return .`self`
//        }
//    }
//    
//    var localizedString: String {
//        switch self {
//        case .everyone:
//            return "everyone".localized
//        case .friends:
//            return "friends_only".localized
//        case .`self`:
//            return "me_only".localized
//        }
//    }
//}
//
//typealias FoursquareLocation = TGPostLocationObject
//
//class TGReleasePulseViewController: TGViewController, UITextViewDelegate, didselectCellDelegate, TGCustomAcionSheetDelegate, UIGestureRecognizerDelegate {
//    /// 主承载视图
//    @IBOutlet weak var mainView: UIView!
//    // 滚动视图高度
//    @IBOutlet weak var scrollContentSizeHeight: NSLayoutConstraint!
//    
//    // 图片查看器的高度
//    @IBOutlet weak var releaseDynamicCollectionViewHeight: NSLayoutConstraint!
//    // 发布内容
//    @IBOutlet weak var contentTextView: KMPlaceholderTextView!
//    @IBOutlet weak var atView: UIView!
//    /// 修饰后的发布内容
//    var releasePulseContent: String {
//        return contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
//    }
//    var apiPulseContent: String = ""
//    // 展示图片CollectionView
//    @IBOutlet weak var showImageCollectionView: TGReleasePulseCollectionView!
//    // 滚动视图
//    @IBOutlet weak var mainScrollView: UIScrollView!
//    // 展示文本字数
//    @IBOutlet weak var showWordsCountLabel: UILabel!
//    @IBOutlet weak var topicView: UIView!
//    @IBOutlet weak var topicViewHeight: NSLayoutConstraint!
//    @IBOutlet weak var repostBgView: UIView!
//    @IBOutlet weak var repostBgViewHeight: NSLayoutConstraint!
//    /// Permission
//    @IBOutlet weak var privacyView: UIView!
//    @IBOutlet weak var privacyValueLabel: UILabel!
//    @IBOutlet weak var privacyTitleLabel: UILabel!
//    @IBOutlet weak var tagTitleLabel: UILabel!
//    
//    @IBOutlet weak var checkInView: UIView!
//    @IBOutlet weak var checkInLabel: UILabel!
//    @IBOutlet weak var checkInLocationLabel: UILabel!
//    @IBOutlet weak var contentStackView: UIStackView!
//    //文本内容展开/收起 按钮
//    @IBOutlet weak var expandCollapseButton: UIButton!
//    @IBOutlet weak var voucherView: UIView!
//    
//    @IBOutlet weak var removeButton: UIButton!
//    @IBOutlet weak var voucherLabel: UILabel!
//    @IBOutlet weak var addVoucher: UILabel!
//    @IBOutlet weak var contentTextViewHeight: NSLayoutConstraint!
//    @IBOutlet weak var voucherConstantH: NSLayoutConstraint!
//    @IBOutlet weak var voucherInfoView: UIView!
//    @IBOutlet weak var arrowImageView: UIImageView!
//    
//    var privacyType: PrivacyType = .everyone {
//        didSet {
//            self.privacyValueLabel.text = privacyType.localizedString
//        }
//    }
//    // cell个数
//    let cellCount: CGFloat = 4.0
//    // cell行间距
//    let spacing: CGFloat = 5.0
//    // 最大标题字数
//    let maxtitleCount: Int = 30
//    // 最大内容字数
//    let maxContentCount: Int = 255
//    // 显示字数时机
//    let showWordsCount: Int = 200
//    // contentTextView是否滚动的行数
//    let contentTextViewScrollNumberLine = 7
//    // 发布按钮（还没判断有无图片时的点击逻辑）
//    // 最大图片张叔
//    let maxPhotoCount: Int = 9
//    private let slp = SwiftLinkPreview()
//    
//    var releaseButton = TGTextButton.initWith(putAreaType: .top)
//    // 记录collection高度
//    var releaseDynamicCollectionViewSourceHeight: CGFloat = 0.0
//    /// 选择图片数据对应数据
//    var selectedPHAssets: [PHAsset] = []
//    /// 选择图片数据对应数据
//    //    var selectedModelImages: [UIImage] = []
//    /// 选择图片数据对应数据
//    var selectedModelImages: [Any] = []
//    
//    var selectedText: String = ""
//    
//    /// 支付信息
//    //    var imagesPayInfo: [TSImgPrice] = [TSImgPrice]()
//    // 是否隐藏CollectionView
//    var isHiddenshowImageCollectionView = false
//    // 是否开启图片支付
//    var isOpenImgsPay = false
//    // 键盘高度
//    var currentKbH: CGFloat = 0
//    
//    ///从话题进入的发布页面自带一个不能删除的话题
//    var chooseModel: TGTopicCommonModel?
//    
//    /// 话题信息
//    var topics: [TGTopicCommonModel] = []
//    /// 转发信息
//    var repostModel: TGRepostModel?
//    
//    var sharedModel: SharedViewModel?
//    
//    /// 从被拒绝动态传来的位置对象
//    var rejectLocation: FoursquareLocation?
//    /// 从被拒绝动态传来的隐私类型对象
//    var rejectPrivacyType: PrivacyType?
//    
//    /// 选中的动态关联用户
//    var selectedUsers: [UserInfoModel] = []
//    /// 选中的动态关联商家
//    var selectedMerchants: [UserInfoModel] = []
//    /// 输入框顶部工具栏
//    // 整个容器
//    var toolView = UIView()
//    // 下分割线
//    var bottomLine = UIView()
//    // 上分割线
//    var topLine = UIView()
//    /// 表情按钮
//    var smileButton = UIButton(type: .custom)
//    /// 收起按钮
//    var packUpButton = UIButton(type: .custom)
//    /// 选择Emoji的视图
//    var emojiView: TSSystemEmojiSelectorView!
//    var toolHeight: CGFloat = 145 + TSBottomSafeAreaHeight + 41
//    
//    // By Kit Foong (Check is it mini program)
//    var isMiniProgram: Bool = false
//    var isFromShareExtension: Bool = false
//    var postPhotoExtension =  [PostPhotoExtension]()
//    //动态ID
//    var feedId: String?
//    //是否从(驳回动态/编辑)页面来
//    var isFromEditFeed: Bool = false
//    
//    var isPost: Bool = false
//    
//    private let beanErrorLabel: UILabel = {
//        let label = UILabel()
//        label.applyStyle(.regular(size: 12, color: UIColor(red: 209, green: 77, blue: 77)))
//        label.text = "socialtoken_post_hot_feed_alert".localized
//        label.textAlignment = .right
//        
//        return label
//    }()
//    
//    var isTapOtherView = false
//    var isPriceTextFiledTap = false
//    var isReposting = false
//    var isText = false
//    var currentIndex = 0
//    private var taggedLocation: FoursquareLocation? {
//        willSet  {
//            guard let checkedIn = newValue else {
//                checkInLocationLabel.text = ""
//                return
//            }
//            checkInLocationLabel.text = checkedIn.locationName
//        }
//    }
//    var preText: String? = nil
//
//    var campaignDict: [String: Any]?
//
//    var voucherId: Int?
//    var voucherName: String?
//    var tagVoucher: TagVoucherModel?
//    var isVoucherRemoved: Bool = false
//    
//    init(isHiddenshowImageCollectionView: Bool,isText:Bool = false, isReposting:Bool = false) {
//        super.init(nibName: "TGReleasePulseViewController", bundle: nil)
//        self.isText = isText
//        self.isReposting = isReposting
//        self.isHiddenshowImageCollectionView = isHiddenshowImageCollectionView
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShowNotificationProcess(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHideNotificationProcess(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(fieldBeginEditingNotificationProcess(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(fieldEndEditingNotificationProcess(_:)), name: UITextField.textDidEndEditingNotification, object: nil)
//        //        NotificationCenter.default.addObserver(self, selector: #selector(topicChooseNotice(notice:)), name: NSNotification.Name(rawValue: "passPublishTopicData"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(updateContentTextViewTag(_:)), name: NSNotification.Name(rawValue: "isTaggingPost"), object: nil)
//        
//        if selectedText != "" {
//            self.contentTextView.insertText(selectedText)
//            contentTextView.delegate?.textViewDidChange!(contentTextView)
//        }
//    }
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
//        //        NotificationCenter.default.addObserver(self, selector: #selector(topicChooseNotice(notice:)), name: NSNotification.Name(rawValue: "passPublishTopicData"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(updateContentTextViewTag(_:)), name: NSNotification.Name(rawValue: "isTaggingPost"), object: nil)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    // MARK: - setUI
//    fileprivate func setUI() {
//        
//        /// 初始化键盘顶部工具视图
//        toolView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: toolHeight)
//        toolView.backgroundColor = UIColor.white
//        self.view.addSubview(toolView)
//        toolView.isHidden = true
//        
//        topLine.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 0.5)
//        topLine.backgroundColor = RLColor.normal.keyboardTopCutLine
//        toolView.addSubview(topLine)
//        
//        packUpButton.frame = CGRect(x: 25, y: 0, width: 22, height: 22)
//        packUpButton.setImage(#imageLiteral(resourceName: "sec_nav_arrow"), for: .normal)
//        packUpButton.centerY = 41 / 2.0
//        toolView.addSubview(packUpButton)
//        packUpButton.addTarget(self, action: #selector(packUpKey), for: UIControl.Event.touchUpInside)
//        
//        smileButton.frame = CGRect(x: ScreenWidth - 50, y: 0, width: 25, height: 25)
//        smileButton.setImage(#imageLiteral(resourceName: "ico_chat_keyboard_expression"), for: .normal)
//        smileButton.setImage(#imageLiteral(resourceName: "ico_chat_keyboard"), for: .selected)
//        smileButton.centerY = packUpButton.centerY
//        toolView.addSubview(smileButton)
//        smileButton.addTarget(self, action: #selector(emojiBtnClick), for: UIControl.Event.touchUpInside)
//        
//        emojiView = TSSystemEmojiSelectorView(frame: CGRect(x: 0, y: 41, width: ScreenWidth, height: 0))
//        emojiView.delegate = self
//        toolView.addSubview(emojiView)
//        emojiView.frame = CGRect(x: 0, y: 41, width: ScreenWidth, height: toolHeight - 41)
//        
//        bottomLine.frame = CGRect(x: 0, y: 40, width: ScreenWidth, height: 1)
//        bottomLine.backgroundColor = UIColor(hex: 0x667487)
//        toolView.addSubview(bottomLine)
//        
//        /// 限制输入文本框字数
//        contentTextView.placeholder = "placeholder_post_status".localized
//        contentTextView.returnKeyType = .default    // 键盘的return键为换行样式
//        contentTextView.font = UIFont.systemFont(ofSize: RLFont.ContentText.text.rawValue)
//        //允许非焦点状态下仍然可以滚动
//        contentTextView.isScrollEnabled = true
//        //显示垂直滚动条
//        contentTextView.showsVerticalScrollIndicator = true
//        contentTextView.placeholderColor = RLColor.normal.disabled
//        contentTextView.placeholderFont = UIFont.systemFont(ofSize: RLFont.ContentText.text.rawValue)
//        contentTextView.delegate = self
//        contentTextView.textAlignment = .left
//        showImageCollectionView.didselectCellDelegate = self
//        releaseDynamicCollectionViewSourceHeight = (UIScreen.main.bounds.size.width - 40 - spacing * 3) / cellCount + 1
//        releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight
//        
//        showImageCollectionView.isHidden = isHiddenshowImageCollectionView
//        
//        expandCollapseButton.setBackgroundImage(UIImage(named: "ic_rl_expand"), for: .normal)
//        expandCollapseButton.setBackgroundImage(UIImage(named: "ic_rl_collapse"), for: .selected)
//        expandCollapseButton.roundCorner(14)
//        expandCollapseButton.backgroundColor = .lightGray.withAlphaComponent(0.4)
//        expandCollapseButton.addTarget(self, action: #selector(expandCollapseButtonTapped(_:)), for: .touchUpInside)
//        
//        // set btns
//        let cancelButton = UIButton(type: .custom)
//        cancelButton.setTitle("cancel".localized, for: .normal)
//        cancelButton.contentHorizontalAlignment = .left
//        cancelButton.addTarget(self, action: #selector(tapCancelButton), for: .touchUpInside)
//        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
//        releaseButton.setTitle("publish".localized, for: .normal)
//        releaseButton.addTarget(self, action: #selector(releasePulse), for: .touchUpInside)
//        releaseButton.contentHorizontalAlignment = .right
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: releaseButton)
//        releaseButton.isEnabled = false
//        showImageCollectionView.maxImageCount = (maxPhotoCount - selectedModelImages.count)
//        self.topicView.isHidden = true
//        setTopicViewUI(showTopic: true, topicData: topics)
//        let atViewTap = UITapGestureRecognizer(target: self, action: #selector(didTapAtView))
//        atView.addGestureRecognizer(atViewTap)
//        
//        tagTitleLabel.text = "tag_title_ppl_merchant".localized
//        
//        /// Privacy view setup
//        setPrivacyView()
//        
//        setCheckInView()
//        
//        setVoucherView()
//        
//        // 有转发内容
////        if let model = self.repostModel {
////            
////            let repostView = TGRepostView(frame: CGRect.zero)
////            repostBgView.addSubview(repostView)
////            repostView.cardShowType = .postView
////            repostView.bindToEdges()
////            
////            repostView.updateUI(model: model, shouldShowCancelButton: true)
////            repostBgViewHeight.constant = 100
////            // 隐藏付费选择器
////            switchPayInfoView.isHidden = true
////            // 增加底部分割线
////            let topicBottomline = UIView(frame: CGRect(x: 0, y: 50, width: ScreenWidth, height: 0.5))
////            topicBottomline.backgroundColor = RLColor.inconspicuous.disabled
////            topicView.addSubview(topicBottomline)
////            topicBottomline.snp.makeConstraints { (make) in
////                make.top.left.right.equalToSuperview()
////                make.height.equalTo(0.5)
////            }
////            
////        } else if let model = self.sharedModel {
////            
////            let sharedView = TGRepostView(frame: .zero)
////            repostBgView.addSubview(sharedView)
////            sharedView.cardShowType = .postView
////            sharedView.updateUI(model: model)
////            repostBgViewHeight.constant = 100
////            sharedView.bindToEdges()
////            // 隐藏付费选择器
////            switchPayInfoView.isHidden = true
////            // 增加底部分割线
////            let topicBottomline = UIView(frame: CGRect(x: 0, y: 50, width: ScreenWidth, height: 0.5))
////            topicBottomline.backgroundColor = RLColor.inconspicuous.disabled
////            topicView.addSubview(topicBottomline)
////            topicBottomline.snp.makeConstraints { (make) in
////                make.top.left.right.equalToSuperview()
////                make.height.equalTo(0.5)
////            }
////            
////        } else {
//            // 普通发布
//            repostBgView.makeHidden()
////        }
//        setCampaignData()
//        view.layoutIfNeeded()
//    }
//    func setCampaignData(){
//        guard let dict = campaignDict else { return }
//        if let content = dict["content"] as? String{
//            do {
//                let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
//                        .documentType: NSAttributedString.DocumentType.html,
//                        .characterEncoding: String.Encoding.utf8.rawValue
//                    ]
//                let attributedString = try NSAttributedString(data: content.data(using: .utf8)!, options: options, documentAttributes: nil)
//                // 设置到UITextView
//                self.contentTextView.attributedText = attributedString
//            } catch {
//                print("Error converting HTML to NSAttributedString: \(error)")
//            }
//           
//           
//        }
//        if let hashtags = dict["hashtag"] as? [String]  {
//            var textStr: String = ""
//            var userIds: Int = 0
//            if let user = dict["user"] as? [String: Any] , let userId = user["yippiUserId"] as? Int{
//                
//                let username = user["yippiUsername"] as? String
//                let originalName = user["name"] as? String
//                
//                let name = TGLocalRemarkName.getRemarkName(userId: nil, username: username, originalName: originalName, label: nil)
//                var userInfo = UserInfoModel()
//                userInfo.userIdentity = userId
//                userInfo.id = Id(userId)
//                userInfo.username = username ?? ""
//                
//                let nickName = name.count == 0 ? (username ?? "") : name
//                userInfo.name = nickName
//                self.selectedMerchants.append(userInfo)
//                self.insertTagTextIntoContent(userId: userInfo.userIdentity, userName: nickName)
//                userIds = userId
//            }
//            if userIds != 0 {
//                textStr = "\n" + " "
//            }
//           
//            for hashtag in hashtags {
//                textStr = textStr + "#" + hashtag + " "
//            }
//
//            self.contentTextView.becomeFirstResponder()
//            self.contentTextView.insertText(textStr)
//            HTMLManager.shared.formatTextViewAttributeText(contentTextView)
//        }
//    }
//    @IBAction func tapScrollView(_ sender: UITapGestureRecognizer) {
//        textViewResignFirstResponder()
//    }
//    
//    // By Kit Foong (Check is valid url)
//    private func isReachable(url: URL, completion: @escaping (Bool) -> ()) {
//        var request = URLRequest(url: url)
//        request.httpMethod = "HEAD"
//        URLSession.shared.dataTask(with: request) { _, response, _ in
//            completion((response as? HTTPURLResponse)?.statusCode == 200)
//        }.resume()
//    }
//    
//    private func checkLinkPreview(withText: String?) {
//        self.repostBgView.removeAllSubViews()
//        guard slp.extractURL(text: withText.orEmpty) != nil && (self.repostBgView.subviews.count == 0) else {
//            self.sharedModel = nil
//            return
//        }
//        
//        var isValidUrl: Bool = false
//        var url = slp.extractURL(text: withText.orEmpty)!
//        
//        let group = DispatchGroup()
//        group.enter()
//        
//        if url != nil {
//            self.isReachable(url: url, completion:  { success in
//                isValidUrl = success
//                
//                group.leave()
//            })
//        } else {
//            group.leave()
//        }
//        
//        group.notify(queue: .global(), execute: {
//            if isValidUrl == false {
//                return
//            }
//            
////            if FileUtils.checkIsDeepLink(urlString: withText ?? "") {
////                return
////            }
//            
//            DispatchQueue.main.async {
//                self.sharedModel = SharedViewModel.getModel(title: nil, description: nil, thumbnail: nil, url: nil, type: .metadata)
//                guard let sharedModel = self.sharedModel, let repostBgView = self.repostBgView , let topicView = self.topicView else { return }
//                let sharedView = TGRepostView(frame: .zero)
//                repostBgView.makeVisible()
//                repostBgView.addSubview(sharedView)
//                sharedView.cardShowType = .postView
//                sharedView.updateUI(model: sharedModel, shouldShowCancelButton: true)
//                self.repostBgViewHeight.constant = 100
//                sharedView.bindToEdges()
//                repostBgView.startShimmering(background: false)
//                
//        
//                // 增加底部分割线
//                let topicBottomline = UIView(frame: CGRect(x: 0, y: 50, width: ScreenWidth, height: 0.5))
//                topicBottomline.backgroundColor = RLColor.inconspicuous.disabled
//                topicView.addSubview(topicBottomline)
//                self.slp.preview(withText.orEmpty,
//                                 onSuccess: { [weak self] (result) in
//                    guard let self = self else { return }
//                    DispatchQueue.main.async {
//                        self.repostBgView.stopShimmering()
//                        self.repostBgView.removeAllSubViews()
//                        self.sharedModel = SharedViewModel.getModel(title: result.title, description: result.description, thumbnail: result.image, url: result.url?.absoluteString, type: .metadata)
//                        guard let sharedModel = self.sharedModel, let repostBgView = self.repostBgView , let topicView = self.topicView else { return }
//                        let sharedView = TGRepostView(frame: .zero)
//                        repostBgView.addSubview(sharedView)
//                        sharedView.cardShowType = .postView
//                        sharedView.updateUI(model: sharedModel, shouldShowCancelButton: true)
//                        self.repostBgViewHeight.constant = 100
//                        sharedView.snp.makeConstraints {
//                            $0.edges.equalToSuperview()
//                            $0.height.equalTo(TGRepostViewUX.postUIPostVideoCardHeight + 15)
//                        }
//                        // 增加底部分割线
//                        let topicBottomline = UIView(frame: CGRect(x: 0, y: 50, width: ScreenWidth, height: 0.5))
//                        topicBottomline.backgroundColor = RLColor.inconspicuous.disabled
//                        topicView.addSubview(topicBottomline)
//                        topicBottomline.snp.makeConstraints { (make) in
//                            make.top.left.right.equalToSuperview()
//                            make.height.equalTo(0.5)
//                        }
//                        
//                        self.view.layoutIfNeeded()
//                    }
//                },
//                                 onError: { [weak self] error in
//                    guard let self = self else { return }
//                    DispatchQueue.main.async {
//                        defer {
//                            self.view.layoutIfNeeded()
//                        }
//                        switch error {
//                        case .cannotBeOpened(let error):
//                            self.repostBgView.stopShimmering()
//                            self.repostBgView.removeAllSubViews()
//                            let imageUrl = error?.description
//                            guard let url = URL(string: imageUrl.orEmpty) else {
//                                self.sharedModel = nil
//                                return
//                            }
//                            
//                            self.sharedModel = SharedViewModel.getModel(title: "", description: url.host, thumbnail:imageUrl , url: imageUrl, type: .metadata)
//                            guard let sharedModel = self.sharedModel, let repostBgView = self.repostBgView , let topicView = self.topicView else { return }
//                            let sharedView = TGRepostView(frame: .zero)
//                            repostBgView.addSubview(sharedView)
//                            sharedView.cardShowType = .postView
//                            sharedView.updateUI(model: sharedModel, shouldShowCancelButton: true)
//                            self.repostBgViewHeight.constant = 100
//                            sharedView.snp.makeConstraints {
//                                $0.edges.equalToSuperview()
//                                $0.height.equalTo(TGRepostViewUX.postUIPostVideoCardHeight + 15)
//                            }
//                            // 增加底部分割线
//                            let topicBottomline = UIView(frame: CGRect(x: 0, y: 50, width: ScreenWidth, height: 0.5))
//                            topicBottomline.backgroundColor = RLColor.inconspicuous.disabled
//                            topicView.addSubview(topicBottomline)
//                            topicBottomline.snp.makeConstraints { (make) in
//                                make.top.left.right.equalToSuperview()
//                                make.height.equalTo(0.5)
//                            }
//                        default:
//                            self.sharedModel = nil
//                            return
//                        }
//                    }
//                })
//            }
//        })
//    }
//    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        isTapOtherView = true
//        if !contentTextView.isFirstResponder && !toolView.isHidden {
//            toolView.isHidden = true
//        }
//        if touch.view == mainScrollView || touch.view == showImageCollectionView {
//            return true
//        }
//        return false
//    }
//    
//    fileprivate func calculationCollectionViewHeight() {
//        if isFromShareExtension {
//            switch postPhotoExtension.count {
//            case 0...3:
//                releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight
//            case 4...7:
//                releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight * 2 + spacing
//            case 8...9:
//                releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight * 3 + 2 * spacing
//            default:
//                break
//            }
//        } else {
//            switch selectedPHAssets.count + selectedModelImages.count {
//            case 0...3:
//                releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight
//            case 4...7:
//                releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight * 2 + spacing
//            case 8...9:
//                releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight * 3 + 2 * spacing
//            default:
//                break
//            }
//        }
//        
//    }
//    
//    private func setCheckInView() {
//        checkInLocationLabel.text = String.empty
//        checkInLabel.text = "check_in".localized
//        
//        let setLocationBlock = { [weak self] (location: TGPostLocationObject) -> Void in
//            self?.taggedLocation = location
//        }
//        
//        checkInView.addTap { [weak self] (_) in
//            let searchVC = TGLocationPOISearchViewController()
//            searchVC.onLocationSelected = setLocationBlock
//            
//            let presentingVC = TGNavigationController(rootViewController: searchVC).fullScreenRepresentation
//            self?.navigationController?.present(presentingVC, animated: true, completion: nil)
//        }
//    }
//    
//    private func setVoucherView() {
//        addVoucher.text = "rw_add_voucher".localized
//        
//        removeButton.addTap { [weak self] (_) in
//            self?.voucherInfoView.isHidden = true
//            self?.voucherConstantH.constant = 50
//            self?.arrowImageView.isHidden = false
//            self?.isVoucherRemoved = true
//        }
//        
//        voucherView.addTap { [weak self] (_) in
////            let suggestVC = SuggestVoucherViewController()
////            suggestVC.delegate = self
////           // searchVC.onLocationSelected = setLocationBlock
////            
////            let presentingVC = TGNavigationController(rootViewController: suggestVC).fullScreenRepresentation
////            self?.navigationController?.present(presentingVC, animated: true, completion: nil)
//        }
//        
//        if let tagVoucher = tagVoucher, tagVoucher.taggedVoucherId > 0 {
//            self.voucherInfoView.isHidden = false
//            self.arrowImageView.isHidden = true
//            self.voucherConstantH.constant = 100
//            self.voucherLabel.text = tagVoucher.taggedVoucherTitle
//            self.voucherId = tagVoucher.taggedVoucherId
//            self.voucherName = tagVoucher.taggedVoucherTitle
//        }
//    }
//    
//    /// 发布按钮是否可点击
//    fileprivate func setReleaseButtonIsEnabled() {
//        if self.isReposting {
//            releaseButton.isEnabled = true
//        } else {
//            if !releasePulseContent.isEmpty || !selectedPHAssets.isEmpty || !postPhotoExtension.isEmpty || !selectedModelImages.isEmpty{
//                releaseButton.isEnabled = true
//            } else {
//                releaseButton.isEnabled = false
//            }
//        }
//    }
//    
//    // MARK: - tapButton
//    @objc fileprivate func tapCancelButton() {
//        textViewResignFirstResponder()
//        if !releasePulseContent.isEmpty || !selectedPHAssets.isEmpty || !postPhotoExtension.isEmpty {
//            let actionsheetView = TGCustomActionsheetView(titles: ["warning_cancel_post_status".localized, "confirm".localized])
//            actionsheetView.delegate = self
//            actionsheetView.tag = 2
//            actionsheetView.notClickIndexs = [0]
//            actionsheetView.show()
//        } else {
//            if self.isMiniProgram {
//                self.navigationController?.popViewController(animated: true)
//            } else {
//                let _ = self.navigationController?.dismiss(animated: true, completion: {})
//            }
//        }
//    }
//    
//    func returnSelectTitle(view: TGCustomActionsheetView, title: String, index: Int) {
//        if view.tag == 2 {
//            let _ = self.navigationController?.dismiss(animated: true, completion: nil)
//        }
//    }
//    
//    // MARK: - tapSend
//    fileprivate  func textViewResignFirstResponder() {
//        contentTextView.resignFirstResponder()
//        packUpKey()
//    }
//    
//    fileprivate  func setShowImages() {
//        self.showImageCollectionView.imageDatas.removeAll()
//        if isFromShareExtension {
//            for item in postPhotoExtension {
//                var image: UIImage!
//                if item.type == kUTTypeGIF as String {
//                    image = UIImage.gif(data: item.data!)
//                } else {
//                    image = UIImage(data: item.data!)
//                }
////                image.TSImageMIMEType = item.type!
//                self.showImageCollectionView.imageDatas.append(image ?? UIImage())
//            }
//            
//            let pi: UIImage? = postPhotoExtension.count < maxPhotoCount ? UIImage(named: "IMG_edit_photo_frame") : nil
//            if let pi = pi {
//                self.showImageCollectionView.imageDatas.append(pi)
//            }
//            self.showImageCollectionView.imageShare = self.postPhotoExtension
//            self.showImageCollectionView.fromShare = true
//            self.showImageCollectionView.shoudSetPayInfo = self.isOpenImgsPay
//            self.showImageCollectionView.reloadData()
//            self.calculationCollectionViewHeight()
//            
//        }else {
//            for item in selectedModelImages {
//                if let imageItem = item as? RejectDetailModelImages {
//                    self.showImageCollectionView.imageDatas.append(imageItem.imagePath ?? "")
//                }
//                if let image = item as? UIImage {
//                    self.showImageCollectionView.imageDatas.append(image)
//                }
//            }
//            for item in selectedPHAssets {
//                
//                let option = PHImageRequestOptions()
//                option.isSynchronous = true
//                PHCachingImageManager.default().requestImageData(for: item, options: option) { [weak self] (data, type, orientation, info) in
//                    guard let data = data, let type = type, let self = self else { return }
//                    var image: UIImage!
//                    if type == kUTTypeGIF as String {
//                        image = UIImage.gif(data: data)
//                    } else {
//                        image = UIImage(data: data)
//                    }
////                    image.TSImageMIMEType = type
//                    self.showImageCollectionView.imageDatas.append(image)
////                    payinfos.append(item.payInfo)
//                }
//            }
//            
//            let pi: UIImage? = (selectedPHAssets.count + selectedModelImages.count) < maxPhotoCount ? UIImage(named: "IMG_edit_photo_frame") : nil
//            if let pi = pi {
//                self.showImageCollectionView.imageDatas.append(pi)
//            }
//            self.showImageCollectionView.imagePHAssets = self.selectedPHAssets
//            self.showImageCollectionView.shoudSetPayInfo = self.isOpenImgsPay
//            self.showImageCollectionView.reloadData()
//            self.calculationCollectionViewHeight()
//        }
//    }
//    
//    // MARK: - 点击了相册按钮
//    func didSelectCell(index: Int) {
//        textViewResignFirstResponder()
//        
//        AuthorizeStatusUtils.checkAuthorizeStatusByType(type: .cameraAlbum, viewController: self, completion: {
//            DispatchQueue.main.async {
//                self.currentIndex = index
//                if self.isFromShareExtension {
//                    if index + 1 > self.postPhotoExtension.count { // 点击了相册选择器,进入图片查看器
//                        self.showCameraVC(true, selectedAssets: self.selectedPHAssets) { [weak self] (assets, _, _, _, _) in
//                            for asset in assets {
//                                let manager = PHImageManager.default()
//                                let options = PHImageRequestOptions()
//                                
//                                options.version = .original
//                                options.isSynchronous = true
//                                manager.requestImageData(for: asset, options: options) { data, uti, _, _ in
//                                    if let data = data {
//                                        self?.postPhotoExtension.append(PostPhotoExtension(data: data as Data, type: uti))
//                                    }
//                                }
//                            }
//                            self?.setShowImages()
//                        }
//                    } else {
//                        if self.isOpenImgsPay == true {
//                            self.editPhotoVC(asset: nil, photo: self.postPhotoExtension[index])
//                            //openImgsPayEnterPreViewVC(index: index)
//                        } else {
//                            self.editPhotoVC(asset: nil, photo: self.postPhotoExtension[index])
//                            //closeImgsPayEnterPreViewVC(index: index)
//                        }
//                    }
//                } else {
//                    if index + 1 > (self.selectedPHAssets.count + self.selectedModelImages.count) { // 点击了相册选择器,进入图片查看器
//                        self.showCameraVC(true, selectedAssets: self.selectedPHAssets, selectedImages: self.selectedModelImages) { [weak self] (assets, _, _, _, _) in
//                            self?.selectedPHAssets = assets
//                            self?.setShowImages()
//                        }
//                    } else {
//                        if index < self.selectedModelImages.count {
//                            if let imageModel = self.selectedModelImages[index] as? RejectDetailModelImages {
//                                self.editPhotoVC(imageURL: imageModel.imagePath ?? "", photo: nil)
//                            }
//                            if let image = self.selectedModelImages[index] as? UIImage {
//                                self.editPhotoVC(image: image, photo: nil)
//                            }
//                        } else {
//                            if self.isOpenImgsPay == true {
//                                self.editPhotoVC(asset: self.selectedPHAssets[index - self.selectedModelImages.count], photo: nil)
//                               
//                            } else {
//                                self.editPhotoVC(asset: self.selectedPHAssets[index - self.selectedModelImages.count], photo: nil)
//                           
//                            }
//                        }
//                        //                if self.isOpenImgsPay == true {
//                        //                    editPhotoVC(asset: self.selectedPHAssets[index], photo: nil)
//                        //                    //openImgsPayEnterPreViewVC(index: index)
//                        //                } else {
//                        //                    editPhotoVC(asset: self.selectedPHAssets[index], photo: nil)
//                        //                    //closeImgsPayEnterPreViewVC(index: index)
//                        //                }
//                    }
//                }
//            }
//        })
//    }
//
//    func didTapDeleteImageBtn(btn: UIButton) {
//        let index = btn.tag
//        releaseButton.isEnabled = true
//        if isFromShareExtension {
//            if postPhotoExtension.count > index {
//                postPhotoExtension.remove(at: index)
//            }
//            
//            if postPhotoExtension.count == 0 {
//                textViewResignFirstResponder()
//                self.navigationController?.dismiss(animated: true, completion: nil)
//                return
//            }
//        } else {
//            if index < selectedModelImages.count {
//                self.selectedModelImages.remove(at: index)
//            } else {
//                if selectedPHAssets.count > index - selectedModelImages.count {
//                    selectedPHAssets.remove(at: index - selectedModelImages.count)
//                }
//            }
//            if selectedPHAssets.count == 0 && !self.isFromEditFeed {
//                textViewResignFirstResponder()
//                self.navigationController?.dismiss(animated: true, completion: nil)
//                return
//            }
//        }
//        if (selectedPHAssets.count + selectedModelImages.count) == 0 && self.isFromEditFeed {
//            releaseButton.isEnabled = false
//        }
//        
//        self.setShowImages()
//    }
//    @objc func emojiBtnClick() {
//        smileButton.isSelected = !smileButton.isSelected
//        if smileButton.isSelected {
//            isTapOtherView = false
//            contentTextView.resignFirstResponder()
//        } else {
//            contentTextView.becomeFirstResponder()
//        }
//    }
//    @objc func packUpKey() {
//        smileButton.isSelected = false
//        contentTextView.resignFirstResponder()
//        UIView.animate(withDuration: 0.3) {
//            self.toolView.isHidden = true
//        }
//    }
//    
//    func editPhotoVC(asset: PHAsset?, photo: PostPhotoExtension?){
//        var image: UIImage!
//        
//        if isFromShareExtension {
//            guard let data = photo?.data, let type = photo?.type else { return }
//            if type == kUTTypeGIF as String {
//                image = UIImage.gif(data: data)
//            } else {
//                image = UIImage(data: data)
//            }
//        } else {
//            guard let asset = asset else { return }
//            let option = PHImageRequestOptions()
//            option.isSynchronous = true
//            PHCachingImageManager.default().requestImageData(for: asset, options: option) { [weak self] (data, type, orientation, info) in
//                guard let data = data, let type = type, let self = self else { return }
//                if type == kUTTypeGIF as String {
//                    image = UIImage.gif(data: data)
//                } else {
//                    image = UIImage(data: data)
//                }
//                
//            }
//        }
//        DispatchQueue.main.async{
//            if let photoEditor = TGAppUtil.shared.createPhotoEditor(for: image) {
//                photoEditor.photoEditorDelegate = self
//                self.present(photoEditor.fullScreenRepresentation, animated: true, completion: nil)
//            }
//        }
//    }
//    func editPhotoVC(image: UIImage?, photo: PostPhotoExtension?){
//        
//        DispatchQueue.main.async{
//            if let photoEditor = TGAppUtil.shared.createPhotoEditor(for: image) {
//                photoEditor.photoEditorDelegate = self
//                self.present(photoEditor.fullScreenRepresentation, animated: true, completion: nil)
//            }
//        }
//    }
//    func editPhotoVC(imageURL: String?, photo: PostPhotoExtension?){
//        
//        guard let imageURL = URL(string: imageURL ?? "") else {
////            printIfDebug("Failed to load image data from URL")
//            return
//        }
//        
//        DispatchQueue.global().async {
//            guard let imageData = try? Data(contentsOf: imageURL) else {
////                printIfDebug("Failed to load image data from URL")
//                return
//            }
//            
//            guard let image = UIImage(data: imageData) else {
////                printIfDebug("Failed to create UIImage from image data")
//                return
//            }
//            
//            DispatchQueue.main.async {
//                if let photoEditor = TGAppUtil.shared.createPhotoEditor(for: image) {
//                    photoEditor.photoEditorDelegate = self
//                    self.present(photoEditor.fullScreenRepresentation, animated: true, completion: nil)
//                }
//            }
//        }
//    }
//    // 按钮点击事件处理
//    @objc func expandCollapseButtonTapped(_ sender: UIButton) {
//        sender.isSelected = !sender.isSelected
//        
//        if sender.isSelected {
//            self.contentTextViewHeight.constant = self.currentKbH == 0 ? 300 : self.currentKbH // 高度设置为展开状态时的高度
//            let newHeight = ScreenHeight - self.currentKbH - TSNavigationBarHeight - TSBottomSafeAreaHeight - 90
//
//            UIView.animate(withDuration: 0.6,
//                           delay: 0,
//                           usingSpringWithDamping: 0.6,
//                           initialSpringVelocity: 0.1,
//                           options: .curveEaseInOut,
//                           animations: {
//                self.contentTextViewHeight.constant = newHeight
//                self.view.layoutIfNeeded()
//            }, completion: nil)
//             self.contentTextView.becomeFirstResponder() // 打开键盘
//         } else {
//             self.contentTextViewHeight.constant = 150 // 收起时的高度
//             self.contentTextView.resignFirstResponder() // 关闭键盘
//         }
//    }
//}
//
//
