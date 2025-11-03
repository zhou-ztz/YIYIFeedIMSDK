//
//  TGAIFeedIntroBottomSheetVC.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/10/23.
//

import Foundation
import Lottie

class TGAIFeedIntroBottomSheetVC: TGViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lottieParentView: UIView!
    @IBOutlet weak var descLabel: UILabel!
    
    lazy var movingImageView: AnimationView = {
        let view = AnimationView(name: "ai_magic")
        view.loopMode = .loop
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let roundCornerPath = UIBezierPath(roundedRect: view.bounds,
                                           byRoundingCorners: [.topLeft , .topRight],
                                           cornerRadii: CGSize(width: 16, height: 16))
        let roundCornerMask = CAShapeLayer()
        roundCornerMask.frame = view.bounds
        roundCornerMask.path = roundCornerPath.cgPath
        view.layer.mask = roundCornerMask
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.roundCorners([.topLeft, .topRight], radius: 10)
        
        titleLabel.text = "rl_ai_info".localized
        
        lottieParentView.addSubview(movingImageView)
        movingImageView.bindToEdges()
        if movingImageView.isAnimationPlaying == false {
            movingImageView.play()
        }
        
        descLabel.text = "rl_ai_desc".localized
    }
}
