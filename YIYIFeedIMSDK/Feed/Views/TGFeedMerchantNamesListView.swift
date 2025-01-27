//
//  TGFeedMerchantNamesListView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/20.
//

import UIKit

class TGFeedMerchantNamesListView: UIView {

    private let stackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.spacing = 5.0
    }
    

    private lazy var bgView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = UIColor.lightGray // Example color
        bgView.layer.cornerRadius = 7
        bgView.clipsToBounds = true
        return bgView
    }()
    
    //标记icon
    private let iconImageView = UIImageView().configure {
        $0.image = UIImage(named: "iconsPinGrey")
        $0.contentMode = .scaleAspectFit
    }
    
    //商店名称
    private let nameLabel: UILabel = UILabel().configure {
        $0.numberOfLines = 1
        $0.textColor = TGAppTheme.merchantNameTextGrey
        $0.text = "-"
        $0.setFontSize(with: 13, weight: .bold)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        self.addSubview(bgView)
        
        bgView.addSubview(nameLabel)
        bgView.roundCorner(7)
        bgView.bindToEdges()
        
        bgView.addSubview(stackView)
        stackView.bindToEdges(inset: 1)
        
        stackView.addArrangedSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        stackView.addArrangedSubview(nameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(merchant: TGRewardsLinkMerchantUserModel) {
        nameLabel.text = merchant.userName
    }

}
