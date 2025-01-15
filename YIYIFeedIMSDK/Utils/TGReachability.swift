//
//  TGReachability.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/2.
//

import UIKit
import Reachability

enum TGReachabilityStatus {
    case WIFI
    case Cellular
    case NotReachable
}

@objc class TGReachability: NSObject {
    let reachability = Reachability.forInternetConnection()
    var reachabilityStatus = TGReachabilityStatus.NotReachable
    static let share = TGReachability()
    private override init() {}

    func startNotifier() {
        guard let reachability = reachability else {
            return
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: Notification.Name.reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            assert(false, "could not start reachability notifier")
        }
    }
    
    func isReachable () -> Bool{
        if reachability?.currentReachabilityStatus() == .ReachableViaWWAN
            || reachability?.currentReachabilityStatus() == .ReachableViaWiFi {
            return true
        }else {
            return false
        }
    }

    @objc func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as? Reachability

        if (reachability?.currentReachabilityStatus() == .ReachableViaWWAN
            || reachability?.currentReachabilityStatus() == .ReachableViaWiFi) {
            if (reachability!.currentReachabilityStatus() == .ReachableViaWiFi) {
                reachabilityStatus = .WIFI
            } else {
                reachabilityStatus = .Cellular
            }
        } else {
            reachabilityStatus = .NotReachable
        }
        //  [warning] 只有网络变动才会发送通知
        //NotificationCenter.default.post(name: Notification.Name.Reachability.Changed, object: self)
    }
    
    @objc func getNetStatus() -> String {

        if ((reachability?.isReachableViaWiFi) != nil){
            return "WIFI"
        }else if ((reachability?.isReachableViaWWAN) != nil){
            return "4G"
        }
        return ""
    }
}
