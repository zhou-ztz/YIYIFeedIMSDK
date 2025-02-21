//
//  TGIMNotificationCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/17.
//

import UIKit

class TGIMNotificationCell: UITableViewCell {

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = TGAppTheme.primaryColor
        return label
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(countLabel)
        
        // Layout using SnapKit
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.left.equalTo(iconImageView.snp.right).offset(15)
            make.right.lessThanOrEqualTo(countLabel.snp.left).offset(-10)
        }
        
        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(15)
            make.bottom.equalToSuperview().offset(-15)
            make.right.lessThanOrEqualTo(countLabel.snp.left).offset(-10)
        }
        
        countLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    
    func refresh(with data: [String: Any]) {
        let maxWidthLabel = contentView.frame.width - 30
        
        titleLabel.text = data["title"] as? String
        titleLabel.sizeToFit()
        detailLabel.text = data["desp"] as? String
        detailLabel.sizeToFit()
        iconImageView.image = UIImage(named: data["icon"] as? String ?? "")
        
        titleLabel.frame.size.width = min(titleLabel.frame.width, maxWidthLabel)
        detailLabel.frame.size.width = min(detailLabel.frame.width, maxWidthLabel)
        
        if let count = data["count"] as? Int, count > 0 {
            let countStr = count > 99 ? "99+" : "\(count)"
            countLabel.isHidden = false
            countLabel.text = countStr
            countLabel.sizeToFit()
            accessoryType = .disclosureIndicator
        } else {
            countLabel.isHidden = true
            accessoryType = .none
        }
    }
}
