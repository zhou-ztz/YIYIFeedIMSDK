//
//  TGChatNotificationCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/6.
//

import UIKit

class TGChatNotificationCell: UITableViewCell {

    var iconImageView: UIImageView!
    var titleLabel: UILabel!
    var contentLabel: UILabel!
    var countLabel: UILabel!
    
    static let cellIdentifier = "TGChatNotificationCell"
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.setUI()
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI(){
        
        self.contentView.addSubview(iconImageView)
    }
    
    func refresh(data: [String : Any]) {
        let maxWidthLabel: CGFloat = contentView.width - 30
        
        titleLabel?.text = data["title"] as? String
        titleLabel?.sizeToFit()
        contentLabel.text = data["desp"] as? String
        contentLabel.sizeToFit()
        iconImageView.image = UIImage(named: data["icon"] as? String ?? "")
        
        guard let count = data["count"] as? Int else { return }
        if count > 0 {
            let countStr = count > 99 ? "99+" : NSNumber(value: count).stringValue
            countLabel.isHidden = false
            countLabel.text = countStr
            countLabel.sizeToFit()
            accessoryType = .disclosureIndicator
        } else {
            countLabel.isHidden = true
            accessoryType = .none
        }
        
    }

}
