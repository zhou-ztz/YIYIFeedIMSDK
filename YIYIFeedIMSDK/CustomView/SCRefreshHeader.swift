//
//  SCRefreshHeader.swift
//
//  下拉刷新 header

import UIKit
import MJRefresh
import SnapKit

class SCRefreshHeader: MJRefreshHeader {
    
    lazy var detailInfoLabel: UILabel = {
        let lab = UILabel()
        lab.text = "下拉刷新"
        lab.textColor = UIColor(hex: 0xb3b3b3)
        lab.font = UIFont.systemFont(ofSize: 12)
        return lab
    }()
    var indicator = UIActivityIndicatorView()
    override var state: MJRefreshState {
        didSet {
            switch state {
            case .idle:
                detailInfoLabel.textAlignment = .center
                detailInfoLabel.text = "下拉刷新"
                indicator.isHidden = true
                indicator.stopAnimating()
                layoutIfNeeded()
                
            case .pulling:
                detailInfoLabel.textAlignment = .center
                detailInfoLabel.text = "正在加载"
                indicator.isHidden = false
                indicator.startAnimating()
                layoutIfNeeded()
                                
            case .refreshing:
                detailInfoLabel.textAlignment = .center
                detailInfoLabel.text = "正在加载"
                indicator.isHidden = false
                indicator.startAnimating()
                layoutIfNeeded()
                
            default:
                detailInfoLabel.textAlignment = .center
                detailInfoLabel.text = "刷新成功"
                indicator.isHidden = true
                indicator.stopAnimating()
                layoutIfNeeded()
            }
        }
    }
    
    override var pullingPercent: CGFloat {
        didSet {
        }
    }

    // MARK: - Custom user interface
    override func prepare() {
        super.prepare()
        
        let stackview = UIStackView(arrangedSubviews: [indicator, detailInfoLabel])
        stackview.axis = .horizontal
        stackview.alignment = .fill
        stackview.distribution = .fill
        stackview.spacing = 3
  
        self.addSubview(stackview)
        
        stackview.snp.makeConstraints { c in
            c.center.equalToSuperview()
            //c.left.top.greaterThanOrEqualToSuperview().inset(10)
        }
        
        self.backgroundColor = UIColor.clear
        
        self.layoutIfNeeded()
    }
    
    override func scrollViewPanStateDidChange(_ change: [AnyHashable : Any]!) {
        super.scrollViewPanStateDidChange(change)
    }
    
    override func scrollViewContentSizeDidChange(_ change: [AnyHashable : Any]!) {
        super.scrollViewContentSizeDidChange(change)
    }
    
    override func scrollViewContentOffsetDidChange(_ change: [AnyHashable : Any]!) {
        super.scrollViewContentOffsetDidChange(change)
    }
}
