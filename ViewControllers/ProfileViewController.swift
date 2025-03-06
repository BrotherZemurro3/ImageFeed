import UIKit
import Foundation
import Kingfisher




final class ProfileViewController: UIViewController {
    
    private let nameLabel = UILabel()
    private let loginLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let profileService = ProfileService.shared
    private let profileImage = UIImageView()
    private var profileimageSeviceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = UIColor(named: "YP Black")
            
            // Настройка observer для обновления аватарки
            profileimageSeviceObserver = NotificationCenter.default
                .addObserver(
                    forName: ProfileImageService.didChangeNotification,
                    object: nil,
                    queue: .main
                ) { [weak self] _ in
                    guard let self = self else { return }
                    self.updateAvatar()
                }
        
        print("🚀 Вызываем updateAvatar()")
        updateAvatar()
        setupUI()
        
        
            
          
           
            // Загрузка данных профиля
            if let profile = profileService.profile {
                updateProfileDetails(profile: profile)
            } else {
                print("Ошибка: профиль не загружен")
            }
        }

        private func setupUI() {
            // Настройка profileImage
            profileImage.tintColor = .gray
            profileImage.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(profileImage)
            NSLayoutConstraint.activate([
                profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
                profileImage.widthAnchor.constraint(equalToConstant: 70),
                profileImage.heightAnchor.constraint(equalToConstant: 70),
            ])
            
            // Настройка logoutButton
            let logoutButton = UIButton(type: .system)
            logoutButton.setImage(UIImage(named: "logoutButton"), for: .normal)
            logoutButton.tintColor = .ypRed
            logoutButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(logoutButton)
            NSLayoutConstraint.activate([
                logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                logoutButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            ])
            
            // Настройка nameLabel
            nameLabel.textColor = .white
            nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(nameLabel)
            NSLayoutConstraint.activate([
                nameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
                nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            ])
            
            // Настройка loginLabel
            loginLabel.textColor = .lightGray
            loginLabel.font = .systemFont(ofSize: 13, weight: .regular)
            loginLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(loginLabel)
            NSLayoutConstraint.activate([
                loginLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
                loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            ])
            
            // Настройка descriptionLabel
            descriptionLabel.textColor = .white
            descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(descriptionLabel)
            NSLayoutConstraint.activate([
                descriptionLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
                descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            ])
        }

    func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL else {
            print("Ошибка: avatarURL отсутствует")  // Проверка, что URL есть
            return
        }
        print("avatarURL: \(profileImageURL)")  // Лог для проверки, что URL правильный
        
        guard let url = URL(string: profileImageURL) else {
            print("Ошибка: avatarURL не может быть преобразован в URL: \(profileImageURL)")  // Логирование URL
            return
        }
        
        // Загрузка изображения с использованием Kingfisher
        profileImage.kf.setImage(with: url,
                                 placeholder: UIImage(named: "UserPhoto"),
                                 options: [.transition(.fade(3))],
                                 completionHandler: { result in
            switch result {
            case .success(let value):
                print("Аватарка успешно загружена: \(value.source.url?.absoluteString ?? "Unknown URL")")
            case .failure(let error):
                print("Ошибка загрузки аватарки: \(error.localizedDescription)")  // Логирование ошибки загрузки
            }
        })
    }

    func updateProfileDetails(profile: Profile) {
        print("[ProfileViewController]: Обновляем профиль - \(profile)")  // Логирование профиля
        nameLabel.text = profile.name.isEmpty ? "No Name" : profile.name
        loginLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? "No Bio"
    }
    }
