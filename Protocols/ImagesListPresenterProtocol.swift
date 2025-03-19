import UIKit


protocol ImagesListPresenterProtocol: AnyObject {
    func viewDidLoad()
      func getPhotos() -> [Photo]
      func loadMorePhotosIfNeeded(for index: Int)
      func toggleLike(for index: Int, completion: @escaping () -> Void)
}
