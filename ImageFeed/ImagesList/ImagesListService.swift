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
        self.size = CGSize(width: photoResult.width, height: photoResult.height)
        self.createdAt = ISO8601DateFormatter().date(from: photoResult.createdAt)
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb
        self.largeImageURL = photoResult.urls.full
        self.isLiked = photoResult.likedByUser
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
 var photos: [Photo]
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var currentTask: URLSessionTask?
    private var dataTask:  URLSessionTask?
    private var lastLoadedPage: Int?
    static var shared = ImagesListService()
    private init() {}
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    
    
    private func fetchPhotosNextPage() {
        guard currentTask == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        let task = NetworkService.fetchPhotos(page: nextPage) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.currentTask = nil
                
                switch result {
                case .success(let newPhotos):
                    self.photos.append(contentsOf: newPhotos.map { Photo(from: $0) })
                    self.lastLoadedPage = nextPage
                    
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                case .failure(let error):
                    print("Ошибка загрузки фотографий: \(error.localizedDescription)")
                }
            }
        }
        currentTask = task
        task.resume()
    }

    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath) {
        //  В этом методе можно проверить условие indexPath.row + 1 == photos.count, и если оно верно — вызывать fetchPhotosNextPage().
        if indexPath.row + 1 == photos.count {
             fetchPhotosNextPage()
         }
     }
    
}
