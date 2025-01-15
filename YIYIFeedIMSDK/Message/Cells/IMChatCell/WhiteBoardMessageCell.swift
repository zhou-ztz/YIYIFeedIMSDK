//
//  WhiteBoardMessageCell.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/11.
//

import UIKit

class WhiteBoardMessageCell: BaseMessageCell {

    lazy var whiteboardView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        bubbleImage.addSubview(whiteboardView)
        bubbleImage.addSubview(titleLabel)
        bubbleImage.addSubview(timeTickStackView)
        whiteboardView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.left.right.equalToSuperview().inset(4)
            make.height.equalTo(180)
            make.width.equalTo(180)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(whiteboardView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(4)
        }
      
        timeTickStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.right.equalToSuperview().inset(5)
            make.bottom.equalTo(-8)
        }
        whiteboardView.image = UIImage.set_image(named: "whiteboard_bg")
    }
    
    override func setData(model: TGMessageData) {
        super.setData(model: model)
        guard let message = model.nimMessageModel else { return }
        let showLeft = !message.isSelf
        if showLeft {
            titleLabel.text = "whiteboard_right".localized
        }else{
            titleLabel.text = "whiteboard_left".localized
        }
    }
    

}
