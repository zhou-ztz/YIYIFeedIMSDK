//
//  TGCustomActionsheetTableViewCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2024/12/31.
//

import UIKit

class TGCustomActionsheetTableViewCell: UITableViewCell {
    
    var describeLabel: UILabel!

    var describeText: String? {
        get {
            return self.describeText
        }

        set {
            describeLabel.text = newValue
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        describeLabel = UILabel()
        describeLabel.font = UIFont.systemFont(ofSize: 16)
        self.contentView.addSubview(describeLabel)
        describeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    

}
