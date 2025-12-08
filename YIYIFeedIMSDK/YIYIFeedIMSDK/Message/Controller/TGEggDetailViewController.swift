//
//  TGEggDetailViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2025/2/12.
//

import UIKit

class TGEggDetailViewController: TGViewController {
    
    let eggView = UIView()
    let topCurvedView = UIView()
    let redPacketFromLabel = UILabel()
    let avatarImageView = UIImageView()
    let nameLabel = UILabel()
    let noteLabel = UILabel()
    let receiverLabel = UILabel()
    let amountView = UIView()
    let yippsAmountLabel = UILabel()
    let pointLabel = UILabel()
    let errorMessageLabel = UILabel()
    let packetInfoLabel = UILabel()
    let tableView = RLTableView()
    let disclaimerLabel = UILabel()
    let closeBtn = UIButton()
    let stackview = UIStackView()

    var info: ClaimEggResponse!
    var isSender: Bool = false
    var isGroup: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        customNavigationBar.isHidden = true
        closeBtn.setImage(UIImage.set_image(named: "IMG_topbar_close"), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        
        setupViews()
        setupTableView()
        setupConstraints()
        mapData()
    }
    
    override func viewDidLayoutSubviews() {
        topCurvedView.addBottomRoundedEdge(desiredCurve: 3.0)
        topCurvedView.setGradientBackground(colorTop: TGAppTheme.blue, colorBottom: UIColor(hex: 0x007AFF), view: topCurvedView)
    }
    
    @objc func closeAction() {
        self.dismiss(animated: true)
    }
    
    private func setupViews() {
        stackview.axis = .horizontal
        stackview.spacing = 5
        stackview.distribution = .fill
        stackview.alignment = .fill
        
        backBaseView.backgroundColor = RLColor.share.backGray
        backBaseView.addSubview(eggView)
        eggView.addSubview(topCurvedView)
        topCurvedView.addSubview(redPacketFromLabel)
        topCurvedView.addSubview(stackview)
        stackview.addArrangedSubview(avatarImageView)
        stackview.addArrangedSubview(nameLabel)
        
        topCurvedView.addSubview(noteLabel)
        topCurvedView.addSubview(receiverLabel)
        topCurvedView.addSubview(amountView)
        amountView.addSubview(yippsAmountLabel)
        amountView.addSubview(pointLabel)
        topCurvedView.addSubview(errorMessageLabel)
        backBaseView.addSubview(packetInfoLabel)
        backBaseView.addSubview(tableView)
        backBaseView.addSubview(disclaimerLabel)
        
        topCurvedView.addSubview(closeBtn)
        // 配置视图属性
        //eggView.backgroundColor = .tintColor
        topCurvedView.backgroundColor = .clear
        redPacketFromLabel.text = "Red packet from"
        redPacketFromLabel.textAlignment = .center
        redPacketFromLabel.font = UIFont.systemFont(ofSize: 11)
        redPacketFromLabel.textColor = .white
        
        avatarImageView.image = UIImage(named: "avatar")
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 15
        avatarImageView.clipsToBounds = true
        
        nameLabel.text = "sdfsdfsdf"
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .white
        
        noteLabel.text = "~Best wishes~"
        noteLabel.textAlignment = .center
        noteLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        noteLabel.textColor = .white
        
        receiverLabel.text = "Receiver"
        receiverLabel.textAlignment = .center
        receiverLabel.font = UIFont.systemFont(ofSize: 17)
        receiverLabel.textColor = .white
        
        yippsAmountLabel.text = "1.00"
        yippsAmountLabel.textAlignment = .center
        yippsAmountLabel.font = UIFont.systemFont(ofSize: 43, weight: .semibold)
        yippsAmountLabel.textColor = .white
        
        pointLabel.text = "pt"
        pointLabel.textAlignment = .center
        pointLabel.font = UIFont.systemFont(ofSize: 14)
        pointLabel.textColor = .white
        
        errorMessageLabel.text = "error message"
        errorMessageLabel.textAlignment = .center
        errorMessageLabel.font = UIFont.systemFont(ofSize: 19)
        errorMessageLabel.textColor = .white
        
        packetInfoLabel.text = "83 Red Pakcet(s) with 1000.00 pt in total."
        packetInfoLabel.textAlignment = .natural
        packetInfoLabel.font = UIFont.systemFont(ofSize: 17)
        packetInfoLabel.textColor = .black
        
        disclaimerLabel.text = "disclaimer Label"
        disclaimerLabel.textAlignment = .center
        disclaimerLabel.font = UIFont.systemFont(ofSize: 17)
        disclaimerLabel.textColor = .black
        avatarImageView.roundCorner(15)
        
        //errorMessage.applyStyle(.semibold(size: 20, color: UIColor.lightGray))
        
        redPacketFromLabel.text = "red_packet_from".localized
        
        packetInfoLabel.applyStyle(.regular(size: 12, color: .gray))
        
        disclaimerLabel.text = "viewholder_redpacket_refund".localized
        disclaimerLabel.font = UIFont.systemFont(ofSize: 12.0)
        disclaimerLabel.textColor = .gray
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.register(TGReceiverTableCell.self, forCellReuseIdentifier: "TGReceiverTableCell")
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.mj_header = nil
        tableView.mj_footer = nil
    }

    private func setupConstraints() {
        
        eggView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(350)
        }
        
        topCurvedView.snp.makeConstraints { make in
            make.edges.equalTo(eggView)
        }
        
        closeBtn.snp.makeConstraints { make in
            make.top.equalTo(TSStatusBarHeight + 12)
            make.left.equalTo(16)
           
        }
        
        redPacketFromLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(85)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(13.5)
        }
        
        stackview.snp.makeConstraints { make in
            make.top.equalTo(redPacketFromLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.left.equalToSuperview().inset(10)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
        }
        
        noteLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(19.5)
        }
        
        receiverLabel.snp.makeConstraints { make in
            make.top.equalTo(noteLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(20.5)
        }
        
        amountView.snp.makeConstraints { make in
            make.top.equalTo(receiverLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(51.5)
        }
        
        yippsAmountLabel.snp.makeConstraints { make in
            make.center.equalTo(amountView)
        }
        
        pointLabel.snp.makeConstraints { make in
            make.leading.equalTo(yippsAmountLabel.snp.trailing).offset(5)
            make.centerY.equalTo(amountView)
        }
        
        errorMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(amountView.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(23)
        }
        
        packetInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(eggView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        disclaimerLabel.snp.makeConstraints { make in
            make.height.equalTo(15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.bottom.equalTo(-25)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(packetInfoLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(disclaimerLabel.snp.top).offset(-5)
        }
        
        
    }
    
    private func mapData() {
        /// User avatar and name
        avatarImageView.sd_setImage(with: URL(string: (info.sender.avatar?.url).orEmpty), placeholderImage: UIImage(named: "IMG_pic_default_secret"))
        nameLabel.text = info.sender.name
        
        /// Wish note
        noteLabel.text = info.header.wishes
        noteLabel.isHidden = info.header.wishes.isEmpty
        
        /// Amount
        if isSender {
            yippsAmountLabel.text = info.header.amount
            if info.header.amount.orEmpty.isEmpty {
                amountView.makeHidden()
            } else {
                amountView.makeVisible()
            }
        } else {
            if let receiver = info.receivers.first(where: { $0.user.uid == (RLSDKManager.shared.loginParma?.uid ?? 0) }), receiver.amount.toDouble() > 0.0 {
                yippsAmountLabel.text = receiver.amount
                amountView.makeVisible()
            } else {
                amountView.makeHidden()
            }
        }
        pointLabel.text = "rewards_link_point_short".localized
        
        errorMessageLabel.text = info.header.messages
        
        if info.header.messages.orEmpty.isEmpty {
            errorMessageLabel.makeHidden()
        } else {
            errorMessageLabel.makeVisible()
        }
        
        receiverLabel.text = info.header.yippsMsg
        
        if info.header.yippsMsg.orEmpty.isEmpty {
            receiverLabel.makeHidden()
        } else {
            receiverLabel.makeVisible()
        }
        
        var header: String
        
        if info.receivers.count > 0 {
            if isGroup {
                header = "rw_text_quantity_egg_redeemed".localized.replacingFirstOccurrence(of: "%1s", with: "\(info.eggInfo.quantity.orZero - info.eggInfo.quantityRemaining.orZero)").replacingFirstOccurrence(of: "%2s", with: info.eggInfo.amount.orEmpty)
            } else {
                header = "rw_text_quantity_egg_redeemed".localized.replacingFirstOccurrence(of: "%1s", with: "\(info.eggInfo.quantity.orZero)").replacingFirstOccurrence(of: "%2s", with: info.eggInfo.amount.orEmpty)
            }
        } else {
            header = "rw_text_quantity_egg_not_redeemed".localized.replacingFirstOccurrence(of: "%1s", with: "\(info.eggInfo.quantity.orZero)").replacingFirstOccurrence(of: "%2s", with: info.eggInfo.amount.orEmpty)
        }
        
        packetInfoLabel.text = header
    }
    

}

// MARK: - UITableViewDelegate
extension TGEggDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return info.receivers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TGReceiverTableCell") as! TGReceiverTableCell
        let item = info.receivers[indexPath.row]
        cell.configureData(with: (item.user.avatar?.url).orEmpty, userId: item.user.uid, name: item.user.name, date: item.redeemTime, amount: item.amount, luckyStar: item.luckyStar ?? 0)
        return cell
    }
  
}
