import Foundation


struct UserResult: Codable {
// MARK: - Модель данных пользователя
    struct ProfileImages: Codable {
        let small: String
    }
    let profileImage: ProfileImages
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

final class ProfileImageService {
    static var shared = ProfileImageService()
    private init() {}
    private(set) var avatarURL: String? {
        didSet {
            print("[ProfileImageService]: avatarURL обновлён -> \(String(describing: avatarURL))")
            NotificationCenter.default.post(
                name: ProfileImageService.didChangeNotification,
                object: self
            )
        }
    }
    private var currentTask: URLSessionTask?
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    func updateAvatarURL(_ avatarURL: String) {
        self.avatarURL = avatarURL
        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: nil)
    }
    // MARK: - Загрузка URL изображения профиля
     func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        currentTask?.cancel()
        print("[ProfileImageService|fetchProfile]: Отправка запроса для картинки")
        
        guard let token = OAuth2TokenStorage().token else {
            print("[ProfileImageService|fetchProfileImageURL]: Токен не получен")
            completion(.failure(ProfileNetworkError.missingToken))
            return
        }
        
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("[ProfileImageService|fetchProfileImageURL]: Невозможно создать URL")
            completion(.failure(ProfileNetworkError.urlSessionError))
            return
        }
        
        print("[ProfileImageService|fetchProfileImageURL]: URL успешно создан: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                print("[ProfileImageService|fetchProfileImageURL]: Успешный ответ: \(userResult)")
                let avatarURL = userResult.profileImage.small
                self?.avatarURL = avatarURL  // Обновление avatarURL
                DispatchQueue.main.async {
                    completion(.success(avatarURL))
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL]
                    )
                }
            case .failure(let error):
                print("[ProfileImageService|fetchProfileImageURL]: Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        self.currentTask = task
        task.resume()
    }
}
