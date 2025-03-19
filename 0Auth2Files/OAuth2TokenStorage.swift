import Foundation
import SwiftKeychainWrapper

// MARK: - Сохранение токена (Bearer Token) в User Defaults 
final class OAuth2TokenStorage {
    
    private let key = "AuthToken"
    private let userDefaults = UserDefaults.standard
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: key)
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: key)
            } else {
                KeychainWrapper.standard.removeObject(forKey: key)
            }
        }
    }
    
}

