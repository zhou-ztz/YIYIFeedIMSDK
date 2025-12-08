//
//  SCCollectionView.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/3.
//

import UIKit

class RLCollectionView: UICollectionView {

    let placeholder = TGPlaceholder()

    func show(placeholderView type: PlaceholderViewType, theme: Theme = .white, margin: CGFloat = 0.0, height: CGFloat? = nil) {
        if placeholder.superview == nil {
            self.addSubview(placeholder)
            placeholder.snp.makeConstraints {
                $0.bottom.left.right.equalToSuperview()
                $0.top.equalToSuperview().offset(margin)
                $0.width.equalToSuperview()
                if let height = height {
                    $0.height.equalTo(height)
                } else {
                    $0.height.equalToSuperview()
                }
            }
        }
        
        placeholder.set(type)
        placeholder.theme = theme
        placeholder.onTapActionButton = { [weak self] in
            guard let self = self, self.mj_header != nil else { return }
            self.mj_header.beginRefreshing()
        }
    }
    
    /// 移除占位图
    func removePlaceholderViews() {
        placeholder.removeFromSuperview()
    }
    
    func setGreyBackgroundColor() {
        placeholder.customBackgroundColor = RLColor.inconspicuous.background
    }

}
