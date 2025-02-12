import UIKit
import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let baseURL = "https://unsplash.com/oauth/token"
    private let storage = OAuth2TokenStorage()
    private init() {}
    
    
    // Коды ошибок

    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        // Объявляю базовый URL, который состоит из схемы и имени
        guard let baseURL = URL(string: "https://unsplash.com") else {
            fatalError("Invalid base URL")
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
    
    
    func fetchAuthToken(code: String, completion: @escaping (Result<String, OAuthError>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(.invalidRequest))
            print("Неверный запрос. Проверьте параметры запроса")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error)))
                    print("Ошибка сети. Повторите попытку позже")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidHTTPResponse))
                    print("Некорректный ответ HTTP. Ответ сервера не распознан")
                }
                return
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidStatusCode(httpResponse.statusCode)))
                    print("Ошибка, недопустиммый код-ответ от сервера")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidData))
                    print("Ответ пустой. Данные отсутствуют")
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                
                self.storage.token = responseBody.accessToken
                
                DispatchQueue.main.async {
                    completion(.success(responseBody.accessToken))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingFailed(error)))
                    print("Ошибка декодирования JSON")
                }
            }
        }
        task.resume()
    }
    
}
