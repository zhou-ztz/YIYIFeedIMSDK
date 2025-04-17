//
//  TGUserReactionView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/20.
//

import UIKit

class TGUserReactionView: UIView {

    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 3
        stack.backgroundColor = .clear

        return stack
    }()

    private let iconStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = -5
        stack.backgroundColor = .clear
        stack.transform = CGAffineTransform(scaleX: -1, y: 1)
        return stack
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.applyStyle(.regular(size: 12, color: TGAppTheme.warmGrey))

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.backgroundColor = .clear
//        self.bindToEdges()
        self.addSubview(containerStack)
        containerStack.addArrangedSubview(iconStack)
        containerStack.addArrangedSubview(label)

        containerStack.bindToEdges()
    }

    func setData(reactionIcon: [ReactionTypes?], totalReactionCount: Int, labelTextColor: UIColor? = nil, isInnerFeed: Bool = false) {
        let maxIcon = 3
        iconStack.removeAllArrangedSubviews()
        let count = (reactionIcon.count > 0) ? min(reactionIcon.count, maxIcon) : 1
        for (index, reaction) in reactionIcon.enumerated() {
            let imageView = UIImageView()
            
            let reactionImageMap: [ReactionTypes: String] = [
                .heart: "love",
                .wow: "wow",
                .angry: "angry",
                .awesome: "yay",
                .cry: "cry"
            ]

            if let reaction = reaction {
                if let baseImageName = reactionImageMap[reaction] {
                    imageView.image = UIImage(named: isInnerFeed ? "\(baseImageName)_black" : baseImageName)
                } else {
                    imageView.image = UIImage(named: isInnerFeed ? "love_black" : "love")
                }
                print("Index: \(index), Reaction: \(reaction)")
            } else {
                imageView.image = UIImage(named: isInnerFeed ? "love_black" : "love")
                print("Index: \(index), Reaction is nil")
            }

            iconStack.addArrangedSubview(imageView)
            imageView.snp.makeConstraints {
                $0.width.height.equalTo(18)
            }
        }
        if let color = labelTextColor {
            label.textColor = color
        }
        label.text = String(format: "number_of_people_reacted".localized, totalReactionCount.stringValue)
        label.sizeToFit()

        setNeedsLayout()
        layoutIfNeeded()
    }

}
