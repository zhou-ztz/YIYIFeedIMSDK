//
//  CustomerStickerViewCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2024/12/24.
//

import UIKit
import SDWebImage
import Photos
import MobileCoreServices

protocol CustomerStickerViewCellDelegate: AnyObject {
    
    func selectItem(indexPath: IndexPath)
}
class CustomerStickerViewCell: UICollectionViewCell {
    
    lazy var bgImage: UIImageView = {
        let img = UIImageView()
        return img
    }()
    lazy var icon: UIImageView = {
        let img = UIImageView()
        return img
    }()
    lazy var selectBtn: UIButton = {
        let btn = UIButton()
        return btn
    }()
    var imageView = SDAnimatedImageView()
    var indexPath: IndexPath!
    weak var delegate: CustomerStickerViewCellDelegate?
    static let cellIdentifier = "CustomerStickerViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        self.contentView.addSubview(bgImage)
        self.contentView.addSubview(icon)
        self.contentView.addSubview(selectBtn)
        self.contentView.addSubview(imageView)
        
        bgImage.bindToEdges()
        icon.snp.makeConstraints { (make) in
            make.width.height.equalTo(22)
            make.center.equalToSuperview()
        }
        selectBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(18)
            make.right.top.equalToSuperview().inset(2)
        }
        self.backgroundColor = .white
        bgImage.contentMode = .scaleAspectFit
        icon.isHidden = true
        icon.image = UIImage.set_image(named: "add_sticker")?.withRenderingMode(.alwaysOriginal)
        imageView.contentMode = .scaleAspectFit
        bgImage.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(0)
        }
        bgImage.bringSubviewToFront(self.selectBtn)
        selectBtn.layer.cornerRadius = 18 / 2.0
        selectBtn.layer.masksToBounds = true

        selectBtn.setImage(UIImage.set_image(named: "ic_rl_checkbox_selected"), for: .selected)
        selectBtn.setImage(UIImage.set_image(named: "icon_accessory_normal"), for: .normal)
    }
    
    func setSticker(sticker: CustomerStickerItem, indexPath: IndexPath){
        self.indexPath = indexPath
       // self.bgImage.sd_setImage(with: URL(string: sticker.stickerUrl ?? ""), completed: nil)
        if let url = sticker.stickerUrl{
            imageView.sd_setImage(with: URL(string: url)!, completed: nil)
        }
  
    }
    
    func setData(asset: PHAsset, indexPath: IndexPath){
        // 判断是不是GIF
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = false
        manager.requestImageData(for: asset, options: option) { [weak self] (imageData, type, orientation, info) in
            guard let imageData = imageData else { return }
            DispatchQueue.main.async {
                if type == kUTTypeGIF as String {
                    self?.bgImage.image = UIImage.gif(data: imageData)
                } else {
                    self?.bgImage.image = UIImage(data: imageData)
                }
            }
        }
    }
}
