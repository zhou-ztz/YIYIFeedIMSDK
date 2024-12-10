import Foundation
import UIKit

enum LabelStyle {
    case bold(size: CGFloat, color: UIColor)
    case semibold(size: CGFloat, color: UIColor)
    case regular(size: CGFloat, color: UIColor)
    case heavy(size: CGFloat, color: UIColor)
}

extension UILabel {
    
    func applyStyle(_ style: LabelStyle, setAdaptive: Bool = false) {
        switch style {
        case let .regular(size, color):
            self.textColor = color
            if setAdaptive == true {
                self.font = UIFont.systemFont(ofSize: size)
            } else {
                self.font = UIFont.systemFont(ofSize: size)
            }
            
            break
        case let .semibold(size, color):
            self.textColor = color
            if setAdaptive == true {
                self.font = UIFont.systemFont(ofSize: size, weight: .semibold)
            } else {
                self.font = UIFont.systemFont(ofSize: size, weight: .semibold)
            }
            break
            
        case let .bold(size, color):
            self.textColor = color
            if setAdaptive == true {
                self.font = UIFont.boldSystemFont(ofSize: size)
            } else {
                self.font = UIFont.boldSystemFont(ofSize: size)
            }
            break

        case let .heavy(size, color):
            self.textColor = color
            if setAdaptive == true {
                self.font = UIFont.systemFont(ofSize: size, weight: .heavy)
            } else {
                self.font = UIFont.systemFont(ofSize: size, weight: .heavy)
            }
            break
        }
    }
}
