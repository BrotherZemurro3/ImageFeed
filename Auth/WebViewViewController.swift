import UIKit
import Foundation
import WebKit


final class WebViewViewController: UIViewController {
    
    
    @IBOutlet  var WKWebView: WKWebView!
    
    @IBOutlet  var progressView: UIProgressView!
    
    weak var delegate: WebViewViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAuthView()
        WKWebView.navigationDelegate = self
        updateProgress()
        
        
    }
    enum WebViewConstants {
        static let unsplashAuthorizedURLString = "https://unsplash.com/oauth/authorize"
        
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizedURLString) else {
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_url", value: Constants.redirectURL),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        guard let url = urlComponents.url else {
            return
        }
        let request = URLRequest(url: url)
        WKWebView.load(request)
        updateProgress()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        WKWebView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
        updateProgress()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        WKWebView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            
        }
    }

    private func updateProgress() {
        progressView.progress = Float(WKWebView.estimatedProgress)
        progressView.isHidden = fabs(WKWebView.estimatedProgress - 1.0) <= 0.0001
    }
    
 
}


extension WebViewViewController: WKNavigationDelegate {
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) { //1
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)                //2
            decisionHandler(.cancel)
            
        } else {
            decisionHandler(.allow) //4
        }
    }
   
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,                         
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
}
