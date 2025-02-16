import UIKit
import Foundation

final class AuthViewController: UIViewController {
    
 
    weak var delegate: AuthViewControllerDelegate?
    private let showWebViewSegueIdentifier = "showWebView"
    private let oauth2Service = OAuth2Service.shared
    
    @IBOutlet weak var entryButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        entryButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        
        print("🟢 Создан экземпляр AuthViewController: \(self)")
        if delegate == nil {
            print("⚠️ delegate в AuthViewController равен nil после возврата из WebView!")
        } else {
            print("✅ delegate в AuthViewController НЕ потерялся после WebView!")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("✅ Появился AuthViewController: \(self), delegate: \(String(describing: delegate))")
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            print("✅ Переход на WebViewViewController")
            
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                assertionFailure("❌ Ошибка: не удалось привести segue.destination к WebViewViewController")
                return
            }
            
            webViewViewController.delegate = self
            
            if webViewViewController.delegate == nil {
                print("⚠️ delegate не установлен в prepare(for:sender:)!")
            } else {
                print("✅ delegate успешно установлен в prepare(for:sender:)")
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
}

// MARK: - Реализация делегата WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("🟡 WebView завершает работу, код: \(code)")
        
        oauth2Service.fetchAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    print("✅ Токен получен: \(token)")
                    
                    if let navController = self.navigationController {
                        print("🔄 Используем popViewController")
                        navController.popViewController(animated: true)
                    } else {
                        print("🔄 Используем dismiss")
                        vc.dismiss(animated: true)
                    }
                    
                    if self.delegate == nil {
                        print("⚠️ delegate в AuthViewController равен nil!")
                    } else {
                        print("✅ delegate вызван, переходим дальше")
                        self.delegate?.didAuthenticate(self)
                    }
                    
                case .failure(let error):
                    print("❌ Ошибка авторизации: \(error.localizedDescription)")
                    self.showAuthErrorAlert()
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        print("Отмена аутентификации пользователем")
        print("Закрываем WebView и передаём управление")
        vc.dismiss(animated: true)
        self.delegate?.didAuthenticate(self)
    }
    
    
    
    // MARK: - Метод для показа ошибки авторизации
    private func showAuthErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка авторизации",
            message: "Не удалось выполнить вход. Попробуйте ещё раз.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
