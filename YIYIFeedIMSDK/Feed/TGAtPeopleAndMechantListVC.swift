//
//  TGAtPeopleAndMechantListVC.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/13.
//

import UIKit

enum UserInfoModelType {
    case people
    case merchant
}
class TGAtPeopleAndMechantListVC: TGViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var selectedBlock: ((Any?, String, String, UserInfoModelType) -> Void)?
    let topView = UIView().configure {
        $0.backgroundColor = .white
    }
    let peopleBtn = UIButton().configure {
        $0.setTitle("text_member".localized, for: .normal)
        $0.titleLabel?.font = UIFont.systemRegularFont(ofSize: 15)
        $0.setTitleColor(UIColor(red: 128, green: 128, blue: 128), for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.isSelected = true
        $0.titleLabel?.textAlignment = .right
    }
    let mechantBtn = UIButton().configure {
        $0.setTitle("merchant".localized, for: .normal)
        $0.titleLabel?.font = UIFont.systemRegularFont(ofSize: 15)
        $0.setTitleColor(UIColor(red: 128, green: 128, blue: 128), for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.titleLabel?.textAlignment = .left
    }
    
    let line = UIView()
    
    var peopleVC: TGAtpeopleListVC!
    var mechantVC: TGAtMechantListVC!
    private var contentControllers: [UIViewController] = []
    private let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [.interPageSpacing : 0])
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCloseButton(backImage: true, titleStr: "tag_title_ppl_merchant".localized, completion: {
            if let currentVC = (self.pageController.viewControllers ?? []).first, let index = self.contentControllers.firstIndex(of: currentVC) {
                self.selectedBlock?(nil, "", "", index == 0 ? .people : .merchant)
                return
            }
            
            self.selectedBlock?(nil, "", "", .people)
        })
        self.customNavigationBar.backItem.setTitle("tag_title_ppl_merchant".localized, for: .normal)
        view.backgroundColor = .white
        setUI()
    }
    

    func setUI(){
        setTopView()
        peopleVC = TGAtpeopleListVC()
        mechantVC = TGAtMechantListVC()

        contentControllers.append(peopleVC)
        contentControllers.append(mechantVC)
        pageController.dataSource = self
        pageController.delegate = self
        addChild(pageController)
        self.backBaseView.addSubview(pageController.view)
        pageController.view.frame = self.view.frame
        pageController.didMove(toParent: self)
        pageController.setViewControllers([contentControllers.first!], direction: .forward, animated: true)
        
        pageController.view.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.topView.snp.bottom)
        }
        
        peopleVC.selectedBlock = {[weak self] model in
            self?.selectedBlock?(model, "", "", .people)
            self?.navigationController?.popViewController(animated: true)
        }
        
        mechantVC.selectedBlock = {[weak self] model, appId, dealPath in
            self?.selectedBlock?(model, appId, dealPath, .merchant)
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func setTopView(){
        let line1 = UIView()
        line1.backgroundColor = UIColor(red: 237, green: 237, blue: 237)
        self.backBaseView.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(38)
        }
        topView.addSubview(peopleBtn)
        topView.addSubview(mechantBtn)
//        topView.addSubview(line1)
        topView.addSubview(line)
        
        line.backgroundColor = RLColor.main.red
        peopleBtn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(40)
            make.width.equalTo(ScreenWidth/2)
        }
        mechantBtn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-40)
            make.width.equalTo(ScreenWidth/2)
        }
        line.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(3)
            make.width.equalTo(ScreenWidth/2 - 120)
            make.left.equalTo(100)
        }
//        line1.snp.makeConstraints { make in
//            make.bottom.equalToSuperview()
//            make.height.equalTo(1)
//            make.left.equalTo(50)
//            make.right.equalTo(-50)
//        }
        peopleBtn.addTarget(self, action: #selector(peopleClick), for: .touchUpInside)
        mechantBtn.addTarget(self, action: #selector(mechantClick), for: .touchUpInside)
    }
   
    @objc func peopleClick(){
        peopleBtn.isSelected = true
        mechantBtn.isSelected = false
        setLineFrame(index: 0)
        self.pageController.setViewControllers([self.contentControllers.first!], direction: .reverse, animated: true, completion: nil)
    }
    @objc func mechantClick(){
        peopleBtn.isSelected = false
        mechantBtn.isSelected = true
        setLineFrame(index: 1)
        self.pageController.setViewControllers([self.contentControllers.last!], direction: .forward, animated: true, completion: nil)
    }
    
    func setLineFrame(index: Int){
        UIView.animate(withDuration: 0.2) {
            var frame = self.line.frame
            frame.origin.x = 100 + CGFloat(index) * (ScreenWidth / 2 - 80)
            self.line.frame = frame
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = pageViewController.viewControllers?.first else { return nil }
        guard let index = contentControllers.firstIndex(of: currentVC) else { return nil }
        guard index > 0 else { return nil }
        return contentControllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = pageViewController.viewControllers?.first else { return nil }
        guard let index = contentControllers.firstIndex(of: currentVC) else { return nil }
        guard index < contentControllers.count - 1 else { return nil }
        return contentControllers[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentVC = pageViewController.viewControllers?.first else { return  }
        
        guard let index = contentControllers.firstIndex(of: currentVC) else { return }
        if index == 0 {
            peopleBtn.isSelected = true
            mechantBtn.isSelected = false
            setLineFrame(index: 0)
        } else {
            peopleBtn.isSelected = false
            mechantBtn.isSelected = true
            setLineFrame(index: 1)
        }
    }

}
