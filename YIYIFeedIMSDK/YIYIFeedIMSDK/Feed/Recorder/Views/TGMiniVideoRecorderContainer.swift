//
//  TGMiniVideoRecorderContainer.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/2.
//

import UIKit

class TGMiniVideoRecorderContainer: TGBaseRecorderContainer {

    override init() {
        super.init()
        
        container.addSubview(progressBar)
        container.addSubview(recordButton)
        container.addSubview(editStackView)
        container.addSubview(speedSegmentControl)
        container.addSubview(videoDurationLabel)
        
        progressBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.leading.equalToSuperview().offset(7)
            $0.trailing.equalToSuperview().offset(-7)
            $0.height.equalTo(5)
        }
        
        stackview.snp.makeConstraints {
            $0.top.equalTo(progressBar.snp.bottom).offset(14)
            $0.trailing.equalToSuperview()
        }
        
        editStackView.snp.makeConstraints {
            $0.leading.equalTo(recordButton.snp.trailing).offset(15)
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(recordButton)
        }
        
        speedSegmentControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(25)
            $0.bottom.equalTo(recordButton.snp.top).offset(-25)
        }
        
        videoDurationLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(progressBar.snp.bottom).offset(23)
        }
        
        stackview.addArrangedSubview(flipButton)
        stackview.addArrangedSubview(durationButton)
        stackview.addArrangedSubview(timerButton)
        stackview.addArrangedSubview(flashButton)
        
        stackview.arrangedSubviews.forEach { (view) in
            view.snp.makeConstraints {
                $0.height.equalTo(50)
            }
        }
        
        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.top.equalTo(progressBar.snp.bottom).offset(14)
            $0.width.height.equalTo(40)
        }
        
        recordButton.snp.makeConstraints {
            $0.width.height.equalTo(73)
            $0.centerX.equalToSuperview()
            
            if RLUserInterfacePrinciples.share.hasNotch() {
                $0.bottom.equalToSuperview().offset(-30)
            } else {
                $0.bottom.equalToSuperview().offset(-60)
            }
        }

        albumButton.snp.makeConstraints {
            $0.leading.equalTo(recordButton.snp.trailing).offset(30)
            $0.centerY.equalTo(recordButton)
            $0.width.height.equalTo(60)
        }
        
        setupRecorder()
       
    }
    
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deinit Minivideo recorder container!!!")
    }
    // MARK: -
    
    lazy var recordButton: TGVideoRecordButton = {
        let button = TGVideoRecordButton(frame: CGRect(origin: .zero, size: CGSize(width: 73, height: 73)))
        button.delegate = self
        return button
    }()

    
    override func setupRecorder() {
        super.setupRecorder()
    }
    
}

extension TGMiniVideoRecorderContainer {
    
    public func enterRecordingState() {
        stackview.makeHidden()
        albumButton.makeHidden()
        videoDurationLabel.makeVisible()
        
        if !speedSegmentControl.isHidden {
            speedSegmentControl.makeHidden()
        }
    }
    
    public func exitRecordingState() {
        stackview.makeVisible()
        videoDurationLabel.makeHidden()
        checkProgressState()
        speedSegmentControl.isHidden = !speedButton.isSelected
    }
    
    private func checkProgressState() {
        albumButton.isHidden = progressBar.hasProgress
        editStackView.isHidden = !albumButton.isHidden
        durationButton.isHidden = progressBar.hasProgress
    }

    
    func resetProgress() {
        progressBar.reset()
        checkProgressState()
    }
    
    func deleteLastProgress() {
        progressBar.popMark()
        checkProgressState()
    }
}

extension TGMiniVideoRecorderContainer: TGRecordButtonDelegate {
    
    func buttonDidLongPressed(state: UIGestureRecognizer.State) {

    }
    // MARK: - 按录制按钮
    func buttonDidTapped() {
        self.delegate?.recorderButtonDidTapped()
    }
    
}
