//
//  TGEventType.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/3/26.
//

import Foundation


/// 行为类型
 enum TGBehaviorType: String {
    //曝光
    case expose    = "expose"
    //点击
    case click     = "click"
    //搜索
    case search     = "search"
    //点赞
    case like      = "like"
    //取消点赞
    case unlike    = "unlike"
    //评论
    case comment   = "comment"
    //收藏
    case collect   = "collect"
    //取消收藏
    case uncollect = "uncollect"
    //停留时长
    case stay      = "stay"
    //分享
    case share     = "share"
    //打赏
    case tip       = "tip"
    //负反馈
    case dislike   = "dislike"
    //信息-动态分享至好友
    case im_msg    = "im_message"
    //转发
    case forward   = "forward"
    //小程序 log
    case miniAppLog   = "mini_app_log"
    //行为类型
    case event   = "event"
    //Scash支付成功
    case scashSuccess   = "scash_payment_success"
    //Scash支付等待中
    case scashPending   = "scash_payment_pending"
    //Scash支付失败
    case scashFailed   = "scash_payment_failed"
    //Scash支付退款
    case scashRefund   = "scash_payment_refund"
    //Scash支付未知
    case scashUnknown   = "scash_payment_unknown"
}

/// 上报数据类型
 enum TGItemType: String {
    //========动态========
    //图片动态
    case image         = "image"
    //图片动态
    case shortvideo    = "shortvideo"
    //图片动态
    case item          = "item"
    
    //========首页========
    //顶部moudle app 模块
    case homeModuleApp          = "home_module_app"
    //底部发现更多
    case homeFindMore           = "home_find_more"
    //首页Banner
    case homeBanner             = "home_banner"
    
    //========搜索========
    //搜索商家
    case searchMerchant         = "merchant"
    //搜索动态
    case searchFeed             = "feed"
    //搜索用户
    case searchUser             = "user"
    //弹出横幅
    case popup_banner   = "popup_banner"
    //小程序log
    case miniLog                = "mini_log"
    
    //========代金劵========
    //代金劵主页
    case voucherDashboard    = "voucher_dashboard"

    //代金劵里列表
    case voucherCategory    = "voucher_category_list"

    //代金劵里搜索模块
    case voucherSearch    = "voucher_search"
    //代金劵里详细
    case voucherDetail    = "voucher_detail"
    //获取代金劵里
    case getVoucher    = "get_voucher"
    //兌換券
    case voucherRedeem    = "voucher_redeem"
    
    //========商家地图========
    //商家地图 彈出視窗
    case mapviewMerchantPopup    = "mapview_merchant_popup"
    //商家地图 搜索
    case mapviewMerchantSearch    = "mapview_merchant_search"
    
    //========SCash========
    //SCash
    case scash    = "scash_payment"
    //水电费账单
    case utilitiesBillProvider = "utilities_bill_provider"
    case utilitiesBillProviderSelected = "utilities_bill_provider_selected"
    case utilitiesBillProviderCategorySelected = "utilities_bill_provider_category_selected"
    // 手机充值
    case mobileTopUpProvider = "mobile_top_up_provider"
    case mobileTopUpProviderSelected = "mobile_top_up_provider_selected"
    case mobileTopUpProviderPackagesSelected = "mobile_top_up_provider_packages_selected"
}

/// 模块ID
 enum TGModuleId: String {
    //首页模块
    case home    = "home"
    //搜索模块
    case search  = "search"
    //动态模块
    case feed    = "feed"
    //弹出横幅
    case popup_banner   = "popup_banner"
    //小程序
    case miniApp    = "mini_app"
    //代金劵
    case voucher    = "voucher"
    //获取代金劵
    case voucherRedeem    = "voucher_redeem"
    //商家地图
    case merchantMapView    = "mapview_merchant"
    //SCash
    case scash    = "scash_payment"
    //水电费账单
    case utilitiesBill = "utilities_bill"
    // 手机充值
    case mobileTopUp = "mobile_top_up"
}

/// 页面ID
 enum TGPageId: String {
    //========动态========
    //首页模块
    case home                   = "home"
    //搜索模块
    case search                 = "search"
    //动态模块
    case feed                   = "feed"
    
    //========首页========
    //顶部moudle app 模块
    case homeModuleApp          = "home_module_app"
    //底部发现更多
    case homeFindMore           = "home_find_more"
    //首页Banner
    case homeBanner             = "home_banner"
    
    //========搜索========
    //搜索商家
    case searchMerchant         = "search_merchant"
    //搜索动态
    case searchFeed             = "search_feed"
    //搜索用户
    case searchUser             = "search_user"
    //弹出横幅
    case popup_banner   = "popup_banner"
    //小程序
    case miniApp                = "mini_app"
    
    //========代金劵========
    //代金劵主页
    case voucherDashboardCategory    = "voucher_dashboard_category"
    case voucherDashboardVoucher    = "voucher_dashboard_voucher"
    //代金劵里列表
    case voucherCategoryListCategory    = "voucher_category_list_category"
    case voucherCategoryListVoucher    = "voucher_category_list_voucher"
    //代金劵里搜索模块
    case voucherSearch    = "voucher_search"
    //代金劵里详细
    case voucherDetail    = "voucher_detail"
    //获取代金劵里
    case getVoucher    = "get_voucher"
    //兌換券
    case voucherRedeem    = "voucher_redeem"
    
    //========商家地图========
    //商家地图 彈出視窗
    case mapviewMerchantPopup    = "mapview_merchant_popup"
    //商家地图 搜索
    case mapviewMerchantSearch    = "mapview_merchant_search"
    
    //========SCash========
    //SCash
    case scash    = "scash_payment"
    //水电费账单
    case utilitiesBillProviderList = "utilities_bill_provider_list"
    case utilitiesBillProviderCategoryList = "utilities_bill_provider_category_list"
    // 手机充值
    case mobileTopUpProviderList = "mobile_top_up_provider_list"
    case mobileTopUpProviderDetail = "mobile_top_up_provider_detail"
}


public enum TGEvent: Int {
    
    // Authentication
    case loginWithEmail
    case loginWithFacebook
    case logout
    
    // View Main
    case viewChats
    case viewSocial
    case viewBeautyCamera
    case viewMore
    case viewContacts
    case viewNotifications
    case viewDiscover
    case viewChatList
    case viewGroups
    
    // Social Feeds
    case viewHotFeed
    case viewLatestFeed
    case viewFollowingFeed
    case viewTrendingFeed
    case innerFeedViewClicks
    
    // Discovers
    case viewYippiEvents
    case viewTopics
    case viewEvents
    case viewSearchPeople
    case viewHotPeople
    case viewNearbyPeople
    case viewContactPeople
    case viewEShop
    case eShopBannerClicked
    case discoverBannerClicked
    
    // Notifications
    case viewSystemNoti
    case viewAtMeNoti
    case viewLikeNoti
    case viewCommentNoti
    case viewFollowRequestNoti
    case viewTeamInvitationNoti
    
    // Actions
    case clickTransferPoint
    case clickCollectPoint
    case clickAnnouncement
    case clickEditProfile
    case clickChangePassword
    case clickChangePhoneNo
    case clickWaveAdvertisement
    case skipWaveAdvertisement
    case hideSponsoredAds
    
    // Setting
    case viewStickersStore
    case viewBeautyCameraStore
    case viewShopping
    case viewTogaGo
    case viewEducation
    case viewNews
    case viewGames
    case viewCentre
    case viewRewardslink
    case viewTAMall
    case viewPointTransactionHistory
    case viewSettings
    case viewQRCode
    case viewFriends
    case viewFollowings
    case viewFollowers
    case viewMyProfile
    case viewWallet
    case clickDailyTreasure
    
    // Reward
    case clickReward5
    case clickReward10
    case clickReward20
    case clickRewardCustom
    
    // Contacts
    case contactsCustomerServiceClicked
    case contactsInvitationClicked
    case contactsPeopleNearbyClicked
    case contactsGroupChatsClicked
    case contactsMeetingGroupedClicked
    case contactsSecretChatClicked
    case contactBlacklistClicked
    case contactClicked
    
    //Energy
    case Wave3Clicked
    
    case trtEnergyClicked
    case trtEnergyMusicVideoWatched
    case trtEnergyWallpaperDownloaded
    case trtEnergyWeblinkClicked
    
    //feed page ad banner
    case advertisementClicked

    //chat's menu items
    case revokeAndEditClicked
    case deleteForEveryoneClicked
    case deleteForSelfClicked
    case deleteMultiForSelfClicked
    case forwardClicked
    case forwardMultiClicked
    case replyMessageClicked
    case copyMessageClicked
    case voiceToTextClicked
    case collectionClicked
    case translateClicked

    // lives
    case liveBannerClicked
    case liveReplySupporterClicked
    
    case onlineMeetUserViewed
    
    // authentication
    case OnboardingPageView
    case OnboardingRegisterAccount
    case OnboardingRegisterUsername
    case OnboardingRegisterPassword
    case OnboardingRegisterPhone
    case OnboardingRegisterOTP
    case OnboardingRegisterReferral
    case OnboardingRegisterProfileSetup
    case OnboardingRegisterUserRecommendations
    case OnboardingForgetPasswordUsername
    case OnboardingForgetPasswordNewPassword
    case OnboardingForgetPasswordOTP
    case OnboardingLogin
    
    // subscription
    case SubscriptionMenu
    
    // Yipps wanted
    case YippsWantedClicked
    case YippsWantedServiceClicked
    case YippsWantedQRViewClicks
    case YippsWantedDealsClicked
    case YippsWantedSuccessViewClicks
    case YippsWantedViewClicks
    
    // Feed Event FLoating Button
    case FloatingEventClicked
    case FloatingEventClosed
    
    case InviteFriend
    // home
    case HomeDashboardClicked
    
    // live player occur
    case LoadLiveError
    
    //NOTE: name() should be follow Proper Case, eg Account Created
   public func name() -> String {
        switch self {
        case .loginWithEmail: return "Login With Email"
        case .loginWithFacebook: return "Login With Facebook"
        case .logout: return "Logout Clicked"
        
        case .viewChats: return "Chats Viewed"
        case .viewSocial: return "Social Feed Viewed"
        case .viewDiscover: return "Discover Viewed"
        case .viewBeautyCamera: return "Beauty Camera Viewed"
        case .viewContacts: return "Contact List Viewed"
        case .viewGroups: return "Group List Viewed"

        case .viewChatList: return "Chat List Viewed"
        case .viewNotifications: return "Notifications Viewed"
        case .viewMore: return "Me Viewed"

        // Notifications
        case .viewSystemNoti: return "System Notification Viewed"
        case .viewAtMeNoti: return "Tag Me Notification Viewed"
        case .viewLikeNoti: return "Like Notification Viewed"
        case .viewCommentNoti: return "Comment Notification Viewed"
        case .viewFollowRequestNoti: return "Follow Request Notification Viewed"
        case .viewTeamInvitationNoti: return "Team Invitation Notification Viewed"
            
        // Social Feeds
        case .viewHotFeed: return "Hot Feed Viewed"
        case .viewLatestFeed: return "Latest Feed Viewed"
        case .viewFollowingFeed: return "Following Feed Viewed"
        case .viewTrendingFeed: return "Trending Feed Viewed"
        case .innerFeedViewClicks: return "Inner Feed View Clicks"
        
        // Discover
        case .viewYippiEvents: return "Yippi Events Viewed"
        case .viewEvents: return "Events Viewed"
        case .viewSearchPeople: return "Search People Viewed"
        case .viewTopics: return "Topics Viewed"
        case .viewHotPeople: return "Hot Users Viewed"
        case .viewNearbyPeople: return "Nearby Users Viewed"
        case .viewContactPeople: return "Contact Users Viewed"
        case .viewEShop: return "EShop Viewed"
        case .eShopBannerClicked: return "EShop Banner Clicked"
        case .discoverBannerClicked: return "Discover Banner Clicked"
            
        // Setting
        case .viewStickersStore: return "Stickers Shop Viewed"
        case .viewBeautyCameraStore: return "Beauty Camera Shop Viewed"
        case .viewShopping: return "Shopping Viewed"
        case .viewTogaGo: return "TogaGo Viewed"
        case .viewEducation: return "Education Viewed"
        case .viewNews: return "News Viewed"
        case .viewGames: return "Games Viewed"
        case .viewCentre: return "Centre Viewed"
        case .viewRewardslink: return "Rewardslink Viewed"
        case .viewTAMall: return "TA Mall Viewed"
        case .viewPointTransactionHistory: return "Point Transaction History Viewed"
        case .viewSettings: return "Settings Viewed"
        case .viewQRCode: return "QRCode Viewed"
        case .viewFollowers: return "Followers Viewed"
        case .viewFriends: return "Friends Viewed"
        case .viewFollowings: return "Followings Viewed"
        case .viewMyProfile: return "My Profile Viewed"
        case .viewWallet: return "Wallet Viewed"
            
        // Actions
        case .clickTransferPoint: return "Transfer Point Button Clicked"
        case .clickCollectPoint: return "Collect Point Button Clicked"
        case .clickAnnouncement: return "Announcement Primary Button Clicked"
        case .clickEditProfile: return "Edit Profile Button Clicked"
        case .clickChangePassword: return "Change Password Button Clicked"
        case .clickChangePhoneNo: return "Change Phone No Button Clicked"
        case .clickWaveAdvertisement: return "Wave Advertisement"
        case .skipWaveAdvertisement: return "Wave Skip Advertisement"
        case .hideSponsoredAds: return "Feed Action Hide Ad"

        // Rewards
        case .clickReward5: return "Reward 5 Clicked"
        case .clickReward10: return "Reward 10 Clicked"
        case .clickReward20: return "Reward 20 Clicked"
        case .clickRewardCustom: return "Reward Custom Value Clicked"
            
        // Contacts (// = To be removed)
        case .contactsCustomerServiceClicked: return "Customer Support Clicked" //
        case .contactsInvitationClicked: return "Contacts Invitations Clicked" //
        case .contactsPeopleNearbyClicked: return "Contacts People Nearby Clicked" //
        case .contactsGroupChatsClicked: return "Contacts Group Chats Clicked" //
        case .contactsMeetingGroupedClicked: return "Contacts Meeting Grouped Clicked" ///
        case .contactsSecretChatClicked: return "Contacts Secret Chat Clicked" ///
        case .contactBlacklistClicked: return "Contacts Blacklist Clicked"
        case .contactClicked: return "Contact Clicked" ///
            
        //Energy
        case .Wave3Clicked: return "Wave Three Generation"
      
        case .trtEnergyClicked: return "TRT Energy Clicked"
        case .trtEnergyMusicVideoWatched: return "TRT Energy Music Video Watched"
        case .trtEnergyWallpaperDownloaded: return "TRT Energy Wallpaper Downloaded"
        case .trtEnergyWeblinkClicked: return "TRT Energy Weblink Clicked"
        
        case .advertisementClicked: return " Advertisement Clicked"

        //Chat's menu items
        case .revokeAndEditClicked: return "Revoke and Edit button clicked"
        case .deleteForEveryoneClicked: return "Delete For Everyone button clicked"
        case .deleteForSelfClicked: return "Delete For Self button clicked"
        case .deleteMultiForSelfClicked: return "Delete Multi For Self button clicked"
        case .forwardClicked: return "Forward button clicked"
        case .forwardMultiClicked: return "Forward Multi button clicked"
        case .replyMessageClicked: return "Reply Message button clicked"
        case .copyMessageClicked: return "Copy Message button clicked"
        case .voiceToTextClicked: return "Voice TO Text button clicked"
        case .collectionClicked: return "Collection button clicked"
        case .translateClicked: return "Translate button clicked"
            
        case .liveBannerClicked: return "Live Banner Clicked"
        case .liveReplySupporterClicked: return "Live Reply Supporter Clicked"

        case .onlineMeetUserViewed: return "Online Meet User Viewed"
            
        case .OnboardingPageView: return "Onboarding Page View"
        case .OnboardingRegisterAccount: return "Onboarding Register Account"
        case .OnboardingRegisterUsername: return "Onboarding Register Username"
        case .OnboardingRegisterPassword: return "Onboarding Register Password"
        case .OnboardingRegisterPhone: return "Onboarding Register Phone"
        case .OnboardingRegisterOTP: return "Onboarding Register OTP"
        case .OnboardingRegisterReferral: return "Onboarding Register Referral"
        case .OnboardingRegisterProfileSetup: return "Onboarding Register Profile Setup"
        case .OnboardingRegisterUserRecommendations: return "Onboarding Register User Recommendations"
        case .OnboardingForgetPasswordUsername: return "Onboarding Forget Password Username"
        case .OnboardingForgetPasswordNewPassword: return "Onboarding Forget Password New Password"
        case .OnboardingForgetPasswordOTP: return "Onboarding Forget Password OTP"
        case .OnboardingLogin: return "Onboarding Login"
            
        case .SubscriptionMenu: return "Subscription Menu"
            
        case .YippsWantedClicked: return "Main Yipps Wanted Clicked"
        case .YippsWantedServiceClicked: return "Yipps Wanted Service Clicked"
        case .YippsWantedQRViewClicks: return "Yipps Wanted QR View Clicks"
        case .YippsWantedDealsClicked: return "Yipps Wanted Deals Clicked"
        case .YippsWantedSuccessViewClicks: return "Yipps Wanted Success View Clicks"
        case .YippsWantedViewClicks: return "Yipps Wanted View Clicks"
            
        case .FloatingEventClicked: return "Home Floating Icon"
        case .FloatingEventClosed: return "Home Floating Icon"
            
        case .InviteFriend: return "Invite Friend"
        case .HomeDashboardClicked: return "Home Dashboard Page"
        case .LoadLiveError: return "Load Live Error"
        
        default:
            return ""
        }
    }
}

extension TGEvent {
    static var all: [TGEvent] = {
        var index = 0
        var events = [TGEvent]()
        while let event = TGEvent(rawValue: index) {
            events.append(event)
            index += 1
        }
        return events
    }()
}
