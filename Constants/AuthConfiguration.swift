import UIKit
import Foundation

enum Constants {
    static let accessKey: String = "5jSHnKb1CCymEW5vBTVBRoT5tR9FGSJm9Lnt2f_NoyA"
    static let secretKey: String = "qeklrUSXczsSE_yUI4ILeT1HpRxM3OQ7T-zEJI3fGRo"
    static let redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Invalid URL")
        }
        return url
    }()
}
    struct AuthConfiguration {
        let accessKey: String
        let secretKey: String
        let redirectURI: String
        let accessScope: String
        let defaultBaseURL: URL
        let authURLString: String

        init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
            self.accessKey = accessKey
            self.secretKey = secretKey
            self.redirectURI = redirectURI
            self.accessScope = accessScope
            self.defaultBaseURL = defaultBaseURL
            self.authURLString = authURLString
        }

        static var standard: AuthConfiguration {
            return AuthConfiguration(accessKey: Constants.accessKey,
                                     secretKey: Constants.secretKey,
                                     redirectURI: Constants.redirectURI,
                                     accessScope: Constants.accessScope,
                                     authURLString: Constants.unsplashAuthorizeURLString,
                                     defaultBaseURL: Constants.defaultBaseURL)
        }
    }
}

