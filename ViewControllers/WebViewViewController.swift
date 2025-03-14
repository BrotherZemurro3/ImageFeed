import UIKit
import Foundation
@preconcurrency import WebKit

enum WebViewConstants {
    static let unsplashAuthorizedURLString = "https://unsplash.com/oauth/authorize"
    
}

final class WebViewViewController: UIViewController {
    @IBOutlet  var webView: WKWebView!
    @IBOutlet  var progressView: UIProgressView!
    @IBOutlet weak var backButton: UIButton!
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.updateProgress()
             })
        loadAuthView()
    }
    
    // MARK: - Actions
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MAR: - Private Methods
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizedURLString) else {
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
            
        ]
        
        guard let url = urlComponents.url else {
            return
        }
        print("[WebViewController|loadAuthView]: Запрашиваем авторизацию по URL: \(url.absoluteString)")
        let request = URLRequest(url: url)
        webView.load(request)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
        updateProgress()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
        }
    }
    private func updateProgress() {
        progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

// MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            print("[extension WebViewViewController|WKNavigationDelegate]:Код авторизации получен: \(code)")
            
            if delegate == nil {
                print("[extension WebViewViewController|WKNavigationDelegate]: delegate равен nil!")
            } else {
                print("[extension WebViewViewController|WKNavigationDelegate]: delegate установлен")
            }
            
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    // MARK: - Извлечение кода авторищации из URL-адреса перенаправления
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            print("[extension WebViewViewController|code(from navigationAction: WKNavigationAction)]: Перенаправление на URL: \(url.absoluteString)")
        }
        
        if
            let url = navigationAction.request.url,
            
                let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            print("[extension WebViewViewController|code(from navigationAction: WKNavigationAction)]: Перенаправление на URL: \(url.absoluteString)")
            print("[code(from navigationAction: WKNavigationAction)]: Код авторизации найден: \(codeItem.value ?? "nil")")
            return codeItem.value
        } else {
            print("[extension WebViewViewController|code(from navigationAction: WKNavigationAction)]: Код авторизации не найден")
            return nil
        }
    }
}
