//
//  RegexParser.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 06/01/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

struct RegexParser {

    static let hashtagPattern = "(?<=^|\\s|$)#[\\p{L}\\p{Nd}_\\p{P}\\p{Emoji}]*"
    static let mentionPattern = "\\u00ad@((?:[^/]+?))\\u00ad"
    static let urlPattern = #"(https?:\/\/[^\s]+|www\.[^\s]+)"#
    
    private static var cachedRegularExpressions: [String : NSRegularExpression] = [:]

    static func getElements(from text: String, with pattern: String, range: NSRange) -> [NSTextCheckingResult]{
        guard let elementRegex = regularExpression(for: pattern) else { return [] }
        return elementRegex.matches(in: text, options: [], range: range)
    }

    private static func regularExpression(for pattern: String) -> NSRegularExpression? {
        if let regex = cachedRegularExpressions[pattern] {
            return regex
        } else if let createdRegex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
            cachedRegularExpressions[pattern] = createdRegex
            return createdRegex
        } else {
            return nil
        }
    }
}
