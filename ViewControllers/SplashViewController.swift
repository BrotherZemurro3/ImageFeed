import UIKit
final class SplashViewController: UIViewController {
    
    private let storage = OAuth2TokenStorage()
    private let showAuthenticationScreenSegueIdentifier = "showAuthenticationScreen"
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Vector")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "YP Black")
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuth()
    }
    
    
    // MARK: - Проверка Аутентификации
    private func checkAuth() {
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            guard let authViewController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
                return
            }
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true)
        }
    }
    // MARK: - Навигация
    private func switchTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("[SplashViewController|switchTabBarController]: Ошибка конфигурации")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarController")
        
        window.rootViewController = tabBarController
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
    func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        ProfileService.shared.fetchProfileInfo(token: token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                print("[SplashViewController|fetchProfile]: Профиль загружен: \(profile)")
                
                //  Сохраняем профиль в `ProfileService`
                ProfileService.shared.updateProfile(profile)
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { imageResult in
                    switch imageResult {
                    case .success(let avatarURL):
                        // Обновить ProfileImageService.shared.avatarURL
                        ProfileImageService.shared.updateAvatarURL(avatarURL)
                        print("[SplashViewController|fetchProfile]: Аватарка загружена: \(avatarURL)")
                    case .failure(let error):
                        print("[SplashViewController|fetchProfile]: Ошибка загрузки аватарки: \(error.localizedDescription)")
                    }
                }
                
                self.switchTabBarController()
                
            case .failure(let error):
                print("[SplashViewController|fetchProfile]: Ошибка загрузки профиля: \(error.localizedDescription)")
                showErrorAlert(message: "Не удалось загрузить профиль", token: token)
                
            }
        }
    }
    private func showErrorAlert(message: String, token: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.fetchProfile(token: token)
        }
        alert.addAction(retryAction)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}

