//
//  RLAudioCallController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/27.
//

import UIKit
import NIMSDK
import NERtcSDK

class RLAudioCallController: RLAudioVideoCallViewController {
    
    // 使用懒加载方式创建UI控件
    lazy var switchVideoBtn: UIButton = {
        let button = UIButton()
        button.setTitle("视频模式", for: .normal)
        button.setImage(UIImage.set_image(named: "ic_switch_video"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 17.5 // 根据实际需要调整
        button.addTarget(self, action: #selector(switchToVideoMode), for: .touchUpInside)
        return button
    }()
    
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "连接中，请稍候..."
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 27)
        label.textColor = .white
        return label
    }()
    
    lazy var userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 53 // 根据实际需要调整
        return imageView
    }()
    
    lazy var muteBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.set_image(named: "btn_mute_normal"), for: .normal)
        button.setImage(UIImage.set_image(named: "btn_mute_pressed"), for: .selected)
        button.addTarget(self, action: #selector(mute), for: .touchUpInside)
        return button
    }()
    
    lazy var speakerBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.set_image(named: "btn_speaker_normal"), for: .normal)
        button.setImage(UIImage.set_image(named: "btn_speaker_pressed"), for: .selected)
        button.addTarget(self, action: #selector(userSpeaker), for: .touchUpInside)
        return button
    }()
    
    lazy var hangUpBtn: UIButton = {
        let button = UIButton()
        return button
    }()
    
    lazy var acceptBtn: UIButton = {
        let button = UIButton()
        return button
    }()
    
    lazy var refuseBtn: UIButton = {
        let button = UIButton()
        return button
    }()
    
    override init(callee: String, callType: NIMSignalingChannelType = .audio) {
        super.init(callee: callee, callType: callType)
    }
    
    override init(caller: String, channelId: String, channelName: String, requestId: String, callType: NIMSignalingChannelType = .audio) {
        super.init(caller: caller, channelId: channelId, channelName: channelName, requestId: requestId, callType: callType)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.088, green: 0.070, blue: 0.118, alpha: 1.00)
        
        // 添加子视图
        view.addSubview(switchVideoBtn)
        view.addSubview(usernameLabel)
        view.addSubview(userProfileImageView)
        view.addSubview(muteBtn)
        view.addSubview(speakerBtn)
        view.addSubview(hangUpBtn)
        view.addSubview(acceptBtn)
        view.addSubview(refuseBtn)
        
        // 使用SnapKit设置约束
        switchVideoBtn.snp.makeConstraints { make in
            make.left.equalTo(15) // 根据实际需要调整
            make.top.equalTo(53) // 根据实际需要调整
            make.height.equalTo(35) // 根据实际需要调整
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(231) // 根据实际需要调整
            make.height.equalTo(60) // 根据实际需要调整
        }
        
        userProfileImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(106) // 根据实际需要调整
        }
        
        
//        muteLabel.text = "mute".localized
//        speakerLabel.text = "speaker".localized

        switchVideoBtn.setTitle("avchat_switch_to_video".localized, for: .normal)
        switchVideoBtn.setImage(UIImage.set_image(named: "ic_switch_video"), for: .normal)
        //
        muteBtn.setBackgroundImage(UIImage.set_image(named: "btn_mute_pressed"), for: .selected)
        muteBtn.setBackgroundImage(UIImage.set_image(named: "btn_mute_normal"), for: .normal)
        
        let refuse_image = UIImage.set_image(named: "icon_decline")
        refuseBtn.setBackgroundImage(refuse_image, for: .normal)

        let accept_image = UIImage.set_image(named: "icon_accept")
        acceptBtn.setBackgroundImage(accept_image, for: .normal)

        let hangUp_image = UIImage.set_image(named: "icon_reject")
        hangUpBtn.setBackgroundImage(hangUp_image, for: .normal)

        switchVideoBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        hangUpBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(70)
            make.bottom.equalTo(-TSBottomSafeAreaHeight - 40)
        }
        refuseBtn.snp.makeConstraints { make in
            make.left.equalTo(69)
            make.width.height.equalTo(70)
            make.bottom.equalTo(-TSBottomSafeAreaHeight - 40)
        }
        acceptBtn.snp.makeConstraints { make in
            make.right.equalTo(-69)
            make.width.height.equalTo(70)
            make.bottom.equalTo(-TSBottomSafeAreaHeight - 40)
        }
        
        muteBtn.snp.makeConstraints { make in
            make.left.equalTo(79)
            make.bottom.equalTo(acceptBtn.snp.top).offset(-30)
            make.width.height.equalTo(50)
        }
        
        speakerBtn.snp.makeConstraints { make in
            make.right.equalTo(-79)
            make.bottom.equalTo(acceptBtn.snp.top).offset(-30)
            make.width.height.equalTo(50)
        }
    }
    
    @objc func switchToVideoMode() {
        // 切换到视频模式的逻辑
    }
    
    @objc func mute() {
        // 静音的逻辑
    }
    
    @objc func userSpeaker() {
        // 使用扬声器的逻辑
    }
    
    @objc func hangup() {
        // 挂断电话的逻辑
    }
    
    @objc func acceptToCall() {
        // 接受来电的逻辑
    }
    
    
}
