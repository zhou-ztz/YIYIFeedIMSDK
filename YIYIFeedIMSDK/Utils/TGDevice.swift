//
//  TGDevice.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/16.
//

import Foundation
import UIKit


struct TGDevice {
    static var isLandscape: Bool {
        switch UIDevice.current.orientation {
        case .portrait, .portraitUpsideDown:
            return false
        case .landscapeLeft, .landscapeRight:
            return true
        default:
            return UIScreen.main.bounds.width > UIScreen.main.bounds.height
        }
    }
    
    static var screenOrientation: UIDeviceOrientation {
        if UIScreen.main.bounds.width > UIScreen.main.bounds.height {
            return .landscapeLeft
        } else {
            return .portrait
        }
    }
    
}
