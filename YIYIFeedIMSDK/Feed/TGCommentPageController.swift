//
//  TGCommentPageController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/21.
//

import UIKit
import SnapKit
import Combine

class TGCommentPageController: UIViewController {

    private var cancellables = Set<AnyCancellable>()
    var pageIndex = 0
    
    var onLoaded: ((Int) -> Void)?
    private(set) var theme: Theme = .dark
    private(set) var feedId: Int = 0
    private(set) var feedOwnerId: Int = 0
    private(set) var feedItem: FeedListCellModel?
    
    private lazy var table: RLTableView = {
        let table = RLTableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.register(FeedDetailCommentTableViewCell.self, forCellReuseIdentifier: FeedDetailCommentTableViewCell.cellIdentifier)
        table.delegate = self
        table.dataSource = self
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        table.separatorInset = .zero
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.textToolbarHeight, right: 0)
        table.mj_header = SCRefreshHeader(refreshingBlock: { [weak self] in
            self?.getCommentList(isLoadMore: false)
        })
        table.mj_footer = SCRefreshFooter(refreshingBlock: { [weak self] in
            self?.getCommentList(isLoadMore: true)
        })
        return table
    }()
    
    private var selectedComment: FeedCommentListCellModel?
    private let fakeTextToolbar = MessageInputView()
    private let invisibleView = UIView().configure {
        $0.backgroundColor = .clear
    }
    private var comments: [FeedCommentListCellModel] = []
    
    init(theme: Theme, feedId: Int, feedOwnerId: Int, feedItem: FeedListCellModel?) {
        self.feedId = feedId
        self.feedOwnerId = feedOwnerId
        self.feedItem = feedItem
        super.init(nibName: nil, bundle: nil)
        self.theme = theme
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        updateTheme()
        TGKeyboardToolbar.share.theme = theme
        TGKeyboardToolbar.share.keyboardToolbarDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TGKeyboardToolbar.share.keyboarddisappear()
        TGKeyboardToolbar.share.keyboardStopNotice()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TGKeyboardToolbar.share.keyboardstartNotice()
    }
    
    private func updateTheme() {
        switch theme {
        case .white:
            self.view.backgroundColor = .white
            navigationController?.navigationBar.barTintColor = UIColor.white
            navigationController?.navigationBar.isTranslucent = false
            
        case .dark:
            self.view.backgroundColor = TGAppTheme.materialBlack
            navigationController?.navigationBar.barTintColor = TGAppTheme.materialBlack
            navigationController?.navigationBar.isTranslucent = false
        }
    }
    
    private func setup() {
        self.view.addSubview(table)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 60;
        table.bindToEdges()
        
        self.view.addSubview(fakeTextToolbar)
        fakeTextToolbar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        fakeTextToolbar.theme = self.theme
        fakeTextToolbar.sendTextView.delegate = self
        fakeTextToolbar.sendTextView.addAction { [weak self] in
            self?.selectedComment = nil
            self?.activeKeyboard()
        }
        fakeTextToolbar.smileButton.addAction { [weak self] in
            self?.activeKeyboard()
            TGKeyboardToolbar.share.showEmojiView()
        }
        
        table.mj_header.beginRefreshing()
    }
    
    private func onUpdateSegmentTitle() {
        self.onLoaded?(self.comments.count)
    }
    
    private func getCommentList(isLoadMore: Bool) {
        let after = isLoadMore ? comments.last?.id["commentId"] : nil
        TGFeedNetworkManager.shared.fetchFeedCommentsList(withFeedId: "\(self.feedId)", afterId: after, limit: 20) { [weak self] (contentListResponse, error) in
            guard let self = self else { return }
            guard let commentModels = contentListResponse else { return }
            defer {
                self.table.reloadData()
                if isLoadMore {
                    if commentModels.count < 20 {
                        self.table.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.table.mj_footer.endRefreshing()
                    }
                } else {
                    self.table.mj_header.endRefreshing()
                }
            }
          
            if isLoadMore {
                self.comments.append(contentsOf: commentModels)
            } else {
                self.comments = commentModels
                guard self.comments.count > 0 else {
                    self.table.show(placeholderView: .noComment, theme: self.theme, height: 100)
                    return
                }
                self.table.removePlaceholderViews()
                self.table.mj_footer.endRefreshing()
            }
        }
    }
    
    private func pinComment(in cell: FeedDetailCommentTableViewCell, comment: FeedCommentListCellModel) {
        
        guard let commentId = comment.id["commentId"], let cellIndex = self.comments.firstIndex(where: { $0.id["commentId"] == commentId }) else {
            return
        }
        TGCommentNetWorkManager.shared.pinComment(for: commentId, sourceId: feedId) { [weak self] (message, status) in
            //            cell.hideLoading()
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard let commentIndex = self.comments.firstIndex(where: { $0.id["commentId"] == commentId }) else { return }
                guard status == true else {
                    self.showTopFloatingToast(with: message.orEmpty, desc: message.orEmpty)
                    return
                }
                self.showTopFloatingToast(with: "feed_live_pinned_comment".localized, desc: message.orEmpty)
                self.comments[cellIndex].showTopIcon = true
                cell.setAsPinned(pinned: true, isDarkMode: false)
                self.table.moveRow(at: IndexPath(row: cellIndex, section: 0), to: IndexPath(row: 0, section: 0))
                self.comments.remove(at: cellIndex)
                self.comments.insert(comment, at: 0)
            }
        }
    }
    
    private func unpinComment(in cell: FeedDetailCommentTableViewCell, comment: FeedCommentListCellModel) {
        guard let commentId = comment.id["commentId"], let cellIndex = self.comments.firstIndex(where: { $0.id["commentId"] == commentId }) else {
            return
        }
        //        cell.showLoading()
        TGCommentNetWorkManager.shared.unpinComment(for: commentId, sourceId: feedId) { [weak self] (message, status) in
            //            cell.hideLoading()
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard let commentIndex = self.comments.firstIndex(where: { $0.id["commentId"] == commentId }) else { return }
                guard status == true else {
                    self.showTopFloatingToast(with: message.orEmpty, desc: message.orEmpty)
                    return
                }
                self.showTopFloatingToast(with: "feed_live_unpinned_comment".localized, desc: message.orEmpty)
                self.comments[cellIndex].showTopIcon = false
                cell.setAsPinned(pinned: false, isDarkMode: false)
                self.table.moveRow(at: IndexPath(row: cellIndex, section: 0), to: IndexPath(row: self.comments.count - 1, section: 0))
                self.comments.remove(at: cellIndex)
                self.comments.append(comment)
            }
        }
    }

}
extension TGCommentPageController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedDetailCommentTableViewCell.identifier, for: indexPath) as! FeedDetailCommentTableViewCell
        cell.setData(data: comments[indexPath.row])
        cell.cellDelegate = self
        cell.setAsPinned(pinned: comments[indexPath.row].showTopIcon, isDarkMode: false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FeedDetailCommentTableViewCell else {
            return
        }
        let model = comments[indexPath.row]
        didTapToReplyUser(in: cell, model: model)
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension TGCommentPageController: TGDetailCommentTableViewCellDelegate {
    func repeatTap(cell: FeedDetailCommentTableViewCell, commnetModel: FeedCommentListCellModel) {
        
    }
    
    func didSelectName(userId: Int) {
        RLSDKManager.shared.imDelegate?.didPressUerProfile(uid: userId)
    }
    
    func didSelectHeader(userId: Int) {
        RLSDKManager.shared.imDelegate?.didPressUerProfile(uid: userId)
    }
    
    func didLongPressComment(in cell: FeedDetailCommentTableViewCell, model: FeedCommentListCellModel) {
        guard  let currentUserInfo = TGUserInfoModel.retrieveCurrentUserSessionInfo() else {
            return
        }
        // 显示举报评论弹窗
        let isFeedOwner = currentUserInfo.userIdentity == self.feedOwnerId
        let isCommentOwner = currentUserInfo.userIdentity == model.userId
        
        if isCommentOwner {
            self.navigationController?.presentPopVC(target: LivePinCommentModel(target: cell, requiredPinMessage: isFeedOwner, model: model), type: .selfComment, delegate: self)
        } else {
            self.navigationController?.presentPopVC(target: LivePinCommentModel(target: cell, requiredPinMessage: isFeedOwner, model: model), type: .normalComment , delegate: self)
        }
    }
    
    func didTapToReplyUser(in cell: FeedDetailCommentTableViewCell, model: FeedCommentListCellModel) {
        guard let userInfo = model.userInfo else { return }
        guard userInfo.isMe() == false else { return }
        self.selectedComment = model
        activeKeyboard()
    }
    
    func needShowError() {
        self.showTopFloatingToast(with: "text_user_suspended", desc: "")
    }
}

extension TGCommentPageController: TGKeyboardToolbarDelegate {
    private func activeKeyboard() {
        
        TGKeyboardToolbar.share.keyboardBecomeFirstResponder()
        if let userInfo = self.selectedComment?.userInfo {
        TGKeyboardToolbar.share.keyboardSetPlaceholderText(placeholderText: "reply_with_string".localized + "\(userInfo.name)")
        } else {
            TGKeyboardToolbar.share.keyboardSetPlaceholderText(placeholderText: "rw_placeholder_comment".localized)
        }
    }
    
    func keyboardToolbarSendTextMessage(message: String, bundleId: String?, inputBox: AnyObject?, contentType: CommentContentType) {
//        guard TSCurrentUserInfo.share.isLogin, let currentUserInfo = TSCurrentUserInfo.share.userInfo else { return }
        
        self.showLoading()
        //上报动态评论事件
        RLSDKManager.shared.feedDelegate?.onTrackEvent(itemId: feedId.stringValue, itemType: feedItem?.feedType == .miniVideo ? TGItemType.shortvideo.rawValue : TGItemType.image.rawValue, behaviorType: TGBehaviorType.comment.rawValue, moduleId: TGModuleId.feed.rawValue, pageId: TGPageId.feed.rawValue, behaviorValue: nil, traceInfo: nil)
        
        
        TGFeedNetworkManager.shared.submitComment(for: .momment, content: message, sourceId: feedId, replyUserId: self.selectedComment?.userInfo?.userIdentity, contentType: contentType) { [weak self] (commentModel, message, result) in
            
            DispatchQueue.main.async {
                defer {
                    self?.selectedComment = nil
//                    self?.dismissLoading()
                }
                guard result == true, let data = commentModel, let feedId = self?.feedId, let wself = self else {
                    UIViewController.showBottomFloatingToast(with: message ?? "please_retry_option".localized, desc: "", displayDuration: 4.0)
                    return
                }
                let model = FeedCommentListCellModel(object: data, feedId: feedId)
                model.replyUserInfo = self?.selectedComment?.userInfo
                model.userId = TGUserInfoModel.retrieveCurrentUserSessionInfo()?.userIdentity ?? 0
                
                if let lastPinnedIndex = self?.comments.lastIndex(where: { $0.showTopIcon == true }) {
                    self?.comments.insert(model, at: lastPinnedIndex + 1)
                } else {
                    self?.comments.insert(model, at: 0)
                }
                self?.onUpdateSegmentTitle()
                self?.table.removePlaceholderViews()
                self?.table.reloadData()
                self?.table.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
    }
    
    func keyboardToolbarDidDismiss() {
        
    }
    
    func keyboardWillHide() {
        //        TGKeyboardToolbar.share.clearCurrentTextOnSend()
        if TGKeyboardToolbar.share.isEmojiSelected() == false {
            TGKeyboardToolbar.share.removeToolBar()
        }
    }
    
    func keyboardToolbarFrame(frame: CGRect, type: keyboardRectChangeType) {
        
    }
}

extension TGCommentPageController {
    private func reportComment(in cell: FeedDetailCommentTableViewCell, model: FeedCommentListCellModel) {
        
        let reportTarget: ReportTargetModel = ReportTargetModel(feedCommentModel: model)
        let reportVC: TGReportViewController = TGReportViewController(reportTarget: reportTarget)
        self.present(TGNavigationController(rootViewController: reportVC).fullScreenRepresentation,
                     animated: true,
                     completion: nil)
    }
    
    private func deleteComment(in cell: FeedDetailCommentTableViewCell, comment: FeedCommentListCellModel) {
        guard let commentId = comment.id["commentId"] else {
            return
        }
        TGCommentNetWorkManager.shared.deleteComment(for: .momment, commentId: commentId, sourceId: feedId) { [weak self] (message, status) in
            DispatchQueue.main.async {
                if status == true {
                    self?.comments.removeAll(where: { $0.id["commentId"] == commentId })
                    self?.table.reloadData()
                    self?.onUpdateSegmentTitle()
                } else {
                    self?.showTopFloatingToast(with: "", desc: message.orEmpty)
                }
            }
        }
    }
}

extension TGCommentPageController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        guard TSCurrentUserInfo.share.isLogin == true else {
//            TSRootViewController.share.guestJoinLandingVC()
//            return false
//        }
        activeKeyboard()
        return false
    }
}

extension TGCommentPageController: CustomPopListProtocol {
    func customPopList(itemType: TGPopUpItem) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.handlePopUpItemAction(itemType: itemType)
        }
    }
    
    func handlePopUpItemAction(itemType: TGPopUpItem) {
        switch itemType {
        case .reportComment(model: let model):
            guard let cell = model.target as? FeedDetailCommentTableViewCell else { return }
            let feedModel = model.model
            DispatchQueue.main.async {
                self.reportComment(in: cell, model: feedModel)
            }
            break
        case .deleteComment(model: let model):
            guard let cell = model.target as? FeedDetailCommentTableViewCell else { return }
            let feedModel = model.model
            self.showRLDelete(title: "delete_comment".localized, message: "rw_delete_comment_action_desc".localized, dismissedButtonTitle: "delete".localized, onDismissed: { [weak self] in
                guard let self = self else { return }
                self.deleteComment(in: cell, comment: feedModel)
            }, cancelButtonTitle: "cancel".localized)
            break
        case .livePinComment(model: let model):
            guard let cell = model.target as? FeedDetailCommentTableViewCell else { return }
            let feedModel = model.model
            DispatchQueue.main.async {
                self.pinComment(in: cell, comment: feedModel)
            }
            break
        case .liveUnPinComment(model: let model):
            guard let cell = model.target as? FeedDetailCommentTableViewCell else { return }
            let feedModel = model.model
            DispatchQueue.main.async {
                self.unpinComment(in: cell, comment: feedModel)
            }
            break
        case .copy(model: let model):
            let feedModel = model.model
            UIPasteboard.general.string = feedModel.content
            UIViewController.showBottomFloatingToast(with: "rw_copy_to_clipboard".localized, desc: "")
            break
        default:
            break
        }
    }
}
