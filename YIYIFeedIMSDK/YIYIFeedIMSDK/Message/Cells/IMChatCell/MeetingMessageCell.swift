//
//  MeetingMessageCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/7.
//

import UIKit

class MeetingMessageCell: BaseMessageCell {
    
    lazy var meetingView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var meetingLabel: UILabel = {
        let label = UILabel()
        label.font = TGAppTheme.Font.regular(TGFontSize.defaultTextFontSize)
        label.textColor = .black
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    
    lazy var joinBtn: UIButton = {
        let button = UIButton()
        button.setTitle("text_join_meeting".localized, for: .normal)
        button.setTitleColor(RLColor.main.white, for: .normal)
        button.backgroundColor = RLColor.main.red
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
       
        button.setImage(UIImage(named: "im_meeting_send")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = RLColor.main.white
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.lineBreakMode = .byWordWrapping
        //button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        button.semanticContentAttribute = .forceRightToLeft
        button.addTarget(self, action: #selector(meetingTapped), for: .touchUpInside)
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupUI(){
        
        bubbleImage.addSubview(meetingView)
        bubbleImage.addSubview(meetingLabel)
        bubbleImage.addSubview(joinBtn)
        bubbleImage.addSubview(timeTickStackView)
       
        meetingView.image = UIImage(named: "im_meeting")
        meetingView.snp.makeConstraints { make in
            make.height.width.equalTo(180)
            make.top.left.equalTo(8)
            make.right.equalTo(-8)
        }
        meetingLabel.numberOfLines = 2
        meetingLabel.snp.makeConstraints { make in
            make.top.equalTo(meetingView.snp.bottom).offset(10)
            make.right.left.equalToSuperview().inset(8)
        }
        
        joinBtn.snp.makeConstraints { make in
            make.width.equalTo(130)
            make.left.equalTo(8)
            make.height.equalTo(30)
            make.top.equalTo(meetingLabel.snp.bottom).offset(10)
        }
        
        timeTickStackView.snp.makeConstraints { make in
            make.top.equalTo(joinBtn.snp.bottom).offset(10)
            make.bottom.right.equalTo(-8)
        }
        
    }
    
    override func setData(model: TGMessageData) {
        super.setData(model: model)
        guard let _ = model.nimMessageModel, let attachment = model.customAttachment as? IMMeetingRoomAttachment else { return }
        let attrs1 = [NSAttributedString.Key.font: TGAppTheme.Font.bold(TGFontSize.defaultTextFontSize), NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 0, blue: 0)]
        let attrs2 = [NSAttributedString.Key.font: TGAppTheme.Font.regular(TGFontSize.defaultTextFontSize), NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 0, blue: 0)]
        
        let attributedString1 = NSMutableAttributedString(string:"\("text_meeting_id".localized) ", attributes:attrs1)

        let attributedString2 = NSMutableAttributedString(string:"\(attachment.meetingNum) \r\n\(attachment.meetingSubject)", attributes:attrs2)
        
        attributedString1.append(attributedString2)
        meetingLabel.attributedText = attributedString1
        
    }
    
    @objc func meetingTapped() {
        self.delegate?.meetingTapped(cell: self, model: self.contentModel)
    }
}
