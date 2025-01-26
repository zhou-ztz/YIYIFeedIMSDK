//
//  TeamDetailViewModel.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/20.
//

import UIKit
import NIMSDK

class TeamDetailViewModel: NSObject {
    
    let maximumMemberDisplayed = 12
    
    var team: V2NIMTeam
    var teamId: String
    var myTeamInfo: V2NIMTeamMember?
    
    var allMembers: [TeamMember] = []
    var onShowSuccess: ((String?) -> Void)?
    var onShowFail: ((String?) -> Void)?
    var onReloadMembers: EmptyClosure?
    var onReloadData: ((SettingType) -> Void)?
    var selectedType: SettingType = .none
    var p2PSessions: [String] = []
    var failedSessionIds: [String] = []
    var isRequesting = false
    var allTeamMembers: [String] = []
    var conversationId: String?
    
    var isNotificationMuted: Bool = false
    var isPinnedToTop: Bool  = false
   
    init(team: V2NIMTeam, teamId: String) {
        self.team = team
        self.teamId = teamId
        super.init()
        NIMSDK.shared().v2TeamService.add(self)
    }
    deinit {
        NIMSDK.shared().v2TeamService.remove(self)
    }
    
    var addMemberButton = TeamMember(isAdd: true)
    var removeMemberButton = TeamMember(isReduce: true)
    
    var members: [TeamMember] = [] {
        didSet {
            /// 如果群设定允许添加加成员
            if self.members.contains(where: { $0.isAdd == true }) == false {
                if self.hasPermission {
                    self.members.append(addMemberButton)
                } else {
                    if team.joinMode == .TEAM_JOIN_MODE_APPLY {
                        // Private Group
                        if team.inviteMode == .TEAM_INVITE_MODE_ALL {
                            self.members.append(addMemberButton)
                        }
                    } else if team.joinMode == .TEAM_JOIN_MODE_FREE {
                        // Public Group
                        if team.inviteMode == .TEAM_INVITE_MODE_ALL {
                            self.members.append(addMemberButton)
                        }
                    } else {
                        // Secret Group
                        if team.inviteMode == .TEAM_INVITE_MODE_ALL {
                            self.members.append(addMemberButton)
                        }
                    }
                }
            }
            if self.members.contains(where: { $0.isReduce == true }) == false {
                if self.hasPermission {
                    if  let _ = self.members.first(where: { $0.isReduce == removeMemberButton.isReduce}) {
                        
                    } else {
                        self.members.append(removeMemberButton)
                    }
                } else {
                    self.members.removeAll(where: { $0 == removeMemberButton })
                }
            }
            /// 如果有权力移除成员
            self.onReloadMembers?()
        }
    }
    
    var canEditTeamInfo: Bool {
        guard let myTeamInfo = self.myTeamInfo else {
            return false
        }
        if team.updateInfoMode == .TEAM_UPDATE_INFO_MODE_MANAGER {
            return myTeamInfo.memberRole == .TEAM_MEMBER_ROLE_OWNER || myTeamInfo.memberRole == .TEAM_MEMBER_ROLE_MANAGER
        } else {
            return myTeamInfo.memberRole == .TEAM_MEMBER_ROLE_OWNER || myTeamInfo.memberRole == .TEAM_MEMBER_ROLE_MANAGER || myTeamInfo.memberRole == .TEAM_MEMBER_ROLE_NORMAL
        }
    }
    
    var hasPermission: Bool {
        guard let myTeamInfo = self.myTeamInfo else {
            return false
        }
        return myTeamInfo.memberRole == .TEAM_MEMBER_ROLE_OWNER || myTeamInfo.memberRole == .TEAM_MEMBER_ROLE_MANAGER
    }
    
    var isOwner: Bool {
        guard let myTeamInfo = self.myTeamInfo else {
            return false
        }
        return myTeamInfo.memberRole == .TEAM_MEMBER_ROLE_OWNER
    }
    
    var isManager: Bool {
        guard let myTeamInfo = self.myTeamInfo else {
            return false
        }
        return myTeamInfo.memberRole == .TEAM_MEMBER_ROLE_MANAGER
    }
    
    
    func getTeamMember(completion: @escaping (Bool) -> ()) {
        let option = V2NIMTeamMemberQueryOption()
        option.limit = 500
        option.nextToken = ""
        option.roleQueryType = .TEAM_MEMBER_ROLE_QUERY_TYPE_ALL
        NIMSDK.shared().v2TeamService.getTeamMemberList(teamId, teamType: .TEAM_TYPE_NORMAL, queryOption: option) {[weak self] listResult in
            guard let self = self, let memberList = listResult.memberList, let accontId = RLSDKManager.shared.loginParma?.imAccid else {
                completion(false)
                return
            }
            self.handleMembers(memberList: memberList, accontId: accontId)
            completion(true)
        } failure: { _ in
            completion(false)
        }
    }
    
    func handleMembers(memberList: [V2NIMTeamMember], accontId: String) {
        self.myTeamInfo = memberList.filter { $0.accountId == accontId }.first
        
        var teamMembers = [TeamMember]()
        var teamMemberUserList : [String] = []
        
        teamMembers = memberList.filter { $0.memberRole == .TEAM_MEMBER_ROLE_OWNER }.compactMap { TeamMember(memberInfo: $0) }
        teamMembers.append(contentsOf: memberList.filter { $0.memberRole == .TEAM_MEMBER_ROLE_MANAGER }.compactMap { TeamMember(memberInfo: $0) })
        teamMembers.append(contentsOf: memberList.filter { $0.memberRole == .TEAM_MEMBER_ROLE_NORMAL }.compactMap { TeamMember(memberInfo: $0) })
        teamMemberUserList.append(contentsOf: memberList.compactMap { TeamMember(memberInfo: $0).memberInfo?.accountId })
        
        self.allMembers.removeAll()
        self.allTeamMembers.removeAll()
       // self.p2PSessions.append(contentsOf: teamMemberUserList)
        self.allTeamMembers.append(contentsOf: teamMemberUserList)
        self.allMembers = teamMembers
       // self.updateMembersInfo()
        
        if memberList.count > self.maximumMemberDisplayed {
            self.members = Array(teamMembers.prefix(self.maximumMemberDisplayed))
            self.members.append(TeamMember(isViewMore: true))
        } else {
            self.members = teamMembers
        }
    }
    
    func getValue(for type: SettingType) -> String? {
        switch type {
        case .groupName:
            return team.name
        case .groupIntro:
            guard let intro = team.intro else {
                return "not_set_content".localized
            }
            return intro
            
        case .groupAnnouncement:
            if let announcement = team.announcement, let data = announcement.data(using: .utf8) {
                do {
                    if let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Dictionary<String, Any>], let value = object.last?["title"]  as? String {
                        return value
                    }
                } catch {
                    assert(false, error.localizedDescription)
                }
            }
            return "without_content".localized
            
        case .groupIcon:
            return team.avatar != nil ? team.avatar : Bundle.main.url(forResource: "icon_pin", withExtension: "png")?.absoluteString
        case .groupType:
            return self.joinModeText
        case .groupWhoCanEdit:
            return updateInfoModeText
        case .groupWhoCanInvite:
            return inviteModeText
        case .groupInviteeApproval:
            return beInviteModeText
        case .myNickname:
            guard let myTeamInfo = myTeamInfo else {
                return ""
            }
            
            guard let nickname = myTeamInfo.teamNick  else {
                return "click_set".localized
            }
            
            return nickname.isEmpty ?  "click_set".localized : myTeamInfo.teamNick
            
        default:
            return nil
        }
        
        
        
    }
    
    func getBoolValue(for type: SettingType) -> Bool {
        switch type {
        case .muteNotification:
            return isNotificationMuted
        case .pinTop:
            return isPinnedToTop
        default:
            return false
        }
    }
    
    var membersCount: Int {
        return members.count
    }
    
    var removeMembersList: [V2NIMTeamMember] {
        if myTeamInfo?.memberRole == .TEAM_MEMBER_ROLE_MANAGER {
            return allMembers.filter { $0.memberInfo?.memberRole == .TEAM_MEMBER_ROLE_NORMAL }.compactMap { $0.memberInfo }
        }
        
        if myTeamInfo?.memberRole == .TEAM_MEMBER_ROLE_OWNER {
            return allMembers.filter { $0.memberInfo?.memberRole != .TEAM_MEMBER_ROLE_OWNER }.compactMap { $0.memberInfo }
        }
        
        return []
    }
    
    var joinModeText: String {
       
        switch team.joinMode {
        case .TEAM_JOIN_MODE_APPLY:
            return "group_ask_to_join".localized
        case .TEAM_JOIN_MODE_FREE:
            return "group_public".localized
        default:
            return "group_private".localized
        }
    }
    
    var inviteModeText: String {
        switch team.inviteMode {
        case .TEAM_INVITE_MODE_MANAGER:
            return "group_admin_only".localized
        case .TEAM_INVITE_MODE_ALL:
            return "group_anyone".localized
        default:
            return "unknown_permission".localized
        }
    }
    
    var updateInfoModeText: String {
       
        switch team.updateInfoMode {
        case .TEAM_UPDATE_INFO_MODE_MANAGER:
            return "group_admin_only".localized
        case .TEAM_UPDATE_INFO_MODE_ALL:
            return "group_anyone".localized
        default:
            return "unknown_permission".localized
        }
    }
    
    var beInviteModeText: String {
       
        switch team.agreeMode {
        case .TEAM_AGREE_MODE_AUTH:
            return "group_required".localized
        case .TEAM_AGREE_MODE_NO_AUTH:
            return "group_not_required".localized
        default:
            return "unknown".localized
        }
    }
    
    func getConversationInfo(){
        guard let conversationId = conversationId  else {
            return
        }
        NIMSDK.shared().v2ConversationService.getConversation(conversationId) {[weak self] conversation in
            self?.isNotificationMuted = conversation.mute
            self?.isPinnedToTop = conversation.stickTop
        } failure: { _ in
        }
    }
    
    
    /// To update invite mode to 'needAuth' whenever number of member achieve maximum amount. Only apply to owner/manager
    func beInviteModeChecker() -> Bool {
        if  team.memberCount >= maximumTeamMemberAuthCompulsory && team.agreeMode == .TEAM_AGREE_MODE_NO_AUTH && self.hasPermission {
            let param = V2NIMUpdateTeamInfoParams()
            param.agreeMode = .TEAM_AGREE_MODE_AUTH
            NIMSDK.shared().v2TeamService.updateTeamInfo(teamId, teamType: .TEAM_TYPE_NORMAL, updateTeamInfoParams: param, antispamConfig: nil, success: nil)
           
            return false
        }
        return true
    }
    
    /// Automatically change all 'beInviteMode' to needAuth
    func changeToNeedAuth () {
        if  team.agreeMode == .TEAM_AGREE_MODE_NO_AUTH && self.hasPermission {
            let param = V2NIMUpdateTeamInfoParams()
            param.agreeMode = .TEAM_AGREE_MODE_AUTH
            NIMSDK.shared().v2TeamService.updateTeamInfo(teamId, teamType: .TEAM_TYPE_NORMAL, updateTeamInfoParams: param, antispamConfig: nil, success: nil)
           
        }
    }
    
    func updateTeamMembers() {
        self.members.removeAll(where: { $0.isAdd == true })
        self.members.removeAll(where: { $0.isReduce == true })
    }
    
    func addMembers(_ members: [String]) {

        NIMSDK.shared().v2TeamService.inviteMember(teamId, teamType: .TEAM_TYPE_NORMAL, inviteeAccountIds: members, postscript: nil) {[weak self] _ in
            if self?.team.agreeMode == .TEAM_AGREE_MODE_AUTH {
                self?.onShowSuccess?("team_invite_members_success".localized)
            } else {
                self?.onShowSuccess?("group_success_add_member".localized)
            }
        } failure: { _ in
            
        }

        
    }
    
    func uploadGroupImage(_ uploadFilepath: String, onHideLoading: EmptyClosure?) {
        selectedType = .groupIcon
        let task = V2NIMUploadFileTask()
        let uploadParams = V2NIMUploadFileParams()
        uploadParams.filePath = uploadFilepath
        uploadParams.sceneName = NIMNOSSceneTypeAvatar
        task.uploadParams = uploadParams
        task.taskId = Date().timeIntervalSince1970.toString()
        NIMSDK.shared().v2StorageService.uploadFile(task) {[weak self] urlString in
            onHideLoading?()
            let param = V2NIMUpdateTeamInfoParams()
            param.avatar = urlString
            NIMSDK.shared().v2TeamService.updateTeamInfo(self?.teamId ?? "", teamType: .TEAM_TYPE_NORMAL, updateTeamInfoParams: param, antispamConfig: nil) { [weak self] in
                self?.updateTeamInfo(completion: {
                    self?.onShowSuccess?(nil)
                })
            } failure: { [weak self] error in
                self?.onShowFail?(error.nserror.localizedDescription)
            }
        } failure: {[weak self] error in
            onHideLoading?()
            self?.onShowFail?(error.nserror.localizedDescription)
        } progress: { progress in
           
        }
    }
    
    func updateTeamName(_ name: String) {
        selectedType = .groupName
        if name.isEmpty {
            self.onShowFail?(String(format: "warning_cnt_empty".localized, "group_name".localized))
        } else {
            let param = V2NIMUpdateTeamInfoParams()
            param.name = name
            NIMSDK.shared().v2TeamService.updateTeamInfo(teamId, teamType: .TEAM_TYPE_NORMAL, updateTeamInfoParams: param, antispamConfig: nil) {  [weak self] in
                self?.updateTeamInfo(completion: {
                    self?.onShowSuccess?(nil)
                })
            } failure: { [weak self] error in
                self?.onShowFail?(error.nserror.localizedDescription)
            }

        }
    }
    
    func updateTeamIntro(_ intro: String) {
        selectedType = .groupIntro
        let param = V2NIMUpdateTeamInfoParams()
        param.intro = intro
        NIMSDK.shared().v2TeamService.updateTeamInfo(teamId, teamType: .TEAM_TYPE_NORMAL, updateTeamInfoParams: param, antispamConfig: nil) { [weak self] in
            self?.updateTeamInfo(completion: {
                self?.onShowSuccess?(nil)
            })
        } failure: { [weak self] error in
            self?.onShowFail?(error.nserror.localizedDescription)
        }
    }
    
    func updateJoinMode(_ mode: V2NIMTeamJoinMode) {
        selectedType = .groupType
        let param = V2NIMUpdateTeamInfoParams()
        param.joinMode = mode
        NIMSDK.shared().v2TeamService.updateTeamInfo(teamId, teamType: .TEAM_TYPE_NORMAL, updateTeamInfoParams: param, antispamConfig: nil) {  [weak self] in
            self?.updateTeamInfo(completion: {
                self?.onShowSuccess?(nil)
            })
        } failure: { [weak self] error in
            self?.onShowFail?(error.nserror.localizedDescription)
        }
      
    }
    
    func updateInviteMode(_ mode: V2NIMTeamInviteMode) {
        selectedType = .groupWhoCanInvite
        let param = V2NIMUpdateTeamInfoParams()
        param.inviteMode = mode
        NIMSDK.shared().v2TeamService.updateTeamInfo(teamId, teamType: .TEAM_TYPE_NORMAL, updateTeamInfoParams: param, antispamConfig: nil) {  [weak self] in
            self?.updateTeamInfo(completion: {
                self?.onShowSuccess?(nil)
            })
        } failure: { [weak self] error in
            self?.onShowFail?(error.nserror.localizedDescription)
        }
    }
    
    func updateBeInviteMode(_ mode: V2NIMTeamAgreeMode) {
        selectedType = .groupInviteeApproval
        let param = V2NIMUpdateTeamInfoParams()
        param.agreeMode = mode
        NIMSDK.shared().v2TeamService.updateTeamInfo(teamId, teamType: .TEAM_TYPE_NORMAL, updateTeamInfoParams: param, antispamConfig: nil) {  [weak self] in
            self?.updateTeamInfo(completion: {
                self?.onShowSuccess?(nil)
            })
        } failure: { [weak self] error in
            self?.onShowFail?(error.nserror.localizedDescription)
        }
    }
    
    func updateInfoMode(_ mode: V2NIMTeamUpdateInfoMode) {
        selectedType = .groupWhoCanEdit
        let param = V2NIMUpdateTeamInfoParams()
        param.updateInfoMode = mode
        NIMSDK.shared().v2TeamService.updateTeamInfo(teamId, teamType: .TEAM_TYPE_NORMAL, updateTeamInfoParams: param, antispamConfig: nil) { [weak self] in
            self?.updateTeamInfo(completion: {
                self?.onShowSuccess?(nil)
            })
        } failure: { [weak self] error in
            self?.onShowFail?(error.nserror.localizedDescription)
        }
    }
    
    func updateUserNickname(_ newNickName: String) {
        selectedType = .myNickname
        guard let myUserName = myTeamInfo?.accountId else { return }
        NIMSDK.shared().v2TeamService.updateTeamMemberNick(teamId, teamType: .TEAM_TYPE_NORMAL, accountId: myUserName, teamNick: newNickName) {[weak self] in
            self?.getTeamMember(completion: { done in
                if done {
                    self?.onShowSuccess?(nil)
                }
            })
            
        } failure: {[weak self] error in
            self?.onShowFail?(error.nserror.localizedDescription)
        }

    }
    
    func updateTeamInfo(completion: @escaping () -> ()){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6) { [weak self] in
            MessageUtils.getTeamInfo(teamId: self?.teamId ?? "", teamType: .TEAM_TYPE_NORMAL) {[weak self] v2Team in
                if let v2Team = v2Team {
                    self?.team = v2Team
                    completion()
                }
            }
        }
    }
    
    func sticktopChat(isOn: Bool, conversationId: String){
        NIMSDK.shared().v2ConversationService.stickTopConversation(conversationId, stickTop: isOn) {[weak self] in
            self?.isPinnedToTop = isOn
            self?.onShowSuccess?(nil)
        } failure: {[weak self] error in
            self?.onShowFail?(error.nserror.localizedDescription)
        }
    }
    
    func onActionMute(isOn: Bool) {
        let muteMode: V2NIMTeamMessageMuteMode = !isOn ? .TEAM_MESSAGE_MUTE_MODE_OFF : .TEAM_MESSAGE_MUTE_MODE_ON
        NIMSDK.shared().v2SettingService.setTeamMessageMuteMode(teamId, teamType: .TEAM_TYPE_NORMAL, muteMode: muteMode) {[weak self] in
            self?.isNotificationMuted = isOn
            self?.onShowSuccess?(nil)
        }
        
    }
    
    func deleteAllMessages(completion: @escaping () -> ()) {
        guard let conversationId = conversationId else { return }
        let option = V2NIMClearHistoryMessageOption()
        option.conversationId = conversationId
        option.deleteRoam = true
        NIMSDK.shared().v2MessageService.clearHistoryMessage(option) { 
            completion()
        } failure: { _ in
            
        }
    }
    
    func transferGroup(to userName: String, isLeaving: Bool, onDismiss: @escaping EmptyClosure) {
        
        NIMSDK.shared().v2TeamService.transferTeamOwner(teamId, teamType: .TEAM_TYPE_NORMAL, accountId: userName, leave: isLeaving) { [weak self] in
            onDismiss()
            self?.onShowSuccess?(nil)
        } failure: {[weak self] error in
            self?.onShowFail?(error.nserror.localizedDescription)
        }
    }
    
    func dismissGroup(onDismiss: @escaping EmptyClosure) {
        NIMSDK.shared().v2TeamService.dismissTeam(teamId, teamType: .TEAM_TYPE_NORMAL) { [weak self] in
            self?.onShowSuccess?(nil)
            onDismiss()
        } failure: {[weak self] error in
            self?.onShowFail?(error.nserror.localizedDescription)
        }
    }
    
    func quitGroup(onDismiss: @escaping EmptyClosure) {
        NIMSDK.shared().v2TeamService.leaveTeam(teamId, teamType: .TEAM_TYPE_NORMAL) {[weak self] in
            self?.onShowSuccess?(nil)
            onDismiss()
        } failure: {[weak self] error in
            self?.onShowFail?(error.nserror.localizedDescription)
        }
    }
    
    func kickMember(_ memberId: String) {
        NIMSDK.shared().v2TeamService.kickMember(teamId, teamType: .TEAM_TYPE_NORMAL, memberAccountIds: [memberId]) {[weak self] in
            self?.onShowSuccess?(nil)
        } failure: {[weak self]  _ in
            self?.onShowFail?("remove_member_failed".localized)
        }
    }
    
    func makeAdmin(_ memberId: String) {
        NIMSDK.shared().v2TeamService.updateTeamMemberRole(teamId, teamType: .TEAM_TYPE_NORMAL, memberAccountIds: [memberId], memberRole: .TEAM_MEMBER_ROLE_MANAGER) { [weak self] in
            self?.onShowSuccess?(nil)
        } failure: {[weak self] error in
            self?.onShowFail?(error.nserror.localizedDescription)
        }
    }
    
    func removeAdmin(_ memberId: String) {
        NIMSDK.shared().v2TeamService.updateTeamMemberRole(teamId, teamType: .TEAM_TYPE_NORMAL, memberAccountIds: [memberId], memberRole: .TEAM_MEMBER_ROLE_NORMAL) { [weak self] in
            self?.onShowSuccess?(nil)
        } failure: { [weak self] error in
            self?.onShowFail?(error.nserror.localizedDescription)
        }
    }
}

extension TeamDetailViewModel: V2NIMTeamListener {
    func onTeamMemberInfoUpdated(_ teamMembers: [V2NIMTeamMember]) {
        self.getTeamMember { [weak self] _ in
            self?.onShowSuccess?(nil)
        }
    }
    
    func onTeamInfoUpdated(_ team: V2NIMTeam) {
        self.team = team
        self.onShowSuccess?(nil)
    }
}
