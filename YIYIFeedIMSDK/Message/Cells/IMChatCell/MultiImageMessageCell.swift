//
//  MultiImageMessageCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/18.
//

import UIKit
import SDWebImage
import NIMSDK

class MultiImageMessageCell: BaseMessageCell {

    lazy var displayImage: SDAnimatedImageView = {
        let view = SDAnimatedImageView()
        view.contentMode = .scaleAspectFill
        view.roundCorner(5)
        view.backgroundColor = UIColor(hex: 0xF5F5F5)
        return view
    }()
    
    lazy var displayImage2: SDAnimatedImageView = {
        let view = SDAnimatedImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = UIColor(hex: 0xF5F5F5)
        view.roundCorner(5)
        return view
    }()
    
    lazy var displayImage3: SDAnimatedImageView = {
        let view = SDAnimatedImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = UIColor(hex: 0xF5F5F5)
        view.roundCorner(5)
        return view
    }()
    
    lazy var displayImage4: SDAnimatedImageView = {
        let view = SDAnimatedImageView()
        view.image = UIImage(named: "IMG_icon")
        view.contentMode = .scaleAspectFill
        view.roundCorner(5)
        return view
    }()
    
    lazy var displayImage4OverlayView: UIView = {
        let view = UIView()
        view.roundCorner(5)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        return view
    }()
    
    lazy var extraCountLabel: UILabel = {
        let label = UILabel()
        label.font = TGAppTheme.Font.bold(20)
        label.textColor = UIColor.white
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
        bubbleImage.addSubview(displayImage)
        bubbleImage.addSubview(displayImage2)
        bubbleImage.addSubview(displayImage3)
        bubbleImage.addSubview(displayImage4)
        bubbleImage.addSubview(displayImage4OverlayView)
        bubbleImage.addSubview(timeTickStackView)
        displayImage.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(90)
            make.top.equalToSuperview().inset(10)
            make.left.equalToSuperview().offset(10)
        }
        
        displayImage2.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(90)
            make.top.equalToSuperview().inset(10)
            make.left.equalTo(displayImage.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        displayImage3.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(90)
            make.top.equalTo(displayImage.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
        }
        
        displayImage4.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(90)
            make.top.equalTo(displayImage2.snp.bottom).offset(10)
            make.left.equalTo(displayImage3.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        displayImage4OverlayView.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(90)
            make.top.equalTo(displayImage2.snp.bottom).offset(10)
            make.left.equalTo(displayImage3.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        displayImage4OverlayView.addSubview(extraCountLabel)
        extraCountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        timeTickStackView.snp.makeConstraints { make in
            make.top.equalTo(displayImage4.snp.bottom).offset(8)
            make.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(5)
        }
        
    }
    
    override func setData(model: TGMessageData) {
        super.setData(model: model)
        for (index, messageData) in model.messageList.enumerated() {
            if let message = messageData.nimMessageModel, let imageObject = message.attachment as? V2NIMMessageImageAttachment {
                switch index {
                case 0:
                    displayImage.sd_setImage(with: URL(string: imageObject.url ?? ""), placeholderImage: UIImage.set_image(named: "IMG_icon"))
                case 1:
                    displayImage2.sd_setImage(with: URL(string: imageObject.url ?? ""), placeholderImage: UIImage.set_image(named: "IMG_icon"))
                case 2:
                    displayImage3.sd_setImage(with: URL(string: imageObject.url ?? ""), placeholderImage: UIImage.set_image(named: "IMG_icon"))
                case 3:
                    displayImage4.sd_setImage(with: URL(string: imageObject.url ?? ""), placeholderImage: UIImage.set_image(named: "IMG_icon"))
                default:
                    break
                }
                
            }
        }
        
        extraCountLabel.text = "\(model.messageList.count - 3)+"
        
    }
}
