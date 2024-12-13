//
//  TGChooseViewCell.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/13.
//

import UIKit

class TGChooseViewCell: UITableViewCell {
    static let cellIdentifier = "TGChooseViewCell"
    
    lazy var icon: UIImageView = {
        let imageView = UIImageView()
       // imageView.image = UIImage.set_image(named: "MdOutlinePushPin")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    lazy var titleLab: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hex: "#808080")
        return label
    }()
    lazy var redLab: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        //label.textColor = UIColor(hex: "#808080")
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
        contentView.addSubview(icon)
        contentView.addSubview(titleLab)
        contentView.addSubview(redLab)
        icon.snp.makeConstraints { make in
            make.width.height.equalTo(22)
            make.centerY.equalToSuperview()
            make.left.equalTo(10)
        }
        titleLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.icon.snp.right).offset(10)
        }
        icon.contentMode = .scaleAspectFit
        titleLab.textColor = .white
        titleLab.numberOfLines = 2
        redLab.backgroundColor = .red
        redLab.roundCorner(3.5)
        redLab.isHidden = true
        self.layoutIfNeeded()
        redLab.snp.makeConstraints { make in
            make.width.height.equalTo(7)
            make.top.equalTo(self.icon.snp_topMargin).offset(-7)
            make.left.equalTo(self.icon.snp_rightMargin).offset(3.5)
        }
    }

}
