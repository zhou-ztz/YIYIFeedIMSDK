//
//  TGMeetingGroupViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/1/22.
//

import UIKit
import NIMSDK

class TGMeetingGroupViewController: TGViewController {

    var searchBar: MeetingSearchView!
    
    lazy var nextBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("next".localized, for: .normal)
        btn.setTitleColor(TGAppTheme.red, for: .normal)
        btn.titleLabel?.font = UIFont.systemMediumFont(ofSize: 17)
        return btn
    }()
    
    lazy var tableView: RLTableView = {
        let table = RLTableView(frame: .zero, style: .grouped)
        table.register(MeetingFriendsListCell.self, forCellReuseIdentifier: "MeetingFriendsListCell")
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 56
        return table
    }()
    var sortedModelArr: [[V2NIMTeam]] = []
    var teams: [V2NIMTeam] = []
    ///索引
    var indexDataSource = [String]()
    var choosedDataSource: [ContactData] = []
    
    var comfirmCall: (([ContactData]) -> ())?
    var meetingNumlimit = 50
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.customNavigationBar.backItem.setTitle("meeting_select_group".localized, for: .normal)
        setUI()
        initData()
    }
    
    func initData() {
        NIMSDK.shared().v2TeamService.getJoinedTeamList([NSNumber(value: V2NIMTeamType.TEAM_TYPE_NORMAL.rawValue)]) {[weak self] teams in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.teams = teams
                self.sortUserList(teams: self.teams)
            }
        }
        
    }
    func sortUserList(teams: [V2NIMTeam] ) {
        
        // 抽取首字母
        var resultNames: [String] = [String]()
        let nameArray = teams.map({ $0.name.transformToPinYin().first?.description ?? " "})
        
        let nameSet: NSSet = NSSet(array: nameArray)
        for item in nameSet {
            resultNames.append("\(item)")
        }
        // 排序, 同时保证特殊字符在最后
        resultNames = resultNames.sorted(by: { (one, two) -> Bool in
            if (one.isNotLetter()) {
                return false
            } else if (two.isNotLetter()) {
                return true
            } else {
                return one < two
            }
        })
        
        // 替换特殊字符
        self.indexDataSource.removeAll()
        let special: String = "#"
        for value in resultNames {
            if (value.isNotLetter()) {
                self.indexDataSource.append(special)
                break
            } else {
                self.indexDataSource.append(value)
            }
        }
        
        // 分组
        self.sortedModelArr.removeAll()
        for object in self.indexDataSource {
            
            let user: [V2NIMTeam] = teams.filter { dataModel in
                if let pinYin = dataModel.name.transformToPinYin().first?.description {
                    if (pinYin.isNotLetter() && object == special) {
                        return true
                    } else {
                        return pinYin == object
                    }
                } else {
                    return false
                }
            }

            self.sortedModelArr.append(user)
        
        }
        self.tableView.reloadData()
    }
    
    func setUI(){
        nextBtn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        self.customNavigationBar.setRightViews(views: [nextBtn])
        setSearchBar()
        self.backBaseView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(68)
        }
    }
    
    func setSearchBar(){
        searchBar = MeetingSearchView(frame: CGRect(x: 0, y: 14, width: ScreenWidth, height: 40))
        searchBar.delegate = self
        self.backBaseView.addSubview(searchBar)
    }
    
    
    @objc func nextAction(){
        self.view.endEditing(true)
        self.comfirmCall?(self.choosedDataSource)
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchNameFor(keyword: String){
        if keyword.count == 0 {
            self.sortUserList(teams: self.teams)
            return
        }
        
        let results = self.teams.filter { team in
            if team.name.uppercased().contains(keyword.uppercased()) {
                return true
            }
            return false
        }
        self.sortUserList(teams: results)
    }
}
extension TGMeetingGroupViewController: MeetingSearchViewDelegate{
    func searchDidClickReturn(text: String) {
        self.searchNameFor(keyword: text)
    }
    
    func searchDidClickCancel() {
        self.searchBar.searchTextFiled.resignFirstResponder()
        
    }
}

extension TGMeetingGroupViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return indexDataSource.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sortedModelArr[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingFriendsListCell", for: indexPath) as! MeetingFriendsListCell
        cell.currentChooseArray = self.choosedDataSource
        cell.team = sortedModelArr[indexPath.section][indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#D9D9D9")
        let lab = UILabel()
        lab.frame = CGRect(x: 15, y: 0, width: 100, height: 30)
        lab.text = indexDataSource[section]
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = UIColor(hex: "#808080")
        view.addSubview(lab)
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        return indexDataSource
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell: MeetingFriendsListCell = tableView.cellForRow(at: indexPath) as! MeetingFriendsListCell

        if cell.chatButton.isSelected {
            for (index, model) in choosedDataSource.enumerated() {
                let userinfo: ContactData = model 
                if userinfo.userName == cell.team?.teamId {
                    choosedDataSource.remove(at: index)
                    break
                }
            }
            cell.chatButton.isSelected = !cell.chatButton.isSelected
            
        } else {
            if let team = cell.team {
                let model = ContactData(team: team)
                choosedDataSource.insert(model, at: 0)
                
            }
            cell.chatButton.isSelected = !cell.chatButton.isSelected
            
        }
        
    }
    
    
}

