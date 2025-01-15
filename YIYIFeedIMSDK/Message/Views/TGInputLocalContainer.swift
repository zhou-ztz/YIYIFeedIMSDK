//
//  TGInputLocalContainer.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/17.
//

import UIKit
import CoreLocation

class TGInputLocalContainer: UIView {

    lazy var fTableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 0
        tableView.rowHeight = 50
        tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = false
        tableView.register(TGInputLocalContainerCell.self, forCellReuseIdentifier: TGInputLocalContainerCell.cellIdentifier)
        tableView.register(TGNearByLocalContainerCell.self, forCellReuseIdentifier: TGNearByLocalContainerCell.cellIdentifier)
        return tableView
    }()
    
    typealias compliteHandler = (_ isSend: Bool, _ title: String, _ coordinate: CLLocationCoordinate2D) -> Void
    var callBackHandler: compliteHandler?
    var bottomView = UIView()
    var localBtn = UIButton()
    var sendBtn = UIButton()
    var dataArray = [TGLocationModel]()
    var selectIndexPath = IndexPath(row: 0, section: 0)
    var locationName = ""
    
    init(frame: CGRect, callBackHandler: compliteHandler?) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.callBackHandler = callBackHandler
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        TGLocationManager.shared.setupLocationService()
        TGLocationManager.shared.onLocationUpdate = { [weak self] in
            guard let self = self else { return }
            self.getLocaltionData()
        }
        self.getLocaltionData()
        self.addSubview(self.fTableView)
        fTableView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.bottom.equalTo(-40)
        }
        self.bottomView.backgroundColor = .white
        self.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.height.equalTo(40)
            make.bottom.equalTo(0)
        }
        
        bottomView.addSubview(localBtn)
        localBtn.setImage(UIImage.set_image(named: "glyphsSearch"), for: .normal)
        localBtn.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(16)
            make.height.equalToSuperview()
        }
        localBtn.addTarget(self, action: #selector(localAction), for: .touchUpInside)
    }
    
    @objc func localAction() {
        self.callBackHandler!(false, "", TGLocationManager.shared.locationCoordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
    }
    
    //send
    @objc func sendAction() {
        if self.dataArray.count == 0 {
            return
        }
        
        if var myCoordinate = TGLocationManager.shared.locationCoordinate {
            let section = self.selectIndexPath.section
            let row = self.selectIndexPath.row
            if section == 0 {
                let data = self.dataArray.first
                myCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(data?.locationLatitude ?? 0), longitude: CLLocationDegrees(data?.locationLatitude ?? 0))
                locationName = data?.locationName ?? ""
            }else{
                let data = self.dataArray[row + 1]
                myCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(data.locationLatitude ), longitude: CLLocationDegrees(data.locationLatitude ))
                locationName = data.locationName
            }
            self.callBackHandler!(true, locationName, myCoordinate)
        }
    }
    
    func getLocaltionData() {
        if let myCoordinate = TGLocationManager.shared.locationCoordinate {
            TGIMNetworkManager.locationSearchList(queryString: "",lat: myCoordinate.latitude, lng: myCoordinate.longitude) {[weak self] locations, error in
                guard let location = locations else { return }
                DispatchQueue.main.async {
                    self?.dataArray = location
                    self?.fTableView.reloadData()
                }
            }
        }
    }
}

extension TGInputLocalContainer : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataArray.count == 0 {
            return 0
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.dataArray.count == 0 {
                return 0
            }
            return 1
        }
        if self.dataArray.count <= 1 {
            return 0
        }
        return  self.dataArray.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TGNearByLocalContainerCell.cellIdentifier, for: indexPath) as! TGNearByLocalContainerCell
            cell.selectionStyle = .none
            cell.setData(data: self.dataArray[indexPath.row + 1])
            
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: TGInputLocalContainerCell.cellIdentifier, for: indexPath) as! TGInputLocalContainerCell
        cell.selectionStyle = .none
        
        cell.setData(data: self.dataArray.first)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if var myCoordinate = TGLocationManager.shared.locationCoordinate {
            let section = indexPath.section
            let row = indexPath.row
            if section == 0 {
                let data = self.dataArray.first
                myCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(data?.locationLatitude ?? 0), longitude: CLLocationDegrees(data?.locationLongtitude ?? 0))
                locationName = data?.locationName ?? ""
            }else{
                let data = self.dataArray[row + 1]
                myCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(data.locationLatitude ), longitude: CLLocationDegrees(data.locationLongtitude ))
                locationName = data.locationName
            }
            self.callBackHandler!(true, locationName, myCoordinate)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        view.frame = CGRect(x: 0, y: 0, width: self.width, height: 30)
        let name = UILabel()
        name.text = "your_current_location".localized
        name.textColor = UIColor(red: 195, green: 195, blue: 195)
        name.setFontSize(with: 12, weight: .norm)
        name.frame = CGRect(x: 12, y: 0, width: 150, height: 30)
        view.addSubview(name)
        if section > 0 {
            name.text = "nearby_location".localized
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

