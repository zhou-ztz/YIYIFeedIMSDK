//
//  TGIMClientsViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/3/12.
//

import UIKit
import SnapKit
import NIMSDK
import Toast

class TGIMClientsViewController: TGViewController, V2NIMLoginListener, UITableViewDelegate, UITableViewDataSource {

    lazy var tableView: UITableView = {
        let tb = UITableView(frame: .zero, style: .plain)
        tb.backgroundColor = UIColor(red: 0xec/255.0, green: 0xf1/255.0, blue: 0xf5/255.0, alpha: 1.0)
        tb.register(TGNTESMutiClientsCell.self, forCellReuseIdentifier: Identifier)
        tb.tableFooterView = createFooterView()
        tb.separatorStyle = .none
        tb.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -500, right: 0)
        tb.delegate = self
        tb.dataSource = self
        return tb
    }()
    
    private var clients: [V2NIMLoginClient] = []
    private let Identifier = "client_cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NIMSDK.shared().v2LoginService.add(self)
        reload()
    }
    
    deinit {
        NIMSDK.shared().v2LoginService.remove(self)
    }
    
    private func setupUI() {
        customNavigationBar.title = "rw_multiport_screen_label".localized
        backBaseView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let header = NTESClientsTableHeader(frame: .zero)
        let size = header.sizeThatFits(view.bounds.size)
        header.frame = CGRect(x: 0, y: 0, width: size.width, height: 15)
        tableView.tableHeaderView = header
    }
    
    private func createFooterView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 60))
        footerView.backgroundColor = .clear
        
        let logoutButton = UIButton()
        logoutButton.setTitle(String(format: NSLocalizedString("multiport_logout_from", comment: ""), NSLocalizedString("rw_multiport_screen_label", comment: "")), for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        logoutButton.setTitleColor(.red, for: .normal)
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        footerView.addSubview(logoutButton)
        
        logoutButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
        }
        
        return footerView
    }
    
    @objc private func logout() {
        for client in clients {
            NIMSDK.shared().v2LoginService.kickOffline(client) {
            
            } failure: { error in
                
            }

        }
    }
    
    private func reload() {
        
        let mClients = NIMSDK.shared().v2LoginService.getLoginClients()
        let newClients = mClients?.filter { $0.type == .LOGIN_CLIENT_TYPE_WEB }
        clients = newClients ?? []
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clients.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier, for: indexPath) as! TGNTESMutiClientsCell
        let client = clients[indexPath.row]
        cell.refreshWidthCilent(client)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let client = clients[indexPath.row]
//            NIMSDK.shared().v2LoginService.kickOffline(client) {[weak self] in
//                self?.reload()
//            } failure: { error in
//                
//            }
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let client = clients[indexPath.row]
//        NIMSDK.shared().v2LoginService.kickOffline(client) {[weak self] in
//            self?.reload()
//        } failure: {[weak self] error in
//            self?.view.makeToast("kicked_out_fail", duration: 2, position: CSToastPositionCenter)
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    // MARK: - NIMLoginManagerDelegate
    
    func onLoginClientChanged(_ change: V2NIMLoginClientChange, clients: [V2NIMLoginClient]?) {
        let mClients = NIMSDK.shared().v2LoginService.getLoginClients()
        self.clients = mClients ?? []
        if self.clients.isEmpty {
            navigationController?.view.makeToast("no_other_devices_connected", duration: 2, position: CSToastPositionCenter)
            navigationController?.popViewController(animated: true)
        } else {
            reload()
        }
    }
    
//    func onMultiLoginClientsChanged() {
//        let mClients = NIMSDK.shared().v2LoginService.getLoginClients()
//        clients = mClients ?? []
//        if clients.isEmpty {
//            navigationController?.view.makeToast("no_other_devices_connected", duration: 2, position: CSToastPositionCenter)
//            navigationController?.popViewController(animated: true)
//        } else {
//            reload()
//        }
//    }
    
    // MARK: - Rotation Handling
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if let header = tableView.tableHeaderView {
            let size = header.sizeThatFits(view.bounds.size)
            header.frame.size = size
            tableView.tableHeaderView = header
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let header = tableView.tableHeaderView {
            let headerSize = header.sizeThatFits(size)
            header.frame.size = headerSize
            tableView.tableHeaderView = header
        }
    }
    
}

class NTESClientsTableHeader: UIView {
    
    private lazy var icon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "icon_clients"))
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(icon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        icon.snp.makeConstraints { make in
            make.top.equalTo(IconTop)
            make.centerX.equalToSuperview()
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = size.height - NavBarHeight - UIApplication.shared.statusBarFrame.height - TableHeaderBottom
        return CGSize(width: size.width, height: height)
    }
    
    private let TableHeaderBottom: CGFloat = 75.0
    private let NavBarHeight: CGFloat = 44.0
    private let IconTop: CGFloat = 73.0
}
