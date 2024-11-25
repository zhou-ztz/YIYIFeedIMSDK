//
//  TipMessageCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/4.
//

import UIKit

class TipMessageCell: UITableViewCell {
    
    lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = RLColor.share.lightGray
        label.text = ""
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
        self.contentView.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
        }
    }
    
    func setData(model: RLMessageData){
        if model.type == .time {
            tipLabel.text = model.messageTime.messageTime(showDetail: true) ?? ""
        }else{
            var nick = "对方"
            if model.nimMessageModel?.from == RLCurrentUserInfo.shared.accid {
                nick = "你"
            }
            tipLabel.text = nick + "\(model.nimMessageModel?.text ?? "")"
        }
    }

}
