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
        if storage.token != nil {
            switchTabBarController()
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
            assertionFailure("[SplashViewController]: Ошибка конфигурации")
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
        profileService.fetchProfileInfo(token: token) { [weak self] (result: Result<Profile, Error>) in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                print("[SplashViewController]: Профиль загружен: \(profile)")
                
                // Сохраняем профиль в сервис
                self.profileService.updateProfile(profile)
                // Оповещаем подписчиков, что профиль обновился
                NotificationCenter.default.post(name: ProfileService.didChangeNotification, object: nil)
                
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { imageResult in
                    switch imageResult {
                    case .success(let avatarURL):
                        print("[SplashViewController]: Аватарка успешно загружена: \(avatarURL)")
                        
                        // Оповещаем о загрузке аватарки
                        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: nil)
                        
                    case .failure(let error):
                        print("[SplashViewController]: Ошибка загрузки аватарки: \(error.localizedDescription)")
                    }
                }
                
                // Вызов switchTabBarController в любом случае
                self.switchTabBarController()
            case .failure(let fetchError):
                  print("[SplashViewController]: Не удалось получить профиль: \(fetchError.localizedDescription)")
              }
            }
        }
        
    }

