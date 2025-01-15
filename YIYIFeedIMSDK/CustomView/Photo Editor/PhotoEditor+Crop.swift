//
//  PhotoEditor+Crop.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import Foundation
import UIKit

// MARK: - CropView
extension PhotoEditorViewController: PhotoEditorCropViewControllerDelegate {
    
    func cropViewController(_ controller: PhotoEditorCropViewController, didFinishCroppingImage image: UIImage, transform: CGAffineTransform, cropRect: CGRect) {
        controller.dismiss(animated: true, completion: nil)
        imageView.image = image
    }
    
    func cropViewControllerDidCancel(_ controller: PhotoEditorCropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
