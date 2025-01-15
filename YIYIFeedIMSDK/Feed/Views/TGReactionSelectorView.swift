//
//  TGReactionSelectorView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2024/12/30.
//

import UIKit
import Lottie

class TGReactionSelectorView: UIView {

    var stackview = UIStackView().configure { v in
        v.axis = .vertical
        v.distribution = .fill
        v.alignment = .fill
        v.spacing = 5
    }
    
    var animatedView = AnimationView().configure { v in
        v.contentMode = .scaleAspectFit
        v.loopMode = .loop
    }
    
    var imageView = UIImageView().configure { v in
        v.contentMode = .scaleAspectFit
    }
    
    var nameContentView = UIView().configure { v in
        v.backgroundColor = RLColor.share.black
    }
    
    var nameLabel = UILabel().configure { v in
        v.font = UIFont.systemFont(ofSize: 12)
        v.textColor = .white
    }
    
    init(reactionType: ReactionTypes) {
        super.init(frame: .zero)
        commonInit()
        
        imageView.addSubview(animatedView)
        animatedView.bindToEdges()
        
        imageView.image = nil
        animatedView.animation = reactionType.lottieAnimation
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(stackview)
        
        stackview.bindToEdges()
        
        nameContentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { v in
            v.top.bottom.equalToSuperview()
            v.left.right.equalToSuperview().inset(5)
        }
        
        stackview.addArrangedSubview(imageView)
        addSubview(nameContentView)
        
        nameContentView.snp.makeConstraints { (v) in
            v.bottom.equalTo(self.snp.top).offset(-5)
            v.left.right.equalToSuperview()
        }
//        stackview.insertArrangedSubview(nameContentView, at: 0)
        nameContentView.isHidden = true
        
        self.isUserInteractionEnabled = true
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            return self
        } else { return nil }
    }

}

class TGTouchAbsorbingView: UIView {
    
    var onTouchInside: EmptyClosure?
    
    private let tapgesture = UITapGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
        
    private func commonInit() {
        self.addGestureRecognizer(tapgesture)
        tapgesture.addActionBlock { [weak self] (_) in
            self?.onTouchInside?()
        }
    }
    
}
