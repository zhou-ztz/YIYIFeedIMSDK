//
//  CollectionAudioMsgViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/19.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK


class CollectionAudioMsgViewController: TGViewController {

    var favoriteModel: FavoriteMsgModel?
    var collectionMsgCall: deleteCollectionMsgCall?
    var dictModel: SessionDictModel?
    var audioAttachment: IMAudioCollectionAttachment?
    
    lazy var playButtonImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named:"voice_play_gray") //voice_pause_gray
        return image
    }()
    
    lazy var progressSlider: UISlider = {
        let slider = UISlider()
        slider.setMaximumTrackImage(UIImage(named:"voice_play_line"), for: .normal)
        slider.setMinimumTrackImage(UIImage(named:"voice_play_line"), for: .normal)
        slider.setThumbImage(UIImage(named:"icon_audio_duration_dot_unread"), for: .normal)
        slider.isContinuous = true
        slider.minimumValue = 0.0
        slider.addTarget(self, action: #selector(sliderAction), for: .valueChanged)
        return slider
    }()
    
    lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.font = TGAppTheme.Font.regular(TGFontSize.defaultLocationDefaultFontSize)
        label.textColor = .black
        label.text = "0:00"
        label.numberOfLines = 1
        return label
    }()
    
    var currSeconds: Int = 0
    var currMinute: Int = 0
    var index: Float = 0.0
    var labelTimer: Timer?
    var pauseTime: TimeInterval = 0.0
    var playTime: TimeInterval = 0.0
    var audioIsPaused : Bool?
    var audioTimeSeek : TimeInterval?
    var audioLeftDuration : TimeInterval?
    var audioTimeDifferent : TimeInterval?
    var filePath: String?
    init(model: FavoriteMsgModel) {
        self.favoriteModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.backItem.setTitle("title_favourite_msg_details".localized, for: .normal)
        setupRightNavItem()
        view.backgroundColor = UIColor(red: 247, green: 247, blue: 247)
        self.audioAttachmentFor(josnStr: self.favoriteModel?.data ?? "")
        self.saveAudioLocal()
        NIMSDK.shared().mediaManager.add(self)
        self.setupRightNavItem()
        self.setUI()
    }
    
    func setupRightNavItem() {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(onMore), for: .touchUpInside)
        button.setImage(UIImage(named: "buttonsMoreDotBlack"), for: .normal)
        button.sizeToFit()
        
        self.customNavigationBar.setRightViews(views: [button])
    }
    @objc func onMore() {
        let items: [IMActionItem] = [.collect_forward, .collect_delete]
        if (items.count > 0 ) {
            let view = IMActionListView(actions: items)
            view.delegate = self
            
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if NIMSDK.shared().mediaManager.isPlaying() {
            NIMSDK.shared().mediaManager.stopPlay()
        }
        NIMSDK.shared().mediaManager.remove(self)
        labelTimer?.invalidate()
        labelTimer = nil
    }
    
    deinit {
        
    }
    
    func setUI(){
        let audioView = UIView()
        audioView.backgroundColor = .white
        self.backBaseView.addSubview(audioView)
        audioView.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.left.right.equalToSuperview()
            make.height.equalTo(100)
        }
        
        audioView.addSubview(playButtonImage)
        playButtonImage.snp.makeConstraints { (make) in
            make.top.equalTo(30)
            make.left.equalTo(20)
            make.width.height.equalTo(40)
        }
        
        audioView.addSubview(progressSlider)
        progressSlider.snp.makeConstraints { (make) in
            make.top.equalTo(40)
            make.left.equalTo(playButtonImage.snp_rightMargin).offset(15)
            make.right.equalTo(-20)
        }
        
        audioView.addSubview(durationLabel)
        durationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(60)
            make.left.equalTo(playButtonImage.snp_rightMargin).offset(15)
            make.right.equalTo(-20)
        }
        
        if let model = self.audioAttachment {
            self.dataUpdate(model: model)
        }
    }


    func audioAttachmentFor(josnStr: String) {
        guard let data = josnStr.data(using: .utf8) else {
            return
        }
        
        do {
            let model = try? JSONDecoder().decode(SessionDictModel.self, from: data)
            self.dictModel = model

        } catch  {
            print("jsonerror = \(error.localizedDescription)")
        }
        
        guard let dataAttach = dictModel?.attachment!.data(using: .utf8) else {
            return
        }
        do {
            let attach = try? JSONDecoder().decode(IMAudioCollectionAttachment.self, from: dataAttach)
            self.audioAttachment = attach

        } catch  {
            print("jsonerror = \(error.localizedDescription)")
        }
    }
    
    func saveAudioLocal() {
        if let url = URL(string: audioAttachment?.url ?? "") {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else { return }
                
                DispatchQueue.main.async {
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                    let name = self.audioAttachment?.md5 ?? ""
                    let ext = self.audioAttachment?.ext ?? "aac"
                    let path = "\(documentsPath)/\(name).\(ext)"
                    self.filePath = path
                    if !FileManager.default.fileExists(atPath: path), let urlPath = URL(string: path)  {
                        do {
                            try data.write(to: urlPath, options: .atomic)
                        } catch {
                            
                        }
                    }
                }
            }.resume()
        }
    }
    
    func dataUpdate(model: IMAudioCollectionAttachment) {
        playButtonImage.image = UIImage(named:"voice_play_gray")
        progressSlider.setThumbImage(UIImage(named:"icon_audio_duration_dot_readed"), for: .normal)
        
        let animationImages: [UIImage] = [UIImage(named: "voice_pause_gray")!]
        
        playButtonImage.animationImages = animationImages
        playButtonImage.animationDuration = 1.0
        playButtonImage.addAction {
            self.clickPlayButton()
        }
        
        if self.labelTimer == nil && progressSlider.value == 0 {
            let seconds: Float = Float(model.dur) / 1000.0
            progressSlider.maximumValue = seconds
            progressSlider.setValue(Float(Double(audioTimeDifferent ?? 0.0)), animated: false)

            var milliseconds = Float(model.dur)
            milliseconds = milliseconds / 1000
            currSeconds = Int(fmod(milliseconds, 60))
            currMinute = Int(fmod((milliseconds / 60), 60))
            durationLabel.text = String(format: "%d:%02d", currMinute, currSeconds)
        }
    }
    
    func setPlaying(isPlaying: Bool) {
        if isPlaying {
            playButtonImage.startAnimating()
            if (labelTimer == nil) {
                let startingValue = progressSlider.value
                currSeconds = Int(fmod(startingValue, 60))
                currMinute = Int(fmod((startingValue / 60), 60))
                durationLabel.text = String(format: "%01d:%02d", currMinute, currSeconds)
                let timer = Timer.scheduledTimer(timeInterval: TimeInterval(Float(1) / 60), target: self, selector: #selector(timerCountDown), userInfo: nil, repeats: true)
                RunLoop.current.add(timer, forMode: .common)
                labelTimer = timer
            }
            
            
        } else {
            playButtonImage.stopAnimating()

            guard let model = self.audioAttachment else { return }
          
            var milliseconds = Float(model.dur)
            milliseconds = milliseconds / 1000
            currSeconds = Int(fmod(milliseconds, 60))
            currMinute = Int(fmod((milliseconds / 60), 60))

            durationLabel.text = String(format: "%01d:%02d", currMinute, currSeconds)
            if progressSlider.value == progressSlider.maximumValue {
                progressSlider.setValue(0, animated: true)
            }
            labelTimer?.invalidate()
            labelTimer = nil
        }
    }
    
    @objc func sliderAction(audioSlider: UISlider) {
        if NIMSDK.shared().mediaManager.isPlaying() {
            NIMSDK.shared().mediaManager.stopPlay()
        }
        
        let dragValue = audioSlider.value
        currSeconds = Int(fmod(dragValue, 60))
        currMinute = Int(fmod((dragValue / 60), 60))
        durationLabel.text = String(format: "%01d:%02d", currMinute, currSeconds)

        audioTimeDifferent = TimeInterval(audioSlider.value)
        let maximumValue = audioSlider.maximumValue
        audioLeftDuration = TimeInterval(maximumValue) - TimeInterval(audioTimeDifferent ?? 0.0)
        
        audioIsPaused = true
    }
    
    @objc func timerCountDown() {
        let temp = Float(1) / 60
        index = index + temp
        let indexValue = progressSlider.value + temp
        progressSlider.setValue(indexValue, animated: true)
        if index >= 1 {
            currSeconds += 1
            if currSeconds == 60 {
                currSeconds = 0
                currMinute += 1
            }
            durationLabel.text = String(format: "%d:%02d", currMinute, currSeconds)
            index = 0
        }
    }
    
    @objc func clickPlayButton() {
        
        guard let model = self.audioAttachment else { return }
      
        if NIMSDK.shared().mediaManager.isPlaying() {
            NIMSDK.shared().mediaManager.stopPlay()
            self.stopPlayingUI()
        }

        let maximumValue = progressSlider.maximumValue
        let timeDiff = Float(audioTimeDifferent ?? 0.0)
        audioTimeDifferent = TimeInterval(progressSlider.value)
        audioLeftDuration = TimeInterval(maximumValue - timeDiff)
        audioIsPaused = true
        playButtonImage.startAnimating()
        
        self.playAudio(model: model)
        setPlaying(isPlaying: labelTimer == nil)
        
    }
    
    
    func stopPlayingUI() {
        setPlaying(isPlaying: false)
        if (!NIMSDK.shared().mediaManager.isPlaying() && audioIsPaused == false) || progressSlider.value == progressSlider.maximumValue {
            progressSlider.setValue(0, animated: false)
        }
    }
    
    
    private func playAudio(model: IMAudioCollectionAttachment) {

        let milliseconds = Double(model.dur)
        let seconds = milliseconds / 1000.0
        
        if !NIMSDK.shared().mediaManager.isPlaying() {
            NIMSDK.shared().mediaManager.switch(NIMAudioOutputDevice.speaker)
            if audioIsPaused ?? false {
                audioTimeSeek = seconds - (audioLeftDuration ?? 0.0)
                if let path = self.filePath {
                    NIMSDK.shared().mediaManager.play(path)
                    NIMSDK.shared().mediaManager.seek(audioTimeSeek ?? 0.0)
                }

            }
            playTime = Date.timeIntervalSinceReferenceDate
        } else {
            pauseTime = Date.timeIntervalSinceReferenceDate
            audioTimeDifferent = pauseTime - playTime
            NIMSDK.shared().mediaManager.stopPlay()
            audioLeftDuration = (audioLeftDuration ?? 0.0) - (audioTimeDifferent ?? 0.0)
            audioIsPaused = true
        }
        
    }

}
//ActionListDelegate
extension CollectionAudioMsgViewController: ActionListDelegate {
   
    func forwardTextIM() {
        guard let messageId = self.favoriteModel?.uniqueId else {
            return
        }
        let messageIds: [String] = [messageId]
        let configuration = TGContactsPickerConfig(title: "select_contact".localized, rightButtonTitle: "done".localized, allowMultiSelect: true, enableTeam: true, enableRecent: true, enableRobot: false, maximumSelectCount: maximumSendContactCount, excludeIds: [], members: nil, enableButtons: false, allowSearchForOtherPeople: true)
        
        let picker = TGNewContactPickerViewController(configuration: configuration, finishClosure: { (contacts) in
            
            NIMSDK.shared().v2MessageService.getMessageList(byIds: messageIds) { messages in
                let accountId = NIMSDK.shared().v2LoginService.getLoginUser() ?? ""
                for contact in contacts {
                    for originalMessage in messages {
                        let conversationId = contact.isTeam ? "\(accountId)|2|\(contact.userName)" : "\(accountId)|1|\(contact.userName)"
                        
                        let message = V2NIMMessageCreator.createForwardMessage(originalMessage)
                        NIMSDK.shared().v2MessageService.send(message, conversationId: conversationId, params: nil) { _ in
                            
                        } failure: { _ in
                            
                        }
                    }
                }
                
            }
        })
        self.navigationController?.pushViewController(picker, animated: true)
    }

    func deleteTextIM() {
        var v2collections = [V2NIMCollection]()
        let collectInfo = V2NIMCollection()
        collectInfo.createTime = self.favoriteModel?.createTime ?? 0
        collectInfo.collectionId = String(self.favoriteModel?.Id ?? 0)
        v2collections.append(collectInfo)
        
        NIMSDK.shared().v2MessageService.remove(v2collections) { [weak self] total in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8 ) {
                self.navigationController?.popViewController(animated: true)
                if let collectMsgCall = self.collectionMsgCall {
                    collectMsgCall!(self.favoriteModel)
                }
                
            }
        } failure: { error in
            
        }
       
    }
    
}

extension CollectionAudioMsgViewController: NIMMediaManagerDelegate {
    func playAudio(_ filePath: String, didBeganWithError error: Error?) {
        
    }
    func playAudio(_ filePath: String, didCompletedWithError error: Error?) {
        self.stopPlayingUI()
    }
}
