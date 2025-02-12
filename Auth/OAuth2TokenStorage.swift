import UIKit
import Foundation

// Сохранение токена (Bearer Token) в User Defaults 
final class OAuth2TokenStorage {
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "AuthToken")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "AuthToken")
        }
    }
    
}
