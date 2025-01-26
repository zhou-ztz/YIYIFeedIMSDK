//
//  TGChatSettingView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/20.
//

import UIKit
import SnapKit

class TGChatSettingView: UIView {

    private(set) var title: String {
        didSet {
            self.titleLabel.text = title
        }
    }
    private(set) var titleColor: UIColor {
        didSet {
            self.titleLabel.textColor = titleColor
        }
    }
    private(set) var type: SettingType
    
    private let contentView: UIStackView = UIStackView().configure {
        $0.spacing = 8
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
    }
    
    private let titleLabel = UILabel().configure { label in
        label.wordWrapped().setFontSize(with: 15.0, weight: .norm)
        label.textColor = .black
    }
    
    private let valueLabel = UILabel().configure { label in
        label.wordWrapped().setFontSize(with: 15.0, weight: .norm)
        label.textColor = RLColor.normal.minor
        label.textAlignment = .right
        label.numberOfLines = 1
    }
    
    private let indicator = UIImageView().configure { imageView in
        imageView.image = UIImage(named: "IMG_ic_arrow_smallgrey")
        imageView.contentMode = .scaleAspectFit
    }
    
    private let switchControl = UISwitch()
    private let iconView = UIImageView().configure { imageView in
        imageView.contentMode = .scaleAspectFill
    }
    
    private let tapView = UIButton()
    
    init(settingData: TGTeamSetting, delegate: UIViewController) {
        self.title = settingData.name
        self.type = settingData.settingType
        self.titleColor = .black
        
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        self.contentView.backgroundColor = .clear
        
        addSubview(contentView)
        contentView.addArrangedSubview(titleLabel)
        self.titleLabel.text = title
        
        if let color = settingData.titleColor {
            self.titleLabel.textColor = color
            self.indicator.isHidden = true
        }
        
        if let detail = settingData.detailValue {
            valueLabel.text = detail
            contentView.addArrangedSubview(valueLabel)
            valueLabel.snp.makeConstraints {
                $0.width.equalTo(130)
            }
        }
        
        if type == .groupIcon {
            iconView.sd_setImage(with: URL(string: settingData.imageUrl ?? ""), placeholderImage: UIImage(named: "ic_rl_default_group"), options: [.continueInBackground], completed: nil)
            contentView.addArrangedSubview(iconView)
            iconView.snp.makeConstraints {
                $0.width.height.equalTo(40)
            }
        } else {
            if let imageUrl = settingData.imageUrl {
                iconView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "IMG_pic_default_secret"), options: [.continueInBackground], completed: nil)
                contentView.addArrangedSubview(iconView)
                iconView.snp.makeConstraints {
                    $0.width.height.equalTo(40)
                }
            }
        }
        
        if let value = settingData.switchValue {
            self.switchControl.isOn = value
            contentView.addArrangedSubview(switchControl)
            switchControl.addTarget(delegate, action: settingData.selector, for: .valueChanged)
            switchControl.snp.makeConstraints {
                $0.width.equalTo(51)
            }
        } else {
            addSubview(tapView)
            tapView.addTarget(delegate, action: settingData.selector, for: .touchUpInside)
            tapView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            contentView.addArrangedSubview(indicator)
            indicator.snp.makeConstraints {
                $0.height.width.equalTo(20)
            }
        }
        
        if !settingData.clickable {
            indicator.isHidden = true
            isUserInteractionEnabled = false
        }
        
        contentView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        iconView.roundCorner(20)
        iconView.clipsToBounds = true
        
        layoutIfNeeded()
    }
    
    func setImageUrl(_ url: String?) {
        iconView.sd_setImage(with: URL(string: url.orEmpty), placeholderImage: UIImage(named: "IMG_pic_default_secret"), options: [.continueInBackground], completed: nil)
    }
    
    func setSwitchValue(_ isOn: Bool) {
        switchControl.isOn = isOn
    }
    
    func setTitle(_ value: String) {
        self.title = value
    }
    
    func setTitleColor(_ color: UIColor) {
        self.titleColor = color
    }
    
    func setValue(_ value: String?) {
        self.valueLabel.text = value
        if !contentView.arrangedSubviews.contains(valueLabel) {
            contentView.insertArrangedSubview(valueLabel, at: 1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
