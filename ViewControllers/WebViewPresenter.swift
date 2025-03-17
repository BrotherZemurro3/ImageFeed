import UIKit




final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        loadAuthView()
    }
    
    
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
        view?.load(request: request)
        
    }

    
}

