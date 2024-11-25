//
//  ChatMoreActionView.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/9.
//

import UIKit
import NIMSDK

/// 屏幕间隔
public let kScreenInterval: CGFloat = 20
public let NEMoreView_Section_Padding: CGFloat = 24.0

// 更多操作view
public let NEMoreCell_ReuseId: String = "InputMoreCell"
public let NEMoreCell_Image_Size: CGSize = .init(width: 56.0, height: 56.0)
public let NEMoreCell_Title_Height: CGFloat = 20.0
public let NEMoreView_Margin: CGFloat = 16.0
public let NEMoreView_Column_Count: Int = 4

protocol ChatMoreViewDelegate: NSObjectProtocol {
    
  func moreViewDidSelectMoreCell(moreView: ChatMoreActionView, cell: InputMoreCell)
}
class ChatMoreActionView: UIView {
    
    private var sectionCount: Int = 1
    private var itemsInSection: Int = 4
    // 默认行数
    private var rowCount: Int = 1
    // 流水布局
    public var moreFlowLayout: UICollectionViewFlowLayout?
    
    private var data: [NEMoreItemModel]?
    
    private var itemIndexs: [IndexPath: NSNumber]?
    
    public weak var delegate: ChatMoreViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collcetionView)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configData(data: [NEMoreItemModel]) {
        self.data = data
        rowCount = (data.count > NEMoreView_Column_Count) ? 2 : 1
        itemsInSection = NEMoreView_Column_Count * rowCount
        sectionCount = Int(ceil(Double(data.count) / Double(itemsInSection)))
        
        itemIndexs = [IndexPath: NSNumber]()
        
        for curSection in 0 ..< sectionCount {
            for itemIndex in 0 ..< itemsInSection {
                let row = itemIndex % rowCount
                let column = itemIndex / rowCount
                let reIndex = NEMoreView_Column_Count * row + column + curSection * itemsInSection
                itemIndexs?[IndexPath(row: itemIndex, section: curSection)] = NSNumber(value: reIndex)
            }
        }
        collcetionView.reloadData()
        setupConstraints()
    }
    
    func setupConstraints() {
        let cellSize = CGSize(width: 56, height: 80)
        let collectionHeight = cellSize.height * CGFloat(rowCount) + NEMoreView_Margin * CGFloat(rowCount - 1)
        
        // 设置collectionview frame
        collcetionView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: collectionHeight)
        if rowCount > 1 {
            // 设置行间距
            moreFlowLayout?.minimumInteritemSpacing = (collcetionView.bounds.height - cellSize.height * CGFloat(rowCount)) / CGFloat(rowCount - 1)
        }
        
        let margin = NEMoreView_Section_Padding
        let spacing = (collcetionView.bounds.width - cellSize.width * CGFloat(NEMoreView_Column_Count) - 2 * margin) / CGFloat(NEMoreView_Column_Count - 1)
        moreFlowLayout?.minimumLineSpacing = spacing
        moreFlowLayout?.sectionInset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
        
    }
    
    // MARK: 懒加载方法
    
    lazy var collcetionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        //        layout.itemSize = CGSize(width: 56, height: 80)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: NEMoreView_Margin, bottom: 0, right: NEMoreView_Margin)
        self.moreFlowLayout = layout
        let collcetionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collcetionView.backgroundColor = UIColor.clear
        collcetionView.dataSource = self
        collcetionView.delegate = self
        collcetionView.isUserInteractionEnabled = true
        collcetionView.isPagingEnabled = true
        collcetionView.showsHorizontalScrollIndicator = false
        collcetionView.showsVerticalScrollIndicator = false
        collcetionView.alwaysBounceHorizontal = true
        collcetionView.register(
            InputMoreCell.self,
            forCellWithReuseIdentifier: NEMoreCell_ReuseId
        )
        return collcetionView
    }()
}

extension ChatMoreActionView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionCount
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        itemsInSection
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NEMoreCell_ReuseId,
            for: indexPath
        ) as? InputMoreCell
        
        var itemModel: NEMoreItemModel?
        
        guard let index = itemIndexs?[indexPath] else {
            return UICollectionViewCell()
        }
        
        guard let cellData = data else {
            return UICollectionViewCell()
        }
        
        if index.intValue >= cellData.count {
            itemModel = nil
        } else {
            itemModel = cellData[index.intValue]
        }
        cell?.config(itemModel ?? NEMoreItemModel())
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = (collectionView.cellForItem(at: indexPath) as? InputMoreCell) {
            delegate?.moreViewDidSelectMoreCell(moreView: self, cell: cell)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 56, height: 80)
    }
}
enum NEMoreActionType: Int {
    case takePicture = 1
    case location
    case file
    case rtc
}

class NEMoreItemModel: NSObject {
    // 单元图标
    var image: UIImage?
    
    // 单元名称
    var title: String?
    
    // 对应的单元类型
    var type: NEMoreActionType?
    
    init(image: UIImage? = nil, title: String? = nil, type: NEMoreActionType? = nil) {
        self.image = image
        self.title = title
        self.type = type
    }
    
}

