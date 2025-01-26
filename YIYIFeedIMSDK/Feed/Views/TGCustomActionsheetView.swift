//
//  TGCustomActionsheetView.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/3.
//

import UIKit

protocol TGCustomAcionSheetDelegate: NSObjectProtocol {
    func returnSelectTitle(view: TGCustomActionsheetView, title: String, index: Int)
}

private let acionSheetCellHeight: CGFloat = 55.0
private let actionFootViewOffset: CGFloat = 5.0

class TGCustomActionsheetView: UIView, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    /// 结果返回 block，效果同 TSCustomAcionSheetDelegate，两者任意实现其一即可
    var finishBlock: ((TGCustomActionsheetView, String, Int) -> Void)?

    weak var delegate: TGCustomAcionSheetDelegate? = nil
    private weak var superView: UIView!
    private var yAxisOffset: CGFloat?
    private var titles: Array<String>?
    private var yAxis: CGFloat?
    var actionSheetTableView: UITableView!
    /// 不能点击的区域
    public var notClickIndexs: [Int]?
    /// 自定义颜色
    public var colors = [(Int, UIColor)]()
    /// 取消按钮内容
    var cancelText: String = "cancel".localized
    // MARK: - Lifecycle
    /// 自定义初始化方法
    ///
    /// - Parameters:
    ///   - titles: 从上至下依次排序的title(取消不用传入，默认就有)
    ///   - superViewController: 父类控制器
    init(titles: Array<String>!, cancelText: String? = nil) {
        super.init(frame: CGRect.zero)
        self.titles = titles
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                let window = windowScene.windows.first(where: { $0.isKeyWindow })
                // 使用 window
            }
        } else {
            let window = UIApplication.shared.keyWindow
            // 使用 window
        }
        self.frame = (window?.bounds) ?? CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        self.superView = window
        self.backgroundColor = UIColor(hex: 0x000000, alpha: 0.0)
        if let text = cancelText {
            self.cancelText = text
        }
    }

    /// 设置文字颜色行数
    public func setColor(color: UIColor, index: Int) {
        colors.append((index, color))
    }

    /// 显示
    func show() {
        let window: UIWindow?
        if #available(iOS 13.0, *) {
            // iOS 13+ 获取当前活动场景的 keyWindow
            window = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            // iOS 12 及以下使用旧方法
            window = UIApplication.shared.keyWindow
        }
        window?.addSubview(self)
        self.frame = window!.bounds
        self.setUI()
        self.setGesture()
    }

    private func setGesture() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(cancelTouch))
        tapGR.delegate = self
        self.addGestureRecognizer(tapGR)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setUI() {
        yAxis = CGFloat(self.titles!.count + 1) * acionSheetCellHeight
        actionSheetTableView = UITableView(frame: CGRect(x: 0, y: self.bounds.size.height, width: self.superView.bounds.size.width, height: yAxis!), style: .plain)
        actionSheetTableView.delegate = self
        actionSheetTableView.dataSource = self
        actionSheetTableView.isScrollEnabled = false
        actionSheetTableView.tableFooterView = self.setFootView()
        actionSheetTableView.separatorColor = RLColor.inconspicuous.disabled
        actionSheetTableView.register(UINib(nibName: "TGCustomActionsheetTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        actionSheetTableView.backgroundColor = RLColor.inconspicuous.background
        self.addSubview(actionSheetTableView)
        self.selfRemove(isShowTableView: true)
    }

    // MARK: - tableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles!.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TGCustomActionsheetTableViewCell
        if colors.count > 0 {
            for item in colors {
                if indexPath.row == item.0 {
                    cell?.describeLabel.textColor = item.1
                }
            }
        }
        if (cell?.responds(to:#selector(setter: UIView.layoutMargins)))! {
            cell?.layoutMargins = UIEdgeInsets.zero
        }
        if (cell?.responds(to: #selector(setter: UITableViewCell.separatorInset)))! {
            cell?.separatorInset = UIEdgeInsets.zero
        }
        cell?.selectionStyle = .none
        cell?.describeText = self.titles![indexPath.row]

        return cell!

    }

    // MARK: - didSelectRow
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let indexs = self.notClickIndexs {
            for item in indexs {
                if indexPath.row == item {
                    return
                }
            }
        }
        /// 模拟点击效果
        if #available(iOS 13.0, *) {
            cell?.contentView.backgroundColor = UIColor.systemGroupedBackground
        } else {
            cell?.contentView.backgroundColor = UIColor.groupTableViewBackground
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            cell?.contentView.backgroundColor = UIColor.white
        }
        tableView.deselectRow(at: indexPath, animated: true)
        // [长期注释] finishBlock 和 delegate 效果相同，任意实现其一即可
        self.delegate?.returnSelectTitle(view: self, title: self.titles![indexPath.row], index:indexPath.row)
        finishBlock?(self, titles![indexPath.row], indexPath.row)
        self.selfRemove(isShowTableView: false)
    }

    func setFootView() -> UIView {
        let actionFootView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: acionSheetCellHeight + actionFootViewOffset))

        let footButton = UIButton(type: .custom)
        footButton.frame = CGRect(x: 0, y: actionFootViewOffset, width: self.bounds.size.width, height: acionSheetCellHeight - actionFootViewOffset)
        footButton.setTitle(cancelText, for: .normal)
        footButton.titleLabel?.textAlignment = NSTextAlignment.center
        footButton.setTitleColor(RLColor.normal.blackTitle, for: .normal)
        footButton.titleLabel?.font = UIFont.systemFont(ofSize: RLFont.Button.navigation.rawValue)
        footButton.addTarget(self, action: #selector(cancelTouch), for: .touchUpInside)
        footButton.backgroundColor = UIColor.white
        actionFootView.addSubview(footButton)
        actionFootView.backgroundColor = UIColor.clear
        return actionFootView
    }

    // MARK: - 判断是否是点击到BGView
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchView = touch.view
        if  touchView?.isEqual(self) == true {
            return true
        } else {
            return false
        }
    }

    // MARK: - 点击取消按钮
    @objc func cancelTouch() {
        self.selfRemove(isShowTableView: false)
    }

    /// 让自身消失
    ///
    /// - Parameter isShowTableView: 是否是消失
    func selfRemove(isShowTableView: Bool) {

        if isShowTableView {
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundColor = RLColor.normal.transparentBackground
                self.actionSheetTableView.frame = CGRect(x: 0, y: self.bounds.size.height - self.yAxis! - TSBottomSafeAreaHeight, width: self.bounds.width, height: self.yAxis!)
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundColor = UIColor(hex: 0x000000, alpha: 0.0)
                self.actionSheetTableView.frame.origin = CGPoint(x: 0, y: self.bounds.size.height)
            }) { (_) in
                self.removeFromSuperview()
            }
        }
    }

}
