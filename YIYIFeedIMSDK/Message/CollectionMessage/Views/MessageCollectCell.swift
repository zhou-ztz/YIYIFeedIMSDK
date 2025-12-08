//
//  MessageCollectCell.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/8.
//

import UIKit

protocol MessageCollectDelegate: AnyObject{
    func checkBoxClicked(model: FavoriteMsgModel)
}

class MessageCollectCell: UITableViewCell {

    var baseView: UIView = UIView()
    lazy var checkBoxButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ic_checkbox_normal"), for: .normal)
        return btn
    }()
    var lineView: UIView = UIView()
    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        return stackView
    }()
    var msgContentView: BaseCollectView?
    static let cellIdentifier = "MessageCollectCell"
    weak var delegate: MessageCollectDelegate?
    var model: FavoriteMsgModel?
    
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                checkBoxButton.setImage(UIImage(named: "ic_rl_checkbox_selected")?.withRenderingMode(.alwaysOriginal), for: UIControl.State.normal)
            } else {
                checkBoxButton.setImage(UIImage(named: "ic_checkbox_normal"), for: UIControl.State.normal)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
   
    func setUI(){
        self.contentView.addSubview(mainStackView)
        self.contentView.addSubview(lineView)
        self.mainStackView.addArrangedSubview(checkBoxButton)
        self.mainStackView.addArrangedSubview(baseView)
        mainStackView.snp.makeConstraints { make in
            make.left.bottom.top.right.equalToSuperview()
        }
        lineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.right.bottom.equalTo(0)
        }
        checkBoxButton.snp.makeConstraints { make in
            make.height.width.equalTo(20)
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
        }
        baseView.snp.makeConstraints { make in
            make.right.bottom.top.equalTo(0)
        }
        
        lineView.backgroundColor = UIColor(hex: 0xF5F5F5)
        checkBoxButton.setTitle("", for: .normal)
        checkBoxButton.addTarget(self, action: #selector(checkBoxAction), for: .touchUpInside)
        checkBoxButton.imageView?.contentMode = .scaleAspectFit
        checkBoxButton.isHidden = true
        isChecked = false
    }
    
    func dataUpdate(dataModel: FavoriteMsgModel, collectView: BaseCollectView) {
        if self.msgContentView != nil {
            self.msgContentView?.removeFromSuperview()
        }
        self.msgContentView = collectView
        self.baseView.layer.cornerRadius = 4
        self.baseView.layer.masksToBounds = true
        //self.msgContentView?.backgroundColor = .white
        self.baseView.addSubview(self.msgContentView!)
        self.msgContentView!.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(0)
        }
        
        model = dataModel
    }
    
    @objc func checkBoxAction (sender: UIButton){
        isChecked = !isChecked
        delegate?.checkBoxClicked(model: model!)
    }

}
