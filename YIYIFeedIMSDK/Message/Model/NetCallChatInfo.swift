//
//  NetCallChatInfo.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/27.
//

import UIKit
import NIMSDK
class NetCallChatInfo: NSObject {

    var caller: String? //呼叫方的 accid
    var callee: String? // 接听方的 accid
    var callID: UInt64?
    var channelId: String?
    var channelName: String?
    var requestId: String?
    var callType: NIMSignalingChannelType = .audio
    var startTime: TimeInterval?
    var isStart: Bool? = false
    var isMute: Bool? = false
    var useSpeaker: Bool? = false
    var disableCammera: Bool? = false
    var localRecording: Bool? = false
    var otherSideRecording: Bool? = false
    var audioConversation: Bool? = false
    var isCaller: Bool = false
}
