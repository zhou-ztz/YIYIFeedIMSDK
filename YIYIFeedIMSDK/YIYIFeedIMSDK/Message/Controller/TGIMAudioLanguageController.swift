//
//  TGIMAudioLanguageController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/19.
//

import UIKit


struct SupportedLanguage {
    let code: String?
    let name: String?
}

class TGIMAudioLanguageController: UIViewController {
    
    //选择语言回调
    var onLanguageCodeDidSelect: ((String) -> Void)?
    /* UI */
    lazy var backgroundView = UIView(frame: .zero).configure {
        $0.backgroundColor = UIColor.clear
    }
    lazy var contentView = UIView(frame: .zero).configure {
        $0.backgroundColor = .white
    }
    //头部视图
    private let titleView = UIView(frame: .zero).configure {
        $0.backgroundColor = .white
    }
    //标题
    private let titleLabel: UILabel = UILabel(frame: .zero).configure {
        $0.applyStyle(.semibold(size: 16, color: TGAppTheme.black))
    }
    //关闭按钮
    private let closeButton: UIButton = UIButton(type: .custom).configure {
        $0.setImage(UIImage(named: "ic_closebtn_black"), for: .normal)
    }
    
    fileprivate let headerStackView: UIStackView = UIStackView(frame: .zero).configure {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.alignment = .fill
        $0.spacing = 10
    }
    /* tableview */
    fileprivate let tableView: RLTableView = RLTableView(frame: .zero, style: .plain).configure {
        $0.register(TGProfileLanguageListCell.self, forCellReuseIdentifier: TGProfileLanguageListCell.identifier)
        $0.contentInsetAdjustmentBehavior = .never
        $0.backgroundColor = .white
        $0.separatorStyle = .none
        $0.rowHeight = 60
    }
    // 弹出页面高度占整个屏幕的比例
    private var viewHeightPercent: Double = 0.55

    private var currentSelectedLangCode: SupportedLanguage = {
        let langIdentifier = TGLanguageIdentifier(rawValue: TGLocalizationManager.getCurrentLanguage())?.rawValue ?? "en"
        
        if let preferredLanguageObject = UserDefaults.standard.object(forKey: "SpeechToTextTypingLanguage") as? [String:String] {
            return SupportedLanguage(code: preferredLanguageObject["locale"] ?? langIdentifier, name: preferredLanguageObject["name"] ?? TGLocalizationManager.getDisplayNameForLanguageIdentifier(identifier: langIdentifier))
        }

        return SupportedLanguage(code: langIdentifier, name: TGLocalizationManager.getDisplayNameForLanguageIdentifier(identifier: langIdentifier))
    }()
    private var availableLanguages: [SupportedLanguage] {
        var availbaleLanguages: [SupportedLanguage] = []
        for locale in TGLocalizationManager.availableLanugages() {
            let language = SupportedLanguage (
                code: locale,
                name: TGLocalizationManager.getDisplayNameForLanguageIdentifier(identifier: locale)
            )
            availbaleLanguages.append(language)
            
        }
        return availbaleLanguages
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContents()
        setupStyles()
        binds()
        // Do any additional setup after loading the view.
    }
    
    private func setupContents() {

        view.backgroundColor = .clear
        view.addSubview(backgroundView)
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * self.viewHeightPercent)
        }
        backgroundView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(contentView.snp.top)
        }
    
        titleView.addSubview(titleLabel)
        titleView.addSubview(closeButton)

        contentView.addSubview(headerStackView)
        headerStackView.addArrangedSubview(titleView)
        
        headerStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
            make.centerX.equalToSuperview()
        }
        titleView.snp.makeConstraints { make in
            make.height.equalTo(45)
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(28)
        }
        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalTo(titleLabel)
        }

        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.top.equalTo(headerStackView.snp.bottom).offset(10)
        }
        
    }
    private func setupStyles() {
        contentView.layer.cornerRadius = 15.0
        contentView.layer.masksToBounds = true

    }
    
    private func binds() {
      
        self.titleLabel.text = "im_choose_language".localized
        
        tableView.mj_header = nil
        tableView.mj_footer = nil
        
        tableView.delegate = self
        tableView.dataSource = self
        backgroundView.addAction {
            self.dismiss(animated: true)
        }
        closeButton.addAction {
            self.dismiss(animated: true)
        }
        
    }
    public func setLanguage(code: String) {
        
        let languageName = TGLocalizationManager.getDisplayNameForLanguageIdentifier(identifier: code)
        
        let dict = [
            "locale": code,
            "name": languageName
        ]

        UserDefaults.standard.set(dict, forKey: "SpeechToTextTypingLanguage")
    }
    
 

}
extension TGIMAudioLanguageController: UITableViewDelegate, UITableViewDataSource {
    // MARK: UITableViewDelegate, UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableLanguages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "TGProfileLanguageListCell") as! TGProfileLanguageListCell
        cell.selectionStyle = .none
        cell.languageNameLabel.text = availableLanguages[indexPath.row].name
        if currentSelectedLangCode.code == availableLanguages[indexPath.row].code {
            cell.selectImageBtn.isSelected = true
        }else{
            cell.selectImageBtn.isSelected = false
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setLanguage(code: availableLanguages[indexPath.row].code ?? "en")
        self.onLanguageCodeDidSelect?(availableLanguages[indexPath.row].code ?? "en")
        self.dismiss(animated: true)
    }
    
}
