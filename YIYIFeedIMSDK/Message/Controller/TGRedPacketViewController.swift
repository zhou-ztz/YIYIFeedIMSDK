//
//  TGRedPacketViewController.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji_zhou on 2024/12/27.
//

import UIKit

typealias ContactSelectCancelClosure = () -> Void
//typealias ContactSelectFinishClosure = ([ContactData]?) -> Void
typealias TransactionFinishClosure = (_ id: Int, _ userId: [String]?, _ msg: String) -> Void
typealias createGroupFinishBlock = (NSString) -> Void
typealias TransactionDismissClosure = () -> Void

enum ModeType {
    case random
    case identical
    case specific
    
    var value: String {
        switch self {
        case .random:
            return "redpacket_mode_random".localized
        case .identical:
            return "redpacket_mode_identical".localized
        case .specific:
            return "redpacket_mode_specific".localized
        default:
            return ""
        }
    }
}

enum TransactionType {
    case personal, group, yippsTransfer
}

class TGRedPacketViewController: TGViewController {
    
    var inputPrice: Double? {
        didSet {
          //  validate()
        }
    }
    /// 打赏金额 单位人民币分
    var inputPrices: [Int] = [1, 5, 10, 20]
    /// 打赏的目标Id
    var sourceId: Int?
   // var rewardSuccessAction: ((_ rewadModel: TSNewsRewardModel) -> Void)?
    
    var username: String
    var finishBlock: TransactionFinishClosure?
    var receiver: String
    var modeType: ModeType = .random
//    var selectedContact: ContactData? = nil
//    var transactionType: TransactionType = .personal
    var numberOfMember: Int
    var teamId: String? = nil
//    private var apiDebouncer = Debouncer(delay: 1)
//    private var handler: ((_ selectedPrice: Int) -> ())?
//    private var buttons: [TSButton] = []
    private(set) var selectedInputIndex: Int?
    private var redPacketId: Int?
    private var message: String?
    
    init(transactionType: TransactionType, fromUser: String, toUser: String, numberOfMember: Int, teamId: String? = nil, completion: TransactionFinishClosure?) {
        self.username = fromUser
        self.receiver = toUser
        self.numberOfMember = numberOfMember
        self.teamId = teamId
        super.init(nibName: nil, bundle: nil)
//        self.username = fromUser
//        self.receiver = toUser
//        self.numberOfMember = numberOfMember
//        self.transactionType = transactionType
//        self.finishBlock = completion
//        self.teamId = teamId
      //  super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
