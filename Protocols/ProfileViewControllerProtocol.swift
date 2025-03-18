import UIKit


 protocol ProfileViewControllerProtocol: AnyObject {
    var presenterProtocol: ProfileViewPresenterProtocol?  { get set }
    func showLogoutAlert()
}
