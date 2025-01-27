//
//  FeedDetailTableHeaderView.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/29.
//

import UIKit
import AVFoundation

class FeedDetailTableHeaderView: UIView {
    
    var followStatusClickCall: (() -> ())?
    var deleteStatusClickCall: (() -> ())?
    var mediaViewClickCall: (() -> ())?
    var onTranslated: EmptyClosure?
    var onTapPictureClickCall: (() -> ())?
    
    // views
    private var contentView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 10
        stack.backgroundColor = .white
        
        return stack
    }()
    
    let headerStackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 5
    }
    
    var avatarView: AvatarUserNameView = AvatarUserNameView(frame: .zero, avatarWidth: 40.0)
    
    private let followButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("关注", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.backgroundColor = .white
        button.roundCorner(10)
        return button
    }()
    
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("删除", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.backgroundColor = .white
        button.roundCorner(10)
        button.applyBorder(color: .black, width: 1)
        button.isHidden = true
        return button
    }()
    
    private var originalTexts: String = ""
    private var translatedTexts: String = ""
    
    //动态图片/视频view
    private var mediaContentView: UIView = UIView()
    
    private var imagesSliderView: FeedImageSliderView = FeedImageSliderView()
    
    private let feedVideoIcon = UIImageView().configure {
        $0.image = UIImage(named: "ic_feed_video_icon")
    }
    
    lazy var contentLabel: ActiveLabel = {
        let lab = ActiveLabel()
        lab.textColor = .black
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.numberOfLines = 0
        lab.text = "-"
        return lab
    }()
    
    let viewsDateTranslateStackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 5
    }
    
    lazy var viewAndDateLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .lightGray
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.numberOfLines = 1
        lab.text = ""
        return lab
    }()
    private var translateButton: LoadableButton = LoadableButton(frame: .zero, icon: nil,
                                                                 text: "text_translate".localized, textColor: RLColor.share.theme,
                                                                 font: UIFont.systemMediumFont(ofSize: 12), bgColor: .clear, cornerRadius: 0,
                                                                 withShadow: false)
    
    private let commentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .lightGray
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.numberOfLines = 1
        lab.text = ""
        return lab
    }()
    
    
    private let commentCountWrapperView: UIStackView = {
        let stack = UIStackView()
        stack.backgroundColor = .white
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .leading
        
        return stack
    }()
    var userIdList: [String] = []
    var htmlAttributedText: NSMutableAttributedString?
    init() {
        super.init(frame: .zero)
        setupUI()
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.snp.makeConstraints { (m) in
            m.width.equalTo(UIScreen.main.bounds.width)
        }
        self.backgroundColor = .white
        
        translateButton.setTitleColor(UIColor(hex: RLSDKManager.shared.loginParma?.themeColor ?? 0x000000), for: .normal)
        
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(10)
        }
        
        contentView.addArrangedSubview(headerStackView)
        headerStackView.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        headerStackView.addArrangedSubview(avatarView)
        self.addSubview(followButton)
        followButton.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(28)
            make.centerY.equalTo(headerStackView)
            make.right.equalToSuperview().inset(10)
        }
        
        self.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.edges.equalTo(followButton)
        }
        
        
        contentView.addArrangedSubview(mediaContentView)
        mediaContentView.snp.makeConstraints { make in
            make.height.equalTo(350)
        }
        mediaContentView.addAction {
            self.mediaViewClickCall?()
        }
        
        mediaContentView.addSubview(imagesSliderView)
        feedVideoIcon.isHidden = true
        mediaContentView.addSubview(feedVideoIcon)
        
        imagesSliderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        feedVideoIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        contentView.addArrangedSubview(contentLabel)
        
        contentView.addArrangedSubview(viewsDateTranslateStackView)
        viewsDateTranslateStackView.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        viewsDateTranslateStackView.addArrangedSubview(viewAndDateLabel)
        viewsDateTranslateStackView.addArrangedSubview(translateButton)
        viewsDateTranslateStackView.addArrangedSubview(UIView())
        
        contentView.addArrangedSubview(commentCountWrapperView)
        commentCountWrapperView.addArrangedSubview(commentLabel)
        let bottomMarginview = UIView()
        bottomMarginview.snp.makeConstraints { make in
            make.height.equalTo(10)
        }
        commentCountWrapperView.addArrangedSubview(bottomMarginview)
        self.followButton.addAction {
            self.followStatusClickCall?()
        }
        self.deleteButton.addAction {
            self.deleteStatusClickCall?()
        }
        self.imagesSliderView.addAction {
            self.onTapPictureClickCall?()
        }
    }
    
    public func setData(data: TGFeedResponse){
        
        originalTexts = data.feedContent ?? ""
        contentLabel.text = data.feedContent ?? ""
        
        avatarView.setData(data: data)
        loadTranslateButton(feedId: data.id?.stringValue ?? "")
        let viewCountLabel = "\(data.feedViewCount ?? 0) \("number_of_browsed".localized) "
        var feedDate = ""
      
        if let timeModel = data.updatedAt?.toBdayDate(by: "yyyy-MM-dd HH:mm:ss") {
            let timeStamp = timeModel.timeAgoDisplay()
            feedDate = timeStamp
        }
        viewAndDateLabel.text = viewCountLabel + " • " + feedDate + " • "
        
       
        if let images = data.images {
            imagesSliderView.set(imageUrls: images.map{ image in
                let apiBaseURL = RLSDKManager.shared.loginParma?.apiBaseURL ?? ""
                let downloadFileUrl = "api/v2/files/"
                let fileId = "\(image.file ?? 0)"
                return apiBaseURL + downloadFileUrl + fileId
            })
        }
    
        
        commentLabel.text  =  "0" + "comment_counts".localized
        
//        if data.isFans == 1 {
//            //已关注
//            self.followButton.setTitle("已关注", for: .normal)
//            self.followButton.setTitleColor(SCColor.share.backGroundGray, for: .normal)
//            self.followButton.backgroundColor = SCColor.share.lightGray
//            self.followButton.applyBorder(color: .clear, width: 1)
//            
//        }else if data.isFans == 0 {
//            //未关注
//            self.followButton.setTitle("未关注", for: .normal)
//            self.followButton.setTitleColor(SCColor.share.themeRed, for: .normal)
//            self.followButton.backgroundColor = .white
//            self.followButton.applyBorder(color: SCColor.share.themeRed, width: 1)
//        }
//        if data.author?.uid == SCCurrentUserInfo.shared.uid {
//            //是自己的账户
//            self.followButton.isHidden = true
//            self.deleteButton.isHidden = false
//        }
    }
    func setCommentLabel(count: Int?, isCommentDisabled: Bool) {
        if let count = count, count > 0 && isCommentDisabled == false {
            commentCountWrapperView.makeVisible()
            commentLabel.text = count.abbreviated + "comment_counts".localized
        } else {
            commentCountWrapperView.makeHidden()
        }
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
    
    private func loadTranslateButton(feedId: String) {
        
        translateButton.setTitle("button_original".localized, for: .selected)
        translateButton.setTitle("text_translate".localized, for: .normal)
        
        // By Kit Foong (Added checking when no text or only emoji will hide translate button)
        translateButton.isHidden = self.originalTexts.isEmpty || self.originalTexts.containsOnlyEmoji
        translateButton.addTap { [weak self] (button) in
            guard let self = self, let button = button as? LoadableButton else { return }
            guard button.isSelected == false else {
                self.htmlAttributedText = self.originalTexts.attributonString().setTextFont(14).setlineSpacing(0)
                if let attributedText = self.htmlAttributedText {
                    self.htmlAttributedText = HTMLManager.shared.formAttributeText(attributedText, userIdList)
                }
                self.contentLabel.attributedText = self.htmlAttributedText
                //self.primaryLabel.text = self.originalTexts
                button.isSelected = false
                self.onTranslated?()
                return
            }
            
            button.showLoader(userInteraction: false)
            
            TGFeedNetworkManager.shared.translateFeed(feedId: feedId.toInt()) { [weak self] (translates, msg, status) in
                guard let self = self else { return }
                defer { button.hideLoader() }
                if status == true {
                    button.isSelected = true
                    self.translatedTexts = translates ?? ""
                    self.contentLabel.text = translates
                }else {
                    print("msg : \(String(describing: msg))")
                }
          
                self.onTranslated?()
            }
        }
    }
    
}
