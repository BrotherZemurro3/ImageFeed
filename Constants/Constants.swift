import UIKit
import Foundation

enum Constants {
    static let accessKey: String = "5jSHnKb1CCymEW5vBTVBRoT5tR9FGSJm9Lnt2f_NoyA"
    static let secretKey: String = "qeklrUSXczsSE_yUI4ILeT1HpRxM3OQ7T-zEJI3fGRo"
    static let redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Invalid URL")
        }
        return url
    }()
}
