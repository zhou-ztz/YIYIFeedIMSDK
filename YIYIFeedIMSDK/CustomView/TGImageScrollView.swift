//
//  TGImageScrollView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/20.
//

import UIKit
import SDWebImage

class TGImageScrollView: UIScrollView, UIScrollViewDelegate {

    private let minZoom: CGFloat = 1.0
    private let maxZoom: CGFloat = 3.0

    let imageView: SDAnimatedImageView = SDAnimatedImageView()
    var onZoomUpdate: EmptyClosure?


    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        guard let superview = self.superview else { return }
        self.bindToEdges()
        self.snp.makeConstraints { v in
            v.width.equalToSuperview()
            v.height.equalToSuperview()
        }

        self.layoutIfNeeded()
    }

    private func commonInit() {
        delegate = self

        imageView.contentMode = .scaleAspectFit

        addSubview(imageView)
        imageView.bindToEdges()
        imageView.snp.makeConstraints { v in
            v.width.equalToSuperview()
            v.height.equalToSuperview()
        }
        minimumZoomScale = minZoom
        maximumZoomScale = maxZoom

        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }

    func resetZoom() {
        setZoomScale(1.0, animated: true)
    }

    func toggleZoom() {
        if zoomScale > 1.0 {
            setZoomScale(1.0, animated: true)
        } else {
            setZoomScale(2.0, animated: true)
        }
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > minimumZoomScale {
            onZoomUpdate?()
        }
    }

    // Tell the scroll view delegate which view to use for zooming and scrolling
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}
