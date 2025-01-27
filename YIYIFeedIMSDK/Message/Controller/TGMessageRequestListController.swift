//
//  TGMessageRequestListController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/13.
//

import UIKit

class TGMessageRequestListController: TGViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        commitUI()
    }
    
    func commitUI(){
        self.customNavigationBar.backItem.setTitle("message_request_title".localized, for: .normal)
       
    }
}
