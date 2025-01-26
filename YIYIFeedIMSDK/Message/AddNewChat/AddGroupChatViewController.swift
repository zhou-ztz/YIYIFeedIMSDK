//
//  AddGroupChatViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/4/12.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import MobileCoreServices
import NIMSDK

class AddGroupChatViewController: TGViewController {
    
    ///搜索 取消按钮样式
    var cancelType: SearchCancleType = .editingShow
    //人数
    var num: Int = 0
    var leftStackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fillProportionally
        $0.alignment = .center
    }
    lazy var groupNum: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor(hex: "#86909C")
        lab.font = UIFont.systemRegularFont(ofSize: 12)
        lab.textAlignment = .left
        lab.text = "0/200"
        return lab
    }()
    lazy var nextBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("next".localized, for: .normal)
        btn.setTitleColor(TGAppTheme.red, for: .normal)
        btn.titleLabel?.font = UIFont.systemRegularFont(ofSize: 17)
        btn.isEnabled = false
        return btn
    }()
    
    lazy var createBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("btn_create".localized, for: .normal)
        btn.setTitleColor(TGAppTheme.red, for: .normal)
        btn.titleLabel?.font = UIFont.systemRegularFont(ofSize: 17)
        btn.isEnabled = false
        return btn
    }()
    
    let bgView = UIView()
    var contactsVC: NewContactsListViewController?
    var settingVC: AddGroupSettingViewController?
  //  let loader = TSIndicatorWindowTop(state: .loading, title: "loading".localized)
    //是否设置
    var isSetting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.isHidden = true
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
        self.backBaseView.backgroundColor = .clear
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setupUI(){
        self.backBaseView.addSubview(bgView)
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 20
        bgView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(TSNavigationBarHeight)
        }
        
        let titleView = self.setTitleView()
        bgView.addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.height.equalTo(84)
            make.left.right.top.equalToSuperview()
        }
        
        contactsVC = NewContactsListViewController(cancelType: self.cancelType)
        
        contactsVC?.view.backgroundColor = .white
        bgView.addSubview(contactsVC!.view)
        contactsVC!.view.snp.makeConstraints { make in
            make.top.equalTo(80)
            make.left.right.bottom.equalToSuperview()
        }
        contactsVC?.didMove(toParent: self)

        self.contactsVC?.searchBar.delegate = self
        self.contactsVC?.searchBar.searchTextFiled.placeholder = "search_name_id".localized
        
        self.contactsVC?.didSelectData = { _ in
            self.numSelectedChange()
        }
        contactsVC?.customNavigationBar.isHidden = true
    }
    
    func setTitleView() -> UIView{
        
        let titleView = UIView()
        
        let line = UIView()
        line.backgroundColor = UIColor(hex: "#D9D9D9")
        titleView.addSubview(line)
        line.layer.cornerRadius = 2.5
        line.clipsToBounds = true
        line.snp.makeConstraints { make in
            make.height.equalTo(5)
            make.width.equalTo(52)
            make.top.equalTo(10)
            make.centerX.equalToSuperview()
        }
        
        let image = UIImage(named: "iconsArrowCaretleftBlack")
        let backimage = UIImageView(image: image)
        let lab = UILabel()
        lab.textColor = .black
        lab.font = UIFont.boldSystemFont(ofSize: 17)
        lab.textAlignment = .left
        lab.text = "new_group".localized
        groupNum.sizeToFit()
        leftStackView.addArrangedSubview(backimage)
        leftStackView.addArrangedSubview(lab)
        leftStackView.addArrangedSubview(groupNum)
        backimage.snp.makeConstraints { make in
            make.height.width.equalTo(24)
        }
        leftStackView.addAction {
            if !self.isSetting {
                self.navigationController?.popViewController(animated: true)
            }else {
                self.isSetting = false
                self.nextBtn.isHidden = false
                self.createBtn.isHidden = true
                
                self.settingVC?.view.removeFromSuperview()
                self.settingVC = nil
                self.contactsVC?.view.isHidden = false
            }
        }
        titleView.addSubview(leftStackView)
        leftStackView.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.height.equalTo(26)
            make.bottom.equalTo(-5)
        }
        
        nextBtn.isEnabled = false
        nextBtn.setTitleColor(UIColor(hex: "#D9D9D9"), for: .normal)
        nextBtn.addTarget(self, action: #selector(nextBtnAction), for: .touchUpInside)
        
        titleView.addSubview(nextBtn)
        nextBtn.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.height.equalTo(26)
            make.bottom.equalTo(-5)
        }
        
        createBtn.isEnabled = false
        createBtn.setTitleColor(UIColor(hex: "#D9D9D9"), for: .normal)
        createBtn.addTarget(self, action: #selector(createBtnAction), for: .touchUpInside)
        titleView.addSubview(createBtn)
        createBtn.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.height.equalTo(26)
            make.bottom.equalTo(-5)
        }
        createBtn.isHidden = true
        return titleView
    }

  
    @objc func nextBtnAction(){
        
        if num == 0 {
            return
        }
        isSetting = true
        settingVC = AddGroupSettingViewController()
        settingVC?.choosedDataSource = self.contactsVC!.choosedDataSource
        
        bgView.addSubview(settingVC!.view)
        settingVC?.didMove(toParent: self)
        settingVC!.view.snp.makeConstraints { make in
            make.top.equalTo(80)
            make.left.right.bottom.equalToSuperview()
        }
        self.contactsVC?.view.isHidden = true
        settingVC?.opneAction = {
            self.showSheet()
        }
        settingVC?.groupNames = { hasName in
            if hasName {
                self.createBtn.isEnabled = true
                self.createBtn.setTitleColor(TGAppTheme.red, for: .normal)
            }else {
                self.createBtn.isEnabled = false
                self.createBtn.setTitleColor(UIColor(hex: "#D9D9D9"), for: .normal)
            }
            
        }
        nextBtn.isHidden = true
        createBtn.isHidden = false
       
    }
    
    @objc func createBtnAction(){
        settingVC?.nameT.resignFirstResponder()
        if (settingVC?.nameT.text?.count ?? 0) == 0 {
            return
        }
        createGroup()
    }
    
    func numSelectedChange() {
        num = self.contactsVC!.choosedDataSource.count
        nextBtn.isEnabled = num > 1 ? true : false
        if num > 1 {
            nextBtn.setTitleColor(TGAppTheme.red, for: .normal)
        }else{
            nextBtn.setTitleColor(UIColor(hex: "#D9D9D9"), for: .normal)
        }
        
        groupNum.text = "\(num)" + "/200"
    }
    
    //创建群组
    func createGroup(){
        
       // loader.show()
        let option = V2NIMCreateTeamParams()
        option.name       = settingVC?.nameT.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        option.teamType   = .TEAM_TYPE_NORMAL
        option.joinMode   = .TEAM_JOIN_MODE_FREE
        option.inviteMode = .TEAM_INVITE_MODE_MANAGER

        if let groupImage =  settingVC?.headImageView.image {
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
        
        NIMSDK.shared().v2TeamService.createTeam(option, inviteeAccountIds: settingVC?.members ?? [], postscript: "text_invite_to_group".localized, antispamConfig: nil) {[weak self] teamResult in
            
            if let teamId = teamResult.team?.teamId {
                self?.settingVC?.headImageView.image = nil
                self?.settingVC?.cameraImageView.isHidden = false
                self?.settingVC?.nameT.text = ""
                self?.createBtn.isEnabled = false
                self?.createBtn.setTitleColor(UIColor(hex: "#D9D9D9"), for: .normal)
                let me: String = NIMSDK.shared().v2LoginService.getLoginUser() ?? ""
                let conversationId = "\(me)|2|\(teamId)"
                let tip = String(format: "%@ %@", option.name,"created".localized)
                let message = MessageUtils.tipV2Message(text: tip)
                NIMSDK.shared().v2MessageService.send(message, conversationId: conversationId, params: nil) {  _ in
                    DispatchQueue.main.async {
                        let vc = TGChatViewController(conversationId: conversationId, conversationType: 2)
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                } failure: { _ in
                    
                }
                
            }
            
        } failure: { error in
            DispatchQueue.main.async {
                self.showFail(text: "error_create_team_failed".localized)
            }
        }
    }

    func showFail(text: String) {
//        let loadingAlert = TSIndicatorWindowTop(state: .faild, title: text)
//        loadingAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
    
    func showSheet(){
        
        var titles: [String] = ["camera".localized, "album".localized]
        if (settingVC?.headImageView.image) != nil {
            titles = ["camera".localized, "album".localized, "remove_photo".localized]
        }
        let actionsheetView = TGCustomCameraSheetView(titles: titles)
        if titles.count == 3 {
            actionsheetView.setColor(color: RLColor.main.warn, index: 2)
        }
        actionsheetView.delegate = self
        //actionsheetView.tag = 2
        actionsheetView.show()
    }
    
    
    func openAblum(){
        AuthorizeStatusUtils.checkAuthorizeStatusByType(type: .cameraAlbum, viewController: self, completion: { [weak self] in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                self?.present(picker, animated: true, completion: nil)
            }
        })
        
    }
    
    func openCamera() {
        AuthorizeStatusUtils.checkAuthorizeStatusByType(type: .cameraAlbum, viewController: self, completion: {[weak self] in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .camera
                picker.allowsEditing = true
                self?.present(picker, animated: true, completion: nil)
            }
        })
    }

}

extension AddGroupChatViewController: ContactsSearchViewDelegate{
    func searchDidClickReturn(text: String) {
        self.contactsVC?.searchBar.searchTextFiled.resignFirstResponder()
        self.contactsVC?.keyword = text
        self.contactsVC?.refresh()
    }
    
    func searchDidClickCancel() {
        
    }
    func searchTextDidChange(text: String) {
        if text.count == 0 {
            self.contactsVC?.keyword = ""
            self.contactsVC?.refresh()
        }
    }
    
}

extension AddGroupChatViewController: TGCustomCameraSheetViewDelegate {
    func didSelectedItem(view: TGCustomCameraSheetView, title: String, index: Int) {
        switch index {
        case 0:
            openCamera()
            break
        case 1:
            openAblum()
            break
        case 2:
            self.settingVC?.headImageView.image = nil
            self.settingVC?.cameraImageView.isHidden = false
            break
        default:
            break
        }
    }
}

extension AddGroupChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            settingVC?.headImageView.image = image
            self.settingVC?.cameraImageView.isHidden = true
            picker.dismiss(animated: true) {
                
            }
        }
    }
}

//extension AddGroupChatViewController: TZImagePickerControllerDelegate {
//    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
//        
//        let lzImage = LZImageCropping()
//        lzImage.cropSize = CGSize(width: UIScreen.main.bounds.width - 80, height: UIScreen.main.bounds.width - 80)
//        lzImage.image = photos.first
//        lzImage.isRound = true
//        lzImage.titleLabel.text = "Move and Scale".localized
//        lzImage.didFinishPickingImage = { [weak self] image in
//            guard let self = self, let image = image else {
//                return
//            }
//            
//            DispatchQueue.main.async {
//                self.settingVC?.headImageView.image = image
//                self.settingVC?.cameraImageView.isHidden = true
//            }
//        }
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
//            self.navigationController?.present(lzImage.fullScreenRepresentation, animated: true, completion: nil)
//        }
//    }
//}
