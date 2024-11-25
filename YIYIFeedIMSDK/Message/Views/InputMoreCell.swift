//
//  InputMoreCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/9.
//

import UIKit

class InputMoreCell: UICollectionViewCell {
    var cellData: NEMoreItemModel?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews() {
        contentView.addSubview(avatarImage)
        contentView.addSubview(titleLabel)
        avatarImage.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.width.equalTo(56)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImage.snp.bottom).offset(6)
            make.left.right.equalToSuperview()
        }
    }
    lazy var avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.textColor = UIColor.lightGray
        title.font = UIFont.systemFont(ofSize: 10)
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    func config(_ itemModel: NEMoreItemModel) {
        cellData = itemModel
        avatarImage.image = itemModel.image
        titleLabel.text = itemModel.title
    }
}
