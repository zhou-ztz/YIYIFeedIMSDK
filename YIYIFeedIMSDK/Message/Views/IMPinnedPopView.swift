//
//  IMPinnedPopView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/13.
//

import UIKit
import SDWebImage
import NIMSDK
import AVFoundation

protocol IMPinnedPopViewDeleagte: AnyObject {
    func didClickImageVideo(model: FavoriteMsgModel)
    func didClickLocaltion(title: String, lat: Double, lng: Double, popView: IMPinnedPopView)
    func didClickFile(attachment: IMFileCollectionAttachment)
    func didClickAudio(model: FavoriteMsgModel)
    func didClickContactCard(memberId: String, popView: IMPinnedPopView)
    func didClickEgg(attachment: IMEggAttachment, nickName: String, avatarInfo: AvatarInfo)
    func didClickMeeting(meetingNum: String, meetingPw: String)
    func didUpdateProfileData(_ data: String, avatar: AvatarInfo)
}

class IMPinnedPopView: UIView {

    var type: MessageCollectionType = .text
    var pinItem: PinnedMessageModel
    
    var dictModel: PinnedDictModel?
    
    weak var delegate: IMPinnedPopViewDeleagte?
    
    var fileAttachment: IMFileCollectionAttachment?
    var meetingNum: String?
    var meetingPw: String?
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10
        stackView.distribution = .fill
        return stackView
    }()
    
    lazy var contentLable: UILabel = {
        let name = UILabel()
        name.textColor = UIColor(red: 0, green: 0, blue: 0)
        name.font = UIFont.systemFont(ofSize: 15)
        name.textAlignment = .left
        name.numberOfLines = 0
        name.text = ""
        return name
    }()
    
    lazy var contentScrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false

        view.bounces = false
        return view
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var imageView: SDAnimatedImageView = {
        let image = SDAnimatedImageView()
        //image.image = UIImage(named: "IMG_icon")
        //image.backgroundColor = .lightGray
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var playImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "ico_video_play_list")
        return image
    }()
    
    lazy var sizeLable: UILabel = {
        let name = UILabel()
        name.textColor = UIColor(red: 109, green: 114, blue: 120)
        name.font = UIFont.systemFont(ofSize: 12)
        name.textAlignment = .center
        name.numberOfLines = 1
        name.text = "567kb"
        return name
    }()
    
    lazy var fileImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "icUnknownL")
        image.contentMode = .scaleAspectFit
        return image
    }()
    lazy var avatarView: TGAvatarView = {
        let view = TGAvatarView(type: .width70(showBorderLine: false))
        view.avatarPlaceholderType = .unknown
        return view
    }()
    
    lazy var openBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 5
        btn.clipsToBounds = true
        btn.backgroundColor = .lightGray
        btn.titleLabel?.font = UIFont.systemRegularFont(ofSize: 15)
        return btn
    }()
    
    init(pinItem: PinnedMessageModel){
        self.pinItem = pinItem
        super.init(frame: .zero)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI(){
        backgroundColor = .white
        contentView.backgroundColor = UIColor(red: 245, green: 245, blue: 245)
        contentView.layer.cornerRadius = 5.0
        contentView.clipsToBounds = true
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(0)
            make.width.equalTo(ScreenWidth - 80)
        }
        contentView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.bottom.equalTo(-10)
            make.left.right.top.equalToSuperview()
        }
        pinnedMessageForModel(model: pinItem)
        
    }
    
    func pinnedMessageForModel(model: PinnedMessageModel){
        guard let contentStr = model.content, let data = contentStr.data(using: .utf8) else {
            return
        }
        
        do {
            let model = try JSONDecoder().decode(PinnedDictModel.self, from: data)
            dictModel = model
        } catch  {
            print("jsonerror = \(error.localizedDescription)")
        }
        
        guard let objectModel = dictModel  else {
            return
        }
        self.type = MessageCollectionType(rawValue: objectModel.type ?? 0) ?? MessageCollectionType.text
        switch type {
        case .text:
            setTextUI(model: objectModel)
        case .image, .video:
            setImageVideoUI(model: objectModel)
        case .file:
            setFileUI(model: objectModel)
        case .location:
            setLocaltionUI(model: objectModel)
        case .audio:
            setAudioUI(model: objectModel)
        case .nameCard:
            setNameCardUI(model: objectModel)
        case .rps:
            setRPSUI(model: objectModel)
        case .egg:
            setEggUI(model: objectModel)
        case .meeting:
            setMeettingUI(model: objectModel)
        default:
            break
        }
    }
    
    @objc func openFile(){
        guard let attachment = self.fileAttachment else { return }
        self.delegate?.didClickFile(attachment: attachment)
    }
    @objc func openMeeting(){
        guard let meetingNum = self.meetingNum else { return }
        self.delegate?.didClickMeeting(meetingNum: meetingNum, meetingPw: meetingPw ?? "")
    }
    
    private func setTextUI(model: PinnedDictModel){
        contentLable.text = model.content
        contentStackView.addArrangedSubview(contentScrollView)
        contentScrollView.addSubview(contentLable)
        
        contentScrollView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
            make.height.lessThanOrEqualTo(ScreenHeight - 180)
        }
        
        contentLable.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.left.right.equalToSuperview().inset(6)
            make.width.equalTo(ScreenWidth - 92)
        }
      
        contentLable.layoutIfNeeded()
        contentScrollView.layoutIfNeeded()
        
        contentScrollView.contentSize = CGSizeMake(contentLable.bounds.size.width, contentLable.bounds.size.height + 24)
        
        let h  = contentLable.bounds.size.height <= ScreenHeight - 180 ? contentLable.bounds.size.height : ScreenHeight - 180
        contentScrollView.snp.remakeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
            make.height.equalTo(h + 24)
        }
    }
    private func setImageVideoUI(model: PinnedDictModel){
        var size: CGSize = CGSizeMake(200, 200)
        imageView.isUserInteractionEnabled = true
        contentStackView.addArrangedSubview(imageView)
        
        contentStackView.snp.remakeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
            make.height.equalTo(ScreenHeight * 0.7)
        }
        
        contentView.backgroundColor = .black
        imageView.addSubview(playImage)
        playImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(40)
        }
        guard let dataAttach = model.attachment?.data(using: .utf8) else {
            return
        }
        imageView.addAction {
            let model = FavoriteMsgModel(Id: 0, type: self.type, data: self.pinItem.content ?? "", ext: "", uniqueId: "", createTime: 0, updateTime: 0)
            self.delegate?.didClickImageVideo(model: model)
        }
        if type == .image {
            playImage.isHidden = true
            do {
                let attach = try JSONDecoder().decode(IMImageCollectionAttachment.self, from: dataAttach)
                self.imageView.sd_setImage(with: URL(string: attach.url), completed: nil)
                size = imageSize(attach.w, h: attach.h)
               
            } catch  {
                print("jsonerror = \(error.localizedDescription)")
            }
        } else {
            playImage.isHidden = false
            do {
                let attach = try JSONDecoder().decode(IMVideoCollectionAttachment.self, from: dataAttach)
                
                if let url = URL(string: attach.url) {
                    DispatchQueue.global().async {
                        let image = self.generateThumnail(url: url)
                        DispatchQueue.main.async {
                            self.imageView.image = image
                        }
                        
                    }
                    
                }
                size = imageSize(attach.w, h: attach.h)

            } catch  {
                print("jsonerror = \(error.localizedDescription)")
            }
        }
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(size.height)
            make.width.equalTo(size.width)
        }
        
    }
    
    private func setFileUI(model: PinnedDictModel){
        contentStackView.snp.makeConstraints { make in
            make.bottom.equalTo(-10)
        }
        contentStackView.addArrangedSubview(fileImageView)
        fileImageView.snp.makeConstraints { (make) in
            make.width.equalTo(93)
            make.height.equalTo(114)
            make.top.equalTo(10)
            make.centerX.equalToSuperview()
        }
        contentStackView.addArrangedSubview(contentLable)
        contentLable.textAlignment = .center
        contentLable.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
        }
        contentStackView.addArrangedSubview(sizeLable)
        sizeLable.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
        }
        contentStackView.addArrangedSubview(openBtn)
        openBtn.snp.makeConstraints { make in
            make.bottom.equalTo(-10)
            make.centerX.equalToSuperview()
            make.height.equalTo(34)
            make.width.equalTo(100)
        }
        openBtn.backgroundColor = TGAppTheme.secondaryColor
        openBtn.setTitleColor(TGAppTheme.twilightBlue, for: .normal)
        openBtn.setTitle("open".localized, for: .normal)
        openBtn.addTarget(self, action: #selector(openFile), for: .touchUpInside)
        contentStackView.alignment = .center
        
        guard let dataAttach = model.attachment?.data(using: .utf8) else {
            return
        }
        do {
            let attach = try JSONDecoder().decode(IMFileCollectionAttachment.self, from: dataAttach)
            fileImageView.image = RLSendFileManager.fileIcon(with:attach.ext).icon
            self.contentLable.text = attach.name
            
            let size: Int64 = attach.size / 1024
            self.sizeLable.text = String(format: "%lldKB", size)
            fileAttachment = attach
        } catch  {
            print("jsonerror = \(error.localizedDescription)")
        }
    }
    
    private func setLocaltionUI(model: PinnedDictModel){
        imageView.image = UIImage(named: "rectangle")
        contentStackView.addArrangedSubview(imageView)
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(144)
        }
        contentStackView.addArrangedSubview(contentLable)
        contentLable.textAlignment = .left
        contentLable.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        guard let dataAttach = model.attachment?.data(using: .utf8) else {
            return
        }
        do {
            let attach = try JSONDecoder().decode(IMLocationCollectionAttachment.self, from: dataAttach)
            self.contentLable.text = attach.title
            contentView.addAction {
                self.delegate?.didClickLocaltion(title: attach.title, lat: attach.lat, lng: attach.lng, popView: self)
            }
        } catch  {
            print("jsonerror = \(error.localizedDescription)")
        }
    }
    
    private func setAudioUI(model: PinnedDictModel){
        imageView.image = UIImage(named: "voice_play_gray")
        contentStackView.addArrangedSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview().inset(10)
            make.height.width.equalTo(60)
        }
        //contentStackView.addArrangedSubview(contentLable)
        contentView.addSubview(contentLable)
        contentLable.textAlignment = .left
        contentLable.snp.makeConstraints { make in
            make.left.equalTo(80)
            make.height.equalTo(80)
            make.right.equalTo(0)
        }
        contentView.addAction {
            let model = FavoriteMsgModel(Id: 0, type: self.type, data: self.pinItem.content ?? "", ext: "", uniqueId: "", createTime: 0, updateTime: 0)
            self.delegate?.didClickAudio(model: model)
        }
        guard let dataAttach = model.attachment?.data(using: .utf8) else {
            return
        }
        do {
            let attach = try JSONDecoder().decode(IMAudioCollectionAttachment.self, from: dataAttach)
            var milliseconds = Float(attach.dur)
            milliseconds = milliseconds / 1000
            let currSeconds = Int(fmod(milliseconds, 60))
            let currMinute = Int(fmod((milliseconds / 60), 60))
            contentLable.text = String(format: "%d:%02d", currMinute, currSeconds)
           
        } catch  {
            print("jsonerror = \(error.localizedDescription)")
        }
    }
    
    private func setNameCardUI(model: PinnedDictModel){
        
        contentStackView.addArrangedSubview(avatarView)
       
        avatarView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview().inset(10)
            make.height.width.equalTo(70)
        }
        contentView.addSubview(contentLable)
        contentLable.textAlignment = .left
        contentLable.snp.makeConstraints { make in
            make.left.equalTo(92)
            //make.height.equalTo(60)
            make.right.equalTo(-10)
            make.centerY.equalTo(avatarView.snp.centerY)
        }
        guard let dataAttach = model.attachment?.data(using: .utf8) else {
            return
        }
        do {
            let dict = try JSONSerialization.jsonObject(with: dataAttach, options: []) as! [String: Any]
            if let dictData = dict[CMData] as? [String: String], let memberId = dictData[CMContactCard] {
                MessageUtils.getAvatarIcon(sessionId: memberId, conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
                    self?.contentLable.text = avatarInfo.nickname
                    self?.avatarView.avatarInfo = avatarInfo
                    self?.delegate?.didUpdateProfileData(avatarInfo.nickname ?? "", avatar: avatarInfo)
                }
               
                contentView.addAction {
                    self.delegate?.didClickContactCard(memberId: memberId, popView: self)
                }
            }
        } catch  {
            print("jsonerror = \(error.localizedDescription)")
        }
    }
    
    private func setEggUI(model: PinnedDictModel){
        contentView.backgroundColor = UIColor(red: 236, green: 172, blue: 162)
        imageView.image = UIImage(named: "egg_icon")
        contentStackView.addArrangedSubview(imageView)
        contentView.snp.makeConstraints { make in
            make.height.equalTo(75)
        }
        imageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.height.equalTo(75)
            make.width.equalTo(70)
        }
        contentView.addSubview(contentLable)
        contentLable.textAlignment = .left
        contentLable.font = UIFont.boldSystemFont(ofSize: 15)
        contentLable.numberOfLines = 1
        contentLable.snp.makeConstraints { make in
            make.left.equalTo(85)
            make.top.equalTo(15)
            make.right.equalToSuperview().offset(-16)
        }
        contentView.addSubview(sizeLable)
        sizeLable.snp.makeConstraints { make in
            make.left.equalTo(85)
            make.top.equalTo(contentLable.snp.bottom).offset(10)
        }
        
        guard let dataAttach = model.attachment?.data(using: .utf8) else {
            return
        }
        do {
            let dict = try JSONSerialization.jsonObject(with: dataAttach, options: []) as! [String: Any]
            if let dictData = dict[CMData] as? NSDictionary, let senderId = dictData[CMEggSendId] as? String {
                let message = (dictData[CMEggMessage]  as? String) ?? ""
                if message != ""{
                    self.contentLable.text = message
                } else {
                    self.contentLable.text = "rw_red_packet_best_wishes".localized
                }
                let showLeft = senderId == (RLSDKManager.shared.loginParma?.imAccid ?? "")
                self.sizeLable.text = !showLeft ? "viewholder_redpacket_open".localized : "viewholder_redpacket_detail".localized
                
                contentView.addAction {
                    let attachment = IMEggAttachment()
                    attachment.eggId = dictData.jsonString(CMEggId)
                    attachment.senderId = dictData.jsonString(CMEggSendId)
                    attachment.tid = dictData.jsonString(CMEggOpenId)
                    attachment.message = dictData.jsonString(CMEggMessage)
                    if let uids = dictData.jsonArray(CMEggUIDs) {
                        attachment.uids = uids
                    }
                    MessageUtils.getAvatarIcon(sessionId: attachment.senderId, conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
                        self?.delegate?.didClickEgg(attachment: attachment, nickName: avatarInfo.nickname ?? "", avatarInfo: avatarInfo)
                    }
                }
            }
        } catch  {
            print("jsonerror = \(error.localizedDescription)")
        }
    }
    
    private func setRPSUI(model: PinnedDictModel){
        
        contentStackView.addArrangedSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(120)
        }
        guard let dataAttach = model.attachment?.data(using: .utf8) else {
            return
        }
        do {
            let dict = try JSONSerialization.jsonObject(with: dataAttach, options: []) as! [String: Any]
            if let dictData = dict[CMData] as? [String: Any], let value = dictData[CMValue] as? Int{
                
                imageView.image = rpsValueImage(value)
            }
        } catch  {
            print("jsonerror = \(error.localizedDescription)")
        }
    }
    
    private func setMeettingUI(model: PinnedDictModel){
        imageView.image = UIImage(named: "im_meeting")
        contentStackView.addArrangedSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.height.height.equalTo(160)
            make.centerX.equalToSuperview()
        }
        contentStackView.addArrangedSubview(contentLable)
        contentLable.textAlignment = .center
        contentLable.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
        }
        contentStackView.addArrangedSubview(sizeLable)
        sizeLable.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
        }
        
        contentStackView.addArrangedSubview(openBtn)
        openBtn.snp.makeConstraints { make in
            make.bottom.equalTo(-10)
            make.centerX.equalToSuperview()
            make.height.equalTo(34)
            make.width.equalTo(140)
        }
        
        openBtn.applyStyle(.custom(text: "text_join_meeting".localized, textColor: RLColor.main.white, backgroundColor: RLColor.main.red, cornerRadius: 5))
        let origImage = UIImage(named: "im_meeting_send")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        openBtn.setImage(tintedImage, for: .normal)
        openBtn.tintColor = RLColor.main.white
        openBtn.semanticContentAttribute = .forceRightToLeft
        contentStackView.alignment = .center
        openBtn.addTarget(self, action: #selector(openMeeting), for: .touchUpInside)
        guard let dataAttach = model.attachment?.data(using: .utf8) else {
            return
        }
        do {
            let dict = try JSONSerialization.jsonObject(with: dataAttach, options: []) as! [String: Any]
            if let dictData = dict[CMData] as? [String: Any], let subject = dictData[CMMeetingSubject] as? String, let meetingNum = dictData[CMMeetingNum] as? String{
                contentLable.text = "text_meeting_id".localized + meetingNum
                sizeLable.text = subject
                self.meetingNum = meetingNum
                self.meetingPw = (dictData[CMMeetingPassword] as? String)
            }
        } catch  {
            print("jsonerror = \(error.localizedDescription)")
        }
    }
    
    
    func generateThumnail(url : URL) -> UIImage? {
        let asset : AVAsset = AVAsset(url: url)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        var frameImg: UIImage?
        let time: CMTime = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
        do {
            let img: CGImage = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            frameImg = UIImage(cgImage: img)
        } catch  {
            
        }

        return frameImg
    }
    
    func rpsValueImage(_ value: Int) -> UIImage? {
        var image: UIImage?
        let rpsValue = CustomRPSValue(rawValue: value)
        switch rpsValue {
        case .Scissor:
            image = UIImage(named: "custom_msg_jan")
        case .Rock:
            image = UIImage(named: "custom_msg_ken")
        case .Paper:
            image = UIImage(named: "custom_msg_pon")
        default:
            break
        }
        return image
    }
    
    private func imageSize(_ w: CGFloat , h: CGFloat) -> CGSize {
        
        let attachmemtImageMaxWidth  = ScreenWidth - 80
        let attachmentImageMaxHeight = ScreenHeight * 0.7
    
        var size: CGSize = CGSizeMake(attachmemtImageMaxWidth, attachmemtImageMaxWidth)
        if (w > h) //宽图
        {
            size.height = h * attachmentImageMaxHeight / w
            size.width = attachmemtImageMaxWidth
            
        }
        else if(w < h)//高图
        {
            size.width = w * attachmemtImageMaxWidth / h
            size.height = attachmentImageMaxHeight
        }
        else//方图
        {
            size.width = attachmemtImageMaxWidth
            size.height = attachmemtImageMaxWidth
        }
        

        return size //UIImage.nim_size(withImageOriginSize: imageSize, minSize: minSize, maxSize: maxSize)
    }
}

