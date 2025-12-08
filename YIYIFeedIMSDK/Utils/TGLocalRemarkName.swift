//
//  TGLocalRemarkName.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2024/12/31.
//

import UIKit

class TGLocalRemarkName: NSObject {
    static func getRemarkName (userId:String?, username:String?, originalName:String? ,label: UILabel?) -> String {
        // MARK: REMARK NAME
        if let userRemarkName =  UserDefaults.standard.array(forKey: "UserRemarkName") {
            
            let remarkNameArray = userRemarkName as! [[String:String]]
            var remarkName: [String:String]?
            
            if userId == nil {
                remarkName = remarkNameArray.filter { $0["username"] == "\(username ?? "")"}.first
            } else {
                remarkName = remarkNameArray.filter { $0["userID"] == "\(userId ?? "")"}.first
            }
            
            if let remarkNameString = remarkName {
                if label == nil {
                    return remarkNameString["remarkName"]!
                }

                label!.text = remarkNameString["remarkName"]
            } else {
                if let username = originalName {
                    if label == nil {
                        return username
                    }
                    label!.text = username
                } else {
                    if label == nil {
                        if originalName == nil {
                            return ""
                        }
                        return originalName!
                    }
                    label!.text = ""
                }
            }
            
        } else {
            if let username = originalName {
                if label == nil {
                    return username
                }
                label!.text = username
            } else {
                if label == nil {
                    if originalName == nil {
                        return ""
                    }
                    return originalName!
                }
                label!.text = ""
            }
        }
        
        return ""
    }

}
