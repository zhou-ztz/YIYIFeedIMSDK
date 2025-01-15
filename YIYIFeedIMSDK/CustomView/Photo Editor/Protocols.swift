//
//  Protocols.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 6/15/17.
//
//

import Foundation
import UIKit
/**
 - didSelectView
 - didSelectImage
 - stickersViewDidDisappear
 */

@objc protocol PhotoEditorDelegate: class {
    /**
     - Parameter image: edited Image
     */
    @objc(doneEditingImage:)
    func doneEditing(image: UIImage)
    /**
     StickersViewController did Disappear
     */
    @objc(canceledEditing)
    func canceledEditing()
}


/**
 - didSelectView
 - didSelectImage
 - stickersViewDidDisappear
 */
@objc protocol StickersViewControllerDelegate: class {
    /**
     - Parameter view: selected view from StickersViewController
     */
    func didSelectView(view: UIView)
    /**
     - Parameter image: selected Image from StickersViewController
     */
    func didSelectImage(image: UIImage)
    /**
     - Parameter url: selected image url from StickersViewController
     */
    func didSelectImage(url: String)
    /**
     StickersViewController did Disappear
     */
    func stickersViewDidDisappear()
}

/**
 - didSelectColor
 */
@objc protocol ColorDelegate: class {
    func didSelectColor(color: UIColor)
}
