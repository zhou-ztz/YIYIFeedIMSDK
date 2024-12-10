//
//  FeedDetailCommentTableViewCell.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/29.
//

import UIKit

class FeedDetailCommentTableViewCell: UITableViewCell {

    var likeButtonClickCall: (() -> ())?
    
    lazy var avatarView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "defaultProfile")
        img.contentMode = .scaleAspectFit
        img.backgroundColor = .gray
        img.layer.cornerRadius = 20
        img.layer.masksToBounds = true
        return img
    }()
    
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .lightGray
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.numberOfLines = 1
        lab.text = "-"
        return lab
    }()
    
    
    lazy var contentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .black
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.numberOfLines = 0
        lab.text = "-"
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
    
    private lazy var likeBtn: FeedToolBarButton = {
        let button = FeedToolBarButton()
        button.imageView.image = UIImage(named: "IMG_home_ico_love")
        button.imageView.contentMode = .scaleAspectFit
        button.addAction { [weak self] in

        }
        return button
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
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
            make.left.top.equalToSuperview().inset(10)
            make.width.height.equalTo(40)
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarView.snp.right).offset(10)
            make.top.equalTo(avatarView.snp.top).offset(2)
            
        }
        
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.left)
            make.right.equalToSuperview().inset(50)
            make.top.equalTo(nameLabel.snp.bottom).offset(3)
        }
        
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.left)
            make.top.equalTo(contentLabel.snp.bottom).offset(3)
            make.bottom.equalToSuperview()
        }
        
        
        contentView.addSubview(likeBtn)
        likeBtn.snp.makeConstraints { make in
            make.centerY.equalTo(contentLabel)
            make.right.equalToSuperview().inset(10)
        }
        likeBtn.addAction {
            self.likeButtonClickCall?()
        }
    }
    
//    public func setData(data: FeedCommentDataList){
//        
//        avatarView.sd_setImage(with: URL(string: data.author?.avatar ?? ""), placeholderImage: UIImage(named: "defaultProfile"))
//        nameLabel.text = data.author?.nickname ?? ""
//        contentLabel.text = data.content ?? ""
//        dateLabel.text = data.createTime ?? ""
//        
//        likeBtn.titleLabel.text = data.countStart.stringValue
//        
//        likeBtn.imageView.image = data.relevanceId > 0 ? UIImage(named: "heart")! :  UIImage(named: "IMG_home_ico_love")!
//        
//    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
