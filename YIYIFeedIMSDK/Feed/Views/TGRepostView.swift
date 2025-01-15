//
//  TGRepostView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/7.
//

import UIKit

enum TGRepostViewType {
    /// 发布页面
    case postView
    /// 列表或者详情页
    case listView
}
struct TGRepostViewUX {
    /// 发布页面中
    static let postUINormalTitleFont: CGFloat = 14
    static let postUINormalContentFont: CGFloat = 12
    static let postUINewsTitleFont: CGFloat = 14
    static let postUINewsContentFont: CGFloat = 12
    // 视图的高度
    static let postUIPostWordCardHeight: CGFloat = 85
    static let postUIPostVideoCardHeight: CGFloat = 100
    static let postUIPostImageCardHeight: CGFloat = 70
    static let postUIGroupCardHeight: CGFloat = 72
    static let postUIGroupPostCardHeight: CGFloat = 85
    static let postUINewsCardHeight: CGFloat = 88
    static let postUIQuestionCardHeight: CGFloat = 88
    static let postUIQuestionAnswerCardHeight: CGFloat = 77

    /// 列表以及详情页
    static let listUINormalTitleFont: CGFloat = 14
    static let listUINormalContentFont: CGFloat = 12
    static let listUINewsTitleFont: CGFloat = 15
    static let listUINewsContentFont: CGFloat = 15
    static let listUIPostWordCardHeight: CGFloat = 100
    static let listUIPostVideoCardHeight: CGFloat = 100
    static let listUIPostStickerCardHeight: CGFloat = 100
    static let listUIPostURLCardHeight: CGFloat = 100
    static let listUIPostUserCardHeight: CGFloat = 100
    static let listUIPostImageCardHeight: CGFloat = 100
    static let listUIPostDefaultCardHeight: CGFloat = 100
    static let listUIGroupCardHeight: CGFloat = 80
    static let listUIGroupPostImageHeight: CGFloat = 220
    static let listUINewsCardHeight: CGFloat = 100
    static let listUIQuestionCardHeight: CGFloat = 75
    static let listUIQuestionAnswerCardHeight: CGFloat = 75
    static let listUIDeleteCardHeight: CGFloat = 40
    static let listUISharedCardHeight: CGFloat = 45
}

class TGRepostView: UIView {
    var cancelImageButton: UIButton!
    /// 卡片显示的位置类型
    var cardShowType: TGRepostViewType = .listView
    /// 图片
    var coverImageView: UIImageView!
    /// 特殊标示,比如视频
    var iconImageView: UIImageView!
    /// 标题,第一行文字就是标题，如果只有一行，那么它就是内容
    var titleLab: UILabel!
    /// 内容label
    /// 不要在外部赋值，允许访问该label的目的是允许处理Handel
    var contentLab: ActiveLabel!
    /// 点击了分享卡片
    var postDetailLab: ActiveLabel!
    
    var liveIcon = UILabel().configure {
        $0.backgroundColor = UIColor(red: 230, green: 35, blue: 35)
//        $0.textInsets = UIEdgeInsets(top: 1, left: 2, bottom: 1, right: 2)
        $0.textColor = .white
        $0.roundCorner(2)
        $0.setFontSize(with: 10, weight: .bold)
        $0.text = "text_live".localized
        $0.isHidden = true
    }
    
    var didTapCardBlock: (() -> Void)?
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        creatUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func getSuperViewHeight(model: TGRepostModel, superviewWidth: CGFloat) -> CGFloat {
        var superViewHeight: CGFloat = 0
        if self.cardShowType == .listView {
            switch model.type {
            case .postWord:
                superViewHeight = TGRepostViewUX.listUIPostWordCardHeight
            case .postImage:
                superViewHeight = TGRepostViewUX.listUIPostImageCardHeight
            case .postVideo, .postLive, .postMiniVideo:
                superViewHeight = TGRepostViewUX.listUIPostVideoCardHeight
            case .postSticker:
                superViewHeight = TGRepostViewUX.listUIPostStickerCardHeight
            case .postURL:
                superViewHeight = TGRepostViewUX.listUIPostURLCardHeight
            case .postUser:
                superViewHeight = TGRepostViewUX.listUIPostUserCardHeight
            case .postMiniProgram:
                superViewHeight = TGRepostViewUX.listUIPostDefaultCardHeight
            case .news:
                superViewHeight = TGRepostViewUX.listUINewsCardHeight
            case .question:
                superViewHeight = TGRepostViewUX.listUIQuestionCardHeight
            case .questionAnswer:
                superViewHeight = TGRepostViewUX.listUIQuestionAnswerCardHeight
            case .delete:
                superViewHeight = TGRepostViewUX.listUIDeleteCardHeight
            }
        }
        return superViewHeight
    }

    func creatUI() {
        /// 现在内容label和卡片点击冲突，暂保留卡片点击
        let control = UIControl(frame: self.bounds)
        addSubview(control)
        control.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.top.equalToSuperview()
        }
        let tapReg = UITapGestureRecognizer(target: self, action: #selector(didTapCard))
        control.addGestureRecognizer(tapReg)
        backgroundColor = RLColor.small.repostBackground
        coverImageView = UIImageView()
        coverImageView.backgroundColor = UIColor.white
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        self.addSubview(coverImageView)
        iconImageView = UIImageView()
        self.addSubview(iconImageView)
        self.addSubview(liveIcon)
        titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.listUINormalTitleFont)
        titleLab.textColor = RLColor.main.content
        titleLab.lineBreakMode = .byTruncatingTail
        titleLab.numberOfLines = 2
        self.addSubview(titleLab)
        contentLab = ActiveLabel()
        contentLab.mentionColor = RLColor.main.theme
        contentLab.URLColor = RLColor.normal.minor
        contentLab.URLSelectedColor = RLColor.normal.minor
        contentLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.listUINormalContentFont)
        contentLab.textColor = RLColor.normal.minor
        contentLab.lineSpacing = 2
        contentLab.lineBreakMode = NSLineBreakMode.byTruncatingTail
//        contentLab.textAlignment = .left
        self.addSubview(contentLab)
        postDetailLab = ActiveLabel()
        postDetailLab.mentionColor = RLColor.main.theme
        postDetailLab.URLColor = RLColor.normal.minor
        postDetailLab.URLSelectedColor = RLColor.normal.minor
        postDetailLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.listUINormalContentFont)
        postDetailLab.textColor = RLColor.normal.minor
        postDetailLab.lineSpacing = 2
        postDetailLab.lineBreakMode = NSLineBreakMode.byTruncatingTail
//        postDetailLab.textAlignment = .left
        self.addSubview(postDetailLab)
        postDetailLab.isHidden = true
        self.layer.cornerRadius = 4
//        self.layer.borderColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0).cgColor
//        self.layer.borderWidth = 1
        cancelImageButton = UIButton()
        cancelImageButton.setImage(UIImage(named: "cancel"), for: .normal)
        cancelImageButton.addTap(action: { [weak self] (_) in
            guard let self = self else { return }
            self.removeFromSuperview()
        })
        self.addSubview(cancelImageButton)
        cancelImageButton.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).inset(5.8)
            $0.right.equalTo(self.snp.right).inset(5.8)
            $0.width.height.equalTo(15)
        }
        cancelImageButton.isHidden = true
    }
    
    func updateUI(model: TGRepostModel, shouldShowCancelButton: Bool = false) {
        backgroundColor = RLColor.small.repostBackground
        if cardShowType == .postView {
            self.isUserInteractionEnabled = false
            contentLab.enabledTypes = []
        } else {
            self.isUserInteractionEnabled = true
        }
        
        switch model.type {
        case .delete:
            self.updataDeleteContentUI(model: model)
            
        case .questionAnswer:
            self.updateQuestionAnswerUI(model: model)
            
        case .question:
            self.updateQuestionUI(model: model)

        case .postURL:
            self.updatePostSharedUI(model: model, shouldShowCancelButton: shouldShowCancelButton)
            if shouldShowCancelButton {
                self.isUserInteractionEnabled = true
            }

        default:
            self.updatePostSharedUI(model: model)
        }
    }
    
    func updateUI(model: SharedViewModel, shouldShowCancelButton: Bool = false) {
        self.updatePostSharedUI(model: model,shouldShowCancelButton:shouldShowCancelButton)
    }
    
    // MARK: - 已经删除
    private func updataDeleteContentUI(model: TGRepostModel) {
        self.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(TGRepostViewUX.listUIDeleteCardHeight)
        }
        titleLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.listUINormalTitleFont)
        coverImageView.isHidden = true
        iconImageView.isHidden = true
        titleLab.isHidden = false
        contentLab.isHidden = true
        postDetailLab.isHidden = true
        titleLab.numberOfLines = 1
        titleLab.text = "review_dynamic_deleted".localized
        titleLab.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview().offset(11)
            make.trailing.equalToSuperview().offset(-11)
            make.centerY.equalTo((superview?.snp.centerY)!)
        }
    }
    // MARK: - 动态
    private func updatePostTextUI(model: TGRepostModel, shouldShowCancelButton: Bool = false) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TGRepostViewUX.postUIPostWordCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalContentFont)
            coverImageView.isHidden = true
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(18)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(5)
                /// 设计图只需要30pt，但是这个富文本控件显示两行需要38
                /// 所以需要把整个控件上间距也调小4pt 使整个控件竖直居中
                make.height.equalTo(38)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(TGRepostViewUX.listUIPostWordCardHeight)
            }
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(5)
                /// 设计图只需要30pt，但是这个富文本控件显示两行需要38
                /// 所以需要把整个控件上间距也调小4pt 使整个控件竖直居中
                make.height.equalTo(44)
            }
            contentLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.listUINormalContentFont)
            contentLab.textColor = RLColor.normal.minor
            coverImageView.isHidden = true
            iconImageView.isHidden = true
            titleLab.isHidden = true
            contentLab.isHidden = false
            contentLab.numberOfLines = 2
            var showStr = model.title! + "："
            if let content = model.content {
                showStr = showStr + content
            } else {
                showStr = showStr + " "
            }
            // 设置名字是黑色
            contentLab.text = showStr
            contentLab.attributedText = showStr.attributonString().setTextFont(TGRepostViewUX.listUINormalContentFont).setlineSpacing(0)

            // 计算 frame
            let contentWidth = UIScreen.main.bounds.width - 58 - 13
            var contentLabelframe = CGRect(origin: .zero, size: CGSize(width: contentWidth, height: 0))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
            paragraphStyle.paragraphSpacing = 3
            paragraphStyle.alignment = .left
            paragraphStyle.headIndent = 0.000_1
            paragraphStyle.tailIndent = -0.000_1
            var labelHeight: CGFloat = 0
            let heightLine = self.heightOfLines(line: 6, font: UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalContentFont))
            let maxHeight = self.heightOfAttributeString(contentWidth: contentWidth, attributeString: contentLab.attributedText!, font: UIFont.systemFont(ofSize: TGRepostViewUX.listUINormalContentFont), paragraphstyle: paragraphStyle)
            if heightLine >= maxHeight {
                labelHeight = maxHeight
            } else {
                labelHeight = heightLine
            }
            contentLabelframe = CGRect(x: 58, y: 0, width: contentWidth, height: labelHeight)

            let attribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: TGRepostViewUX.listUINormalContentFont)]
            let arr: NSArray = NSArray(array: LabelLineText.getSeparatedLines(from: contentLab.attributedText ?? NSAttributedString(string: ""), frame: contentLabelframe, attribute: attribute))
            let rangeArr: NSArray = NSArray(array: LabelLineText.getSeparatedLinesRange(from: contentLab.attributedText ?? NSAttributedString(string: ""), frame: contentLabelframe, attribute: attribute))
            var sixLineText: NSString = ""
            var sixRange: NSRange?
            let sixReplaceRange: NSRange?
            var replaceLocation: NSInteger = 0
            let replaceText: String = "sticker_see_all".localized
            let replaceAtttribute: NSMutableAttributedString = NSMutableAttributedString(string: replaceText)
            let replacefirstAtttribute: NSMutableAttributedString = NSMutableAttributedString(string: "...")
            replaceAtttribute.addAttributes(attribute, range: NSRange(location: 0, length: replaceAtttribute.length))
            if arr.count > 2 {
                sixLineText = NSString(string: "\(arr[1] )")
                let modelSix: RangeModel = rangeArr[1] as! RangeModel
                for (index, _) in rangeArr.enumerated() {
                    if index > 0 {
                        break
                    }
                    let model: RangeModel = rangeArr[index] as! RangeModel
                    replaceLocation = replaceLocation + model.locations
                }

                // 计算出最合适的 range 范围来放置 "阅读全文  " ，让 UI 看起来就是刚好拼接在第六行最后面
                sixReplaceRange = NSRange(location: replaceLocation + modelSix.locations - replaceText.count, length: replaceText.count)
                sixRange = NSRange(location: replaceLocation, length: modelSix.locations)
                let mutableReplace: NSMutableAttributedString = NSMutableAttributedString(attributedString: (contentLab.attributedText?.attributedSubstring(from: sixRange!))!)

                /// 这里要处理 第六行是换行的空白 或者 第六行未填满就换行 的情况
                var lastRange: NSRange?
                if modelSix.locations == 1 {
                    /// 换行直接追加
                    lastRange = NSRange(location: 0, length: replaceLocation + modelSix.locations - 1)
                } else {
                    /// 如果第六行最后一个字符是 \n 换行符的话，需要将换行符扔掉，再 追加 “查看更多”字样
                    let mutablepassLastString: NSMutableAttributedString = NSMutableAttributedString(attributedString: mutableReplace.attributedSubstring(from: NSRange(location: modelSix.locations - 1, length: 1)))
                    var originI: Int = 0
                    if mutablepassLastString.string == "\n" {
                        originI = 1
                    }
                    for i in originI..<modelSix.locations - 1 {
                        /// 获取每一次替换后的属性文本
                        let mutablepass: NSMutableAttributedString = NSMutableAttributedString(attributedString: mutableReplace.attributedSubstring(from: NSRange(location: 0, length: modelSix.locations - i)))
                        mutablepass.append(replaceAtttribute)
                        let mutablePassWidth = self.WidthOfAttributeString(contentHeight: 20, attributeString: mutablepass, font: UIFont.systemFont(ofSize: TGRepostViewUX.listUINormalContentFont))
                        /// 判断当前系统是不是 11.0 及以后的 是就不处理，11.0 以前要再细判断(有没有空格，有的情况下再判断宽度对比小的话要多留两个汉字距离来追加 阅读全文 字样)
                        if #available(iOS 11.0, *) {
                            if mutablePassWidth <= contentWidth * 2 / 3 {
                                lastRange = NSRange(location: 0, length: replaceLocation + modelSix.locations - i)
                                break
                            }
                        } else {
                            if mutablePassWidth <= contentWidth * 2 / 3 {
                                let mutableAll: NSMutableAttributedString = NSMutableAttributedString(attributedString: (contentLab.attributedText?.attributedSubstring(from: NSRange(location: 0, length: replaceLocation + modelSix.locations - i)))!)
                                if mutableAll.string.contains(" ") {
                                    if mutablePassWidth <= (contentWidth * 2 / 3 - contentLab.font.pointSize * 2.0) {
                                        lastRange = NSRange(location: 0, length: replaceLocation + modelSix.locations - i)
                                        break
                                    }
                                } else {
                                    lastRange = NSRange(location: 0, length: replaceLocation + modelSix.locations - i)
                                    break
                                }
                            }
                        }
                    }
                }
                if lastRange == nil {
                    lastRange = NSRange(location: 0, length: replaceLocation)
                }

                let mutable: NSMutableAttributedString = NSMutableAttributedString(attributedString: (contentLab.attributedText?.attributedSubstring(from: lastRange!))!)
                mutable.append(replacefirstAtttribute)
                mutable.append(replaceAtttribute)
                contentLab.attributedText = NSAttributedString(attributedString: mutable)
            }
        }
    }
    
    private func updatePostURLUI(model: TGRepostModel) {
        self.cancelImageButton.isHidden = false
        self.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(TGRepostViewUX.listUIPostURLCardHeight)
        }
        titleLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalContentFont)
        contentLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalContentFont)
        coverImageView.isHidden = false
        iconImageView.isHidden = true
        titleLab.isHidden = false
        contentLab.isHidden = false
        postDetailLab.isHidden = true
        titleLab.numberOfLines = 2
        contentLab.numberOfLines = 2
        titleLab.text = model.title
        if let thumbnailImage = model.coverImage, thumbnailImage != "" {
            coverImageView.sd_setImage(with: URL(string: thumbnailImage), placeholderImage: UIImage(named: "post_placeholder"))
        }
        else {
            coverImageView.image = UIImage(named: "post_placeholder")
        }
        if let urlString = model.content, let url = URL(string: urlString), let domain = url.host {
            contentLab.text = domain
        }
        contentLab.textColor = UIColor(red: 109, green: 114, blue: 120)
        
        contentLab.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(14)
            make.bottom.equalToSuperview().offset(-8)
        }
        titleLab.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(30)
            make.bottom.equalTo(contentLab.snp.top).offset(-5)
        }
        coverImageView.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(titleLab.snp.top).offset(-11)
        }
    }
    
    private func updatePostMediaUI(model: TGRepostModel) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TGRepostViewUX.postUIPostVideoCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalContentFont)
            coverImageView.isHidden = true
            iconImageView.isHidden = false
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(18)
                make.height.equalTo(18)
            }
            if model.type == .postVideo {
                iconImageView.image = UIImage(named: "ico_video_disabled")
                contentLab.text = "feed_click_video".localized
            } else  if model.type == .postImage {
                iconImageView.image = UIImage(named: "ico_pic_disabled")
                contentLab.text = "feed_click_picture".localized
            } else if model.type == .postLive {
                iconImageView.image = UIImage(named: "ico_pic_disabled")
                contentLab.text = "feed_click_live".localized
            } else if model.type == .postMiniVideo {
                iconImageView.image = UIImage(named: "ico_video_disabled")
                contentLab.text = "feed_click_mini_video".localized
            }

            iconImageView.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.top.equalTo(titleLab.snp.bottom).offset(10)
                make.width.equalTo(15)
                make.height.equalTo(12)
            }
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(iconImageView.snp.trailing).offset(6)
                make.trailing.equalToSuperview().offset(-11)
                make.height.equalTo(15)
                make.centerY.equalTo(iconImageView.snp.centerY)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(TGRepostViewUX.listUIPostVideoCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.listUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.listUINormalContentFont)
            contentLab.textColor = RLColor.main.theme
            titleLab.textColor = RLColor.main.content
            coverImageView.isHidden = true
            iconImageView.isHidden = false
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            let showTitle = model.title! + "："
            titleLab.text = showTitle
            let showTitleSize = showTitle.size(maxSize: CGSize(width: ScreenWidth, height: 20), font: titleLab.font!)
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(17)
                make.top.equalToSuperview().offset(12)
                make.height.equalTo(15)
                make.width.equalTo(showTitleSize.width + 2)
            }
            titleLab.sizeToFit()
            if model.type == .postVideo {
                iconImageView.image = UIImage(named: "ico_video_highlight")
                contentLab.text = "feed_click_video".localized
            } else  if model.type == .postImage {
                iconImageView.image = UIImage(named: "ico_pic_highlight")
                contentLab.text = "feed_click_picture".localized
            } else if model.type == .postLive {
                iconImageView.image = UIImage(named: "ico_pic_disabled")
                contentLab.text = "feed_click_live".localized
            } else if model.type == .postMiniVideo {
                iconImageView.image = UIImage(named: "ico_video_highlight")
                contentLab.text = "feed_click_mini_video".localized
            }
            
            iconImageView.snp.remakeConstraints { (make) in
                make.leading.equalTo(titleLab.snp.trailing).offset(2)
                make.centerY.equalTo(titleLab.snp.centerY)
                make.width.equalTo(15)
                make.height.equalTo(12)
            }
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(iconImageView.snp.trailing).offset(6)
                make.trailing.equalToSuperview().offset(-11)
                make.height.equalTo(15)
                make.centerY.equalTo(iconImageView.snp.centerY)
            }
        }
    }

    func heightOfLines(line: Int, font: UIFont) -> CGFloat {
        if line <= 0 {
            return 0
        }

        var mutStr = "*"
        for _ in 0..<line - 1 {
            mutStr = mutStr + "\n*"
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 3
        paragraphStyle.headIndent = 0.000_1
        paragraphStyle.tailIndent = -0.000_1
        let attribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalContentFont), NSAttributedString.Key.paragraphStyle: paragraphStyle.copy(), NSAttributedString.Key.strokeColor: UIColor.black]
        let tSize = mutStr.size(withAttributes: attribute)
        return tSize.height
    }

    func heightOfAttributeString(contentWidth: CGFloat, attributeString: NSAttributedString, font: UIFont, paragraphstyle: NSMutableParagraphStyle) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphstyle.copy()]
        let att: NSString = NSString(string: attributeString.string)
        let rectToFit1 = att.boundingRect(with: CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        if attributeString.length == 0 {
            return 0
        }
        return rectToFit1.size.height
    }

    // MARK: - 圈子
    private func updateGroupUI(model: TGRepostModel) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TGRepostViewUX.postUIGroupCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalContentFont)
            coverImageView.isHidden = false
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            if let coverImage = model.coverImage {
                coverImageView.sd_setImage(with: URL(string: coverImage), completed: nil)
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview().offset(11)
                    make.top.equalToSuperview().offset(11)
                    make.height.width.equalTo(50)
                }
            } else {
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview()
                    make.top.equalToSuperview()
                    make.height.width.equalTo(0)
                }
            }

            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(15)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(18)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(titleLab.snp.leading)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(4)
                make.height.equalTo(38)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(15)
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TGRepostViewUX.listUIGroupCardHeight)
            }
            self.superview?.backgroundColor = UIColor(hex: 0xF7F7F7)
            self.backgroundColor = UIColor(hex: 0xFFFFFF)
            titleLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.listUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.listUINormalContentFont)
            coverImageView.isHidden = false
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            if let coverImage = model.coverImage {
                coverImageView.sd_setImage(with: URL(string: coverImage), completed: nil)
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview().offset(11)
                    make.top.equalToSuperview().offset(11)
                    make.height.width.equalTo(50)
                }
            } else {
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview()
                    make.top.equalToSuperview()
                    make.height.width.equalTo(0)
                }
            }
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(15)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(18)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(titleLab.snp.leading)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(4)
                make.height.equalTo(38)
            }
        }
    }
    // MARK: - 帖子
    private func updateGroupPostUI(model: TGRepostModel) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TGRepostViewUX.postUIGroupPostCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalContentFont)
            coverImageView.isHidden = false
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            if let coverImage = model.coverImage {
                coverImageView.sd_setImage(with: URL(string: coverImage), completed: nil)
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview()
                    make.top.equalToSuperview()
                    make.bottom.equalToSuperview()
                    make.width.equalTo(TGRepostViewUX.postUIGroupPostCardHeight)
                }
            } else {
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview()
                    make.top.equalToSuperview()
                    make.height.width.equalTo(0)
                }
            }

            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(15)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(18)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(titleLab.snp.leading)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(9)
                make.height.equalTo(38)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            titleLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.listUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.listUINormalContentFont)
            coverImageView.isHidden = false
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
                make.top.equalToSuperview().offset(10)
                make.height.equalTo(18)
            }
            var contentHeight: CGFloat = 0
            if let content = model.content, content.count > 0 {
                contentLab.text = model.content
                contentHeight = content.size(maxSize: CGSize(width: (superview?.width)! - 16 * 2, height: 34), font: UIFont.systemFont(ofSize: TGRepostViewUX.listUINormalContentFont)).height
                contentHeight = contentHeight + 4
                contentLab.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview().offset(16)
                    make.trailing.equalToSuperview().offset(-16)
                    make.top.equalTo(titleLab.snp.bottom).offset(8)
                    make.height.equalTo(contentHeight)
                }
            } else {
                contentLab.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview()
                    make.trailing.equalToSuperview()
                    make.top.equalTo(titleLab.snp.bottom)
                    make.height.equalTo(contentHeight)
                }
            }

            if let coverImage = model.coverImage {
                coverImageView.sd_setImage(with: URL(string: coverImage), completed: nil)
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview().offset(23)
                    make.trailing.equalToSuperview().offset(-23)
                    make.top.equalTo(contentLab.snp.bottom).offset(8)
                    make.height.width.equalTo(TGRepostViewUX.listUIGroupPostImageHeight)
                }
            } else {
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview()
                    make.top.equalToSuperview()
                    make.height.width.equalTo(0)
                }
            }
        }
    }
    // MARK: - 资讯
    private func updateNewsUI(model: TGRepostModel) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TGRepostViewUX.postUINewsCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINewsTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINewsContentFont)

            coverImageView.isHidden = false
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 2
            contentLab.numberOfLines = 2

            if let coverImage = model.coverImage {
                coverImageView.sd_setImage(with: URL(string: coverImage), completed: nil)
                coverImageView.snp.remakeConstraints { (make) in
                    make.trailing.equalToSuperview().offset(-5)
                    make.top.equalToSuperview().offset(10)
                    make.bottom.equalToSuperview().offset(-10)
                    make.width.equalTo(95)
                }
            } else {
                coverImageView.snp.remakeConstraints { (make) in
                    make.trailing.equalToSuperview().offset(0)
                    make.height.width.equalTo(0)
                }
            }

            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(10)
                make.trailing.equalTo(coverImageView.snp.leading).offset(-23)
                make.top.equalToSuperview().offset(13)
                make.height.equalTo(35)
            }

            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(titleLab.snp.leading)
                make.trailing.equalTo(titleLab.snp.trailing)
                make.top.equalTo(titleLab.snp.bottom).offset(8)
                make.height.equalTo(15)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(TGRepostViewUX.listUINewsCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.listUINewsTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.listUINewsContentFont)
            titleLab.textColor = RLColor.main.content
            contentLab.textColor = RLColor.normal.minor
            coverImageView.isHidden = false
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 2
            contentLab.numberOfLines = 2
            if let coverImage = model.coverImage {
                coverImageView.sd_setImage(with: URL(string: coverImage), completed: nil)
                coverImageView.snp.remakeConstraints { (make) in
                    make.trailing.equalToSuperview().offset(-5)
                    make.top.equalToSuperview().offset(10)
                    make.bottom.equalToSuperview().offset(-10)
                    make.width.equalTo(95)
                }
            } else {
                coverImageView.snp.remakeConstraints { (make) in
                    make.trailing.equalToSuperview().offset(0)
                    make.height.width.equalTo(0)
                }
            }

            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(10)
                make.trailing.equalTo(coverImageView.snp.leading).offset(-23)
                make.top.equalToSuperview().offset(8)
                make.height.equalTo(40)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(titleLab.snp.leading)
                make.trailing.equalTo(titleLab.snp.trailing)
                make.top.equalTo(titleLab.snp.bottom).offset(8)
                make.height.equalTo(15)
            }
        }
    }
    // MARK: - 问题
    private func updateQuestionUI(model: TGRepostModel) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TGRepostViewUX.postUIQuestionCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalContentFont)
            coverImageView.isHidden = true
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 2
            contentLab.numberOfLines = 2
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(40)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(5)
                /// 设计图只需要30pt，但是这个富文本控件显示两行需要38
                /// 所以需要把整个控件上间距也调小4pt 使整个控件竖直居中
//                make.height.equalTo(18)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(TGRepostViewUX.listUIQuestionCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.listUINewsTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.listUINewsContentFont)
            titleLab.textColor = RLColor.main.content
            contentLab.textColor = RLColor.normal.minor
            coverImageView.isHidden = true
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 2
            contentLab.numberOfLines = 2
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(8)
                make.height.equalTo(36)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
                make.top.equalTo(titleLab.snp.bottom).offset(8)
                make.height.equalTo(18)
            }
        }
    }
    // MARK: - 回答
    private func updateQuestionAnswerUI(model: TGRepostModel) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TGRepostViewUX.postUIQuestionAnswerCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalContentFont)
            coverImageView.isHidden = true
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(8)
                make.height.equalTo(15)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(8)
                make.height.equalTo(40)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(TGRepostViewUX.postUIQuestionAnswerCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.listUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.listUINormalContentFont)
            titleLab.textColor = RLColor.main.content
            contentLab.textColor = RLColor.normal.minor
            coverImageView.isHidden = true
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(18)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(5)
                /// 设计图只需要30pt，但是这个富文本控件显示两行需要38
                /// 所以需要把整个控件上间距也调小4pt 使整个控件竖直居中
                make.height.equalTo(38)
            }
        }
    }
    /// 点击了卡片
    @objc func didTapCard() {
        if let tapBlock = didTapCardBlock {
            tapBlock()
        }
    }
    /// 这个地方需要处理从ActiveLabel穿透过来的点击事件，不然该事件会被tableview处理，导致cell被点击
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let tapBlock = didTapCardBlock {
            tapBlock()
        }
    }
    func WidthOfAttributeString(contentHeight: CGFloat, attributeString: NSAttributedString, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let att: NSString = NSString(string: attributeString.string)
        let rectToFit1 = att.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: contentHeight), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        if attributeString.length == 0 {
            return 0
        }
        return rectToFit1.size.width
    }
}


extension TGRepostView {
    
    func getSuperViewHeight() -> CGFloat {
        return TGRepostViewUX.postUIPostVideoCardHeight
    }
    
    func updatePostSharedUI(model: SharedViewModel, shouldShowCancelButton: Bool = false) {
        if shouldShowCancelButton {
            cancelImageButton.isHidden = false
        } else {
            cancelImageButton.isHidden = true
            self.bringSubviewToFront(cancelImageButton)
        }
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TGRepostViewUX.postUIPostVideoCardHeight)
            }
        } else {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(TGRepostViewUX.postUIPostVideoCardHeight)
            }
        }
        
        titleLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalTitleFont)
        contentLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalContentFont)
        coverImageView.isHidden = false
        coverImageView.roundCorner(2)
        iconImageView.isHidden = true
        titleLab.isHidden = false
        contentLab.isHidden = false
        postDetailLab.isHidden = false
        titleLab.numberOfLines = 1
        postDetailLab.numberOfLines = 2
        contentLab.numberOfLines = 1
        titleLab.text = model.title
//        if model.sharedType == SharedType.live.rawValue, let postExtra = model.extra, let postId = Int(postExtra) {
//            do {
//                titleLab.text = LiveStoreManager().fetchById(id: postId.uint64)?.hostName
//            } catch let err {
//                LogManager.Log(err, loggingType: .exception)
//            }
//        }
        postDetailLab.text = (model.desc?.removeNewLineChar() ?? "").isEmpty ? "" : model.desc?.removeNewLineChar()
        contentLab.textColor = RLColor.main.theme
        if model.type == .user {
            contentLab.text = "view_user".localized
        } else  if model.type == .sticker {
            contentLab.text = "sticker_view".localized
        } else if model.type == .live {
            contentLab.text = "feed_click_live".localized
        } else if model.type == .miniProgram {
            let mpIcon = NSTextAttachment()
            mpIcon.image = UIImage(named: "ic_miniProgram")
            mpIcon.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
            let space: NSAttributedString = NSAttributedString(string: " ")
            let fullString: NSMutableAttributedString = NSMutableAttributedString(attachment: mpIcon)
            fullString.append(space)
            let text: NSAttributedString = NSAttributedString(string: "view_mini_program".localized)
            fullString.append(text)
            contentLab.attributedText = fullString
        } else if model.type == .miniVideo {
            contentLab.text = "feed_click_mini_video".localized
        } else if model.type == .metadata {
            titleLab.numberOfLines = 2
            let urlString = model.url.orEmpty
            let url = URL(string: urlString)
            let domain = url?.host
            contentLab.text = domain
        }
        coverImageView.snp.remakeConstraints { (make) in
//            make.leading.equalToSuperview()
//            make.top.equalToSuperview()
//            make.bottom.equalToSuperview()
            make.top.left.bottom.equalToSuperview().inset(12)
            make.width.equalTo(coverImageView.snp.height)
            make.height.equalTo(coverImageView.snp.height)
        }
        coverImageView.layer.cornerRadius = 4
//        coverImageView.layer.borderColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0).cgColor
//        coverImageView.layer.borderWidth = 1
        if let thumbnail = model.thumbnail {
            coverImageView.sd_setImage(with: URL(string: thumbnail), placeholderImage: UIImage(named: "post_placeholder"))
        } else {
            coverImageView.image = UIImage(named: "post_placeholder")
        }

        if (postDetailLab.text ?? "").isEmpty {
            postDetailLab.isHidden = true
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.bottom.equalTo(contentLab.snp.top).offset(-5)
            }
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.height.equalTo(15)
                make.bottom.equalToSuperview().offset(-12)
            }
        } else {
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(18)
            }
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.height.equalTo(15)
                make.bottom.equalToSuperview().offset(-12)
            }
            postDetailLab.removeConstraints(postDetailLab.constraints)
            postDetailLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(2)
                make.height.equalTo(42)
            }
            setNeedsDisplay()
            layoutIfNeeded()
            postDetailLab.sizeToFit()
            postDetailLab.snp.updateConstraints {
                $0.height.equalTo(postDetailLab.frame.height)
            }
        }
    }
    
    func updatePostSharedUI(model: TGRepostModel, shouldShowCancelButton: Bool = false) {
        if shouldShowCancelButton {
            cancelImageButton.isHidden = false
        } else {
            cancelImageButton.isHidden = true
            self.bringSubviewToFront(cancelImageButton)
        }
        self.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(TGRepostViewUX.postUIPostVideoCardHeight)
        }
        
        titleLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalTitleFont)
        contentLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalContentFont)
        postDetailLab.font = UIFont.systemFont(ofSize: TGRepostViewUX.postUINormalContentFont)
        coverImageView.isHidden = false
        coverImageView.roundCorner(2)
        iconImageView.isHidden = true
        titleLab.isHidden = false
        contentLab.isHidden = false
        postDetailLab.isHidden = false
        titleLab.numberOfLines = 1
        postDetailLab.numberOfLines = 2
        contentLab.numberOfLines = 1
        titleLab.text = model.title
//        if model.type == .postLive {
//            if let originalLive = LiveStoreManager().fetchById(id: model.id.uint64), let name = originalLive.hostName {
//                titleLab.text = name
//            }
//        }

        if let contentString = model.content, let urlString = contentString.getUrlStringFromString() {
            postDetailLab.text = urlString
        }
        postDetailLab.text = (model.content?.removeNewLineChar() ?? "").isEmpty ? "feed_no_desc".localized : model.content?.removeNewLineChar()
        contentLab.textColor = RLColor.main.theme
        liveIcon.isHidden = true
        iconImageView.isHidden = true
        if model.type == .postVideo {
            iconImageView.isHidden = false
            iconImageView.image = UIImage(named: "ico_video_play_list")
            contentLab.text = "feed_click_video".localized
        } else  if model.type == .postImage {
            contentLab.text = "feed_click_picture".localized
        } else if model.type == .postLive {
            liveIcon.isHidden = true
            contentLab.text = "feed_click_live".localized
        } else if model.type == .postWord {
            contentLab.text = "feed_click_text".localized
        } else if model.type == .postUser {
            contentLab.text = "view_user".localized
        } else if model.type == .postSticker {
            contentLab.text = "feed_click_sticker".localized
        } else if model.type == .news {
            contentLab.text = "feed_click_article".localized
        } else if model.type == .postMiniVideo {
            contentLab.text = "feed_click_mini_video".localized
        } else if model.type == .postMiniProgram {
            let mpIcon = NSTextAttachment()
            mpIcon.image = UIImage(named: "ic_miniProgram")
            mpIcon.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
            let space: NSAttributedString = NSAttributedString(string: " ")
            let fullString: NSMutableAttributedString = NSMutableAttributedString(attachment: mpIcon)
            fullString.append(space)
            let text: NSAttributedString = NSAttributedString(string: "view_mini_program".localized)
            fullString.append(text)
            contentLab.attributedText = fullString
        } else if model.type == .postURL {
            titleLab.numberOfLines = 2
            if let urlString = model.content, let url = URL(string: urlString) {
                contentLab.text = url.host
                postDetailLab.text = nil
                contentLab.textColor = RLColor.normal.minor
            }
        }
        coverImageView.snp.remakeConstraints { (make) in
//            make.leading.equalToSuperview()
//            make.top.equalToSuperview()
//            make.bottom.equalToSuperview()
            make.top.left.bottom.equalToSuperview().inset(12)
            make.width.equalTo(coverImageView.snp.height)
            make.height.equalTo(coverImageView.snp.height)
        }
        coverImageView.layer.cornerRadius = 4
//        coverImageView.layer.borderColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0).cgColor
//        coverImageView.layer.borderWidth = 1
        if let thumbnailImage = model.coverImage, thumbnailImage != "" {
            coverImageView.sd_setImage(with: URL(string: thumbnailImage), placeholderImage: UIImage(named: "post_placeholder"))
        }
        else {
            coverImageView.image = UIImage(named: "post_placeholder")
        }
        
        if model.type == .postVideo {
            iconImageView.snp.remakeConstraints { (make) in
                make.height.equalTo(coverImageView.snp.height).multipliedBy(0.3)
                make.width.equalTo(coverImageView.snp.width).multipliedBy(0.3)
                make.centerX.equalTo(coverImageView.snp.centerX)
                make.centerY.equalTo(coverImageView.snp.centerY)
            }
        } else if model.type == .postLive {
            liveIcon.snp.remakeConstraints { (make) in
                make.top.equalTo(coverImageView.snp.top).offset(8)
                make.trailing.equalTo(coverImageView.snp.trailing).offset(-8)
            }
        }

        if (postDetailLab.text ?? "").isEmpty {
            postDetailLab.isHidden = true
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.bottom.equalTo(contentLab.snp.top).offset(-5)
            }
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.height.equalTo(15)
                make.bottom.equalToSuperview().offset(-12)
            }
        } else {
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(18)
            }
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.height.equalTo(15)
                make.bottom.equalToSuperview().offset(-12)
            }
            postDetailLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(2)
                make.height.equalTo(42)
            }
            setNeedsDisplay()
            layoutIfNeeded()
            postDetailLab.sizeToFit()
            postDetailLab.snp.updateConstraints {
                $0.height.equalTo(postDetailLab.frame.height)
            }
        }
    }
}
