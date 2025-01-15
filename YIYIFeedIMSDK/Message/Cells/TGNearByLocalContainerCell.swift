//
//  TGNearByLocalContainerCell.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/17.
//

import UIKit

class TGNearByLocalContainerCell: UITableViewCell {

    lazy var nameLab: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = RLColor.share.black3
        label.text = ""
        label.isHidden = false
        return label
    }()
    lazy var contentLab: UILabel  = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = RLColor.share.black3
        label.text = ""
        label.isHidden = false
        return label
    }()
    lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.set_image(named: "ic_rl_checkbox_selected")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    static let cellIdentifier = "TGNearByLocalContainerCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonUI() {
        
        self.contentView.addSubview(nameLab)
        self.contentView.addSubview(contentLab)
        self.contentView.addSubview(icon)

        nameLab.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(10)
        }
        contentLab.snp.makeConstraints { make in
            make.top.equalTo(self.nameLab.snp.bottom).offset(2)
            make.left.equalTo(10)
        }
        icon.snp.makeConstraints { make in
            make.height.width.equalTo(16)
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
        }
        self.icon.image = UIImage.set_image(named: "ic_rl_checkbox_selected")
        self.icon.roundCorner(8)
        self.icon.isHidden = true
    }
    
    func setData(data: TGLocationModel){
        nameLab.text = data.locationName
        contentLab.text = data.address
    }


}
