import UIKit
import Foundation
import WebKit


final class WebViewViewController: UIViewController {
    override func viewDidLoad() {
        loadAuthView()
 
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
    }
    
    @IBOutlet private var WKWebView: WKWebView!

    enum WebViewConstants {
        static let unsplashAuthorizedURLString = "https://unsplash.com/oauth/authorize"
        
    }
    
    }
    

