//
//  TGLocationPOICell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/7.
//

import UIKit

import UIKit

class TGLocationPOICell: UITableViewCell {

    var primaryLabel: UILabel!
    var secondaryLabel: UILabel!
    
    // 初始化方法
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // 设置视图
    private func setupViews() {
        // 创建主标签
        primaryLabel = UILabel()
        primaryLabel.numberOfLines = 1
        primaryLabel.font = UIFont.systemFont(ofSize: 15)
        primaryLabel.text = "Lao Si Chuan Steamboat"
        contentView.addSubview(primaryLabel)
        
        // 创建副标签
        secondaryLabel = UILabel()
        secondaryLabel.numberOfLines = 2
        secondaryLabel.font = UIFont.systemFont(ofSize: 15)
        secondaryLabel.text = "2 Place Saime-Opportune 75001 Paris 法國"
        secondaryLabel.textColor = UIColor(white: 0.6, alpha: 1)
        contentView.addSubview(secondaryLabel)
        
        setupConstraints()
    }
    
    // 配置方法：用于设置主标签和副标签的文本
    func configure(primary: String?, secondary: String?) {
        primaryLabel.text = primary ?? "Default Primary Text"
        secondaryLabel.text = secondary ?? "Default Secondary Text"
    }
    
    private func setupConstraints() {
        primaryLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(16)
            make.leading.equalTo(contentView.snp.leading).offset(16)
            make.trailing.equalTo(contentView.snp.trailing).offset(-16)
            make.height.equalTo(22)
        }
        
        secondaryLabel.snp.makeConstraints { make in
            make.top.equalTo(primaryLabel.snp.bottom).offset(6)
            make.leading.equalTo(contentView.snp.leading).offset(16)
            make.trailing.equalTo(contentView.snp.trailing).offset(-16)
            make.bottom.equalTo(contentView.snp.bottom).offset(-13)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
