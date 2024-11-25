//
//  RLMapClient.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/25.
//

import UIKit
import MapKit

class RLMapClient: NSObject {
    
    public static let shared = RLMapClient()
    
    override init() {
        super.init()
    }
    
    func setupMapSdkConfig(appkey: String) {
//        QMapServices.shared().setPrivacyAgreement(true)
//        QMapServices.shared().apiKey = appkey
//        QMSSearchServices.shared().apiKey = appkey
    }
    
    func getCellMapView() -> MKMapView? {
        
        let mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: 222, height: 100))
        mapView.showsUserLocation = false
        //mapView.zoomLevel = 15
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.isZoomEnabled = false
        mapView.isUserInteractionEnabled = false
        
        return mapView
    }
    
    func setMapviewLocation(lat: Double, lng: Double, mapView: MKMapView?){
        mapView?.setCenter(CLLocationCoordinate2DMake(lat, lng), animated: false)
    }

}
