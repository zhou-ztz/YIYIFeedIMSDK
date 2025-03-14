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
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubview(customContentView)
        selectionStyle = .default
        indentationWidth = 10
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        customContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(47) 
        }
    }
    
    // MARK: - Public Methods
    func refreshWidthCilent(_ client: NIMLoginClient) {
        
    }
    
}
