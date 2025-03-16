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
        print("[OAuth2Service|fetchAuthToken]: fetchAuthToken вызван с кодом: \(code)")
        assert(Thread.isMainThread)                         // 4
        if task != nil {
            if lastCode != code {
                print("[OAuth2Service|fetchAuthToken]:  Код не совпадает, отменяем задачу")
                task?.cancel()
            } else {
                print("[OAuth2Service|fetchAuthToken]:  Код совпадает, прерываем выполнение")
                completion(.failure(OAuthError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                print("[OAuth2Service|fetchAuthToken]:  Последний код совпадает, прерываем выполнение")
                completion(.failure(OAuthError.invalidRequest))
                return
            }
        }
        lastCode = code                                     // 10
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service|fetchAuthToken]:  Ошибка: makeOAuthTokenRequest вернул nil")
            completion(.failure(OAuthError.invalidRequest))
            return
        }
        print("[OAuth2Service|fetchAuthToken]:  Создан запрос: \(request)")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in guard let self = self else { return }
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(OAuthError.networkError(error)))
                    print("[OAuth2Service|fetchAuthToken]:  Ошибка сети:", error.localizedDescription)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(OAuthError.invalidHTTPResponse))
                    print("[OAuth2Service|fetchAuthToken]:  Ошибка: Некорректный HTTP-ответ")
                }
                return
            }
            
            print("[OAuth2Service|fetchAuthToken]: Код ответа от сервера:", httpResponse.statusCode)
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(OAuthError.invalidStatusCode(httpResponse.statusCode)))
                    print("[OAuth2Service|fetchAuthToken]:  Ошибка: Недопустимый статус-код \(httpResponse.statusCode)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(OAuthError.invalidData))
                    print("[OAuth2Service|fetchAuthToken]:  Ошибка: Данные от сервера отсутствуют")
                }
                return
            }
            
            print("📥 Ответ от сервера:", String(data: data, encoding: .utf8) ?? "Нет данных")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("[OAuth2Service|fetchAuthToken]: jsonString: \(jsonString)")
            } else {
                print("[OAuth2Service|fetchAuthToken]: Error: invalid JSON")
            }
            do {
                let decoder = JSONDecoder()
                print("[OAuth2Service|fetchAuthToken]: Полученные данные JSON:", String(data: data, encoding: .utf8) ?? "Нет данных")
                print("[OAuth2Service|fetchAuthToken]:  JSON перед декодированием:", String(data: data, encoding: .utf8) ?? "Нет данных")
                
                let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                
                print("[OAuth2Service|fetchAuthToken]:  Токен успешно получен:", responseBody.accessToken)
                self.storage.token = responseBody.accessToken
                
                DispatchQueue.main.async {
                    completion(.success(responseBody.accessToken))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(OAuthError.decodingFailed(error)))
                    print("[OAuth2Service|fetchAuthToken]:  Ошибка декодирования JSON:", error.localizedDescription)
                }
                self.task = nil
                self.lastCode = nil
            }
        }
        self.task = task
        self.lastCode = nil
        print("[OAuth2Service|fetchAuthToken]:  Отправка запроса на токен: \(request)")
        print("[OAuth2Service|fetchAuthToken]:  Заголовки запроса: \(request.allHTTPHeaderFields ?? [:])")
        if let body = request.httpBody, let jsonString = String(data: body, encoding: .utf8) {
            print("[OAuth2Service|fetchAuthToken]:  Тело запроса: \(jsonString)")
        }
        
        task.resume()
    }
    // MARK: - Запрос Токена
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
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
            assertionFailure("Failed to construct URL from components")
            return nil
        }
        
        // Создан URLRequest и задание ему метода Post в свойсвте httpMethod
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
}
