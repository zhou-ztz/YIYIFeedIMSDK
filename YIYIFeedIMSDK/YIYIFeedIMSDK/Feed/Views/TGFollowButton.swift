//
//  TGFollowButton.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/20.
//

import UIKit

class TGFollowButton: LoadableButton {

    private let widthInset: CGFloat = 12.0
    private let heightInset: CGFloat = 3.5

//    override var intrinsicContentSize: CGSize {
//        let current = super.intrinsicContentSize
//
//        return CGSize(width: widthInset*2 + current.width, height: heightInset*2 + current.height)
//    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setTitle("display_follow".localized)
        self.setTitleColor(.white, for: .normal)

        // Set button contents
        self.titleLabel?.font = UIFont.systemRegularFont(ofSize: 12)
        self.bgColor = RLColor.main.red
        self.backgroundColor =  RLColor.main.red
        self.contentEdgeInsets = UIEdgeInsets(top: heightInset, left: widthInset, bottom: heightInset, right: widthInset)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.cornerRadius = self.bounds.height / 2
        self.roundCorner(self.cornerRadius)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        layoutSubviews()
    }

}
