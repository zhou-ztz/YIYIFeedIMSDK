//
//  TipMessageCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/4.
//

import UIKit
import NIMSDK

class TipMessageCell: UITableViewCell {
    
    lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = RLColor.share.lightGray
        label.text = ""
        return label
    }()
    let bgView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.setUI()
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI(){
        bgView.backgroundColor = UIColor(red: 230, green: 230, blue: 230)
        
        tipLabel.font = UIFont.systemFont(ofSize: 10.0)
        tipLabel.textColor = .black
        tipLabel.textAlignment = .center
        self.contentView.addSubview(bgView)
        
        bgView.addSubview(tipLabel)
        bgView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(6)
        }
        tipLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(4)
            make.left.right.equalToSuperview().inset(8)
        }
        
        bgView.roundCorner(7.5)
    }
    
    func setData(model: TGMessageData){
        guard let message = model.nimMessageModel else {
            return
        }
        /// 时间
        if model.type == .time {
            tipLabel.text = model.messageTime.messageTime(showDetail: true) ?? ""
        }else{
            ///群通知处理
            if let _ = model.nimMessageModel?.attachment as? V2NIMMessageNotificationAttachment  {
                MessageUtils.teamNotificationFormatedMessage(message) { text in
                    self.tipLabel.text = text
                }
            } else { /// 撤回消息处理
                
                var nick = "opponent".localized
                if message.isSelf {
                    nick = "you".localized
                }
                if message.conversationType == .CONVERSATION_TYPE_TEAM, let accoundId = message.senderId , !message.isSelf {
                    MessageUtils.getUserInfo(accountIds: [accoundId]) { [weak self] users, _ in
                        if let user = users?.first {
                            nick = TGLocalRemarkName.getRemarkName(userId: nil, username: user.accountId, originalName: user.name, label: nil)
                            self?.tipLabel.text = String(format: "revoke_msg".localized, nick)
                        }
                    }
                } else {
                    tipLabel.text = String(format: "revoke_msg".localized, nick)
                }
 
            }

        }
    }

}
