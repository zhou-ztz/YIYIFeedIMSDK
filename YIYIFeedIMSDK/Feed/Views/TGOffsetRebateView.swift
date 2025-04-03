//
//  OffsetRebateView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/20.
//

import UIKit


class TGOffsetRebateView: UIView {
    // MARK: - UI Components
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        return view
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let rebateContainerView = UIView()
    private let offsetContainerView = UIView()
    
    private let rebateView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let rebateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = TGAppTheme.red
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.25
        return label
    }()
    
    private let offsetLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.25
        return label
    }()
    
    // MARK: - Properties
    var rebate: String? {
        didSet { updateRebateText() }
    }
    
    var offset: String? {
        didSet { updateOffsetText() }
    }
    
    // MARK: - Initialization
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
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.bounds.height / 2
        rebateView.layer.cornerRadius = 8
    }
    
    // MARK: - Setup
    private func setupView() {
        addSubview(contentView)
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(rebateContainerView)
        stackView.addArrangedSubview(offsetContainerView)
        
        rebateContainerView.addSubview(rebateView)
        rebateView.addSubview(rebateLabel)
        offsetContainerView.addSubview(offsetLabel)
    }
    
    private func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        
        rebateView.snp.makeConstraints { make in
            make.top.equalTo(rebateContainerView).offset(3)
            make.leading.equalTo(rebateContainerView).offset(3)
            make.trailing.equalTo(rebateContainerView)
            make.bottom.equalTo(rebateContainerView).offset(-3)
        }
        
        rebateLabel.snp.makeConstraints { make in
            make.edges.equalTo(rebateView).inset(5)
        }
        
        offsetLabel.snp.makeConstraints { make in
            make.edges.equalTo(offsetContainerView).inset(5)
        }
    }
    
    // MARK: - Text Updates
    private func updateRebateText() {
        let value = Float(rebate ?? "0") ?? 0
        rebateLabel.text = "text_rebate_value".localized.replacingOccurrences(of: "%1$s", with: String(format: "%.1f", value)) + "%"
    }
    
    private func updateOffsetText() {
        let value = Float(offset ?? "0") ?? 0
        offsetLabel.text = "text_offset_value".localized.replacingOccurrences(of: "%1$s", with: String(format: "%.1f", value)) + "%"
    }
}
