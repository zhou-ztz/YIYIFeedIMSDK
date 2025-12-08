//
//  CollectionTextMsgViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/19.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK


class CollectionTextMsgViewController: TGViewController {

    var favoriteModel: FavoriteMsgModel?
    var collectionMsgCall: deleteCollectionMsgCall?
    
    lazy var scrollView: UIScrollView = {
        let sc = UIScrollView()
        sc.backgroundColor = UIColor(red: 247, green: 247, blue: 247)
        return sc
    }()
    
    lazy var bgView: UIView = {
        let bg = UIView()
        bg.backgroundColor = .white
        return bg
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    init(model: FavoriteMsgModel) {
        self.favoriteModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.backItem.setTitle("title_favourite_msg_details".localized, for: .normal)
        self.setUI()
    }
    
    func setUI(){
        let btn = UIButton()
        btn.setImage(UIImage(named: "buttonsMoreDotBlack"), for: .normal)
        btn.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
        self.customNavigationBar.setRightViews(views: [btn])
        self.backBaseView.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.top.equalTo(12)
            make.width.equalTo(ScreenWidth)
        }
        if let model = self.textForJson(josnStr: self.favoriteModel!.data) {
            contentLabel.text = model.content
        }
        
        bgView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(13)
            make.bottom.equalTo(-13)
            make.width.equalTo(ScreenWidth - 28)
        }
        
        self.view.layer.layoutIfNeeded()
        
        self.scrollView.contentSize = CGSize(width: 0, height: bgView.height + 26)
        
    }

    @objc func moreAction(){

        let items: [IMActionItem] = [.collect_copy, .collect_forward, .collect_delete]

        if (items.count > 0 ) {
            let view = IMActionListView(actions: items)
            view.delegate = self
            
        }
    }
    
    //MARK:
    func textForJson(josnStr: String) -> SessionDictModel? {
        var dictModel: SessionDictModel?
        guard let data = josnStr.data(using: .utf8) else {
            return nil
        }
        do {
            let model = try JSONDecoder().decode(SessionDictModel.self, from: data)
            dictModel = model

        } catch  {
            print("jsonerror = \(error.localizedDescription)")
        }
        return dictModel
    }
    

}

extension CollectionTextMsgViewController: ActionListDelegate {
    func copyTextIM() {
        let pasteboard = UIPasteboard.general
        if let model = self.textForJson(josnStr: self.favoriteModel!.data) {
            pasteboard.string = model.content
        }
        
    }
    
    func forwardTextIM() {
        guard let messageId = self.favoriteModel?.uniqueId else {
            return
        }
        let messageIds: [String] = [messageId]
        let configuration = TGContactsPickerConfig(title: "select_contact".localized, rightButtonTitle: "done".localized, allowMultiSelect: true, enableTeam: true, enableRecent: true, enableRobot: false, maximumSelectCount: maximumSendContactCount, excludeIds: [], members: nil, enableButtons: false, allowSearchForOtherPeople: true)
        
        let picker = TGNewContactPickerViewController(configuration: configuration, finishClosure: { (contacts) in
            
            NIMSDK.shared().v2MessageService.getMessageList(byIds: messageIds) { messages in
                let accountId = NIMSDK.shared().v2LoginService.getLoginUser() ?? ""
                for contact in contacts {
                    for originalMessage in messages {
                        let conversationId = contact.isTeam ? "\(accountId)|2|\(contact.userName)" : "\(accountId)|1|\(contact.userName)"
                        
                        let message = V2NIMMessageCreator.createForwardMessage(originalMessage)
                        NIMSDK.shared().v2MessageService.send(message, conversationId: conversationId, params: nil) { _ in
                            
                        } failure: { _ in
                            
                        }
                    }
                }
                
            }
        })
        self.navigationController?.pushViewController(picker, animated: true)
        
    }
    
    func deleteTextIM() {
        var v2collections = [V2NIMCollection]()
        let collectInfo = V2NIMCollection()
        collectInfo.createTime = self.favoriteModel?.createTime ?? 0
        collectInfo.collectionId = String(self.favoriteModel?.Id ?? 0)
        v2collections.append(collectInfo)
        
        NIMSDK.shared().v2MessageService.remove(v2collections) { [weak self] total in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8 ) {
                self.navigationController?.popViewController(animated: true)
                if let collectMsgCall = self.collectionMsgCall {
                    collectMsgCall!(self.favoriteModel)
                }
                
            }
        } failure: { error in
            
        }
    }
 
}
