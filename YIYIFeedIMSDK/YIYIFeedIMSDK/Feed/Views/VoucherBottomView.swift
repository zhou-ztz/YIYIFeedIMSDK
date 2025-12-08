//
//  VoucherBottomView.swift
//  RewardsLink
//
//  Created by Wong Jin Lun on 17/07/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit

class VoucherBottomView: UIView {
    
    var voucherOnTapped: TGEmptyClosure?
    
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.235, green: 0.655, blue: 0.737, alpha: 0.95)
        return view
    }()
    
    let voucherLabel: UILabel = {
        let label = UILabel()
        label.text = "Glo laser Glo Laser Centres"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_rl_feed_voucher")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_arrow_next")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillProportionally
        return stack
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        addSubview(contentView)
        contentView.addSubview(stackView)
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(voucherLabel)
        stackView.addArrangedSubview(arrowImageView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(voucherAction))
        contentView.addGestureRecognizer(tap)
    }
    @objc func voucherAction() {
        self.voucherOnTapped?()
    }
    private func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.width.equalTo(25)
            make.height.equalTo(26)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.width.equalTo(25)
            make.height.equalTo(26)
        }
    }
}
