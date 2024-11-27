//
//  ReplyView.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/18.
//

import UIKit

class ReplyView: UIView {
    var closeButton = UIButton(type: .custom)
    var line = UIView()
    var textLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "#EFF1F2")
        closeButton.setImage(UIImage.set_image(named: "close"), for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(closeButton)
        
        line.backgroundColor = UIColor(hex: "#D8DAE4")
        line.translatesAutoresizingMaskIntoConstraints = false
        addSubview(line)
        
        
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.textColor = UIColor(hex: "#929299")
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)

        closeButton.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(0)
            make.width.equalTo(34)
        }
        
        line.snp.makeConstraints { make in
            make.left.equalTo(closeButton.snp.right).offset(3)
            make.width.equalTo(1)
            make.top.bottom.equalToSuperview().inset(8)
        }
        textLabel.snp.makeConstraints { make in
            make.left.equalTo(closeButton.snp.right).offset(8)
            make.top.bottom.right.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
