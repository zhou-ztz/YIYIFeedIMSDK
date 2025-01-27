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

var MomentPHAssetPayInfoKey = 100_000
var MomentUIImageGIFKey = 100_001
extension UIImage {
    // 默认设置为kUTTypeJPEG
    var TGImageMIMEType: String {
        set {
            objc_setAssociatedObject(self, &MomentUIImageGIFKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            if let rs = objc_getAssociatedObject(self, &MomentUIImageGIFKey) as? String {
                return rs
            }
            return kUTTypeJPEG as String
        }
    }
    class func gif(data: Data, speedMultiplier: Double = 0.0) -> UIImage? {
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
        let frameworkBundle = Bundle(identifier: "com.yiyi.feedimsdk") ?? Bundle.main
        if let resourceBundleURL = frameworkBundle.url(forResource: "SDKResource", withExtension: "bundle"),
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
    
    class func imageWithColor(_ color: UIColor!, cornerRadius: Double!) -> UIImage {
        let minEdgeSize: Double = cornerRadius * 2.0 + 1.0
        let rect = CGRect(x: 0.0, y: 0.0, width: minEdgeSize, height: minEdgeSize)
        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: CGFloat(cornerRadius))
        roundedRect.lineWidth = 0
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        roundedRect.fill()
        roundedRect.stroke()
        roundedRect.addClip()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return (image?.resizableImage(withCapInsets: UIEdgeInsets(top: CGFloat(cornerRadius), left: CGFloat(cornerRadius), bottom: CGFloat(cornerRadius), right: CGFloat(cornerRadius))))!
    }

}

extension UIImage {
    /// 修复图片旋转
    func fixOrientation() -> UIImage {
        // 默认方向无需旋转
        if imageOrientation == .up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
            // 默认方向旋转180度、镜像旋转180度
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
            
            // 默认方向逆时针旋转90度、镜像逆时针旋转90度
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            
            // 默认方向顺时针旋转90度、镜像顺时针旋转90度
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -.pi / 2)
            
        default:
            break
        }
        
        switch imageOrientation {
            // 默认方向的竖线镜像、镜像旋转180度
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
            // 镜像逆时针旋转90度、镜像顺时针旋转90度
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        default:
            break
        }
        
        let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage!.bitsPerComponent, bytesPerRow: 0, space: cgImage!.colorSpace!, bitmapInfo: cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
        
        // 重新绘制
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            
        default:
            ctx?.draw(cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
        }
        
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
        
        return img
    }
}

extension UIImage {
    // MARK: - 替换 UIImage(named:) 方法
    public static let swizzleImageNamed: Void = {
        let originalSelector = #selector(UIImage.init(named:))
        let swizzledSelector = #selector(UIImage.customImageNamed(_:))
        
        if let originalMethod = class_getClassMethod(UIImage.self, originalSelector),
           let swizzledMethod = class_getClassMethod(UIImage.self, swizzledSelector) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()
    
    @objc private class func customImageNamed(_ name: String) -> UIImage? {
        // 获取框架的 Bundle
        let frameworkBundle = Bundle(identifier: "com.yiyi.feedimsdk") ?? Bundle.main
        if let resourceBundleURL = frameworkBundle.url(forResource: "SDKResource", withExtension: "bundle"),
           let resourceBundle = Bundle(url: resourceBundleURL) {
            // 尝试从自定义 Bundle 中加载图片
            if let image = UIImage(named: name, in: resourceBundle, compatibleWith: nil) {
                return image
            }
        }
        // 如果自定义 Bundle 中没有找到图片，调用原始的 UIImage(named:) 方法
        return customImageNamed(name)
    }
    func addWatermark () -> UIImage? {
        guard let watermarkImage = UIImage(named: "ic_rl_watermark") else {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, _: false, _: 0.0)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        watermarkImage.draw(in: CGRect(x: 16 * Constants.bestPixelRatio,
                                       y: self.size.height - (Constants.watermarkSize + 16) * Constants.bestPixelRatio,
                                       width: Constants.watermarkSize * Constants.bestPixelRatio,
                                       height: Constants.watermarkSize * Constants.bestPixelRatio))
        let resultImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
}
