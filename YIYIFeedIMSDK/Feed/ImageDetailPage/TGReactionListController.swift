//
//  TGReactionListController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/20.
//

import UIKit

class TGReactionListController: TGViewController {

    private(set) var reactionType: ReactionTypes?
    
    private let table = UITableView(frame: .zero, style: .plain).configure { v in
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
        table.register(UINib(nibName: "ReactionTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
//        view.addSubview(table)
//        table.bindToEdges()
//        table.delegate = self
//        table.dataSource = self
//        
//        table.mj_header = nil
//        table.mj_footer = SCRefreshFooter(refreshingBlock: { [weak self] in
//            self?.fetch()
//        })
//        
//        fetch()
//
//        switch theme {
//        case .white:
//            table.backgroundColor = .white
//            view.backgroundColor = .white
//        case .dark:
//            table.backgroundColor = TGAppTheme.materialBlack
//            view.backgroundColor = TGAppTheme.materialBlack
//        }
    }
    
//    private func fetch() {
//        
//        TSMomentNetworkManager().reactionList(id: feedId, reactionType: reactionType, after: apiPointer) { [weak self] (result, success, message) in
//            guard let self = self else { return }
//            
//            DispatchQueue.main.async {
//                
//                guard success else {
//                    self.table.show(placeholderView: .network)
//                    UIViewController.showBottomFloatingToast(with: "", desc: message.orEmpty)
//                    return
//                }
//                
//                if let data = result?.data, data.count > 0 {
//                    self.tableSource.append(contentsOf: data)
//                    self.apiPointer = (data.last?.id).orZero.stringValue
//                    
//                    self.table.reloadData()
//                    self.table.mj_footer.endRefreshing()
//                    self.table.removePlaceholderViews()
//                } else {
//                    if self.tableSource.count == 0 {
//                        self.table.show(placeholderView: .empty, theme: self.theme)
//                    }
//                    self.table.mj_footer.endRefreshingWithNoMoreData()
//                }
//            }
//            
//        }
//    }
}
