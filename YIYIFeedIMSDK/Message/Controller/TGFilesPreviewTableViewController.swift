//
//  TGFilesPreviewTableViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/20.
//

import UIKit
import NIMSDK
import Foundation

class TGFilesPreviewTableViewController: UIViewController {

    let filesMessages: [V2NIMMessage]
    var sortedFilesMessages: [String:[V2NIMMessage]] = [:]
    var documentPreview: UIDocumentInteractionController!
    
    lazy var tableView: RLTableView = {
        let tb = RLTableView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 0), style: .plain)
        tb.showsVerticalScrollIndicator = false
        tb.separatorStyle = .none
        tb.delegate = self
        tb.dataSource = self
        tb.backgroundColor = .white
        return tb
    }()
    
    init(filesMessages: [V2NIMMessage]) {
        self.filesMessages = filesMessages
        self.sortedFilesMessages = Dictionary(grouping: filesMessages) {($0.createTime.keyForPreviewObject())}
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        tableView.bindToEdges()
        tableView.register(TGFilesPreviewTableViewCell.self, forCellReuseIdentifier: TGFilesPreviewTableViewCell.cellReuseIdentifier)
        tableView.mj_header = nil
        tableView.mj_footer = nil
        tableView.rowHeight = UITableView.automaticDimension
    }
}

// MARK: - Table view data source
extension TGFilesPreviewTableViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sortedFilesMessages.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let key = self.getKey(section)
        return self.sortedFilesMessages[key]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TGFilesPreviewTableViewCell.cellReuseIdentifier, for: indexPath) as! TGFilesPreviewTableViewCell
        let section = indexPath.section
        let row = indexPath.row
        let key = self.getKey(section)
        if let dataObj: V2NIMMessageFileAttachment = self.sortedFilesMessages[key]?[row].attachment as? V2NIMMessageFileAttachment {
            cell.setData(attachment: dataObj)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 45))
        let titleLbl = UILabel(frame: CGRect(x: 10, y: 0, width: ScreenWidth - 20, height: 45))
        titleLbl.text = self.getKey(section)
        titleLbl.font = UIFont.systemFont(ofSize: 15)
        headerView.addSubview(titleLbl)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        let key = self.getKey(section)
        if let dataObj: V2NIMMessageFileAttachment = self.sortedFilesMessages[key]?[row].attachment as? V2NIMMessageFileAttachment, let path = dataObj.path {
            if FileManager.default.fileExists(atPath: path) {
                documentPreview = UIDocumentInteractionController(url: URL(fileURLWithPath: path))
                documentPreview.name = dataObj.name
                documentPreview.delegate = self
                documentPreview.presentPreview(animated: true)
            } else {
                let vc = TGIMFilePreViewController(object: dataObj)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    private func getKey(_ section: Int) -> String {
        let keys = Array(self.sortedFilesMessages.keys).sorted(by: >)
        return keys[section]
    }
}

extension TGFilesPreviewTableViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        documentPreview = nil
    }
    
}

extension TimeInterval {
    
    func keyForPreviewObject() -> String {
        let calendar = NSCalendar.current
        let date = Date(timeIntervalSince1970: self)
        let now = Date()
        let components = Set<Calendar.Component>([.year, .month, .day])

        let dateComponents = calendar.dateComponents(components, from: date)
        let nowComponents = calendar.dateComponents(components, from: now)
        
        var key = ""
        if (dateComponents.year == nowComponents.year && dateComponents.month == nowComponents.month && dateComponents.weekOfMonth == nowComponents.weekOfMonth) {
            key = "this_week".localized
        } else {
            if let year = dateComponents.year, let month = dateComponents.month {
                key = String(format: "year_month".localized, year, month)
            }
        }
        return key
    }
}
