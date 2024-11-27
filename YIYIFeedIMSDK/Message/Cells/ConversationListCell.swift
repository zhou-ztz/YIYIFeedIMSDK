//
//  ConversationListCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2023/12/19.
//

import UIKit
import NIMSDK

protocol ConversationListCellDelegate: AnyObject {
    func handleLongPress(cell: ConversationListCell, session: NIMRecentSession?)
}

class ConversationListCell: UITableViewCell {
    
    weak var delegate: ConversationListCellDelegate?
    
    lazy var headImage: UIImageView = {
        let img = UIImageView()
        //img.backgroundColor = RLColor.share.lightGray
        img.clipsToBounds = true
        img.layer.cornerRadius = 10
        return img
    }()
    
    lazy var titleL: UILabel = {
        let lab = UILabel()
        lab.textColor = RLColor.share.black3
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.numberOfLines = 1
        lab.text = "笑死"
        return lab
    }()
    lazy var contentL: UILabel = {
        let lab = UILabel()
        lab.textColor = RLColor.share.lightGray
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.numberOfLines = 1
        lab.text = "你好哈哈哈"
        return lab
    }()
    lazy var redPiont: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = UIFont.systemFont(ofSize: 9)
        lab.numberOfLines = 1
        lab.text = ""
        lab.backgroundColor = .red
        lab.textAlignment = .center
        lab.clipsToBounds = true
        lab.layer.cornerRadius = 8
        return lab
    }()
    
    lazy var timeL: UILabel = {
        let lab = UILabel()
        lab.textColor = RLColor.share.lightGray
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.numberOfLines = 1
        lab.text = "15:17"
        return lab
    }()
    
    lazy var addressL: UILabel = {
        let lab = UILabel()
        lab.textColor = RLColor.share.lightGray
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.numberOfLines = 1
        lab.text = "深圳"
        return lab
    }()
    
    var session: NIMRecentSession?

    static let cellIdentifier = "ConversationListCell"
    class func nib() -> UINib {
        return UINib(nibName: cellIdentifier, bundle: nil)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.setUI()
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI(){
        setupLongPressGesture()
        self.contentView.addSubview(headImage)
        self.contentView.addSubview(titleL)
        self.contentView.addSubview(contentL)
        self.contentView.addSubview(timeL)
        self.contentView.addSubview(addressL)
        self.contentView.addSubview(redPiont)
        headImage.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(8)
            make.height.width.equalTo(70)
        }
        
        titleL.snp.makeConstraints { make in
            make.left.equalTo(headImage.snp.right).offset(10)
            make.top.equalTo(20)
            make.right.equalTo(-70)
        }
        
        contentL.snp.makeConstraints { make in
            make.left.equalTo(headImage.snp.right).offset(10)
            make.bottom.equalTo(-20)
            make.right.equalTo(-100)
        }
        
        addressL.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.right.equalTo(-10)
        }
        
        timeL.snp.makeConstraints { make in
            make.bottom.equalTo(-20)
            make.right.equalTo(-10)
        }
        
        redPiont.snp.makeConstraints { make in
            make.left.equalTo(77)
            make.top.equalTo(0)
            make.height.width.equalTo(16)
        }
        
    }
    
    func setData(session: NIMRecentSession){
        self.session = session
        
        if let sessions = session.session {
            titleL.text = MessageUtils.getShowName(userId: sessions.sessionId , teamId: sessions.sessionId, session: sessions)
            let url = MessageUtils.getUserAvatar(userId: sessions.sessionId, session: sessions)
            headImage.sd_setImage(with: URL(string: url ?? ""), placeholderImage: UIImage.set_image(named: "defaultProfile"))
        }
        redPiont.text = "\(session.unreadCount)"
        redPiont.isHidden = session.unreadCount == 0 ? true : false
        timeL.text = "\(session.lastMessage?.timestamp ?? 0)".convertDateFromString(timeType: 0)
        guard let messageType = session.lastMessage?.messageType else { return }
        switch messageType {
        case .text:
            contentL.text = session.lastMessage?.text ?? ""
        case .image:
            contentL.text = "[图片消息]"
        case .location:
            contentL.text = "[位置消息]"
        case .video:
            contentL.text = "[视频消息]"
        case .file:
            contentL.text = "[文件消息]"
        case .audio:
            contentL.text = "[语音消息]"
        case .notification:
            contentL.text = "[通知消息]"
        case .tip:
            var nick = "对方"
            if session.lastMessage?.from == RLCurrentUserInfo.shared.accid {
                nick = "你"
            }
            contentL.text = nick + "\(session.lastMessage?.text ?? "")"
        default:
            contentL.text = "[未知消息]"
        }
    }
    
    private func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.delegate = self
        contentView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            self.delegate?.handleLongPress(cell: self, session: session)
        }
    }

}
