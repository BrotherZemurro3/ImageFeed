import Foundation
import UIKit

struct UserResult: Codable {
    struct ProfileImages: Codable {
        let small: String
    }
    let profileImage: ProfileImages
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    
    private(set) var avatarURL: String?
    private var currentTask: URLSessionTask?
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        currentTask?.cancel()
        print("[fetchProfile]: Отправка запроса для картинки")
        
        guard let token = OAuth2TokenStorage().token else {
            print("[fetchProfileImageURL]: Токен не получен")
            completion(.failure(ProfileNetworkError.missingToken))
            return
        }
        
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("[fetchProfileImageURL]: Невозможно создать URL")
            completion(.failure(ProfileNetworkError.urlSessionError))
            return
        }
        
        print("URL успешно создан: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let userResult = try JSONDecoder().decode(UserResult.self, from: data)
                    let avatarURL = userResult.profileImage.small
                    self?.avatarURL = avatarURL
                    
                    DispatchQueue.main.async {
                        completion(.success(avatarURL))
                        NotificationCenter.default.post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": avatarURL]
                        )
                    }
                } catch {
                    print("[fetchProfileImageURL]: Ошибка декодирования - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            
            case .failure(let error):
                print("[fetchProfileImageURL]: NetworkError - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        self.currentTask = task
        task.resume()
    }
}
