//
//  TGKeyChainHelper.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/10/27.
//

import Foundation
import KeychainAccess

public class TGKeyChainHelper: NSObject {
    public static let shared = TGKeyChainHelper()
    let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "com.togl.rewardslink")
    
    // MARK: - Store
    public func store<T>(value: T, forKey key: String) -> (success: Bool, message: String) {
        do {
            switch value {
            case let stringValue as String:
                try keychain.set(stringValue, key: key)
            case let dataValue as Data:
                try keychain.set(dataValue, key: key)
            case let intValue as Int:
                try keychain.set(String(intValue), key: key)
            case let boolValue as Bool:
                try keychain.set(boolValue ? "true" : "false", key: key)
            default:
                printIfDebug("❌ Unsupported type: \(type(of: value))")
                return (false, "Unsupported type: \(type(of: value))")
            }
            return (true, "")
        } catch {
            printIfDebug("❌ Failed to store: \(error.localizedDescription)")
            return (false, error.localizedDescription)
        }
    }

    // MARK: - Read
    public func read<T>(type: T.Type, forKey key: String) -> (success: Bool, message: String, value: T?) {
        do {
            switch type {
            case is String.Type:
                let value = try keychain.getString(key) as? T
                return (value != nil, "", value)
            case is Data.Type:
                let value = try keychain.getData(key) as? T
                return (value != nil, "", value)
            case is Int.Type:
                if let string = try keychain.getString(key), let intValue = Int(string) {
                    return (true, "", intValue as? T)
                }
                return (false, "", nil)
            case is Bool.Type:
                if let string = try keychain.getString(key) {
                    return (true, "", (string == "true") as? T)
                }
                return (false, "", nil)
            default:
                printIfDebug("❌ Unsupported type: \(type)")
                return (false, "Unsupported type: \(type)", nil)
            }
        } catch {
            printIfDebug("❌ Failed to read: \(error.localizedDescription)")
            return (false, error.localizedDescription, nil)
        }
    }
    
    public func clear(type: String) -> (success: Bool, message: String) {
        do {
            try keychain.remove(type)
            return (true, "")
        } catch let error {
            printIfDebug("❌ Unable to remove value from keychain: \(error.localizedDescription)")
            return (false, error.localizedDescription)
        }
    }
}

