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

    lazy var baseView: UIView = {
        let label = UIView()
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        return label
    }()
    lazy var titleL: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.text = ""
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
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
    let greyView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.bubbleImage.addSubview(baseView)
        self.bubbleImage.addSubview(timeTickStackView)
        baseView.addSubview(mapImage)
        baseView.addSubview(greyView)
        greyView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        greyView.addSubview(titleL)
        
        baseView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview().inset(8)
        }
        timeTickStackView.snp.makeConstraints { make in
            make.top.equalTo(baseView.snp.bottom).offset(6)
            make.right.equalToSuperview().inset(5)
            make.bottom.equalTo(-5)
        }
        mapImage.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(100)
            make.width.equalTo(202)
        }
        
        greyView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(mapImage.snp.bottom)
        }
        
        titleL.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview().inset(5)
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
            titleL.text = object.address
            
            RLMapClient.shared.setMapviewLocation(lat: object.latitude, lng: object.longitude, mapView: mapView)
        }
        
    }

}
