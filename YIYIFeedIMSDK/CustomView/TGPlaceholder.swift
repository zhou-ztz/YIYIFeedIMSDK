//
//  TGPlaceholder.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/14.
//

import UIKit

/// 占位图类型
enum PlaceholderViewType: Equatable {
    /// 网络请求失败
    case network
    
    case networkWithRetry
    /// 数据为空
    case empty
    
    /// 动态被删除或者过期
    case removed
    
    case needLocationAccess
    
    case emptyResult
    
    case custom(image: UIImage?, text: String?)
    
    case customWithButton(image: UIImage?, text: String, buttonText: String?)
    
    case emptyChat
    
    case serverError
    //系统维护
    case serverUnavailable
    
    case contentRemoved
    
    case websiteError
    
    case noComment
    
    case imEmpty
    
    case teenMode
    
    case noVoucher
    
    case noReferral
    
    case noPlatformVoucher
    
    case noRegister
    
    case nothingYet
    
    case noSearchVoucher
    
    var content: (image: UIImage?, text: String?, content: String?) {
        switch self {
        case .network, .networkWithRetry:
            return (UIImage(named: "placeholder_no_internet"), "rw_error_title_no_internet".localized, "rw_error_message_no_internet".localized)
        case .empty:
            return (UIImage(named: "placeholder_no_result"), "rw_error_title_no_content_found".localized, "")
        case .removed:
            return (UIImage(named: "placeholder_no_result"), "rw_error_title_no_content_found".localized, "rw_content_removed_or_deleted_message".localized)
            
        case .needLocationAccess:
            return (UIImage(named: "placeholder_location"), "placeholder_locationaccess_error".localized, "")
        case .emptyResult:
            return (UIImage(named: "placeholder_no_result"), "rw_error_title_no_result_found".localized, "rw_error_message_no_result_found".localized)
        case .emptyChat:
            return (UIImage(named: "placeholder_no_message"), "rw_error_title_no_message".localized, "rw_error_message_no_message".localized)
        case .serverError:
            return (UIImage(named: "reward_link_404"), "rw_error_title_something_wrong".localized, "rw_error_message_something_wrong".localized)
        case .serverUnavailable:
            return (UIImage(named: "maintenance"), "rw_error_title_maintenance".localized, "rw_error_message_maintenance".localized)
        case .contentRemoved:
            return (UIImage(named: "placeholder_no_result"), "reward_link_empty_list".localized, "")
        case .websiteError:
            return (UIImage(named: "placeholder_no_internet"), "text_invalid_web_url".localized, "")
        case .teenMode:
            return (UIImage(named: "placeholder_no_result"), "teen_mode_placeholder_msg".localized, "")
        case .noVoucher:
            return (UIImage(named: "placeholder_no_result"), "rw_no_voucher_placeholder_msg".localized, "")
        case .noReferral:
            return (UIImage(named: "placeholder_no_result"), "rw_error_title_no_one_here".localized, "rw_error_message_referral".localized)
        case .custom(let image, let text):
            return (image, text, "")
        case let .customWithButton(image, text, _ ):
            return (image, text, "")
        case .noComment:
            return (UIImage(), "rw_no_comments_yet".localized, "rw_be_first_comment".localized)
        case .imEmpty:
            return (UIImage(named: "placeholder_chat_empty"), "rw_text_say_hi_to_new_friend".localized, "")
        case .noPlatformVoucher:
            return (UIImage(named: "ic_voucher_placeholder_empty"), "rw_no_voucher_placeholder_msg".localized, "rw_no_voucher_placeholder_desc_msg".localized)
        case .noRegister:
            return (UIImage(named: "placeholder_no_result"), "rw_text_refer_empty_description".localized, "")
            
        case .nothingYet:
            return (UIImage(named: "placeholder_no_result"), "rw_text_nothing_here_yet".localized, "")
            
        case .noSearchVoucher:
            return (UIImage(named: "ic_voucher_placeholder_empty"), "rw_error_title_no_result_found".localized, "rw_error_message_no_result_found".localized)
           
        }
    }
    
    var buttonText: String? {
        switch self {
        case .customWithButton(_, _, let buttonText):
            return buttonText
        case .needLocationAccess:
            return "placeholder_locationaccess_button".localized
        case .serverError:
            return "retry".localized
        case .networkWithRetry, .network:
            return "rw_refresh".localized
        case .teenMode:
            return "teen_mode_placeholder_turn_off_teen_mode".localized
        default:
            return nil
        }
    }
}

class TGPlaceholder: UIView {

    private lazy var container: UIView = UIView().configure {
        $0.backgroundColor = .clear
    }
    
    private lazy var stackView = UIStackView().configure {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 16
    }
    
    private lazy var placeholderImageView = UIImageView().configure {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var placeholderLabel = UILabel().configure {
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.textColor = UIColor(red: 0.141, green: 0.141, blue: 0.142, alpha: 1)
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    private lazy var contentLabel = UILabel().configure {
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.textColor = UIColor(red: 0.141, green: 0.141, blue: 0.142, alpha: 1)
        $0.font = UIFont.systemRegularFont(ofSize: 12)
    }
    
    private lazy var button = UIButton()
    
    var onTapActionButton: TGEmptyClosure?
    var theme: Theme = .white {
        didSet {
            if let customColor = customBackgroundColor {
                backgroundColor = customColor
                return
            }
            switch theme {
            case .dark:
                backgroundColor = TGAppTheme.materialBlack
            default:
                backgroundColor = .white
            }
        }
    }
    
    var customBackgroundColor: UIColor? = nil
    var type: PlaceholderViewType?
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        self.addSubview(container)
        container.addSubview(stackView)
        container.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-30)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        stackView.addArrangedSubview(placeholderImageView)
        stackView.addArrangedSubview(placeholderLabel)
        stackView.addArrangedSubview(contentLabel)
        
        stackView.bindToEdges()
        
        placeholderImageView.snp.makeConstraints {
            $0.height.equalTo(240)
            $0.width.equalTo(200)
        }
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ type: PlaceholderViewType) {
        self.type = type
        placeholderImageView.image = type.content.image
        placeholderLabel.text = type.content.text
        contentLabel.text = type.content.content
        
        switch type {
        case .needLocationAccess, .networkWithRetry, .customWithButton, .serverError, .network, .teenMode:
            if button.superview == nil {
                let buttonTitle : String = type.buttonText ?? ""
                
                let buttonHeight = Int(round(buttonTitle.heightOfString(usingFont: UIFont.boldSystemFont(ofSize: 14)))) + 10
                let buttonWidth = Int(round(buttonTitle.widthOfString(usingFont: UIFont.boldSystemFont(ofSize: 14)))) + 10
                      
                stackView.addArrangedSubview(button)
                button.snp.makeConstraints {
                    $0.height.equalTo(buttonHeight)
                    $0.width.equalTo(buttonWidth)
                }
                button.addAction {
                    self.onTapActionButton?()
                }
                button.setTitle(type.buttonText, for: .normal)

                switch type {
                case .customWithButton:
                    button.setBackgroundColor(TGAppTheme.dodgerBlue, for: .normal)
                    button.setTitleColor(.white, for: .normal)
                    button.roundCorner(20)
                default:
                    button.setTitleColor(UIColor(red: 0.929, green: 0.102, blue: 0.231, alpha: 1), for: .normal)
                    button.set(font: UIFont.boldSystemFont(ofSize: 14), cornerRadius: 8, borderWidth: 1, borderColor: UIColor(red: 0.929, green: 0.102, blue: 0.231, alpha: 1))
                }
            }
        case .imEmpty:
            placeholderLabel.font =  UIFont.systemFont(ofSize: 16, weight: .regular)
        default:
            button.removeFromSuperview()
            break
        }
    }

}

extension UIButton {

    func set(title: String?, titleColor: UIColor, image: UIImage? = nil, bgImage: UIImage? = nil, for state: UIControl.State) -> Void {
        self.setTitle(title, for: state)
        self.setTitleColor(titleColor, for: state)
        self.setImage(image, for: state)
        self.setBackgroundImage(bgImage, for: state)
    }

    func set(font: UIFont?, cornerRadius: CGFloat = 0, borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.clear) -> Void {
        if let font = font {
            self.titleLabel?.font = font
        }
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        // 图片拉伸样式设置
        self.contentMode = .scaleAspectFill
    }
}
