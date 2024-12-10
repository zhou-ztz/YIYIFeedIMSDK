//
//  AudioMessageCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/5.
//

import UIKit
import NIMSDK

class AudioMessageCell: BaseMessageCell {
    
    var messageId: String?
    var isPlaying: Bool = false

    var audioImageViewLeft = UIImageView(image: UIImage.set_image(named: "left_audio_3"))
    var timeLabelLeft: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = RLColor.share.black3
        label.text = "未知消息类型"
        label.numberOfLines = 1
        return label
    }()

    var audioImageViewRight = UIImageView(image: UIImage.set_image(named: "right_audio_3"))
    var timeLabelRight: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = RLColor.share.black3
        label.text = "未知消息类型"
        label.numberOfLines = 1
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      commonUI()
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func commonUI() {
        bubbleImage.addSubview(audioImageViewLeft)
        bubbleImage.addSubview(timeLabelLeft)
        bubbleImage.addSubview(audioImageViewRight)
        bubbleImage.addSubview(timeLabelRight)
        audioImageViewRight.animationDuration = 1
        audioImageViewLeft.animationDuration = 1
        if let image1 = UIImage.set_image(named: "left_audio_1"),
           let image2 = UIImage.set_image(named: "left_audio_2"),
           let image3 = UIImage.set_image(named: "left_audio_3") {
          audioImageViewLeft.animationImages = [image1, image2, image3]
        }
        
        if let image1 = UIImage.set_image(named: "right_audio_1"),
           let image2 = UIImage.set_image(named: "right_audio_2"),
           let image3 = UIImage.set_image(named: "right_audio_3") {
          audioImageViewRight.animationImages = [image1, image2, image3]
        }
        self.bubbleImage.layoutIfNeeded()
    }
    
    open func startAnimation(byRight: Bool) {
        if byRight {
            if !audioImageViewRight.isAnimating {
                audioImageViewRight.startAnimating()
            }
        } else if !audioImageViewLeft.isAnimating {
            audioImageViewLeft.startAnimating()
        }
        if let m = contentModel {
            m.isPlaying = true
            isPlaying = true
        }
        
    }
    
    open func stopAnimation(byRight: Bool) {
        if byRight {
            if audioImageViewRight.isAnimating {
                audioImageViewRight.stopAnimating()
            }
        } else if audioImageViewLeft.isAnimating {
            audioImageViewLeft.stopAnimating()
        }
        if let m = contentModel {
            m.isPlaying = false
            isPlaying = false
        }
    }
    
    func showLeftOrRight(showRight: Bool) {
      audioImageViewLeft.isHidden = showRight
      timeLabelLeft.isHidden = showRight

      audioImageViewRight.isHidden = !showRight
      timeLabelRight.isHidden = !showRight
    }

    
    override func setData(model: TGMessageData) {
        super.setData(model: model)
        guard let message = model.nimMessageModel, let audioObject = message.attachment as? V2NIMMessageAudioAttachment else { return }
        let isRight = message.isSelf
        showLeftOrRight(showRight: isRight)
        messageId = message.messageClientId
        
        if isRight {
            audioImageViewRight.snp.remakeConstraints { make in
                make.right.equalTo(-12)
                make.width.equalTo(26)
                make.height.equalTo(28)
                make.top.bottom.equalToSuperview().inset(8)
            }
           
            timeLabelRight.snp.remakeConstraints { make in
                make.left.equalTo(12)
                make.right.equalTo(audioImageViewRight.snp.left).offset(-18)
                make.centerY.equalToSuperview()
            }
            timeLabelRight.text = "\(audioObject.duration / 1000)" + "s"
        } else {
            audioImageViewLeft.snp.remakeConstraints { make in
                make.left.equalTo(12)
                make.width.equalTo(26)
                make.height.equalTo(28)
                make.top.bottom.equalToSuperview().inset(8)
            }
            timeLabelLeft.snp.remakeConstraints { make in
                make.right.equalTo(-12)
                make.left.equalTo(audioImageViewLeft.snp.right).offset(18)
                make.centerY.equalToSuperview()
            }
            timeLabelLeft.text = "\(audioObject.duration / 1000)" + "s"
        }
    }
}
