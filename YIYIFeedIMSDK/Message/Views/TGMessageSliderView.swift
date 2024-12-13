//
//  TGMessageSliderView.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/13.
//

import UIKit
import SnapKit

class TGMessageSliderView: UIView {
    
    var tabs: [TabHeaderdModal] = []
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.spacing = 40
        stack.alignment = .center
        return stack
    }()
    
    var selectIndex: Int = 0
    
    var itemViews: [TGMessageSliderItemView] = []
    ///是否可以点击切换
    var isCanSlider = false
    
    var selectCallBack: ((Int)->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commitUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commitUI() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(30)
        }
        tabs = [TabHeaderdModal(titleString: "rw_text_chats".localized, messageCount: 0, bubbleColor: RLColor.share.theme, isSelected: true), TabHeaderdModal(titleString: "title_requests".localized, messageCount: 0, bubbleColor: RLColor.share.theme, isSelected: false)]
        for (index, tab) in tabs.enumerated() {
            let sub = TGMessageSliderItemView()
            
            stackView.addArrangedSubview(sub)
            sub.snp.makeConstraints { make in
                make.height.equalTo(30)
            }
            sub.tag = index
            sub.setModel(tab, index: index)
            sub.selectedView.isHidden = !(index == selectIndex)
            itemViews.append(sub)
            sub.addAction {[weak self] in
                self?.updateUI(index: sub.tag)
            }
        }
        
    }
    
    func updateUI(index: Int){

        if itemViews.count > index {
            let sub = itemViews[index]
            sub.setModel(tabs[index], index: index)
            
        }
        
        for (index, tab) in tabs.enumerated() {
            if isCanSlider {
                let sub = itemViews[index]
                sub.selectedView.isHidden = !(index == selectIndex)
            }
        }
        selectCallBack?(index)
    }
    
    
    
}

class TGMessageSliderItemView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor(hex: "#808080")
        return label
    }()
    let countView: UIView = UIView()
    lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor(hex: "#808080")
        return label
    }()
    let selectedView: UIView = UIView()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .fill
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commitUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func commitUI() {
        selectedView.backgroundColor = RLColor.share.theme
        selectedView.layer.cornerRadius = 2
        selectedView.clipsToBounds = true
        addSubview(stackView)
        addSubview(selectedView)
        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(2)
            make.top.equalToSuperview()
        }
        selectedView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.stackView.snp.bottom).offset(5)
            make.height.equalTo(4)
        }
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(countView)
        countView.addSubview(countLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        
        countView.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        
        countLabel.snp.makeConstraints { make in
            make.height.equalTo(16)
            make.left.right.equalToSuperview().inset(5)
            make.centerY.equalToSuperview()
        }
        
    }
    
    func setModel(_ tab: TabHeaderdModal, index: Int = 0){
        
        titleLabel.text = tab.titleString
        
        if tab.messageCount > 0 {
            countView.isHidden = false
            
            var countString: String = ""
            
            if tab.messageCount > 99 {
                countString = "99+"
            } else {
                countString = String(tab.messageCount)
            }
            
            countLabel.textColor = .white
            countLabel.backgroundColor = tab.bubbleColor
            
            countLabel.text = countString
            countLabel.roundCorner(8)
        } else {
            countView.isHidden = true
        }
        
        updateSelectedView(tab: tab, index: index)
    }
    
    func updateSelectedView(tab: TabHeaderdModal, index: Int) {
        if tab.isSelected {
            titleLabel.font =  .systemFont(ofSize: 14, weight: .regular)
            titleLabel.textColor = UIColor(hex: 0x242424)
            //selectedView.isHidden = false
        } else {
            titleLabel.font =  .systemFont(ofSize: 14, weight: .regular)
            titleLabel.textColor = UIColor(hex: 0xA5A5A5)
            //selectedView.isHidden = true
        }
        
        selectedView.snp.remakeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.stackView.snp.bottom).offset(5)
            make.height.equalTo(4)
        }
    }
    
}

class TabHeaderdModal {
    var titleString: String
    var messageCount: Int
    var bubbleColor: UIColor
    var isSelected: Bool

    init(titleString: String, messageCount: Int, bubbleColor: UIColor, isSelected: Bool) {
        self.titleString = titleString
        self.messageCount = messageCount
        self.bubbleColor = bubbleColor
        self.isSelected = isSelected
    }
}
