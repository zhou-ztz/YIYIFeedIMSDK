//
//  OffsetRebateView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/20.
//

import UIKit

class TGOffsetRebateView: UIView {
    
    private var contentView: UIView!
    private var rebateView: UIView!
    private var rebateLabel: UILabel!
    private var offsetLabel: UILabel!
      
    var rebate: String? {
        didSet {
            let temp = Float(rebate ?? "0") ?? 0
            self.rebateLabel.text = "\("text_rebate_value".localized.replacingFirstOccurrence(of: "%1$s", with: temp.cleanValue))%"
        }
    }
    
    var offset: String? {
        didSet {
            let temp = Float(offset ?? "0") ?? 0
            self.offsetLabel.text = "\("text_offset_value".localized.replacingFirstOccurrence(of: "%1$s", with: temp.cleanValue))%"
        }
    }
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.clipsToBounds = true
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = contentView.frame.height / 2
        
        rebateView.clipsToBounds = true
        rebateView.layer.masksToBounds = true
        rebateView.layer.cornerRadius = rebateView.frame.height / 2
    }
    
    private func setupUI() {
        // Initialize contentView
        contentView = UIView()
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 20 // Set a fixed radius for simplicity
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
        
        // Set up rebateView
        rebateView = UIView()
        rebateView.backgroundColor = .clear
        rebateView.layer.cornerRadius = 12 // Set a fixed radius for rebateView
        rebateView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rebateView)
        
        // Set up rebateLabel
        rebateLabel = UILabel()
        rebateLabel.textAlignment = .center
        rebateLabel.font = UIFont.systemFont(ofSize: 11)
        rebateLabel.textColor = TGAppTheme.red
        rebateLabel.translatesAutoresizingMaskIntoConstraints = false
        rebateView.addSubview(rebateLabel)
        
        // Set up offsetLabel
        offsetLabel = UILabel()
        offsetLabel.textAlignment = .center
        offsetLabel.font = UIFont.systemFont(ofSize: 11)
        offsetLabel.textColor = .white
        offsetLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(offsetLabel)
        
        // Use SnapKit to create constraints
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(self).multipliedBy(0.6) // Adjust contentView height ratio
        }
        
        rebateView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(3)
            make.left.equalTo(contentView.snp.left).offset(3)
            make.right.equalTo(contentView.snp.right).offset(-3)
            make.height.equalTo(24)
        }
        
        rebateLabel.snp.makeConstraints { make in
            make.edges.equalTo(rebateView).inset(5)
        }
        
        offsetLabel.snp.makeConstraints { make in
            make.top.equalTo(rebateView.snp.bottom).offset(5)
            make.left.equalTo(contentView.snp.left).offset(5)
            make.right.equalTo(contentView.snp.right).offset(-5)
            make.bottom.equalTo(contentView.snp.bottom).offset(-5)
        }
        
        // Final UI Setup
        contentView.backgroundColor = TGAppTheme.red
        rebateView.clipsToBounds = true
        rebateView.layer.masksToBounds = true
        rebateView.layer.cornerRadius = rebateView.frame.height / 2
    }

}
