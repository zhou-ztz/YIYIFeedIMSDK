//
//  TGLocationManager.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/17.
//

import UIKit
import CoreLocation

class TGLocationManager: NSObject {

    static let shared = TGLocationManager()
    private var locationManager = CLLocationManager()
    private var geoCoder = CLGeocoder()
    private let operationQueue = OperationQueue()
    
    var onLocationUpdate: TGEmptyClosure?
    var location: CLLocation? = nil
    var locationCoordinate: CLLocationCoordinate2D? = nil
    var latitude : Double?
    var longitude : Double?
    var shouldPromptAlert: Bool = false
    
    override init() {
        super.init()
    }
    
    func setupLocationService() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 100
        //locationManager.allowsBackgroundLocationUpdates = true
        //locationManager.pausesLocationUpdatesAutomatically = false
        //locationManager.allowDeferredLocationUpdates(untilTraveled: 5, timeout: 60000)
        self.startMonitorLocation()
        
        if getLocationPermissionStatus() == .denied || getLocationPermissionStatus() == .restricted {
            showLocationAlert()
        }
    }
    
    func startMonitorLocation() {
        self.locationManager.startUpdatingLocation()
        self.locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitorLocation() {
        self.locationManager.stopUpdatingLocation()
        self.locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    /// 清除位置数据
    func clearLocationData() {
         location = nil
         locationCoordinate = nil
         latitude = nil
         longitude = nil
    }

    func getLocationPermissionStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    func showLocationAlert() {
        if shouldPromptAlert {
            shouldPromptAlert = false
            
            let alert = UIAlertController(title: "rw_location_limited_permission_fail".localized, message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "settings".localized, style: UIAlertAction.Style.default, handler: { action in
                let url = URL(string: UIApplication.openSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "cancel".localized, style: UIAlertAction.Style.cancel, handler: nil))
            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        }
    }
    
    ///Checks the status of the location permission
    /// and adds the callback block to the queue to run when finished checking
    /// NOTE: Anything done in the UI should be enclosed in `DispatchQueue.main.async {}`
    func runLocationBlock(callback: @escaping () -> ()) {
        
        //Get the current authorization status
        let authState = CLLocationManager.authorizationStatus()
        
        //If we have permissions, start executing the commands immediately
        // otherwise request permission
        if (authState == .authorizedAlways || authState == .authorizedWhenInUse) {
            self.operationQueue.isSuspended = false
        } else {
            //Request permission
            locationManager.requestAlwaysAuthorization()
        }
        
        //Create a closure with the callback function so we can add it to the operationQueue
        let block = { callback() }
        
        //Add block to the queue to be executed asynchronously
        self.operationQueue.addOperation(block)
    }
}

extension TGLocationManager: CLLocationManagerDelegate  {
    ///When the user presses the allow/don't allow buttons on the popup dialogue
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //If we're authorized to use location services, run all operations in the queue
        // otherwise if we were denied access, cancel the operations
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.operationQueue.isSuspended = false
            startMonitorLocation()  // 确保位置服务被重新启动

        } else if status == .denied || status == .restricted {
            self.operationQueue.cancelAllOperations()
            clearLocationData()
            self.showLocationAlert()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
        locationCoordinate = manager.location?.coordinate
        latitude = locationCoordinate?.latitude
        longitude = locationCoordinate?.longitude
        locationManager.stopUpdatingLocation()
        onLocationUpdate?()
    }
}

extension UIApplication {
    class func topViewController(viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(viewController: nav.visibleViewController)
        } else if let tab = viewController as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(viewController: selected)
        } else if let presented = viewController?.presentedViewController {
            return topViewController(viewController: presented)
        } else if let child = viewController?.children.last {
            return child
        }
        
        return viewController
    }
}

