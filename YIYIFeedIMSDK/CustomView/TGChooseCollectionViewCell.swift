//
//  TGChooseCollectionViewCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2024/12/25.
//

import UIKit

class TGChooseCollectionViewCell: UICollectionViewCell {
    
    static let cellIdentifier = "TSChooseCollectionViewCell"
    var iconImageView: UIImageView = UIImageView()
    var iconTitleLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews () {
        self.contentView.addSubview(iconImageView)
        self.contentView.addSubview(iconTitleLabel)
        iconTitleLabel.font = UIFont.systemFont(ofSize: 10)
        iconTitleLabel.textColor = .white
        iconTitleLabel.textAlignment = .center
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(10)
        }
        iconTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconImageView.snp.bottom).offset(5)
           // make.bottom.equalTo(-10)
        }
    }
}

class TGChooseFooterView: UICollectionReusableView {
    static let cellIdentifier = "TGChooseFooterView"
    
    let separatorView = UIView().configure {
        $0.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
            
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = .clear
        alpha = 0.2
        
        addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(1)
            make.width.equalToSuperview()
        }
    }
}

