//
//  TGContactsPickerConfig.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/2.
//

import UIKit

let maximumTeamMemberAuthCompulsory: Int = 50
let maximumTeamMemberAuthFromCardView: Int = 49
let maximumSendContactCount: Int = 5
let VideoPlayerPlayButtonWidth: CGFloat = 64
let VideoPlayerPlayButtonHeight: CGFloat = 64

let YippiNetCallRingtone = "yippi_ringtone.wav"

let RewardLinkUserDefaultKey = "rewardlinkusersh:"
let RewardsLinkScheme = "rewardslink"
let merchantQRCode = "business.payment:branch."

class TGContactsPickerConfig: NSObject {
    // Navigation title
    let title: String
    
    // Right button title
    let rightButtonTitle: String
    
    // Allow multi select. Default is false.
    let allowMultiSelect: Bool
    
    // Enable to show and share to joined team. Default is false.
    let enableTeam: Bool
    
    // Enable to show and share to recent conversations. Default is false.
    let enableRecent: Bool
    
    // Enable to show and share to Hungry Bear (Robot). Default is false.
    let enableRobot: Bool
    
    // Maximum select count
    let maximumSelectCount: Int
    
    // Excluded users' ids which default selected in the list and cant be deselect
    let excludeIds: [String]?
    
    // List of members' id. Used for remove member from team.
    let members: [String]?
    
    // Enabled to show scanner & find people buttons. Enabled in select friends to chat view. Default is false.
    let enableButtons: Bool
    
    // Allow search for other member
    let allowSearchForOtherPeople: Bool
    
    @objc init(title: String,
                      rightButtonTitle: String,
                      allowMultiSelect: Bool = false,
                      enableTeam: Bool = false,
                      enableRecent: Bool = false,
                      enableRobot: Bool = false,
                      maximumSelectCount: Int = 999999,
                      excludeIds: [String]? = nil,
                      members: [String]? = nil,
                      enableButtons: Bool = false,
                      allowSearchForOtherPeople: Bool = true) {
        
        self.title = title
        self.rightButtonTitle = rightButtonTitle
        self.allowMultiSelect = allowMultiSelect
        self.enableTeam = enableTeam
        self.enableRecent = enableRecent
        self.enableRobot = enableRobot
        self.maximumSelectCount = allowMultiSelect ? maximumSelectCount : 1
        self.excludeIds = excludeIds
        self.members = members
        self.enableButtons = enableButtons
        self.allowSearchForOtherPeople = allowSearchForOtherPeople
    }
    
    class func shareToChatConfig() -> TGContactsPickerConfig {
        let config = TGContactsPickerConfig(title: NSLocalizedString("title_select_contacts", comment: ""),
                                          rightButtonTitle: NSLocalizedString("text_send", comment: ""),
                                          allowMultiSelect: true,
                                          enableTeam: true,
                                          enableRecent: true)
        return config
    }
    
    class func selectFriendToChatConfig() -> TGContactsPickerConfig {
        let config = TGContactsPickerConfig(title: NSLocalizedString("title_select_friends", comment: ""),
                                          rightButtonTitle: NSLocalizedString("select_friends_right_title_default", comment: ""),
                                          allowMultiSelect: true,
                                          maximumSelectCount: maximumTeamMemberAuthCompulsory,
                                          enableButtons: false)
        return config
    }
    
    class func selectFriendBasicConfig(_ excludeIds: [String]?) -> TGContactsPickerConfig {
        let config = TGContactsPickerConfig(title: NSLocalizedString("title_select_friends", comment: ""),
                                          rightButtonTitle: NSLocalizedString("select_friends_right_title_default", comment: ""),
                                          allowMultiSelect: true,
                                          maximumSelectCount: maximumTeamMemberAuthFromCardView,
                                          excludeIds: excludeIds)
        return config
    }
    
    class func mentionConfig(_ members: [String]?) -> TGContactsPickerConfig {
        let config = TGContactsPickerConfig(title: NSLocalizedString("select_friend_select_contact", comment: ""),
                                          rightButtonTitle: NSLocalizedString("confirm", comment: ""),
                                          allowMultiSelect: true,
                                          members:  members)
        return config
    }
}
