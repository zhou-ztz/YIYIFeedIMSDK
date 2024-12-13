//
//  SCCustomNavigationBar.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/2/20.
//

import UIKit

class SCCustomNavigationBar: UIView {

    // 标题标签
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .black // 设置文本颜色
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    lazy var titleView: UIView = {
        let label = UIView()
        label.isHidden = true
        return label
    }()
    
    lazy var leftStackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 4
        stack.axis = .horizontal
        stack.alignment = .leading
        return stack
    }()
    lazy var rightStackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 5
        stack.axis = .horizontal
        stack.alignment = .trailing
        stack.distribution = .fill
        return stack
    }()
    
    lazy var backItem: UIButton = {
        let item = UIButton()
        item.setImage(UIImage.set_image(named: "iconsArrowCaretleftBlack")?.withRenderingMode(.alwaysOriginal), for: .normal)
        item.setTitleColor(.black, for: .normal)
        item.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        return item
    }()
    
    var leftItems: [UIView] = []
    var rightItems: [UIView] = []
    
    lazy var backgroudImage: UIImageView = {
        let item = UIImageView()
        item.backgroundColor = .white
        item.isUserInteractionEnabled = true
        return item
    }()
    
    lazy var backgroudView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var title: String = "" {
        didSet{
            self.titleLabel.text = title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI(){
        self.addSubview(backgroudImage)
        backgroudImage.bindToEdges()
        backgroudImage.addSubview(backgroudView)
        backgroudView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(TSStatusBarHeight)
        }
        backgroudView.addSubview(titleLabel)
        backgroudView.addSubview(leftStackView)
        backgroudView.addSubview(rightStackView)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        leftStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(14)
        }
        rightStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-14)
        }
        
        setLeftViews(views: [backItem])
    }
    
    public func setTitleView(view: UIView){
        titleView = view
        titleView.isHidden = false
        titleLabel.isHidden = true
        backgroudView.addSubview(titleView)
        titleView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    public func setLeftViews(views: [UIView]){
        leftItems = views
        leftStackView.removeAllArrangedSubviews()
        for item in leftItems {
            leftStackView.addArrangedSubview(item)
            item.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.height.equalTo(30)
                make.width.greaterThanOrEqualTo(30)
            }
        }
        
    }
    public func setRightViews(views: [UIView]){
        rightItems = views
        rightStackView.removeAllArrangedSubviews()
        for item in rightItems {
            rightStackView.addArrangedSubview(item)
            item.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.height.equalTo(30)
                make.width.greaterThanOrEqualTo(30)
            }
        }
    }
}
