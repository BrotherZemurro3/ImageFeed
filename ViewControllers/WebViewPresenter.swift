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
        print("[WebViewPresenter|loadAuthView]: Запрашиваем авторизацию по URL: \(url.absoluteString)")
        let request = URLRequest(url: url)
        didUpdateProgressValue(0)
        view?.load(request: request)
        
    }

    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
     func code(from url: URL) -> String? {
          if let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            print("[WebViewPresenter|code(from url: URL): WKNavigationAction)]: Перенаправление на URL: \(url.absoluteString)")
            print("[WebViewPresenter|code(from url: URL): WKNavigationAction)]: Код авторизации найден: \(codeItem.value ?? "nil")")
            return codeItem.value
        } else {
            print("[WebViewPresenter|code(from url: URL): Код авторизации не найден")
            return nil
        }
    }
    
}

