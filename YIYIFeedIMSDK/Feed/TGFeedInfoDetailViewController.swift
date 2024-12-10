//
//  TGFeedInfoDetailViewController.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/28.
//

import UIKit

public class TGFeedInfoDetailViewController: TGViewController {

    lazy var tableView: UITableView = {
        let tb = UITableView(frame: CGRect.zero, style: .plain)
        tb.register(FeedDetailCommentTableViewCell.self, forCellReuseIdentifier: FeedDetailCommentTableViewCell.cellIdentifier)
        tb.showsVerticalScrollIndicator = false
        tb.backgroundColor = .white
        tb.tableFooterView = UIView()
        tb.separatorStyle = .none
        tb.delegate = self
        tb.dataSource = self
        return tb
    }()
    
    private var headerView: FeedDetailTableHeaderView = FeedDetailTableHeaderView()
    private let navView: TGMomentDetailNavTitle = TGMomentDetailNavTitle()
    
//    var currentPrimaryButtonState: SocialButtonState = .follow
    
    private let primaryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("display_follow".localized, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = TGAppTheme.Font.regular(12)
        button.backgroundColor = TGAppTheme.primaryRedColor
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.roundCorner(10)
        return button
    }()
    let moreButton = UIButton(type: .custom).configure {
        $0.setImage(UIImage(named: "IMG_topbar_more_black"), for: .normal)
    }
    
    var dontTriggerObservers:Bool = false
    public var model: FeedListCellModel? {
        didSet {
            self.setHeader()
            self.setBottomViewData()
            self.getCommentList()
            self.navView.updateSponsorStatus(model?.isSponsored ?? false)
        }
    }
    public var transitionId = UUID().uuidString
    public var afterTime: String = ""
    
    private var commentModel: FeedCommentListCellModel?
    private var commentDatas: [FeedCommentListCellModel] = [FeedCommentListCellModel]()
    private var sendText: String?
    private var isTapMore = false
    private var isClickCommentButton = false
    
    private let commentInputView = UIView()
    private var feedId: Int = 0
    private var feedOwnerId: Int = 0
    private var afterId: Int?
    private var isFullScreen: Bool = false
//    private var sendCommentType: SendCommentType = .send
//    private var headerView: FeedCommentDetailTableHeaderView = FeedCommentDetailTableHeaderView()
//    private var bottomToolBarView: FeedCommentDetailBottomView = FeedCommentDetailBottomView(frame: .zero, colorStyle: .normal)
//
    
    var isHomePage: Bool = false
    // feed type
//    var type: FeedListType?
    
    public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return true
    }
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    
//    var startPlayTime: CMTime = .zero
//    var onDismiss: ((CMTime) -> Void)?
    
    
    public init(feedId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.feedId = feedId
//        self.onToolbarUpdated = onToolbarUpdated
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        loadFeedDetailInfo()
    }
    

    // MARK: - 设置导航栏部分
//    private func setupNavHeaderView() {
//        
//        let titleView = UIBarButtonItem(customView: navView)
//        self.navigationItem.leftBarButtonItems = [titleView]
//        
//        primaryButton.addTap { [weak self] (_) in
////            guard let self = self else { return }
////            self.followUserClicked()
//        }
//        primaryButton.snp.makeConstraints {
//            $0.width.equalTo(70)
//            $0.height.equalTo(25)
//        }
//        let followView = UIBarButtonItem(customView: primaryButton)
//        moreButton.addAction {
////            guard let id = CurrentUserSessionInfo?.userIdentity else {
////                return
////            }
////            guard let model = self.model else { return }
////            
////            self.navigationController?.presentPopVC(target: model, type: model.userId == id ? .moreMe : .moreUser , delegate: self)
//        }
//        let moreView = UIBarButtonItem(customView: moreButton)
//        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//        space.width = 12
//        //等数据加载成功再显示按钮
//        primaryButton.isHidden = true
//        moreButton.isHidden = true
//        self.navigationItem.rightBarButtonItems = [moreView, space ,followView]
//    }
    private func loadFeedDetailInfo() {
        TGFeedNetworkManager.shared.fetchFeedDetailInfo(with: "\(feedId)") { feedInfo, error in
            guard let feedInfo = feedInfo else { return }
            self.headerView.setData(data: feedInfo)
        }
    }
    private func setupTableView() {
        self.customNavigationBar.title = "动态详情"
        backBaseView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60;
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 70))
//        tableView.mj_header = SCRefreshHeader(refreshingTarget: self, refreshingAction: #selector(getData))
//        tableView.mj_footer = SCRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        tableView.tableHeaderView = headerView
    }
    private func setHeader() {
        guard let model = model else { return }
    
    }
    private func setBottomViewData() {
        guard let model = model else { return }
//        bottomToolBarView.isHidden = false
//        bottomToolBarView.loadToolbar(model: model.toolModel, canAcceptReward: model.canAcceptReward == 1 ? true : false, reactionType: model.reactionType)
        
       
    }
    private func setBottomView() {
//        view.addSubview(bottomToolBarView)
//        bottomToolBarView.isHidden = true
//        bottomToolBarView.onCommentAction = { [weak self] in
//            guard let self = self else { return }
////            TSKeyboardToolbar.share.keyboardBecomeFirstResponder()
//        }
//        
//        bottomToolBarView.snp.makeConstraints {
//            $0.right.left.bottom.equalToSuperview()
//            $0.height.equalTo(70)
//        }
    }
    private func getCommentList() {

    }
}


// Table View Delegate
extension TGFeedInfoDetailViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedDetailCommentTableViewCell.cellIdentifier, for: indexPath) as! FeedDetailCommentTableViewCell
        cell.selectionStyle = .none
//        let feedCommentModel = self.dataSource[indexPath.row]
//        
//        cell.setData(data: feedCommentModel)
//        
//        cell.likeButtonClickCall = {[weak self] in
//            guard let self = self else {return}
//            //是否点赞
//            let isLiking = feedCommentModel.relevanceId > 0
//            if isLiking {
//                self.handleLikeAction(feedModel: feedCommentModel, indexPath: indexPath, likeValue: 1, countChange: -1)
//            } else {
//                self.handleLikeAction(feedModel: feedCommentModel, indexPath: indexPath, likeValue: 0, countChange: 1)
//            }
//        }
//        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
