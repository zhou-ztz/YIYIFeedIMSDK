//
//  FeedCategoryOptions.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/8.
//

import UIKit

class FeedCategoryOptions: UIView {

    var borderView: UIView = UIView()
    var view: UIView = UIView()
    lazy var label: UILabel = {
        let name = UILabel()
        name.font = UIFont.systemFont(ofSize: 12)
        name.textAlignment = .left
        name.numberOfLines = 1
        return name
    }()
    var arrowImageView: UIImageView = UIImageView()
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }

    // MARK: - Lifecycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        view.frame = bounds
        addSubview(view)
        view.addSubview(label)
        view.addSubview(arrowImageView)
        arrowImageView.image = UIImage.set_image(named: "ic_drop_down")
        
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(10)
        }
        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-10)
            make.left.equalTo(arrowImageView.snp.right).offset(5)
        }
        
        borderView.roundCorner(25.0/2)
        borderView.backgroundColor = .white
        borderView.layer.borderColor = UIColor(hex: 0xD1D1D1).cgColor
        borderView.layer.borderWidth = 1.0

        label.textColor = TGAppTheme.brownGrey
    }

}
