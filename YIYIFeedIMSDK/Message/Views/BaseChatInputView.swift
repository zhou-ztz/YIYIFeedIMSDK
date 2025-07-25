//
//  BaseChatInputView.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/8.
//

import UIKit
import KMPlaceholderTextView
import AudioToolbox
import CoreLocation
import NIMSDK

enum ChatMenuType: Int {
    case normal = 0
    case text
    case more
    case sticker
    case picture
    case file
    case local
    case audio
}


public let yxAtMsg = "yxAitMsg"
public let atRangeOffset = 1
public let atSegmentsKey = "segments"
public let atTextKey = "text"

@objc protocol ChatInputViewDelegate: NSObjectProtocol {
    func sendText(text: String?, attribute: NSAttributedString?)
    func willSelectItem(show: Bool)
    func didSelectMoreCell(cell: InputMoreCell)
    func didSendLocation(isSend: Bool, title: String, coordinate: CLLocationCoordinate2D)
    
    @discardableResult
    func textChanged(text: String) -> Bool
    func textDelete(range: NSRange, text: String) -> Bool
    func textFieldDidChange(_ textField: UITextView)
    func textFieldDidEndEditing(_ textField: UITextView)
    func textFieldDidBeginEditing(_ textField: UITextView)
    func removeAtUsertext(text: String)
    
    
    @objc optional func onStartRecording()
    @objc optional func onStopRecording()
    @objc optional func onCancelRecording()
    @objc optional func onConverting()
    @objc optional func onConvertError()
    @objc optional func pasteImage(image: UIImage)
    @objc optional func onPasteMentioned(usernames: [String], _ message: String)

    //取消发送
    @objc optional func cancelButtonTapped()
    //发送原语音
    @objc optional func sendVoiceButtonTapped()
    //发送文字
    @objc optional func sendVoiceMsgTextButtonTapped()
    //弹出更多语言页面
    @objc optional func moreLanguageButtonTapped()
    
    ///贴纸
    func didPressAdd(_ sender: Any?)
    func selectedEmoticon(_ emoticonID: String?, catalog emotCatalogID: String?, description:  String?, stickerId: String?)
    func didPressMySticker(_ sender: Any?)
    func didPressCustomerSticker()
}

class BaseChatInputView: UIView {
    
    weak var delegate: ChatInputViewDelegate?

    var currentType: ChatMenuType = .normal
    var currentButton: UIButton?
    var menuHeight = 50.0
    var contentHeight = 234.0 + TSBottomSafeAreaHeight
    
    var maxTextViewHeight = 100.0
    var textViewHeight: CGFloat = 40
    
    var conversationType: V2NIMConversationType = .CONVERSATION_TYPE_P2P

    lazy var barStackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .bottom
        return stack
    }()
    
    lazy var textView: KMPlaceholderTextView = {
        let textView = KMPlaceholderTextView()
        textView.placeholder = "请输入".localized
        textView.layer.cornerRadius = 8
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.clipsToBounds = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
       // textView.returnKeyType = .send
        textView.allowsEditingTextAttributes = true
        textView.typingAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        textView.dataDetectorTypes = []
        //textView.accessibilityIdentifier = "id.chatMessageInput"
        textView.delegate = self
        textView.inputAccessoryView = UIView()
        return textView
    }()
    
    lazy var recordButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.backgroundColor = .white
        button.setTitle("input_panel_hold_talk".localized, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 245 / 255.0, green: 245 / 255.0, blue: 245 / 255.0, alpha: 1).cgColor
        return button
    }()
    
    lazy var moreButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 18
        button.setImage(UIImage.set_image(named: "plus"), for: .normal)
        return button
    }()
    
    lazy var stickerBtn: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 18
        button.setImage(UIImage.set_image(named: "emoji"), for: .normal)
        button.setImage(UIImage.set_image(named: "keyboard"), for: .selected)
        return button
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 18
        button.setImage(UIImage.set_image(named: "speech"), for: .normal)
        //button.setImage(UIImage.set_image(named: "keyboard"), for: .selected)
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        return stack
    }()
    var greyView = UIView()
    
    // Recording
    var _recordPhase: AudioRecordPhase? = nil
    var recordPhase: AudioRecordPhase? = nil {
        willSet {
            
            let prevPhase = recordPhase
            _recordPhase = newValue
            self.audioRecordIndicator.phase = recordPhase
            if prevPhase == .end || prevPhase == .converterror {
                if  _recordPhase == .start {
                    delegate?.onStartRecording?()
                }
            }else if prevPhase == .start || prevPhase == .recording {
                if _recordPhase == .end {
                    delegate?.onStopRecording?()
                }
            }else if prevPhase == .cancelling {
                if _recordPhase == .end {
                    delegate?.onCancelRecording?()
                }
            }else if prevPhase == .converting {
                if _recordPhase == .converted {
                    self.audioRecordIndicator.phase = .converted
                    delegate?.onConverting?()
                }
                if _recordPhase == .converterror {
                    self.audioRecordIndicator.phase = .converterror
                    delegate?.onConvertError?()
                }
            }else if _recordPhase == .converterror {
                self.audioRecordIndicator.phase = .converterror
                delegate?.onConvertError?()
            }else if _recordPhase == .converted {
                self.audioRecordIndicator.phase = .converted
                delegate?.onConverting?()
            }
        }
    }
    
    var recognizedText: String = "" {
        didSet {
            SpeechVoiceDetectManager.shared.hasRecognizedText = true
            self.audioRecordIndicator.recognizedTextView.text = "\(recognizedText) ···"
            if SpeechVoiceDetectManager.shared.isRecordEnd == true {
                var recognizedStr = self.audioRecordIndicator.recognizedTextView.text
                recognizedStr = recognizedStr?.replacingOccurrences(of: "·", with: "")
                self.audioRecordIndicator.recognizedTextView.text = recognizedStr
            }
            
        }
    }
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    var recording: Bool = false {
        didSet {
            if recording {
                let soundShort = SystemSoundID(1519)
                AudioServicesPlaySystemSound(soundShort)
                self.audioRecordIndicator.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
                UIApplication.shared.windows.first?.addSubview(self.audioRecordIndicator)
                self.recordPhase = .end
                self.setRecordIndicatorAction()
                self.audioRecordIndicator.recordStateView.startMeterTimer()
            } else {
                self.audioRecordIndicator.recordStateView.stopMeterTimer()
                self.recordPhase = .end
                self.audioRecordIndicator.removeFromSuperview()
            }
        }
    }
    
    var audioRecordIndicator: InputAudioRecordIndicatorView = InputAudioRecordIndicatorView()
    
    var isShowingPressToTalk = false
    
    lazy var textfieldView: UIView = {
        let view = UIView()
        view.backgroundColor = RLColor.share.backGroundGray
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    var contentSubView = UIView()
    
    public var nickAccidDic = [String: String]()
    
    var locationView: TGInputLocalContainer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func commonUI() {
        self.layer.shadowColor = UIColor.black.cgColor  // 阴影颜色
        self.layer.shadowOpacity = 0.3                 // 阴影透明度，范围 0.0 到 1.0
        self.layer.shadowOffset = CGSize(width: 3, height: 3) // 阴影偏移量，x 和 y
        self.layer.shadowRadius = 5
        self.backgroundColor = .white
        self.addSubview(barStackView)
       // self.addSubview(stackView)
        self.addSubview(greyView)
        self.addSubview(contentSubView)
        
        barStackView.addArrangedSubview(moreButton)
        barStackView.addArrangedSubview(textfieldView)
        barStackView.addArrangedSubview(sendButton)
        
        textfieldView.addSubview(textView)
        textfieldView.addSubview(stickerBtn)
        textfieldView.addSubview(recordButton)
        
        recordButton.isHidden = true
        greyView.isHidden = true
        greyView.backgroundColor = RLColor.share.backGroundGray
        greyView.bindToEdges()
        recordButton.bindToEdges()
        stackView.spacing = 15
        
        barStackView.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.top.equalTo(5)
            //make.height.equalTo(40)
            make.right.equalTo(-8)
        }
        textfieldView.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
           
        }
        
        textView.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.bottom.top.equalTo(0)
            make.right.equalTo(-44)
            make.height.equalTo(40)
            
        }
        
        stickerBtn.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.bottom.equalTo(-2)
            make.right.equalTo(-4)
        }
        
        
        moreButton.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            
        }
        moreButton.addTarget(self, action: #selector(moreButtonAction), for: .touchUpInside)
        stickerBtn.addTarget(self, action: #selector(stickerButtonAction), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendButtonAction), for: .touchUpInside)
        
        sendButton.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }
        stickerBtn.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }
       
        contentSubView.snp.makeConstraints { make in
            make.top.equalTo(barStackView.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(TSBottomSafeAreaHeight)
        }
        locationView = TGInputLocalContainer(frame: .zero, callBackHandler: {[weak self] isSend, title, coordinate in
            self?.delegate?.didSendLocation(isSend: isSend, title: title, coordinate: coordinate)
        })
        contentSubView.addSubview(emojiView)
        contentSubView.addSubview(chatAddMoreView)
        contentSubView.addSubview(locationView)
        
        emojiView.isHidden = true
        chatAddMoreView.isHidden = true
        locationView.isHidden = true
        locationView.backgroundColor = .yellow

        emojiView.snp.makeConstraints { make in
            make.left.top.bottom.right.equalToSuperview()
        }
        chatAddMoreView.snp.makeConstraints { make in
            make.left.top.bottom.right.equalToSuperview()
        }
        locationView.snp.makeConstraints { make in
            make.left.top.bottom.right.equalToSuperview()
        }
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(recognizer:)))
        longPressRecognizer.delegate = self
        recordButton.addGestureRecognizer(longPressRecognizer)
        
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panAction(recognizer:)))
        panGesture.delegate = self
        recordButton.addGestureRecognizer(panGesture)
    }
    
    func configMoreViewData(conversationType: V2NIMConversationType) {
        self.conversationType = conversationType
        let moreItems = MessageUtils.mediaItems(conversationType: conversationType)
        chatAddMoreView.configData(data: moreItems)
    }
    
    func keyboardDismiss(){
        textView.resignFirstResponder()
        contentSubView.isHidden = true
        stickerBtn.isSelected = false
        moreButton.isSelected = false
        currentButton?.isSelected = false
    }
    
    @objc func moreButtonAction(){
        addMoreActionView()
    }
    @objc func stickerButtonAction(){
        addEmojiView()
    }
    @objc func sendButtonAction(){
        if textView.text.isEmpty {
            textView.resignFirstResponder()
            contentSubView.isHidden = true
            if recordButton.isHidden {
                recordButton.isHidden = false
                sendButton.setImage(UIImage.set_image(named: "keyboard"), for: .normal)
            } else {
                recordButton.isHidden = true
                sendButton.setImage(UIImage.set_image(named: "speech"), for: .normal)
            }
            delegate?.willSelectItem(show: false)
        } else {
            guard let text = getRealSendText(textView.attributedText) else {
                return
            }
            delegate?.sendText(text: text, attribute: textView.attributedText)
            textView.text = ""
            sendButton.setImage(UIImage.set_image(named: "speech"), for: .normal)
            textViewHeight = 40
            textView.snp.remakeConstraints { make in
                make.left.equalTo(8)
                make.bottom.top.equalTo(0)
                make.right.equalTo(-44)
                make.height.equalTo(textViewHeight)
                
            }
            
            delegate?.textFieldDidChange(textView)
        }

        
    }
    
    func addEmojiView() {
        stickerBtn.isSelected = !stickerBtn.isSelected
        if stickerBtn.isSelected {
            currentType = .sticker
            textView.resignFirstResponder()
            chatAddMoreView.isHidden = true
            contentSubView.isHidden = false
            emojiView.isHidden = false
            locationView.isHidden = true
            delegate?.willSelectItem(show: true)
        } else {
            contentSubView.isHidden = true
            textView.becomeFirstResponder()
            currentType = .text
        }
        
    }
    
    func addMoreActionView() {
        moreButton.isSelected = !moreButton.isSelected
        if moreButton.isSelected {
            currentType = .more
            textView.resignFirstResponder()
            chatAddMoreView.isHidden = false
            contentSubView.isHidden = false
            emojiView.isHidden = true
            locationView.isHidden = true
            delegate?.willSelectItem(show: true)
        } else {
            contentSubView.isHidden = true
            textView.becomeFirstResponder()
            currentType = .text
        }
        
    }
    
    func tapedLocationItem() {
        
        chatAddMoreView.isHidden = true
        contentSubView.isHidden = false
        emojiView.isHidden = true
        locationView.isHidden = false
        
    }
    
    func stopRecordAnimation() {
      greyView.isHidden = true
    }
    
    func updateAudioRecordTime(time: TimeInterval) {
        self.audioRecordIndicator.recordTime = time
    }
    
    // MARK: ===================== lazy method =====================
    
    lazy var emojiView: TGInputEmoticonContainer = {
        let view = TGInputEmoticonContainer(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 244.0))
        view.delegate = self
        return view
    }()
    
    lazy var chatAddMoreView: ChatMoreActionView = {
        let view = ChatMoreActionView(frame: CGRect(x: 0, y: 100, width: ScreenWidth, height: 244))
        view.isHidden = true
        view.delegate = self
        return view
    }()
    
    func checkRemoveAtMessage(range: NSRange, attribute: NSAttributedString) -> NSRange? {
        var temRange: NSRange?
        let start = range.location
        //    let end = range.location + range.length
        attribute.enumerateAttribute(
            NSAttributedString.Key.foregroundColor,
            in: NSMakeRange(0, attribute.length)
        ) { value, findRange, stop in
            guard let findColor = value as? UIColor else {
                return
            }
            if isEqualToColor(findColor, UIColor.blue) == false {
                return
            }
            if findRange.location <= start, start < findRange.location + findRange.length + atRangeOffset {
                temRange = NSMakeRange(findRange.location, findRange.length + atRangeOffset)
                stop.pointee = true
            }
        }
        return temRange
    }
    
    private func isEqualToColor(_ color1: UIColor, _ color2: UIColor) -> Bool {
        guard let components1 = color1.cgColor.components,
              let components2 = color2.cgColor.components,
              color1.cgColor.colorSpace == color2.cgColor.colorSpace,
              color1.cgColor.numberOfComponents == 4,
              color2.cgColor.numberOfComponents == 4
        else {
            return false
        }
        
        return components1[0] == components2[0] && // Red
        components1[1] == components2[1] && // Green
        components1[2] == components2[2] && // Blue
        components1[3] == components2[3] // Alpha
    }
    @objc func missClickEmoj() {
      print("click one px space")
    }
    
    func getRealSendText(_ attribute: NSAttributedString) -> String? {
        let muta = NSMutableString()
        
        attribute.enumerateAttributes(
            in: NSMakeRange(0, attribute.length),
            options: NSAttributedString.EnumerationOptions(rawValue: 0)
        ) { dics, range, stop in
            
//            if let neAttachment = dics[NSAttributedString.Key.attachment] as? TGNEEmotionAttachment,
//               let des = neAttachment.emotion?.tag {
//                muta.append(des)
//            } else {
//                let sub = attribute.attributedSubstring(from: range).string
//                muta.append(sub)
//            }
            let sub = attribute.attributedSubstring(from: range).string
            muta.append(sub)
        }
        return muta as String
    }
    
    func setRecordIndicatorAction() {
        self.audioRecordIndicator.cancelImageView.addTap { [weak self] (v) in
            guard let self = self else { return }
            self.audioRecordIndicator.recognizedTextView.resignFirstResponder()
            self.delegate?.cancelButtonTapped?()
        }
        self.audioRecordIndicator.sendVoiceImageView.addTap { [weak self] (v) in
            guard let self = self else { return }
            self.delegate?.sendVoiceButtonTapped?()
        }
        self.audioRecordIndicator.sendMsgImageView.addTap { [weak self] (v) in
            guard let self = self, self.recordPhase != .converterror else { return }
            self.audioRecordIndicator.recognizedTextView.resignFirstResponder()
            self.delegate?.sendVoiceMsgTextButtonTapped?()
        }
        self.audioRecordIndicator.moreButton.addTap { [weak self] (v) in
            guard let self = self else { return }
            self.delegate?.moreLanguageButtonTapped?()
        }
    }
    
    func updateUI(textHeight: CGFloat) {
        
        if textHeight > maxTextViewHeight {
            textViewHeight = maxTextViewHeight
        } else if textHeight < 40  {
            textViewHeight = 40
        } else {
            textViewHeight = textHeight
        }
        textView.snp.remakeConstraints { make in
            make.left.equalTo(8)
            make.bottom.top.equalTo(0)
            make.right.equalTo(-44)
            make.height.equalTo(textViewHeight)
            
        }
    }
}

extension BaseChatInputView: UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textField.resignFirstResponder()
        return true
    }
    public func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            sendButton.isEnabled =  true
            sendButton.setImage(UIImage.set_image(named: "speech"), for: .normal)
        } else {
            sendButton.setImage(UIImage.set_image(named: "icASendBlue"), for: .normal)
            recordButton.isHidden = true
        }
        
        // At
        let selectedRange = textView.markedTextRange
        if selectedRange == nil {
            HTMLManager.shared.formatTextViewAttributeText(textView)
           // return
        }
        let height = textView.text.heightWithConstrainedWidth(width: ScreenWidth - 152, font: UIFont.systemFont(ofSize: 16))
        self.updateUI(textHeight: height)
        delegate?.textFieldDidChange(textView)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textFieldDidEndEditing(textView)
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        currentType = .text
        delegate?.textFieldDidBeginEditing(textView)
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        currentType = .text
        return true
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                         replacementText text: String) -> Bool {
        print("text view range : ", range)
        print("select range : ", textView.selectedRange)
        textView.typingAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        
        if textView.attributedText.length == 0, let pasteString = UIPasteboard.general.string, text.count > 0 {
            if pasteString == text {
                let muta = NSMutableAttributedString(string: text)
                muta.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)], range: NSMakeRange(0, text.count))
                textView.attributedText = muta
                textView.selectedRange = NSMakeRange(text.count - 1, 0)
                ///计算高度
                let height = textView.text.heightWithConstrainedWidth(width: ScreenWidth - 152, font: UIFont.systemFont(ofSize: 16))
                self.updateUI(textHeight: height)
                delegate?.textFieldDidChange(textView)
                return false
            }
        }
        
        if text.count == 0 {
            let selectRange = textView.selectedRange
            if selectRange.length > 0 {
                if let selecttextRange = textView.selectedTextRange {
                    let userText = textView.text(in: selecttextRange)
                    self.delegate?.removeAtUsertext(text: userText ?? "")
                }
                return true
            }
            // 整体删除at的关键词，修改为整体选中
            var isEditAt = false
            var atRange = selectRange
            let matchs = TGUtil.findAllTSAt(inputStr: textView.text)
            for match in matchs {
                let newRange = NSRange(location: match.range.location + 1, length: match.range.length - 1)
                if NSLocationInRange(range.location, newRange) {
                    isEditAt = true
                    atRange = match.range
                    break
                }
            }
            
            if isEditAt {
                HTMLManager.shared.formatTextViewAttributeText(textView)
                textView.selectedRange = atRange
                return false
            }
            return true
        } else {
            if let flag = delegate?.textChanged(text: text) {
                return flag
            } else {
                return true
            }
        }
        
        
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        print("textViewDidChangeSelection")
        let range = textView.selectedRange
        if range.length > 0 {
            return
        }
        let matchs = TGUtil.findAllTSAt(inputStr: textView.text)
        for match in matchs {
            let newRange = NSRange(location: match.range.location + 1, length: match.range.length - 1)
            if NSLocationInRange(range.location, newRange) {
                textView.selectedRange = NSRange(location: match.range.location + match.range.length, length: 0)
                break
            }
        }
        if textView.text.isEmpty {
            sendButton.isEnabled =  true
            sendButton.setImage(UIImage.set_image(named: "speech"), for: .normal)
        } else {
            sendButton.setImage(UIImage.set_image(named: "icASendBlue"), for: .normal)
        }
    }
    
    @available(iOS 10.0, *)
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print("action : ", interaction)
        
        return true
    }
    
    func insertTagTextIntoContent (userId: Int? = nil, userName: String) {
        self.textView = TGCommonTool.atMeTextViewEdit(self.textView) as! KMPlaceholderTextView
        
        let temp = HTMLManager.shared.addUserIdToTagContent(userId: userId, userName: userName)
        let newMutableString = self.textView.attributedText.mutableCopy() as! NSMutableAttributedString
        newMutableString.append(temp)
        
        self.textView.attributedText = newMutableString
        self.textView.delegate?.textViewDidChange!(textView)
        self.textView.becomeFirstResponder()
        self.textView.insertText("")
    }
}
// MARK: more - ChatMoreViewDelegate
extension BaseChatInputView: ChatMoreViewDelegate {
    func moreViewDidSelectMoreCell(moreView: ChatMoreActionView, cell: InputMoreCell) {
        guard let item = cell.cellData else {
            return
        }
        if item == .sendLocation {
            tapedLocationItem()
        } else {
            delegate?.didSelectMoreCell(cell: cell)
        }
    }
}

// MARK: 录音
extension BaseChatInputView: UIGestureRecognizerDelegate {
    
    @objc public func panAction(recognizer: UIPanGestureRecognizer) {
        if  SpeechVoiceDetectManager.shared.isRecordEnd == true {
            return
        }
        let translationPoint: CGPoint = recognizer.translation(in: self.superview)
        let centerP: CGPoint = recognizer.view?.center ?? CGPoint.zero
        var pointX = centerP.x + translationPoint.x
        var pointY = centerP.y + translationPoint.y
        switch recognizer.state {
            
        case  .changed:
            if pointY > 0 {
                recordPhase = .recording
                UIView.animate(withDuration: 0.1, animations: {
                    self.audioRecordIndicator.cancelImageView.transform = .identity
                    self.audioRecordIndicator.convertImageView.transform = .identity
                })
                return
            }
            if pointX < ScreenWidth / 2 {
                recordPhase = .cancelling
                UIView.animate(withDuration: 0.1, animations: {
                    self.audioRecordIndicator.cancelImageView.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.0)
                })
            } else {
                recordPhase = .converting
                UIView.animate(withDuration: 0.1, animations: {
                    self.audioRecordIndicator.convertImageView.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.0)
                })
            }
        case .ended:
            audioRecordIndicator.cancelImageView.transform = .identity
            audioRecordIndicator.convertImageView.transform = .identity
        @unknown default:
            break
        }
    }
    @objc public func longPress(recognizer:UILongPressGestureRecognizer) {
        
        if recognizer.state == .began {
            SpeechVoiceDetectManager.shared.isRecordEnd = false
            SpeechVoiceDetectManager.shared.hasRecognizedText = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) { [weak self] in
                self?.recordPhase = .start
            }
        } else if recognizer.state == .ended {
            SpeechVoiceDetectManager.shared.isRecordEnd = true
            let isConvert = (recordPhase == .converting || recordPhase == .converted)
            if isConvert && self.recognizedText.isEmpty {
                //没有识别到任何文字
                recordPhase = .converterror
            } else {
                recordPhase = isConvert == true ? .converted : .end
            }
        }
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension BaseChatInputView: TGInputEmoticonProtocol {
    func didPressSend(_ sender: Any?) {
        
    }
    
    func didPressAdd(_ sender: Any?) {
        self.delegate?.didPressAdd(sender)
    }
    
    func selectedEmoticon(_ emoticonID: String?, catalog emotCatalogID: String?, description: String?, stickerId: String?) {
        self.delegate?.selectedEmoticon(emoticonID, catalog: emotCatalogID, description: description, stickerId: stickerId)
    }
    
    func sendEmoji(_ emojiTag: String?) {
        guard let emojiTag = emojiTag else { return }
        self.textView.insertText(emojiTag)
    }
    
    func didPressMySticker(_ sender: Any?) {
        self.delegate?.didPressMySticker(sender)
    }
    
    func didPressCustomerSticker() {
        self.delegate?.didPressCustomerSticker()
    }
    
    
}


struct AutoMentionsUser {
    
    let text: String
    
    let context: [String: Any]?
    
    init(text: String, context: [String: Any]? = nil) {
        self.text = text
        self.context = context
    }

}
