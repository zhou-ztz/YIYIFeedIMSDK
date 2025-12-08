//
//  TGReactionController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/20.
//

import UIKit

class TGReactionController: UIViewController {

    private(set) var theme: Theme = .dark
    
    var onLoaded: ((Int?) -> Void)?
    
    var reactionStats: [TGFeedReactionsModel.Stat]?
    private let pagecontroller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private var segmentView: SegmentView = SegmentView(configs: [])
    var configs: [HeadingSelectionViewStyles] = []
    fileprivate lazy var pageHandler: TGPageHandler = {
        let handler = TGPageHandler()
        handler.reactionController = self
        return handler
    }()

    private let contentstack = UIStackView().configure { v in
        v.axis = .vertical
        v.spacing = 8
        v.distribution = .fill
        v.alignment = .fill
    }
    lazy var placeHolder: TGPlaceHolderView = {
        return TGPlaceHolderView(offset: TSNavigationBarHeight - 50, heading: "", detail: "", lottieName: "feed-loading", theme: theme)
    }()
    var feedId: Int!

    private var isNavTransparent: Bool = false
    
    init(theme: Theme, feedId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.theme = theme
        self.feedId = feedId
        self.isNavTransparent = true
    }

    convenience init(feedId: Int) {
        self.init(theme: .white, feedId: feedId)
    }
    
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTheme()
        pageHandler.pageController = pagecontroller
        
        view.addSubview(placeHolder)
        placeHolder.bindToEdges()
        view.layoutIfNeeded()

        placeHolder.play()
        
        fetch()
        
        segmentView.didSelectIndex = { [weak self] index in
            self?.jumpToPage(index: index)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func fetch() {
        TGFeedNetworkManager.shared.getReactionList(id: feedId, reactionType: nil) { [weak self] (model, error) in
                    
            DispatchQueue.main.async {
                defer {
                    self?.onLoaded?(model?.stats?.first?.count)
                    self?.placeHolder.removeFromSuperview()
                }
                guard let self = self, let model = model else { return }
                    self.removePlaceholderView()
                    self.setup(with: model.stats, reactionLists: model.data)
                    self.reactionStats = model.stats
            
            }
        }
    }
    func removePlaceholderView() {
        self.placeHolder.removeFromSuperview()
    }
    
//    override func placeholderButtonDidTapped() {
//        fetch()
//    }
    
    func segmentIndexUpdate(for index: Int) {
        segmentView.setActive(index: index)
    }

    private func updateTheme() {
        switch theme {
        case .white:
            view.backgroundColor = .white
            navigationController?.navigationBar.barTintColor = UIColor.white

        case .dark:
            view.backgroundColor = TGAppTheme.materialBlack
            navigationController?.navigationBar.barTintColor = TGAppTheme.materialBlack
        }
    }

    private func setup(with reactionStats: [TGFeedReactionsModel.Stat]?, reactionLists: [TGFeedReactionsModel.Data]?) {
        
        if let reactionStats = reactionStats, reactionStats.count > 0 {
            setupPrepareSegments(with: reactionStats, reactionLists: reactionLists ?? [])
            contentstack.addArrangedSubview(segmentView)
        } else {
//            showEmptyData()
        }
                
        view.addSubview(contentstack)
        contentstack.bindToEdges()

        addChild(pagecontroller)
        contentstack.addArrangedSubview(pagecontroller.view)
        pagecontroller.didMove(toParent: self)
        
        let firstController = TGReactionListController(theme: theme, reactionType: nil, feedId: feedId, index: 0)
        pagecontroller.setViewControllers([firstController], direction: .forward, animated: false)
    }
    
    
    private func setupPrepareSegments(with reactionStats: [TGFeedReactionsModel.Stat],
                                      reactionLists: [TGFeedReactionsModel.Data]) {
        
        var configs = reactionStats.compactMap { (model) -> HeadingSelectionViewStyles? in
            guard let reaction = ReactionTypes.initialize(with: model.reaction) else { return nil }
            return HeadingSelectionViewStyles.icon(text: model.count.abbreviated, reaction: reaction, highlightColor: TGAppTheme.red, unhighlightColor: TGAppTheme.brownGrey, indicatorColor: TGAppTheme.red)
        }
        
        if let allStats = reactionStats.filter({ $0.reaction == "all" }).first {
            configs.insert(HeadingSelectionViewStyles.icon(text: "rl_total_reactions".localized.replacingOccurrences(of: "%s", with: allStats.count.stringValue), reaction: nil, highlightColor: TGAppTheme.red, unhighlightColor: TGAppTheme.brownGrey, indicatorColor: TGAppTheme.red), at: 0)
        }
        
        self.configs = configs

        segmentView = SegmentView(configs: configs)
        segmentView.didSelectIndex = { [weak self] index in
            guard let self = self else { return }
            guard let currentController = self.pagecontroller.viewControllers?.first as? TGReactionListController else { return }
            guard let newReaction = configs[index].reaction else {
                
                DispatchQueue.main.async {
                    self.pagecontroller.setViewControllers([TGReactionListController(theme: self.theme, reactionType: nil, feedId: self.feedId, index: 0)],
                                                      direction: .reverse, animated: true, completion: nil)
                }
                
                return
            }
            
            let direction: UIPageViewController.NavigationDirection
            if index >= currentController.index {
                direction = .forward
            } else { direction = .reverse }
            
            DispatchQueue.main.async {
                self.pagecontroller.setViewControllers([TGReactionListController(theme: self.theme, reactionType: newReaction, feedId: self.feedId, index: index)],
                                                        direction: direction, animated: true, completion: nil)
            }
        }
    }
    
    
    private func jumpToPage(index: Int) {
        let currentIndex = segmentView.currentIndex
        guard currentIndex != index else { return }
        
        if index == 0 {
            pagecontroller.setViewControllers([TGReactionListController(theme: theme, reactionType: nil, feedId: feedId, index: index)], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
            return
        }
        
        let direction: UIPageViewController.NavigationDirection
        if currentIndex > index {
            direction = .reverse
        } else {
            direction = .forward
        }
        
        let reaction = configs[index].reaction
        
        pagecontroller.setViewControllers([TGReactionListController(theme: theme, reactionType: reaction, feedId: feedId, index: index)], direction: direction, animated: true, completion: nil)
    }
}

class TGPageHandler: NSObject, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    weak var reactionController: TGReactionController?
    weak var pageController: UIPageViewController? {
        didSet {
            self.pageController?.delegate = self
            self.pageController?.dataSource = self
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard finished == true else { return }
        guard let currentController = pageViewController.viewControllers?.first as? TGReactionListController else { return }
        reactionController?.segmentIndexUpdate(for: currentController.index)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let hostController = reactionController, let previousController = viewController as? TGReactionListController else { return nil }
        let index = previousController.index - 1
        
        guard index >= 0 else {
            return nil
        }
        guard hostController.configs.count > index else {
            return nil
        }
        
        let reaction = hostController.configs[index].reaction
        return TGReactionListController(theme: hostController.theme, reactionType: reaction, feedId: hostController.feedId, index: index)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let hostController = reactionController, let currentController = viewController as? TGReactionListController else { return nil }
        let nextIndex = currentController.index + 1
        guard hostController.configs.count != nextIndex else {
            return nil
        }
        guard hostController.configs.count > nextIndex else {
            return nil
        }
        let reaction = hostController.configs[nextIndex].reaction
        return TGReactionListController(theme: hostController.theme, reactionType: reaction, feedId: hostController.feedId, index: nextIndex)
    }
}
