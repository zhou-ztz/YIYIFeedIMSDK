//
//  UIImage+Extension.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司 on 2024/1/10.
//

import Foundation
import UIKit
import CoreServices
import ObjectiveC

extension UIImage {
    // 默认设置为kUTTypeJPEG
//    var TSImageMIMEType: String {
//        set {
//            objc_setAssociatedObject(self, &MomentUIImageGIFKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
//        }
//        get {
//            if let rs = objc_getAssociatedObject(self, &MomentUIImageGIFKey) as? String {
//                return rs
//            }
//            return kUTTypeJPEG as String
//        }
//    }
    public class func gif(data: Data, speedMultiplier: Double = 0.0) -> UIImage? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        return UIImage.animatedImageWithSource(source, speedMultiplier: speedMultiplier)
    }
    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        if CFDictionaryGetValueIfPresent(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque(), gifPropertiesPointer) == false {
            return delay
        }
        
        let gifProperties:CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
        
        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as? Double ?? 0
        
        if delay < 0.1 {
            delay = 0.1 // Make sure they're not too fast
        }
        
        return delay
    }
    
    internal class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        // Check if one of them is nil
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        // Swap for modulo
        if a! < b! {
            let c = a
            a = b
            b = c
        }
        
        // Get greatest common divisor
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b! // Found it
            } else {
                a = b
                b = rest
            }
        }
    }
    
    internal class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    internal class func animatedImageWithSource(_ source: CGImageSource, speedMultiplier: Double = 0.0) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        // Fill arrays
        for i in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            // At it's delay in cs
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        // Calculate full duration
        let duration: Int = {
            var sum:Double = 0
            
            for val: Int in delays {
                var newVal: Double = 0.0
                if speedMultiplier > 0 {
                    newVal = Double(val) - (Double(val)/speedMultiplier)
                } else {
                    newVal = Double(val)
                }
                sum += newVal
            }
            
            return Int(sum)
            
        }()
        
        // Get frames
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        // Heyhey
        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 1000.0)
        
        return animation
    }
    
    class func set_image(named: String) -> UIImage?{
        
        // 获取框架的 Bundle
        let frameworkBundle = Bundle(identifier: "com.yiyi.feedimsdk")

        if let resourceBundleURL = frameworkBundle?.url(forResource: "SDKResource", withExtension: "bundle"),
           let resourceBundle = Bundle(url: resourceBundleURL) {

            if let image = UIImage(named: named, in: resourceBundle, compatibleWith: nil) {
    
                return image
            } else {
                print("Failed to load image from SDKResource.bundle")
            }
        } else {
            print("SDKResource.bundle not found in framework")
        }

        return nil
    }

}
