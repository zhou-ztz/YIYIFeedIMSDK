//
//  TGTeamMeetingPreviewCell.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/2.
//

import UIKit
import NIMSDK

class TGTeamMeetingPreviewCell: UICollectionViewCell {
    var team: V2NIMTeam?
    var avatarImageView: TGAvatarView = TGAvatarView(type: AvatarType.custom(avatarWidth: 90, showBorderLine: false))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.setUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUI(){
        self.contentView.addSubview(avatarImageView)
        avatarImageView.bindToEdges()
        avatarImageView.layoutIfNeeded()
    }
    
    func loadCallingUser(user: String, number: Int, index: Int){
        
        self.avatarImageView.isHidden = false
        self.avatarImageView.layer.cornerRadius = 45
        self.avatarImageView.layer.masksToBounds = true
        self.backgroundColor  = .clear
        
        MessageUtils.getAvatarIcon(sessionId: user, conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.avatarImageView.avatarInfo = avatarInfo
                self.setNeedsLayout()
            }
        }
        
    }
}
