//
//  EggMessageCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2024/12/26.
//

import UIKit

class EggMessageCell: BaseMessageCell {
    
    lazy var eggImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"egg_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = TGAppTheme.Font.semibold(12)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    lazy var clickToViewLabel: UILabel = {
        let label = UILabel()
        label.font = TGAppTheme.Font.regular(10)
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    lazy var redPacketLabel: UILabel = {
        let label = UILabel()
        label.font = TGAppTheme.Font.regular(12)
        label.textColor = .gray
        label.text = "rw_yippi_red_packet".localized
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xD9D9D9)

        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        bubbleImage.addSubview(eggImage)
        bubbleImage.addSubview(descriptionLabel)
        bubbleImage.addSubview(clickToViewLabel)
        bubbleImage.addSubview(redPacketLabel)
        bubbleImage.addSubview(lineView)
        bubbleImage.addSubview(timeTickStackView)
        eggImage.snp.makeConstraints { make in
            make.width.equalTo(68)
            make.height.equalTo(80)
            make.left.top.equalTo(7)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(28)
            make.left.equalTo(eggImage.snp.right).offset(5)
            make.right.equalTo(-10)
        }
        clickToViewLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(12)
            make.left.equalTo(eggImage.snp.right).offset(5)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(eggImage.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(1)
            make.width.equalTo(202)
        }
        
        redPacketLabel.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(5)
            make.bottom.equalTo(-6)
            make.left.equalTo(8)
            make.height.equalTo(14)
        }
        
        timeTickStackView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(5)
            make.bottom.equalTo(-6)
            make.right.equalTo(-8)
            make.height.equalTo(14)
        }
    }

    
    override func setData(model: TGMessageData) {
        super.setData(model: model)
        guard let attachment = model.customAttachment as? IMEggAttachment, let message = model.nimMessageModel else { return }

        if attachment.message != ""{
            self.descriptionLabel.text = attachment.message
        } else {
            self.descriptionLabel.text = "rw_red_packet_best_wishes".localized
        }
        self.clickToViewLabel.text = !message.isSelf ? "viewholder_redpacket_open".localized : "viewholder_redpacket_detail".localized
        
    }
}
