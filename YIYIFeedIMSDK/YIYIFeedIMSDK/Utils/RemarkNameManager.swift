//
//  RemarkNameManager.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/3/21.
//

import Foundation
import Apollo

class RemarkNameManager {
    
    static let shared = RemarkNameManager()
    
    func setRemarkName(for id:Int, username:String, remarkName:String) {
        let mutation = InsertUpdateUserRemarkMutation(target_id: id, target_username: username, remark_name: remarkName)
        
        YPApolloClient.perform(mutation: mutation) { (response, error) in
            guard error == nil else {
                // show fail loading
                return
            }
            NotificationCenter.default.post(name: Notification.Name("RefreshRemarkName"), object: nil)
        }
    }
    
    func removeRemarkName (for id:Int) {
        let mutation = RemoveUserRemarkMutation(target_id: id)
        YPApolloClient.perform(mutation: mutation) { (response, error) in
            guard error == nil else {
                // show fail loading
                return
            }
            NotificationCenter.default.post(name: Notification.Name("RefreshRemarkName"), object: nil)
        }
    }
    
    func getRemarkName(for id: Int) {
        let query = FetchRemarksQuery(owner_id: id)
        YPApolloClient.fetch(query: query) { (response, error) in
            guard error == nil else {
                return
            }
            
            var tableData = [[String:String]]()
            
            guard let obj = response?.data?.fetchRemarks.compactMap({ $0.jsonObject.jsonValue }),
                  let data = try? JSONSerialization.data(withJSONObject: obj),
                  let remarkObjArray = try? JSONDecoder().decode([RemarkName].self, from: data) else {
                return
            }
            
            for remark in remarkObjArray {
                tableData.append(["userID": "\(remark.targetID)","username":remark.targetUsername,"remarkName":remark.remarkName])
            }
            UserDefaults.standard.set(tableData, forKey: "UserRemarkName")
            NotificationCenter.default.post(name: Notification.Name("RefreshRemarkName"), object: nil)
            
        }
    }
    
    
}

struct RemarkName: Decodable {
    
    public let targetID: Int
    public let targetUsername: String
    public let remarkName: String
    
    enum CodingKeys: String, CodingKey {
        case targetID = "target_id"
        case targetUsername = "target_username"
        case remarkName = "remark_name"
    }
}

