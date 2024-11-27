//
//  RLAudioVideoCallViewController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/27.
//

import UIKit
import NERtcSDK
import NIMSDK

class RLAudioVideoCallViewController: RLViewController {
    
    let viewmodel: AudioVideoViewModel = AudioVideoViewModel()
    
    init(callee: String, callType: NIMSignalingChannelType = .audio) {
        self.viewmodel.callInfo.callType = callType
        self.viewmodel.callInfo.isCaller = true
        self.viewmodel.callInfo.callee = callee
        self.viewmodel.callInfo.caller = NIMSDK.shared().loginManager.currentAccount()
        super.init(nibName: nil, bundle: nil)
        
    }
    
    init(caller: String, channelId: String, channelName: String, requestId: String, callType: NIMSignalingChannelType = .audio) {
        self.viewmodel.callInfo.callType = callType
        self.viewmodel.callInfo.isCaller = false
        self.viewmodel.callInfo.caller = caller
        self.viewmodel.callInfo.callee = NIMSDK.shared().loginManager.currentAccount()
        self.viewmodel.callInfo.channelId = channelId
        self.viewmodel.callInfo.channelName = channelName
        self.viewmodel.callInfo.requestId = requestId
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.isHidden = true
        self.view.backgroundColor = UIColor(hex: 0x1E1E1E)
    }
    
    deinit {
        viewmodel.removeAllObserver()
    }
    

}
