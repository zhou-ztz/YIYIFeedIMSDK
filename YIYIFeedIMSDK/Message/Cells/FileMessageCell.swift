//
//  FileMessageCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/10.
//

import UIKit
import NIMSDK

class FileMessageCell: BaseMessageCell {
    
    var fileImageView = UIImageView()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = RLColor.share.black3
        label.text = "name"
        label.numberOfLines = 1
        return label
    }()
    
    var sizeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = RLColor.share.lightGray
        label.text = "大小"
        label.numberOfLines = 1
        return label
    }()
    
    let bgView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonUI() {
        fileImageView.contentMode = .scaleAspectFill
        self.bubbleImage.addSubview(bgView)
        bgView.bindToEdges()
        bgView.addSubview(fileImageView)
        bgView.addSubview(contentLabel)
        bgView.addSubview(sizeLabel)
        fileImageView.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.left.top.bottom.equalToSuperview().inset(10)
        }
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(fileImageView.snp.right).offset(16)
            make.top.right.equalToSuperview().inset(10)
            make.width.equalTo(140)
        }
        sizeLabel.snp.makeConstraints { make in
            make.left.equalTo(fileImageView.snp.right).offset(16)
            make.bottom.equalTo(-10)
        }
    }
    
    override func setData(model: RLMessageData) {
        super.setData(model: model)
        guard let message = model.nimMessageModel, let fileObject = message.messageObject as? NIMFileObject else { return }
        contentLabel.text = fileObject.displayName
        sizeLabel.text = fileObject.fileLength.fileSizeString()
        let icon = SendFileManager.fileIcon(with: URL(string: fileObject.path ?? "")?.pathExtension ?? "")
        fileImageView.image = icon.icon
    }

}
