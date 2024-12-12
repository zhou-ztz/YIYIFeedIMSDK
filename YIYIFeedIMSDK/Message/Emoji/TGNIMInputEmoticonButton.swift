
// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
protocol TGNIMInputEmoticonButtonDelegate: NSObjectProtocol {
    func selectedEmoticon(emotion: NIMInputEmoticon, catalogID: String)
}

class TGNIMInputEmoticonButton: UIButton {
    var emotionData: NIMInputEmoticon?
    var catalogID: String?
    weak var delegate: TGNIMInputEmoticonButtonDelegate?
    private let classsTag = "TGNIMInputEmoticonButton"
    
    class func iconButtonWithData(data: NIMInputEmoticon, catalogID: String,
                                         delegate: TGNIMInputEmoticonButtonDelegate)
    -> TGNIMInputEmoticonButton {
        let icon = TGNIMInputEmoticonButton()
        icon.addTarget(icon, action: #selector(onIconSelected), for: .touchUpInside)
        icon.emotionData = data
        icon.catalogID = catalogID
        icon.isUserInteractionEnabled = true
        icon.isExclusiveTouch = true
        icon.contentMode = .scaleToFill
        icon.delegate = delegate
        switch data.type {
        case .unicode:
            icon.setTitle(data.unicode, for: .normal)
            icon.setTitle(data.unicode, for: .highlighted)
            icon.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        default:
            let image = UIImage.ne_bundleImage(name: data.fileName ?? "")
            icon.setImage(image, for: .normal)
            icon.setImage(image, for: .highlighted)
        }
        return icon
    }
    
    @objc func onIconSelected(sender: TGNIMInputEmoticonButton) {
        guard let data = emotionData, let id = catalogID else {
            //NELog.errorLog(classsTag, desc: "emotionData or catalogID maybe nil")
            return
        }
        delegate?.selectedEmoticon(emotion: data, catalogID: id)
    }
}
