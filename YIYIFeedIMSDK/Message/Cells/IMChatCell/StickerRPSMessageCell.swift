//
//  StickerRPSMessageCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2024/12/24.
//

import UIKit
import NIMSDK
import SDWebImage

class StickerRPSMessageCell: BaseMessageCell {
    
    lazy var stickerImageView: EmojiImageView = {
        let imageView = EmojiImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        bubbleView.addSubview(stickerImageView)
        bubbleView.addSubview(timeTickStackView)
        stickerImageView.snp.makeConstraints { make in
            make.width.height.equalTo(115)
            make.centerX.equalToSuperview()
            make.leading.right.top.equalToSuperview().inset(8)
        }
        timeTickStackView.snp.makeConstraints { make in
            make.right.bottom.equalTo(-8)
            make.top.equalTo(stickerImageView.snp.bottom).offset(5)
        }
    }
    
    override func setData(model: TGMessageData) {
        super.setData(model: model)
        if let attachment = model.customAttachment as? IMStickerAttachment {
            if attachment.chartletId.hasPrefix("http://") || attachment.chartletId.hasPrefix("https://") {
                gifDisplay(attachment)
            } else {
                self.stickerImageView.image = UIImage()
            }
        } else if let attachment = model.customAttachment as? IMRPSAttachment {
            self.stickerImageView.image = rpsImage(attachment)
        }
    }
    
    func gifDisplay(_ attachment: IMStickerAttachment) {
        self.stickerImageView.image = nil
        self.stickerImageView.imageUrl = URL(string: attachment.chartletId) as NSURL?
        self.stickerImageView.sd_setImage(with: URL(string: attachment.chartletId), completed: nil)
        self.stickerImageView.sd_imageIndicator = self.sd_imageIndicator
        self.stickerImageView.shouldCustomLoopCount = true
        self.stickerImageView.animationRepeatCount = 0
    }
    
    func rpsImage(_ attachment: IMRPSAttachment) -> UIImage? {
        var image: UIImage?
        let rpsValue = CustomRPSValue(rawValue: attachment.value)
        switch rpsValue {
        case .Scissor:
            image = UIImage.set_image(named: "custom_msg_jan")
        case .Rock:
            image = UIImage.set_image(named: "custom_msg_ken")
        case .Paper:
            image = UIImage.set_image(named: "custom_msg_pon")
        default:
            break
        }
        return image
    }
    
}
class EmojiImageView: SDAnimatedImageView {
    var imageUrl: NSURL?
}
