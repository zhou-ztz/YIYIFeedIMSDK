//
//  FeedDetailTableHeaderView.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/29.
//

import UIKit
import AVFoundation

class FeedDetailTableHeaderView: UIView {
    
    var deleteStatusClickCall: (() -> ())?
    var mediaViewClickCall: (() -> ())?
    var onTranslated: TGEmptyClosure?
    var onTapPictureClickCall: ((Int, String) -> ())?
    
    // views
    var contentView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 10
        stack.backgroundColor = .white
        
        return stack
    }()
    
    public let headerStackView: UIStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.spacing = 5
    }

    private let deleteButton: UIButton = {
        let button = UIButton(type: .custom)
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
  
    private var currentPrimaryButtonState: SocialButtonState = .follow
    
    //动态图片/视频view
    private var mediaContentView: UIView = UIView()
    
    var imagesSliderView: FeedImageSliderView = FeedImageSliderView()
    
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
        
        self.deleteButton.addAction {
            self.deleteStatusClickCall?()
        }
        
        self.imagesSliderView.onImageTap = { index in
            let transitionId = UUID().uuidString
            self.onTapPictureClickCall?(index, transitionId)
        }
    }
    
    public func setData(model: FeedListCellModel){
        
        originalTexts = model.content
        contentLabel.text = model.content
        
        loadTranslateButton(feedId: model.idindex.stringValue)
        let viewCountLabel = "\((model.toolModel?.viewCount).orZero) \("number_of_browsed".localized) "
        var feedDate = ""
        
        if let timeModel = model.time {
            let timeStamp = timeModel.timeAgoDisplay(dateFormat: "MMMM dd")
            feedDate = timeStamp
        }
        viewAndDateLabel.text = viewCountLabel + " • " + feedDate + " • "
        
        imagesSliderView.set(imageUrls: model.pictures.map{ image in
            let apiBaseURL = RLSDKManager.shared.loginParma?.apiBaseURL ?? ""
            let downloadFileUrl = "api/v2/files/"
            let fileId = image.file.stringValue
            return apiBaseURL + downloadFileUrl + fileId
        })
        
        commentLabel.text  =  "0" + "comment_counts".localized
        
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
