//
//  TGTutorialView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/20.
//

import UIKit
import Lottie

class TGTutorialView: UIView {

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemMediumFont(ofSize: 14)
        label.text = "inner_feed_on_boarding_hint".localized
        return label
    }()
    
    private let lottieView = AnimationView()
    
    private lazy var container: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 0
        view.alignment = .center
        return view
    }()
    
    var onDismiss: EmptyClosure?
    
    init() {
        super.init(frame: .zero)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        self.addTap { _ in
            self.stop()
        }
        
        self.addSubview(container)
        container.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        container.addArrangedSubview(lottieView)
        container.addArrangedSubview(label)
        
        lottieView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(150)
        }
    }
    
    func play() {
        lottieView.animation = Animation.named("guide")
        lottieView.loopMode = .loop
        lottieView.contentMode = .scaleAspectFit
        lottieView.play()
    }
    
    func stop() {
        onDismiss?()
        lottieView.stop()
        self.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
