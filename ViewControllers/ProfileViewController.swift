import UIKit
import Foundation
import Kingfisher




final class ProfileViewController: UIViewController {
    // MARK: - UI Elements
    private let nameLabel = UILabel()
    private let loginLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let profileService = ProfileService.shared
    private let profileImage = UIImageView()
    private var profile: Profile?
    private var profileObserver: NSObjectProtocol?
    private var profileImageObserver: NSObjectProtocol?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[ProfileViewController]: Загружен")

        view.backgroundColor = UIColor(named: "YP Black")
        profileImage.clipsToBounds = true

        setupUI()
        updateAvatar()
        updateProfile()

        profileObserver = NotificationCenter.default.addObserver(
            forName: ProfileService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("[ProfileViewController]: Получено обновление профиля")
            self?.updateProfile()
        }

        profileImageObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("[ProfileViewController]: Получено обновление аватарки")
            self?.updateAvatar()
        }
        
    }
    // MARK: - UI Setup
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
    // MARK: - Avatar Update
    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL else {
            print("[ProfileViewController|updateAvatar]: Ошибка: avatarURL отсутствует")  // Проверка, что URL есть
            return
        }
        print("avatarURL: \(profileImageURL)")  // Лог для проверки, что URL правильный
        
        guard let url = URL(string: profileImageURL) else {
            print("ProfileViewController|updateAvatar]: Ошибка: avatarURL не может быть преобразован в URL: \(profileImageURL)")  // Логирование URL
            return
        }
        let processor = RoundCornerImageProcessor(cornerRadius: 50, backgroundColor: .ypBlack)
        // Загрузка изображения с использованием Kingfisher
        profileImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "UserPhoto"),
            options: [
                .processor(processor),
                .transition(.fade(3))
            ]
        )
    }

    // MARK: - Update Profile Details
    private func updateProfile() {
        guard let profile = ProfileService.shared.profile else {
            print("[ProfileViewController|updateProfile]: Профиль отсутствует")
            return
        }
        print("[ProfileViewController|updateProfile]: Обновляем профиль - \(profile)")

        nameLabel.text = profile.name.isEmpty ? "No Name" : profile.name
        loginLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? "No Bio"
    }
    
    func configure(with profile: Profile, avatarURL: String) {
        self.profile = profile
        self.updateProfile()
        self.profileImage.kf.setImage(with: URL(string: avatarURL))
    }
}
