//
//  TGToolbarView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2024/12/24.
//

import UIKit

/// 工具栏代理事件
protocol TGToolbarViewDelegate: AnyObject {
    /// item 被点击
    func toolbar(_ toolbar: TGToolbarView, DidSelectedItemAt index: Int)
}

class TGToolbarView: UIView, TGToolBarButtonItemDelegate{

    /// 代理
    weak var delegate: TGToolbarViewDelegate? = nil
    private let tagNumberForItem = 200
    private var contentView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 0
        return stack
    }()
    
    /// item 数据模型
    var itemModels: [TGToolbarItemModel]? = nil
    
    var paddingContentView: UIView = UIView()
    
    init() {
        super.init(frame: .zero)
    }
    
    init(items: [TGToolbarItemModel]) {
        super.init(frame: .zero)
        self.itemModels = items
        setUI()
    }
    
    func set(items: [TGToolbarItemModel]) {
        self.itemModels = items
        self.frame = .zero
        setUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // 设置视图
    func setUI() {
        self.backgroundColor = UIColor.clear
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        for (_, model) in itemModels!.enumerated() {
            let item = TGToolBarButtonItem(model: model)
            item.delegate = self
            item.tag = tagNumberForItem + model.index
            contentView.addArrangedSubview(item)
        }
     
        paddingContentView.backgroundColor = .clear
        paddingContentView.isHidden = true
        contentView.addArrangedSubview(paddingContentView)
    }
    /// 通过 index 获取 item
    func getItemAt(_ index: Int) -> TGToolBarButtonItem {
        return (self.viewWithTag(index + tagNumberForItem) as? TGToolBarButtonItem)!
    }
    
    public func setTitleColor(_ newColor: UIColor, At index: Int) {
        let item = getItemAt(index)
        item.setTitleTextColor(newColor)
    }
    
    public func set(isUserInteractionEnabled enable: Bool, at index: Int) {
        let item = getItemAt(index)
        item.isUserInteractionEnabled = enable
    }
    public func setTitle(_ newTitle: String, At index: Int) {
        let item = getItemAt(index)
        let model = itemModels?[index]
        model?.title = newTitle
        itemModels?[index] = model!
        item.setItemWithNewModel(model!)
    }
    public func setImage(_ newImage: [String], At index: Int) {
        let item = getItemAt(index)
        let model = itemModels?[index]
        model?.image = newImage
        itemModels?[index] = model!
        item.setItemWithNewModel(model!)
    }
    public func item(isHidden: Bool, at index: Int) {
        let item = getItemAt(index)
        item.isHidden = isHidden
        self.paddingContentView.isHidden  = !isHidden
    }
    
    func toolbarDidSelectedItemAt(index: Int) {
        if let delegate = delegate {
            delegate.toolbar(self, DidSelectedItemAt: index)
        }
    }

}


class TGToolbarItemModel: NSObject {

    /// 图像
    var image: [String]? = nil
    /// 标题
    var title: String? = nil
    
    var titleShouldHide = false
    
    var index: Int = -1
    
    // MARK: - Lifecycle
    private override init() {
        super.init()
    }

    
    /// 自定义初始化方法
    /// - Parameters:
    ///   - imageValue: 图片名称
    ///   - titleValue: 标题
    ///   - titleShouldHide: 是否需要隐藏
    init(image imageValue: [String]?, title titleValue: String?, index indexValue: Int, titleShouldHide: Bool = false) {
        super.init()
        image = imageValue
        title = titleValue
        index = indexValue
        self.titleShouldHide = titleShouldHide
    }

}

