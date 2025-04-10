//
//  FeedDetailCommentTableViewCell.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/29.
//

import UIKit

protocol TGDetailCommentTableViewCellDelegate: NSObjectProtocol {

    /// 点击重新发送按钮
    ///
    /// - Parameter commnetModel: 数据模型
    func repeatTap(cell: FeedDetailCommentTableViewCell, commnetModel: FeedCommentListCellModel)

    /// 点击了名字
    ///
    /// - Parameter userId: 用户Id
    func didSelectName(userId: Int)

    /// 点击了头像
    ///
    /// - Parameter userId: 用户Id
    func didSelectHeader(userId: Int)

    /// 长按了评论
    func didLongPressComment(in cell: FeedDetailCommentTableViewCell, model: FeedCommentListCellModel) -> Void
    
    func didTapToReplyUser(in cell:FeedDetailCommentTableViewCell, model: FeedCommentListCellModel)

    func needShowError()
}

class FeedDetailCommentTableViewCell: UITableViewCell, TGCommentLabelDelegate {

    
    static let identifier = "FeedDetailCommentTableViewCell"
    
    weak var cellDelegate: TGDetailCommentTableViewCellDelegate?

    var commnetModel: FeedCommentListCellModel?
    
    var likeButtonClickCall: (() -> ())?
    
    lazy var avatarView: TGAvatarView = {
        let img = TGAvatarView()
        return img
    }()
    
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = RLColor.share.black3
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.numberOfLines = 1
        lab.text = "-"
        return lab
    }()
    
    
    lazy var commentDetailLabel: TGCommentLabel = {
        let lab = TGCommentLabel()
        lab.textColor = MainColor.normal.minor
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.text = "-"
        lab.showType = .detail
        lab.labelDelegate = self
        lab.linesSpacing = 4.0
        return lab
    }()
    
    lazy var dateLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .lightGray
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.numberOfLines = 1
        lab.text = "-"
        return lab
    }()
    
    lazy var pinnedContainer: UIView = {
        let pinnedContainer = UIView()
        return pinnedContainer
    }()
   
    lazy var pinnedIcon: UIImageView = {
        let pinnedIcon = UIImageView()
        pinnedIcon.image = UIImage(named: "icPinnedWhite")
        return pinnedIcon
    }()
    
    lazy var pinnedLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .lightGray
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.text = "feed_live_comment_pinned_text".localized
        return lab
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        self.setUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static let cellIdentifier = "FeedDetailCommentTableViewCell"
    class func nib() -> UINib {
        return UINib(nibName: cellIdentifier, bundle: nil)
    }
    
    func setUI(){

        contentView.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(10)
            make.width.height.equalTo(36)
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarView.snp.right).offset(10)
            make.top.equalTo(avatarView.snp.top).offset(2)
        }
        
        contentView.addSubview(pinnedContainer)
        pinnedContainer.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(10)
            make.centerY.equalTo(nameLabel)
            make.height.equalTo(20)
        }
        pinnedContainer.addSubview(pinnedIcon)
        pinnedContainer.addSubview(pinnedLabel)
        pinnedIcon.snp.makeConstraints { make in
            make.left.equalTo(4)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSizeMake(15, 15))
        }
        pinnedLabel.snp.makeConstraints { make in
            make.left.equalTo(pinnedIcon.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }
        contentView.addSubview(commentDetailLabel)
        commentDetailLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.left)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.height.equalTo(50).priority(.high) // 设置优先级
            make.bottom.lessThanOrEqualToSuperview().offset(-10) // 防止冲突
        }
        
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(nameLabel)
        }
        
        // 添加底部分割线
         let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor(hex: 0xf9f9f9)
         contentView.addSubview(separatorLine)
         separatorLine.snp.makeConstraints { make in
             make.left.right.bottom.equalToSuperview()
             make.height.equalTo(1)
         }
        
        // 姓名点击响应
        let nameControl = UIControl()
        self.contentView.addSubview(nameControl)
        nameControl.addTarget(self, action: #selector(didTapName), for: .touchUpInside)
        nameControl.snp.makeConstraints { (make) in
            make.edges.equalTo(nameLabel)
        }
        // 评论整体添加长按举报手势
        let longGR = UILongPressGestureRecognizer(target: self, action: #selector(commentLongProcess(_:)))
        contentView.addGestureRecognizer(longGR)
        
    }
    
    public func setData(data: FeedCommentListCellModel){
        commnetModel = data
        
        let avatarInfo = TGAvatarInfo()
        avatarInfo.type = TGAvatarInfo.UserAvatarType.normal(userId: data.userId)
        avatarInfo.avatarURL = data.userInfo?.avatarUrl
        avatarInfo.verifiedIcon = (data.userInfo?.verificationIcon).orEmpty
        avatarInfo.verifiedType = (data.userInfo?.verificationType).orEmpty
        avatarView.avatarInfo = avatarInfo
        if data.userInfo == nil {
            nameLabel.text = "default_delete_user_name".localized
        } else {
            nameLabel.text = data.userInfo!.name
        }
        commentDetailLabel.linesSpacing = 0
        commentDetailLabel.showType = .detail
        commentDetailLabel.commentModel = data
        commentDetailLabel.sizeToFit()
        commentDetailLabel.labelDelegate = self
        commentDetailLabel.linesSpacing = 4.0
        
     
        dateLabel.text = TGDate().dateString(.normal, nDate: data.createDate ?? Date())
     
        let height = CGFloat(commentDetailLabel.getSizeWithWidth(width - 10 - 40 - 10 - 15).height)
        commentDetailLabel.snp.updateConstraints { make in
            make.height.equalTo(height).priority(.high) // 设置优先级
        }
        
    }
    public func setAsPinned(pinned: Bool?, isDarkMode: Bool) {
        pinnedContainer.backgroundColor = isDarkMode ? UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0) : UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        pinnedIcon.image = isDarkMode ? UIImage(named: "icPinnedWhite") : UIImage(named: "icPinned")
        pinnedLabel.textColor = isDarkMode ? UIColor(red: 184.0/255.0, green: 184.0/255.0, blue: 184.0/255.0, alpha: 1.0) : UIColor(red: 102.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1.0)
        if let pinned = pinned {
            pinnedContainer.isHidden = !pinned
        }
    }
    
    /// 点击名字
    @objc fileprivate func didTapName() {
        if let userInfo = self.commnetModel?.userInfo {
            self.cellDelegate?.didSelectHeader(userId: userInfo.userIdentity)
        } else {
            self.cellDelegate?.needShowError()
        }
    }
    
    @objc fileprivate func commentLongProcess(_ longPressGR: UILongPressGestureRecognizer) {
        guard let commnetModel = self.commnetModel else {
            return
        }
        
        if longPressGR.state == UIGestureRecognizer.State.began {
            self.cellDelegate?.didLongPressComment(in: self, model: commnetModel)
        }
    }
    func didSelect(didSelectId: Int) {
        guard let userId = self.commnetModel?.type["replyUserId"] else { return }
        self.cellDelegate?.didSelectName(userId: userId.toInt())
    }
    
    func didTapToReply() {
        self.cellDelegate?.didTapToReplyUser(in: self, model: self.commnetModel!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
