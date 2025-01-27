//
//  TGGroupInfoEditViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/21.
//

import UIKit
import NIMSDK

enum GroupInfoEditType: Int {
        case name = 0
        case description
        case nickname
}

class TGGroupInfoEditViewController: TGViewController {
    
    lazy var charLimitLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor(hexString: "#9a9a9a")
        lab.font = UIFont.systemFont(ofSize: 11)
        return lab
    }()
    var editTextView: UITextView = {
        let textview = UITextView()
        textview.font = UIFont.systemFont(ofSize: 16)
        return textview
    }()
    lazy var editInfoView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    lazy var footerLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor(hexString: "#9a9a9a")
        lab.font = UIFont.systemFont(ofSize: 13)
        return lab
    }()
    
    private var canEdit: Bool = false
    private var textLimit: Int = 25
    private var editType: GroupInfoEditType = .name
    private var textToDisplay: String = ""
   // private var loadingAlert: TSIndicatorWindowTop?
    private var hideKeyboardGesture: UITapGestureRecognizer!
    
    var viewmodel: TeamDetailViewModel
    
    var onReloadUI: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        self.backBaseView.backgroundColor = RLColor.inconspicuous.background
        self.backBaseView.addSubview(editInfoView)
        self.backBaseView.addSubview(footerLabel)
        self.editInfoView.addSubview(editTextView)
        self.editInfoView.addSubview(charLimitLabel)
        editInfoView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(20)
            make.height.greaterThanOrEqualTo(50)
        }
        
        footerLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(editInfoView.snp.bottom).offset(10)
        }
        
        charLimitLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(16)
            make.right.equalTo(-10)
        }
        //editTextView.backgroundColor = .red
        editTextView.snp.makeConstraints { make in
            make.left.equalTo(13)
            make.right.equalTo(-50)
            make.top.bottom.equalToSuperview().inset(10)
        }
        
        
        hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserver()
    }
   
    init(editType: GroupInfoEditType, editText: String, canEdit: Bool, viewmodel: TeamDetailViewModel) {
        self.textToDisplay = editText
        self.editType = editType
        self.canEdit = canEdit
        self.viewmodel = viewmodel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        switch editType {
        case .name:
            textLimit = 25
            self.customNavigationBar.backItem.setTitle("group_name".localized, for: .normal)
            setPlaceholder(placeHolder: "team_settings_set_name".localized)
            break
        case .nickname:
            textLimit = 32
            setCloseButton(backImage: true, titleStr: "group_introduce".localized)
            setPlaceholder(placeHolder: "group_nickname".localized)
            break
        case .description:
            textLimit = 150
            self.customNavigationBar.backItem.setTitle("group_introduce".localized, for: .normal)
            setPlaceholder(placeHolder: "team_introduce_hint".localized)
            break
        }
        
        editTextView.textColor = textToDisplay.isEmpty ? .lightGray : .black
        //editTextView.sizeToFit()
        charLimitLabel.text = "\(textLimit - (textToDisplay.count))"
        editTextView.delegate = self
        
        charLimitLabel.isHidden = true
        editTextView.isEditable = false
        editTextView.isSelectable = false
        //charLimitLabelWidth.constant = 0
        if canEdit {
            self.setupRightBarButton()
            charLimitLabel.isHidden = false
            editTextView.isEditable = true
            editTextView.isSelectable = true
           // charLimitLabelWidth.constant = 30
        } else {
            footerLabel.text = "group_creator_or_admin_edit_description".localized
            footerLabel.sizeToFit()
            footerLabel.isHidden = false
        }
        
        if canEdit && textToDisplay != "" {
            self.customNavigationBar.backItem.setTitle("edit".localized, for: .normal)
        }
        helperCallback()
    }
    
    private func setupRightBarButton() {
        let rightBtn = UIButton()
        rightBtn.setTitle("save".localized, for: .normal)
        rightBtn.setTitleColor(.black, for: .normal)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        rightBtn.addTarget(self, action: #selector(saveInfo), for: .touchUpInside)
        self.customNavigationBar.setRightViews(views: [rightBtn])
    }

    @objc func saveInfo() {
        var currentText = editTextView.text ?? ""
        
        if editTextView.textColor == .lightGray {
            currentText = ""
        }
        
        switch editType {
        case .name:
            viewmodel.updateTeamName(currentText)
            if !currentText.isEmpty {
                self.perform(#selector(self.dismissView), afterDelay: 0.8)
            }
            break
        case .nickname:
            viewmodel.updateUserNickname(currentText)
            self.perform(#selector(self.dismissView), afterDelay: 0.8)
            break
        case .description:
            viewmodel.updateTeamIntro(currentText)
            self.perform(#selector(self.dismissView), afterDelay: 0.8)
            
            break
        }
    }
    
    private func helperCallback() {
        viewmodel.onShowSuccess = {[weak self] msg in
            self?.showSuccess(msg)
            self?.onReloadUI?()
        }
        
        viewmodel.onShowFail = {[weak self] msg in
            self?.showFail(msg)
        }
    }
    
    private func showFail(_ msg: String? = nil) {
//        loadingAlert = TSIndicatorWindowTop(state: .faild, title: msg ?? "error_tips_fail".localized)
//        loadingAlert?.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
    
    private func showSuccess(_ msg: String? = nil) {
//        loadingAlert = TSIndicatorWindowTop(state: .success, title: msg ?? "change_success".localized)
//        loadingAlert?.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
    
    private func setPlaceholder (placeHolder: String) {
        if textToDisplay.isEmpty && canEdit {
            editTextView.text = placeHolder
        } else if textToDisplay.isEmpty && !canEdit {
            editTextView.text = "not_set_content".localized
        } else {
            editTextView.text = textToDisplay
        }
    }
    
    @objc private func dismissView() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - keyboard
    @objc private func hideKeyboard() {
        editTextView.resignFirstResponder()
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        self.view.addGestureRecognizer(hideKeyboardGesture)
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        self.view.removeGestureRecognizer(hideKeyboardGesture)
    }
}

extension TGGroupInfoEditViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        let charCount = textLimit - (updatedText.count)
        if charCount >= 0 {
            charLimitLabel.text = "\(charCount)"
        }
        return updatedText.count <= textLimit
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            switch editType {
            case .name:
                textView.text = "team_settings_set_name".localized
                break
            case .nickname:
                textView.text = "group_nickname".localized
                break
            case .description:
                textView.text = "team_introduce_hint".localized
                break
            }
            textView.textColor = .lightGray
        }
        
    }

}
