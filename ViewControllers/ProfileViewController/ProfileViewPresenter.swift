import UIKit


final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    
    var profile: Profile? {
         didSet {
             onProfileUpdate?(profile)
         }
     }
     
     var avatarURL: String? {
         didSet {
             onAvatarUpdate?(avatarURL)
         }
     }

     var onProfileUpdate: ((Profile?) -> Void)?
     var onAvatarUpdate: ((String?) -> Void)?
     
     private var profileObserver: NSObjectProtocol?
     private var profileImageObserver: NSObjectProtocol?

    
    func setupObservers() {
           profileObserver = NotificationCenter.default.addObserver(
               forName: ProfileService.didChangeNotification,
               object: nil,
               queue: .main
           ) { [weak self] _ in
               self?.profile = ProfileService.shared.profile
           }

           profileImageObserver = NotificationCenter.default.addObserver(
               forName: ProfileImageService.didChangeNotification,
               object: nil,
               queue: .main
           ) { [weak self] _ in
               self?.avatarURL = ProfileImageService.shared.avatarURL
           }
       }

       func loadInitialData() {
           profile = ProfileService.shared.profile
           avatarURL = ProfileImageService.shared.avatarURL
       }

       // Переносим логику обновления профиля в презентер
       func updateProfile() {
           guard let profile = ProfileService.shared.profile else {
               print("[ProfileViewPresenter|updateProfile]: Профиль отсутствует или не был загружен")
               onProfileUpdate?(nil)
               return
           }
           print("[ProfileViewPresenter|updateProfile]: Обновляем профиль - \(profile)")
           onProfileUpdate?(profile)
       }
       
       // Переносим логику обновления аватара в презентер
    func updateAvatar() {
          guard let avatarURLString = ProfileImageService.shared.avatarURL, !avatarURLString.isEmpty else {
              print("[ProfileViewPresenter|updateAvatar]: Ошибка: avatarURL отсутствует или пустое значение")
              onAvatarUpdate?(nil)
              return
          }
          
          guard let url = URL(string: avatarURLString) else {
              print("[ProfileViewPresenter|updateAvatar]: Ошибка: avatarURL не может быть преобразован в URL: \(avatarURLString)")
              onAvatarUpdate?(nil)
              return
          }
          
          onAvatarUpdate?(avatarURLString)
      }

       deinit {
           if let profileObserver = profileObserver {
               NotificationCenter.default.removeObserver(profileObserver)
           }
           if let profileImageObserver = profileImageObserver {
               NotificationCenter.default.removeObserver(profileImageObserver)
           }
       }
   }
    

