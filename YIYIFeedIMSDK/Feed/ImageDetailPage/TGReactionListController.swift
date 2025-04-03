//
//  TGReactionListController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/20.
//

import UIKit
import Foundation

class TGReactionListController: UIViewController {

    private(set) var reactionType: ReactionTypes?
    
    private let table = RLTableView(frame: .zero, style: .plain).configure { v in
        v.separatorStyle = .none
    }
    private var theme: Theme = .white
    private var feedId: Int!
    private var apiPointer: String? = nil
    private var tableSource = [TGFeedReactionsModel.Data]()
    var index: Int = 0
    
    init(theme: Theme, reactionType: ReactionTypes?, feedId: Int, index: Int) {
        super.init(nibName: nil, bundle: nil)
        self.feedId = feedId
        self.theme = theme
        self.reactionType = reactionType
        self.index = index
        
        table.showsVerticalScrollIndicator = false
        table.register(TGReactionTableViewCell.self, forCellReuseIdentifier: TGReactionTableViewCell.cellIdentifier)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(table)
        table.bindToEdges()
        table.delegate = self
        table.dataSource = self
        
        table.mj_header = nil
        table.mj_footer = SCRefreshFooter(refreshingBlock: { [weak self] in
            self?.fetch()
        })
        
        fetch()

        switch theme {
        case .white:
            table.backgroundColor = .white
            view.backgroundColor = .white
        case .dark:
            table.backgroundColor = TGAppTheme.materialBlack
            view.backgroundColor = TGAppTheme.materialBlack
        }
    }
    
    private func fetch() {
        
        TGFeedNetworkManager.shared.getReactionList(id: feedId, reactionType: reactionType, after: apiPointer) { [weak self] (model, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                if let data = model?.data, data.count > 0 {
                    self.tableSource.append(contentsOf: data)
                    self.apiPointer = (data.last?.id).orZero.stringValue
                    
                    self.table.reloadData()
                    self.table.mj_footer.endRefreshing()
                    self.table.removePlaceholderViews()
                } else {
                    if self.tableSource.count == 0 {
                        self.table.show(placeholderView: .empty, theme: self.theme)
                    }
                    self.table.mj_footer.endRefreshingWithNoMoreData()
                }
            }
            
        }
    }
}

extension TGReactionListController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int { return 1 }

//    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return UIView(frame: CGRect(x: 0, y: 0, width: self.table.width, height: CGFloat.leastNonzeroMagnitude))
//    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TGReactionTableViewCell.cellIdentifier, for: indexPath) as! TGReactionTableViewCell
        let data = tableSource[indexPath.row]
    
        if data.subscribing, let userSubscriptionBadge = data.subscribingBadge, let medalIcon = UIImage(contentsOfURL: userSubscriptionBadge) {
            cell.nameLabel.setTextWithIcon(text: data.userName, image: medalIcon, imagePosition: .front, imageSize: CGSize(width: 16, height: 16), yOffset: -4)
        } else {
            cell.nameLabel.text = data.userName
        }
        cell.captionLabel.text = data.userBio
        cell.setAvatar(urlPath: data.userAvatar.orEmpty, username: "", verifiedIcon: data.verifiedIcon, userId: data.userId)
        cell.reactionImageView.image = ReactionTypes.initialize(with: data.reaction)?.image
        
        cell.prepareUI(with: theme)
        
        return cell
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
