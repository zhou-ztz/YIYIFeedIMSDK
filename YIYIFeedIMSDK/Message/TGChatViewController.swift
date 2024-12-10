//
//  TGChatViewController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/2.
//

import UIKit
import NIMSDK
import AVFoundation
import Photos

// 发送文件大小限制(单位：MB)
let fileSizeLimit: Double = 200
//录音时长
let record_duration: TimeInterval = 60.0

class TGChatViewController: TGViewController {

    var viewmodel: TGChatViewModel
    
    lazy var tableView: UITableView = {
        let tableView = RLTableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.mj_header = SCRefreshHeader(
            refreshingTarget: self,
            refreshingAction: #selector(loadMoreData)
        )
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    let chatInputView = BaseChatInputView(frame: .zero)
    var bottomExanpndHeight: CGFloat = 204 + TSBottomSafeAreaHeight // 底部展开高度
    var normalInputHeight: CGFloat = 50.0
    //记录播放语音的cell
    private var playingCell: AudioMessageCell?
    private var playingModel: RLMessageData?
    
    let ges = UITapGestureRecognizer()

    var operationView: MessageOperationView?
    var replyView = ReplyView()
 
    lazy var enterInfoBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(UIImage.set_image(named: "more")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setImage(UIImage.set_image(named: "more")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
        button.tintColor = UIColor(hex: 0x808080)
        button.addTarget(self, action: #selector(enterPersonInfoCard), for: .touchUpInside)
        return button
    }()
    
    lazy var videoCallBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(UIImage.set_image(named: "ic_call_plus")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setImage(UIImage.set_image(named: "ic_call_plus")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
        button.tintColor = UIColor(hex: 0x808080)
        button.addTarget(self, action: #selector(callActionSheet), for: .touchUpInside)
        return button
    }()
    
    //保存识别结果
    private var receiveResult = ""
    // speech model
    var locale: Locale = .current
    var recognizedText = ""
    var isRecognitionInProgress = false
    //记录当前录制的语音
    private var saveAudioMessage: V2NIMMessage?
  
    init(conversationId: String, conversationType: V2NIMConversationType) {
        self.viewmodel = TGChatViewModel(conversationId: conversationId, conversationType: conversationType)
        super.init(nibName: nil, bundle: nil)
    }
    init(conversationId: String, conversationType: V2NIMConversationType, anchor: V2NIMMessage?) {
        self.viewmodel = TGChatViewModel(conversationId: conversationId, conversationType: conversationType, anchor: anchor)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserve()
        commonUI()
        loadData()
    }
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        operationView?.removeFromSuperview()
    }

    func addObserve() {
        NIMSDK.shared().mediaManager.add(self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    //    MARK: 键盘通知相关操作
    @objc func keyBoardWillShow(_ notification: Notification) {
        if chatInputView.currentType != .text {
            return
        }
        chatInputView.currentButton?.isSelected = false
        
        chatInputView.contentSubView.isHidden = true
        let oldKeyboardRect = (notification
            .userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardRect = (notification
            .userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        print("chat view key board size : ", keyboardRect)
        layoutInputView(offset: keyboardRect.size.height)
        weak var weakSelf = self
        UIView.animate(withDuration: 0.25, animations: {
            weakSelf?.view.layoutIfNeeded()
        })
        
        // 键盘已经弹出
        if oldKeyboardRect == keyboardRect {
            return
        }
        scrollTableViewToBottom()
    }
    
    @objc func keyBoardWillHide(_ notification: Notification) {
        if chatInputView.currentType != .text {
            return
        }
        chatInputView.currentButton?.isSelected = false
        layoutInputView(offset: TSBottomSafeAreaHeight)
    }
    
    private func scrollTableViewToBottom() {
        if viewmodel.messages.count > 0 {
            weak var weakSelf = self
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: DispatchWorkItem(block: {
                if let row = weakSelf?.tableView.numberOfRows(inSection: 0) {
                    let indexPath = IndexPath(row: row - 1, section: 0)
                    weakSelf?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }))
        }
    }
    
    func commonUI(){
        viewmodel.delegate = self
        backBaseView.addSubview(tableView)
        backBaseView.addSubview(chatInputView)
        chatInputView.delegate = self
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: ScreenHeight - chatInputView.menuHeight - TSNavigationBarHeight - TSBottomSafeAreaHeight)
        tableView.register(TextMessageCell.self, forCellReuseIdentifier: "TextMessageCell")
        tableView.register(ImageMessageCell.self, forCellReuseIdentifier: "ImageMessageCell")
        tableView.register(TipMessageCell.self, forCellReuseIdentifier: "TipMessageCell")
        tableView.register(AudioMessageCell.self, forCellReuseIdentifier: "AudioMessageCell")
        tableView.register(FileMessageCell.self, forCellReuseIdentifier: "FileMessageCell")
        tableView.register(LocationMessageCell.self, forCellReuseIdentifier: "LocationMessageCell")
        tableView.register(ReplyMessageCell.self, forCellReuseIdentifier: "ReplyMessageCell")
        chatInputView.frame = CGRect(x: 0, y: ScreenHeight - chatInputView.menuHeight - TSNavigationBarHeight - TSBottomSafeAreaHeight, width: self.view.bounds.width, height: chatInputView.menuHeight + chatInputView.contentHeight)
        
        self.customNavigationBar.title = viewmodel.sessionId//viewmodel.getShowName(userId: viewmodel.sessionId, teamId: nil)

        customNavigationBar.setRightViews(views: [videoCallBtn, enterInfoBtn])
    }
    
    func loadData() {
        viewmodel.loadData {[weak self] error, count, messages in
            if messages.count > 0 {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    let indexPath = IndexPath(row: messages.count - 1, section: 0)
                    self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
            }
        }
    }
    
    @objc func loadMoreData(){
        viewmodel.dropDownRemoteRefresh {[weak self] error, count, messages, indexpath  in
            self?.tableView.mj_header.endRefreshing()
            if let indexPath = indexpath {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                }
            }
        }
    }
    
    @objc func enterPersonInfoCard(){
        
    }
    
    @objc func callActionSheet(){
        self.layoutInputView(offset: TSBottomSafeAreaHeight)
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let voiceImage = UIImage.set_image(named: "voiceCallTop")
        let videoImage = UIImage.set_image(named: "videoCallTop")
        let videoCall = UIAlertAction(title: "msg_type_video_call".localized, style: .default, handler: nil)
        videoCall.setValue(videoImage?.withRenderingMode(.alwaysOriginal), forKey: "image")
        let type = MessageUtils.conversationTargetType(self.viewmodel.conversationId)
        switch type {
        case .CONVERSATION_TYPE_TEAM:
            let videoCall = UIAlertAction(title: "msg_type_video_call".localized, style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                
            })
            videoCall.setValue(videoImage?.withRenderingMode(.alwaysOriginal), forKey: "image")
            actionSheet.addAction(videoCall)
            break
        case .CONVERSATION_TYPE_P2P:
            let voiceCall = UIAlertAction(title: "msg_type_voice_call".localized, style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                let vc = RLAudioCallController(callee: self.viewmodel.sessionId, callType: .SIGNALLING_CHANNEL_TYPE_AUDIO)
                let nav = TGNavigationController(rootViewController: vc)
                self.present(nav.fullScreenRepresentation, animated: true)
            })
            voiceCall.setValue(voiceImage?.withRenderingMode(.alwaysOriginal), forKey: "image")

            let videoImage = UIImage.set_image(named: "videoCallTop")
            let videoCall = UIAlertAction(title: "msg_type_video_call".localized, style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                let vc = RLAudioCallController(callee: self.viewmodel.sessionId, callType: .SIGNALLING_CHANNEL_TYPE_VIDEO)
                let nav = TGNavigationController(rootViewController: vc)
                self.present(nav.fullScreenRepresentation, animated: true)
            })
            videoCall.setValue(videoImage?.withRenderingMode(.alwaysOriginal), forKey: "image")
            
            actionSheet.addAction(voiceCall)
            actionSheet.addAction(videoCall)
            break
        default:
            break
        }
        
        actionSheet.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    deinit {
        NIMSDK.shared().mediaManager.remove(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: inputview action
    // 打开相册
    func openPhotoLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        present(imagePicker, animated: true, completion: nil)
    }
    // 打开相机
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("Camera not available")
        }
    }
    //打开文件
    func openFile(){
        RLSendFileManager.shared.presentView(owner: self)
        RLSendFileManager.shared.completion = {[weak self] urls in
            guard let url = urls.first else { return }
            NSFileCoordinator().coordinate(readingItemAt: url, options: .withoutChanges, error: nil) { newUrl in
                let displayName = newUrl.lastPathComponent
                self?.copyFileToSend(url: newUrl, displayName: displayName)
            }
        }
    }
    //打开地图
    func openLocation(){
        let vc = TGMessageMapViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        vc.sendBlock = { [weak self] model in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.15){
                self?.viewmodel.sendLocationMessage(model: model, conversationId: self?.viewmodel.conversationId ?? "", { _ in
                    
                })
            }
        }
    }
    
    func copyFileToSend(url: URL, displayName: String) {
        let desPath = NSTemporaryDirectory() + "\(url.lastPathComponent)"
        let dirUrl = URL(fileURLWithPath: desPath)
        if !FileManager.default.fileExists(atPath: desPath) {
            do {
                try FileManager.default.copyItem(at: url, to: dirUrl)
            } catch {
                
            }
        }
        if FileManager.default.fileExists(atPath: desPath) {
            do {
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: desPath)
                if let size_B = fileAttributes[FileAttributeKey.size] as? Double {
                    let size_MB = size_B / 1e6
                    if size_MB > fileSizeLimit {
                       // self.showTips(message: "文件大小不能超过\(fileSizeLimit)MB")
                        try? FileManager.default.removeItem(atPath: desPath)
                    } else {
                        viewmodel.sendFileMessage(filePath: desPath, displayName: displayName, conversationId: viewmodel.conversationId) { [weak self] _, error, _ in
                            
                        }

                    }
                }
            } catch {
                
            }
        }
    }
    
    // MARK: audio play
    func startPlaying(audio: NIMAudioObject, isSend: Bool) {
        playingCell?.startAnimation(byRight: isSend)
        if let url = audio.path {
            if RLAuthManager.shared.checkAudioOutputRoute(){
                NIMSDK.shared().mediaManager.switch(.speaker)
            } else {
                NIMSDK.shared().mediaManager.switch(.receiver)
            }
            NIMSDK.shared().mediaManager.play(url)
        }
    }
    
    private func startPlay(cell: AudioMessageCell?, model: RLMessageData?) {
        guard let audio = model?.nimMessageModel?.messageObject as? NIMAudioObject,
              let isSend = model?.nimMessageModel?.isOutgoingMsg else {
            return
        }
        if playingModel == model {
            if NIMSDK.shared().mediaManager.isPlaying() {
                stopPlay()
            } else {
                startPlaying(audio: audio, isSend: isSend)
            }
        } else {
            stopPlay()
            playingCell = cell
            playingModel = model
            startPlaying(audio: audio, isSend: isSend)
        }
    }
    
    public func stopPlay() {
        if NIMSDK.shared().mediaManager.isPlaying() {
            playingCell?.startAnimation(byRight: playingModel?.nimMessageModel?.isOutgoingMsg ?? true)
            NIMSDK.shared().mediaManager.stopPlay()
        }
    }
    
    private func recordDuration(filePath: String) -> Float64 {
        let avAsset = AVURLAsset(url: URL(fileURLWithPath: filePath))
        return CMTimeGetSeconds(avAsset.duration)
    }
    
    func layoutInputView(offset: CGFloat) {
        print("layoutInputView offset : ", offset)
        operationView?.removeFromSuperview()
        if offset == TSBottomSafeAreaHeight {
            removeGesture()
            chatInputView.keyboardDismiss()
            
        }else{
            addGesture()
        }
        UIView.animate(withDuration: 0.15, animations: {
            
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: offset - TSBottomSafeAreaHeight, right: 0)
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
            var frame = self.chatInputView.frame
            frame.origin.y = self.backBaseView.bounds.height - self.normalInputHeight - offset
            self.chatInputView.frame = frame
            self.scrollTableViewToBottom()
            
            if self.viewmodel.isReplying{
                self.replyView.snp.remakeConstraints { make in
                    make.top.equalTo(self.backBaseView.bounds.height - self.normalInputHeight - 36 - offset)
                    make.height.equalTo(36)
                    make.width.equalTo(ScreenWidth)
                    make.left.equalTo(0)
                }
            }
        })
        
    }

    func addGesture(){
        self.tableView.addGestureRecognizer(ges)
        ges.addTarget(self, action: #selector(dismissInputView))
    }
    func removeGesture(){
        self.tableView.removeGestureRecognizer(ges)
    }
    
    @objc func dismissInputView(){
        operationView?.removeFromSuperview()
        chatInputView.textView.resignFirstResponder()
        layoutInputView(offset: TSBottomSafeAreaHeight)
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension TGChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let model = viewmodel.messages[indexPath.row]
        //插入的时间类
        if model.type == .time {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TipMessageCell", for: indexPath) as! TipMessageCell
            cell.selectionStyle = .none
            cell.setData(model: model)
            return cell
        }
        // 回复消息
        if model.type == .reply {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyMessageCell", for: indexPath) as! ReplyMessageCell
            cell.selectionStyle = .none
            cell.setData(model: model)
            cell.delegate = self
            return cell
        }
        switch model.messageType {
        case .MESSAGE_TYPE_TEXT:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextMessageCell", for: indexPath) as! TextMessageCell
            cell.selectionStyle = .none
            cell.setData(model: model)
            cell.delegate = self
            return cell
        case .MESSAGE_TYPE_IMAGE, .MESSAGE_TYPE_VIDEO:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageMessageCell", for: indexPath) as! ImageMessageCell
            cell.selectionStyle = .none
            cell.setData(model: model)
            cell.delegate = self
            return cell
        case .MESSAGE_TYPE_TIP, .MESSAGE_TYPE_NOTIFICATION:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TipMessageCell", for: indexPath) as! TipMessageCell
            cell.selectionStyle = .none
            cell.setData(model: model)
            return cell
        case .MESSAGE_TYPE_AUDIO:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AudioMessageCell", for: indexPath) as! AudioMessageCell
            cell.selectionStyle = .none
            cell.setData(model: model)
            cell.delegate = self
            return cell
        case .MESSAGE_TYPE_FILE:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FileMessageCell", for: indexPath) as! FileMessageCell
            cell.selectionStyle = .none
            cell.setData(model: model)
            cell.delegate = self
            return cell
        case .MESSAGE_TYPE_LOCATION:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationMessageCell", for: indexPath) as! LocationMessageCell
            cell.selectionStyle = .none
            cell.setData(model: model)
            cell.delegate = self
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextMessageCell", for: indexPath) as! TextMessageCell
            cell.selectionStyle = .none
            cell.contentLabel.text = "未知消息类型"
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        operationView?.removeFromSuperview()

    }
    
}
//    MARK: BaseMessageCellDelegate
extension TGChatViewController: BaseMessageCellDelegate {
    func tapItemMessage(cell: BaseMessageCell?, model: TGMessageData?) {
        
    }
    
    func handleBaseMessageCellLongPress(cell: BaseMessageCell, model: TGMessageData?) {
        
    }
    
    func tapUserAvatar(cell: BaseMessageCell?, model: TGMessageData?) {
        
    }
    
    
}

//    MARK: NIMMediaManagerDelegate
extension TGChatViewController: NIMMediaManagerDelegate{
    
    func playAudio(_ filePath: String, didBeganWithError error: Error?) {
        if let e = error {
            //showTips(message: e.localizedDescription)
            // stop
            playingCell?.stopAnimation(byRight: playingModel?.nimMessageModel?.isOutgoingMsg ?? true)
            playingModel?.isPlaying = false
        }
    }
    func playAudio(_ filePath: String, didCompletedWithError error: Error?) {
        playingCell?.stopAnimation(byRight: playingModel?.nimMessageModel?.isOutgoingMsg ?? true)
        playingModel?.isPlaying = false
    }
    func stopPlayAudio(_ filePath: String, didCompletedWithError error: Error?) {
        if let e = error {
            // showTips(message: e.localizedDescription)
        }
        playingCell?.stopAnimation(byRight: playingModel?.nimMessageModel?.isOutgoingMsg ?? true)
        playingModel?.isPlaying = false
    }
    
    func playAudio(_ filePath: String, progress value: Float) {}
    
    open func playAudioInterruptionEnd() {
        print(#function)
        playingCell?.stopAnimation(byRight: playingModel?.nimMessageModel?.isOutgoingMsg ?? true)
        playingModel?.isPlaying = false
    }
    
    func playAudioInterruptionBegin() {
        print(#function)
        // stop play
        playingCell?.stopAnimation(byRight: playingModel?.nimMessageModel?.isOutgoingMsg ?? true)
        playingModel?.isPlaying = false
    }
    
    func recordAudio(_ filePath: String?, didBeganWithError error: Error?) {
        
    }
    func recordAudio(_ filePath: String?, didCompletedWithError error: Error?) {
        chatInputView.stopRecordAnimation()
        guard let fp = filePath else {
            // showTips(message: error?.localizedDescription ?? "")
            return
        }
        let dur = recordDuration(filePath: fp)
        
        print("dur:\(dur)")
        if dur > 1 {
            //            viewmodel.sendAudioMessage(filePath: fp) { error in
            //                if let e = error {
            //                  //  self.showTips(message: e.localizedDescription)
            //                } else {}
            //            }
        } else {
            // showTips(message: "录音时间太短！")
        }
    }
    
    // MARK: UIScrollViewDelegate
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        operationView?.removeFromSuperview()
    }
    // MARK: OperationView Action
    //回复消息
    func showReplyMessageView(isReEdit: Bool = false) {
        replyView.removeFromSuperview()
        viewmodel.isReplying = true
        replyView.frame = CGRect(x: 0, y: self.view.bounds.height - normalInputHeight - 36, width: ScreenWidth, height: 36)
        backBaseView.addSubview(replyView)
        replyView.closeButton.addTarget(self, action: #selector(closeReply), for: .touchUpInside)
        replyView.translatesAutoresizingMaskIntoConstraints = false
        replyView.snp.makeConstraints { make in
            make.top.equalTo(self.view.bounds.height - normalInputHeight - 36)
            make.height.equalTo(36)
            make.width.equalTo(ScreenWidth)
            make.left.equalTo(0)
        }
        
        if let message = viewmodel.operationModel?.nimMessageModel {
            if isReEdit {
                replyView.textLabel.attributedText = NEEmotionTool.getAttWithStr(str: viewmodel.operationModel?.replyText ?? "", font: replyView.textLabel.font, CGPoint(x: 0, y: -4), color: replyView.textLabel.textColor)
                
                //              if let replyMessage = viewmodel.getReplyMessageWithoutThread(message: message) {
                //              viewmodel.operationModel = replyMessage
                //  }
            } else {
                var text = "回复"
                //            if let uid = message.from {
                //              let showName = viewmodel.getShowName(userId: uid, teamId: viewmodel.session.sessionId, false)
                // //             if viewmodel.session.sessionType != .P2P,
                ////                 !IMKitClient.instance.isMySelf(uid) {
                ////                addToAtUsers(addText: "@" + showName + "", isReply: true, accid: uid)
                // //             }
                ////              let user = viewmodel.getUserInfo(userId: uid)
                ////              if let alias = user?.alias {
                ////                showName = alias
                ////              }
                //              text += " " + showName
                //            }
                text += ": "
                switch message.messageType {
                case .MESSAGE_TYPE_TEXT:
                    if let t = message.text {
                        text += t
                    }
                case .MESSAGE_TYPE_IMAGE:
                    text += "[图片消息]"
                case .MESSAGE_TYPE_AUDIO:
                    text += "[语音消息]"
                case .MESSAGE_TYPE_VIDEO:
                    text += "[视频消息]"
                case .MESSAGE_TYPE_FILE:
                    text += "[文件消息]"
                case .MESSAGE_TYPE_LOCATION:
                    text += "[位置消息]"
                case .MESSAGE_TYPE_CUSTOM:
                    text += "[自定义消息]"
                default:
                    text += "[未知消息]"
                }
                replyView.textLabel.attributedText = NEEmotionTool.getAttWithStr(str: text,
                                                                                 font: replyView.textLabel.font,
                                                                                 CGPoint(x: 0, y: -4),
                                                                                 color: replyView.textLabel.textColor)
                chatInputView.textView.becomeFirstResponder()
            }
        }
        
    }
    
    @objc func closeReply(){
        replyView.removeFromSuperview()
        viewmodel.isReplying = false
    }
    
    //删除消息
    func deleteMessage() {
        showAlert(message: "确定要删除该消息？") { [weak self]  in
            if let message = self?.viewmodel.operationModel?.nimMessageModel {
//                self?.viewmodel.deleteMessage(message: message, { error in
//                    if let error = error {
//                       // self?.showTips(message: error.localizedDescription)
//                    }
//                })
            }
        }
    }
    //转发消息
    func forwardMessage(){
        if let message = self.viewmodel.operationModel?.nimMessageModel {
           // viewmodel.forwardUserMessage(message, ["10000002"])
        }
    }
    //撤回消息
    func recallMessage(){
        showAlert(message: "确定是否要撤回？") {[weak self] in
            if let message = self?.viewmodel.operationModel?.nimMessageModel {
                if message.messageType == .MESSAGE_TYPE_TEXT {
                  self?.viewmodel.operationModel?.isRevokedText = true
                }
                
//                self?.viewmodel.revokeMessage(message: message, { error in
//                    if let error = error {
//                       // self?.showTips(message: error.localizedDescription)
//                    }else{
//                        // 自己撤回成功 & 收到对方撤回 都会走回调方法 onRevokeMessage
//                        self?.viewmodel.saveRevokeMessage(message, { _ in
//                            
//                        })
//                    }
//                })
                
            }
        }
    }
    
    func showAlert(message: String, _ completion: @escaping () -> Void){
        
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        let comfire = UIAlertAction(title: "确定", style: .default) { _ in
            completion()
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        alert.addAction(cancel)
        alert.addAction(comfire)
        self.present(alert, animated: true)
    }
    
    func sendMediaMessage(didFinishPickingMediaWithInfo info: [UIImagePickerController
        .InfoKey: Any]) {
            var imageName = "IMG_0001"
            var imageWidth: Int32 = 0
            var imageHeight: Int32 = 0
            var videoDuration: Int32 = 0
            
            // 获取展示名称
            if let imgUrl = info[.referenceURL] as? URL {
                let fetchRes = PHAsset.fetchAssets(withALAssetURLs: [imgUrl], options: nil)
                let asset = fetchRes.firstObject
                if let fileName = asset?.value(forKey: "filename") as? String {
                    imageName = fileName
                }
            }
            
            // 获取图片宽高、视频时长
            // phAsset 不一定有
            if #available(iOS 11.0, *) {
                if let phAsset = info[.phAsset] as? PHAsset {
                    imageWidth = Int32(phAsset.pixelWidth)
                    imageHeight = Int32(phAsset.pixelHeight)
                    videoDuration = Int32(phAsset.duration * 1000)
                }
            }
            
            // video
            if let videoUrl = info[.mediaURL] as? URL {
                print("image picker video : url", videoUrl)
                
                // 获取视频宽高、时长
                let asset = AVURLAsset(url: videoUrl)
                videoDuration = Int32(asset.duration.seconds * 1000)
                
                let track = asset.tracks(withMediaType: .video).first
                if let track = track {
                    let size = track.naturalSize
                    let transform = track.preferredTransform
                    let correctedSize = size.applying(transform)
                    imageWidth = Int32(abs(correctedSize.width))
                    imageHeight = Int32(abs(correctedSize.height))
                }
                
                weak var weakSelf = self
                viewmodel.sendVideoMessage(url: videoUrl, name: imageName, width: imageWidth, height: imageHeight, duration: videoDuration, conversationId: viewmodel.conversationId) { message, error, progress in
                    //if progress > 0, progress <= 100 {
                    // self?.setModelProgress(message, progress)
                    //  }
                    
                }
                
                return
            }
            
            if #available(iOS 11.0, *) {
                var imageUrl = info[.imageURL] as? URL
                var image = info[.originalImage] as? UIImage
                image = image?.fixOrientation()
                // 获取图片宽度
                if let width = image?.size.width {
                    imageWidth = Int32(width)
                }
                // 获取图片高度度
                if let height = image?.size.height {
                    imageHeight = Int32(height)
                }
                
                let pngImage = image?.pngData()
                var needDelete = false
                // 无url则临时保存到本地，发送成功后删除临时文件
                if imageUrl == nil {
                    if let data = pngImage {
                        let url = FileUtils.getDocumentsDirectory().appendingPathComponent("photo_\(UUID().uuidString).png")
                        do {
                            try data.write(to: url)
                            imageUrl = url
                            needDelete = true
                        } catch  {
                            print("Error saving image: \(error)")
                            // showToast(chatLocalizable("image_is_nil"))
                        }
                    }
                }
                guard let imageUrl = imageUrl else {
                    return
                }
                
                if let url = info[.referenceURL] as? URL {
                    if url.absoluteString.hasSuffix("ext=GIF") == true {
                        // GIF 需要特殊处理
                        let imageAsset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset
                        let options = PHImageRequestOptions()
                        options.version = .current
                        guard let asset = imageAsset else {
                            return
                        }
                        weak var weakSelf = self
                        PHImageManager.default().requestImageData(for: asset, options: options) { imageData, dataUTI, orientation, info in
                            if let data = imageData {
                                let tempDirectoryURL = FileManager.default.temporaryDirectory
                                let uniqueString = UUID().uuidString
                                let temUrl = tempDirectoryURL.appendingPathComponent(uniqueString + ".gif")
                                print("tem url path : ", temUrl.path)
                                do {
                                    try data.write(to: temUrl)
                                    DispatchQueue.main.async {
                                        weakSelf?.viewmodel.sendImageMessage(path: temUrl.path, name: imageName, width: imageWidth, height: imageHeight, conversationId: weakSelf?.viewmodel.conversationId ?? "") { error in
                                            
                                            
                                        }
                                    }
                                } catch {
                                    
                                }
                            }
                        }
                        return
                    }
                }
                
                viewmodel.sendImageMessage(path: imageUrl.relativePath, name: imageName, width: imageWidth, height: imageHeight, conversationId: viewmodel.conversationId) { [weak self] error in
                    
                    // 删除临时保存的图片
                    if needDelete {
                        try? FileManager.default.removeItem(at: imageUrl)
                    }
                }
        }
    }
    
    //获取处理后的语音分贝数据
    func getVolumeLevels() -> String {
        var saveLevels = self.chatInputView.audioRecordIndicator.recordStateView.saveLevels
        let filterArrays = saveLevels.filterDuplicates({$0})
        var resultArrays = [CGFloat]()
        var audioSecond = filterArrays.count / 10
        switch audioSecond {
        case 5..<10:
            resultArrays = filterArrays.enumerated().filter { $0.offset % 2 == 0 }.map { CGFloat($0.element) }
        case 10..<25:
            resultArrays = filterArrays.enumerated().filter { $0.offset % 4 == 0 }.map { CGFloat($0.element) }
        case 25..<40:
            resultArrays = filterArrays.enumerated().filter { $0.offset % 6 == 0 }.map { CGFloat($0.element) }
        default:
            resultArrays = filterArrays.enumerated().filter { $0.offset % 1 == 0 }.map { CGFloat($0.element) }
            break
        }
        // 转换为Android需要的格式
        let targetArray = (0..<27).map { index -> Int in
            if index < resultArrays.count {
                var value = Int(resultArrays[index] * 100)
                return min(value, 55)
            } else {
                return 5
            }
        }
        let dblist = VoiceDBBean(dbList: targetArray)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let jsonData = try? encoder.encode(dblist),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return ""
    }
}

extension TGChatViewController: UIDocumentInteractionControllerDelegate{
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        controller.dismissPreview(animated: true)
    }
}
//MARK: TGChatViewModelDelegate
extension TGChatViewController: TGChatViewModelDelegate {
    func onSend(_ message: V2NIMMessage, succeeded: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.scrollTableViewToBottom()
        }
    }
    
    func onReceive(_ messages: [V2NIMMessage]) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.scrollTableViewToBottom()
        }
    }
    
    func onReceive(_ readReceipts: [V2NIMP2PMessageReadReceipt]) {
        
    }
    
    func onReceive(_ readReceipts: [V2NIMTeamMessageReadReceipt]) {
        
    }
    
    func onReceiveMessagesModified(_ messages: [V2NIMMessage]) {
        
    }
    
    func onMessageRevokeNotifications(_ revokeNotifications: [V2NIMMessageRevokeNotification]) {
        
    }
    
    func onMessagePinNotification(_ pinNotification: V2NIMMessagePinNotification) {
        
    }
    
    func onMessageQuickCommentNotification(_ notification: V2NIMMessageQuickCommentNotification) {
        
    }
    
    func onMessageDeletedNotifications(_ messageDeletedNotification: [V2NIMMessageDeletedNotification]) {
        
    }
    
    func onClearHistoryNotifications(_ clearHistoryNotification: [V2NIMClearHistoryNotification]) {
        
    }

}
//MARK: ChatInputViewDelegate
extension TGChatViewController: ChatInputViewDelegate {
    func didSelectMoreCell(cell: InputMoreCell) {
        guard let item = cell.cellData else {
            return
        }
        switch item {
        case .album:
            openPhotoLibrary()
        case .file:
            openFile()
        case .sendLocation:
            openLocation()
        case .sendCard:
            break
        case .camera:
            openCamera()
        case .redpacket:
            break
        case .videoCall:
            break
        case .voiceCall:
            break
        case .whiteBoard:
            break
        case .voiceToText:
            break
        case .rps:
            break
        case .collectMessage:
            break
        default:
            break
        }
    }
    
    func sendText(text: String?, attribute: NSAttributedString?) {
        guard let content = text, content.count > 0 else {
          return
        }
        let remoteExt = chatInputView.getRemoteExtension(attribute)
        
        if viewmodel.isReplying, let _ = viewmodel.operationModel?.nimMessageModel {
            self.closeReply()
        }else {
            viewmodel.sendTextMessage(text: content, conversationId: viewmodel.conversationId, remoteExt: remoteExt) {[weak self] message, error in
                if let _ = error {
                    
                }
            }
        }
        
    }
    
    func willSelectItem(show: Bool) {
        if show {
            self.layoutInputView(offset: self.bottomExanpndHeight)
        }else{
            self.layoutInputView(offset: TSBottomSafeAreaHeight)
        }
    }
    
    func textChanged(text: String) -> Bool {
        return true
    }
    
    func textDelete(range: NSRange, text: String) -> Bool {
        return true
    }
    
    func startRecord() {
        if RLAuthManager.shared.checkRecordPermission() {
            NIMSDK.shared().mediaManager.record(forDuration: record_duration)
        }
    }
    
    func moveOutView() {
    }
    
    func moveInView() {
    }
    
    func endRecord(insideView: Bool) {
        if insideView {
          //            send
          NIMSDK.shared().mediaManager.stopRecord()
        } else {
          //            cancel
          NIMSDK.shared().mediaManager.cancelRecord()
        }
    }
    
    func textFieldDidChange(_ textField: UITextView) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextView) {
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextView) {
        
    }
    
    // MARK: Audio
    func onStartRecording() {
        if NIMSDK.shared().mediaManager.isPlaying() {
            NIMSDK.shared().mediaManager.stopPlay()
        }
        chatInputView.recognizedText = ""
        chatInputView.recording = true

        NIMSDK.shared().mediaManager.add(self)
        NIMSDK.shared().mediaManager.record(NIMAudioType.AMR, duration: 65)
        //保存识别结果
        SpeechVoiceDetectManager.shared.state = .recording
        SpeechVoiceDetectManager.shared.onReceiveValue = { [weak self] (receiveValue, isFinal) in
            guard let self = self else { return }
            //判断识别结果是否为空
            guard let receiveValue = receiveValue, receiveValue.count > 0 else {
                //判断之前识别到了结果，但是最终为nil 取用之前的结果显示
                if self.receiveResult.count > 0 {
                    self.chatInputView.recordPhase = .converted
                    self.chatInputView.recognizedText = self.receiveResult
                } else if self.chatInputView.audioRecordIndicator.moreButton.isHidden == false && isFinal {
                    //判断是否是二次识别，需要更改状态为识别错误
                    self.chatInputView.recordPhase = .converterror
                }
                return
            }
            
            self.receiveResult = receiveValue
            // 在识别错误的前提下，识别到了文字，将状态改回识别成功状态
            if self.receiveResult.count > 0 && self.chatInputView.audioRecordIndicator.convertErrorView.isHidden == false {
                self.chatInputView.recordPhase = .converted
            }
            //识别结果赋值给TextView
            self.chatInputView.recognizedText = self.receiveResult
        }
        
        SpeechVoiceDetectManager.shared.onRequestAuthorizationStateChanged = { [weak self] (state,errorMsg) in
            guard let self = self else { return }
            if state != .authorized {
                //声音授权出现问题
                self.chatInputView.audioRecordIndicator.authErrorMsg = errorMsg
            }
        }
        
        var dotCount = 1 // 初始点数为 3
        SpeechVoiceDetectManager.shared.onDurationChanged = { [weak self] (duration) in
            guard let self = self else { return }
            if dotCount == 1 {
                dotCount = 2
            } else if dotCount == 2 {
                dotCount = 3
            } else if dotCount == 3 {
                dotCount = 1
            }
            let dots = String(repeating: "·", count: dotCount)
            
            self.chatInputView.audioRecordIndicator.countDownNumber = duration
            self.chatInputView.audioRecordIndicator.recognizedTextView.text = "\(self.chatInputView.recognizedText)\(dots)"
        }
        
        SpeechVoiceDetectManager.shared.onRecordEnd = { [weak self] in
            guard let self = self else { return }
            self.onRecordEnd()
        }
    }
    
    func onStopRecording() {
        NIMSDK.shared().mediaManager.stopRecord()
        SpeechVoiceDetectManager.shared.stopRecording()
        self.chatInputView.audioRecordIndicator.countDownNumber = 60
        self.recognizedText = ""
    }
    
    func onRecordEnd() {
        let isConvert = (self.chatInputView.recordPhase == .converting || self.chatInputView.recordPhase == .converted)
        if isConvert && self.chatInputView.recognizedText.isEmpty {
            //没有识别到任何文字
            self.chatInputView.recordPhase = .converterror
        } else {
            self.chatInputView.recordPhase = isConvert == true ? .converted : .end
        }
    }
    
    func onCancelRecording() {
        NIMSDK.shared().mediaManager.cancelRecord()
        SpeechVoiceDetectManager.shared.stopRecording()
        self.chatInputView.audioRecordIndicator.countDownNumber = 60
        self.chatInputView.audioRecordIndicator.recognizedTextView.text = ""
        self.recognizedText = ""
    }
    
    func onConverting() {
        SpeechVoiceDetectManager.shared.stopRecording()
        NIMSDK.shared().mediaManager.stopRecord()
    }
    
    func onConvertError() {
        SpeechVoiceDetectManager.shared.stopRecording()
        self.chatInputView.audioRecordIndicator.countDownNumber = 60
        NIMSDK.shared().mediaManager.stopRecord()
    }
    
    //取消发送
    func cancelButtonTapped() {
        self.view.resignFirstResponder()
        NIMSDK.shared().mediaManager.cancelRecord()
        SpeechVoiceDetectManager.shared.stopRecording()
        self.recognizedText = ""
        chatInputView.recording = false
    }
    
    //发送原语音
    func sendVoiceButtonTapped() {
        self.view.resignFirstResponder()
        if let message = self.saveAudioMessage{
            let volumeLevels = self.getVolumeLevels()
            message.localExtension = ["voice":volumeLevels].toJSON
            NIMSDK.shared().v2MessageService.send(message, conversationId: self.viewmodel.conversationId, params: nil) { _ in
                
            } failure: { _ in
                
            }

            chatInputView.recording = false
        }
        NIMSDK.shared().mediaManager.cancelRecord()
        SpeechVoiceDetectManager.shared.stopRecording()
    }
    
    //发送语音文字
    func sendVoiceMsgTextButtonTapped() {
        self.view.resignFirstResponder()
        
        NIMSDK.shared().mediaManager.cancelRecord()
        SpeechVoiceDetectManager.shared.stopRecording()
        var recognizedText = self.chatInputView.audioRecordIndicator.recognizedTextView.text ?? ""
        if recognizedText != "" {
            self.viewmodel.sendTextMessage(text: recognizedText, conversationId: self.viewmodel.conversationId) { _, _ in
                
            }
        }
        self.recognizedText = ""
        chatInputView.recording = false
    }
    
    
    
}

//    MARK: UIImagePickerControllerDelegate
extension TGChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    // 处理选择的照片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        sendMediaMessage(didFinishPickingMediaWithInfo: info)
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 取消选择时调用
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}

