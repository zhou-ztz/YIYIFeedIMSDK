//
//  ChatRecordView.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/9.
//

import UIKit


protocol ChatRecordViewDelegate: NSObjectProtocol {
    func startRecord()
    func moveOutView()
    func moveInView()
    func endRecord(insideView: Bool)
}

class ChatRecordView: UIView, UIGestureRecognizerDelegate {
    
    var recordImageView = UIImageView()
    var topTipLabel = UILabel()
    var tipLabel = UILabel()
    public weak var delegate: ChatRecordViewDelegate?
    private var outView = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonUI() {
        topTipLabel.translatesAutoresizingMaskIntoConstraints = false
        topTipLabel.text = "松开发送，按住滑动到空白区域取消"
        topTipLabel.font = UIFont.systemFont(ofSize: 12)
        topTipLabel.textColor = RLColor.share.lightGray
        topTipLabel.textAlignment = .center
        addSubview(topTipLabel)
        topTipLabel.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(23)
        }
        
        recordImageView.translatesAutoresizingMaskIntoConstraints = false
        recordImageView.image = UIImage.set_image(named: "chat_record")
        recordImageView.contentMode = .center
        addSubview(recordImageView)
        recordImageView.snp.makeConstraints { make in
            make.top.equalTo(40)
            make.height.width.equalTo(100)
            make.centerX.equalToSuperview()
        }
        
        if let image1 = UIImage.set_image(named: "record_4"),
           let image2 = UIImage.set_image(named: "record_3"),
           let image3 = UIImage.set_image(named: "record_2") {
            recordImageView.animationImages = [image1, image2, image3]
        }
        recordImageView.animationDuration = 0.8
        let guesture = UILongPressGestureRecognizer(target: self, action: #selector(clickLabel))
        recordImageView.isUserInteractionEnabled = true
        recordImageView.addGestureRecognizer(guesture)
        
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        tipLabel.text = "按住说话"
        tipLabel.font = UIFont.systemFont(ofSize: 12)
        tipLabel.textColor = RLColor.share.lightGray
        tipLabel.textAlignment = .center
        addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(23)
            make.top.equalTo(recordImageView.snp.bottom).offset(12)
        }
    }
    
    @objc func clickLabel(recognizer: UILongPressGestureRecognizer) {
        //    print("location:\(recognizer.location(in: recognizer.view))")
        switch recognizer.state {
        case .began:
            print("state:begin")
            startRecord()
        case .changed:
            print("state:changed")
        case .ended:
            endRecord(recognizer: recognizer)
        case .cancelled:
            endRecord(recognizer: recognizer)
            print("state:cancelled")
        case .failed:
            endRecord(recognizer: recognizer)
            print("state:failed")
        default:
            print("state:default")
        }
    }
    
    public func stopRecordAnimation() {
        topTipLabel.isHidden = true
        recordImageView.stopAnimating()
    }
    
    private func startRecord() {
        topTipLabel.isHidden = false
        recordImageView.startAnimating()
        delegate?.startRecord()
    }
    
    private func moveOutView() {
        delegate?.moveOutView()
    }
    
    private func moveInView() {
        delegate?.moveInView()
    }
    
    private func endRecord(recognizer: UILongPressGestureRecognizer) {
        stopRecordAnimation()
        let inView = isInRecordView(recognizer: recognizer)
        delegate?.endRecord(insideView: inView)
    }
    
    private func isInRecordView(recognizer: UILongPressGestureRecognizer) -> Bool {
        let point = recognizer.location(in: recognizer.view)
        if point.x < 0 || point.x > recognizer.view?.bounds.size.width ?? 0 || point.y < 0 || point
            .y > recognizer.view?.bounds.size.height ?? 0 {
            return false
        }
        return true
    }
}
