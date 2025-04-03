//
//  SocialPostMessageCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/8.
//

import UIKit
import SDWebImage
import NIMSDK

class SocialPostMessageCell: BaseMessageCell {

    lazy var displayImage: SDAnimatedImageView = {
        let view = SDAnimatedImageView()
        view.image = UIImage(named: "default_image")
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var playImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "ico_video_play_list")
        return view
    }()
    
    lazy var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        return view
    }()
    
    lazy var liveLabel: UILabel = {
        let label = UILabel()
        label.font = TGAppTheme.Font.regular(TGFontSize.defaultTextFontSize)
        label.textColor = .white
        label.backgroundColor = .red
        label.text = "text_live".localized
        label.numberOfLines = 1
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    lazy var dataView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12.0, weight: .semibold)
        label.textColor = UIColor(hex: 0x242424)
        label.text = ""
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 2
        return label
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10.0, weight: .regular)
        label.textColor = UIColor(hex: 0x808080)
        label.text = ""
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    lazy var contentLabel: ActiveLabel = {
        let infoLbl = ActiveLabel()
        infoLbl.font = TGAppTheme.Font.regular(TGFontSize.defaultFontSize)
        infoLbl.textColor = .black
        infoLbl.text = ""
        infoLbl.textAlignment = .left
        infoLbl.numberOfLines = 0
        infoLbl.enabledTypes = [.mention, .hashtag, .url]
        infoLbl.mentionColor = TGAppTheme.primaryColor
        infoLbl.URLColor = TGAppTheme.primaryBlueColor
        return infoLbl
    }()
    
    let socialPostStackView = UIStackView().configure { (stack) in
        stack.axis = .horizontal
        stack.spacing = 5
    }
    
    lazy var backView: UIView = {
        let view = UIView()
        view.roundCorner(10)
        return view
    }()
    
    let labelView = UIView()
    
    var attachment: IMSocialPostAttachment!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupUI(){
        
        bubbleImage.addSubview(backView)
        bubbleImage.addSubview(contentLabel)
        bubbleImage.addSubview(timeTickStackView)
        
        dataView.addSubview(displayImage)
        dataView.addSubview(loadingView)
        dataView.addSubview(playImage)
        dataView.addSubview(liveLabel)
        
        labelView.addSubview(titleLabel)
        labelView.addSubview(infoLabel)
        
        socialPostStackView.addArrangedSubview(dataView)
        socialPostStackView.addArrangedSubview(labelView)
        
        backView.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.top.right.equalToSuperview().inset(10)
        }
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.right.equalTo(-10)
            make.top.equalTo(backView.snp.bottom).offset(8)
        }
        timeTickStackView.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.top.equalTo(contentLabel.snp.bottom).offset(8)
            make.bottom.equalTo(-10)
        }
        
        displayImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        playImage.snp.makeConstraints { make in
            make.width.height.equalTo(42)
            make.center.equalToSuperview()
        }
        
        liveLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(5)
            make.top.equalToSuperview().inset(5)
            make.width.equalTo(liveLabel.width + 8)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
        }
        
        dataView.snp.makeConstraints { make in
            make.width.equalTo(119)
            make.height.equalTo(86)
        }
        
        labelView.snp.makeConstraints { make in
            make.width.equalTo(131)
            make.height.equalTo(86)
        }
        backView.addSubview(socialPostStackView)
        socialPostStackView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        
    }
    
    override func setData(model: TGMessageData) {
        super.setData(model: model)
        guard let message = model.nimMessageModel, let attachment = model.customAttachment as? IMSocialPostAttachment else { return }
        self.attachment = attachment
        backView.backgroundColor = !message.isSelf ? UIColor(hex: 0xf9f9f9) : UIColor(hex: 0xeef8ff)
        backView.applyBorder(color: !message.isSelf ? UIColor(hex: 0xeaeaea) : UIColor(hex: 0xaee0ff), width: 1)
        labelView.backgroundColor = !message.isSelf ? UIColor(hex: 0xf9f9f9) : UIColor(hex: 0xeef8ff)
        
        self.loadingView.startAnimating()
        //displayImage.isHidden = !self.needShowImage()
        liveLabel.isHidden = !self.isLiveVideo()
        playImage.isHidden = !self.isVideo()
        infoLabel.isHidden = self.isDescNil()

        if isMetaData() {
            infoLabel.isHidden = false
            titleLabel.isHidden = false
            displayImage.isHidden = false
        }
        
        titleLabel.text = attachment.postUrl
        
        guard let decodedUrl = attachment.postUrl.removingPercentEncoding else {
            return
        }
        
        if let localExt = message.localExtension?.toDictionary, let title = localExt["title"] as? String, let desc = localExt["description"] as? String, let image = localExt["image"] as? String {
            self.updateUIWithContent(image: image, title: title.count > 0 ? title : attachment.postUrl, desc: desc, content:decodedUrl)
        } else {
            if attachment.imageURL != "" || attachment.title != "" || attachment.desc != "" {
                
                HTMLManager.shared.removeHtmlTag(htmlString: attachment.desc, completion: { [weak self] (content, _) in
                    guard let self = self else { return }
                    self.updateUIWithContent(image: attachment.imageURL, title: attachment.title, desc: content, content:decodedUrl)
                })
            } else {
                TGURLParser.parse(attachment.postUrl, completion: { title, description, imageUrl in
                    DispatchQueue.main.async {
                        self.updateUIWithContent(image: imageUrl, title: title, desc: description, content:decodedUrl)
                        let localExtension = ["title":title,
                                        "description":description,
                                              "image":imageUrl].toJSON ?? ""
                        NIMSDK.shared().v2MessageService.updateMessageLocalExtension(message, localExtension: localExtension) { _ in
                            
                        }
                    }
                })
            }
        }
    }
    
    private func updateUI(image: String, title: String, desc: String) {
        self.displayImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "default_image"), completed: nil)
        self.titleLabel.text = title
        self.infoLabel.text = desc
        self.contentLabel.isHidden = true
        self.loadingView.stopAnimating()
    }
    
    private func updateUIWithContent(image: String, title: String, desc: String, content: String) {
        self.displayImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "default_image"), completed: nil)
        self.titleLabel.text = title
        self.infoLabel.text = desc
        self.contentLabel.isHidden = false
        
        self.loadingView.stopAnimating()
        if attachment.contentDescribed.count > 0 {
            self.contentLabel.text = attachment.contentDescribed + "\n" + content
        } else {
            self.contentLabel.text = content
        }
    }
    
    
    private func isLiveVideo() -> Bool {
        if attachment.contentType == "live" {
            return true
        } else {
            return false
        }
    }

    private func isDescNil() -> Bool {
        if (attachment.desc == "") && attachment.postUrl.lowercased().contains("yippi") {
            return true
        } else {
            return false
        }
    }
    
    private func needShowImage() -> Bool {
        if attachment.postUrl.lowercased().contains("yippi") && (attachment.imageURL == "") {
            return false
        } else {
            return true
        }
    }

    private func isMetaData() -> Bool {
        if (attachment.title == "") && (attachment.desc == "") && (attachment.imageURL == "") {
            return true
        } else {
            return false
        }
    }

    private func isVideo() -> Bool {
        if attachment.contentType == "dynamic_video" {
            return true
        } else {
            return false
        }
    }
}
