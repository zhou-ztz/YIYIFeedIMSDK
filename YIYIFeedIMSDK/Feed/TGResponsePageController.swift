//
//  TGResponsePageController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/20.
//

import UIKit

private enum ResponseSegment: Int {
    case comment = 0
    case reaction = 1

    init?(rawValue: Int)  {
        switch rawValue {
        case 0: self = .comment
        case 1: self = .reaction
        default: return nil
        }
    }
}
class TGResponsePageController: UIViewController {

    private var segments: [ResponseSegment] = [.comment, .reaction]
    fileprivate var activeSegments: ResponseSegment = .comment
    private(set) var theme: Theme = .white
    
    private lazy var segmentView: SegmentView = {
        let segment: SegmentView = SegmentView(configs: [HeadingSelectionViewStyles.largeText(text: "comment", highlightColor: UIColor.black, unhighlightColor: UIColor.black, indicatorColor: UIColor.clear),
                                                         ])
        return segment
    }()
    lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.applyStyle(.regular(size: 14, color:.black))
        label.text = "comment".localized
        label.textAlignment = .center
        return label
    }()

    private let closeButton = UIButton()
    private(set) var feed: FeedListCellModel
    private lazy var reactionController = { return TGReactionController(theme: self.theme, feedId: feed.idindex) }()
    private lazy var commentController = { return TGCommentPageController(theme: self.theme, feedId: feed.idindex, feedOwnerId: feed.userId, feedItem: feed) }()

    private let pagecontroller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private let contentstack = UIStackView().configure { v in
        v.axis = .vertical
        v.spacing = 8
        v.distribution = .fill
        v.alignment = .leading
    }

    private var onToolbarUpdated: onToolbarUpdate?
    
    init(theme: Theme, feed: FeedListCellModel, defaultSegment: Int = 0, onToolbarUpdate: onToolbarUpdate?) {
        self.feed = feed
        super.init(nibName: nil, bundle: nil)
        self.theme = theme
        self.activeSegments = segments[defaultSegment]
        self.onToolbarUpdated = onToolbarUpdate
        
  
        commentController.onLoaded = { [weak self] count in
            self?.feed.toolModel?.commentCount = count
            guard let self = self else { return }
            self.onToolbarUpdated?(self.feed)
        }
        
        reactionController.onLoaded = { [weak self] stats in
           
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        updateTheme()
        self.setLeftAlignedNavigationItemView(titleLabel)
        self.edgesForExtendedLayout = []

        closeButton.setImage(UIImage(named: "ic_gray_close"))
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReciveAvatarDidClick), name: NSNotification.Name.AvatarButton.DidClick, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AvatarButton.DidClick, object: nil)
    }

    private func updateTheme() {
        switch theme {
        case .white:
            view.backgroundColor = .white
            navigationController?.navigationBar.barTintColor = UIColor.white
            closeButton.tintColor = .black
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.backgroundColor = .white
            if #available(iOS 15, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .white
                self.navigationController?.navigationBar.standardAppearance = appearance
                self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            }
            
        case .dark:
            view.backgroundColor = TGAppTheme.materialBlack
            navigationController?.navigationBar.barTintColor = TGAppTheme.materialBlack
            closeButton.tintColor = .white
            navigationController?.navigationBar.tintColor = TGAppTheme.materialBlack
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.backgroundColor = TGAppTheme.materialBlack
            if #available(iOS 15, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = TGAppTheme.materialBlack
                self.navigationController?.navigationBar.standardAppearance = appearance
                self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            }
        }
    }

    private func setup() {
        view.backgroundColor = .white
        view.addSubview(contentstack)
        contentstack.snp.makeConstraints { v in
            v.top.left.right.equalToSuperview()
            v.bottom.lessThanOrEqualToSuperview()
        }

        self.navigationController?.navigationBar.roundCorners([.topLeft, .topRight], radius: 10)
        self.navigationController?.navigationBar.clipsToBounds = true
        
        let leftPaddingView = UIView(frame: CGRectMake(0, 0, 15, 15))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftPaddingView)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        let  view = UIView(frame: CGRect(x: 100, y: 100, width: 100, height: 30))
        view.backgroundColor = .red
        self.view.addSubview(view)
        closeButton.addTap { [weak self] (_) in
            self?.dismiss(animated: true, completion: nil)
        }

        addChild(commentController)
        addChild(reactionController)
        
        self.view.addSubview(commentController.view)
        self.view.addSubview(reactionController.view)
        
        commentController.didMove(toParent: self)
        reactionController.didMove(toParent: self)
        
        commentController.view.bindToEdges()
        reactionController.view.bindToEdges()
        
        updateSegmentView()
        
        segmentView.didSelectIndex = { [weak self] index in
            guard let self = self else { return }
            let segment = self.segments[index]
            self.activeSegments = segment
            self.updateSegmentView()
        }
    }
    
    private func updateSegmentView() {
        
        switch activeSegments {
        case .comment:
            self.commentController.view.makeVisible()
            self.reactionController.view.makeHidden()
            self.view.bringSubviewToFront(self.commentController.view)

        case .reaction:
            self.reactionController.view.makeVisible()
            self.commentController.view.makeHidden()
            self.view.bringSubviewToFront(self.reactionController.view)
        }
    }
    
    @objc func didReciveAvatarDidClick() {
        self.dismiss(animated: true, completion: nil)
    }

}
