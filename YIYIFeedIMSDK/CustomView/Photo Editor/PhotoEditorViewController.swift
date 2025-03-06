//
//  ViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

@objcMembers final public class PhotoEditorViewController: UIViewController {

    /** holding the 2 imageViews original image and drawing & stickers */
    @IBOutlet weak var canvasView: UIView!
    //To hold the image
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    //To hold the drawings and stickers
    @IBOutlet weak var canvasImageView: UIImageView!

    @IBOutlet weak var topToolbar: UIView!
    @IBOutlet weak var bottomToolbar: UIView!

    @IBOutlet weak var topGradient: UIView!
    @IBOutlet weak var bottomGradient: UIView!

    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!

    //Controls
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var stickerButton: UIButton!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet private var rotationButtons: [UIButton]!
    
    @IBOutlet weak var closeButton: UIButton!
    private var safeAreaTop: CGFloat {
        if #available(iOS 11.0, *) {
            return self.view.safeAreaInsets.top
        } else {
            return 0.0
        }
    }
    private var safeAreaBottom: CGFloat {
        if #available(iOS 11.0, *) {
            return self.view.safeAreaInsets.bottom
        } else {
            return 0.0
        }
    }

    private var safeAreaHeight: CGFloat {
        let verticalSafeAreaInset: CGFloat
        if #available(iOS 11.0, *) {
            verticalSafeAreaInset = safeAreaTop + safeAreaBottom
        } else {
            verticalSafeAreaInset = 0.0
        }
        return self.view.frame.height - verticalSafeAreaInset
    }


    public var image: UIImage?
    /**
     Array of Stickers -UIImage- that the user will choose from
     */
    var stickers: [Any] = []
    /**
     Array of Colors that will show while drawing or typing
     */
    var colors  : [UIColor] = []

    weak var photoEditorDelegate: PhotoEditorDelegate?
    var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!

    // list of controls to be hidden
    var hiddenControls : [control] = [.sticker, .crop]

    var stickersVCIsVisible = false
    var drawColor: UIColor = UIColor.black
    var textColor: UIColor = UIColor.white
    var isDrawing: Bool = false
    var lines = [Line]()
    var lastPoint: CGPoint!
    var lineWidth: CGFloat = 0.0
    var swiped = false
    var lastPanPoint: CGPoint?
    var lastTextViewTransform: CGAffineTransform?
    var activeTextView: UITextView?
    var currentActiveLabel: UILabel?
    var imageViewToPan: UIImageView?
    var isTyping: Bool = false
    var isFirstTimeLaunch: Bool = false
    var previousCenter: CGPoint?
    private var isButtonsAnimating = false
    var isCamera: Bool = false
    
    var stickersViewController = StickersViewController()

    var sliderView = SliderView(frame: CGRect(x: 10, y: 0, width: 31, height: 250))
    var slider = UISlider()
    let circularLayer: CAShapeLayer = CAShapeLayer()
    let backgroundView: UIView = {
        let view = UIView()
        view.frame = UIScreen.main.bounds
        view.backgroundColor = .black
        view.layer.opacity = 0.7

        return view
    }()
    let maxTextViewCount = 4
    var currentTextViewCount = 1
    var pinchGestureRecognizer = UIPinchGestureRecognizer()
    var rotationGestureRecognizer = UIRotationGestureRecognizer()
    var panGestureRecognizer = UIPanGestureRecognizer()

    //Register Custom font before we load XIB
    public override func loadView() {
        registerFont()
        super.loadView()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        //        self.setImageView(image: image!)
        imageView.image = image
        
        if isCamera {
            imageView.contentMode = .scaleAspectFit
        } else {
            imageView.contentMode = .scaleAspectFill
        }
        
//        if let image = image {
//            let size = image.suitableSize(widthLimit: UIScreen.main.bounds.width)
//            imageViewHeightConstraint.constant = size?.height ?? 818
//        } else {
//            imageViewHeightConstraint.constant = 818
//        }
        closeButton.setImage(UIImage(named: "ico_search_delete")?.withRenderingMode(.alwaysOriginal), for: .normal)
        saveButton.setImage(UIImage(named: "icEditDownload"), for: .normal)
        shareButton.setImage(UIImage(named: "icShare"), for: .normal)
        clearButton.setImage(UIImage(named: "icClearall"), for: .normal)
        cropButton.setImage(UIImage(named: "icCrop"), for: .normal)
        stickerButton.setImage(UIImage(named: "icSticker"), for: .normal)
        drawButton.setImage(UIImage(named: "icDraw"), for: .normal)
        textButton.setImage(UIImage(named: "icText"), for: .normal)
        continueButton.setImage(UIImage(named: "icRoundedNext"), for: .normal)
        deleteView.layer.cornerRadius = deleteView.bounds.height / 2
        deleteView.layer.borderWidth = 2.0
        deleteView.layer.borderColor = UIColor.white.cgColor
        deleteView.clipsToBounds = true

        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .bottom
        edgePan.delegate = self
        self.view.addGestureRecognizer(edgePan)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        setupSlider()
        isFirstTimeLaunch = true
        configureCollectionView()
        hideControls()
    }

    @objc func sliderValueChanged(_ slider: UISlider, event: UIEvent) {
        lineWidth = CGFloat(slider.value)
        if let touch = event.allTouches?.first {

            let path = UIBezierPath(arcCenter: view.center, radius: lineWidth, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            circularLayer.path = path.cgPath
            circularLayer.fillColor = drawColor.cgColor
            circularLayer.lineCap = .round
            circularLayer.lineWidth = 2.0
            circularLayer.strokeColor = UIColor.white.cgColor
            circularLayer.shadowColor = UIColor.lightGray.cgColor
            circularLayer.shadowPath = path.cgPath
            circularLayer.shadowOffset = CGSize(width: 0, height: 1)
            circularLayer.shadowRadius = 5
            circularLayer.shadowOpacity = 0.7

            switch touch.phase {
                case .began:
                    circularLayer.opacity = 1.0
                    circularLayer.isHidden = false
                case .ended:
                    UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveEaseOut, animations: {
                        self.circularLayer.opacity = 0.0
                    }) { (_) in
                        self.circularLayer.isHidden = true
                }
                default:
                    break
            }
        }
    }

    func calculateDotRadius() {

    }

    @objc private func orientationChanged() {

        guard isButtonsAnimating == false else { return }

        isButtonsAnimating = true

        var angle: Double = 0

        switch UIDevice.current.orientation {
            case .landscapeRight:
                angle = -90 * Double.pi / 180

            case .landscapeLeft:
                angle = 90 * Double.pi / 180

            case .portraitUpsideDown:
                angle = Double.pi / 180

            default: angle = 0
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: {
            self.rotationButtons.forEach({ (button) in
                button.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
            })
        }) { (_) in
            self.isButtonsAnimating = false
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isFirstTimeLaunch == true {
            let trackRect = slider.trackRect(forBounds: slider.bounds)
            let thumbValue = slider.thumbRect(forBounds: slider.bounds, trackRect: trackRect, value: slider.value)
            sliderView.frame.size = CGSize(width: thumbValue.width - 4, height: sliderView.frame.height - thumbValue.height)
            sliderView.center.y = view.center.y
            slider.center.y = sliderView.frame.height / 2
            slider.center.x = (sliderView.frame.maxX - sliderView.frame.minX) / 2
            sliderView.setNeedsDisplay()
            isFirstTimeLaunch = false
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func configureCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        colorsCollectionView.collectionViewLayout = layout
        colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
        colorsCollectionViewDelegate.colorDelegate = self
        if !colors.isEmpty {
            colorsCollectionViewDelegate.colors = colors
        }
        colorsCollectionView.delegate = colorsCollectionViewDelegate
        colorsCollectionView.dataSource = colorsCollectionViewDelegate
        colorsCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "ColorCollectionViewCell")
        
    }

    func setupSlider() {
        sliderView.center.y = view.center.y
        sliderView.backgroundColor = UIColor.clear
        sliderView.isUserInteractionEnabled = true
        sliderView.isHidden = true
        view.addSubview(sliderView)

        slider.frame = CGRect(origin: .zero, size: CGSize(width: sliderView.frame.height, height: 30))
        slider.minimumValue = 3
        slider.maximumValue = 30
        slider.setValue(5, animated: false)
        lineWidth = CGFloat(slider.value)
        slider.thumbTintColor = UIColor.white
        slider.minimumTrackTintColor = UIColor.clear
        slider.maximumTrackTintColor = UIColor.clear
        slider.transform = slider.transform.rotated(by: -.pi / 2)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:event:)), for: .valueChanged)
        sliderView.addSubview(slider)
    }

    func hideToolbar(hide: Bool) {
        topToolbar.isHidden = hide
        topGradient.isHidden = hide
        bottomToolbar.isHidden = hide
        bottomGradient.isHidden = hide
    }

    func hideDrawingControls(hide: Bool) {
        undoButton.isHidden = hide
        doneButton.isHidden = hide
        colorsCollectionView.isHidden = hide
    }
}

extension PhotoEditorViewController: ColorDelegate {
    func didSelectColor(color: UIColor) {
        if isDrawing {
            self.drawColor = color
            circularLayer.fillColor = color.cgColor
        } else if activeTextView != nil {
            activeTextView?.textColor = color
            textColor = color
        }
    }
}

struct Line {
    let color: UIColor
    var points: [CGPoint]
    let width: CGFloat
}





