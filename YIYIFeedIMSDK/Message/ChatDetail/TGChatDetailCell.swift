//
//  TGChatDetailCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/17.
//

import UIKit

class TGChatDetailCell: UITableViewCell {
    lazy var cellTitle: UILabel = {
        let lab = UILabel()
        lab.textColor = RLColor.share.black3
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.numberOfLines = 1
        lab.text = ""
        return lab
    }()
    lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.tintColor = RLColor.share.theme
        return switcher
    }()
    
    static let cellIdentifier = "TGChatDetailCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.setUI()
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        self.contentView.addSubview(cellTitle)
        self.contentView.addSubview(switcher)
        cellTitle.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(18)
        }
        switcher.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-10)
        }
    }
    
    func configure(title: String) {
        cellTitle.text = title
    }
}
