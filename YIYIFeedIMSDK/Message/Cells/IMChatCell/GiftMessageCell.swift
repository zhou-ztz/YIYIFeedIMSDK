//
//  GiftMessageCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/6/19.
//

import UIKit

class GiftMessageCell: BaseMessageCell {
    
    private lazy var displayImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "bg_gift01")
        view.contentMode = .scaleAspectFill
        return view
    }()
    private lazy var grayOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12.0, weight: .regular)
        label.textColor = UIColor(hex: 0x808080)
        label.text = ""
        return label
    }()
    
    private lazy var statusTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10.0, weight: .regular)
        label.textColor = UIColor(hex: 0x808080)
        label.text = ""
        return label
    }()
    
    private lazy var wholeStackView: UIStackView =  {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .trailing
        return stackView
    }()
    
    private lazy var dateStackView: UIStackView =  {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .trailing
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        bubbleImage.isHidden = true
        bubbleView.addSubview(wholeStackView)
        bubbleView.addSubview(dateStackView)
        wholeStackView.addArrangedSubview(titleLabel)
        wholeStackView.addArrangedSubview(displayImage)
 
        dateStackView.addArrangedSubview(statusTitleLabel)
        dateStackView.addArrangedSubview(timeTickStackView)
        
        wholeStackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        let giftViewWidth = ScreenWidth * 0.4
        let giftViewHeight = giftViewWidth * 1.4
        
        displayImage.snp.makeConstraints { make in
            make.width.equalTo(giftViewWidth)
            make.height.equalTo(giftViewHeight)
            make.left.right.equalTo(0)
        }
        
        dateStackView.snp.makeConstraints { make in
            make.top.equalTo(wholeStackView.snp.bottom).offset(6)
            make.bottom.equalToSuperview()
            make.right.equalTo(wholeStackView.snp.right)
        }
        
        displayImage.addSubview(grayOverlay)
        grayOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setData(model: TGMessageData) {
        super.setData(model: model)
        guard let message = model.nimMessageModel else { return }
        guard let attachment = model.customAttachment as? IMGiftAttachment else { return }
        
        self.titleLabel.text = "I sent you a surprise, check it out!"
        
        self.statusTitleLabel.text = ""
        if attachment.imageName == "" {
            attachment.imageName = "bg_gift01"
        }
        
        displayImage.image = UIImage(named: attachment.imageName)
        
        let localExt = model.nimMessageModel?.localExtension?.toDictionary
        let giftMessageStatusString = localExt?["gift_message_status"] as? String ?? ""
        let giftMessageStatus = GiftMessageStatus(rawValue: giftMessageStatusString) ?? .pending
        grayOverlay.isHidden = giftMessageStatus == .pending
        
        let showLeft = !message.isSelf
        if showLeft {
            wholeStackView.alignment = .leading
        } else {
            wholeStackView.alignment = .trailing
        }
       
        self.titleLabel.text = showLeft ? "rw_im_gift_msg_left".localized : "rw_im_gift_msg_right".localized
 
        switch giftMessageStatus {
        case .accepted:
            self.statusTitleLabel.text = showLeft ? "rw_im_gift_already_opened".localized : "rw_im_gift_already_accepted".localized
        case .rejected:
            self.statusTitleLabel.text = showLeft ? "rw_im_gift_already_opened".localized : "rw_im_gift_already_declined".localized
        case .expired:
            self.statusTitleLabel.text = showLeft ? "rw_im_gift_already_opened".localized : "rw_im_gift_already_expires".localized
        case .cancelled:
            self.statusTitleLabel.text = showLeft ? "rw_im_gift_already_revoked".localized : "rw_im_gift_already_cancelled".localized
        case .pending:
            self.statusTitleLabel.text = "rw_im_gift_expires_time".localized
        default:
            self.statusTitleLabel.text = ""
        }
    }

}
