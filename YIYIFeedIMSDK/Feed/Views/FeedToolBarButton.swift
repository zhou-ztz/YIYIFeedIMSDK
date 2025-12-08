//
//  FeedToolBarButton.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/29.
//

import UIKit

class FeedToolBarButton: UIView {
    
    let imageView: UIImageView = UIImageView(frame: .zero).configure {
        $0.contentMode = .scaleAspectFit
    }
    let titleLabel: UILabel = UILabel().configure {
        $0.font = UIFont.systemFont(ofSize: 10)
    }
    private let stackview = UIStackView().configure {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 3
    }
    
    init() {
        super.init(frame: .zero)
        addSubview(stackview)
        stackview.bindToEdges()
        
        stackview.addArrangedSubview(imageView)
        stackview.addArrangedSubview(titleLabel)
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FeedListCollectionViewCell: UICollectionViewCell {
    
    static let cellIdentifier = "FeedListCollectionViewCell"
    
    var likeButtonClickCall: (() -> ())?
    
    private let pictureView = UIImageView().configure {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    private let feedVideoIcon = UIImageView().configure {
        $0.image = UIImage(named: "ic_feed_video_icon")
    }
    private let bottomStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 5
        return stack
    }()
    
    let avatarNameStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 5
        return stack
    }()
    

    var avatarView: AvatarUserNameView = AvatarUserNameView(frame: .zero, avatarWidth: 27.0)
    
    lazy var contentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .black
        lab.font = UIFont.boldSystemFont(ofSize: 15)
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    /// 设置视图
    private func setUI() {
        //封面图
        contentView.addSubview(pictureView)
        //视频标识
        feedVideoIcon.isHidden = true
        contentView.addSubview(feedVideoIcon)
        //动态内容
        contentView.addSubview(contentLabel)
        
        //用户头像、用户昵称
        contentView.addSubview(bottomStackView)
        
        bottomStackView.addArrangedSubview(avatarView)
        //点赞
        bottomStackView.addArrangedSubview(likeBtn)
        
        
        bottomStackView.snp.makeConstraints {
            $0.bottom.equalTo(-10)
            $0.left.right.equalToSuperview().offset(0)
            $0.height.equalTo(27)
        }
        
        contentLabel.snp.makeConstraints {
            $0.bottom.equalTo(bottomStackView.snp.top)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        pictureView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(contentLabel.snp.top).offset(0)
        }
        
        feedVideoIcon.snp.makeConstraints {
            $0.top.equalTo(pictureView.snp.top).offset(5)
            $0.right.equalTo(pictureView.snp.right).offset(-5)
            $0.height.width.equalTo(35)
        }
 
        likeBtn.snp.makeConstraints {
            $0.width.equalTo(25)
        }
        
        likeBtn.addAction {
            self.likeButtonClickCall?()
        }
    }
    
//    public func setData(data: FeedModelDataList){
//        
//        avatarView.setData(data: data)
//      
//        contentLabel.text = data.content
//        
//        if data.image.count > 0 {
//            pictureView.sd_setImage(with: URL(string: data.image[0]), placeholderImage: UIImage(named: "icPicturePostPlaceholder"))
//        }
//        likeBtn.titleLabel.text = data.countStart.stringValue
//        feedVideoIcon.isHidden = (data.videoLink?.isEmpty ?? true)
//        likeBtn.imageView.image = data.relevanceId != 0 ? UIImage(named: "heart")! :  UIImage(named: "IMG_home_ico_love")!
//    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}
