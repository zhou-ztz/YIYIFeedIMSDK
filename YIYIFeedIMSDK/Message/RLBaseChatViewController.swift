//
//  RLBaseChatViewController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/25.
//

import UIKit
import NIMSDK
import AVFoundation

// 发送文件大小限制(单位：MB)
let fileSizeLimit: Double = 200
//录音时长
let record_duration: TimeInterval = 60.0

class RLBaseChatViewController: RLViewController {

    var viewmodel: RLChatViewModel
    
    public var session: NIMSession
    public var messages = [RLMessageData]()
    //未读数
    var unreadCount: Int = 0
    
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
    var bottomExanpndHeight: CGFloat = 204 // 底部展开高度
    var normalInputHeight: CGFloat = 100
    //记录播放语音的cell
    private var playingCell: AudioMessageCell?
    private var playingModel: RLMessageData?
    
    let ges = UITapGestureRecognizer()

    var operationView: MessageOperationView?
    var replyView = ReplyView()
  
    init(session: NIMSession, unreadCount: Int = 0) {
        self.session = session
        self.viewmodel = RLChatViewModel(session: session, unreadCount: unreadCount)
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
    
    func commonUI(){
        viewmodel.delegate = self
        backBaseView.addSubview(tableView)
        backBaseView.addSubview(chatInputView)
        chatInputView.delegate = self
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: ScreenHeight - chatInputView.menuHeight - TSNavigationBarHeight)
        tableView.register(TextMessageCell.self, forCellReuseIdentifier: "TextMessageCell")
        tableView.register(ImageMessageCell.self, forCellReuseIdentifier: "ImageMessageCell")
        tableView.register(TipMessageCell.self, forCellReuseIdentifier: "TipMessageCell")
        tableView.register(AudioMessageCell.self, forCellReuseIdentifier: "AudioMessageCell")
        tableView.register(FileMessageCell.self, forCellReuseIdentifier: "FileMessageCell")
        tableView.register(LocationMessageCell.self, forCellReuseIdentifier: "LocationMessageCell")
        tableView.register(ReplyMessageCell.self, forCellReuseIdentifier: "ReplyMessageCell")
        
        chatInputView.frame = CGRect(x: 0, y: ScreenHeight - chatInputView.menuHeight - TSNavigationBarHeight, width: self.view.bounds.width, height: chatInputView.menuHeight + chatInputView.contentHeight)
        
        self.customNavigationBar.title = viewmodel.getShowName(userId: session.sessionId, teamId: nil)
        
        let barItem = UIButton()
        barItem.setImage(UIImage(named: "buttonsMoreDotBlack")?.withRenderingMode(.alwaysOriginal), for: .normal)
        barItem.addTarget(self, action: #selector(settingAcion), for: .touchUpInside)
        customNavigationBar.setRightViews(views: [barItem])
    }
    
    func loadData() {
        viewmodel.getLocalMessages {[weak self] count, datas in
            if let datas = datas {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    let indexPath = IndexPath(row: datas.count - 1, section: 0)
                    self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
                
            }
        }
    }
    
    @objc func loadMoreData(){
        viewmodel.loadMoreMessage {[weak self] _, datas, indexPath in
            self?.tableView.mj_header.endRefreshing()
            if let _ = datas, let indexPath = indexPath {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.tableView.scrollToRow(at: indexPath, at: .top, animated: false)

                }
            }
        }
    }
    
    @objc func settingAcion(){
//        let vc = ChatSettingViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    deinit {
        NIMSDK.shared().mediaManager.remove(self)
        NotificationCenter.default.removeObserver(self)
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
        layoutInputView(offset: 0)
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
    
    func layoutInputView(offset: CGFloat) {
        print("layoutInputView offset : ", offset)
        operationView?.removeFromSuperview()
        if offset == 0 {
            removeGesture()
            chatInputView.contentSubView.isHidden = true
            chatInputView.currentButton?.isSelected = false
        }else{
            addGesture()
        }
        UIView.animate(withDuration: 0.15, animations: {
            
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: offset, right: 0)
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
        layoutInputView(offset: 0)
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
        SendFileManager.shared.presentView(owner: self)
        SendFileManager.shared.completion = {[weak self] urls in
            guard let url = urls.first else { return }
            NSFileCoordinator().coordinate(readingItemAt: url, options: .withoutChanges, error: nil) { newUrl in
                let displayName = newUrl.lastPathComponent
                self?.copyFileToSend(url: newUrl, displayName: displayName)
            }
        }
    }
    //打开地图
    func openLocation(){
//        let vc = MessageMapViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
//        vc.sendBlock = { [weak self] model in
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.15){
//                self?.viewmodel.sendLocationMessage(model, { error in
//                    
//                })
//            }
//        }
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
                        viewmodel.sendFileMessage(filePath: desPath, displayName: displayName) { [weak self] error in
                            if error != nil {
                               // self?.showTips(message: error!.localizedDescription)
                            }
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
             
              if let replyMessage = viewmodel.getReplyMessageWithoutThread(message: message) {
              viewmodel.operationModel = replyMessage
            }
          } else {
            var text = "回复"
            if let uid = message.from {
              let showName = viewmodel.getShowName(userId: uid, teamId: viewmodel.session.sessionId, false)
 //             if viewmodel.session.sessionType != .P2P,
//                 !IMKitClient.instance.isMySelf(uid) {
//                addToAtUsers(addText: "@" + showName + "", isReply: true, accid: uid)
 //             }
//              let user = viewmodel.getUserInfo(userId: uid)
//              if let alias = user?.alias {
//                showName = alias
//              }
              text += " " + showName
            }
            text += ": "
            switch message.messageType {
            case .text:
              if let t = message.text {
                text += t
              }
            case .image:
              text += "[图片消息]"
            case .audio:
              text += "[语音消息]"
            case .video:
              text += "[视频消息]"
            case .file:
              text += "[文件消息]"
            case .location:
              text += "[位置消息]"
            case .custom:
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
                self?.viewmodel.deleteMessage(message: message, { error in
                    if let error = error {
                       // self?.showTips(message: error.localizedDescription)
                    }
                })
            }
        }
    }
    //转发消息
    func forwardMessage(){
        if let message = self.viewmodel.operationModel?.nimMessageModel {
            viewmodel.forwardUserMessage(message, ["10000002"])
        }
    }
    //撤回消息
    func recallMessage(){
        showAlert(message: "确定是否要撤回？") {[weak self] in
            if let message = self?.viewmodel.operationModel?.nimMessageModel {
                if message.messageType == .text {
                  self?.viewmodel.operationModel?.isRevokedText = true
                }
                
                self?.viewmodel.revokeMessage(message: message, { error in
                    if let error = error {
                       // self?.showTips(message: error.localizedDescription)
                    }else{
                        // 自己撤回成功 & 收到对方撤回 都会走回调方法 onRevokeMessage
                        self?.viewmodel.saveRevokeMessage(message, { _ in
                            
                        })
                    }
                })
                
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
}
// MARK:  MessageOperationViewDelegate
extension RLBaseChatViewController: MessageOperationViewDelegate{
    func didSelectedItem(item: OperationItem) {
        guard let model = viewmodel.operationModel, let message = model.nimMessageModel else { return }
        switch item.type {
        case .copy:
            let pasteboard = UIPasteboard.general
            pasteboard.string = message.text
        case .reply:
            showReplyMessageView()
        case .delete:
            deleteMessage()
        case .forward:
            forwardMessage()
        case .recall:
            recallMessage()
        default:
            break
        }
    }
}
// MARK: BaseMessageCellDelegate
extension RLBaseChatViewController: BaseMessageCellDelegate{
    ///点击用户头像
    func tapUserAvatar(cell: BaseMessageCell?, model: RLMessageData?) {
        
    }
    
    func tapItemMessage(cell: BaseMessageCell?, model: RLMessageData?) {
        operationView?.removeFromSuperview()
        guard let model = model, let cell = cell else { return }
        switch model.messageType {
        case .audio:
            startPlay(cell: cell as? AudioMessageCell, model: model)
        case .video:
            stopPlay()
            if let message = model.nimMessageModel, let object = message.messageObject as? NIMVideoObject, let path = object.path , let urlString = object.url{
                if FileManager.default.fileExists(atPath: path) == true {
                    let url = URL(fileURLWithPath: path)
                    let coverUrl = URL(fileURLWithPath: object.coverPath ?? "")
//                    let vc = FeedFullVideoViewController()
//                    self.navigationController?.pushViewController(vc, animated: true)
//                    vc.setVideoUrl(url: url, coverUrl: coverUrl)
                    
                }else{
                    viewmodel.downLoad(urlString, path) { progress in
                        // TODO: 处理下载中...
                    } _: { error in
                        
                    }

                }
                
            }

        case .file:
            guard let object = model.nimMessageModel?.messageObject as? NIMFileObject,
                  let path = object.path else {
                return
            }
            if !FileManager.default.fileExists(atPath: path) {
                viewmodel.downLoadFile(object: object)
            }else{
                let url = URL(fileURLWithPath: path)
                let interactionController = UIDocumentInteractionController()
                interactionController.url = url
                interactionController.delegate = self
                if interactionController.presentPreview(animated: true) {}
                else {
                  interactionController.presentOptionsMenu(from: view.bounds, in: view, animated: true)
                }
            }
        case .image:
            if let imageObject = model.nimMessageModel?.messageObject as? NIMImageObject {
                var imageUrl = ""
                if let url = imageObject.url {
                    imageUrl = url
                } else {
                    if let path = imageObject.path, FileManager.default.fileExists(atPath: path) {
                        imageUrl = path
                    }
                }
                if imageUrl.count > 0, let cell = cell as? ImageMessageCell {
                    let urls = viewmodel.getUrls()
                    
                    let index = urls.firstIndex { str in
                        str == imageUrl
                    }
//                    var images: [ImageBrowserModel] = []
//                    for url in urls {
//                        if let urlT = URL(string: url) {
//                            let imageModel = ImageBrowserModel(url: urlT, image: nil, toView: cell.displayImage)
//                            images.append(imageModel)
//                        }
//                    }
//                    let vc = SCImageBrowserController()
//                    vc.images = images
//                    vc.index = index ?? 0
//                    vc.modalPresentationStyle = .overFullScreen
//                    present(vc, animated: false, completion: nil)

                }
            }
        case .location :
//            let vc = ShowMapViewController(model: model)
//            self.navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
        
    }
    func handleBaseMessageCellLongPress(cell: BaseMessageCell, model: RLMessageData?) {
        guard let model = model else { return }
        // 底部收起
        chatInputView.textView.resignFirstResponder()
        //layoutInputView(offset: 0)
        operationView?.removeFromSuperview()
        // operations
        guard let items = viewmodel.avalibleOperationsForMessage(model) else {
          return
        }
        viewmodel.operationModel = model
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: DispatchWorkItem(block: { [self] in
            // size
            let w = items.count <= 5 ? 60.0 * Double(items.count) + 16.0 : 60.0 * 5 + 16.0
            let h = items.count <= 5 ? 56.0 + 16.0 : 56.0 * 2 + 16.0
            
            if let index = tableView.indexPath(for: cell) {
                let rectInTableView = tableView.rectForRow(at: index)
                let rectInView = tableView.convert(rectInTableView, to: view)
                let topOffset = 10.0
                var operationY = 0.0
               
                if topOffset + h  > rectInView.origin.y {
                    // under the cell
                    if rectInView.origin.y + rectInView.size.height > self.backBaseView.bounds.height - normalInputHeight {
                        operationY = self.backBaseView.bounds.height - normalInputHeight - h
                    }else{
                        operationY = rectInView.origin.y + rectInView.size.height
                    }
                } else {
                    operationY = rectInView.origin.y - h
                }
                var frameX = 10.0
                if let msg = model.nimMessageModel,
                   msg.isOutgoingMsg {
                    frameX = ScreenWidth - w - frameX
                }
                var frame = CGRect(x: frameX, y: operationY, width: w, height: h)
                if frame.origin.y + h < tableView.frame.origin.y {
                    frame.origin.y = tableView.frame.origin.y
                } else if frame.origin.y + h > view.frame.size.height {
                    frame.origin.y = tableView.frame.origin.y + tableView.frame.size.height - h
                }
                
                operationView = MessageOperationView(frame: frame, model: model)
                operationView!.delegate = self
                operationView!.items = items
                backBaseView.addSubview(operationView!)
            }
        }))
                                      
    }
}
// MARK: UITableViewDelegate, UITableViewDataSource
extension RLBaseChatViewController: UITableViewDelegate, UITableViewDataSource {
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
        case .text:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextMessageCell", for: indexPath) as! TextMessageCell
            cell.selectionStyle = .none
            cell.setData(model: model)
            cell.delegate = self
            return cell
        case .image, .video:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageMessageCell", for: indexPath) as! ImageMessageCell
            cell.selectionStyle = .none
            cell.setData(model: model)
            cell.delegate = self
            return cell
        case .tip, .notification:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TipMessageCell", for: indexPath) as! TipMessageCell
            cell.selectionStyle = .none
            cell.setData(model: model)
            return cell
        case .audio:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AudioMessageCell", for: indexPath) as! AudioMessageCell
            cell.selectionStyle = .none
            cell.setData(model: model)
            cell.delegate = self
            return cell
        case .file:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FileMessageCell", for: indexPath) as! FileMessageCell
            cell.selectionStyle = .none
            cell.setData(model: model)
            cell.delegate = self
            return cell
        case .location:
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
//    MARK: ChatInputViewDelegate
extension RLBaseChatViewController: ChatInputViewDelegate {
    func didSelectMoreCell(cell: InputMoreCell) {
        guard let type = cell.cellData?.type else {
            return
        }
        switch type {
        case .takePicture:
            openCamera()
        case .file:
            openFile()
        case .location:
            openLocation()
        case .rtc:
            break
           // self.showTips(message: "暂无该功能")
        }
    }
    
    func sendText(text: String?, attribute: NSAttributedString?) {
        guard let content = text, content.count > 0 else {
          return
        }
        let remoteExt = chatInputView.getRemoteExtension(attribute)
        
        if viewmodel.isReplying, let msg = viewmodel.operationModel?.nimMessageModel {
            self.closeReply()
            viewmodel.replyMessageWithoutThread(message: MessageUtils.textMessage(text: content, remoteExt: remoteExt), target: msg) { [weak self] error in
                if error != nil {
                   // self?.showTips(message: error?.localizedDescription ?? "")
                } else {
                    self?.closeReply()
                }
            }

        }else {
            
            viewmodel.sendTextMessage(text: content, remoteExt: remoteExt) {[weak self] error in
                if let error = error {
                   // self?.showTips(message: error.localizedDescription)
                }
            }
        }
        
    }
    
    func willSelectItem(button: UIButton?, index: Int) {
        if index == 2 {
            openPhotoLibrary()
        }else {
            guard let btn = button else {
                return
            }
            if btn.isSelected {
                self.layoutInputView(offset: self.bottomExanpndHeight)
            }else{
                self.layoutInputView(offset: 0)
            }
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
    
    
}
//    MARK: ChatViewModelDelegate
extension RLBaseChatViewController: ChatViewModelDelegate{
    
    func onRecvMessages(_ messages: [NIMMessage]) {
        operationView?.removeFromSuperview()
        self.tableView.reloadData()
        self.scrollTableViewToBottom()
    }
    
    func willSend(_ message: NIMMessage) {
        
    }
    
    func send(_ message: NIMMessage, didCompleteWithError error: Error?) {
        if let error = error {
            //self.showTips(message: "send msg error = \(error.localizedDescription)")
        }
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.scrollTableViewToBottom()
        }
        
    }
    
    func send(_ message: NIMMessage, progress: Float) {
        
    }
    
    func didReadedMessageIndexs() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func onDeleteMessage(_ message: NIMMessage, atIndexs: [IndexPath], reloadIndex: [IndexPath]) {
        if atIndexs.isEmpty {
          return
        }
        operationView?.removeFromSuperview()
        self.tableView.deleteRows(at: atIndexs, with: .none)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: DispatchWorkItem(block: { [weak self] in
            self?.tableView.reloadRows(at: reloadIndex, with: .none)
        }))
    }
    
    func onRevokeMessage(_ message: NIMMessage, atIndexs: [IndexPath]) {
        if atIndexs.isEmpty {
          return
        }
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
        
    }
    
}
//    MARK: UIImagePickerControllerDelegate
extension RLBaseChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    // 处理选择的照片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // 处理选定的照片
            viewmodel.sendImageMessage(image: selectedImage) { error in
                if let error = error {
                   // self.showTips(message: error.localizedDescription)
                }
            }
        }
        if let pickedVideoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            // 处理选择的视频
            viewmodel.sendVideoMessage(url: pickedVideoURL) { error in
                if let error = error {
                   // self.showTips(message: error.localizedDescription)
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 取消选择时调用
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
//    MARK: NIMMediaManagerDelegate
extension RLBaseChatViewController: NIMMediaManagerDelegate{
    
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
            viewmodel.sendAudioMessage(filePath: fp) { error in
                if let e = error {
                  //  self.showTips(message: e.localizedDescription)
                } else {}
            }
        } else {
           // showTips(message: "录音时间太短！")
        }
    }
}

extension RLBaseChatViewController: UIDocumentInteractionControllerDelegate{
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        controller.dismissPreview(animated: true)
    }
}

