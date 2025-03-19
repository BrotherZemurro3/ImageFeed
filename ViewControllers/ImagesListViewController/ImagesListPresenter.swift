import UIKit


final class ImagesListPresenter: ImagesListPresenterProtocol {
 weak var view: ImagesListViewControllerProtocol?
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    private var imagesListServiceObserver: NSObjectProtocol?
    
    init(view: ImagesListViewControllerProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableView()
        }
        imagesListService.fetchPhotosNextPage()
    }
    
    func getPhotos() -> [Photo] {
        return photos
    }
    
    func updateTableView() {
        photos = imagesListService.photos
        view?.updateTableView()
    }
    
    func loadMorePhotosIfNeeded(for index: Int) {
        if index + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func toggleLike(for index: Int, completion: @escaping () -> Void) {
        let photo = photos[index]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success:
                    guard let self = self else { return }
                    // Перезаписываем массив `photos` целиком
                    self.photos = self.imagesListService.photos
                    completion()
                case .failure:
                    self?.view?.showLikeErrorAlert()
                }
            }
        }
    }
}




