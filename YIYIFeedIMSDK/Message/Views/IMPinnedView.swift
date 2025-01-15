//
//  IMPinnedView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/13.
//

import UIKit
import NIMSDK
import AVFoundation

protocol IMPinnedViewDelegate: AnyObject {
    func deletePinItem(pinItem: PinnedMessageModel)
}

class IMPinnedView: UIView {
    weak var delegate: IMPinnedViewDelegate?
    
    //var message: NIMMessage
    var pinItem: PinnedMessageModel
    
    lazy var title: UILabel = {
        let lab = UILabel()
        lab.text = "im_pinned_message".localized
        lab.font = UIFont.boldSystemFont(ofSize: 14)
        lab.textColor = TGAppTheme.primaryColor
        return lab
    }()
    lazy var content: UILabel = {
        let lab = UILabel()
        //lab.text = "I want to eat Happy Meal!"
        lab.font = UIFont.systemRegularFont(ofSize: 14)
        lab.textColor = UIColor(hexString: "#808080")
        return lab
    }()
    
    lazy var leftView: UIView = {
        let view = UIView()
        view.backgroundColor = TGAppTheme.primaryColor
        return view
    }()
    
    lazy var deleteBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ic_close_line"), for: .normal)
        return btn
    }()
    
    lazy var baseView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.clipsToBounds = true
        //imageview.backgroundColor = .lightGray
        return imageview
    }()
    
    var avatarImageView: TGAvatarView = TGAvatarView()
    
    lazy var stakView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 0
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .leading
        return stack
    }()
    lazy var allStakView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 8
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.alignment = .leading
        return stack
    }()
    
    init(pinItem: PinnedMessageModel) {
        self.pinItem = pinItem
        super.init(frame: .zero)
        backgroundColor = UIColor(hex: "#F5F5F5", alpha: 1)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        layer.shadowColor = UIColor(hex: "#000000", alpha: 0.1).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 1
        layer.shadowRadius = 5.0
        addSubview(self.leftView)
        addSubview(self.allStakView)
        addSubview(self.deleteBtn)
        deleteBtn.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        deleteBtn.addTarget(self, action: #selector(deleteItem), for: .touchUpInside)
        leftView.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(0)
            make.width.equalTo(4)
        }
        
        allStakView.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
            make.left.equalTo(self.leftView.snp.right).offset(12)
            make.right.equalTo(-44)
        }
        allStakView.addArrangedSubview(baseView)
        //allStakView.addArrangedSubview(avatarImageView)
        allStakView.addArrangedSubview(stakView)
        
        baseView.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(0)
            // make.centerY.equalToSuperview()
        }
        baseView.addSubview(avatarImageView)
        baseView.addSubview(imageView)
        
        avatarImageView.snp.makeConstraints { make in
            make.height.width.equalTo(34)
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(34)
            make.left.right.equalToSuperview()
        }
        stakView.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
            //            make.left.equalTo(self.leftView.snp_right).offset(16)
            //            make.right.equalTo(-44)
        }
        stakView.addArrangedSubview(self.title)
        stakView.addArrangedSubview(self.content)
        title.snp.makeConstraints { make in
            make.top.equalTo(3)
            make.height.equalTo(21)
            make.left.equalTo(0)
        }
        content.snp.makeConstraints { make in
            make.left.equalTo(0)
            //make.bottom.equalTo(-3)
            make.height.equalTo(21)
        }
    }
    
    func setData(pinItem: PinnedMessageModel) {
        self.pinItem = pinItem
        avatarImageView.isHidden = true
        imageView.isHidden = false
        baseView.isHidden = false
        baseView.snp.remakeConstraints { make in
            make.left.top.bottom.equalTo(0)
            make.width.height.equalTo(34)
        }
        imageView.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(34)
            make.left.right.equalToSuperview()
        }
        
        pinnedMessageForModel(model: pinItem)
    }
    
    @objc func deleteItem() {
        self.delegate?.deletePinItem(pinItem: pinItem)
    }
    
    func pinnedMessageForModel(model: PinnedMessageModel) {
        guard let contentStr = model.content, let data = contentStr.data(using: .utf8) else {
            return
        }
        var dictModel: PinnedDictModel?
        
        do {
            let model = try JSONDecoder().decode(PinnedDictModel.self, from: data)
            dictModel = model
        } catch {
           
        }
        
        guard let objectModel = dictModel  else {
            return
        }
        
        switch (MessageCollectionType(rawValue: objectModel.type ?? 0) ?? MessageCollectionType.text) {
        case .text:
            baseView.isHidden = true
            content.text = objectModel.content
            break
        case .image:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return
            }
            do {
                let attach = try JSONDecoder().decode(IMImageCollectionAttachment.self, from: dataAttach)
                baseView.isHidden = false
                imageView.sd_setImage(with: URL(string: attach.url), placeholderImage: attach.path == nil ? UIImage(named: "IMG_icon") : UIImage(contentsOfFile: attach.path ?? ""))
                content.text = "recent_msg_desc_picture".localized
                
            } catch {
               
            }
            break
        case .audio:
            baseView.isHidden = true
            content.text = "recent_msg_desc_audio".localized
            break
        case .video:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return
            }
            do {
                let attach = try JSONDecoder().decode(IMVideoCollectionAttachment.self, from: dataAttach)
                baseView.isHidden = false
                if let coverUrl = attach.coverUrl {
                    imageView.sd_setImage(with: URL(string: coverUrl), placeholderImage:  UIImage(named: "IMG_icon"))
                } else {
                    if let url =  URL(string: attach.url) {
                        let coverImage = self.generateThumnail(url: url)
                        imageView.image = coverImage
                    }
                }
                content.text = "recent_msg_desc_video".localized
            } catch {
               
            }
            break
        case .location:
            baseView.isHidden = true
            content.text = "recent_msg_desc_location".localized
            break
        case .file:
            baseView.isHidden = true
            content.text = "recent_msg_desc_file".localized
            break
        case .nameCard:
            baseView.isHidden = false
            imageView.isHidden = true
            avatarImageView.isHidden = false
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return
            }
            do {
                let attach = try JSONSerialization.jsonObject(with: dataAttach, options: []) as! [String: Any]
                if let data = attach[CMData] as? [String: Any], let memberId = data[CMContactCard] as? String {
                    MessageUtils.getAvatarIcon(sessionId: memberId, conversationType: .CONVERSATION_TYPE_P2P) {[weak self] avatarInfo in
                        self?.avatarImageView.avatarInfo = avatarInfo
                        self?.content.text = avatarInfo.nickname
                    }
                } else {
                    return
                }
            } catch {
                
            }
            break
        case .sticker:
            break
        case .link:
            break
        case .miniProgram:
            break
        case .meeting:
            baseView.isHidden = false
            imageView.image = UIImage(named: "ic_meeting_video")
            content.text = "recent_msg_desc_meeting".localized
            imageView.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.width.equalTo(56)
                make.height.equalTo(37)
                make.left.right.equalToSuperview()
            }
            baseView.snp.remakeConstraints { make in
                make.left.top.bottom.equalTo(0)
                make.width.equalTo(56)
            }
        case .egg:
            baseView.isHidden = true
            content.text = "recent_msg_desc_redpacket".localized
            
        case .rps:
            baseView.isHidden = true
            content.text = "recent_msg_desc_guess".localized
        default:
            break
        }
    }
    
    private func generateThumnail(url : URL) -> UIImage? {
        let asset : AVAsset = AVAsset(url: url)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        var frameImg: UIImage?
        let time: CMTime = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
        do {
            let img: CGImage = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            frameImg = UIImage(cgImage: img)
        } catch {
            
        }
        
        return frameImg
    }
}
