//
//  TGPTableViewCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/13.
//

import UIKit

typealias DataCollectionDict = (timer: Timer, indexPath: IndexPath, itemId: Int, startTime: Int)

protocol BaseCellProtocol {
    static var cellIdentifier: String { get }
    static func nib() -> UINib
}

extension BaseCellProtocol {
    static var cellIdentifier: String {
        return String(describing: Self.self)
    }
    
    static func nib() -> UINib {
        return UINib(nibName: cellIdentifier, bundle: nil)
    }
}

class TGPTableViewCell: UITableViewCell, BaseCellProtocol {
    var indexPath: IndexPath?
    static var timerDictionary: [IndexPath: DataCollectionDict] = [:]
    
    func getCurrentTime() -> Int {
        return Date().timeStamp.toInt()
    }
    
    func viewStayEvent(indexPath: IndexPath, itemId: Int) {

    }
    
    func stopStayEvent(indexPath: IndexPath) {
        
    }
}
