
// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
@objc protocol InputEmoticonTabViewDelegate: NSObjectProtocol {
    @objc optional func tabView(_ tabView: TGInputEmoticonTabView?, didSelectTabIndex index: Int)
}

class TGInputEmoticonTabView: UIControl {
    weak var delegate: InputEmoticonTabViewDelegate?
    private var tabs = [UIButton]()
    private var seps = [UIView]()
    private var className = "TGInputEmoticonTabView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpSubViews() {
        addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            sendButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            sendButton.rightAnchor.constraint(equalTo: rightAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            sendButton.heightAnchor.constraint(equalToConstant: 32),
        ])
    }
    
    func selectTabIndex(_ index: Int) {
        for i in 0 ..< tabs.count {
            let btn = tabs[i]
            btn.isSelected = i == index
        }
    }
    
    func loadCatalogs(_ emoticonCatalogs: [NIMInputEmoticonCatalog]?) {
        tabs.forEach { btn in
            btn.removeFromSuperview()
        }
        seps.forEach { view in
            view.removeFromSuperview()
        }
        tabs.removeAll()
        seps.removeAll()
        
        guard let catalogs = emoticonCatalogs else {
            return
        }
        catalogs.forEach { catelog in
            let button = UIButton()
            button.addTarget(self, action: #selector(onTouchTab), for: .touchUpInside)
            button.sizeToFit()
            self.addSubview(button)
            tabs.append(button)
            
            let sep = UIView(frame: CGRect(x: 0, y: 0, width: 0.5, height: 35))
            sep.backgroundColor = RLColor.share.backGroundGray
            seps.append(sep)
            self.addSubview(sep)
        }
    }
    
    @objc func onTouchTab(sender: UIButton) {
        if let index = tabs.firstIndex(of: sender) {
            selectTabIndex(index)
            delegate?.tabView?(self, didSelectTabIndex: index)
        }
    }
    
    // MARK: lazy method
    
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("发送", for: .normal)
        button.titleLabel?.textColor = .white
        button.backgroundColor = RLColor.share.theme
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }()
}
