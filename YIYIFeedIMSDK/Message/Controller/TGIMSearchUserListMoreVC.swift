//
//  TGIMSearchUserListMoreVC.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/18.
//

import UIKit
import NIMSDK

class TGIMSearchUserListMoreVC: TGViewController {
    var members: [TGUserInfoModel] = []
    var keyword: String = ""
    
    lazy var tableView = RLTableView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight), style: .plain).configure {
        $0.tableFooterView = UIView()
        $0.backgroundColor = .white
        $0.rowHeight = 60
        $0.register(TGUserSearchListMoreCell.self, forCellReuseIdentifier: TGUserSearchListMoreCell.identifier)
        $0.showsVerticalScrollIndicator = false
        $0.separatorStyle = .none
        $0.delegate = self
        $0.dataSource = self
    }
    
    var bottomEmptyView = UIView()
    var endListLabel = UILabel()
    
    func setupRightNavItem() {
        let doneItem = UIButton(type: .custom)
        doneItem.addTarget(self, action: #selector(rightNavButtonTapped), for: .touchUpInside)
        doneItem.setTitle("done".localized, for: .normal)
        doneItem.setTitleColor(TGAppTheme.dodgerBlue, for: .normal)
        doneItem.titleLabel?.font = .systemFont(ofSize: 14)
        self.customNavigationBar.setRightViews(views: [doneItem])
    }
    
    @objc func rightNavButtonTapped(){
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.title = "more_friends".localized
        setupRightNavItem()
        setupUI()
    }
    
    func setupUI() {
        self.backBaseView.addSubview(tableView)
        
        bottomEmptyView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 60))
        bottomEmptyView.backgroundColor = UIColor(hex: 0xe1e1e1)
        
        self.backBaseView.addSubview(bottomEmptyView)
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.bottom.equalTo(bottomEmptyView.snp.top).offset(-10)
        }
        
        bottomEmptyView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        bottomEmptyView.makeHidden()
        
        endListLabel = UILabel()
        endListLabel.textColor = UIColor(red: 128, green: 128, blue: 128)
        endListLabel.font = UIFont.systemFont(ofSize: 10)
        endListLabel.textAlignment = .center
        endListLabel.isUserInteractionEnabled = true
        endListLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnLabel(_:))))
        
        let attrs1 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor(red: 128, green: 128, blue: 128)]
        let attrs2 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor(red: 59, green: 179, blue: 255)]
        
        let attributedString1 = NSMutableAttributedString(string:"text_end_of_the_list".localized, attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string:"text_back_to_search_result".localized, attributes:attrs2)
        let range = NSMakeRange(0, attributedString2.length)
        attributedString2.addAttribute(NSAttributedString.Key.underlineStyle, value: NSNumber(value:  NSUnderlineStyle.single.rawValue), range: range)
        
        attributedString1.append(attributedString2)
        endListLabel.attributedText = attributedString1
        
        bottomEmptyView.addSubview(endListLabel)
        
        endListLabel.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(bottomEmptyView)
        }
        
        tableView.mj_header = nil
        tableView.mj_footer = SCRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.mj_footer.endRefreshing()
    }
    
    @objc func loadMore() {
        let offset = self.members.count
        
        let extras = TGAppUtil.getUserID(remarkName: keyword)
        TGNewFriendsNetworkManager.searchMyFriend(offset: offset, keyWordString: keyword, extras: extras) {[weak self] userModels, error in
            
            guard let users = userModels, let self = self else {
                DispatchQueue.main.async {
                    self?.tableView.mj_footer.endRefreshingWithWeakNetwork()
                }
                return
            }
            DispatchQueue.main.async {
                if users.count == 0 {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    self.tableView.mj_footer.isHidden = true
                    self.bottomEmptyView.makeVisible()
                    self.bottomEmptyView.snp.makeConstraints { make in
                        make.height.equalTo(60)
                    }
                } else {
                    self.tableView.mj_footer.endRefreshing()
                }
                self.members = self.members + users
                self.tableView.reloadData()

            }
            
            
        }
    }
    
    @objc func handleTapOnLabel(_ recognizer: UITapGestureRecognizer) {
        guard let text = endListLabel.attributedText?.string else {
            return
        }
        
        if let range = text.range(of: "text_back_to_search_result".localized),
           recognizer.didTapAttributedTextInLabel(label: endListLabel, inRange: NSRange(range, in: text)) {
            self.navigationController?.popViewController(animated: true)
        }
    }

}

extension TGIMSearchUserListMoreVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TGUserSearchListMoreCell.identifier) as! TGUserSearchListMoreCell
        
        cell.refreshUser(withUser: members[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let me = NIMSDK.shared().v2LoginService.getLoginUser() else {return}
        let model = members[indexPath.item]
        let conversationId = "\(me)|1|\(model.username)"
        let vc = TGChatViewController(conversationId: conversationId, conversationType: 1)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        guard let attrString = label.attributedText else {
            return false
        }
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        let textStorage = NSTextStorage(attributedString: attrString)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}

