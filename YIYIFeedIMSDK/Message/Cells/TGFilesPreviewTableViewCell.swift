//
//  TGFilesPreviewTableViewCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/20.
//

import UIKit
import NIMSDK

class TGFilesPreviewTableViewCell: UITableViewCell {
    
    var fileImageView = UIImageView()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .black
        label.text = ""
        label.numberOfLines = 1
        return label
    }()
    
    var sizeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = RLColor.share.lightGray
        label.numberOfLines = 1
        return label
    }()

    static let cellReuseIdentifier = "TGFilesPreviewTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.setUI()
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        fileImageView.contentMode = .scaleAspectFill
        
        self.addSubview(fileImageView)
        self.addSubview(contentLabel)
        self.addSubview(sizeLabel)
        fileImageView.snp.makeConstraints { make in
            make.height.width.equalTo(50)
            make.left.top.bottom.equalToSuperview().inset(15)
        }
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(fileImageView.snp.right).offset(8)
            make.top.equalToSuperview().inset(20)
            make.right.equalTo(-20)
        }
        sizeLabel.snp.makeConstraints { make in
            make.left.equalTo(fileImageView.snp.right).offset(8)
            make.top.equalTo(contentLabel.snp.bottom).offset(8)
            make.right.equalTo(-20)
        }
    }
    
    func setData(attachment: V2NIMMessageFileAttachment) {

        contentLabel.text = attachment.name
        sizeLabel.text = Int64(attachment.size).fileSizeString()
        let icon = RLSendFileManager.fileIcon(with: URL(string: attachment.path ?? "")?.pathExtension ?? "").icon
        fileImageView.image = icon
    }
}
