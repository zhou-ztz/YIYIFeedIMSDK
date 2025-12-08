//
//  OperationItem.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/25.
//

import UIKit

enum OperationType: Int {
    case copy = 1 //复制
    case reply //回复
    case forward //转发
    case pin //置顶
    case removePin // 取消置顶
    case collection // 收藏
    case delete // 删除
    case recall //撤销
}

class OperationItem: NSObject {

    var text: String = ""
    var imageName: String = ""
    var type: OperationType?
    
    static func copyItem() -> OperationItem {
        let item = OperationItem()
        item.text = "复制"
        item.imageName = "op_copy"
        item.type = .copy
        return item
    }
    
    static func replayItem() -> OperationItem {
        let item = OperationItem()
        item.text = "回复"
        item.imageName = "op_replay"
        item.type = .reply
        return item
    }
    
    static func forwardItem() -> OperationItem {
        let item = OperationItem()
        item.text = "转发"
        item.imageName = "op_forward"
        item.type = .forward
        return item
    }
    
    static func pinItem() -> OperationItem {
        let item = OperationItem()
        item.text = "置顶"
        item.imageName = "op_pin"
        item.type = .pin
        return item
    }
    
    static func removePinItem() -> OperationItem {
        let item = OperationItem()
        item.text = "取消置顶"
        item.imageName = "op_pin"
        item.type = .removePin
        return item
    }
    
    public static func deleteItem() -> OperationItem {
        let item = OperationItem()
        item.text = "删除"
        item.imageName = "op_delete"
        item.type = .delete
        return item
    }
    
    public static func recallItem() -> OperationItem {
        let item = OperationItem()
        item.text = "撤销"
        item.imageName = "op_recall"
        item.type = .recall
        return item
    }
}
