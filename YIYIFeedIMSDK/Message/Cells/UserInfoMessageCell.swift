//
//  UserInfoMessageCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/22.
//

import UIKit

class UserInfoMessageCell: UITableViewCell {

    lazy var baseLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = RLColor.share.black3
        label.text = "基本资料：25岁 | 服务业 | 160cm"
        return label
    }()
    lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = RLColor.share.black3
        label.text = "所在城市：深圳（距离12.89km）"
        return label
    }()
    lazy var realLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = RLColor.share.black3
        label.text = "真人认证"
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.setUI()
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI(){
        self.contentView.addSubview(baseLabel)
        baseLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
        }
    }
    
    func setData(model: RLMessageData){
        
    }

}
