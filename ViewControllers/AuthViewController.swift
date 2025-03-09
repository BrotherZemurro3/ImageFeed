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
            print("[AuthViewController|prepare]: Переход на WebViewViewController")
            
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                assertionFailure("[AuthViewController|prepare]: Ошибка: не удалось привести segue.destination к WebViewViewController")
                return
            }
            
            webViewViewController.delegate = self
            
            if webViewViewController.delegate == nil {
                print("[AuthViewController|prepare]: delegate не установлен в prepare(for:sender:)!")
            } else {
                print("[AuthViewController|prepare]: delegate успешно установлен в prepare(for:sender:)")
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    private func showAuthErrorAlert() {
          let alert = UIAlertController(
              title: "Что-то пошло не так(",
              message: "Не удалось войти в систему",
              preferredStyle: .alert
          )
          alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
          present(alert, animated: true, completion: nil)
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
    
}
