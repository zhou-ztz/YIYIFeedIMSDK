//
//  TGPreviewVideoVC.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/16.
//

import UIKit
import SnapKit
import AVKit

protocol TGPreviewVideoVCDelegate: AnyObject {
    func previewDeleteVideo()
}

class TGPreviewVideoVC: TGViewController {
    var avasset: AVAsset? // 资源需通过 AVPlayerItem 播放
    private var avPlayer: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    private let playerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    private let playIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ico_video_play_fullscreen")
        return imageView
    }()
    private let deleteBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("delete".localized, for: .normal)
        button.setTitleColor(UIColor(red: 0.35, green: 0.71, blue: 0.84, alpha: 1), for: .normal)
        return button
    }()
    private let backBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "IMG_topbar_back_white"), for: .normal)
        return button
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "photo_select_preview".localized
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    weak var delegate: TGPreviewVideoVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPlayer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
//        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        avPlayer?.pause()
        navigationController?.isNavigationBarHidden = false
//        if #available(iOS 13.0, *) {
//            UIApplication.shared.statusBarStyle = .darkContent
//        } else {
//            UIApplication.shared.statusBarStyle = .default
//        }
    }
    deinit {
         // 移除通知
         NotificationCenter.default.removeObserver(self)
     }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(playerView)
        view.addSubview(playIcon)
        view.addSubview(deleteBtn)
        view.addSubview(backBtn)
        view.addSubview(titleLabel)

        deleteBtn.addTarget(self, action: #selector(deleteBtnAction), for: .touchUpInside)
        backBtn.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
        
        playerView.frame = self.view.bounds

        playIcon.snp.makeConstraints { make in
            make.center.equalTo(playerView)
            make.width.height.equalTo(40)
        }

        backBtn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(15)
            make.width.height.equalTo(20)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backBtn)
        }

        deleteBtn.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-15)
            make.centerY.equalTo(backBtn)
        }
    }

    private func setupPlayer() {
        
        guard let avasset = avasset else { return }
        // 初始化 AVPlayerItem 和 AVPlayer
        let playerItem = AVPlayerItem(asset: avasset)
        avPlayer = AVPlayer(playerItem: playerItem)
        // 配置 AVPlayerLayer 并添加到 playerView
        playerLayer = AVPlayerLayer(player: avPlayer)
        playerLayer?.videoGravity = .resizeAspect
        playerLayer?.frame = playerView.bounds
        if let playerLayer = playerLayer {
            playerView.layer.addSublayer(playerLayer)
        }
        self.setupPlayerObservers(playerItem: playerItem)
        
        // 添加点击手势控制播放/暂停
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playerViewTapped))
        playerView.addGestureRecognizer(tapGesture)

    }
    private func setupPlayerObservers(playerItem: AVPlayerItem) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }
    @objc private func playerViewTapped() {
        guard let avPlayer = avPlayer else { return }
        if avPlayer.timeControlStatus == .paused {
            avPlayer.play()
            playIcon.isHidden = true
        } else {
            avPlayer.pause()
            playIcon.isHidden = false
        }
    }

    @objc private func backBtnAction() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func deleteBtnAction() {
        delegate?.previewDeleteVideo()
        navigationController?.popViewController(animated: true)
    }

    @objc private func playerDidFinishPlaying(notification: Notification) {
        self.avPlayer?.seek(to: .zero)
        self.avPlayer?.play()
    }
    
    
}
