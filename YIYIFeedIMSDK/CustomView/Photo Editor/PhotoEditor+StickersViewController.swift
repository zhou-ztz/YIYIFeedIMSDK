//
//  PhotoEditor+StickersViewController.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import Foundation
import UIKit

extension PhotoEditorViewController {

    func addStickersViewController() {
        stickersVCIsVisible = true
        hideToolbar(hide: true)
        self.canvasImageView.isUserInteractionEnabled = false
        stickersViewController.stickersViewControllerDelegate = self

        for sticker in self.stickers {
            stickersViewController.stickers.append(sticker)
        }
        self.addChild(stickersViewController)
        self.view.addSubview(stickersViewController.view)
        stickersViewController.didMove(toParent: self)
        let height = view.frame.height
        let width  = view.frame.width
        stickersViewController.view.frame = CGRect(x: 0, y: self.view.frame.maxY , width: width, height: height)
    }

    func removeStickersView() {
        stickersVCIsVisible = false
        self.canvasImageView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        var frame = self.stickersViewController.view.frame
                        frame.origin.y = UIScreen.main.bounds.maxY
                        self.stickersViewController.view.frame = frame

        }, completion: { (finished) -> Void in
            self.stickersViewController.view.removeFromSuperview()
            self.stickersViewController.removeFromParent()
            self.hideToolbar(hide: false)
        })
    }
}

extension PhotoEditorViewController: StickersViewControllerDelegate {

    func didSelectView(view: UIView) {
        self.removeStickersView()

        view.center = canvasImageView.center
        self.canvasImageView.addSubview(view)
        //Gestures
        addGestures(view: view)
    }

    func didSelectImage(image: UIImage) {
        self.removeStickersView()

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size = CGSize(width: 150, height: 150)
        imageView.center = canvasImageView.center

        self.canvasImageView.addSubview(imageView)
        //Gestures
        addGestures(view: imageView)
    }

    func didSelectImage(url: String) {
        self.removeStickersView()

        let imageView = UIImageView(image: nil)
        imageView.sd_setImage(with: URL(string: url), completed: nil)
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size = CGSize(width: 150, height: 150)
        imageView.center = canvasImageView.center

        self.canvasImageView.addSubview(imageView)
        //Gestures
        addGestures(view: imageView)
    }

    func stickersViewDidDisappear() {
        stickersVCIsVisible = false
        hideToolbar(hide: false)
    }

    func addGestures(view: UIView) {
        //Gestures
        view.isUserInteractionEnabled = true

        panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                      action: #selector(PhotoEditorViewController.panGesture))
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)

        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self,
                                                          action: #selector(PhotoEditorViewController.pinchGesture))
        pinchGestureRecognizer.delegate = self
        view.addGestureRecognizer(pinchGestureRecognizer)

        rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                action:#selector(PhotoEditorViewController.rotationGesture) )
        rotationGestureRecognizer.delegate = self
        view.addGestureRecognizer(rotationGestureRecognizer)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PhotoEditorViewController.tapGesture))
        view.addGestureRecognizer(tapGesture)

    }

    func addLabelGestures(view: UILabel) {
        //Gestures
        view.isUserInteractionEnabled = true

        panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                      action: #selector(PhotoEditorViewController.panGesture))
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)

        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self,
                                                          action: #selector(PhotoEditorViewController.pinchGesture))
        pinchGestureRecognizer.delegate = self
        view.addGestureRecognizer(pinchGestureRecognizer)

        rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                action:#selector(PhotoEditorViewController.rotationGesture) )
        rotationGestureRecognizer.delegate = self
        view.addGestureRecognizer(rotationGestureRecognizer)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PhotoEditorViewController.tapGesture))
        view.addGestureRecognizer(tapGesture)

    }
}
