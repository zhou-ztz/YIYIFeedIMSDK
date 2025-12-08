//
//  MessageRequestActionView.swift
//  Yippi
//
//  Created by Kit Foong on 22/02/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class TGMessageRequestActionView: UIView {
    
    var alertButtonClosure: (()->())?
    var cancelButtonClosure: (()->())?
    
    private lazy var alertView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var alertTitle: UILabel = {
        let label = UILabel()
        label.text = "Reject message request"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var alertMessage: UILabel = {
        let label = UILabel()
        label.text = "Are you sure you want to reject LehLeh Hu's request? This action cannot be undone."
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var alertButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reject", for: .normal)
        button.addTarget(self, action: #selector(alertAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, alertButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()

    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .white
        // Add subviews
        addSubview(alertView)
        alertView.addSubview(alertTitle)
        alertView.addSubview(alertMessage)
        alertView.addSubview(buttonStackView)
        
        // Layout constraints using SnapKit
        alertView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalToSuperview().priority(.low)
        }
        
        alertTitle.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().offset(20)
        }
        
        alertMessage.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalTo(alertTitle.snp.bottom).offset(30)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalTo(alertMessage.snp.bottom).offset(30)
            make.bottom.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        alertView.layoutIfNeeded()
    }

    @objc func cancelAction() {
        cancelButtonClosure?()
    }
    
    @objc func alertAction() {
        alertButtonClosure?()
    }
    
    init(isAccept: Bool, isGroup: Bool, name: String) {
        super.init(frame: .zero)
        setupUI(isAccept: isAccept, isGroup: isGroup, name: name)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI(isAccept: false, isGroup: false, name: "")
    }
    
    private func setupUI(isAccept: Bool, isGroup: Bool, name: String) {
        setupUI()
        alertView.frame = self.bounds
        alertView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    
        alertView.roundCorner(10)
        
        cancelButton.applyStyle(.custom(text: "cancel".localized, textColor: RLColor.normal.blackTitle, backgroundColor: RLColor.normal.keyboardTopCutLine, cornerRadius: 10))
        
        if isAccept {
            alertTitle.text = isGroup ? "title_accept_group_request".localized : "title_accept_message_request".localized
            alertMessage.text = isGroup ? String(format:"desc_accept_group_request".localized, name) : String(format: "desc_accept_message_request".localized, name)
            alertButton.applyStyle(.custom(text: "accept_session".localized, textColor: RLColor.main.white, backgroundColor: RLColor.main.red, cornerRadius: 10))
        } else {
            alertTitle.text = isGroup ? "title_reject_group_request".localized : "title_reject_message_request".localized
            alertMessage.text = isGroup ? String(format:"desc_reject_group_request".localized, name) : String(format:"desc_reject_message_request".localized, name)
            alertButton.applyStyle(.custom(text: "reject_session".localized, textColor: RLColor.main.white, backgroundColor: RLColor.main.red, cornerRadius: 10))
        }
    }
}
