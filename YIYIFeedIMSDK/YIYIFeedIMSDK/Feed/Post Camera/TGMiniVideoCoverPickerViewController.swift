//
//  TGMiniVideoCoverPickerViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/16.
//

import UIKit
import AVFoundation
import SnapKit

protocol MiniVideoCoverPickerDelegate: AnyObject {
    func coverImageDidPicked(_ image: UIImage)
}

class TGMiniVideoCoverPickerViewController: UIViewController {

    private let previewView = UIView()
    private let bottomSubView = UIView()
    private let selectorView = UIView()
    private let cancelBtn = UIButton(type: .system)
    private let doneBtn = UIButton(type: .system)

    private(set) var asset: AVAsset
    weak var delegate: MiniVideoCoverPickerDelegate?

    private lazy var selectorThumbView = ThumbSelectorView().configure {
        $0.thumbBorderColor = RLColor.main.theme
    }
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?

    init(asset: AVAsset) {
        self.asset = asset
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupPlayer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player = nil
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = previewView.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectorThumbView.regenerateThumbnails()
    }

    @objc private func cancelBtnTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func doneBtnTapped() {
        guard let selectedTime = selectorThumbView.selectedTime else {
            return
        }
        let generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        generator.appliesPreferredTrackTransform = true

        var actualTime = CMTime.zero
        if let image = try? generator.copyCGImage(at: selectedTime, actualTime: &actualTime) {
            let selectedImage = UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .up)
            delegate?.coverImageDidPicked(selectedImage)
            dismiss(animated: true)
        }
    }

    private func setupUI() {
        view.backgroundColor = .black

        // Add subviews
        view.addSubview(previewView)
        view.addSubview(bottomSubView)
        view.addSubview(cancelBtn)
        view.addSubview(doneBtn)
        bottomSubView.addSubview(selectorView)
        
        // Set up SnapKit constraints
        previewView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight * 0.75)
        selectorThumbView.frame = CGRect(origin: .zero, size: CGSize(width: ScreenWidth, height: 60))
        selectorView.addSubview(selectorThumbView)
        selectorThumbView.bindToEdges()
        selectorThumbView.asset = asset
        selectorThumbView.delegate = self
        
        bottomSubView.snp.makeConstraints { make in
            make.top.equalTo(previewView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }

        selectorView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.height.equalTo(60)
        }

        cancelBtn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(30)
        }

        doneBtn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(30)
        }

        // Set up button styles
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnTapped), for: .touchUpInside)

        doneBtn.setTitle("Done", for: .normal)
        doneBtn.setTitleColor(.white, for: .normal)
        doneBtn.addTarget(self, action: #selector(doneBtnTapped), for: .touchUpInside)
    }

    private func setupPlayer() {
        let avPlayerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: avPlayerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        previewView.layer.addSublayer(playerLayer!)
    }
}

extension TGMiniVideoCoverPickerViewController: ThumbSelectorViewDelegate {
    func didChangeThumbPosition(_ imageTime: CMTime) {
        player?.seek(to: imageTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
}
