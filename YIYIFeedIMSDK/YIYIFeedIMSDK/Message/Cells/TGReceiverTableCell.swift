//
//  TGReceiverTableCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/12.
//

import UIKit

class TGReceiverTableCell: UITableViewCell {

    // 使用懒加载初始化所有子视图
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 0.2745, green: 0.2745, blue: 0.2745, alpha: 1.0)
        return label
    }()
    
    private lazy var noteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor(red: 0.6078, green: 0.6078, blue: 0.6078, alpha: 1.0)
        return label
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    private lazy var currencyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor(red: 0.4353, green: 0.4431, blue: 0.4745, alpha: 1.0)
        return label
    }()
    
    private lazy var luckyStarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_lucky_star")
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var luckyStarLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = RLColor.main.theme
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(noteLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(currencyLabel)
        contentView.addSubview(luckyStarImageView)
        contentView.addSubview(luckyStarLabel)
        luckyStarImageView.isHidden = true
        luckyStarLabel.isHidden = true
    }
    
    private func setupConstraints() {
    
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(10)
            make.centerY.equalTo(contentView)
            make.size.equalTo(32)
            make.bottom.top.equalToSuperview().inset(10)
        }
        avatarImageView.roundCorner(16)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(16)
            make.top.equalTo(contentView).offset(8)
            make.trailing.lessThanOrEqualTo(amountLabel.snp.leading).offset(-16)
        }
        
        noteLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.trailing.lessThanOrEqualTo(amountLabel.snp.leading).offset(-16)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.trailing.equalTo(currencyLabel.snp.leading).offset(-5)
            make.top.equalTo(contentView).offset(8)
        }
        
        currencyLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(5)
            make.bottom.equalTo(amountLabel)
        }
        
        luckyStarImageView.snp.makeConstraints { make in
            make.trailing.equalTo(luckyStarLabel.snp.leading).offset(-5)
            make.top.equalTo(amountLabel.snp.bottom).offset(8)
            make.size.equalTo(18)
        }
        
        luckyStarLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-10)
            make.top.equalTo(amountLabel.snp.bottom).offset(8)
        }
    }
    
    func configureData(with imagePath: String, userId:Int, name: String, date: String, amount: String, currency: String? = nil, luckyStar: Int) {
        avatarImageView.sd_setImage(with: URL(string: imagePath), placeholderImage: UIImage(named: "IMG_pic_default_secret"))

        noteLabel.text = date.toDate(from: "yyyy-MM-dd'T'HH:mm:ss.ssssssZ", to: "yyyy-MM-dd HH:mm:ss")
        amountLabel.text = amount
        currencyLabel.text = currency ?? "rewards_link_point_short".localized
        luckyStarLabel.text = "viewholder_lucky_star".localized
        if luckyStar == 1 {
            luckyStarImageView.isHidden = false
            luckyStarLabel.isHidden = false
        } else {
            luckyStarImageView.isHidden = true
            luckyStarLabel.isHidden = true
        }
        self.nameLabel.text = name
        
    }
}
