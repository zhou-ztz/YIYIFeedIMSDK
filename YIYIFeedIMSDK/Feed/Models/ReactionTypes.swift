//
//  ReactionTypes.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/12/12.
//

import Foundation
import UIKit
import Lottie

enum ReactionTypes: Int, CaseIterable {
    //love, like, heart_eyes, surprised, sad, angry)
    case heart = 0
    case like = 1
    case awesome = 2
    case wow = 3
    case cry = 4
    case angry = 5
    
    static func initialize(with stringValue: String) -> ReactionTypes? {
        switch stringValue {
        case ReactionTypes.like.apiName: return .like
        case ReactionTypes.heart.apiName: return .heart
        case ReactionTypes.awesome.apiName: return .awesome
        case ReactionTypes.wow.apiName: return .wow
        case ReactionTypes.cry.apiName: return .cry
        case ReactionTypes.angry.apiName: return .angry
        default: return nil
        }
    }

    var apiName: String {
        switch self {
        case .like: return "like"
        case .heart: return "love"
        case .awesome: return "awesome"
        case .wow: return "wow"
        case .cry: return "sad"
        case .angry: return "angry"
        }
    }

    var colorSignature: UIColor {
        switch self {
        case .like: return UIColor.systemBlue
        case .heart: return UIColor.systemPink
        case .awesome: return UIColor.gray
        case .wow: return UIColor.systemYellow
        case .cry: return UIColor.red
        case .angry: return UIColor.orange
        }
    }
    
    var image: UIImage {
        switch self {
        case .like: return UIImage(named: "blue_like")!
        case .heart: return UIImage(named: "red_heart")!
        case .awesome: return UIImage(named: "cry_laugh")!
        case .wow: return UIImage(named: "surprised")!
        case .cry: return UIImage(named: "cry")!
        case .angry: return UIImage(named: "angry")!
        }
    }

    var imageName: String {
        switch self {
        case .like: return "blue_like"
        case .heart: return "red_heart"
        case .wow: return "surprised"
        case .awesome: return "cry_laugh"
        case .cry: return "cry"
        case .angry: return "angry"
        }
    }
    
    var lottieAnimation: Animation {
        switch self {
        case .like: return Animation.named("reaction-like")!
        case .heart: return Animation.named("reaction-love")!
        case .wow: return Animation.named("reaction-wow")!
        case .awesome: return Animation.named("reaction-awesome")!
        case .cry: return Animation.named("reaction-cry")!
        case .angry: return Animation.named("reaction-angry")!
        }
    }

    var title: String {
        switch self {
        case .like: return "like_reaction".localized
        case .heart: return "love_reaction".localized
        case .wow: return "wow_reaction".localized
        case .awesome: return "awesome_reaction".localized
        case .cry: return "sad_reaction".localized
        case .angry: return "angry_reaction".localized
        }
    }
}
