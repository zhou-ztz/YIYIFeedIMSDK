//
//  Then.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司 on 2023/12/19.
//

import Foundation
import UIKit

protocol Then {}

extension Then {
    @discardableResult
    public func configure(_ block: (inout Self) -> Void) -> Self {
        var copy = self
        block(&copy)
        return copy
    }

    @discardableResult
    public func build(_ block: (inout Self) -> Void) -> Self {
        var copy = self
        block(&copy)
        return copy
    }
    
}

extension NSObject: Then {}
extension UIView: Then {}
