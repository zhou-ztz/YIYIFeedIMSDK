//
//  PhotoEditor+UITextView.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import Foundation
import UIKit

extension PhotoEditorViewController: UITextViewDelegate {

    public func textViewDidChange(_ textView: UITextView) {
        let oldFrame = textView.frame
        let sizeToFit = textView.sizeThatFits(CGSize(width: oldFrame.width, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: oldFrame.width, height: sizeToFit.height)
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        isTyping = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        backgroundView.addGestureRecognizer(tap)
        self.canvasImageView.addSubview(backgroundView)
        self.canvasImageView.bringSubviewToFront(textView)
        lastTextViewTransform = textView.transform
        activeTextView = textView
        textView.superview?.bringSubviewToFront(textView)
        textView.font = UIFont(name: "Helvetica-Bold", size: 30)
        self.currentActiveLabel?.removeFromSuperview()
        UIView.animate(withDuration: 0.3,
                       animations: {
                        textView.transform = CGAffineTransform.identity
                        textView.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 5)
        }, completion: nil)

    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        guard previousCenter != nil && textView.text.isEmpty == false else {
            currentTextViewCount -= 1
            textView.removeFromSuperview()
            return
        }
        // By Kit Foong (Set to nill will not able to change text color)
        //activeTextView = nil
        var label = UILabel()
        if currentActiveLabel != nil {
            currentTextViewCount -= 1
        }
        label = addLabel(frame: textView.frame, text: textView.text, textColor: textView.textColor)
        UIView.animate(withDuration: 0.3, animations: {
            textView.center = self.previousCenter!
            textView.transform = self.lastTextViewTransform!
        }) { (finished) -> Void in
            label.isHidden = false
            textView.superview?.addSubview(label)
            label.contentScaleFactor = 7
            label.setNeedsDisplay()
            textView.removeFromSuperview()
            self.currentActiveLabel = nil
        }
    }

    func addLabel(frame: CGRect, text: String, textColor: UIColor?) -> UILabel {
        let label = UILabel(frame: frame)
        label.text = text
        label.textColor = textColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.center = previousCenter!
        label.transform = lastTextViewTransform!
        label.font = UIFont(name: "Helvetica-Bold", size: 30)
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        label.layer.shadowOpacity = 0.2
        label.layer.shadowRadius = 1.0
        label.layer.backgroundColor = UIColor.clear.cgColor
        addLabelGestures(view: label)

        return label
    }

}
