//
//  IMActionListView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/10.
//

import UIKit

@objc protocol ActionListDelegate: AnyObject {
    @objc optional
    func copyTextIM()
    @objc optional
    func copyImageIM()
    @objc optional
    func forwardTextIM()
    @objc optional
    func revokeTextIM()
    @objc optional
    func deleteTextIM()
    @objc optional
    func translateTextIM()
    @objc optional
    func replyTextIM()
    @objc optional
    func handleStickerIM()
    @objc optional
    func cancelUploadIM()
    @objc optional
    func stickerCollectionIM()
    @objc optional
    func voiceToTextIM()
    @objc optional
    func messageCollectionIM()
    @objc optional
    func saveMsgCollectionIM()
    @objc optional
    func forwardAllImageIM()
    @objc optional
    func deleteAllImageIM()
    @objc optional
    func pinMessageIM()
    @objc optional
    func unPinMessageIM()
}

enum ActionEnum: Int {
    case IM_COPY = 0,
    IM_COPY_IMAGE = 1,
    IM_DELETE = 2,
    IM_FORWARD = 3,
    IM_REVOKE = 4,
    IM_REVOKE_AND_EDIT = 5,
    IM_REPLY = 6,
    IM_TRANSLATE = 7,
    IM_STICKER_COLLECTION = 8,
    IM_VOICE_TO_TEXT = 9,
    IM_CANCEL_UPLOAD = 10,
    IM_FORWARD_ALL = 11,
    IM_REVOKE_ALL = 12,
    IM_PIN = 13,
    IM_UNPIN = 14,
    IM_COLLECT_COPY = 15,
    IM_COLLECT_DELETE = 16,
    IM_COLLECT_FORWARD = 17
}


class IMActionListView: UIView {

    weak var delegate: ActionListDelegate?
    /// 点击取消的回调
    var dismissAction: (() -> Void)?
    /// 按钮间距
    let buttonSpace: CGFloat = 45.0
    /// 按钮尺寸
    let buttonSize: CGSize = CGSize(width: 33.0, height: 60)
    /// 按钮 tag
    let tagForShareButton = 200
    /// 按钮背景滚动视图
    var scrollow = UIScrollView()
    /// 分享按钮组
    var shareViewArray = [UIView]()
    /// 分享链接
    var shareUrlString: String? = nil
    /// 分享图片
    var shareImage: UIImage? = nil
    /// 分享描述
    var shareDescription: String? = nil
    /// 分享标题
    var shareTitle: String? = nil
    /// 是自己的还是他人的
    var isMine = false
    // 是否是管理员
    var isManager = false
    // 是否是圈主
    var isOwner = false
    // 是否是精华
    var isExcellent = false
    // 是否是置顶
    var isTop = false
    // 是否置顶
    var isCollect = false
    var isCommentDisabled = false
    var cancleButton = UIButton(type: .custom)
    var oneLineheight: CGFloat = 117.0
    var twoLineheight: CGFloat = 333.0 / 2.0
         
    /// Powerful array ever
    var itemArray: [IMActionItem] = []
    
    init(actionArray: [Int]) {
        super.init(frame: UIScreen.main.bounds)
        for action in actionArray {
            switch action {
            case Int(ActionEnum.IM_CANCEL_UPLOAD.rawValue):
                itemArray.insert(.cancelUpload, at: 0)
            case Int(ActionEnum.IM_COPY.rawValue):
                itemArray.append(.copy)
            case Int(ActionEnum.IM_COPY_IMAGE.rawValue):
                itemArray.append(.copyImage)
            case Int(ActionEnum.IM_DELETE.rawValue):
                itemArray.append(.delete)
            case Int(ActionEnum.IM_FORWARD.rawValue):
                itemArray.append(.forward)
            case Int(ActionEnum.IM_REVOKE_AND_EDIT.rawValue):
                itemArray.append(.edit)
            case Int(ActionEnum.IM_REPLY.rawValue):
                itemArray.append(.reply)
            case Int(ActionEnum.IM_TRANSLATE.rawValue):
                itemArray.append(.translate)
            case Int(ActionEnum.IM_STICKER_COLLECTION.rawValue):
                itemArray.append(.stickerCollection)
            case Int(ActionEnum.IM_VOICE_TO_TEXT.rawValue):
                itemArray.append(.voiceToText)
            case Int(ActionEnum.IM_FORWARD_ALL.rawValue):
                itemArray.append(.stickerCollection)
            case Int(ActionEnum.IM_REVOKE_ALL.rawValue):
                itemArray.append(.voiceToText)
            case Int(ActionEnum.IM_PIN.rawValue):
                itemArray.append(.pinned)
            case Int(ActionEnum.IM_UNPIN.rawValue):
                itemArray.append(.pinned)
            case Int(ActionEnum.IM_COLLECT_COPY.rawValue):
                itemArray.append(.collect_copy)
            case Int(ActionEnum.IM_COLLECT_DELETE.rawValue):
                itemArray.append(.collect_delete)
            case Int(ActionEnum.IM_COLLECT_FORWARD.rawValue):
                itemArray.append(.collect_forward)
            default:
                break
            }
        }
        
        setUI()
        show()
    }
    
    init(actions: [IMActionItem]) {
        super.init(frame: UIScreen.main.bounds)
        itemArray = actions
        setUI()
        show()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame = UIScreen.main.bounds
    }

    // MARK: - Custom user interface
    func setUI() {
        
        backgroundColor = UIColor(white: 0, alpha: 0.2)
        
        let topOffset = 40 + TSBottomSafeAreaHeight
        
        //scroll view
        scrollow.backgroundColor = UIColor(hex: 0xf6f6f6)
        addSubview(scrollow)
        scrollow.translatesAutoresizingMaskIntoConstraints = false
        scrollow.snp.makeConstraints({ (make) in
            make.leading.trailing.bottom.equalTo(self)
            make.height.equalTo(115 + topOffset)
        })
        
        //stack view
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.distribution = .fill
        scrollow.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.snp.makeConstraints({ (make) in
            make.trailing.top.bottom.equalTo(scrollow)
            make.left.equalTo(scrollow).offset(15)
            make.height.equalTo(scrollow)
        })
        
        
        for index in 0..<itemArray.count {
            //shareview content
            let shareView = UIView()
            shareView.backgroundColor = UIColor(hex: 0xf6f6f6)
            shareView.tag = tagForShareButton + index
            shareView.isUserInteractionEnabled = true
            
            let imageView = UIImageView(image: UIImage(named: itemArray[index].image))
            imageView.isUserInteractionEnabled = true
            shareView.addSubview(imageView)
            imageView.snp.makeConstraints({ (make) in
                make.top.equalTo(shareView.snp.top).offset(15)
                make.centerX.equalTo(shareView.snp.centerX)
                make.size.equalTo(CGSize(width: 50, height: 50))
            })
            
            let label = UILabel()
            label.text = itemArray[index].title
            label.textColor = RLColor.normal.content
            label.font = UIFont.systemFont(ofSize: RLFont.SubInfo.mini.rawValue)
            label.textAlignment = .center
            label.numberOfLines = 0
            shareView.addSubview(label)
            label.snp.makeConstraints({ (make) in
                make.top.equalTo(imageView.snp.bottom).offset(12)
                make.width.equalTo(60)
                make.centerX.equalTo(imageView.snp.centerX)

            })
            
            stackView.addArrangedSubview(shareView)
            shareView.translatesAutoresizingMaskIntoConstraints = false
            shareView.snp.makeConstraints({ (make) in
                make.width.equalTo(70)
            })
            shareView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonTaped(_:))))
        }

        // gesture
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        cancleButton.backgroundColor = UIColor.white
        cancleButton.setTitle("cancel".localized, for: .normal)
        cancleButton.setTitleColor(UIColor(hex: 0x333333), for: .normal)
        cancleButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        addSubview(cancleButton)
        cancleButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
            $0.bottom.equalTo(-TSBottomSafeAreaHeight)
        }
        cancleButton.addTarget(self, action: #selector(cancelBtnClick), for: UIControl.Event.touchUpInside)
        let view = UIView()
        view.backgroundColor = .white
        addSubview(view)
        view.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(TSBottomSafeAreaHeight)
        }
    }

    // MARK: - Button click
    @objc internal func buttonTaped(_ sender: UIGestureRecognizer) {
        let view = sender.view
        let index = view!.tag - 200
        let finishBlock = setFinishBlock()
        let shareName = itemArray[index]
        
        switch shareName {
        case .stickerCollection:
            delegate?.stickerCollectionIM?()
        case .cancelUpload:
            delegate?.cancelUploadIM?()
        case .reply:
            delegate?.replyTextIM?()
        case .copy, .collect_copy:
            delegate?.copyTextIM?()
        case .copyImage:
            delegate?.copyImageIM?()
        case .forward, .collect_forward:
            delegate?.forwardTextIM?()
        case .edit:
            delegate?.revokeTextIM?()
        case .delete, .collect_delete:
            delegate?.deleteTextIM?()
        case .translate:
            delegate?.translateTextIM?()
        case .voiceToText:
            delegate?.voiceToTextIM?()
        case .collection:
            delegate?.messageCollectionIM?()
        case .save:
            delegate?.saveMsgCollectionIM?()
        case .forwardAll:
            delegate?.forwardAllImageIM?()
        case .deleteAll:
            delegate?.deleteAllImageIM?()
        case .pinned:
            delegate?.pinMessageIM?()
        case .unPinned:
            delegate?.unPinMessageIM?()
        default:
            break
        }
            
        dismiss()
    }
    
    @objc func cancelBtnClick() {
        dismiss()
        dismissAction?()
    }

    func setFinishBlock() -> ((Bool) -> Void) {
        func finishBlock(success: Bool) -> Void {
            if success {
            }
        }
        return finishBlock
    }

    public func show() {

        if self.superview != nil {
            return
        }
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        window.addSubview(self)
    }

   @objc public func dismiss() {
        if self.superview == nil {
            return
        }
        self.removeFromSuperview()
        dismissAction?()
    }

}
