//
//  FileUtils.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司 on 2024/1/9.
//

import Foundation
import UIKit
import AVFoundation

class FileUtils {

    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    //录制时的配置路径
    static func videoTaskDir() -> String {
        let path = (rootPath() as NSString).appendingPathComponent("task")
        try? deleteCache(path: path)
        return path
    }

    //删除单个文件
    static func deleteCache(path: String) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path, isDirectory: nil) == true {
            do {
                try fileManager.removeItem(atPath: path)
            } catch {
                throw error
            }
        }
    }
    static func generateAVAssetVideoCoverImage(avAsset:AVAsset) -> UIImage? {
        let imgGenerator = AVAssetImageGenerator(asset: avAsset)
        imgGenerator.appliesPreferredTrackTransform = true
        imgGenerator.apertureMode = .productionAperture
        do {
            let cgImage = try imgGenerator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            return nil
        }
    }
    static private func videoCacheDir() -> String {
        let path = (rootPath() as NSString).appendingPathComponent("com.scapp.cache")
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
    
    //录制视频的保存地址
    static func videoRecordCachePath() -> String {
        let path = ((videoCacheDir() as NSString).appendingPathComponent(fileName()) as NSString).appendingPathExtension("mp4")!
        try? deleteCache(path: path)
        return path
    }
    

    static private func rootPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    }

    static func fileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return dateFormatter.string(from: Date())
    }
}
