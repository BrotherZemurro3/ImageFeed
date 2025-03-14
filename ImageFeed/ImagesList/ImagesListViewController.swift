// ViewController.swift
// ImageFeed
//
// Created by Дионисий Коневиченко on 21.12.2024.
//

import UIKit
import Foundation

class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    private var imagesListServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        imagesListServiceObserver = NotificationCenter.default.addObserver(forName: ImagesListService.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            print("imagesListServiceObserver notification: Обновление таблицы")
            self?.updateTableViewAnimated()
        }
        ImagesListService.shared.fetchPhotosNextPage()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("[ImagesListViewController|prepare]: Invalid segue destination")
                return
            }
            let photo = photos[indexPath.row] // ✅ Берём один объект photo из массива
            viewController.imageURL = photo.fullImageURL // ✅ Передаём ссылку на изображение
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
  private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        guard oldCount <= newCount else {
            tableView.reloadData()
            return
        }
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ImagesListCell.reuseIdentifier,
                for: indexPath
            ) as? ImagesListCell
        else {
            return UITableViewCell()
        }
        
        let photo = photos[indexPath.row]
        cell.configure(with: photo)
        cell.delegate = self
        cell.setIsLiked(photo.isLiked)
        return cell
    }
    
    
}
extension ImagesListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: IndexPath
    ) {
        performSegue(
            withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(
        _ tableView: UITableView, heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        
        let photo = photos[indexPath.row]
        let tableWidth = tableView.bounds.width - tableView.layoutMargins.left - tableView.layoutMargins.right
        return (photo.size.height / photo.size.width) * tableWidth + 8
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
    
    
}
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success:
                    self.photos[indexPath.row] = self.imagesListService.photos.first { $0.id == photo.id } ?? photo
                    cell.setIsLiked(self.photos[indexPath.row].isLiked) // 🛠 Мгновенно обновляем UI
                case .failure:
                    self.showLikeErrorAlert()
                }
            }
        }
    }
    private func showLikeErrorAlert() {
        let alert = UIAlertController(title: "Ошибка", message: "Не удалось поставить лайк(", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

