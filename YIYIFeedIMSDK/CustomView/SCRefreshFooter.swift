//
//  SCRefreshFooter.swift
//  
//  上拉加载更多 footer

import UIKit
import SnapKit
import MJRefresh

class SCRefreshFooter: MJRefreshAutoFooter {
    
    lazy var detailInfoLabel: UILabel = {
        let lab = UILabel()
        lab.text = "加载更多"
        lab.textColor = UIColor(hex: 0xb3b3b3)
        lab.font = UIFont.systemFont(ofSize: 12)
        return lab
    }()
    
    var indicator = UIActivityIndicatorView()
    
    override var state: MJRefreshState {
        didSet {
            switch state {
            case .noMoreData:
                detailInfoLabel.textAlignment = .center
                detailInfoLabel.text = "没有更多数据"
                indicator.isHidden = true
                indicator.stopAnimating()
                layoutIfNeeded()
            case .idle:
                detailInfoLabel.textAlignment = .center
                detailInfoLabel.text = "上拉加载"
                indicator.isHidden = true
                indicator.stopAnimating()
                layoutIfNeeded()
            default:
                indicator.isHidden = false
                indicator.startAnimating()
                detailInfoLabel.textAlignment = .right
                detailInfoLabel.text = "加载更多"
                layoutIfNeeded()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonSetup()
    }
    
    private func commonSetup() {
        
        let stackview = UIStackView(arrangedSubviews: [indicator, detailInfoLabel])
        stackview.axis = .horizontal
        stackview.alignment = .fill
        stackview.distribution = .fill
        stackview.spacing = 3
  
        self.addSubview(stackview)
        indicator.startAnimating()
        
        let noticeLabelTap = UITapGestureRecognizer(target: self, action: #selector(footerDidTap))
        addGestureRecognizer(noticeLabelTap)
        
        stackview.snp.makeConstraints { c in
            c.center.equalToSuperview()
            //c.left.top.greaterThanOrEqualToSuperview().inset(10)
        }
        
        self.layoutIfNeeded()
    }
    
    @objc func footerDidTap() {
        beginRefreshing()
    }
}

extension MJRefreshFooter {
    /// 网络异常
    func endRefreshingWithWeakNetwork() {
        endRefreshing()
    }
}
