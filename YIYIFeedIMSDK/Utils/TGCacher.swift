//
//  TGCacher.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/8.
//

import UIKit

enum cacheType: Int {
    case video, photo, document
}

class TGCacher: NSObject {
    private(set) var pathComponent: String
    private(set) var cacheType: cacheType?

    init(with pathComponent: String, cacheType: cacheType) {
        self.pathComponent = pathComponent
        self.cacheType = cacheType
    }
    
    static private func rootPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    }
    
    func cacheDir() -> String {
        let path = (TGCacher.rootPath() as NSString).appendingPathComponent(self.pathComponent)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path, isDirectory: nil) == false {
            do {
                try fileManager.createDirectory(atPath: path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                // do nothing
            }
        }
        return path
    }

    func deleteCache(path: String) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path, isDirectory: nil) == true {
            do {
                try fileManager.removeItem(atPath: path)
            } catch {
                throw error
            }
        }
    }
}
