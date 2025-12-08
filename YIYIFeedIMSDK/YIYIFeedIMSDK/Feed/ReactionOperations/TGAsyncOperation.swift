//
//  TGAsyncOperation.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2024/12/31.
//

import Foundation

let backgroundOperationQueue = OperationQueue()

class TGAsyncOperation: Operation, @unchecked Sendable {
    public enum State: String {
        case ready, executing, finished

        fileprivate var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }

    public var state = State.ready {
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
}


extension TGAsyncOperation {

    override var isAsynchronous: Bool {
        return true
    }

    override var isExecuting: Bool {
        return state == .executing
    }

    override var isFinished: Bool {
        return state == .finished
    }

    override func start() {
        if isCancelled {
            return
        }
        main()
        state = .executing
    }
}
