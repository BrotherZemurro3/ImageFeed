import UIKit
import Foundation

final class OAuth2Service {
    
    // MARK: - Синглтон
    static let shared = OAuth2Service()
    private let baseURL = "https://unsplash.com/oauth/token"
    private let storage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?

    private init() {}
    
    
        
        // MARK: - Запрос Токена
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        // Объявляю базовый URL, который состоит из схемы и имени
        guard let baseURL = URL(string: "https://unsplash.com") else {
            assertionFailure("Invalid base URL")
            return nil
        }
        
        // Полученние конечного URL , собранного из базового URL, пути и параметров запроса (констант)
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.path = "/oauth/token"
        
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        // Получение URL с обращением к свойству url у собранного объекта URLComponents
        guard let url = components.url else {
            fatalError("Failed to construct URL from components")
        }
        
        // Создан URLRequest и задание ему метода Post в свойсвте httpMethod
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    enum OAuthError: Error {
        case invalidRequest
        case networkError(Error)
        case invalidHTTPResponse
        case invalidStatusCode(Int)
        case invalidData
        case decodingFailed(Error)
        
    }
    
        // MARK: - Извлечение токена
    func fetchAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
          assert(Thread.isMainThread)                         // 4
          if task != nil {                                    // 5
              if lastCode != code {                           // 6
                  task?.cancel()                              // 7
              } else {
                  completion(.failure(OAuthError.invalidRequest))
                  return                                      // 8
              }
          } else {
              if lastCode == code {                           // 9
                  completion(.failure(OAuthError.invalidRequest))
                  return
              }
          }
          lastCode = code                                     // 10
          guard
              let request = makeOAuthTokenRequest(code: code)           // 11
          else {
              completion(.failure(OAuthError.invalidRequest))
              return
          }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in guard let self = self else { return }
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(OAuthError.networkError(error)))
                    print("❌ Ошибка сети:", error.localizedDescription)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(OAuthError.invalidHTTPResponse))
                    print("❌ Ошибка: Некорректный HTTP-ответ")
                }
                return
            }
            
            print("📥 Код ответа от сервера:", httpResponse.statusCode)
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(OAuthError.invalidStatusCode(httpResponse.statusCode)))
                    print("❌ Ошибка: Недопустимый статус-код \(httpResponse.statusCode)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(OAuthError.invalidData))
                    print("❌ Ошибка: Данные от сервера отсутствуют")
                }
                return
            }
            
            print("📥 Ответ от сервера:", String(data: data, encoding: .utf8) ?? "Нет данных")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("jsonString: \(jsonString)")
            } else {
                print("Error: invalid JSON")
            }
            do {
                let decoder = JSONDecoder()
                print("Полученные данные JSON:", String(data: data, encoding: .utf8) ?? "Нет данных")
                print("📥 JSON перед декодированием:", String(data: data, encoding: .utf8) ?? "Нет данных")
                
                let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                
                print("✅ Токен успешно получен:", responseBody.accessToken)
                self.storage.token = responseBody.accessToken
                
                DispatchQueue.main.async {
                    completion(.success(responseBody.accessToken))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(OAuthError.decodingFailed(error)))
                    print("❌ Ошибка декодирования JSON:", error.localizedDescription)
                }
                self.task = nil
                self.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
    
}
