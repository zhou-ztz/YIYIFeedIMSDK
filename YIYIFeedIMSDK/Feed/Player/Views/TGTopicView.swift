//
//  TGTopicView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/23.
//

import UIKit

class TGTopicListView: UIView {
    
    private lazy var stackview: UIStackView = {
        let stackview = UIStackView().configure {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.spacing = 10
            $0.alignment = .leading
        }
        return stackview
    }()
    
    init() {
        super.init(frame: .zero)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        self.backgroundColor = .clear
        addSubview(stackview)
        stackview.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
    }
    
    func setTopics(_ topics: [TopicListModel]) {
        stackview.removeAllArrangedSubviews()
        
        topics.forEach { (topic) in
            let view = TGTopicView(title: topic.topicTitle)
            // By Kit Foong (Add gesture for topic)
            view.addTap { [weak self] (_) in
                //                guard let self = self, let feedListCell = self.parentFeedListCell, let feedListCellDelegate = self.feedListCellDelegate else { return }
                //                feedListCellDelegate.feedCellDidClickTopic?(feedListCell, topicId: topic.topicId)
//                let topicVC = TopicPostListVC(groupId: topic.topicId)
//                if #available(iOS 11, *) {
//                    self?.getParentViewController()?.navigation(navigateType: .pushView(viewController: topicVC))
//                } else {
//                    let nav = TSNavigationController(rootViewController: topicVC).fullScreenRepresentation
//                    self?.getParentViewController()?.navigation(navigateType: .presentView(viewController: nav))
//                }
            }
            stackview.addArrangedSubview(view)
        }
        
        self.layoutIfNeeded()
    }

}

class TGTopicView: UIView {
    
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.applyStyle(.regular(size: 12, color: RLColor.main.theme))
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        
        self.backgroundColor = RLColor.main.theme.withAlphaComponent(0.2)
        self.roundCorner(3)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(5)
            $0.top.bottom.equalToSuperview().inset(2)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
