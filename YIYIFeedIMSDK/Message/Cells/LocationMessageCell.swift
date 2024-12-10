//
//  LocationMessageCell.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/12.
//

import UIKit
import NIMSDK
import MapKit
class LocationMessageCell: BaseMessageCell {

    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = RLColor.share.lightGray
        label.text = "内容"
        label.numberOfLines = 1
        return label
    }()
    lazy var titleL: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = RLColor.share.black3
        label.text = "标题"
        label.numberOfLines = 1
        return label
    }()
    lazy var mapImage: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var piontImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.set_image(named: "ic_location")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    var mapView: MKMapView?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.bubbleImage.addSubview(titleL)
        self.bubbleImage.addSubview(contentLabel)
        self.bubbleImage.addSubview(mapImage)
        titleL.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview().inset(10)
        }
        contentLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalTo(titleL.snp.bottom).offset(2)
        }
        
        mapImage.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(contentLabel.snp.bottom).offset(4)
            make.height.equalTo(100)
            make.width.equalTo(222)
        }
        
        if let map = RLMapClient.shared.getCellMapView() {
            mapImage.addSubview(map)
            mapView = map
            mapView?.bindToEdges()
        }
        mapImage.addSubview(piontImage)
        piontImage.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(40)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(20)
        }
    }
    
    override func setData(model: TGMessageData) {
        super.setData(model: model)
        if let message = model.nimMessageModel, let object = message.attachment as? V2NIMMessageLocationAttachment {
            titleL.text = message.text
            contentLabel.text = object.address
            RLMapClient.shared.setMapviewLocation(lat: object.latitude, lng: object.longitude, mapView: mapView)
        }
        
    }

}
