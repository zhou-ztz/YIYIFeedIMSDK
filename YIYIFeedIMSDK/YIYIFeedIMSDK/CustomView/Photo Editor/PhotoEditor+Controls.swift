//
//  PhotoEditor+Controls.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import Foundation
import UIKit

// MARK: - Control
@objc enum control: Int {
    case crop
    case sticker
    case draw
    case text
    case save
    case share
    case clear
}

extension PhotoEditorViewController {

    //MARK: Top Toolbar

    @IBAction func cancelButtonTapped(_ sender: Any) {
        photoEditorDelegate?.canceledEditing()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cropButtonTapped(_ sender: UIButton) {
        let controller = PhotoEditorCropViewController()
        controller.delegate = self
        controller.image = image
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }

    @IBAction func stickersButtonTapped(_ sender: Any) {
        addStickersViewController()
    }

    @IBAction func drawButtonTapped(_ sender: Any) {
        isDrawing = true
        canvasImageView.isUserInteractionEnabled = false
        doneButton.isHidden = false
        undoButton.isHidden = false
        colorPickerView.isHidden = false
        sliderView.isHidden = false
        sliderView.alpha = 1.0
        hideToolbar(hide: true)

        view.layer.addSublayer(circularLayer)
        view.bringSubviewToFront(sliderView)
    }

    @IBAction func textButtonTapped(_ sender: Any) {
        isTyping = true
        if currentTextViewCount <= maxTextViewCount {
            let textView = UITextView()
            if let label = currentActiveLabel {
                textView.frame = label.bounds
                textView.textColor = label.textColor
                textView.text = label.text
                textView.transform = label.transform
                previousCenter = label.center
                label.isHidden = true
            } else {
                textView.frame = CGRect(x: 0, y: canvasImageView.center.y, width: UIScreen.main.bounds.width, height: 30)
                previousCenter = textView.center
                textView.textColor = textColor
            }

            textView.textAlignment = .center
            textView.font = UIFont(name: "Helvetica-Bold", size: 30)
            textView.layer.shadowColor = UIColor.black.cgColor
            textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
            textView.layer.shadowOpacity = 0.2
            textView.layer.shadowRadius = 1.0
            textView.layer.backgroundColor = UIColor.clear.cgColor
            textView.autocorrectionType = .no
            textView.isScrollEnabled = false
            textView.delegate = self
            self.canvasImageView.addSubview(textView)
            currentTextViewCount += 1
            textView.becomeFirstResponder()
        }
    }

    @IBAction func undoButtonTapped(_ sender: Any) {
        _ = lines.popLast()
        canvasImageView.image = nil
        redrawLineFrom()
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        view.endEditing(true)
        backgroundView.removeFromSuperview()
        doneButton.isHidden = true
        undoButton.isHidden = true
        colorPickerView.isHidden = true
        canvasImageView.isUserInteractionEnabled = true
        sliderView.isHidden = true
        hideToolbar(hide: false)
        isDrawing = false
    }

    //MARK: Bottom Toolbar

    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(canvasView.toImage(),self, #selector(PhotoEditorViewController.image(_:withPotentialError:contextInfo:)), nil)
    }

    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let activity = UIActivityViewController(activityItems: [canvasView.toImage(), ShareExtensionBlockerItem()], applicationActivities: nil)
        present(activity, animated: true, completion: nil)

    }

    @IBAction func clearButtonTapped(_ sender: AnyObject) {
        //clear drawing
        canvasImageView.image = nil
        currentTextViewCount = 0
        lines.removeAll()
        //clear stickers and textviews
        for subview in canvasImageView.subviews {
            subview.removeFromSuperview()
        }
    }

    @IBAction func continueButtonPressed(_ sender: Any) {
        let img = self.canvasView.toImage()
        photoEditorDelegate?.doneEditing(image: img)
        self.dismiss(animated: true, completion: nil)
    }

    //MAKR: helper methods

    @objc func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(title: "Image Saved", message: "Image successfully saved to Photos library", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func hideControls() {
        for control in hiddenControls {
            switch control {

                case .clear:
                    clearButton.isHidden = true
                case .crop:
                    cropButton.isHidden = true
                case .draw:
                    drawButton.isHidden = true
                case .save:
                    saveButton.isHidden = true
                case .share:
                    shareButton.isHidden = true
                case .sticker:
                    stickerButton.isHidden = true
                case .text:
                    stickerButton.isHidden = true
            }
        }
    }

    @objc func hideKeyboard() {
        self.doneButtonTapped(doneButton)
    }

}
