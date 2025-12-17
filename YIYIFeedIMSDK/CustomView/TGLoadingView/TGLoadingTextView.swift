//
//  TGLoadingTextView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/12/15.
//

import UIKit

class TGLoadingTextView: UIView {
    private let label = UILabel()
    private var contentStack: UIStackView!

    public var texts: [String] = [] {
        didSet {
            startTimers()
            baseTextIndex = 0
            currentDotCount = 0
            updateLabelText()
        }
    }

    private var baseTextIndex = 0
    private var currentDotCount = 0
    private var dotTimer: Timer?
    private var baseTextTimer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentStack = UIStackView()
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(hex: 0xFFFFFF)
        label.textAlignment = .center
        contentStack.addArrangedSubview(label)

        addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
        ])
    }

    private func startTimers() {
        dotTimer?.invalidate()
        baseTextTimer?.invalidate()

        currentDotCount = 0
        baseTextIndex = 0

        // Animate dots every 0.4s
        dotTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            self.updateLabelText()
        }

        // Change base text every 2.4s
        baseTextTimer = Timer.scheduledTimer(withTimeInterval: 2.4, repeats: true) { _ in
            self.baseTextIndex = (self.baseTextIndex + 1) % self.texts.count
            self.currentDotCount = 0 // Reset dot count when base text changes
        }

        updateLabelText()
    }

    private func updateLabelText() {
        guard !texts.isEmpty, let raw = texts[safe: baseTextIndex] else { return }

        let baseText = raw.replacingOccurrences(of: "...", with: "")
        currentDotCount = (currentDotCount % 3) + 1
        let dots = String(repeating: ".", count: currentDotCount)

        label.text = baseText + dots
    }

    public func restartAnimation() {
        startTimers()
    }

    public func updateTitleContent(title: String) {
        dotTimer?.invalidate()
        baseTextTimer?.invalidate()
        currentDotCount = 0
        baseTextIndex = 0
        label.text = title
    }

    deinit {
        dotTimer?.invalidate()
        baseTextTimer?.invalidate()
    }
}
