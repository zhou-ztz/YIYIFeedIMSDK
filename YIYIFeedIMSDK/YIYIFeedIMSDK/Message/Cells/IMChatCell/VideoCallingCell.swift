//
//  VideoCallingCell.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/12.
//

import UIKit
import NIMSDK

class VideoCallingCell: BaseMessageCell {
    
    lazy var callImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.set_image(named: "icon_voice_call")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.text = ""
        label.numberOfLines = 1
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        bubbleImage.addSubview(callImageView)
        bubbleImage.addSubview(infoLabel)
        bubbleImage.addSubview(timeTickStackView)
        callImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.width.height.equalTo(20)
            make.left.equalTo(10)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(callImageView.snp.right).offset(8)
        }
        timeTickStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(infoLabel.snp.right).offset(8)
            make.right.equalTo(-10)
        }
    }
    
    override func setData(model: TGMessageData) {
        super.setData(model: model)
        guard let attachment = model.customAttachment as? IMCallingAttachment else { return }
        
        var image = ""
        var text = "unknown_message".localized
        if attachment.callType == .SIGNALLING_CHANNEL_TYPE_VIDEO {
            image = "icon_video_call"
        }else {
            image = "icon_voice_call"
        }
        callImageView.image = UIImage.set_image(named: image)
        text = netcallFormatedMessage(attachment.eventType, duration: attachment.duration)
        infoLabel.text = text
    }
    
    func netcallFormatedMessage(_ eventType: CallingEventType, duration: TimeInterval) -> String {
        var text = "unknown_message".localized
        switch eventType {
        case .miss:
            text = "chatroom_miss_call".localized
        case .bill:
            text = "text_duration".localized
            let durationDesc = String(format: " %02d:%02d", Int(duration) / 60, Int(duration) % 60)
            text = text + durationDesc
        case .reject:
            text = "chatroom_rejected".localized
        case .noResponse:
            text = "chatroom_miss_call".localized

        }
        return text
    }

}
