//
//  RLVideoCallViewController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/27.
//

import UIKit
import NIMSDK
import NERtcSDK

class RLVideoCallViewController: RLAudioVideoCallViewController {
    
    override init(callee: String, callType: NIMSignalingChannelType = .audio) {
        super.init(callee: callee, callType: callType)
    }
    
    override init(caller: String, channelId: String, channelName: String, requestId: String, callType: NIMSignalingChannelType = .audio) {
        super.init(caller: caller, channelId: channelId, channelName: channelName, requestId: requestId, callType: callType)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}
