//
//  Array+Extension.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2024/12/25.
//

import Foundation

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
    
    func removingDuplicates<T: Equatable>(byKey key: KeyPath<Element, T>)  -> [Element] {
        var result = [Element]()
        var seen = [T]()
        for value in self {
            let key = value[keyPath: key]
            if !seen.contains(key) {
                seen.append(key)
                result.append(value)
            }
        }
        return result
    }
}

extension Array where Element == String {
    func containsIgnoringCase(_ element: Element) -> Bool {
        contains { $0.caseInsensitiveCompare(element) == .orderedSame }
    }
}

extension Array {
    /// 将数组转为 字符串
    ///
    /// - Note:
    ///     - 例如:[1,2,3] -> "1,2,3"
    ///     - 返回的字符串均以`,`分割,且末尾带字符
    /// - Warning: 只允许在和服务器通讯时,使用此类字符串
    func convertToString() -> String? {
        if self.isEmpty {
            return nil
        }
        var tempArray: Array<String> = [String]()
        for number in self {
            tempArray.append("\(number)")
        }
        return tempArray.joined(separator: ",")
    }
}

public extension Array {
    func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key:Element] {
        var dict = [Key:Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}
