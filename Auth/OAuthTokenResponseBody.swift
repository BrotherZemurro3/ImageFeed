import UIKit
import Foundation

// Структура для декодинга JSON-ответа
struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "acess_token"
    }
    
}

