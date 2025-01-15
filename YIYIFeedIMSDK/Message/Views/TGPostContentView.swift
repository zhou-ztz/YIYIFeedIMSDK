//
//  TGPostContentView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/2.
//

import UIKit

class TGPostContentView: UIView {
    var stackView: UIStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.spacing = 3
        $0.distribution = .fill
        $0.alignment = .leading
    }
    lazy var imageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    var shadowView: UIView = UIView()
    
    lazy var bodyLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = RLColor.share.black3
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.numberOfLines = 1
        lab.text = "笑死"
        return lab
    }()
    lazy var postDescLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = RLColor.share.black3
        lab.font = UIFont.systemFont(ofSize: 14)
     
        return lab
    }()
    lazy var postContentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = RLColor.share.black3
        lab.font = UIFont.systemFont(ofSize: 14)

        return lab
    }()
    private var _model: TGmessagePopModel?
    var model: TGmessagePopModel? {
        set {
            _model = newValue
            guard let value = newValue else {
                return
            }
            bodyLabel.text = value.owner
            
            if value.content.isEmpty {
                postContentLabel.text = "feed_no_desc".localized
            } else {
                /// 活动分享
                if value.campaignContent.count > 0 {
                    if let attr = value.content.toHTMLString(size: "12", color: "#999999") {
                        postContentLabel.attributedText = attr
                    } else {
                        postContentLabel.text = value.content
                    }
                } else {
                    HTMLManager.shared.removeHtmlTag(htmlString: value.content, completion: { [weak self] (content, _) in
                        guard let self = self else { return }
                        postContentLabel.text = content.removeNewLineChar()
                    })
                }
            }
            
            postDescLabel.text = value.noteContent
            switch value.contentType {
            case .url:
                if let url = URL(string: value.content) {
                    postDescLabel.text = url.host
                }
            default: break
            }
            //if !value.coverImage.isEmpty {
            imageView.sd_setImage(with: URL(string: value.coverImage), placeholderImage: UIImage(named: "default_image"), completed: nil)
            //} else {
            //    imageView.makeHidden()
            //}
            updateUI()
        }
        
        get {
            return _model
        }
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(imageView)
        addSubview(stackView)
        stackView.addArrangedSubview(bodyLabel)
        stackView.addArrangedSubview(postDescLabel)
        stackView.addArrangedSubview(postContentLabel)
        
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalTo(72)
            make.height.equalTo(64)
        }
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(imageView.snp.right).offset(10)
        }
        bodyLabel.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
        }
        postDescLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
        }
        postContentLabel.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
        }
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        shadowView.layer.cornerRadius = 4
        shadowView.layer.borderColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0).cgColor
        shadowView.layer.borderWidth = 1
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.roundCorner(4)
        shadowView.backgroundColor = SmallColor().repostBackground
        bodyLabel.applyStyle(.bold(size: 14, color: TGAppTheme.black))
        postContentLabel.applyStyle(.regular(size: 12, color: NormalColor().minor))
        postDescLabel.applyStyle(.regular(size: 12, color: RLColor.main.theme))
        postDescLabel.numberOfLines = 2
        postContentLabel.numberOfLines = 2
        postContentLabel.lineBreakMode = .byTruncatingTail
        postDescLabel.lineBreakMode = .byWordWrapping
    }

    
    private func updateUI() {
        guard let model = _model else { return }
        switch model.contentType {
        case .url:
            bodyLabel.numberOfLines = 2
            bodyLabel.removeConstraints(bodyLabel.constraints)
            postContentLabel.isHidden = true
            postDescLabel.textColor = NormalColor().minor
        default:
            break
        }
        if model.content.isEmpty {
            postContentLabel.isHidden = true
            bodyLabel.removeConstraints(bodyLabel.constraints)
        }
        
        bodyLabel.isHidden = (bodyLabel.text ?? "").isEmpty
        postDescLabel.isHidden = (postDescLabel.text ?? "").isEmpty
        postContentLabel.isHidden = (postContentLabel.text ?? "").isEmpty
    }
}
