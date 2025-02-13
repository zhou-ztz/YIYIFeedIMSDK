//
//  TGToolBarButtonItem.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2024/12/24.
//

import UIKit

/// 工具栏 item 代理事件
protocol TGToolBarButtonItemDelegate: AnyObject {
    /// item 被点击
    func toolbarDidSelectedItemAt(index: Int)
}

class TGToolBarButtonItem: UIView {

    /// item 数据模型
    private var model: TGToolbarItemModel? = nil

    /// 图标
    let imageView = UIImageView()
    /// 标题
    let titleLabel = UILabel()
    /// 代理
    weak var delegate: TGToolBarButtonItemDelegate? = nil
    /// 字体颜色
    var titleColor = UIColor.black
    
    init(model: TGToolbarItemModel) {
        super.init(frame: .zero)
        self.model = model
        self.setUI()
    }
    // 视图相关
    func setUI() {
        self.backgroundColor = UIColor.clear
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        
        titleLabel.textColor = RLColor.share.black
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(24.0)
            make.left.equalTo(5.0)
            make.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(3)
            make.right.equalToSuperview().inset(3)
            make.centerY.equalToSuperview()
        }
        
        updateChildView()
     
        self.addAction { [weak self] in
            self?.buttonTaped()
        }
    }
    
    // 刷新 item 的布局
    func updateChildView() {
  
        // 设置 imageView 的图片
         if let imageName = model?.image {
             imageView.image = UIImage.set_image(named: imageName)
         }

         // 设置 titleLabel 的文本
         if let title = model?.title {
             titleLabel.text = title
         }

        titleLabel.isHidden = model?.titleShouldHide ?? true
        titleLabel.textColor = titleColor
    }
    
    // MARK: - Public
    public func setTitleTextColor(_ color: UIColor) {
        titleColor = color
        titleLabel.textColor = color
    }

    public func setItemWithNewModel(_ newModel: TGToolbarItemModel) {
        model = newModel
        updateChildView()
    }

    // MARK: - Button click
    // button 的点击事件
    @objc func buttonTaped() {
        if let delegate = delegate {
            delegate.toolbarDidSelectedItemAt(index: (model?.index)!)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
