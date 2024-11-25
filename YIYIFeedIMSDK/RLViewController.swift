//
//  RLViewController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/22.
//

import UIKit
import SDWebImage
import NEMeetingKit
import NIMSDK
import SnapKit
import IQKeyboardManagerSwift


class RLViewController: UIViewController {

    var customNavigationBar :SCCustomNavigationBar!
    var backBaseView = UIView()
    lazy var allStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    var isHiddenNavigaBar: Bool = false {
        didSet {
            customNavigationBar.isHidden = isHiddenNavigaBar
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        setupIQKeyboardManager()
        setNavigationBar()
    }
    
    func setNavigationBar(){
        customNavigationBar = SCCustomNavigationBar(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: TSNavigationBarHeight + 44))
        view.addSubview(allStackView)
        allStackView.bindToEdges()
        allStackView.addArrangedSubview(customNavigationBar)
        allStackView.addArrangedSubview(backBaseView)
        customNavigationBar.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(TSNavigationBarHeight)
        }
        backBaseView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        backBaseView.setNeedsLayout()
        backBaseView.layoutIfNeeded()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        customNavigationBar.backItem.addTarget(self, action: #selector(backAtcion), for: .touchUpInside)
    }
    
    
    func setupIQKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }

    @objc func backAtcion(){
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        print("\(self) will deinit")
    }
    


}
