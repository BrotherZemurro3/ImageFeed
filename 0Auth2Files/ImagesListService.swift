import UIKit
import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
    init(from photoResult: PhotoResult) {
        self.id = photoResult.id
        self.imageUrl = photoResult.urls.regular
        self.width = photoResult.width
        self.height = photoResult.height
        self.description = photoResult.description
        self.likes = photoResult.likes
    }
}


struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let updatedAt:String
    let width: Int
    let height: Int
    let color: String
    let blurHash: String
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width
        case height
        case color
        case blurHash = "blur_hash"
        case likes
        case likedByUser = "liked"
        case description
        case urls
    }
    struct UrlsResult: Codable {
        let raw: String
         let full: String
         let regular: String
         let small: String
         let thumb: String
      
    }
}




final class ImagesListService {
    private let photos: [Photo]
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var currentTask: URLSessionTask?
    private var dataTask:  URLSessionTask?
    private var lastLoadedPage
    
    
    
 private func fetchPhotosNextPage() {
     guard currentTask == nil else {
         return
     }
          let nextPage = (lastLoadedPage?.number ?? 0) + 1
            if nextPage == 1 {
                photos.removeAll()
            }
     ImagesListService.fetchPhotosNextPage() { [weak self] result in
         DispatchQueue.main.async {
             guard let self = self else {return}
             self.isLoading = false
             
             switch result {
             case .success(let new photos):
                 self.photos.append(contentOf: newPhotos)
                 self.lastLoadedPage = netxPage
                 
                 NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
             case .failure(let error):
                 print("Ошибка загрузки фотографий: \(error.localizedDescription)")
             }
         }}
    }

    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath) {
        //  В этом методе можно проверить условие indexPath.row + 1 == photos.count, и если оно верно — вызывать fetchPhotosNextPage().
    }
    
}
