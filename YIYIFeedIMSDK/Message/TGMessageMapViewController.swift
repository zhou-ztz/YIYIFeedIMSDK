//
//  TGMessageMapViewController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/9.
//

import UIKit
import MapKit
import CoreLocation

class TGMessageMapViewController: TGViewController, CLLocationManagerDelegate, MKMapViewDelegate  {

    var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var coordinate: CLLocationCoordinate2D?
    var titleString: String = ""
    var sendBlock: ((ChatLocaitonModel) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.isHidden = false
        let barItem = UIButton()
        barItem.setTitle("发送", for: .normal)
        barItem.setTitleColor(RLColor.share.theme, for: .normal)
        barItem.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        barItem.addTarget(self, action: #selector(sendClick), for: .touchUpInside)
        customNavigationBar.setRightViews(views: [barItem])
        // 初始化地图
        mapView = MKMapView(frame: CGRect(x: 0, y: TSNavigationBarHeight, width: ScreenWidth, height: ScreenHeight - TSNavigationBarHeight))
        mapView.delegate = self
        mapView.showsUserLocation = true // 显示当前位置
        mapView.userTrackingMode = .follow // 跟踪用户位置
        self.view.addSubview(mapView)
        
        // 初始化 CLLocationManager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // 高精度定位
        
        // 请求授权
        locationManager.requestWhenInUseAuthorization()
        
        // 检查权限并开始定位
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc func sendClick(){
        
        if let data = self.coordinate {
            let model = ChatLocaitonModel()
            model.lat = data.latitude
            model.lng = data.longitude
            model.address = titleString
            model.title = titleString
            self.sendBlock?(model)
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // CLLocationManagerDelegate 方法：更新位置
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        
        // 更新地图的中心位置
        let gcj02Coordinate = currentLocation.coordinate.wgs84ToGCJ02()
        print("WGS84 坐标系转换为 GCJ-02 坐标系：\(gcj02Coordinate.latitude), \(gcj02Coordinate.longitude)")
        let gcj02location = CLLocation(latitude: gcj02Coordinate.latitude, longitude: gcj02Coordinate.longitude)
        let regionRadius: CLLocationDistance = 1000
        self.coordinate = gcj02Coordinate
        centerMapOnLocation(location: gcj02location, radius: regionRadius)
        self.geocoderCoordinate(coordinate: currentLocation.coordinate)
        print("当前位置：\(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
    }
    
    // CLLocationManagerDelegate 方法：处理定位失败
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("定位失败：\(error.localizedDescription)")
    }
    
    //
    func geocoderCoordinate(coordinate: CLLocationCoordinate2D){
        // 创建 CLLocation 对象
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        // 调用反向地理编码
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("反向地理编码失败：\(error.localizedDescription)")
                return
            }
            
            // 处理获取的地理信息
            if let placemarks = placemarks, let placemark = placemarks.first {
                // 输出地址信息
                let country = placemark.country ?? "未知国家"
                let administrativeArea = placemark.administrativeArea ?? "未知省份"
                let locality = placemark.locality ?? "未知城市"
                let thoroughfare = placemark.thoroughfare ?? "未知街道"
                let subThoroughfare = placemark.subThoroughfare ?? "未知门牌号"
                
                print("国家：\(country)")
                print("省份：\(administrativeArea)")
                print("城市：\(locality)")
                print("街道：\(thoroughfare)")
                print("门牌号：\(subThoroughfare)")
                self.titleString = "\(country)\(administrativeArea)\(locality)\(thoroughfare)"
                // 拼接完整地址
                let fullAddress = "\(country) \(administrativeArea) \(locality) \(thoroughfare) \(subThoroughfare)"
                print("完整地址：\(fullAddress)")
            }
        }
    }
    
    func centerMapOnLocation(location: CLLocation, radius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}

extension CLLocationCoordinate2D {
    func wgs84ToGCJ02() -> CLLocationCoordinate2D {
        let pi = 3.14159265358979324
        let ee = 0.00669342162296594323
        let a = 6378245.0
        _ = 0.000001

        var dLat = transformLat(x: self.longitude - 105.0, y: self.latitude - 35.0)
        var dLon = transformLon(x: self.longitude - 105.0, y: self.latitude - 35.0)
        let radLat = self.latitude / 180.0 * pi
        var magic = sin(radLat)
        magic = 1 - ee * magic * magic
        let sqrtMagic = sqrt(magic)
        dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi)
        dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi)
        return CLLocationCoordinate2D(latitude: self.latitude + dLat, longitude: self.longitude + dLon)
    }

    func transformLat(x: Double, y: Double) -> Double {
        let pi = 3.14159265358979324
        _ = 0.00669342162296594323
        _ = 6378245.0
        var ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x))
        ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0
        ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0
        ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0
        return ret
    }

    func transformLon(x: Double, y: Double) -> Double {
        let pi = 3.14159265358979324
        _ = 0.00669342162296594323
        _ = 6378245.0
        var ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x))
        ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0
        ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0
        ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0
        return ret
    }
}
