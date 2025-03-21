import UIKit
import Foundation
import ProgressHUD

final class AuthViewController: UIViewController {
    
    
    weak var delegate: AuthViewControllerDelegate?
    private let showWebViewSegueIdentifier = "showWebView"
    private let oauth2Service = OAuth2Service.shared
    
    @IBOutlet weak var entryButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        entryButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        entryButton.accessibilityIdentifier = "Authenticate"
        print("[AuthViewController|viewDidLoad]: Создан экземпляр AuthViewController: \(self)")
        if delegate == nil {
            print("[AuthViewController|viewDidLoad]: delegate в AuthViewController равен nil после возврата из WebView!")
        } else {
            print("[AuthViewController|viewDidLoad]: delegate в AuthViewController НЕ потерялся после WebView!")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("[AuthViewController|viewDidAppear]: Появился AuthViewController: \(self), delegate: \(String(describing: delegate))")
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
}


// MARK: - Реализация делегата WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("[extension AuthViewController|WebViewViewControllerDelegate]: WebView завершает работу, код: \(code)")
        
        UIBlockingProgressHUD.show()
        oauth2Service.fetchAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    print("[extension AuthViewController|WebViewViewControllerDelegate]: Токен получен: \(token)")
                    
                    if let navController = self.navigationController {
                        print("[extension AuthViewController|WebViewViewControllerDelegate]: Используем popViewController")
                        navController.popViewController(animated: true)
                    } else {
                        print("[extension AuthViewController|WebViewViewControllerDelegate]: Используем dismiss")
                        vc.dismiss(animated: true)
                    }
                    
                    if self.delegate == nil {
                        print("[extension AuthViewController| WebViewViewControllerDelegate]: delegate в AuthViewController равен nil!")
                    } else {
                        print("[extension AuthViewController| WebViewViewControllerDelegate]: delegate вызван, переходим дальше")
                        self.delegate?.didAuthenticate(self)
                    }
                    
                case .failure(let error):
                    print("[extension AuthViewController|WebViewViewControllerDelegate]: Ошибка авторизации: \(error.localizedDescription)")
                    self.showAuthErrorAlert()
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        print("[extension AuthViewController|webViewViewControllerDidCancel]: Отмена аутентификации пользователем")
        print("[extension AuthViewController|webViewViewControllerDidCancel]: Закрываем WebView и передаём управление")
        vc.dismiss(animated: true)
        self.delegate?.didAuthenticate(self)
    }
    func showAuthErrorAlert() {
        print("[AuthViewController]: Вызван showAuthErrorAlert()") // ✅ Лог для проверки
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            if let presented = self.presentedViewController {
                print("[AuthViewController]: Закрываем ранее открытый presentedViewController: \(presented)")
                presented.dismiss(animated: false) // Принудительно закрываем перед показом алерта
            }
            
            self.present(alert, animated: true) {
                print("[AuthViewController]: Алерт успешно показан!")
            }
        }
    }
    
}
