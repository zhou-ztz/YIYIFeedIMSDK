//
//  MsgCollectionViewCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2024/12/24.
//

import UIKit

class MsgCollectionViewCell: UICollectionViewCell {
    lazy var cateLabel: UILabel = {
        let name = UILabel()
        name.textColor = UIColor(red: 0, green: 0, blue: 0)
        name.font = UIFont.systemFont(ofSize: 14)
        name.textAlignment = .left
        name.numberOfLines = 1
        return name
    }()
    var cateImageView: UIImageView = UIImageView()
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 5
        return stackView
    }()
    var categoryList = [CategoryMsgModel]()
    static let cellIdentifier = "MsgCollectionViewCell"
    override var isSelected: Bool {
        didSet {
            self.contentView.backgroundColor = isSelected ? TGAppTheme.red : UIColor(hex: 0xededed)
            self.cateLabel.textColor = isSelected ? .white : .lightGray
            self.cateImageView.image = self.cateImageView.image?.withRenderingMode(.alwaysTemplate)
            self.cateImageView.tintColor = isSelected ? .white : .lightGray
           
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews () {
        cateImageView.contentMode = .scaleAspectFit
        self.contentView.layer.cornerRadius = 3
        self.contentView.clipsToBounds = true
        self.contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(cateImageView)
        contentStackView.addArrangedSubview(cateLabel)
        contentStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(6)
            make.bottom.top.equalToSuperview().inset(4)
        }
        cateImageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        cateLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
        }
        
    }
    
    func setData(data: CategoryMsgModel){
        if data.type == .all {
            cateImageView.isHidden = true
        } else {
            cateImageView.isHidden = false
        }
        cateLabel.text = data.name
        cateImageView.image = data.image
    }
    
    
}
