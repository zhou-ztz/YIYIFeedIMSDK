//
//  TGIMSessionHistoryViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/25.
//

import UIKit

class TGIMSessionHistoryViewController: TGChatViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func loadData() {
        var dataList: [TGMessageData] = []
        var dataList2: [TGMessageData] = []
        let group = DispatchGroup()
        group.enter()
        self.viewmodel.getHistoryMessage(order: .QUERY_DIRECTION_ASC, message: viewmodel.anchor) { [weak self] error, count, messageList in
            if messageList.count > 0 , let self = self {
                let datas = messageList.compactMap { TGMessageData($0) }
                let newDatas = self.viewmodel.processTimeData(datas)
                dataList = newDatas
            }
            group.leave()
        }
        
        group.enter()
        self.viewmodel.getHistoryMessage(order: .QUERY_DIRECTION_DESC, message: viewmodel.anchor) { [weak self] error, count, messageList in
            if messageList.count > 0 , let self = self {
                let datas = messageList.reversed().compactMap { TGMessageData($0) }
                let newDatas = self.viewmodel.processTimeData(datas)
                dataList2 = newDatas
            }
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) { [weak self] in
            if let self = self, let msg = self.viewmodel.anchor {
                let data = TGMessageData(msg)
                self.viewmodel.messages.insert(contentsOf: dataList, at: 0)
                self.viewmodel.messages.insert(data, at: 0)
                self.viewmodel.messages.insert(contentsOf: dataList2, at: 0)
                
                self.viewmodel.handleMultiImageMessage()
                self.tableView.reloadData()
                if let indexPath = viewmodel.getIndexPathForMessageClientId(messageClientId: msg.messageClientId ?? "") {
                    self.scrollToMessage(by: indexPath, animation: true)
                }
                self.viewmodel.oldMsg = self.viewmodel.messages.first?.nimMessageModel
            }
        }
    }

}
