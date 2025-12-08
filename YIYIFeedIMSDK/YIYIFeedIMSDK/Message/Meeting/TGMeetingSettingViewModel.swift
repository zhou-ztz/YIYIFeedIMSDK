//
//  TGMeetingSettingViewModel.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/22.
//

import UIKit
import NEMeetingKit
import NIMSDK

enum MeetingCreateType: Int {
    /*会议类型。
     1：使用随机号创建的即时会议。
     2：使用个人号创建的即时会议。
     3：使用随机号预约的会议。*/
    case random      = 1
    case personal    = 2
    case orderRandom = 3
}

protocol TGMeetingSettingViewModelDelegate: AnyObject {
    /// 更新会议成员
    func updateMemberRoom()
    /// 离开会议
    func leaveMeetingRoom()
}

class TGMeetingSettingViewModel: NSObject {
    
    var meetingInfo: CreateMeetingInfo?
    
    //会议等级 0 免费 1 付过年费
    var meetingLevel: Int = 0
    //剩余会议时长
    var duration: Int = 0
    //会议人数限制
    var meetingNumlimit: Int = 50
    //开始时间
    var startTime: Int = 0
    //会议总时长
    var meetingTimeLimit: Int = 0
    
    var meetingId: Int?
    var meetingNum: String?
    var roomUuid: Int = 0
    var dataSource: [ContactData] = []
    
    weak var delegate: TGMeetingSettingViewModelDelegate?
    
    override init() {
        super.init()
        addObserver()
    }
    
    func addObserver() {
        NEMeetingKit.getInstance().getMeetingService().add(self as NEMeetingStatusListener)
    }
    
    deinit {
        NEMeetingKit.getInstance().getMeetingService().remove(self as NEMeetingStatusListener)
        guard let roomContext = NERoomKit.shared().roomService.getRoomContext(roomUuid: self.roomUuid.stringValue) else {
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
    
    //创建会议
    func createMeeting(meetingName: String, password: String, priviteInvite: Bool = false, completion: @escaping (_ requestdata: CreateMeetingResponse?, _ error: Error?) ->Void){
        let user = RLSDKManager.shared.loginParma?.imAccid ?? ""
        var userDict: [String: String] = ["\(user)": "host"]
        var members: [String] = []
        var groupIds: [String] = []
        for source in dataSource {
            if !source.isTeam {
                userDict["\(source.userName)"] = "member"
                members.append(source.userName)
            }else{
                groupIds.append(source.userName)
            }
        }
        members.append(user)
        
        let group = DispatchGroup()
        
        //遍历邀请的群成员
        for username in groupIds {
            group.enter()
            MessageUtils.fetchMembersTeam(teamId: username) { users in
                members.append(contentsOf: users)
                group.leave()
            }
        }
        
        group.notify(queue: .global()) {
            //去重
            let members1 = Array(Set(members))
            let dict: [String : Any]  = ["type": MeetingCreateType.random.rawValue, "subject": meetingName, "password": password, "nickName": user, "roleBinds": userDict,
                                          "isPrivate": priviteInvite ? 1 : 0,
                                          "privateOption": ["members": members1, "groupIds": groupIds],
                                          "roomConfig": ["resource": [
                                            "whiteboard": true,
                                            "chatroom": true,
                                            "rtc": true,
                                            "live": false,
                                            "record": false,
                                            "sip": false
                                          ]],
                                          "roomProperties": [
                                            //"audioOff": ["value": "none"],
                                            //"videoOff": ["value": "none"]
                                          ]]
            print("dict =\(dict)")
            
            TGIMNetworkManager.createMeeting(param: dict) { requestdata, error in
                completion(requestdata, error)
            }
        }
        
        
    }
    
    ///后端接口加入会议- 会议记录
    func joinMeetingApi(meetingNum: String, data: CreateMeetingInfo, completion: @escaping (_ requestdata: JoinMeetingResponse?, _ error: Error?) ->Void){
        
        TGIMNetworkManager.joinMeeting(meetingNum: meetingNum) { requestdata, error in
            completion(requestdata, error)
        }
        
    }
    
    ///加入会议 - sdk
    func joinInMeeting(meetingID: String, password: String, noVideo: Bool = true, noAudio: Bool = true, data: CreateMeetingInfo, isPrivate: Bool = false, completion: @escaping (_ requestdata: JoinMeetingResponse?, _ code: Int, _ msg: String?) ->Void){
        
        let params = NEJoinMeetingParams() //会议参数
        params.meetingNum = meetingID
        params.displayName = RLSDKManager.shared.loginParma?.imAccid ?? ""
        params.password = password
        //会议选项，可自定义会中的 UI 显示、菜单、行为等
        let options = NEJoinMeetingOptions()
        options.noVideo = noVideo //入会时关闭视频，默认为 YES
        options.noAudio = noAudio //入会时关闭音频，默认为 YES
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
    
    func addNeRoomListener() {
        guard let roomContext = NERoomKit.shared().roomService.getRoomContext(roomUuid: self.roomUuid.stringValue) else {
              return
        }
        // 添加房间监听
        roomContext.addRoomListener(listener: self)
    }
    
    /// 发送会议消息
    func sendMessage(model: CreateMeetingInfo){
        
        for source in dataSource {
            let attachment = IMMeetingRoomAttachment()
            attachment.meetingId = "\(model.meetingId)"
            attachment.meetingNum = model.meetingNum
            attachment.meetingShortNum = model.meetingShortNum
            attachment.meetingPassword = model.settings?.roomInfo?.password ?? ""
            attachment.meetingStatus = "\(model.status)"
            attachment.meetingSubject = model.subject
            attachment.meetingType = model.type
            attachment.roomArchiveId = model.roomArchiveId
            attachment.roomUuid = model.roomUuid

            let rawAttachment = attachment.encode()
            let message = MessageUtils.customV2Message(text: "", rawAttachment: rawAttachment)
            
            let param = V2NIMSendMessageParams()
            let pushConfig = V2NIMMessagePushConfig()
            pushConfig.pushContent = "recent_msg_desc_meeting".localized
            param.pushConfig = pushConfig
            
            let accountId = NIMSDK.shared().v2LoginService.getLoginUser() ?? ""
            let conversationId = source.isTeam ? "\(accountId)|2|\(source.userName)" : "\(accountId)|1|\(source.userName)"
            NIMSDK.shared().v2MessageService.send(message, conversationId: conversationId, params: param) { _ in
                
            } failure: { _ in
                
            }

            
        }
       
        
    }
    
    func leaveMeetingRoom() {
        NEMeetingKit.getInstance().getMeetingService().leaveCurrentMeeting(false) { code, msg, info in
            
        }
    }

}

extension TGMeetingSettingViewModel: NEMeetingStatusListener {
    
    func onMeetingStatusChanged(_ event: NEMeetingEvent) {
        
        if event.status == .MEETING_STATUS_DISCONNECTING || event.status == .MEETING_STATUS_IDLE {
            self.delegate?.leaveMeetingRoom()
        }
    }
    
}

extension TGMeetingSettingViewModel: NERoomListener {
    func onMemberJoinRoom(members: [NERoomMember]) {
    }
    
    func onMemberLeaveRoom(members: [NERoomMember]) {
    }
    
    func onMemberJoinRtcChannel(members: [NERoomMember]) {
        if self.meetingLevel == 0 {
            self.delegate?.updateMemberRoom()
        }
    }
}
