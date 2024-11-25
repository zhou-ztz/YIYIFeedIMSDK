//
//  MessageOperationView.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/17.
//

import UIKit

protocol MessageOperationViewDelegate: AnyObject {
    func didSelectedItem(item: OperationItem)
}

class MessageOperationView: UIView , UICollectionViewDataSource, UICollectionViewDelegate {
    var collcetionView: UICollectionView
    public weak var delegate: MessageOperationViewDelegate?
    public var items = [OperationItem]() {
        didSet {
            collcetionView.reloadData()
        }
    }
    var model: RLMessageData?
    
    init(frame: CGRect, model: RLMessageData?) {
        self.model = model
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 56)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        collcetionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collcetionView.backgroundColor = .white
        collcetionView.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowColor = RLColor.share.black3.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 8
        
        collcetionView.dataSource = self
        collcetionView.delegate = self
        collcetionView.isUserInteractionEnabled = true
        collcetionView.register(
            OperationCell.self,
            forCellWithReuseIdentifier: "\(OperationCell.self)"
        )
        addSubview(collcetionView)
        NSLayoutConstraint.activate([
            collcetionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            collcetionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            collcetionView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            collcetionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
        
        addSubview(collcetionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    MARK: UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "\(OperationCell.self)",
            for: indexPath
        ) as? OperationCell
        cell?.model = items[indexPath.row]
        
        return cell ?? UICollectionViewCell()
    }
    
    //    MARK: UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        removeFromSuperview()
        delegate?.didSelectedItem(item: items[indexPath.row])
    }
    
    
}
