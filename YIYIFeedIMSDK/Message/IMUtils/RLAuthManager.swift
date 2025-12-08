//
//  RLAuthManager.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/25.
//

import UIKit
import AVFAudio

class RLAuthManager: NSObject {
    static let shared = RLAuthManager()
    
    override init() {
        super.init()
    }
    
    func checkRecordPermission() ->Bool {
        var flag = false
        let audioSession = AVAudioSession.sharedInstance()
        
        switch audioSession.recordPermission {
        case .granted:
            // 用户已授权录音
            print("用户已授权录音")
            flag = true
            // 在这里执行启动录音的逻辑
        case .denied:
            // 用户拒绝了录音权限
            print("用户拒绝了录音权限")
            // 提示用户去应用设置中打开录音权限
        case .undetermined:
            // 录音权限尚未确定，可以向用户请求权限
            audioSession.requestRecordPermission { granted in
                if granted {
                    // 用户授权录音
                    print("用户授权录音")
                    // 在这里执行启动录音的逻辑
                    flag = true
                } else {
                    // 用户拒绝了录音权限
                    print("用户拒绝了录音权限")
                    // 提示用户去应用设置中打开录音权限
                }
            }
        default:
            break
        }
        
        return flag
    }
    //听筒模式，扬声器
    func checkAudioOutputRoute() -> Bool {
        var isSpeaker = true
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try audioSession.setActive(true)
            
            let currentRoute = audioSession.currentRoute
            
            for output in currentRoute.outputs {
                if output.portType == AVAudioSession.Port.headphones {
                    print("设备连接了耳机（听筒模式）")
                    isSpeaker = false
                } else if output.portType == AVAudioSession.Port.builtInSpeaker {
                    print("设备使用扬声器（扬声器模式）")
                    isSpeaker = true
                }
            }
        } catch {
            print("Failed to set audio session category or activate audio session: \(error.localizedDescription)")
        }
        return isSpeaker
    }
}
