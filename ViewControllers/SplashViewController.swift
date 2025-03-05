import UIKit
final class SplashViewController: UIViewController {
   
    private let storage = OAuth2TokenStorage()
    private let showAuthenticationScreenSegueIdentifier = "showAuthenticationScreen"
    private let profileService = ProfileService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuth()
        
    }
    // MARK: - Проверка Аутентификации
    private func checkAuth() {
        if storage.token != nil {
            switchTabBarController()
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    // MARK: - Навигация
    private func switchTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Ошибка конфигурации")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
  
    }

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard let navigationController = segue.destination as? UINavigationController,
                  let authViewController = navigationController.viewControllers.first as? AuthViewController else {
                assertionFailure("❌ Ошибка: не удалось перейти на AuthViewController")
                return
            }
            authViewController.delegate = self
            print("✅ Установили delegate в SplashViewController: \(self)")
            print("✅ Делегат AuthViewController: \(String(describing: authViewController.delegate))")
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            self?.switchTabBarController()
            
            guard let token = self?.storage.token else {
                return
            }
            self?.fetchProfile(token:token)
        }
    }
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        ProfileService.shared.fetchProfile(token: token) { [weak self] (result: Result <Profile, Error>) in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { imageResult in
                    switch imageResult {
                    case .success(let avatarURL):
                        print("Аватарка успешно загружена: \(avatarURL)")
                    case .failure(let error):
                        print("Ошибка загрузки аватарки: \(error.localizedDescription)")
                    }
                }
                self.switchTabBarController()
                
            case .failure(let fetchError):
                print("Не удалось получить данные профиля: \(fetchError.localizedDescription)")
            }
        }
    }

}
