//
//  TGReactionTableViewCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/3/31.
//

import UIKit
import SnapKit

class TGReactionTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "TGReactionTableViewCell"
    
    lazy var avatarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    lazy var captionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = TGAppTheme.brownGrey
        return label
    }()
    
    lazy var reactionImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, captionLabel])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()
    
    lazy var avatarView: TGAvatarView = {
        let img = TGAvatarView()
        return img
    }()

    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(avatarContainer)
        contentView.addSubview(textStack)
        contentView.addSubview(reactionImageView)
        
        avatarContainer.addSubview(avatarView)
    }
    
    private func setupConstraints() {
        // Avatar Container
        avatarContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(31)
        }
        
        // Avatar View
        avatarView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Text Stack
        textStack.snp.makeConstraints { make in
            make.leading.equalTo(avatarContainer.snp.trailing).offset(16)
            make.centerY.equalTo(avatarContainer)
            make.trailing.lessThanOrEqualTo(reactionImageView.snp.leading).offset(-12)
        }
        
        // Reaction Image
        reactionImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-12)
            make.size.equalTo(24)
        }
    }

    // MARK: - Configuration
    func configure(with model: ReactionCellModel, theme: Theme) {
        setAvatar(
            urlPath: model.avatarURL,
            username: model.username,
            verifiedIcon: model.verifiedIcon,
            userId: model.userId
        )
        nameLabel.text = model.username
        captionLabel.text = model.caption
        reactionImageView.image = UIImage(named: model.reactionImageName)
        prepareUI(with: theme)
    }
    
    func setAvatar(urlPath: String, username: String, verifiedIcon: String?, userId: Int) {
        let avatarInfo = AvatarInfo(
            avatarURL: urlPath
        )
        avatarInfo.verifiedIcon = verifiedIcon ?? ""
        avatarInfo.verifiedType = "badge"
        avatarInfo.type = .normal(userId: userId)
        avatarView.avatarInfo = avatarInfo
    }
    
    func prepareUI(with theme: Theme) {
        switch theme {
        case .white:
            nameLabel.textColor = .black
            contentView.backgroundColor = .white
        case .dark:
            nameLabel.textColor = .white
            contentView.backgroundColor = TGAppTheme.materialBlack
        }
    }
}

// MARK: - Helper Types
struct ReactionCellModel {
    let avatarURL: String
    let username: String
    let caption: String
    let reactionImageName: String
    let verifiedIcon: String?
    let userId: Int
}

//extension UIColor {
//    static let brownGray = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
//    static let materialBlack = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
//}
