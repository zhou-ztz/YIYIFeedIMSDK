//
//  TGCreateGroupViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/17.
//

import UIKit
import NIMSDK

let maximumGroupNameLength = 25

class TGCreateGroupViewController: TGViewController {
    
    ///选中的数据
    var choosedDataSource: [ContactData] = []
    var members: [String] = []
    var finishBlock: ((String, String) -> Void)?
    
    let headView = UIView()
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(TGCreateGroupCell.self, forCellReuseIdentifier: "TGCreateGroupCell")
        table.separatorStyle = .none
        table.backgroundColor = .white
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        table.tableHeaderView = UIView()
        return table
    }()
    lazy var headImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.backgroundColor = UIColor(hex: "#EBEBEB")
        return imageview
    }()
    
    lazy var cameraImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFit
        imageview.image = UIImage(named: "camera_group")
        return imageview
    }()
    
    lazy var nameT: UITextField = {
        let textfield = UITextField()
        textfield.font = UIFont.systemRegularFont(ofSize: 14)
        textfield.placeholder = "chat_set_group_name".localized
        return textfield
    }()
    
    var rightBtn: UIButton!
    
    let countLabel = UILabel()
    let memberL = UILabel()
    let titelL = UILabel()
    var containText: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getMembers()
    }
    
    func rightButtonEnable(enable: Bool) {
        self.rightBtn?.isEnabled = enable
        self.rightBtn?.setTitleColor(enable ? RLColor.main.theme : RLColor.normal.disabled, for: UIControl.State.normal)
    }
    
    func setupUI() {
        rightBtn = UIButton()
        rightBtn.setTitle("btn_create".localized, for: .normal)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        rightBtn.addTarget(self, action: #selector(rightBtnAction), for: .touchUpInside)
        self.rightButtonEnable(enable: false)
        backBaseView.backgroundColor = RLColor.inconspicuous.background
        self.customNavigationBar.setRightViews(views: [rightBtn])
        
        
        titelL.textColor = UIColor(hexString: "#9a9a9a")
        titelL.font = UIFont.systemRegularFont(ofSize: 13)
        titelL.textAlignment = .left
        titelL.text = "title_create_group_header".localized
        self.backBaseView.addSubview(titelL)
        titelL.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.equalTo(15)
        }
        
        headView.backgroundColor = .white
//        headView.layer.cornerRadius = 10
//        headView.clipsToBounds = true
        self.backBaseView.addSubview(headView)
        headView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(titelL.snp.bottom).offset(5)
            make.height.equalTo(85)
        }
        headView.addSubview(headImageView)
        headImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(25)
            make.height.width.equalTo(45)
        }
        headImageView.layer.cornerRadius = 22.5
        headImageView.clipsToBounds = true
        headImageView.isUserInteractionEnabled = true
        headImageView.addAction { [weak self] in
            self?.nameT.resignFirstResponder()
        }
        headImageView.addSubview(cameraImageView)
        cameraImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(20)
        }
        
        headView.addSubview(nameT)
        nameT.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(headImageView.snp.right).offset(15)
            make.height.width.equalTo(45)
            make.right.equalTo(-50)
        }
        
        countLabel.textAlignment = NSTextAlignment.right
        countLabel.textColor = UIColor(hexString: "#9a9a9a")
        countLabel.text = String(maximumGroupNameLength)
        headView.addSubview(countLabel)
        countLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(5)
            make.width.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
        
        memberL.textColor = UIColor(hexString: "#9a9a9a")
        memberL.font = UIFont.systemRegularFont(ofSize: 13)
        memberL.textAlignment = .left
        memberL.text = "\(choosedDataSource.count)" + "members".localized
        self.backBaseView.addSubview(memberL)
        memberL.snp.makeConstraints { make in
            make.top.equalTo(headView.snp.bottom).offset(5)
            make.left.equalTo(15)
        }

        self.backBaseView.addSubview(self.tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(memberL.snp.bottom).offset(5)
            make.left.right.bottom.equalTo(0)
        }
        nameT.delegate = self
        nameT.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
    }
    
    func groupIconDidTapped() {
        AuthorizeStatusUtils.checkAuthorizeStatusByType(type: .cameraAlbum, viewController: self, completion: {
            DispatchQueue.main.async {
               // self.openCamera()
            }
        })
    }

    func getMembers() {
        members.append(NIMSDK.shared().v2LoginService.getLoginUser() ?? "")
        for model in choosedDataSource {
            members.append(model.userName)
        }
    }
    
    @objc func rightBtnAction() {
        createGroup()
    }
    
    func openCamera() {
        func showImagePicker(type: UIImagePickerController.SourceType, alert: TGAlertController) {
            alert.dismiss(animated: true, completion: {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = type
                picker.allowsEditing = true
                self.present(picker, animated: true, completion: nil)
            })
        }
        
        let alert = TGAlertController(title: nil, message: "set_group_avatar".localized, style: .actionsheet, sheetCancelTitle: "cancel".localized)
        
        alert.addAction(TGAlertAction(title: "choose_from_camera".localized, style: TGAlertSheetActionStyle.default, handler: { _ in
            showImagePicker(type: .camera, alert: alert)
        }))
        
        alert.addAction(TGAlertAction(title: "choose_from_photo".localized, style: TGAlertSheetActionStyle.default, handler: { _ in
            showImagePicker(type: .photoLibrary, alert: alert)
        }))
        
        self.presentPopup(alert: alert)
        
    }
    func showFail(text: String) {
//        let loadingAlert = TSIndicatorWindowTop(state: .faild, title: text)
//        loadingAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
    //创建群组
    func createGroup(){
        
       // loader.show()
        let option = V2NIMCreateTeamParams()
        option.name       = self.nameT.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        option.teamType   = .TEAM_TYPE_NORMAL
        option.joinMode   = .TEAM_JOIN_MODE_FREE
        option.inviteMode = .TEAM_INVITE_MODE_MANAGER

        if let groupImage =  self.headImageView.image {
            //let imageForAvatarUpload = groupImage.nim_imageForAvatarUpload()
            var fileName = URL(fileURLWithPath: UUID().uuidString.lowercased()).appendingPathExtension("jpg").absoluteString
            fileName = fileName.replacingOccurrences(of: "file:///", with: "", options: NSString.CompareOptions.literal, range: nil)
            var filePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName).absoluteString
            let filePathTemp = filePath
            filePath = filePath.replacingOccurrences(of: "file:///", with: "", options: NSString.CompareOptions.literal, range: nil)
           // var data: Data? = nil
//            if let imageForAvatarUpload = imageForAvatarUpload {
//                data = imageForAvatarUpload.jpegData(compressionQuality: 1.0)
//            }
            var data: Data? = groupImage.jpegData(compressionQuality: 1.0)
            var success: Bool = (data != nil && data!.bytes.count > 0)
            do {
                try data?.write(to: URL(string: filePathTemp)!, options: .atomic)
            }
            catch {
                success = false
            }

            if success {
                let task = V2NIMUploadFileTask()
                let uploadParams = V2NIMUploadFileParams()
                uploadParams.filePath = filePath
                uploadParams.sceneName = NIMNOSSceneTypeAvatar
                task.uploadParams = uploadParams
                task.taskId = Date().timeIntervalSince1970.toString()
                NIMSDK.shared().v2StorageService.uploadFile(task) {[weak self] urlString in
                    guard let strongSelf = self else { return }
                    option.avatar = urlString
                    strongSelf.createTeam(option: option)
                } failure: {[weak self] error in
                    self?.showFail(text: "group_avatar_upload_fail".localized)
                } progress: { progress in
                   
                }
            } else if let data = data, data.bytes.count == 0 {
                createTeam(option: option)
            } else {
               // loader.dismiss()
                self.showFail(text: "error_create_team_failed".localized)
            }
        }
        else {
            createTeam(option: option)
        }
        
    }
    
    func createTeam(option: V2NIMCreateTeamParams) {
        
        NIMSDK.shared().v2TeamService.createTeam(option, inviteeAccountIds: members, postscript: "text_invite_to_group".localized, antispamConfig: nil) {[weak self] teamResult in
            DispatchQueue.main.async {
                if let teamId = teamResult.team?.teamId , let name = teamResult.team?.name {
                    self?.navigationController?.popViewController(animated: false)
                    self?.finishBlock?(teamId, name)
                    
                }
            }
            
        } failure: { error in
            DispatchQueue.main.async {
                self.showFail(text: "error_create_team_failed".localized)
            }
        }
    }

}

extension TGCreateGroupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return choosedDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TGCreateGroupCell", for: indexPath) as! TGCreateGroupCell
        
        cell.setData(model: choosedDataSource[indexPath.row])
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    
}

extension TGCreateGroupViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(tap:)))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard(tap: UIGestureRecognizer?) {
        view.endEditing(true)
        if let tap = tap {
            self.view.removeGestureRecognizer(tap)
        }
    }

    @objc func textFieldDidChange(textField: UITextField) {
        containText = !textField.text!.isEmpty
     
        self.rightButtonEnable(enable: !textField.text!.isEmpty)
        //获取高亮部分
        let selectedRange = textField.markedTextRange
        var pos: UITextPosition? = nil
        if let start = selectedRange?.start {
            pos = textField.position(from: start, offset: 0)
        }

        //如果在变化中是高亮部分在变，就不要计算字符了
        if selectedRange != nil && pos != nil {
            return
        }

        let textContent = textField.text
        let textNum = textContent?.count ?? 0

        if(textNum > maximumGroupNameLength) {
            //截取到最大位置的字符(由于超出截部分在should时被处理了所在这里这了提高效率不再判断)
            let s = textContent?.subString(with: NSRange(location: 0, length: 25))

            textField.text = s
        }

        //不让显示负数
        countLabel.text = String(max(0, maximumGroupNameLength - textNum))
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //获取高亮部分
        let selectedRange = textField.markedTextRange
        //获取高亮部分内容
        var pos: UITextPosition? = nil
        if let start = selectedRange?.start {
            pos = textField.position(from: start, offset: 0)
        }

        //如果有高亮且当前字数开始位置小于最大限制时允许输入
        if selectedRange != nil && pos != nil {
            var startOffset: Int? = nil
            if let start = selectedRange?.start {
                startOffset = textField.offset(from: textField.beginningOfDocument, to: start)
            }
            var endOffset: Int? = nil
            if let end = selectedRange?.end {
                endOffset = textField.offset(from: textField.beginningOfDocument, to: end)
            }

            let offsetRange = NSRange(location: startOffset ?? 0, length: (endOffset ?? 0) - (startOffset ?? 0))

            if offsetRange.location < maximumGroupNameLength {
                return true
            } else {
                return false
            }
        }

        let comcatstr = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)

        let caninputlen = maximumGroupNameLength - (comcatstr?.count ?? 0)

        if caninputlen >= 0 {
            return true
        } else {
            let len = string.count + caninputlen
            //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
            let rg = NSRange(location: 0, length: max(len,0))

            checkMarkedTextNumber(rg: rg, string: string, textField: textField, range: range)
            return false
        }
    }

    //Use to check whether the current input string for language other than English is exceed the limit and show only the string within limit of 25
    func checkMarkedTextNumber(rg: NSRange, string: String, textField: UITextField, range: NSRange) {
        var finalTrimString = ""
        if rg.length > 0 {

            //判断是否只普通的字符或asc码(对于中文和表情返回NO)
            let asc = string.canBeConverted(to: String.Encoding.ascii)
            if asc {
                finalTrimString = (string as NSString).substring(with: rg) //因为是ascii码直接取就可以了不会错
            } else {
                var idx = 0
                var trimstring = ""//截取出的字串
                //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                (string as NSString).enumerateSubstrings(in: NSRange(location: 0, length: string.count), options: .byComposedCharacterSequences, using: { substring, substringRange, enclosingRange, stop in
                    if idx >= rg.length {
                        stop[0] = true //取出所需要就break，提高效率
                        return
                    }

                    trimstring = trimstring + (substring ?? "")

                    idx += 1
                })

                finalTrimString = trimstring
            }

            textField.text = (textField.text as NSString?)?.replacingCharacters(in: range, with: finalTrimString)
        }
    }
}

extension TGCreateGroupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.headImageView.image = image
            picker.dismiss(animated: true) {
                
            }
        }
    }
}
