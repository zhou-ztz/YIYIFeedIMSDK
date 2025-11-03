//
//  TGRejectedDetailController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/4/1.
//

import UIKit

public class TGRejectedDetailController: TGViewController {

    public var onDelete: TGEmptyClosure?
    
    /// 动态id
    public var feedId: String = ""
    
    var rejectDetailModel: TGRejectDetailModel?
    
    private let imgBgView: UIView = UIView()
    
    private let titleWarningContainer = UIView().configure {
        $0.backgroundColor = .clear
    }
    
    private let paddingContainer = UIView().configure {
        $0.backgroundColor = .clear
    }
    
    private let titleView = UIView().configure {
        $0.backgroundColor = .clear
    }
    
    private lazy var readMoreLabel: TGTruncatableLabel = {
        return TGTruncatableLabel()
    }()
    
    private let labelForTitleIssue = UILabel().configure {
        $0.setFontSize(with: 14, weight: .norm)
        $0.textColor = UIColor(red: 0, green: 0, blue: 0)
        $0.numberOfLines = 0
    }
    
    private let titleIssueView: UIView = UIView().configure {
        $0.backgroundColor = UIColor(hex: 0xFCE1E1)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
        $0.isHidden = true
    }
    
    private let ruleBtn: UIButton = UIButton().configure {
        $0.setTitle("what_is_community_guidelines".localized, for: .normal)
        $0.setTitleColor(TGAppTheme.red, for: .normal)
        $0.set(font: .systemFont(ofSize: 14))
        $0.isHidden = true
    }
    
    private let editBtn: TGStickerDownloadButton = TGStickerDownloadButton().configure {
        $0.setTitle("edit".localized, for: .normal)
        $0.setTitleColor(TGAppTheme.red, for: .normal)
        $0.set(font: .systemFont(ofSize: 14))
    }
    
    private let deleteBtn: UIButton = UIButton().configure {
        $0.setTitle("delete".localized, for: .normal)
        $0.setTitleColor(TGAppTheme.red, for: .normal)
        $0.set(font: .systemFont(ofSize: 14))
    }
    
    private let rightBarStackView: UIStackView = UIStackView(frame: .zero).configure {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 20
        $0.contentCompressionResistancePriority = .required
    }
    
    private let titleStackView: UIStackView = UIStackView(frame: .zero).configure {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.spacing = 8
    }
    
    private var scrollView: UIScrollView = UIScrollView().configure {
        $0.showsVerticalScrollIndicator = false
        $0.isScrollEnabled = true
        $0.isHidden = true
    }
    
    private let imageSliderView: TGImageSliderView = TGImageSliderView.init(frame: CGRectMake(0, 0, ScreenWidth, 350))
    
    var htmlAttributedText: NSMutableAttributedString?
    
    // MARK: - Lifecycle
    public init(feedId: String) {
        super.init(nibName: nil, bundle: nil)
        self.feedId = feedId
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCloseButton(backImage: true, titleStr: "".localized)
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getData()
        // Do any additional setup after loading the view.
    }
    @objc func getData(){
        self.showLoading()
        TGFeedNetworkManager.shared.fetchFeedRejectDetail(withFeedId: feedId) {  [weak self] responseModel, error in
            guard let self = self else { return }
            defer {
                DispatchQueue.main.async {
                    self.dismissLoading()
                    self.scrollView.isHidden = false
                    self.ruleBtn.isHidden = false
                }
            }
            
            guard let responseModel = responseModel else {
                self.dismissLoading()
                self.scrollView.isHidden = false
                self.ruleBtn.isHidden = false
                self.navigationController?.popViewController(animated: true)
                return
            }
            self.rejectDetailModel = responseModel
            self.updateData(data: responseModel)
        }
        
    }
    private func updateData(data: TGRejectDetailModel?) {
        guard let data = data else { return }
        
        if let feedContent = data.textModel?.feedContent {
            titleStackView.isHidden = false
            HTMLManager.shared.removeHtmlTag(htmlString: feedContent, completion: { [weak self] (content, userIdList, merchantIdList, merchantAppIdList, merchantDealPathList) in
                guard let self = self else { return }
                self.htmlAttributedText = content.attributonString()
                if let attributedText = self.htmlAttributedText {
                    self.htmlAttributedText = HTMLManager.shared.formAttributeText(attributedText, userIdList, merchantIdList, merchantAppIdList, merchantDealPathList)
                    if self.readMoreLabel != nil { self.readMoreLabel.setAttributeText(attString: attributedText, textColor: .black, allowTruncation: true) }
                } else {
                    if self.readMoreLabel != nil { self.readMoreLabel.setText(text: content, textColor: .black, allowTruncation: true) }
                }
            })
        }
        // 显示违规原因内容
        if let sensitiveContent = data.textModel?.sensitiveType {
            labelForTitleIssue.text = sensitiveContent
            titleIssueView.isHidden = false
        }
        guard let video = data.video, let coverPath = video.coverPath, !coverPath.isEmpty else {
            guard !data.images.isEmpty else {
                imageSliderView.isHidden = true
                imgBgView.isHidden = true
                return
            }
            let pictures = data.images
            imageSliderView.isHidden = pictures.isEmpty
            imgBgView.isHidden = pictures.isEmpty
            imageSliderView.imageModels = pictures
            imageSliderView.placeholder = "ic_rejected_default"
            return
        }
        imageSliderView.isHidden = false
        imgBgView.isHidden = false
        
        imageSliderView.imageModels = [TGRejectDetailModelImages(fileId: video.coverId, imagePath: coverPath, isSensitive: video.isSensitive, sensitiveType: video.sensitiveType)]

    }
    
    private func setupUI() {
        
        self.backBaseView.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(-65)
        }
        //底部规则
        self.backBaseView.addSubview(ruleBtn)
        ruleBtn.addTap { [weak self] (v) in
            guard let self = self else { return }
            self.communityGuidelinesTapped()
        }
        ruleBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(-23)
        }
        
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.distribution = .fill
        mainStackView.spacing = 0
        scrollView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            // 设置高度约束，使其可以根据内容自动调整
            $0.bottom.equalToSuperview().offset(-8)
            $0.width.equalTo(scrollView.snp.width)
        }
        
        mainStackView.addArrangedSubview(imgBgView)
        mainStackView.addArrangedSubview(paddingContainer)
        mainStackView.addArrangedSubview(titleStackView)
        paddingContainer.snp.makeConstraints {
            $0.height.equalTo(11)
        }
        
        //======= cover =======
        imgBgView.snp.makeConstraints {
            $0.height.equalTo(350)
        }
        //Cover滑动视图
        imgBgView.addSubview(imageSliderView)
        imageSliderView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        //======= content 文字内容 =======
        let titleIssueStackView = UIStackView()
        titleIssueStackView.axis = .horizontal
        titleIssueStackView.distribution = .fill
        titleIssueStackView.spacing = 8
        titleIssueView.addSubview(titleIssueStackView)
        
        titleIssueStackView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(10)
            $0.trailing.bottom.equalToSuperview().offset(-10)
        }
        
        let warningImageView = UIImageView()
        warningImageView.image = UIImage(named: "ic_rejected_warning_icon")
        titleWarningContainer.addSubview(warningImageView)
        warningImageView.snp.makeConstraints {
            $0.size.equalTo(CGSizeMake(24, 24))
            $0.centerY.equalToSuperview()
        }
        
        titleIssueStackView.addArrangedSubview(titleWarningContainer)
        titleIssueStackView.addArrangedSubview(labelForTitleIssue)
        titleStackView.addArrangedSubview(titleView)
        
        if readMoreLabel != nil {
            titleView.addSubview(readMoreLabel)
            readMoreLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(5)
                $0.leading.equalToSuperview().offset(5)
                $0.trailing.equalToSuperview().offset(-5)
                $0.bottom.equalToSuperview().offset(-5)
            }
        }
        
        titleStackView.addArrangedSubview(titleIssueView)
        titleStackView.isHidden = true
        
        titleIssueView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
        }
        
        titleWarningContainer.snp.makeConstraints {
            $0.width.equalTo(30)
        }
        
        rightBarStackView.addArrangedSubview(editBtn)
        rightBarStackView.addArrangedSubview(deleteBtn)
        customNavigationBar.setRightViews(views: [editBtn, deleteBtn])
        
        //设定一次高度
        scrollView.layoutIfNeeded()
        scrollView.contentSize = mainStackView.frame.size
        if readMoreLabel != nil {
            readMoreLabel.setText(text: "")
            readMoreLabel.numberOfLines = 0
            readMoreLabel.aliasColor = TGAppTheme.primaryBlueColor
            readMoreLabel.hashTagColor = TGAppTheme.primaryBlueColor
            readMoreLabel.httpTagColor = TGAppTheme.primaryBlueColor
        }
        labelForTitleIssue.text = ""
        
        deleteBtn.addTap { [weak self] (_) in
            let alert = TGAlertController(title: "delete".localized, message: "delete_confirmation".localized, style: .alert, hideCloseButton: true, animateView: true, allowBackgroundDismiss: false)
            alert.addAction(TGAlertAction(title: "delete".localized, style: TGAlertActionStyle.default, handler: { _ in
                guard let self = self else { return }
                TGFeedNetworkManager.shared.deleteMoment(Int(self.feedId) ?? 0) { [weak self] result in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        self.onDelete?()
                    }
               
                }
            }))
            alert.addAction(TGAlertAction(title: "cancel".localized, style: TGAlertActionStyle.cancel, handler: { _ in
             
            }))
            self?.presentPopup(alert: alert)
        }
        
        editBtn.addTap { [weak self] (_) in
            guard let self = self, let rejectDetailModel = self.rejectDetailModel else { return }
            
            editBtn.showLoading()
            //被拒绝动态为视频动态
            if let video = rejectDetailModel.video, let videoPath = video.videoPath, let videoUrl = URL(string: videoPath) {
                // 创建一个表示网络视频文件的URL对象
                let asset = AVURLAsset(url: videoUrl)
                let coverImage = FileUtils.generateAVAssetVideoCoverImage(avAsset: asset)
                editBtn.hideLoading()
                let vc = TGReleasePulseViewController(type: .miniVideo)
                vc.shortVideoAsset = TGShortVideoAsset(coverImage: coverImage, asset: nil, videoFileURL: videoUrl)
                vc.isFromEditFeed = true
                vc.feedId = self.feedId
                vc.coverId = video.coverId
                vc.videoId = video.videoId
                vc.tagVoucher = rejectDetailModel.tagVoucher
                if let feedContent = rejectDetailModel.textModel?.feedContent {
                    vc.preText = feedContent
                }
                let navigation = TGNavigationController(rootViewController: vc).fullScreenRepresentation
                self.present(navigation, animated: true, completion: nil)
                return
            }
            if rejectDetailModel.images.count > 0 {
                editBtn.hideLoading()
                let vc = TGReleasePulseViewController(type: .photo)
                vc.selectedModelImages = rejectDetailModel.images
                if let feedContent = rejectDetailModel.textModel?.feedContent {
                    vc.preText = feedContent
                }
                vc.feedId = self.feedId
                vc.isFromEditFeed = true
                vc.tagVoucher = rejectDetailModel.tagVoucher
                
                let navigation = TGNavigationController(rootViewController: vc).fullScreenRepresentation
                self.present(navigation, animated: true, completion: nil)
                return
            }
            //被拒绝动态为纯文本
            if let feedContent = rejectDetailModel.textModel?.feedContent {
                self.editBtn.hideLoading()
                let vc = TGReleasePulseViewController(type: .photo)
                vc.preText = feedContent
                vc.feedId = self.feedId
                vc.isFromEditFeed = true
                
                let navigation = TGNavigationController(rootViewController: vc).fullScreenRepresentation
                self.present(navigation, animated: true, completion: nil)
            }
        }
        
    }
    
    @objc func communityGuidelinesTapped() {
        let webVC = TGWebViewController()
        webVC.urlString = WebViewType.communityGuidelines.urlString
        webVC.title = "community_guidelines".localized
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}
class TGStickerDownloadButton: UIButton {
    
    lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init() {
        super.init(frame: .zero)
        self.addSubview(indicator)
        indicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showLoading() {
        indicator.startAnimating()
        self.isUserInteractionEnabled = false
        self.alpha = 0.7
    }
    
    func hideLoading() {
        indicator.stopAnimating()
        self.isUserInteractionEnabled = true
        self.alpha = 1.0
    }
}
