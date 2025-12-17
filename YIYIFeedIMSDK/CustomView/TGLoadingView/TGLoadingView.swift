//
//  TGLoadingView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/12/15.
//

import Foundation
import Lottie

class TGLoadingView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingTextView: TGLoadingTextView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var retryButton: UIButton!
    
    private let viewTag = 999_002  // Any unique integer
    
    private let movingImageView = AnimationView()
    var onCancel: TGEmptyClosure?
    var onRetry: TGEmptyClosure?
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        let bundle = Bundle(identifier: "com.yiyi.feedimsdk") ?? Bundle.main
        bundle.loadNibNamed(String(describing: TGLoadingView.self), owner: self, options: nil)
        contentView.backgroundColor = .clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        backgroundColor = UIColor.black.withAlphaComponent(0.65)
        tag = viewTag
        
        movingImageView.animation = Animation.named("AI_Loading")
        movingImageView.loopMode = .loop
        movingImageView.contentMode = .scaleAspectFit
        parentView.addSubview(movingImageView)
        movingImageView.bindToEdges()
        
        movingImageView.play()
        
        descriptionLabel.text = "ai_desc_label".localized
        
        retryButton.applyBorder(color: UIColor(hex: 0xFFFFFF).withAlphaComponent(0.25), width: 1.0)
        retryButton.setText(text: "try_again".localized, font: UIFont.systemFont(ofSize: 12, weight: .semibold), color: UIColor(hex: 0xFFFFFF))
        
        cancelButton.applyBorder(color: UIColor(hex: 0xFFFFFF).withAlphaComponent(0.25), width: 1.0)
        cancelButton.setText(text: "cancel".localized, font: UIFont.systemFont(ofSize: 12, weight: .semibold), color: UIColor(hex: 0xFFFFFF))
    }
    
    func show(in parentView: UIView) {
        // If already present in the view hierarchy
        if let existingView = parentView.subviews.first(where: { $0.tag == self.viewTag }) as? TGLoadingView {
            // If new banners passed, update the content
            return
        }
        
        // Start with the content view scaled down and transparent
        contentView.alpha = 0
        contentView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        let navBarHeight = parentView.parentViewController?.navigationController?.navigationBar.frame.height ?? 0
        let safeTop = parentView.safeAreaInsets.top
        let safeBottom = parentView.safeAreaInsets.bottom
        let screenHeight = ScreenHeight

        let availableHeight = screenHeight - navBarHeight - safeTop - safeBottom

        var currentFrame = parentView.frame
        currentFrame.size.width = ScreenWidth
        currentFrame.size.height = availableHeight
        frame = currentFrame
        parentView.addSubview(self)
        
        // Animate the appearance with fade and scale
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
            self.contentView.alpha = 1
            self.contentView.transform = CGAffineTransform.identity
        })
    }
    
    func show() {
        guard let window = UIApplication.shared.windows.first else { return }

        DispatchQueue.main.async {
            // Avoid duplicate
            if window.subviews.contains(where: { $0.tag == self.viewTag }) { return }

            // Match window bounds
            self.frame = window.bounds
            self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.contentView.alpha = 0
            self.contentView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

            window.addSubview(self)
            window.bringSubviewToFront(self)

            // Animate appearance
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseInOut,
                           animations: {
                self.contentView.alpha = 1
                self.contentView.transform = .identity
            })
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.contentView.alpha = 0
            self.contentView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    func updateAnimationItems(items: [String]) {
        loadingTextView.texts = items
    }
    
    func updateContent(title: String, desc: String) {
        imageView.makeVisible()
        movingImageView.makeHidden()
        loadingTextView.updateTitleContent(title: title)
        descriptionLabel.text = desc
    }
    
    func restartAnimation() {
        imageView.makeHidden()
        movingImageView.makeVisible()
        loadingTextView.restartAnimation()
        descriptionLabel.text = "ai_desc_label".localized
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        onCancel?()
    }
    
    @IBAction func retryAction(_ sender: Any) {
        onRetry?()
    }
}
