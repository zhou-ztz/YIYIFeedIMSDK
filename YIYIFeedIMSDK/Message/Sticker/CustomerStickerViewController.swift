//
//  CustomerStickerViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2020/12/22.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class CustomerStickerViewController: TGViewController {
    var isEdit = false
    var rightBtn = UIButton()
    var editBtn = UIButton()
    var deleteBtn = UIButton()
    var bottomView = UIView()
    var tipLable = UILabel()
    var dataArray : [CustomerStickerItem] = []
    var selectArray : [CustomerStickerItem] = []
    public var stickerId: String = ""
    lazy var collectionView: UICollectionView = {
        let collectionLayout = UICollectionViewFlowLayout.init()
        let rect = CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height - TSNavigationBarHeight )
        collectionLayout.itemSize = CGSize(width: (self.view.width - 10) / 4.0, height: (self.view.width - 10) / 4.0)
        let col = UICollectionView(frame: rect, collectionViewLayout: collectionLayout)
        col.delegate = self
        col.dataSource = self
        col.backgroundColor = UIColor(red: 247, green: 247, blue: 247)
        col.showsVerticalScrollIndicator = false
        col.register(CustomerStickerViewCell.self, forCellWithReuseIdentifier: CustomerStickerViewCell.cellIdentifier)
        return col
    }()
    
    public func downloadWith(stickerId: String) {
        print("stickerId = \(stickerId)")
        if stickerId == "" {
            return
        }
        for sticker in self.dataArray {
            if sticker.customStickerId == stickerId {
                return
            }
        }
        //没有就下载该贴图
        StickerManager.shared.downloadCustomerSticker(stickerId: stickerId) { (complete, error, msg) in
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.backItem.setTitle("text_custom_sticker".localized, for: .normal)
      
        rightBtn.setImage(UIImage.set_image(named: "sort"), for: .normal)
        rightBtn.addTarget(self, action: #selector(editAction), for: .touchUpInside)
        
        editBtn.setTitle("done".localized, for: .normal)
        editBtn.setTitleColor(UIColor(red: 155, green: 155, blue: 155), for: .normal)
        editBtn.titleLabel?.setFontSize(with: 15, weight: .norm)
        editBtn.addTarget(self, action: #selector(editBtnAction), for: .touchUpInside)
        self.customNavigationBar.setRightViews(views: [rightBtn])
        self.backBaseView.addSubview(self.collectionView)
        setUI()
        StickerManager.shared.delegate = self
        self.getData()
    }
    
    init(sticker: String) {
        super.init(nibName: nil, bundle: nil)
        self.stickerId = sticker
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getData() {
        guard let userID = RLSDKManager.shared.loginParma?.uid else { return }
        let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        if !FileManager.default.fileExists(atPath: documentsPath + "/customerSticker/" + "/\(userID)/" ) {
            StickerManager.shared.fetchMyCustomerStickers(first: 10000, after: "") { [weak self] (stickerItems) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let stickerItems = stickerItems {
                        self.dataArray = stickerItems
                        self.collectionView.reloadData()
                    }
                }
            }
        } else {
            StickerManager.shared.getCustomerStickerList { [weak self] (stickerItems) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let stickerItems = stickerItems {
                        self.dataArray = stickerItems
                        self.collectionView.reloadData()
                        //StickerManager.shared.saveServeToLocal()
                    }
                }
            }
        }
    }
    
    func setUI() {
        bottomView.isHidden = true
        bottomView.backgroundColor = .white
        self.backBaseView.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(50 + TSBottomSafeAreaHeight)
        }
        let lable = UILabel()
        lable.text = "text_move_to_front".localized
        lable.textColor = UIColor(red: 155, green: 155, blue: 155)
        lable.setFontSize(with: 14, weight: .norm)
        bottomView.addSubview(lable)
        lable.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(15)
            make.height.equalTo(50)
        }
        lable.addTap { [weak self] (_) in
            self?.moveToFront()
        }
        self.tipLable = lable
        let delete = UIButton()

        delete.setImage(UIImage.set_image(named: "ic_delete_sticker"), for: .normal)
        bottomView.addSubview(delete)
        delete.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        delete.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.height.equalTo(50)
            make.right.equalTo(-2)
            make.width.equalTo(47)
        }
        self.deleteBtn = delete
        self.deleteBtn.isEnabled = false
    }
    
    func moveToFront() {
        var temArray = [CustomStickerInput]()
        var index = selectArray.count
        for sticker in selectArray.reversed() {
            let stickerInput = CustomStickerInput(customStickerId: sticker.customStickerId ?? "", sequence: index)
            temArray.append(stickerInput)
            index = index - 1
        }
        
        if temArray.count == 0 {
            return
        }
       // self.displayActivityIndicator(shouldDisplay: true)
        StickerManager.shared.sortCustomerStickers(custom_stickers: temArray) { [weak self] (complete) in
            guard let self = self else { return }
            //self.displayActivityIndicator(shouldDisplay: false)
            if complete {
                DispatchQueue.main.async {
                    //删除数据源
                    for sticker in self.selectArray {
                        if let index = self.dataArray.index(of: sticker) {
                            self.dataArray.remove(at: index)
                        }
                    }
                    self.dataArray.insert(contentsOf: self.selectArray, at: 0)
                    //删除本地
                    StickerManager.shared.sortLocalCustomerStickers(custom_stickers: self.selectArray)
                    //刷新UI
                    self.collectionView.reloadData()
                    self.selectArray.removeAll()
                    self.deleteBtn.isEnabled = self.selectArray.count ?? 0 > 0
                    self.tipLable.textColor = self.selectArray.count ?? 0 > 0 ? .black : UIColor(red: 155, green: 155, blue: 155)
                }
            }
        }
    }
    
    @objc func deleteAction() {
        var temArray = [String]()
        for sticker in selectArray {
            temArray.append(sticker.customStickerId ?? "")
        }
        
        if temArray.count == 0 {
            return
        }
       // self.displayActivityIndicator(shouldDisplay: true)
        StickerManager.shared.removeCustomerStickers(stickerIds: temArray) { [weak self] (complete) in
            guard let self = self else { return }
           // self.displayActivityIndicator(shouldDisplay: false)
            if complete {
                DispatchQueue.main.async {
                    for stickerId in temArray {
                        //删除本地
                        StickerManager.shared.deleteLocalWithStickerId(sticlerId: stickerId)
                    }
                    
                    //删除数据源
                    for sticker in self.selectArray {
                        if let index = self.dataArray.index(of: sticker) {
                            self.dataArray.remove(at: index)
                            self.collectionView.deleteItems(at: [IndexPath(row: index + 1, section: 0)])
                        }
                    }
                    
                    self.selectArray.removeAll()
                    self.deleteBtn.isEnabled = self.selectArray.count ?? 0 > 0
                    self.tipLable.textColor = self.selectArray.count ?? 0 > 0 ? .black : UIColor(red: 155, green: 155, blue: 155)
                }
            } else {
               // self.showError(message: "network_is_not_available".localized)
            }
        }
    }
    
    @objc func editBtnAction() {
        isEdit = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        collectionView.height = self.view.height
        bottomView.isHidden = true
        self.collectionView.reloadData()
    }
    
    //编辑
    @objc func editAction() {
        isEdit = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editBtn)
        collectionView.height = self.view.height  - 50 - TSBottomSafeAreaHeight
        bottomView.isHidden = false
        self.collectionView.reloadData()
    }
    
    //添加
    func addCustomerSticker() {
        
    }
}

extension CustomerStickerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: CustomerStickerViewCell.cellIdentifier, for: indexPath) as! CustomerStickerViewCell
        cell.delegate = self
        
        cell.icon.isHidden = indexPath.item > 0
        cell.bgImage.isHidden = indexPath.item == 0
        cell.selectBtn.isHidden = true
        if indexPath.item > 0 {
            cell.selectBtn.isHidden = !isEdit
            let sticker = self.dataArray[indexPath.row - 1]
            cell.setSticker(sticker: sticker, indexPath: indexPath)
            if self.selectArray.index(of: sticker) != nil {
                cell.selectBtn.isSelected = true
            } else {
                cell.selectBtn.isSelected = false
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //点击相机
        if indexPath.item == 0 {
            self.addCustomerSticker()
        } else {
            if isEdit {
                let sticker = self.dataArray[indexPath.row - 1]
                if let index = self.selectArray.firstIndex(where: { $0.customStickerId == sticker.customStickerId }){
                    self.selectArray.remove(at: index)
                } else {
                    self.selectArray.append(sticker)
                }
                
                if self.selectArray.count > 0 {
                    editBtn.setTitleColor(UIColor(red: 59, green: 179, blue: 255), for: .normal)
                    self.tipLable.textColor = .black
                    
                } else {
                    editBtn.setTitleColor(UIColor(red: 155, green: 155, blue: 155), for: .normal)
                    self.tipLable.textColor = UIColor(red: 155, green: 155, blue: 155)
                }
                
                self.deleteBtn.isEnabled = self.selectArray.count > 0
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return  UIEdgeInsets(top: 2, left: 2, bottom: 0, right: 0)
    }
    
    //    MARK: - 行最小间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    //    MARK: - 列最小间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}



extension CustomerStickerViewController: CustomerStickerViewCellDelegate{
    func selectItem(indexPath: IndexPath) {
        if isEdit {
            let sticker = self.dataArray[indexPath.row - 1]
            
            if let index = self.selectArray.firstIndex(where: { $0.customStickerId == sticker.customStickerId }){
                self.selectArray.remove(at: index)
            } else {
                self.selectArray.append(sticker)
            }
            
            if self.selectArray.count > 0 {
                editBtn.setTitleColor(UIColor(red: 59, green: 179, blue: 255), for: .normal)
                self.tipLable.textColor = .black
                
            } else {
                editBtn.setTitleColor(UIColor(red: 155, green: 155, blue: 155), for: .normal)
                self.tipLable.textColor = UIColor(red: 155, green: 155, blue: 155)
            }
            
            self.deleteBtn.isEnabled = self.selectArray.count > 0
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
}

extension CustomerStickerViewController: StickerManagerDelegate {
    func stickerDidRemoved(id: String) {
        
    }
    
    func stickerDidDownloaded(id: String) {
        
    }
    
    func downLoadCustomerSticker(sticker: CustomerStickerItem) {
        self.dataArray.insert(sticker, at: 0)
        self.collectionView.insertItems(at: [IndexPath(row: 1, section: 0)])
    }
}
