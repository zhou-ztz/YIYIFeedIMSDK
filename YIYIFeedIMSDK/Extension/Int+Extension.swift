//
//  Int+Extension.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/17.
//

import Foundation

extension Int {
    /// 毫秒 转 00:00 时长格式
    func millisecondsToDuratioFormat() -> String {
        var time = ""
        let s = self / 1000
        let min = s / 60
        let ss = s % 60
        time = String(format: "%02ld:%02ld", min, ss)
        return time
    }
    
    
}

extension Int64 {
    /// long long文件大小 转格式
    func fileSizeString() -> String {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useBytes, .useKB, .useMB] 
        byteCountFormatter.countStyle = .file

        return byteCountFormatter.string(fromByteCount: self)
    }
}
