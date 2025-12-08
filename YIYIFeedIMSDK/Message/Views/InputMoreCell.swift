//
//  InputMoreCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/9.
//

import UIKit

class InputMoreCell: UICollectionViewCell {
    var cellData: MediaItem?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews() {
        contentView.addSubview(bgView)
        bgView.addSubview(avatarImage)
        contentView.addSubview(titleLabel)
        bgView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(50)
        }
        avatarImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
           
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(bgView.snp.bottom).offset(6)
            make.left.right.equalToSuperview()
        }
    }
    lazy var avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
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
    
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = RLColor.share.backGroundGray
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()
    func config(_ itemModel: MediaItem?) {
        cellData = itemModel
        if  let model = itemModel {
            avatarImage.image = model.info.icon
            titleLabel.text = model.info.title
            bgView.isHidden = false
        } else {
            bgView.isHidden = true
            avatarImage.image = nil
            titleLabel.text = ""
        }
        
        
    }
}
