import UIKit
import Foundation

// Протокол делегата
protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    private let showWebViewSegueIdentifier = "showWebView"
    private let oauth2Service = OAuth2Service.shared
    
    // Свойство делегата
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
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
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
}

// Реализация делегата WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        // Вызываем fetchOAuthToken для получения токена
        print("Отправляем запрос на получение токена с кодом: \(code)")
        oauth2Service.fetchAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    print("Токен получен: \(token)")
                    vc.dismiss(animated: true) {
                        self.delegate?.didAuthenticate(self)
                        if self.delegate == nil {
                            print("⚠️ delegate в AuthViewController равен nil!")
                        } else {
                            print("✅ delegate вызван, переходим дальше")
                            self.delegate?.didAuthenticate(self)
                        }
                    }
                case .failure(let error):
                    print("Ошибка авторизации: \(error.localizedDescription)")
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
    
    // Метод для показа ошибки авторизации
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
