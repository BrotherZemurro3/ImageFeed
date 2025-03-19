
import UIKit
import Foundation

class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    
    @IBOutlet private var tableView: UITableView!
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
       private var presenter: ImagesListPresenter!
       
       override func viewDidLoad() {
           super.viewDidLoad()
           tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
           presenter = ImagesListPresenter(view: self)
           presenter.viewDidLoad()
       }
    func configure(_ presenter: ImagesListPresenter) {
           self.presenter = presenter
           presenter.view = self
       }
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == showSingleImageSegueIdentifier,
              let viewController = segue.destination as? SingleImageViewController,
              let indexPath = sender as? IndexPath {
               let photo = presenter.getPhotos()[indexPath.row]
               viewController.imageURL = photo.fullImageURL
           } else {
               super.prepare(for: segue, sender: sender)
           }
       }
       
    
    
    
       func updateTableView() {
           tableView.reloadData()
       }
       
       func showLikeErrorAlert() {
           let alert = UIAlertController(title: "Ошибка", message: "Не удалось поставить лайк(", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
       }
   }


   // Extensions
   extension ImagesListViewController: UITableViewDataSource {
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return presenter.getPhotos().count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
               return UITableViewCell()
           }
           
           let photo = presenter.getPhotos()[indexPath.row]
           cell.configure(with: photo)
           cell.delegate = self
           cell.setIsLiked(photo.isLiked)
           return cell
       }
   }

   extension ImagesListViewController: UITableViewDelegate {
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
       }
       
       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           let photo = presenter.getPhotos()[indexPath.row]
           let tableWidth = tableView.bounds.width - tableView.layoutMargins.left - tableView.layoutMargins.right
           return (photo.size.height / photo.size.width) * tableWidth + 8
       }
       
       func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
           presenter.loadMorePhotosIfNeeded(for: indexPath.row)
       }
   }

   extension ImagesListViewController: ImagesListCellDelegate {
       func imageListCellDidTapLike(_ cell: ImagesListCell) {
           guard let indexPath = tableView.indexPath(for: cell) else { return }
           presenter.toggleLike(for: indexPath.row) {
               cell.setIsLiked(self.presenter.getPhotos()[indexPath.row].isLiked)
           }
       }
   }
