//
//  IMGiftOpenedView.swift
//  RewardsLink
//
//  Created by yiyikeji on 2025/5/9.
//  Copyright © 2025 Toga Capital. All rights reserved.
//

import UIKit

class IMGiftOpenedView: UIView {

    var actionButtonClosure: (()->())?
    var closeButtonClosure: (()->())?

    private lazy var titleLabel: GradientLabel = {
        let label = GradientLabel(colors: [
            UIColor(hex: 0xFFDC31),
            UIColor(hex: 0xF7931E)
        ])
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.text = "rw_gift_opened_title".localized
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var flareImage: UIImageView = {
        let medalImgV = UIImageView()
        medalImgV.image = UIImage(named: "ic_rl_light_flares")
        return medalImgV
    }()
    
    private lazy var secFlareImage: UIImageView = {
        let medalImgV = UIImageView()
        medalImgV.image = UIImage(named: "ic_rl_light_flares")
        return medalImgV
    }()
    
    private lazy var subView: UIView = {
        let view = UIView()
        view.roundCorner(8)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()

    private lazy var voucherImageView: UIImageView = {
        let medalImgV = UIImageView()
        medalImgV.image = UIImage(named: "rl_placeholder")
//        medalImgV.contentMode = .scaleAspectFill
        medalImgV.roundCorner(12)
        return medalImgV
    }()

    private lazy var voucherFrameView: UIImageView = {
        let medalImgV = UIImageView()
        medalImgV.image = UIImage(named: "ic_voucher_frame")
        return medalImgV
    }()
    
    private lazy var descLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 2
        label.text = "..."
        return label
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 16
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        return stackView
    }()
    
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("close".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemMediumFont(ofSize: 13)
        button.layer.cornerRadius = 18
        button.clipsToBounds = true
        button.backgroundColor = .clear
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    private lazy var actionGradientButton: GradientButtonView = {
        let button = GradientButtonView(title: "rw_gift_opened_action_button".localized, startColor: UIColor(hex: 0xFE8770), endColor: UIColor(hex: 0xFA1503))
        return button
    }()
    private var gradientLayer: CAGradientLayer?
    private lazy var tipStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var tipInfoIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_tip_info")
        imageView.tintColor = .white
        return imageView
    }()
    
    private lazy var tipInfoDescLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: 0xd1d1d1)
        label.font = UIFont.systemMediumFont(ofSize: 13)
        label.text = "rw_gift_opened_desc_text".localized
        label.numberOfLines = 0
        return label
    }()
    private lazy var tipInfoIconView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    init(statusResponse: GiftStatusResponse?) {
        
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.addSubview(subView)
        subView.bindToEdges()
        
        subView.addSubview(flareImage)
        subView.addSubview(secFlareImage)
        flareImage.bindToEdges()
        
        secFlareImage.snp.makeConstraints { make in
            make.edges.equalTo(flareImage)
        }

        voucherImageView.roundCorner(12)
 
        subView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        
        let imageUrlString = statusResponse?.imageUrl?.first ?? statusResponse?.logoUrl?.first ?? ""
        voucherImageView.sd_setImage(with: URL(string: imageUrlString), placeholderImage: UIImage(named: "icPicturePostPlaceholder"))
        subView.addSubview(voucherImageView)
        voucherImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.height.equalTo(160)
            make.width.equalTo(voucherImageView.snp.height).multipliedBy(45.0 / 30.0)
        }
        
        subView.addSubview(voucherFrameView)
        voucherFrameView.snp.makeConstraints { make in
            make.edges.equalTo(voucherImageView)
        }

        descLabel.text = statusResponse?.voucherName ?? ""
        subView.addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(voucherFrameView.snp.bottom).offset(20)
            make.left.right.equalTo(voucherImageView).inset(-16)
            
        }
        
        subView.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        buttonStackView.addArrangedSubview(closeButton)
        buttonStackView.addArrangedSubview(actionGradientButton)

        closeButton.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        actionGradientButton.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        closeButton.addAction {
            self.closeButtonClosure?()
        }
        actionGradientButton.addAction {
            self.actionButtonClosure?()
        }

        subView.addSubview(tipStackView)
        tipStackView.addArrangedSubview(tipInfoIconView)
        tipStackView.addArrangedSubview(tipInfoDescLabel)
        tipStackView.snp.makeConstraints { make in
            make.top.equalTo(buttonStackView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(20)
        }
        tipInfoIconView.snp.makeConstraints { make in
            make.width.equalTo(35)
        }
        
        tipInfoIconView.addSubview(tipInfoIconImageView)
        tipInfoIconImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 15, height: 15))
            make.center.equalToSuperview()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.flareImage.rotate(duration: 15)
            self.secFlareImage.counterRotate(duration: 15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class GradientButtonView: UIView {
    
    var tapAction: (() -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemMediumFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()
    private let iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: "ic_gift_arrow")
        return iconImageView
    }()
    private let gradientLayer = CAGradientLayer()
    
    private let startColor: UIColor
    private let endColor: UIColor
    
    init(title: String, startColor: UIColor, endColor: UIColor) {
        self.startColor = startColor
        self.endColor = endColor
        super.init(frame: .zero)
        
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = 18
        self.clipsToBounds = true
        
        titleLabel.text = title
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(5)
            make.centerY.equalToSuperview()
        }
        gradientLayer.colors = [
            startColor.cgColor,
            endColor.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.cornerRadius = 15
        layer.insertSublayer(gradientLayer, at: 0)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tap)
    }
    
    @objc private func handleTap() {
        tapAction?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GradientLabel: UIView {

    private let gradientLayer = CAGradientLayer()
    private let textLabel = UILabel()

    var text: String? {
        get { textLabel.text }
        set {
            textLabel.text = newValue
            setNeedsLayout()
        }
    }

    var font: UIFont {
        get { textLabel.font }
        set { textLabel.font = newValue }
    }

    var textAlignment: NSTextAlignment {
        get { textLabel.textAlignment }
        set { textLabel.textAlignment = newValue }
    }

    var numberOfLines: Int {
        get { textLabel.numberOfLines }
        set { textLabel.numberOfLines = newValue }
    }

    init(colors: [UIColor]) {
        super.init(frame: .zero)

        // 设置 label
        textLabel.textColor = .black
        textLabel.backgroundColor = .clear
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        addSubview(textLabel)

        // 设置 gradientLayer
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)

        // 设置 mask
        gradientLayer.mask = textLabel.layer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = bounds
        gradientLayer.frame = bounds
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
