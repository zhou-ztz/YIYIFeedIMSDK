//
//  UIViewController+Navigator.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/24.
//

import Foundation
import Combine
import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
