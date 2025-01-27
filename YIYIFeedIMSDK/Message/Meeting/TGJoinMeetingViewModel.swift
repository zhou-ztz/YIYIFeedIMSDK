//
//  TGJoinMeetingViewModel.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/24.
//

import UIKit
import NEMeetingKit

class TGJoinMeetingViewModel: NSObject {

    //会议是否付年费 0 无 1 已付
    var level: Int = 0
    //会议时长
    var meetingMemberLimit: Int = 0
    var meetingTimeLimit: Int = 0
    // 房间id
    var roomUuid: String = ""
    //开始时间
    var startTime: Int = 0
    //剩余会议时长
    var duration: Int = 0
    var meetingNum: String = ""
    //是否私密会议
    var isPrivate: Bool = false
    
    var isUnMute: Bool = false
    var isOnCamera: Bool = false
    
    override init() {
        super.init()
    }
    
    func addObserver() {
        NEMeetingKit.getInstance().getMeetingService().add(self as NEMeetingStatusListener)
    }
    
    deinit {
        NEMeetingKit.getInstance().getMeetingService().remove(self as NEMeetingStatusListener)
        guard let roomContext = NERoomKit.shared().roomService.getRoomContext(roomUuid: self.roomUuid) else {
              return
        }
        roomContext.removeRoomListener(listener: self)
    }
    
    ///获取当前会议信息
    func getCurrentMeetingInfo(completion: @escaping (NEMeetingInfo?) ->Void) {
        NEMeetingKit.getInstance().getMeetingService().getCurrentMeetingInfo { code, message, meetingInfo in
            completion(meetingInfo)
        }
    }
    
    ///meetingkit 登录
    func meetingkitLogin(username: String, password: String, completion: @escaping (Int, String?) ->Void){
        NEMeetingKit.getInstance().getAccountService().login(byToken: username, token: password) { code, msg, accountInfo in
            completion(code, msg)
        }
    }
    
    ///后端接口加入会议- 会议记录
    func joinMeetingApi(meetingNum: String, completion: @escaping (_ requestdata: JoinMeetingResponse?, _ error: Error?) ->Void){
        
        TGIMNetworkManager.joinMeeting(meetingNum: meetingNum) { requestdata, error in
            completion(requestdata, error)
        }
        
    }
    
    ///加入会议 - sdk
    func joinInMeeting(meetingID: String, password: String, completion: @escaping (_ requestdata: JoinMeetingResponse?, _ code: Int, _ msg: String?) ->Void){
        
        let params = NEJoinMeetingParams() //会议参数
        params.meetingNum = meetingID
        params.displayName = RLSDKManager.shared.loginParma?.imAccid ?? ""
        params.password = password
        //会议选项，可自定义会中的 UI 显示、菜单、行为等
        let options = NEJoinMeetingOptions()
        options.noVideo = isOnCamera //入会时关闭视频，默认为 YES
        options.noAudio = isUnMute //入会时关闭音频，默认为 YES
        options.noInvite = false                    //入会隐藏"邀请"按钮，默认为 NO
        options.noChat = false                      //入会隐藏"聊天"按钮，默认为 NO
        options.noWhiteBoard = false                               //入会隐藏白板入口，默认为 NO
        options.noGallery = false                                //入会隐藏设置"画廊模式"入口，默认为 NO
        options.noSwitchCamera = false                             //入会隐藏"切换摄像头"功能入口，默认为 NO
        options.noSwitchAudioMode = false                           //入会隐藏"切换音频模式"功能入口，默认为 NO
        options.noRename = false                                   //入会隐藏"改名"功能入口，默认为 NO
        options.meetingElapsedTimeDisplayType = .MEETING_ELAPSED_TIME                            //设置入会后是否显示会议持续时间，默认为 NO
        
        options.noMinimize = true                                 //入会是否允许最小化会议页面，默认为 YES
        options.defaultWindowMode = NEMeetingWindowMode.gallery         //入会默认会议视图模式
        options.meetingIdDisplayOption = .DISPLAY_ALL  //设置会议中会议 ID 的显示规则，默认为全部显示
        options.noSip = false                                        //会议是否支持 SIP 用户入会，默认为 NO
        options.showMeetingRemainingTip = true                     //会议中是否开启剩余时间（秒）提醒，默认为 NO
        
        let chatroomConfig = NEMeetingChatroomConfig() //配置聊天室
        chatroomConfig.enableFileMessage = true //是否允许发送/接收文件消息，默认为 YES
        chatroomConfig.enableImageMessage = true //是否允许发送/接收图片消息，默认为 YES
        options.chatroomConfig = chatroomConfig
        //在MoreMenus里面添加自定义菜单
        if isPrivate {
            MessageUtils.configMoreMenus(options: options)
        }
 
        let meetingServce = NEMeetingKit.getInstance().getMeetingService()
        meetingServce.joinMeeting(params, opts: options, callback: { resultCode, resultMsg, result in
            completion(nil, resultCode, resultMsg)
        })
    }
    
    func leaveMeetingRoom() {
        NEMeetingKit.getInstance().getMeetingService().leaveCurrentMeeting(false) { _, _, _ in
            
        }
    }
    
}

extension TGJoinMeetingViewModel: NEMeetingStatusListener {
    
    func onMeetingStatusChanged(_ event: NEMeetingEvent) {
        
        if event.status == .MEETING_STATUS_DISCONNECTING || event.status == .MEETING_STATUS_IDLE {
           // self.delegate?.leaveMeetingRoom()
        }
    }
    
}

extension TGJoinMeetingViewModel: NERoomListener {
    func onMemberJoinRoom(members: [NERoomMember]) {
    }
    
    func onMemberLeaveRoom(members: [NERoomMember]) {
    }
    
    func onMemberJoinRtcChannel(members: [NERoomMember]) {
        //if self.meetingLevel == 0 {
          //  self.delegate?.updateMemberRoom()
      //  }
    }
}
