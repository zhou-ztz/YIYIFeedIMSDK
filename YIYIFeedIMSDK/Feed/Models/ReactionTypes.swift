//
//  ReactionTypes.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/12/12.
//
import Foundation
import Lottie

public enum ReactionTypes: Int, CaseIterable {
    //love, like, heart_eyes, surprised, sad, angry)
    case heart = 0
    case like = 1
    case awesome = 2
    case wow = 3
    case cry = 4
    case angry = 5
    
    case blackHeart = 6
    case blackAwesome = 7
    case blackWow = 8
    case blackCry = 9
    case blackAngry = 10
    
    static func initialize(with stringValue: String) -> ReactionTypes? {
        switch stringValue {
        case ReactionTypes.like.apiName: return .like
        case ReactionTypes.heart.apiName: return .heart
        case ReactionTypes.awesome.apiName: return .awesome
        case ReactionTypes.wow.apiName: return .wow
        case ReactionTypes.cry.apiName: return .cry
        case ReactionTypes.angry.apiName: return .angry
            
        case ReactionTypes.blackHeart.apiName: return .heart
        case ReactionTypes.blackAwesome.apiName: return .awesome
        case ReactionTypes.blackWow.apiName: return .wow
        case ReactionTypes.blackCry.apiName: return .cry
        case ReactionTypes.blackAngry.apiName: return .angry
        default: return nil
        }
    }
    
    func unHighlightColor(for theme: Theme) -> UIColor {
        switch theme {
        case .dark:
            return .white
        case .white:
            return TGAppTheme.pinkishGrey
        }
    }
    
    public var apiName: String {
        switch self {
        case .like: return "like"
        case .heart: return "love"
        case .awesome: return "awesome"
        case .wow: return "wow"
        case .cry: return "sad"
        case .angry: return "angry"
            
        case .blackHeart: return "love"
        case .blackAwesome: return "awesome"
        case .blackWow: return "wow"
        case .blackCry: return "sad"
        case .blackAngry: return "angry"
        }
    }

    public var colorSignature: UIColor {
        switch self {
        case .like: return UIColor.systemBlue
        case .heart: return UIColor.systemPink
        case .awesome: return UIColor.gray
        case .wow: return UIColor.systemYellow
        case .cry: return UIColor.red
        case .angry: return UIColor.orange
            
        case .blackHeart: return UIColor.systemPink
        case .blackAwesome: return UIColor.gray
        case .blackWow: return UIColor.systemYellow
        case .blackCry: return UIColor.red
        case .blackAngry: return UIColor.orange
        }
    }
    
    public var image: UIImage {
        switch self {
        case .like: return UIImage(named: "blue_like")!
        case .heart: return UIImage(named: "love")!
        case .awesome: return UIImage(named: "yay")!
        case .wow: return UIImage(named: "wow")!
        case .cry: return UIImage(named: "cry")!
        case .angry: return UIImage(named: "angry")!
            
        case .blackHeart: return UIImage(named: "love_black")!
        case .blackAwesome: return UIImage(named: "yay_black")!
        case .blackWow: return UIImage(named: "wow_black")!
        case .blackCry: return UIImage(named: "cry_black")!
        case .blackAngry: return UIImage(named: "angry_black")!
        }
    }

    public var imageName: String {
        switch self {
        case .like: return "blue_like"
        case .heart: return "love"
        case .wow: return "wow"
        case .awesome: return "yay"
        case .cry: return "cry"
        case .angry: return "angry"
            
        case .blackHeart: return "love_black"
        case .blackAwesome: return "yay_black"
        case .blackWow: return "wow_black"
        case .blackCry: return "cry_black"
        case .blackAngry: return "angry_black"
        }
    }
    
    public var lottieAnimation: Animation {
        switch self {
        case .like: return Animation.named("reaction-like")!
        case .heart: return Animation.named("reaction-love")!
        case .wow: return Animation.named("reaction-wow")!
        case .awesome: return Animation.named("reaction-awesome")!
        case .cry: return Animation.named("reaction-cry")!
        case .angry: return Animation.named("reaction-angry")!
            
        case .blackHeart: return Animation.named("reaction-love")!
        case .blackWow: return Animation.named("reaction-wow")!
        case .blackAwesome: return Animation.named("reaction-awesome")!
        case .blackCry: return Animation.named("reaction-cry")!
        case .blackAngry: return Animation.named("reaction-angry")!
        }
    }

    public var title: String {
        switch self {
        case .like: return "like_reaction".localized
        case .heart: return "love_reaction".localized
        case .wow: return "wow_reaction".localized
        case .awesome: return "awesome_reaction".localized
        case .cry: return "sad_reaction".localized
        case .angry: return "angry_reaction".localized
            
        case .blackHeart: return "love_reaction".localized
        case .blackWow: return "wow_reaction".localized
        case .blackAwesome: return "awesome_reaction".localized
        case .blackCry: return "sad_reaction".localized
        case .blackAngry: return "angry_reaction".localized
        }
    }

//    func generateStyle(for theme: Theme) -> HeadingSelectionViewStyles {
//        switch theme {
//        case .white:
//            return .icon(text: self.title, highlightColor: UIColor.black, unhighlightColor: AppTheme.pinkishGrey,
//                    iconSelect: image, iconDeselect: image, indicatorColor: colorSignature)
//
//        case .dark:
//            return .icon(text: self.title, highlightColor: UIColor.white, unhighlightColor: UIColor.white.withAlphaComponent(0.3),
//                    iconSelect: image, iconDeselect: image, indicatorColor: colorSignature)
//        }
//    }
}
