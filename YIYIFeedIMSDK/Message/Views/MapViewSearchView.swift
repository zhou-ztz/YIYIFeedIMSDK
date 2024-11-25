//
//  MapViewSearchView.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/15.
//

import UIKit
protocol MapViewSearchViewDelegate: AnyObject {
    
    func textFieldDidChangeWith(textField: UITextField)
    func textFieldDidFinish(textField: UITextField)
    func textFieldDidCancel()
    func textFieldbeginEditing()
}
class MapViewSearchView: UIView, UITextFieldDelegate {
    
    weak var delegate: MapViewSearchViewDelegate?
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 12
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    
    lazy var textField: UITextField = {
        let textfield = UITextField()
        textfield.font = UIFont.systemFont(ofSize: 14)
        textfield.textColor = RLColor.share.black3
        textfield.placeholder = "搜索"
        return textfield
    }()
    
    lazy var  searchBtn: UIButton = {
        let btn = UIButton()
       
        return btn
    }()
    
    lazy var  cancelBtn: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.setTitleColor(RLColor.share.lightGray, for: .normal)
        btn.setTitle("取消", for: .normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI(){
        self.textField.layer.cornerRadius = 16
        self.textField.clipsToBounds = true
        textField.layer.borderColor = RLColor.share.lightGray.cgColor
        textField.layer.borderWidth = 1
        self.backgroundColor = .white
        self.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.bottom.equalTo(0)
        }
        
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(cancelBtn)
        cancelBtn.isHidden = true
        searchBtn.layer.cornerRadius = 4
        searchBtn.clipsToBounds = true
        searchBtn.backgroundColor = .clear
        searchBtn.setImage(UIImage(named: "iconsSearchGrey"), for: .normal)
        searchBtn.frame = CGRect(x: 10, y: 0, width: 30, height: 30)
        let leView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        leView.addSubview(searchBtn)
        textField.leftView = leView
        textField.leftViewMode = .always
        
        textField.snp.makeConstraints { make in
            make.top.left.bottom.equalTo(0)
        }
        
        textField.returnKeyType = .search
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
    }
    
    @objc func cancelAction(){
        self.textField.text = ""
        self.textField.resignFirstResponder()
        cancelBtn.isHidden = true
        self.delegate?.textFieldDidCancel()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField){
       
        self.delegate?.textFieldDidChangeWith(textField: textField)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        cancelBtn.isHidden = false
        self.delegate?.textFieldbeginEditing()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.text = ""
        self.textField.resignFirstResponder()
        cancelBtn.isHidden = true
        self.delegate?.textFieldDidFinish(textField: textField)
        return true
    }
}

