//
//  TGWebViewController.swift
//  YIYIFeedIMSDK
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/12/16.
//

import UIKit
import WebKit


class TGWebViewController: TGViewController {

    /// 网页地址
    var urlString: String = ""
    /// 网页视图
    var webView: WKWebView!
    ///进度条
    public let progressView = UIProgressView(progressViewStyle: .bar)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        isHiddenNavigaBar = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    deinit{
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
    }
    
    func setUI(){
        
        // 设置WKWebView配置，添加消息处理器
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: "goBack")
        configuration.preferences.javaScriptEnabled = true
        
        // 注入 token 的方法
        let script = """
            window.setToken = function() {
                this.HEADERS = '123333'
                return {'token':'\(2222)'}
            }
        """

        let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(userScript)

        
        
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        
        progressView.tintColor = RLColor.main.theme
        self.backBaseView.addSubview(progressView)
        self.backBaseView.addSubview(webView)
        progressView.snp.makeConstraints {
            $0.top.equalTo(TSStatusBarHeight)
            $0.right.left.equalToSuperview()
            $0.height.equalTo(progressView.frame.height)
        }
        webView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.isMultipleTouchEnabled = true
        let str = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        print("urlString = \(str ?? "")")
        if let url = URL(string: str ?? "") {
            var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: TimeInterval(45))
            if let token = RLSDKManager.shared.loginParma?.xToken {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "X-Token")
            }
            let cookies = HTTPCookieStorage.shared.cookies
            let values = HTTPCookie.requestHeaderFields(with: cookies!)
            request.allHTTPHeaderFields = values
            request.httpShouldHandleCookies = true
            webView.load(request)
        }
        if let token = RLSDKManager.shared.loginParma?.xToken {
            let xtoken = "Bearer \(token)"
            // 获取请求头信息并注入到 H5 页面 //"window.headers = {'token': '222'}"
            webView.evaluateJavaScript("window.headers = {'token': '222'}") { message, error in
                print("message injecting headers: \(message)")
                if let error = error {
                    print("Error injecting headers: \(error)")
                }
            }
        }
 
    }
    
    func goBack(){
        if webView.canGoBack {
            webView.goBack()
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let _ = object as? WKWebView else { return }
        guard let keyPath = keyPath else { return }
        if keyPath == "estimatedProgress" {
            switch Float(self.webView.estimatedProgress) {
            case 1.0: // 隐藏进度条
                UIView.animate(withDuration: 0.1, animations: {
                    self.progressView.alpha = 0
                    self.progressView.isHidden = true
                }, completion: nil)
            default:  // 显示进度条
                self.progressView.alpha = 1
            }
            progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
        } else if keyPath == "title" {
            self.title = webView.title
        }
    }

}

extension TGWebViewController:  WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    // MARK: - Delegate
    // MARK: WKNavigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        progressView.progress = 0.2
        progressView.isHidden = false
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 更新网页标题
        if let title = webView.title, title.count > 0 {
            self.title = webView.title
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("webview did fail load with error: \(error)")

        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    // MARK: - WebView UI Delegate
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
       
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
       
    }
    
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // 处理来自H5的消息
        print("Message from H5: \(message)")
        let messageName = message.name
        if messageName == "goBack" {
            goBack()
        }
    }
    
}
