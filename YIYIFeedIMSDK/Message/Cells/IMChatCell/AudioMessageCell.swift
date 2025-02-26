//
//  AudioMessageCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/5.
//

import UIKit
import NIMSDK

class AudioMessageCell: BaseMessageCell {
    
    var messageId: String?

    let leftSeparatorColor = UIColor(red: 216.0/255.0, green: 216.0/255.0, blue: 216.0/255.0, alpha: 1)
    let rightSeparatorColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1)
    
    lazy var playButtonImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.set_image(named: "voice_play_blue")
        return image
    }()
    var maximumValue: Float = 0.0
    var progressValue: Float = 0.0
    lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemMediumFont(ofSize: 9)
        label.textColor = UIColor(hex: 0x212121)
        label.text = "0:00"
        label.numberOfLines = 1
        return label
    }()
    //音高波纹
    var msgStateView: IMAudioMessageStateView = IMAudioMessageStateView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    
    lazy var selectionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemRegularFont(ofSize: 9)
        label.textColor = .black
        label.text = ""
        label.numberOfLines = 1
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = leftSeparatorColor
        return view
    }()
    
    var currSeconds: Int = 0
    var currMinute: Int = 0
    var index: Float = 0.0
    var labelTimer: Timer?
    var pauseTime: TimeInterval = 0.0
    var playTime: TimeInterval = 0.0
    var levels: [Float] = []


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      commonUI()
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func commonUI() {
        bubbleImage.addSubview(playButtonImage)
        bubbleImage.addSubview(msgStateView)
        bubbleImage.addSubview(durationLabel)
        bubbleImage.addSubview(timeTickStackView)
        bubbleImage.addSubview(separatorView)
        bubbleImage.addSubview(selectionLabel)
        
        playButtonImage.snp.makeConstraints { make in
            make.left.top.equalTo(10)
            make.width.height.equalTo(25)
        }
        msgStateView.snp.makeConstraints { make in
            make.centerY.equalTo(playButtonImage.snp.centerY)
            make.height.equalTo(30)
            make.right.equalTo(-10)
            make.left.equalTo(playButtonImage.snp.right).offset(8)
        }
        durationLabel.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(playButtonImage.snp.bottom).offset(8)
        }
        timeTickStackView.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.centerY.equalTo(durationLabel.snp.centerY)
        }
        
        separatorView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalTo(durationLabel.snp.bottom).offset(8)
            make.height.equalTo(1)
        }
        
        selectionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(8)
            make.top.equalTo(separatorView.snp.bottom).offset(8)
            make.bottom.equalTo(-8)
        }
        
        selectionLabel.attributedText = "setting_language".localized.attributonString().setlineSpacing(10)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectionTapFunction))
        selectionLabel.addGestureRecognizer(tap)
        
        let animationImages: [UIImage] = [UIImage.set_image(named: "voice_pause_gray")!]
        
        playButtonImage.animationImages = animationImages
        playButtonImage.animationDuration = 1.0
        playButtonImage.addAction {
            self.clickPlayButton()
        }
    }
    
    @objc func selectionTapFunction(sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.2) {
            self.selectionLabel.textColor = .purple
        }
        self.delegate?.selectionLanguageTapped(cell: self, model: self.contentModel)
    }
    
    @objc func clickPlayButton() {
        self.delegate?.startAudioPlay(cell: self, model: self.contentModel)
    }

    override func setData(model: TGMessageData) {
        super.setData(model: model)
        guard let message = model.nimMessageModel, let audioObject = message.attachment as? V2NIMMessageAudioAttachment else { return }
        let isRight = message.isSelf
        separatorView.backgroundColor = !isRight ? leftSeparatorColor : rightSeparatorColor
        messageId = message.messageClientId
        if (message.sendingState == .MESSAGE_SENDING_STATE_SUCCEEDED  && !isRight) {
            playButtonImage.image = UIImage.set_image(named: "voice_play_blue")
        } else {
            playButtonImage.image = UIImage.set_image(named: "voice_play_gray")
        }
        let seconds: Float = Float(audioObject.duration) / 1000.0
        self.maximumValue = seconds

        msgStateView.clearAllView()
        handleAudioJson(jsonString: message.serverExtension, duration: Int(audioObject.duration))
        if let currentMessage = IMAudioCenter.shared.currentMessage , currentMessage.messageClientId ==  self.contentModel?.nimMessageModel?.messageClientId {
            startAnimation(model: self.contentModel)
        } else {
            stopAnimation(model: self.contentModel)
        }
        
    }
    ///处理拓展
    func handleAudioJson(jsonString: String?, duration: Int){
        if let ext = jsonString, let jsonData = ext.data(using: .utf8) {
            do {
                let dict = try JSONSerialization.jsonObject(with: jsonData, options: [])
                
                if let dict = dict as? [String: Any], let audioJson = dict["voice"] as? String {
                    if let audioData = audioJson.data(using: .utf8) {
                        do {
                            let voice = try JSONDecoder().decode(VoiceDBBean.self, from: audioData)
                            let levels = voice.dbList.map({Float( Float($0) / 100)})
                            msgStateView.duration = duration / 1000
                            msgStateView.currentLevels = levels
                            self.levels = levels
                            let levelWidth = self.levels.count * 5
                            msgStateView.snp.makeConstraints { make in
                                make.width.equalTo(levelWidth < 100 ? 100 : levelWidth)
                            }

                        } catch {
                           
                        }
                    }
                }
                
            } catch {

            }
            
        }
    }
    
    func timerCountDown() {
        
        guard let currentMessage = IMAudioCenter.shared.currentMessage , currentMessage.messageClientId ==  self.contentModel?.nimMessageModel?.messageClientId else { return }
        
        let progress = IMAudioCenter.shared.progressValue * IMAudioCenter.shared.maximumValue
        self.msgStateView.updateLevelColor(CGFloat(progress))
        
        currSeconds = Int(fmod(progress, 60))
        currMinute = Int(fmod((progress / 60), 60))
        durationLabel.text = String(format: "%01d:%02d", currMinute, currSeconds)

    }
    
    func startAnimation(model: TGMessageData?){
        playButtonImage.startAnimating()
        self.contentModel?.isPlaying = true
        self.timerCountDown()
    }
    
    func stopAnimation(model: TGMessageData?){
   
        playButtonImage.stopAnimating()
        
        self.msgStateView.resetLevelColor()
        guard let message = self.contentModel?.nimMessageModel , let object = message.attachment as? V2NIMMessageAudioAttachment else { return }
        
        var milliseconds = Float(object.duration)
        milliseconds = milliseconds / 1000
        currSeconds = Int(fmod(milliseconds, 60))
        currMinute = Int(fmod((milliseconds / 60), 60))

        durationLabel.text = String(format: "%01d:%02d", currMinute, currSeconds)
        self.contentModel?.isPlaying = false
        
    }
}

class IMAudioCenter: NSObject {
    
    static let shared = IMAudioCenter()
    
    var currentMessage: V2NIMMessage? = nil
    
    var progressValue: Float = 0.0
    
    var maximumValue: Float = 0.0

    override init() {
        super.init()
    }
    
    func clearAll() {
        currentMessage = nil
        progressValue = 0.0
        maximumValue = 0.0
    }
}


