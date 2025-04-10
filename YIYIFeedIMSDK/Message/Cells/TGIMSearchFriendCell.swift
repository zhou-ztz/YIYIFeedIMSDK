//
//  TGIMSearchFriendCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/17.
//

import UIKit

protocol TGIMSearchFriendCellDelegate: AnyObject {
    func didTapOnCollectionCell(_ cell: TGIMSearchFriendCell)
}

class TGIMSearchFriendCell: UICollectionViewCell {

    lazy var avatarImageView: TGAvatarView = {
        let imageView = TGAvatarView()
        return imageView
    }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    weak var delegate: TGIMSearchFriendCellDelegate?
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 设置
    private func setupUI() {
        // 添加子视图
        contentView.addSubview(avatarImageView)
        contentView.addSubview(textLabel)
        
        // 设置约束
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(contentView.snp.width).multipliedBy(0.7)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        avatarImageView.circleCorner()
        textLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(5)
        }
        
        // 添加点击手势
       // let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onPressAvatarImage(_:)))
       // avatarImageView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - 数据刷新
    
    func refreshUserInfo(_ user: TGUserInfoModel) {
        textLabel.text = user.displayName
        avatarImageView.avatarInfo = user.avatarInfo()
    }
    
    // MARK: - 事件处理
    
    @objc private func onPressAvatarImage(_ sender: UITapGestureRecognizer) {
        delegate?.didTapOnCollectionCell(self)
    }
}
