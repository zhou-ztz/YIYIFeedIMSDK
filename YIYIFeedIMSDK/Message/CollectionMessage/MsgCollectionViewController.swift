//
//  MsgCollectionViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/12.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class MsgCollectionViewController: TGViewController {
    var dataArray = [FavoriteMsgModel]()
    var selectData = [FavoriteMsgModel]()
    var selectModel: FavoriteMsgModel?
    let limit = 15
    var excludeId = 0 //上一页最后一条ID，第一条传0
    var selectedType: MessageCollectionType = .all // 收藏类型
    var edit: Bool = false //编辑状态
    private var selectorView: IMCategorySelectView?
    private lazy var msgCategoryView = { return UIView() }()
    let optionView = FeedCategoryOptions()
    var categoryList = [CategoryMsgModel]()
    var isShow: Bool = false
    var isFirstLoad: Bool = true
    
    var interactionController: UIDocumentInteractionController!
    
    lazy var placehoderView: UIView = {
        let placehoder = UIView(frame: self.backBaseView.bounds)
        placehoder.backgroundColor = .white
        placehoder.isHidden = true
        return placehoder
    }()
    
    lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.text = "favourite_msg_type".localized
        label.textColor = UIColor(red: 136, green: 136, blue: 136)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    lazy var topView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 40))
        view.backgroundColor = .white
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 120, height: 30)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(MsgCollectionViewCell.self, forCellWithReuseIdentifier: "MsgCollectionViewCell")
        collection.dataSource = self
        collection.delegate = self
        collection.isUserInteractionEnabled = true
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 0
        tableView.rowHeight = UITableView.automaticDimension
        //tableView.estimatedRowHeight = 50
        tableView.backgroundColor = .white
        tableView.register(MessageCollectCell.self, forCellReuseIdentifier: MessageCollectCell.cellIdentifier)
        return tableView
    }()
    
    lazy var cancel: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        btn.setTitle("cancel".localized, for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    lazy var selectedItem: UIButton = {
        let button = UIButton()
        button.setTitle("msg_number_of_selected".localized, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        //button.tintColor = UIColor.black
        return button
    }()
    
    lazy var selectActionToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.tintColor = TGAppTheme.white
        toolbar.isTranslucent = false
        toolbar.isHidden = true
        return toolbar
    }()
    
    lazy var deleteBarButton: UIBarButtonItem = {
        let button = UIButton()
        button.setImage(UIImage(named: "msg_select_delete"), for: .normal)
        button.addTarget(self, action: #selector(deleteCollectMessages), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height : -5.0)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 3
        view.isHidden = true
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("favourite_msg_delete".localized, for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = TGAppTheme.Font.semibold(16)
        button.addTarget(self, action: #selector(deleteCollectMessages), for: .touchUpInside)
        return button
    }()
    
    lazy var fowardButton: UIButton = {
        let button = UIButton()
        button.setTitle("favourite_msg_forward".localized, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = TGAppTheme.Font.semibold(16)
        button.addTarget(self, action: #selector(forwardAction), for: .touchUpInside)
        return button
    }()
    
    var collection: V2NIMCollection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backBaseView.backgroundColor = .white
        self.customNavigationBar.backItem.setTitle("title_favourite_message".localized, for: .normal)
//        self.setCloseButton(backImage: true, titleStr: "title_favourite_message".localized, completion: {
//            if !self.isShow {
//                self.navigationController?.popViewController(animated: true)
//            } else {
//                self.isShow = false
//                self.shadowView.isHidden = true
//            }
//            self.selectData.removeAll()
//            self.tableView.reloadData()
//        }, needPop: false)
       // self.customNavigationBar.setRightViews(views: [cancel])
        self.setPlacehoderView()
        self.setRightBarButton()
        self.setUI()
        self.setData()
        self.getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setUI() {
        self.backBaseView.addSubview(self.collectionView)
        self.backBaseView.addSubview(self.tableView)
        self.backBaseView.addSubview(self.shadowView)
        self.shadowView.addSubview(self.stackView)
        self.stackView.addArrangedSubview(fowardButton)
        self.stackView.addArrangedSubview(deleteButton)
        
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(40)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom)
            $0.bottom.left.right.equalToSuperview()
        }
        
        shadowView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(90)
        }
        stackView.bindToEdges(inset: 12)
        
        fowardButton.snp.makeConstraints {
            $0.width.equalTo(80)
            $0.height.equalTo(30)
        }
        
        deleteButton.snp.makeConstraints {
            $0.width.equalTo(80)
            $0.height.equalTo(30)
        }
        tableView.mj_header = SCRefreshHeader(refreshingTarget: self, refreshingAction: #selector(getData))
        tableView.mj_footer = SCRefreshFooter(refreshingTarget: self, refreshingAction: #selector(self.loadMore))
   
        self.backBaseView.addSubview(selectActionToolbar)
        selectActionToolbar.snp.makeConstraints { make in
            make.height.equalTo(50 + TSBottomSafeAreaHeight)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.backBaseView.layer.layoutIfNeeded()
    }
    
    private func setRightBarButton() {
        let button = UIButton()
        button.setTitleColor(RLColor.main.theme, for: .normal)
        button.setTitle("edit".localized, for: .normal)
        button.addTarget(self, action: #selector(editAction), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.customNavigationBar.setRightViews(views: [button])
    }
    
    func setPlacehoderView() {
        self.backBaseView.addSubview(placehoderView)
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 21
        stackView.alignment = .center
        placehoderView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(210)
        }
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "placeholder_no_result")
        imageView.contentMode = .scaleAspectFill
        stackView.addArrangedSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.width.equalTo(240)
            make.height.equalTo(200)
        }
        
        let tipLab = UILabel()
        tipLab.text = "favourite_msg_empty_state".localized
        tipLab.textAlignment = .center
        tipLab.textColor = UIColor(red: 155, green: 155, blue: 155)
        tipLab.font = UIFont.systemFont(ofSize: 14)
        stackView.addArrangedSubview(tipLab)
        
        let typeBtn = UIButton()
        typeBtn.setTitle("favourite_msg_button_other_types".localized, for: .normal)
        typeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        typeBtn.setTitleColor(UIColor.white, for: .normal)
        typeBtn.backgroundColor = UIColor(red: 59, green: 179, blue: 255)
        typeBtn.layer.cornerRadius = 22.5
        typeBtn.clipsToBounds = true
        stackView.addArrangedSubview(typeBtn)
        typeBtn.snp.makeConstraints { (make) in
            make.height.equalTo(45)
            make.width.equalTo(159)
        }
        typeBtn.addTarget(self, action: #selector(otherTypeAction), for: .touchUpInside)
        typeBtn.isHidden = true
    }
    
    private func setData() {
        let types: [MessageCollectionType] = [.all, .text, .image, .video, .audio, .link, .location, .file, .nameCard, .voucher]
        let names: [String] = ["filter_favourite_all".localized,"filter_favourite_chats".localized,
                               "filter_favourite_photos".localized, "filter_favourite_videos".localized,
                               "filter_favourite_audios".localized, "filter_favourite_links".localized,
                               "filter_favourite_locations".localized, "filter_favourite_files".localized,
                               "filter_favourite_contacts".localized, "filter_favourite_voucher".localized]
        let images: [UIImage] = [UIImage(), UIImage(named: "chat")!, UIImage(named: "album")!, UIImage(named: "video")!,UIImage(named: "ic_fav_msg_audio")!, UIImage(named: "link")!,  UIImage(named: "location_new")!,  UIImage(named: "files")!,  UIImage(named: "ic_contact")!,  UIImage(named: "ic_voucher")!]
        
        for i in 0..<types.count {
            let model = CategoryMsgModel(type: types[i], name: names[i], image: images[i])
            categoryList.append(model)
    
        }
        collectionView.reloadData()
    }
    
    @objc func otherTypeAction() {
        guard self.selectorView == nil else {
            self.selectorView?.hide()
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            self.optionView.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        }
        
        self.selectorView = IMCategorySelectView(selectedType: self.selectedType, animatable: true)
        self.view.addSubview(self.selectorView!)
        self.selectorView?.selectionHandler = { [weak self] (type, name) in
            guard let self = self else { return }
            self.optionView.label.text = name
            self.selectedType = type
            self.excludeId = 0
            self.getData()
        }
        
        self.selectorView!.snp.makeConstraints { (v) in
            v.top.equalTo(self.topView.snp.bottom)
            v.left.bottom.right.equalToSuperview()
        }
        
        self.selectorView!.notifyComplete = { [weak self] in
            guard let self = self else { return }
            self.selectorView = nil
            UIView.animate(withDuration: 0.2) {
                self.optionView.arrowImageView.transform = .identity
            }
        }
    }
    
    @objc func editAction() {
        if !isShow {
            isShow = true
            self.shadowView.isHidden = false
        } else {
            isShow = false
            self.shadowView.isHidden = true
        }
        self.selectData.removeAll()
        self.tableView.reloadData()
    }
    
    @objc func forwardAction() {
        forwardTextIM()
    }
    
    func showShouldhideTip() {
        if UserDefaults.messageCollectionFilterTooltipShouldHide == false {
            let tooltip = ToolTipPreferences()
            tooltip.drawing.bubble.color = UIColor(red: 37, green: 37, blue: 37)
            tooltip.drawing.message.color = .white
            tooltip.drawing.background.color = .clear
            
            self.optionView.showToolTip(identifier: "", title: "title_tooltips_filter".localized, message: "desc_tooltips_filter".localized, button: nil, arrowPosition: .top, preferences: tooltip, delegate: nil)
            
            UserDefaults.messageCollectionFilterTooltipShouldHide = true
        }
    }
    
    @objc func cancelAction() {
        self.selectData.removeAll()
        cancel.isHidden = true
        self.edit = false
        self.tableView.reloadData()
        self.topView.isHidden = false
        self.tableView.frame = CGRect(x: 0, y: self.topView.height, width: ScreenWidth, height: ScreenHeight - TSNavigationBarHeight - self.topView.height)
        self.updateSelectedItem()
        self.selectActionToolbar.setToolbarHidden(true)
    }
    
    @objc func getData() {
        self.collection = nil
        let option = V2NIMCollectionOption()
        option.limit = limit
        option.collectionType = self.selectedType.rawValue
        NIMSDK.shared().v2MessageService.getCollectionList(by: option) {[weak self] collections in
            guard let self = self else { return }
            self.dataArray.removeAll()
            self.tableView.mj_header.endRefreshing()
            self.collection = collections.last
            for item in collections {
                if let type = MessageCollectionType(rawValue: Int(item.collectionType)) {
                    let model = FavoriteMsgModel(Id: Int(item.collectionId ?? "0") ?? 0, type: type, data: item.collectionData ?? "" , ext: item.serverExtension ?? "" , uniqueId: item.uniqueId ?? "" , createTime: item.createTime , updateTime: item.updateTime)
                    self.dataArray.append(model)
                }
            }
            if collections.count < self.limit {
                self.tableView.mj_footer.isHidden = true
            }
            self.tableView.isHidden = self.dataArray.count == 0
            self.placehoderView.isHidden = self.dataArray.count > 0
            self.tableView.reloadData()
        } failure: { error in
            //self.showError(message: error.localizedDescription)
        }

    }
    
    @objc func loadMore() {
        let option = V2NIMCollectionOption()
        option.limit = limit
        option.collectionType = self.selectedType.rawValue
        if let collection = self.collection {
            option.anchorCollection = collection
        }
        NIMSDK.shared().v2MessageService.getCollectionList(by: option) {[weak self] collections in
            guard let self = self, collections.count > 0 else { return }
            self.tableView.mj_footer.endRefreshing()
            self.collection = collections.last
            for item in collections {
                if let type = MessageCollectionType(rawValue: Int(item.collectionType)) {
                    let model = FavoriteMsgModel(Id: Int(item.collectionId ?? "0") ?? 0, type: type, data: item.collectionData ?? "" , ext: item.serverExtension ?? "" , uniqueId: item.uniqueId ?? "" , createTime: item.createTime , updateTime: item.updateTime)
                    self.dataArray.append(model)
                }
            }
            if collections.count >= self.limit {
                self.tableView.mj_footer = SCRefreshFooter(refreshingTarget: self, refreshingAction: #selector(self.loadMore))
            } else{
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
            }
            self.tableView.mj_footer.isHidden = collections.count != self.limit
            self.tableView.reloadData()
        } failure: { error in
            //self.showError(message: error.localizedDescription)
        }
    }
    
    func collectionMsgContentView(_ message: FavoriteMsgModel, indexPath: IndexPath) -> BaseCollectView {
        let msgType = message.type
        switch msgType {
        case .text:
            return TextCollectView(collectModel: message, indexPath: indexPath)
        case .image:
            return ImageVideoCollectView(collectModel: message, indexPath: indexPath)
        case .audio:
            return AudioCollectView(collectModel: message, indexPath: indexPath)
        case .video:
            return ImageVideoCollectView(collectModel: message, indexPath: indexPath)
        case .file:
            return FileCollectView(collectModel: message, indexPath: indexPath)
        case .location:
            return LocaltionCollectView(collectModel: message, indexPath: indexPath)
        case .nameCard:
            return ContactCardCollectView(collectModel: message, indexPath: indexPath)
        case .sticker:
            return StickerCollectView(collectModel: message, indexPath: indexPath)
        case .link:
            return WebLinkCollectView(collectModel: message, indexPath: indexPath)
        case .miniProgram:
            return MiniProgramCollectView(collectModel: message, indexPath: indexPath)
        case .voucher:
            return VoucherCollectView(collectModel: message, indexPath: indexPath)
        default:
            return UnkonwCollectView(collectModel: message, indexPath: indexPath)
        }
    }
    
    func moreViewAction() {
        let items: [IMActionItem] = [.forward, .delete]
        if (items.count > 0 ) {
            let view = IMActionListView(actions: items)
            view.delegate = self
        }
    }
    
    // MARK: delete
    @objc func deleteCollectMessages() {
        deleteAction()
    }
    
    func deleteAction() {
        if self.selectData.count == 0 {
            //self.showError(message: "favourite_msg_delete_at_least".localized)
            return
        }
        
        self.showDialog(title: "favourite_msg_delete".localized, message:  String(format: "favourite_msg_delete_desc".localized, selectData.count), dismissedButtonTitle: "favourite_msg_delete".localized, onDismissed: { [weak self] in
            guard let self = self else { return }
            self.deleteMsg()
        }, onCancelled: {
          
        }, cancelButtonTitle: "cancel".localized, isRedPacket: true, isFavouriteMessage: true)
      
    }
    
    func deleteMsg() {
        
        var v2collections = [V2NIMCollection]()
        for model in self.selectData {
            let collectInfo = V2NIMCollection()
            collectInfo.createTime = model.createTime
            collectInfo.collectionId = String(model.Id)
            v2collections.append(collectInfo)
        }
        
        NIMSDK.shared().v2MessageService.remove(v2collections) { [weak self] total in
            guard let self = self else { return }
            for model in self.selectData {
                if let index = self.dataArray.firstIndex(where: { $0.Id == model.Id }) {
                    self.dataArray.remove(at: index)
                }
            }
            self.selectData.removeAll()
            self.tableView.reloadData()
            self.tableView.isHidden = self.dataArray.count == 0
            self.placehoderView.isHidden = self.dataArray.count > 0
        } failure: { error in
            
        }

    }
    
    func updateSelectedItem() {
        selectedItem.setTitle(String(format: "msg_number_of_selected".localized, String(format: "%i", selectData.count)), for: .normal)
    }
    
    private func showShareContent(_ urlAddress: String) {
        guard let url = URL(string: urlAddress) else { return }
        
        if url.host?.lowercased().contains("yippi") ?? false {
            RLSDKManager.shared.imDelegate?.didPressSocialPost(urlString: urlAddress)
        } else {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func liveEndAlert() {
        let alertController = UIAlertController(title: nil, message: "text_livestream_ended".localized, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "ok".localized, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    //MARK: 打开其他应用
    func openWithDocumentInterator(path: String, name: String){
        let url = URL(fileURLWithPath: path)
        self.interactionController = UIDocumentInteractionController(url: url)
        self.interactionController.delegate = self
        self.interactionController.name = name
        self.interactionController.presentPreview(animated: true)
    }
}

extension MsgCollectionViewController:  MessageCollectDelegate {
    func checkBoxClicked(model: FavoriteMsgModel) {
        // let model = self.dataArray[indexPath.section]
        self.selectModel = model
        if let index = self.selectData.firstIndex(where: { $0.Id == model.Id }){
            self.selectData.remove(at: index)
        } else {
            self.selectData.append(model)
        }
        
    }
}

extension MsgCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MsgCollectionViewCell.cellIdentifier, for: indexPath) as! MsgCollectionViewCell
        cell.setData(data: categoryList[indexPath.row])
        
        if !collectionView.isDragging && !collectionView.isDecelerating {
            if indexPath.section == 0 && indexPath.row == 0 {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
            } else {
                cell.contentView.backgroundColor = UIColor(hex: 0xededed)
                cell.cateLabel.textColor = .lightGray
                cell.cateImageView.image = cell.cateImageView.image?.withRenderingMode(.alwaysTemplate)
                cell.cateImageView.tintColor = .lightGray
            }
        }
        
        if cell.isSelected {
            cell.contentView.backgroundColor = TGAppTheme.red
            cell.cateLabel.textColor = .white
            cell.cateImageView.image = cell.cateImageView.image?.withRenderingMode(.alwaysTemplate)
            cell.cateImageView.tintColor = .white
        } else {
            cell.contentView.backgroundColor = UIColor(hex: 0xededed)
            cell.cateLabel.textColor = .lightGray
            cell.cateImageView.image = cell.cateImageView.image?.withRenderingMode(.alwaysTemplate)
            cell.cateImageView.tintColor = .lightGray
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let data = categoryList[safe: indexPath.row] {
            self.selectedType = data.type
            self.excludeId = 0
            self.selectData.removeAll()
            self.isShow = false
            self.shadowView.isHidden = true
            self.getData()
        }
    }
}

extension MsgCollectionViewController: BaseCollectViewDelegate {
    // MARK: Text
    func baseViewTextMsgTap(indexPath: IndexPath, favoriteModel: FavoriteMsgModel?) {
        guard let model = favoriteModel else {
            return
        }
        let vc = CollectionTextMsgViewController(model: model)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.collectionMsgCall = { [weak self] (model) in
            guard let self = self else { return }
            if let faModel = model {
                if let index = self.dataArray.firstIndex(where: { $0.Id == faModel.Id }){
                    self.dataArray.remove(at: index)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: Audio
    func baseViewAudioMsgTap(indexPath: IndexPath, favoriteModel: FavoriteMsgModel?) {
        guard let model = favoriteModel else {
            return
        }
        let vc = CollectionAudioMsgViewController(model: model)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.collectionMsgCall = { [weak self] (model) in
            guard let self = self else { return }
            if let faModel = model {
                if let index = self.dataArray.firstIndex(where: { $0.Id == faModel.Id }){
                    self.dataArray.remove(at: index)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: Image,Video
    func baseViewImageVideoTap(indexPath: IndexPath, favoriteModel: FavoriteMsgModel?) {
        guard let model = favoriteModel else {
            return
        }
        let vc = CollectionImageVideoMsgViewController(model: model)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.collectionMsgCall = { [weak self] (model) in
            guard let self = self else { return }
            if let faModel = model {
                if let index = self.dataArray.firstIndex(where: { $0.Id == faModel.Id }){
                    self.dataArray.remove(at: index)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //MARK: Location
    func baseViewLocaltionoMsgTap(indexPath: IndexPath, favoriteModel: IMLocationCollectionAttachment?) {
        guard let model = favoriteModel else {
            return
        }
        let object: ChatLocaitonModel = ChatLocaitonModel()
        object.title = model.title
        object.lat = model.lat
        object.lng = model.lng
        let vc = TGMessageMapViewController()
        vc.model = object
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func baseViewFileMsgTap(indexPath: IndexPath, favoriteModel: IMFileCollectionAttachment?) {
        guard let model = favoriteModel else {
            return
        }
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        let name = model.name
        let path = "\(documentsPath)/collectionFile/\(name)"
        
        if FileManager.default.fileExists(atPath: path) {
            let url = URL(fileURLWithPath: path)
            if url.isFileURL {
                openWithDocumentInterator(path: path, name: model.name)
            } else {
                //url: url, type: .defaultType, title: model.name
                RLSDKManager.shared.imDelegate?.openFileWebview(url: url, title: model.name)
            }
        } else {
            let vc: CollectionFileMsgViewController = CollectionFileMsgViewController(model: model)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func baseViewLinkMsgTap(url: String?) {
        guard let url = url else {
            return
        }
        self.showShareContent(url)
    }
    
    //MARK: Mini Program
    func baseViewMiniProgromMsgTap(appId: String?, path: String?) {
        guard let appId = appId, let path = path else {
            return
        }
        RLSDKManager.shared.imDelegate?.didPressMiniProgrom(appId: appId, path: path)
    }

    func baseViewMoreEditTap(indexPath: IndexPath) {
        let model = self.dataArray[indexPath.section]
        self.selectModel = model
        if self.edit {
            if let index = self.selectData.firstIndex(where: { $0.Id == model.Id }){
                self.selectData.remove(at: index)
            } else {
                self.selectData.append(model)
            }
            
            self.tableView.reloadRow(at: indexPath, with: .none)
            self.updateSelectedItem()
        } else {
            self.moreViewAction()
        }
    }
    
    //MARK: Name Card
    func baseViewContactTap(memberId: String) {
        RLSDKManager.shared.imDelegate?.didPressNameCard(memberId: memberId)

    }
    
    //MARK: Sticker
    func baseViewStickerTap(bundleId: String) {
        RLSDKManager.shared.imDelegate?.didPressStickerDetail(bundleId: bundleId)
    }
    
    //MARK: Unknown
    func baseViewUnknownTap() {
//        if let lastCheckModel = TSCurrentUserInfo.share.lastCheckAppVesin {
//            TSRootViewController.share.checkAppVersion(lastCheckModel: lastCheckModel, forceShowAlert: true)
//        }
    }

    //MARK: Voucher
    func baseViewVoucherMsgTap(url: String?) {
        guard let url = url else { return }
        self.showShareContent(url)
    }
    
    //MARK: 打开其他应用
//    func openWithDocumentInterator(object: V2NIMMessageFileAttachment) {
//        let url = URL(fileURLWithPath: object.path ?? "")
//        self.interactionController = UIDocumentInteractionController(url: url)
//        self.interactionController.delegate = self
//        self.interactionController.name = object.name
//        self.interactionController.presentPreview(animated: true)
//    }
}

extension MsgCollectionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCollectCell.cellIdentifier, for: indexPath) as! MessageCollectCell
        cell.selectionStyle = .none
        cell.delegate = self
        cell.isChecked = false
        cell.checkBoxButton.isSelected = false
        let model = self.dataArray[indexPath.section]
        let contentV = self.collectionMsgContentView(model, indexPath: indexPath)
        contentV.delegate = self
        if self.edit, model.type.rawValue != -1 {
            contentV.moreBtn.setImage(nil, for: .normal)
            contentV.moreBtn.layer.cornerRadius = 18 / 2.0
            contentV.moreBtn.layer.masksToBounds = true
            contentV.moreBtn.layer.borderWidth = 1
            contentV.moreBtn.layer.borderColor = UIColor(hex: 0xededed).cgColor
            contentV.moreBtn.setImage(UIImage(named: "ic_rl_checkbox_selected"), for: .selected)
            if let _ = self.selectData.firstIndex(where: { $0.Id == model.Id }){
                contentV.moreBtn.isSelected = true
            } else {
                contentV.moreBtn.isSelected = false
            }
        } else {
            contentV.moreBtn.layer.cornerRadius = 0
            contentV.moreBtn.layer.masksToBounds = false
            contentV.moreBtn.layer.borderWidth = 0
            contentV.moreBtn.setImage(UIImage(named: "buttonsMoreDotGrey"), for: .normal)
        }
       
        cell.dataUpdate(dataModel: model, collectView: contentV)
        
        if isShow {
            cell.checkBoxButton.isHidden = false
            if let _ = self.selectData.firstIndex(where: { $0.Id == model.Id }){
                cell.checkBoxButton.isSelected = true
            } else {
                cell.checkBoxButton.isSelected = false
            }
        } else {
            cell.checkBoxButton.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let model = self.dataArray[safe: indexPath.section], model.type.rawValue != -1 {
            let forward = UIContextualAction(style: .normal, title: "") { [weak self] (action, sourceView, completionHandler) in
                guard let self = self else { return }
                if let index = self.selectData.firstIndex(where: { $0.Id == model.Id }) {
                    self.selectData.remove(at: index)
                } else {
                    self.selectData.append(model)
                }
                self.forwardTextIM()
                completionHandler(true)
            }
            
            let forwardLabel = UILabel()
            forwardLabel.sizeToFit()
            forwardLabel.textColor = .white
            forwardLabel.text = "favourite_msg_forward".localized
            forward.backgroundColor = UIColor(hex: 0xFFB516)
            
            if let forwardImage = UIImage(named: "ic_fav_msg_forward") {
                forward.image = resizeActionRow(image: forwardImage, label: forwardLabel)
            }
            
            let delete = UIContextualAction(style: .normal, title: "") { [weak self] (action, sourceView, completionHandler)  in
                guard let self = self else { return }
                if let index = self.selectData.firstIndex(where: { $0.Id == model.Id }) {
                    self.selectData.remove(at: index)
                } else {
                    self.selectData.append(model)
                }
                self.deleteAction()
                completionHandler(true)
            }
            
            let deleteLabel = UILabel()
            deleteLabel.sizeToFit()
            deleteLabel.textColor = .white
            deleteLabel.text = "favourite_msg_delete".localized
            
            if let deleteImage = UIImage(named: "iconsDeleteWhite") {
                delete.image = resizeActionRow(image: deleteImage, label: deleteLabel)
            }
            delete.backgroundColor = UIColor(hex: 0xED2121)
            
            let swipeAction = UISwipeActionsConfiguration(actions: [delete, forward])
            swipeAction.performsFirstActionWithFullSwipe = false
            return swipeAction
        }
        
        return nil
    }
}

extension MsgCollectionViewController: ActionListDelegate {
  
    func forwardTextIM() {
        if self.selectData.count == 0 {
            UIViewController.showBottomFloatingToast(with: "favourite_msg_delete_at_least".localized, desc: "")
            return
        }
        let messageIds: [String] = self.selectData.compactMap { model in
            model.uniqueId
        }
        
        let configuration = TGContactsPickerConfig(title: "select_contact".localized, rightButtonTitle: "done".localized, allowMultiSelect: true, enableTeam: true, enableRecent: true, enableRobot: false, maximumSelectCount: maximumSendContactCount, excludeIds: [], members: nil, enableButtons: false, allowSearchForOtherPeople: true)
        
        let picker = TGNewContactPickerViewController(configuration: configuration, finishClosure: {  (contacts) in
            NIMSDK.shared().v2MessageService.getMessageList(byIds: messageIds) { messages in
                let accountId = NIMSDK.shared().v2LoginService.getLoginUser() ?? ""
                for contact in contacts {
                    let conversationId = contact.isTeam ? "\(accountId)|2|\(contact.userName)" : "\(accountId)|1|\(contact.userName)"
                    /// 如果本地能全部查询到，直接转发
                    if messageIds.count == messages.count {
                        for originalMessage in messages {
                            let message = V2NIMMessageCreator.createForwardMessage(originalMessage)
                            NIMSDK.shared().v2MessageService.send(message, conversationId: conversationId, params: nil) { _ in
                                
                            } failure: { _ in
                                
                            }
                        }
                    } else {
                        for model in self.selectData {
                            if let v2Message = CollectionMsgDataManager.collectionManager.messageModel(model: model) {
                                NIMSDK.shared().v2MessageService.send(v2Message, conversationId: conversationId, params: nil) { _ in
                                    
                                } failure: { _ in
                                    
                                }
                            }
                        }
                    }
                }
                
            }
        })
        
        self.navigationController?.pushViewController(picker, animated: true)
    }
    func deleteTextIM() {
        self.edit = true
        self.tableView.reloadData()
        self.topView.isHidden = true
        self.tableView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - TSNavigationBarHeight - 50 - TSBottomSafeAreaHeight)
        cancel.isHidden = false
        
        self.selectActionToolbar.setToolbarHidden(false)
        let spacing = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        self.selectedItem.bounds = CGRect(x: 0, y: 0, width: self.selectActionToolbar.bounds.width / 4, height: self.selectActionToolbar.bounds.height)
        let selectedItem1 = UIBarButtonItem(customView: self.selectedItem)
        self.selectActionToolbar.setItems([self.deleteBarButton, spacing, selectedItem1, spacing], animated: true)
        self.updateSelectedItem()
    }
 
}

extension MsgCollectionViewController {
    private func resizeActionRow(image: UIImage, label: UILabel) -> UIImage? {
        let tempView = UIStackView(frame: CGRect(x: 0, y: 0, width: 80, height: 50))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.height))
        tempView.axis = .vertical
        tempView.alignment = .center
        tempView.spacing = 8
        imageView.image = image
        tempView.addArrangedSubview(imageView)
        tempView.addArrangedSubview(label)
        let renderer = UIGraphicsImageRenderer(bounds: tempView.bounds)
        let image = renderer.image { rendererContext in
            tempView.layer.render(in: rendererContext.cgContext)
        }
        return image
    }
}


extension MsgCollectionViewController: UIDocumentInteractionControllerDelegate{
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

    func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        controller.dismissPreview(animated: true)
    }

}
