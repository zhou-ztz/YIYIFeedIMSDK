//
//  StickerCollectionViewCell.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

@objcMembers class StickerCollectionViewCell: UICollectionViewCell {
    // MARK: - Subviews
    var stickerImage: UIImageView!

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: - Setup Views
    private func setupViews() {
        // Initialize stickerImage
        stickerImage = UIImageView()
        stickerImage.contentMode = .scaleAspectFit
        stickerImage.clipsToBounds = true
        
        // Add to contentView
        contentView.addSubview(stickerImage)
        
        // Use SnapKit for layout
        stickerImage.snp.makeConstraints { make in
            make.edges.equalToSuperview() // Pin to all edges of contentView
        }
        
        // Optional: Set background color if needed
        contentView.backgroundColor = .clear
    }
}
