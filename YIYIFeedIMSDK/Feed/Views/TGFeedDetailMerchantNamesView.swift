//
//  TGFeedDetailMerchantNamesView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/20.
//

import UIKit

class TGFeedDetailMerchantNamesView: UIView {

    var list: [TGRewardsLinkMerchantUserModel] = []
    
    var momentMerchantDidClick: ((_ merchantData: TGRewardsLinkMerchantUserModel) -> Void)?
    
    private let merchantNamesListView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 5
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(merchantNamesListView)
        merchantNamesListView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setData(merchantList: [TGRewardsLinkMerchantUserModel]) {
        
        merchantNamesListView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        self.list = merchantList
        
        for merchant in merchantList {
            let merchantView = TGFeedMerchantNamesListView()
            merchantView.setData(merchant: merchant)
            merchantView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(merchantTapped(_:)))
            merchantView.addGestureRecognizer(tap)
            merchantNamesListView.addArrangedSubview(merchantView)
        }
    }
    
    @objc private func merchantTapped(_ sender: UITapGestureRecognizer) {
        if let merchantView = sender.view as? TGFeedMerchantNamesListView,
           let index = merchantNamesListView.arrangedSubviews.firstIndex(of: merchantView) {
            let merchant = list[index]
            momentMerchantDidClick?(merchant)
        }
    }

}
