//
//  TGNTESMutiClientsCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/3/12.
//

import UIKit
import NIMSDK

class TGNTESMutiClientsCell: UITableViewCell {

    // MARK: - UI Components
    private lazy var customContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        //setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        self.textLabel?.font = UIFont.systemFont(ofSize: 17)
        self.textLabel?.textColor = UIColor(hex: 0x333333)
        //contentView.addSubview(customContentView)
        selectionStyle = .none
       // indentationWidth = 10
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        customContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(47) 
        }
    }
    
    // MARK: - Public Methods
    func refreshWidthCilent(_ client: V2NIMLoginClient) {
        let name = clientName(clientType: client.type)
        self.textLabel?.text = String(format: "multiport_logged_in".localized, name)
    }
    
    func clientName(clientType: V2NIMLoginClientType) -> String {
        var name: String = ""
        switch clientType {
        case .LOGIN_CLIENT_TYPE_ANDROID, .LOGIN_CLIENT_TYPE_HARMONY_OS, .LOGIN_CLIENT_TYPE_IOS, .LOGIN_CLIENT_TYPE_WINPHONE:
            name = "rw_mobile_version".localized
            break
        case .LOGIN_CLIENT_TYPE_PC, .LOGIN_CLIENT_TYPE_MAC_OS:
            name = "computer_version".localized
            break
        case .LOGIN_CLIENT_TYPE_WEB:
            name = "rw_multiport_screen_label".localized
            break
        default:
            name = "rw_mobile_version".localized
            break
        }
        return name
    }
   
}
