//
//  TranslateMessageCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/20.
//

import UIKit

class TranslateMessageCell: BaseMessageCell {
    
    lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "yippitranslate")
        return imageView
    }()
    
    lazy var yippiLabel: UILabel = {
        let label = UILabel()
        label.font = TGAppTheme.Font.regular(10)
        label.textColor = .darkGray
        label.text = "text_translate".localized
        label.numberOfLines = 1
        return label
    }()
    
    lazy var textL: UILabel = {
        let label = UILabel()
        label.font = TGAppTheme.Font.regular(TGFontSize.defaultFontSize)
        label.textColor = .darkGray
        label.text = "translate"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView().configure { (stack) in
            stack.axis = .horizontal
            stack.spacing = 4
            stack.distribution = .fill
            stack.alignment = .fill
        }
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
        
        bubbleImage.addSubview(textL)
        bubbleImage.addSubview(bottomStackView)
        bottomStackView.addArrangedSubview(icon)
        bottomStackView.addArrangedSubview(yippiLabel)
        
        textL.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.top.equalTo(10)
        }
        bottomStackView.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview().inset(8)
            make.top.equalTo(textL.snp.bottom).offset(10)
        }
    }
    
    override func setData(model: TGMessageData) {
        super.setData(model: model)
        guard let attachment = model.customAttachment as? IMTextTranslateAttachment else { return }
        
        textL.text = attachment.translatedText
        
    }
}
