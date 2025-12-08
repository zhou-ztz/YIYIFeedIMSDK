//
//  TGProfileLanguageListCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/19.
//

import UIKit

class TGProfileLanguageListCell: UITableViewCell {

    static let identifier = "TGProfileLanguageListCell"
    
    lazy var languageNameLabel: UILabel = {
        let languageNameLabel = UILabel()
        languageNameLabel.font = .systemFont(ofSize: 14)
        languageNameLabel.textColor = TGAppTheme.black
        return languageNameLabel
    }()
    
    lazy var selectImageBtn: UIButton = {
        let selectImageBtn = UIButton()
        selectImageBtn.isUserInteractionEnabled = false
        selectImageBtn.setImage(UIImage(named: "ic_checkbox_normal"), for: .normal)
        selectImageBtn.setImage(UIImage(named: "ic_rl_checkbox_selected"), for: .selected)
        return selectImageBtn
    }()
    
    lazy var bottomSeparator = UIView().configure {
        $0.backgroundColor = UIColor(red: 237, green: 237, blue: 237)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(languageNameLabel)
        contentView.addSubview(selectImageBtn)
        contentView.addSubview(bottomSeparator)
        
        languageNameLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }
        selectImageBtn.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
        bottomSeparator.snp.makeConstraints {
            $0.bottom.left.right.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
