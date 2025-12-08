//
//  StickersViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//  Credit https://github.com/AhmedElassuty/IOS-BottomSheet


import UIKit
import SDWebImage

@objcMembers class StickersViewController: UIViewController, UIGestureRecognizerDelegate {

    var headerView: UIView!
    var holdView: UIView!
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    
    var collectionView: UICollectionView!
    var emojisCollectionView: UICollectionView!
    
    var emojisDelegate: EmojisCollectionViewDelegate!
    
    var stickers: [Any] = []
    weak var stickersViewControllerDelegate: StickersViewControllerDelegate?
    
    let screenSize = UIScreen.main.bounds.size
    let fullView: CGFloat = 100 // Top position when fully expanded
    var partialView: CGFloat {
        return UIScreen.main.bounds.height - 380 // Position when partially shown
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configureCollectionViews()
        
        scrollView.contentSize = CGSize(width: 2.0 * screenSize.width, height: scrollView.frame.size.height)
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        
        pageControl.numberOfPages = 2
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    func setupViews() {
        // Background Blur
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(blurView)
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        // Header View
        headerView = UIView()
        view.addSubview(headerView)
        headerView.backgroundColor = UIColor.clear
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        // Hold View
        holdView = UIView()
        headerView.addSubview(holdView)
        holdView.backgroundColor = UIColor.lightGray
        holdView.layer.cornerRadius = 3
        holdView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(5)
        }
        
        // Page Control
        pageControl = UIPageControl()
        headerView.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(holdView.snp.bottom).offset(8)
        }
        
        // Scroll View
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.clipsToBounds = true
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configureCollectionViews() {
        // Stickers Collection View
        let stickerLayout = UICollectionViewFlowLayout()
        stickerLayout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        stickerLayout.itemSize = CGSize(width: (screenSize.width - 30) / 3.0, height: 100)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: stickerLayout)
        collectionView.backgroundColor = .clear
        scrollView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.equalTo(screenSize.width)
            make.height.equalToSuperview()
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(StickerCollectionViewCell.self, forCellWithReuseIdentifier: "StickerCollectionViewCell")
        
        // Emojis Collection View
        let emojiLayout = UICollectionViewFlowLayout()
        emojiLayout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        emojiLayout.itemSize = CGSize(width: 70, height: 70)
        
        emojisCollectionView = UICollectionView(frame: .zero, collectionViewLayout: emojiLayout)
        emojisCollectionView.backgroundColor = .clear
        scrollView.addSubview(emojisCollectionView)
        
        emojisCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(collectionView.snp.trailing)
            make.width.equalTo(screenSize.width)
            make.height.equalToSuperview()
        }
        
        emojisDelegate = EmojisCollectionViewDelegate()
        emojisDelegate.stickersViewControllerDelegate = stickersViewControllerDelegate
        emojisCollectionView.delegate = emojisDelegate
        emojisCollectionView.dataSource = emojisDelegate
        
        emojisCollectionView.register(
            UINib(nibName: "EmojiCollectionViewCell", bundle: Bundle(for: EmojiCollectionViewCell.self)),
            forCellWithReuseIdentifier: "EmojiCollectionViewCell"
        )
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        let velocity = recognizer.velocity(in: view)
        let y = view.frame.minY
        
        if y + translation.y >= fullView {
            view.frame = CGRect(
                x: 0,
                y: y + translation.y,
                width: view.frame.width,
                height: UIScreen.main.bounds.height - (y + translation.y)
            )
            recognizer.setTranslation(.zero, in: view)
        }
        
        if recognizer.state == .ended {
            let duration = velocity.y < 0
                ? Double((y - fullView) / -velocity.y)
                : Double((partialView - y) / velocity.y)
            
            UIView.animate(withDuration: min(duration, 1.0), delay: 0, options: .allowUserInteraction) {
                if velocity.y >= 0 {
                    self.view.frame.origin.y = self.partialView
                } else {
                    self.view.frame.origin.y = self.fullView
                }
            }
        }
    }
}

// MARK: - UIScrollViewDelegate
extension StickersViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        let pageFraction = scrollView.contentOffset.x / pageWidth
        pageControl.currentPage = Int(round(pageFraction))
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension StickersViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerCollectionViewCell", for: indexPath) as! StickerCollectionViewCell
        if let stickerURL = stickers[indexPath.item] as? String {
            cell.stickerImage.sd_setImage(with: URL(string: stickerURL), completed: nil)
        } else if let sticker = stickers[indexPath.item] as? UIImage {
            cell.stickerImage.image = sticker
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let stickerURL = stickers[indexPath.item] as? String {
            stickersViewControllerDelegate?.didSelectImage(url: stickerURL)
        } else if let sticker = stickers[indexPath.item] as? UIImage {
            stickersViewControllerDelegate?.didSelectImage(image: sticker)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
