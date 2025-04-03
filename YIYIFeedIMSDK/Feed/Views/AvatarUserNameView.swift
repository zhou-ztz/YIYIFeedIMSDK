//
//  AvatarUserNameView.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/29.
//

import UIKit

class AvatarUserNameView: UIView {

    /// 头像尺寸
    var avatarWidth = 27.0
    
    let avatarNameStackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 5
    }
    
    lazy var avatarView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage.set_image(named: "IMG_pic_default_secret")
        img.contentMode = .scaleAspectFit
        img.backgroundColor = .gray
    
        return img
    }()
    
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .black
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.numberOfLines = 1
        lab.text = ""
        return lab
    }()
    

    init(frame: CGRect, avatarWidth: CGFloat) {
        super.init(frame: frame)
        self.avatarWidth = avatarWidth
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setupUI(){
        
        avatarView.layer.cornerRadius = avatarWidth / 2
        avatarView.layer.masksToBounds = true
        
        self.addSubview(avatarNameStackView)
        avatarNameStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        avatarNameStackView.addArrangedSubview(avatarView)
        avatarNameStackView.addArrangedSubview(nameLabel)
        avatarView.snp.makeConstraints { make in
            make.width.height.equalTo(self.avatarWidth)
        }
        
        
    }
    
    public func setData(data: FeedListCellModel){
        avatarView.sd_setImage(with: URL(string: data.avatarInfo?.avatarURL ?? ""), placeholderImage: UIImage.set_image(named: "IMG_pic_default_secret"))
        nameLabel.text = data.avatarInfo?.username ?? ""
    }
}
