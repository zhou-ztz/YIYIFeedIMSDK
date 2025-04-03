//
//  TGRejectListController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/4/1.
//

import UIKit

public class TGRejectListController: TGViewController {

    var dataArray : [TGRejectListModel] = []
    var after: Int? = nil
    let limit: Int = 15
    /// 分页
    var page = 1
    private lazy var rejectListTableView: RLTableView = {
        let tableView = RLTableView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height - TSNavigationBarHeight), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 0
        tableView.rowHeight = 60
        tableView.backgroundColor = .white
        
        tableView.register(TGRejectedListTableViewCell.self, forCellReuseIdentifier: TGRejectedListTableViewCell.identifier)
        return tableView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.backBaseView.addSubview(rejectListTableView)
        rejectListTableView.mj_header = SCRefreshHeader(refreshingTarget: self, refreshingAction: #selector(getData))
        rejectListTableView.mj_footer = SCRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreList))
        rejectListTableView.mj_footer.isHidden = true
        rejectListTableView.mj_header.beginRefreshing()
        rejectListTableView.bindToEdges()
        // Do any additional setup after loading the view.
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCloseButton(backImage: true, titleStr: "rejected_post".localized)
    }
    
    @objc func getData() {
        page = 1
        let readGroup = DispatchGroup()
        
        readGroup.enter() // 进入 DispatchGroup
        
        TGFeedNetworkManager.shared.fetchFeedRejectList(withPage: page.stringValue, limit: limit) { [weak self] model, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.page += 1
                self.rejectListTableView.mj_header.endRefreshing()
                
                guard let data = model?.data, !data.isEmpty else {
                    self.page -= 1
                    self.rejectListTableView.show(placeholderView: .network)
                    self.showTopFloatingToast(with: "system_error_msg".localized)
                    readGroup.leave()
                    return
                }
                
                self.rejectListTableView.removePlaceholderViews()
                self.dataArray = data
                
                if data.count < self.limit {
                    self.rejectListTableView.mj_footer.isHidden = true
                    self.rejectListTableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self.rejectListTableView.mj_footer.isHidden = false
                    self.rejectListTableView.mj_footer.resetNoMoreData()
                }
                
                self.rejectListTableView.reloadData()
                readGroup.leave()
            }
        }

        // 监听数据获取完成
        readGroup.notify(queue: .main) {
            if self.dataArray.isEmpty {
                return
            }
            TGFeedNetworkManager.shared.readAllNoti { model, error in
                guard let model = model else { return }
//                TGCurrentUserInfo.share.unreadCount.reject = 0
                NotificationCenter.default.post(name: NSNotification.Name.DashBoard.reloadNotificationBadge, object: nil)
            }
        }
    }
    
    @objc func loadMoreList() {
        
        TGFeedNetworkManager.shared.fetchFeedRejectList(withPage: page.stringValue, limit: limit) { [weak self] model, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.page += 1
                self.rejectListTableView.mj_header.endRefreshing()
                
                guard let data = model?.data, !data.isEmpty else {
                    self.page -= 1
                    self.rejectListTableView.show(placeholderView: .network)
                    self.showTopFloatingToast(with: "system_error_msg".localized)
                    return
                }
                
                self.dataArray = self.dataArray + data
                
                if data.count < self.limit {
                    //                        self.rejectListTableView.mj_footer.isHidden = true
                    self.rejectListTableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    //                        self.rejectListTableView.mj_footer.isHidden = false
                    self.rejectListTableView.mj_footer.resetNoMoreData()
                }
                
                self.rejectListTableView.reloadData()
            }
        }
        
    }

}
extension TGRejectListController :UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TGRejectedListTableViewCell.identifier, for: indexPath) as! TGRejectedListTableViewCell
        cell.selectionStyle = .none
        cell.setReject(data: dataArray[indexPath.row])
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = TGRejectedDetailController(feedId: dataArray[indexPath.row].id.stringValue)
        vc.onDelete = {
            self.rejectListTableView.mj_header.beginRefreshing()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
