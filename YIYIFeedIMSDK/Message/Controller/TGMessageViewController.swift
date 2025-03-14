//
//  TGMessageViewController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/26.
//

import UIKit
import NIMSDK

public class TGMessageViewController: TGViewController {
    
    /// 发起聊天按钮
    var chatButton: UIButton!
    /// 更多
    var moreButton: UIButton!
    var isWebLoggedIn: Bool = false
    
    let chatListNewVC = RLConversationListViewController()
   
    var currentIndex = 0
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    let containerView = UIView()
    
    var sliderView: TGMessageSliderView!

    public override func viewDidLoad() {
        super.viewDidLoad()
        checkWebIsOnline()
        commonUI()
        NotificationCenter.default.addObserver(self, selector: #selector(updateConversationUnreadCount), name: NSNotification.Name("updateConversationUnreadCount"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkWebIsOnline), name: NSNotification.Name("checkWebIsOnline"), object: nil)
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateConversationUnreadCount()
        getRequestListCount()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func commonUI(){
        let tabs = [TabHeaderdModal(titleString: "rw_text_chats".localized, messageCount: 0, bubbleColor: RLColor.share.theme, isSelected: true), TabHeaderdModal(titleString: "title_requests".localized, messageCount: 0, bubbleColor: RLColor.share.theme, isSelected: false)]
        sliderView = TGMessageSliderView(frame: .zero, tabs: tabs)
       
        setChatButton()
        backBaseView.addSubview(contentStackView)
        contentStackView.bindToEdges()
        contentStackView.addArrangedSubview(sliderView)
        contentStackView.addArrangedSubview(containerView)
        sliderView.snp.makeConstraints { make in
            make.left.right.top.equalTo(0)
            make.height.equalTo(40)
        }
        containerView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
        }
        containerView.layoutIfNeeded()
        if currentIndex == 0 {
            addChild(chatListNewVC)
            chatListNewVC.delegate = self
            chatListNewVC.view.frame = containerView.bounds
            chatListNewVC.isWebLoggedIn = isWebLoggedIn
            containerView.addSubview(chatListNewVC.view)
            chatListNewVC.didMove(toParent: self)
        }
        
        sliderView.selectCallBack = {[weak self] index in
            self?.currentIndex = index
            RLSDKManager.shared.predownloadSticker()
            if index == 1 {
                let requestListVC = TGMessageRequestListController()
                self?.navigationController?.pushViewController(requestListVC, animated: true)
            }
        }
    }
    // MARK: - 设置customNavigationBar
    func setChatButton() {
        let chatItem = UIButton(type: .custom)
        chatItem.addTarget(self, action: #selector(rightButtonClick), for: .touchUpInside)
        self.chatButton = chatItem
        self.chatButton.setImage(UIImage.set_image(named: "iconsSearchBlack"), for: UIControl.State.normal)
        let moreItem = UIButton(type: .custom)
        moreItem.addTarget(self, action: #selector(moreButtonClick), for: .touchUpInside)
        self.moreButton = moreItem
        self.moreButton.setImage(UIImage.set_image(named: "iconsAddmomentBlack"), for: UIControl.State.normal)
        customNavigationBar.setRightViews(views: [chatButton, moreButton])
        let leftBtn = UIButton(type: .custom)
        leftBtn.setTitle("message".localized, for: .normal)
        leftBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        leftBtn.titleLabel?.lineBreakMode = .byTruncatingTail
        leftBtn.setTitleColor(.black, for: .normal)
        customNavigationBar.setLeftViews(views: [leftBtn])
    }
    
    // MARK: - （右上角按钮点击事件）
    @objc func rightButtonClick() {
        let vc = TGMessageSearchListController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func moreButtonClick(){
        var data = [TGToolModel]()
        let titles = ["scan_qr".localized, "new_chat_title".localized, "meeting_kit".localized, "people_nearby".localized, "contact".localized, "title_favourite_message".localized]
        let images = ["iconsQrscanBlack", "iconsAddComment", "iconsGroupMeeting", "iconsPeopleNearbyBlack", "iconsContactBlack", "iconsFavouriteBlack"]
        let types = [TGToolType.scan, TGToolType.newChat, TGToolType.meeting, TGToolType.nearBy, TGToolType.contact, TGToolType.collection]
        for i in 0 ..< titles.count {
            let model = TGToolModel(title: titles[i], image: images[i], type: types[i])
            data.append(model)
        }
        let preference = TGToolChoosePreferences()
        preference.drawing.bubble.color = .white
        preference.drawing.message.color = .lightGray
        preference.drawing.button.color = .lightGray
        preference.drawing.background.color = .clear
        self.moreButton.showToolChoose(identifier: "", data: data, arrowPosition: .none, preferences: preference, delegate: self, isMessage: true)
    }
    
    @objc func updateConversationUnreadCount() {
        let unreadCount = TGIMUnreadCountManager.shared.getConversationAllUnreadCount()
        sliderView.updateUnreadCount(count: unreadCount, index: 0)
    }
    func getRequestListCount() {
        TGIMUnreadCountManager.shared.getRequestlistCountAllUnreadCount {[weak self] count in
            self?.sliderView.updateUnreadCount(count: count, index: 1)
        }
    }
    
    ///判断网页端是否在线
    @objc func checkWebIsOnline(){
        if let clients = NIMSDK.shared().v2LoginService.getLoginClients(), clients.count > 0 {
            for client in clients {
                if client.type == .LOGIN_CLIENT_TYPE_WEB {
                    //is web login
                    isWebLoggedIn = true
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "isWebLoggedIn"), object: nil,
                                                    userInfo: ["isLogIn": true])
                    break
                }
            }
        } else {
            isWebLoggedIn = false
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "isWebLoggedIn"), object: nil,
                                            userInfo:  ["isLogIn": false])
        }
    }

}

extension TGMessageViewController: RLConversationListViewControllerDelegate {
    func didTapItem(conversationId: String, conversationType: Int) {
        let vc = TGChatViewController(conversationId: conversationId, conversationType: conversationType)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension TGMessageViewController: TGToolChooseDelegate {
    func didSelectedItem(type: TGToolType, title: String) {
        switch type {
        case .scan:
            RLSDKManager.shared.imDelegate?.didPressQRScan()
        case .contact:
            RLSDKManager.shared.imDelegate?.didPressContacts()
        case .nearBy:
            RLSDKManager.shared.imDelegate?.didPressNearByPeople()
        case .newChat:
            let vc = AddChatViewController(isShowCol: false, cancelType: .allwayShow)
            self.navigationController?.pushViewController(vc, animated: true)
        case .meeting:
            let vc = TGMeetingListViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case .collection:
            let vc = MsgCollectionViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    
}
