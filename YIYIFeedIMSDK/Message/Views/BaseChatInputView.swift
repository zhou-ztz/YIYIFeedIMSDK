//
//  BaseChatInputView.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/8.
//

import UIKit
import KMPlaceholderTextView

enum ChatMenuType: Int {
  case text = 0
  case audio
  case emoji
  case image
  case addMore
}

public let yxAtMsg = "yxAitMsg"
public let atRangeOffset = 1
public let atSegmentsKey = "segments"
public let atTextKey = "text"

protocol ChatInputViewDelegate: NSObjectProtocol {
  func sendText(text: String?, attribute: NSAttributedString?)
  func willSelectItem(button: UIButton?, index: Int)
  func didSelectMoreCell(cell: InputMoreCell)

  @discardableResult
  func textChanged(text: String) -> Bool
  func textDelete(range: NSRange, text: String) -> Bool
  func startRecord()
  func moveOutView()
  func moveInView()
  func endRecord(insideView: Bool)
  func textFieldDidChange(_ textField: UITextView)
  func textFieldDidEndEditing(_ textField: UITextView)
  func textFieldDidBeginEditing(_ textField: UITextView)
}

class BaseChatInputView: UIView {
    
    weak var delegate: ChatInputViewDelegate?

    var currentType: ChatMenuType = .text
    var currentButton: UIButton?
    var menuHeight = 100.0
    var contentHeight = 204.0
    
    lazy var textView: KMPlaceholderTextView = {
        let textView = KMPlaceholderTextView()
        textView.placeholder = "请输入"
        //textView.placeholderLabel.numberOfLines = 1
        textView.layer.cornerRadius = 8
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.clipsToBounds = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .white
        textView.returnKeyType = .send
        textView.allowsEditingTextAttributes = true
        textView.typingAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        textView.dataDetectorTypes = []
        //textView.accessibilityIdentifier = "id.chatMessageInput"
        textView.delegate = self
        textView.inputAccessoryView = UIView()
        return textView
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        return stack
    }()
    var greyView = UIView()
    var recordView = ChatRecordView(frame: .zero)
    
    var contentSubView = UIView()
    
    public var nickAccidDic = [String: String]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        //NotificationCenter.default.removeObserver(self)
    }

    func commonUI() {
        
        self.backgroundColor = RLColor.share.backGroundGray
        self.addSubview(textView)
        self.addSubview(stackView)
        self.addSubview(greyView)
        self.addSubview(contentSubView)
        greyView.isHidden = true
        greyView.backgroundColor = RLColor.share.backGroundGray
        greyView.bindToEdges()
        stackView.spacing = 15
        textView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(7)
            make.top.equalTo(6)
            make.height.equalTo(40)
        }
        
        let imageNames = ["mic", "emoji", "photo", "add"]
        let imageNamesSelected = ["mic_selected", "emoji_selected", "photo", "add_selected"]
       
        for i in 0 ..< imageNames.count {
            
            let button = UIButton()
            button.setImage(UIImage(named: imageNames[i]), for: .normal)
            button.setImage(UIImage(named: imageNamesSelected[i]), for: .selected)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(buttonEvent), for: .touchUpInside)
            button.tag = i + 5
            stackView.addArrangedSubview(button)

        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom)
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(54)
        }
        
        contentSubView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(200)
        }
        contentSubView.addSubview(recordView)
        contentSubView.addSubview(emojiView)
        contentSubView.addSubview(chatAddMoreView)
        recordView.isHidden = true
        emojiView.isHidden = true
        chatAddMoreView.isHidden = true
        var moreData: [NEMoreItemModel] = []
        let moreImageNames = ["chat_takePicture", "chat_location", "chat_file", "chat_rtc"]
        let moreTitles = ["拍摄", "位置", "文件", "音视频通话"]
        for (index, title) in moreTitles.enumerated() {
            let model = NEMoreItemModel(image: UIImage(named: moreImageNames[index]), title: title, type: NEMoreActionType(rawValue: index + 1))
            moreData.append(model)
        }
        chatAddMoreView.configData(data: moreData)
        
        recordView.snp.makeConstraints { make in
            make.left.top.bottom.right.equalToSuperview()
        }
        emojiView.snp.makeConstraints { make in
            make.left.top.bottom.right.equalToSuperview()
        }
        chatAddMoreView.snp.makeConstraints { make in
            make.left.top.bottom.right.equalToSuperview()
        }
        
        recordView.delegate = self
    }
    
    
    
    @objc func buttonEvent(_ button: UIButton){
        button.isSelected = !button.isSelected
        if button.tag - 5 != 2, button != currentButton {
            currentButton?.isSelected = false
            currentButton = button
        }
        switch button.tag - 5 {
        case 0:
            addRecordView()
        case 1:
            addEmojiView()
        case 2:
            button.isSelected = true
        case 3:
            addMoreActionView()
        default:
            print("default")
        }
        delegate?.willSelectItem(button: button, index: button.tag - 5)
    }
    
    func addRecordView() {
        currentType = .audio
        textView.resignFirstResponder()
        chatAddMoreView.isHidden = true
        contentSubView.isHidden = false
        recordView.isHidden = false
        emojiView.isHidden = true
    }
    
    func addEmojiView() {
        currentType = .emoji
        textView.resignFirstResponder()
        chatAddMoreView.isHidden = true
        contentSubView.isHidden = false
        recordView.isHidden = true
        emojiView.isHidden = false
    }
    
    func addMoreActionView() {
        currentType = .addMore
        textView.resignFirstResponder()
       
        chatAddMoreView.isHidden = false
        contentSubView.isHidden = false
        recordView.isHidden = true
        emojiView.isHidden = true
    }
    
    public func stopRecordAnimation() {
      greyView.isHidden = true
      recordView.stopRecordAnimation()
    }
    
    // MARK: ===================== lazy method =====================
    
    public lazy var emojiView: UIView = {
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 200))
        let view = InputEmoticonContainerView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 200))
        view.delegate = self
        backView.isHidden = true
        
        backView.backgroundColor = UIColor.clear
        backView.addSubview(view)
        let tap = UITapGestureRecognizer()
        backView.addGestureRecognizer(tap)
        tap.addTarget(self, action: #selector(missClickEmoj))
        return backView
    }()
    
    public lazy var chatAddMoreView: ChatMoreActionView = {
        let view = ChatMoreActionView(frame: CGRect(x: 0, y: 100, width: ScreenWidth, height: 200))
        view.isHidden = true
        view.delegate = self
        return view
    }()
    
    public func checkRemoveAtMessage(range: NSRange, attribute: NSAttributedString) -> NSRange? {
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
            
            //      if (findRange.location <= start && start < findRange.location + findRange.length + atRangeOffset) ||
            //        (findRange.location < end && end <= findRange.location + findRange.length + atRangeOffset) {
            //        temRange = NSMakeRange(findRange.location, findRange.length + atRangeOffset)
            //        stop.pointee = true
            //      }
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
            
            if let neAttachment = dics[NSAttributedString.Key.attachment] as? NEEmotionAttachment,
               let des = neAttachment.emotion?.tag {
                muta.append(des)
            } else {
                let sub = attribute.attributedSubstring(from: range).string
                muta.append(sub)
            }
        }
        return muta as String
    }
    
    public func getRemoteExtension(_ attri: NSAttributedString?) -> [String: Any]? {
        guard let attribute = attri else {
            return nil
        }
        var atDic = [String: [String: Any]]()
        let string = attribute.string
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
            if let range = Range(findRange, in: string) {
                let text = string[range]
                let model = MessageAtInfoModel()
                print("range text : ", String(text))
                model.start = findRange.location
                model.end = model.start + findRange.length
                var dic: [String: Any]?
                var array: [Any]?
                if let accid = nickAccidDic[String(text)] {
                    if let atCacheDic = atDic[accid] {
                        dic = atCacheDic
                    } else {
                        dic = [String: Any]()
                    }
                    
                    if let atCacheArray = dic?[atSegmentsKey] as? [Any] {
                        array = atCacheArray
                    } else {
                        array = [Any]()
                    }
                    
                    do {
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted 
                        let jsonData = try encoder.encode(model)
                        if let object = String(data: jsonData, encoding: .utf8) {
                            array?.append(object)
                        }
                    } catch {
                        print("Error encoding person to JSON: \(error)")
                    }
//                    if let object = model.yx_modelToJSONObject() {
//                        array?.append(object)
//                    }
                    dic?[atSegmentsKey] = array
                    dic?[atTextKey] = String(text) + " "
                    dic?[#keyPath(MessageAtCacheModel.accid)] = accid
                    atDic[accid] = dic
                }
            }
        }
        if atDic.count > 0 {
            return [yxAtMsg: atDic]
        }
        return nil
    }
    
    public func getAtRemoteExtension() -> [String: Any]? {
     //   var atDic = [String: Any]()
//        NELog.infoLog(className(), desc: "at range cache : \(atRangeCache)")
//        atRangeCache.forEach { (key: String, value: MessageAtCacheModel) in
//            if let userValue = atDic[value.accid] as? [String: AnyObject], var array = userValue[atSegmentsKey] as? [Any], let object = value.atModel.yx_modelToJSONObject() {
//                array.append(object)
//                if var dic = atDic[value.accid] as? [String: Any] {
//                    dic[atSegmentsKey] = array
//                    atDic[value.accid] = dic
//                }
//            } else if let object = value.atModel.yx_modelToJSONObject() {
//                var array = [Any]()
//                array.append(object)
//                var dic = [String: Any]()
//                dic[atTextKey] = value.text
//                dic[atSegmentsKey] = array
//                atDic[value.accid] = dic
//            }
//        }
//        NELog.infoLog(className(), desc: "at dic value : \(atDic)")
//        if atDic.count > 0 {
//            return [yxAtMsg: atDic]
//        }
        return nil
    }
}

extension BaseChatInputView: UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textField.resignFirstResponder()
        return true
    }
    public func textViewDidChange(_ textView: UITextView) {
      delegate?.textFieldDidChange(textView)
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
      delegate?.textFieldDidEndEditing(textView)
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
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

      if text == "\n" {
        guard var realText = getRealSendText(textView.attributedText) else {
          return true
        }
        if realText.trimmingCharacters(in: .whitespaces).isEmpty {
          realText = ""
        }
        delegate?.sendText(text: realText, attribute: textView.attributedText)
        textView.text = ""
        return false
      }

      if textView.attributedText.length == 0, let pasteString = UIPasteboard.general.string, text.count > 0 {
        if pasteString == text {
          let muta = NSMutableAttributedString(string: text)
          muta.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)], range: NSMakeRange(0, text.count))
          textView.attributedText = muta
          textView.selectedRange = NSMakeRange(text.count - 1, 0)
          return false
        }
      }

      if text.count == 0 {
  //      let selectRange = textView.selectedRange
        let temRange = checkRemoveAtMessage(range: range, attribute: textView.attributedText)

        if let findRange = temRange {
          let mutableAttri = NSMutableAttributedString(attributedString: textView.attributedText)
          if mutableAttri.length >= findRange.location + findRange.length {
            mutableAttri.removeAttribute(NSAttributedString.Key.foregroundColor, range: findRange)
            mutableAttri.removeAttribute(NSAttributedString.Key.font, range: findRange)
            if range.length == 1 {
              mutableAttri.replaceCharacters(in: findRange, with: "")
            }
            if mutableAttri.length <= 0 {
              textView.attributedText = nil
            } else {
              textView.attributedText = mutableAttri
            }
            textView.selectedRange = NSMakeRange(findRange.location, 0)
          }
          return false
        }
        return true
      } else {
        delegate?.textChanged(text: text)
      }

      return true
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
      print("textViewDidChangeSelection")
      let range = textView.selectedRange
      if let findRange = checkRemoveAtMessage(range: range, attribute: textView.attributedText) {
        textView.selectedRange = NSMakeRange(findRange.location + findRange.length, 0)
      }
    }

    @available(iOS 10.0, *)
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
      print("action : ", interaction)

      return true
    }
}
// MARK: more - ChatMoreViewDelegate
extension BaseChatInputView: ChatMoreViewDelegate {
    func moreViewDidSelectMoreCell(moreView: ChatMoreActionView, cell: InputMoreCell) {
        
        delegate?.didSelectMoreCell(cell: cell)
    }
}
// MARK: 录音 - ChatRecordViewDelegate
extension BaseChatInputView: ChatRecordViewDelegate {
    func startRecord() {
        greyView.isHidden = false
        delegate?.startRecord()
    }
    
    func moveOutView() {
        delegate?.moveOutView()
    }
    
    func moveInView() {
        delegate?.moveInView()
    }
    
    func endRecord(insideView: Bool) {
        greyView.isHidden = true
        delegate?.endRecord(insideView: insideView)
    }
    
    
}

extension BaseChatInputView: InputEmoticonContainerViewDelegate {
    func selectedEmoticon(emoticonID: String, emotCatalogID: String, description: String) {
        if emoticonID.isEmpty { // 删除键
          textView.deleteBackward()
          print("delete ward")
        } else {
          if let font = textView.font {
            let attribute = NEEmotionTool.getAttWithStr(
              str: description,
              font: font,
              CGPoint(x: 0, y: -4)
            )
            print("attribute : ", attribute)
            let mutaAttribute = NSMutableAttributedString()
            if let origin = textView.attributedText {
              mutaAttribute.append(origin)
            }
            attribute.enumerateAttribute(
              NSAttributedString.Key.attachment,
              in: NSMakeRange(0, attribute.length)
            ) { value, range, stop in
              if let neAttachment = value as? NEEmotionAttachment {
                print("ne attachment bounds ", neAttachment.bounds)
              }
            }
            mutaAttribute.append(attribute)
            mutaAttribute.addAttribute(
              NSAttributedString.Key.font,
              value: font,
              range: NSMakeRange(0, mutaAttribute.length)
            )
            textView.attributedText = mutaAttribute
            textView.scrollRangeToVisible(NSMakeRange(textView.attributedText.length, 1))
          }
        }
    }
    
    func didPressSend(sender: UIButton) {
        guard let text = getRealSendText(textView.attributedText) else {
          return
        }
        delegate?.sendText(text: text, attribute: textView.attributedText)
        textView.text = ""
        //atCache?.clean()
    }
    
    
}
