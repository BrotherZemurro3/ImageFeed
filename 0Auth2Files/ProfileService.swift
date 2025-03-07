import Foundation


struct ProfileResult: Codable {
    let username: String
    let name: String?
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    
    enum CodingKeys: String, CodingKey {
        case username
        case name
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(profileResult: ProfileResult) {
        self.username = profileResult.username
        self.name = [profileResult.firstName, profileResult.lastName] .compactMap { $0 }.joined(separator: " ")
        self.loginName = "@\(profileResult.username)"
        self.bio = profileResult.bio
    }
}

enum ProfileNetworkError: Error {
    case requestCancelled
    case urlSessionError
    case urlSessionRequestError
    case missingToken
}

final class ProfileService {
    private var currentTask: URLSessionTask?
    static let shared = ProfileService()
    private init() {}
    private(set) var profile: Profile?
    
    private func createAuthRequest(url: URL, token: String) -> URLRequest? {
        print("[ProfileService|createAuthRequest]: Создаём запрос с токеном: \(token)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
 func fetchProfile(token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        currentTask?.cancel()
        print("[ProfileService|fetchProfile]: Отправка запроса...")
        
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print("[ProfileService|fetchProfile]: Ошибка интернет соединения - не создаётся URL")
            completion(.failure(ProfileNetworkError.urlSessionError))
            return
        }
        
        print("URL successfully created: \(url)")
        guard let request = createAuthRequest(url: url, token: token) else {
            print("[ProfileService|fetchProfile]: Ошибка интернет соединения - не создаётся URLRequest")
            completion(.failure(ProfileNetworkError.requestCancelled))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                print("[ProfileService|fetchProfile]: Данные успешно декодированы: \(profileResult)")
                let profile = Profile(profileResult: profileResult)
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService|fetchProfile]: Ошибка декодирования - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        self.currentTask = task
        task.resume()
    }
}
