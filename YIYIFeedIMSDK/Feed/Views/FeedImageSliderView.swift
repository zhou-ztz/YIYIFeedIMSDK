//
//  FeedImageSliderView.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/29.
//

import UIKit

class FeedImageSliderView: UIView {

    private var collectionView: UICollectionView!
    private var pageControl: UIPageControl!
    
    private var imageUrls: [String] = []
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    private func setupUI() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(FeedScrollChildImageCell.self, forCellWithReuseIdentifier: FeedScrollChildImageCell.identifier)
        addSubview(collectionView)
        
        
        pageControl = UIPageControl()
        pageControl.numberOfPages = 0
        pageControl.currentPage = 0
        pageControl.hidesForSinglePage = true
        addSubview(pageControl)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    func set(imageUrls: [String]) {
        self.imageUrls = imageUrls
        pageControl.numberOfPages = imageUrls.count
        collectionView.reloadData()
        
        // 打印collectionView.contentSize
        print("CollectionView ContentSize: \(collectionView.contentSize)")
    }

}

extension FeedImageSliderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedScrollChildImageCell.identifier, for: indexPath) as! FeedScrollChildImageCell
           let imageUrl = imageUrls[indexPath.item]
           cell.imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage.set_image(named: "rl_placeholder@2x"))
           
           return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        
        if currentPage >= 0 && currentPage < imageUrls.count {
            pageControl.currentPage = currentPage
            collectionView.layoutIfNeeded()
        }
    }
}

class FeedScrollChildImageCell: UICollectionViewCell {
    
    static let identifier = "FeedScrollChildImageCellIdentifier"
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

