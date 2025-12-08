//
//  TGCancelPopView.swift
//  RewardsLink
//
//  Created by Wong Jin Lun on 10/07/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit

class TGCancelPopView: UIView {

    @IBOutlet var alertView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var alertButtonClosure: (()->())?
    var cancelButtonClosure: (()->())?
    var closeButtonClosure: (()->())?
    
    var isVoucherPop: Bool = false
    var username: String? = ""
    var isFollow: Bool? = false
    var isBiometric: Bool = false
    var isInvalidPin: Bool = false
    var isGiftPop: Bool = false
    
    @IBAction func cancelAction(_ sender: Any) {
        cancelButtonClosure?()
    }
    
    @IBAction func alertAction(_ sender: Any) {
        alertButtonClosure?()
    }
    
    @IBAction func closeButtonClosure(_ sender: UIButton) {
        closeButtonClosure?()
    }
    
    
    init(isVoucherPop: Bool = false, isBiometric: Bool = false, isInvalidPin: Bool = false, username: String? = nil,  isFollow: Bool? = nil, isGift: Bool? = nil) {
        self.isVoucherPop = isVoucherPop
        self.isBiometric = isBiometric
        self.isInvalidPin = isInvalidPin
        self.username = username
        self.isFollow = isFollow
        self.isGiftPop = isGift ?? false
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        let bundle = Bundle(identifier: "com.yiyi.feedimsdk") ?? Bundle.main
        bundle.loadNibNamed(String(describing: TGCancelPopView.self), owner: self, options: nil)
        alertView.frame = self.bounds
        alertView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        closeButton.setImage(UIImage.set_image(named: "ic_btn_close"), for: .normal)
        closeButton.setTitle("", for: .normal)
        self.addSubview(alertView)
        alertView.roundCorner(10)
        var cancelText = "rw_text_no".localized
        
        cancelButton.applyStyle(.custom(text: cancelText, textColor: RLColor.normal.blackTitle, backgroundColor: RLColor.normal.keyboardTopCutLine, cornerRadius: 10))
        closeButton.isHidden = true
        
        if isVoucherPop {
            titleLabel.text = "rw_text_mark_as_redeemed".localized + "?"
            descLabel.text = "rw_text_voucher_redeem_desc".localized
        } else if let username = username {
            if let isFollow = isFollow, isFollow {
                descLabel.text = "profile_home_unfollow".localized + " " + username + "?"
            } else {
                descLabel.text = "profile_home_follow".localized + " " + username + "?"
            }
            descLabel.textColor = .black
            titleLabel.isHidden = true
        } else if isBiometric {
            titleLabel.text = "rw_disable_biometric_title".localized
            descLabel.text = "rw_disable_biometric_subtitle".localized
            cancelText = "cancel".localized
        } else if isInvalidPin {
            titleLabel.text = "rw_text_biometric_is_disabled".localized
            descLabel.text = "rw_biometric_invalid_pin_desc".localized
            cancelButton.isHidden = true
        } else if isGiftPop {
            titleLabel.text = "rw_gift_alert_title_text".localized
            descLabel.text = "rw_gift_alert_desc_text".localized
            cancelButton.isHidden = false
            closeButton.isHidden = false
            cancelText = "rw_gift_decline_button".localized
            cancelButton.applyStyle(.custom(text: cancelText, textColor: RLColor.main.red, backgroundColor: UIColor(hex: 0xFFD5D4), cornerRadius: 10))
        } else {
            titleLabel.text = "rw_text_cancel_transaction".localized
            descLabel.text = "rw_text_cancel_transaction_description".localized
        }
       
 

        var confirmText: String
        if let username = username {
            if let isFollow = isFollow, isFollow {
                confirmText = "profile_home_unfollow".localized
            } else {
                confirmText = "profile_home_follow".localized
            }
        } else if isInvalidPin {
            confirmText = "rw_text_biometric_failed_action".localized
        } else if isBiometric {
            confirmText = "rw_disable_biometric_btn_disable".localized
        } else if isGiftPop {
            confirmText = "text_confirm".localized
        } else {
            confirmText = "rw_text_yes".localized
            
        }
        confirmButton.applyStyle(.custom(text: confirmText, textColor: RLColor.main.white, backgroundColor: RLColor.main.red, cornerRadius: 10))

    }
    
}
