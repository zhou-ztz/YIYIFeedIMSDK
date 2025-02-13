//
//  TGAlertContentView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/2/7.
//

import UIKit
import SnapKit

class TGAlertContentView: UIView {

    private(set) var title: String
    private(set) var desc: String
    private let contentView = UIStackView().configure {
        $0.spacing = 8
        $0.axis = .vertical
        $0.distribution = .fill
        $0.alignment = .fill
    }
    
    private let titleLabel = UILabel().configure { label in
        label.wordWrapped().setFontSize(with: 14.0, weight: .bold)
        label.textColor = .white
    }
    private let contentLabel = UILabel().configure { label in
        label.wordWrapped().setFontSize(with: 12.0, weight: .norm)
        label.textColor = .white
    }
    
    init(for title: String, desc: String, background: UIColor = .black) {
        self.title = title
        self.desc = desc
        
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        addSubview(contentView)
        
        if title.isEmpty == false {
            titleLabel.text = title
            contentView.addArrangedSubview(titleLabel)
        }
        
        if desc.isEmpty == false {
            contentLabel.text = desc
            contentView.addArrangedSubview(contentLabel)
        }
        
        contentView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview().inset(16)
        })
        
        DispatchQueue.main.async { [weak self] in
            self?.layoutIfNeeded()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
