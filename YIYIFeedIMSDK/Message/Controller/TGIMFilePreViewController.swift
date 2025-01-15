//
//  TGIMFilePreViewController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/16.
//

import UIKit
import NIMSDK

class TGIMFilePreViewController: TGViewController {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.image = UIImage(named: "icon_file")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var nameLable: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    lazy var progress: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progress = 0.5
        progressView.progressTintColor = .blue // 设置进度条颜色
        return progressView
    }()
    
    lazy var doneBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("", for: .normal)
        button.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        return button
    }()
    
    var fileObject: V2NIMMessageFileAttachment!
    var interactionController: UIDocumentInteractionController!
    var isDownLoading: Bool! = false
    // By Kit Foong (Refresh table function)
    var refreshTable: (() -> Void)?
    
    init(object: V2NIMMessageFileAttachment) {
        super.init(nibName: nil, bundle: nil)
        fileObject = object
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backBaseView.addSubview(imageView)
        backBaseView.addSubview(nameLable)
        backBaseView.addSubview(progress)
        backBaseView.addSubview(doneBtn)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(134)
            make.centerX.equalToSuperview()
            make.height.equalTo(168)
            make.width.equalTo(132)
        }
        
        nameLable.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        progress.snp.makeConstraints { make in
            make.top.equalTo(nameLable.snp.bottom).offset(30)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(194)
            make.height.equalTo(2)
        }
        
        doneBtn.snp.makeConstraints { make in
            make.top.equalTo(progress.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(202)
            make.height.equalTo(45)
        }
        
        self.customNavigationBar.title = fileObject.name
        self.nameLable.text  = fileObject.name
        if let path = fileObject.path{
            self.imageView.image = RLSendFileManager.fileIcon(with: URL(fileURLWithPath: path).pathExtension).icon
        }
        
        self.imageView.contentMode = .scaleAspectFit
        self.progress.isHidden = true
        doneBtn.backgroundColor = TGAppTheme.secondaryColor
        doneBtn.layer.cornerRadius = 7
        doneBtn.setTitleColor(TGAppTheme.twilightBlue, for: .normal)
        
        // By Kit Foong (Check file is it exist to update button design)
        let urlPath = self.fileObject.path ?? ""
        
        if FileManager.default.fileExists(atPath: urlPath) {
            doneBtn.setTitle("open".localized, for: .normal)
        } else {
            doneBtn.setTitle("viewholder_download_document".localized, for: .normal)
        }
    }
    
    @objc func doneAction (){
        if isDownLoading {
            return
        }
        guard let filePath = self.fileObject.path else {return}
        
        if FileManager.default.fileExists(atPath: filePath) {
            self.openWithDocumentInterator()
        }else{
            self.downLoadFile()
        }
    }
    
    //MARK: 打开其他应用
    func openWithDocumentInterator(){
        let url = URL(fileURLWithPath: self.fileObject.path ?? "")
        self.interactionController = UIDocumentInteractionController(url: url)
        self.interactionController.delegate = self
        self.interactionController.name = self.fileObject.name
        self.interactionController.presentPreview(animated: true)
    }
    
    //MARK: 文件下载
    func downLoadFile()
    {
        NIMSDK.shared().v2StorageService.downloadFile(fileObject.url ?? "", filePath: fileObject.path ?? "") {[weak self] _ in
            self?.doneBtn.setTitle("open".localized, for: .normal)
            self?.openWithDocumentInterator()
        } failure: {[weak self] _ in
            self?.progress.progress = 0
            self?.doneBtn.setTitle("download_failed_try_again".localized, for: .normal)
        } progress: {[weak self] progress in
            self?.isDownLoading = true
            self?.progress.isHidden = false
            self?.progress.progress = Float(progress) / 100.0
            self?.doneBtn.setTitle("viewholder_download_cancel".localized, for: .normal)
        }
    }
    
}

extension TGIMFilePreViewController: UIDocumentInteractionControllerDelegate{
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

    func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        controller.dismissPreview(animated: true)
    }

}
