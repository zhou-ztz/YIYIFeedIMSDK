//
//  OperationCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/17.
//

import UIKit

class OperationCell: UICollectionViewCell {
    
    lazy var imageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    lazy var label = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = RLColor.share.black3
        label.textAlignment = .center
        return label
    }()
    
    var model: OperationItem? {
        didSet {
            imageView.image = UIImage(named: model?.imageName ?? "")
            label.text = model?.text ?? ""
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(18)
            make.top.equalTo(8)
            make.centerX.equalToSuperview()
        }
        label.snp.makeConstraints { make in
            make.height.equalTo(18)
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
