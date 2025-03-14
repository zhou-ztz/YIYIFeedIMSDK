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

class TGIMClientsViewController: TGViewController, NIMLoginManagerDelegate {

//    private lazy var tableView: UITableView = {
//        let tableView = UITableView(frame: .zero, style: .plain)
//        tableView.backgroundColor = UIColor(red: 0xec/255.0, green: 0xf1/255.0, blue: 0xf5/255.0, alpha: 1.0)
//        tableView.register(UINib(nibName: "NTESMutiClientsCell", bundle: nil), forCellReuseIdentifier: Identifier)
//        tableView.tableFooterView = createFooterView()
//        tableView.separatorStyle = .none
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -500, right: 0)
//        tableView.delegate = self
//        tableView.dataSource = self
//        return tableView
//    }()
//    
//    private var clients: [NIMLoginClient] = []
//    private let Identifier = "client_cell"
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        NIMSDK.shared().loginManager.add(self)
//        reload()
//    }
//    
//    deinit {
//        NIMSDK.shared().loginManager.remove(self)
//    }
//    
//    private func setupUI() {
//        navigationItem.title = NSLocalizedString("rw_multiport_screen_label", comment: "")
//        view.addSubview(tableView)
//        tableView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        let header = NTESClientsTableHeader(frame: .zero)
//        let size = header.sizeThatFits(view.bounds.size)
//        header.frame = CGRect(x: 0, y: 0, width: size.width, height: 15)
//        tableView.tableHeaderView = header
//    }
//    
//    private func createFooterView() -> UIView {
//        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 60))
//        footerView.backgroundColor = .clear
//        
//        let logoutButton = UIButton()
//        logoutButton.setTitle(String(format: NSLocalizedString("multiport_logout_from", comment: ""), NSLocalizedString("rw_multiport_screen_label", comment: "")), for: .normal)
//        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
//        logoutButton.setTitleColor(.red, for: .normal)
//        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
//        footerView.addSubview(logoutButton)
//        
//        logoutButton.snp.makeConstraints { make in
//            make.centerY.equalToSuperview()
//            make.leading.equalToSuperview().offset(15)
//        }
//        
//        return footerView
//    }
//    
//    @objc private func logout() {
//        for client in clients {
//            NIMSDK.shared().loginManager.kickOtherClient(client) { error in
//                // Handle error if needed
//            }
//        }
//    }
//    
//    private func reload() {
//        let mClients = NIMSDK.shared().loginManager.currentLoginClients
//        let newClients = mClients.filter { $0.type == .web }
//        clients = newClients
//        tableView.reloadData()
//    }
//    
//    // MARK: - UITableViewDataSource
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return clients.count
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 60
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier, for: indexPath) as! NTESMutiClientsCell
//        let client = clients[indexPath.row]
//        cell.refreshWidthCilent(client)
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let client = clients[indexPath.row]
//            NIMSDK.shared().loginManager.kickOtherClient(client) { [weak self] error in
//                self?.reload()
//            }
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let client = clients[indexPath.row]
//        NIMSDK.shared().loginManager.kickOtherClient(client) { [weak self] error in
//            if let error = error {
//                self?.view.makeToast("kicked_out_fail", duration: 2, position: .center)
//            } else {
//                self?.reload()
//            }
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 50
//    }
//    
//    // MARK: - NIMLoginManagerDelegate
//    
//    func onMultiLoginClientsChanged() {
//        clients = NIMSDK.shared().loginManager.currentLoginClients
//        if clients.isEmpty {
//            navigationController?.view.makeToast("no_other_devices_connected", duration: 2, position: .center)
//            navigationController?.popViewController(animated: true)
//        } else {
//            reload()
//        }
//    }
//    
//    // MARK: - Rotation Handling
//    
//    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
//        if let header = tableView.tableHeaderView {
//            let size = header.sizeThatFits(view.bounds.size)
//            header.frame.size = size
//            tableView.tableHeaderView = header
//        }
//    }
//    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        if let header = tableView.tableHeaderView {
//            let headerSize = header.sizeThatFits(size)
//            header.frame.size = headerSize
//            tableView.tableHeaderView = header
//        }
//    }
    
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
