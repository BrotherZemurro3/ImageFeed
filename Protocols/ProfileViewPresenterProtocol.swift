import UIKit

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? {get set}
    var profile: Profile? { get }
    var avatarURL: String? { get }
    
    var onProfileUpdate: ((Profile?) -> Void)? { get set }
    var onAvatarUpdate: ((String?) -> Void)? { get set }
    func setupObservers()
    func loadInitialData()
    func updateProfile()
    func updateAvatar()
 

}
