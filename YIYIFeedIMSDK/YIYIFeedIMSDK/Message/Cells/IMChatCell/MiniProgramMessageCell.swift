//
//  MiniProgramMessageCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/14.
//

import UIKit

class MiniProgramMessageCell: BaseMessageCell {

    lazy var iconImage: UIImageView = {
        let iconImage = UIImageView()
        iconImage.contentMode = .scaleAspectFit
        iconImage.backgroundColor = .white
        return iconImage
    }()
    
    lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.systemFont(ofSize: TGFontSize.defaultLocationDefaultFontSize)
//        descriptionLabel.aut = true
        descriptionLabel.textColor = .gray
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.numberOfLines = 2
        descriptionLabel.backgroundColor = .clear
        return descriptionLabel
    }()
    
    lazy var tLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: TGFontSize.defaultTextFontSize, weight: .semibold)
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .black
        return titleLabel
    }()
    
    lazy var background: UIView = {
        let background = UIView()
        background.layer.masksToBounds = true
        background.backgroundColor = .white
        background.layer.borderColor = UIColor(hex: 0xaee0ff).cgColor
        background.layer.borderWidth = 1
        return background
    }()
    
    var socialShareContent: UIStackView!
    var shareDescContent: UIStackView!
    var imageCacheShare: UIImage!
    
    var attachment: IMMiniProgramAttachment!
    
    lazy var contentStackView: UIStackView = {
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        //contentStackView.distribution = .fill
        contentStackView.alignment = .leading;
        contentStackView.spacing = 3
        contentStackView.addArrangedSubview(self.tLabel)
        contentStackView.addArrangedSubview(self.descriptionLabel)
        return contentStackView
    }()
    
    lazy var mpTextLabel: UILabel = {
        let mpTextLabel = UILabel()
        mpTextLabel.lineBreakMode = .byTruncatingTail
        mpTextLabel.numberOfLines = 1
        mpTextLabel.textColor = TGAppTheme.blue
        mpTextLabel.font = UIFont.systemFont(ofSize: 14)
        let image = NSTextAttachment()
        image.image =  UIImage(named: "ic_chat_mini_program")
        image.bounds = CGRect(x: 0, y: 0, width: 12, height: 12)
        let imageStr = NSAttributedString(attachment: image)
        let fullStr = NSMutableAttributedString(string: "view_mini_program".localized)
        fullStr.insert(imageStr, at: 0)
        fullStr.insert(NSAttributedString(string: " "), at: 1)
        mpTextLabel.attributedText = fullStr
        return mpTextLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupUI() {
        background.backgroundColor = .white
        background.layer.masksToBounds = true
        background.layer.cornerRadius = 10
        
        bubbleImage.addSubview(background)
        bubbleImage.addSubview(timeTickStackView)
        self.background.addSubview(self.iconImage)
        self.background.addSubview(self.mpTextLabel)
        self.background.addSubview(self.contentStackView)
        background.snp.makeConstraints { make in
            make.left.top.equalTo(6)
            make.right.equalToSuperview().inset(10)
            make.width.equalTo(230)
        }
        timeTickStackView.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.top.equalTo(background.snp.bottom).offset(8)
            make.bottom.equalTo(-5)
        }

        self.iconImage.isHidden = false
        self.descriptionLabel.isHidden = true
        
        self.tLabel.sizeToFit()
       
        self.iconImage.snp.makeConstraints { (make) in
            make.leading.equalTo(0).offset(6)
            make.top.equalTo(0).offset(6)
            make.width.height.equalTo(60)
        }
        self.iconImage.layer.masksToBounds = true
        self.iconImage.layer.cornerRadius = 15
        self.iconImage.clipsToBounds = false

        self.descriptionLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(34)
        }
        self.descriptionLabel.numberOfLines = 2;
        self.descriptionLabel.sizeToFit()

        self.tLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(17)
        }

        self.contentStackView.snp.makeConstraints { (make) in
            make.top.equalTo(6)
            make.left.equalTo(72)
            make.height.equalTo(60)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        self.mpTextLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.iconImage.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(17)
            make.trailing.equalToSuperview()
            make.left.equalTo(6)
        }
    }
    
    
    override func setData(model: TGMessageData) {
        super.setData(model: model)
        guard let message = model.nimMessageModel, let attachment = model.customAttachment as? IMMiniProgramAttachment else { return }
        self.attachment = attachment
        background.layer.borderColor = message.isSelf ? UIColor(hex: 0xaee0ff).cgColor : UIColor(hex: 0xeaeaea).cgColor
        if !self.isDescNil() {
            self.descriptionLabel.isHidden = false
        }
        if self.isMP() {
            self.descriptionLabel.isHidden = false
            self.tLabel.isHidden = false
            self.iconImage.isHidden = false
        }
        
        if let localExt = message.localExtension?.toDictionary as? [String: String] {
            self.updateUI(title: localExt["title"] ?? "", image: localExt["image"] ?? "", desc: localExt["description"] ?? "")
        } else {
            self.updateUI(title: self.attachment.title, image: self.attachment.imageURL, desc: self.attachment.desc)
        }
    }
    
    func updateUI(title: String, image: String, desc: String) {
        DispatchQueue.main.async {
            self.iconImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "default_image"))
            self.tLabel.text = title
            self.descriptionLabel.text = desc
        }
    }
    
    func isDescNil() -> Bool {
        if self.attachment.desc == "" {
            return true
        } else {
            return false
        }
    }

    func isMP() -> Bool {
        if self.attachment.desc.isEmpty && self.attachment.imageURL.isEmpty && self.attachment.title.isEmpty {
            return true
        }
        return false
    }
}
