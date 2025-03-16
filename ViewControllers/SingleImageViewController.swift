//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Дионисий Коневиченко on 20.01.2025.
//

import UIKit
import Foundation
import Kingfisher
import ProgressHUD

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            rescaleAndCenterImageInScrollView(image: image)
            imageView.frame.size = image.size
            centerImageView()
        }
    }
    var imageURL: String?
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "stubForSingleImage"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let imagesListService = ImagesListService.shared
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet var shareButton: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настройка scrollView
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 3.0
        
        // Настройка заглушки
        if image == nil {
            setupPlaceholderConstraints()
        }
        
        // Загрузка изображения
        if let image = image {
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        } else {
            loadImage()
        }
    }
    
    // MARK: - Actions
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    @IBAction private func didShareButton(_ sender: UIButton) {
        guard let image else {return}
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(share, animated: true, completion: nil)
    }
    
    private func setupPlaceholderConstraints() {
        imageView.addSubview(placeholderImageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderImageView.widthAnchor.constraint(equalToConstant: 83),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 75),
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func removePlaceholder() {
        placeholderImageView.removeFromSuperview()
    }
    
    
    // MARK: - Image Scaling & Positioning
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let imageSize = image.size
        let scrollViewSize = scrollView.bounds.size
        
        // Рассчитываем масштаб для заполнения экрана
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minScale = max(widthScale, heightScale)
        
        // Устанавливаем минимальный и максимальный масштаб
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 3.0
        
        // Устанавливаем начальный масштаб
        scrollView.zoomScale = minScale
        
        // Обновляем размер imageView
        imageView.frame.size = CGSize(
            width: imageSize.width * minScale,
            height: imageSize.height * minScale
        )
        
        // Центрируем изображение
        centerImageView()
    }
    
    private func centerImageView() {
        guard let imageView = imageView else { return }
        
        let horizontalInset = max(0, (scrollView.bounds.width - imageView.frame.width) / 2)
        let verticalInset = max(0, (scrollView.bounds.height - imageView.frame.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset
        )
    }
    
    // MARK: - Load Image
    private func loadImage() {
        guard let imageURLString = imageURL,
              let url = URL(string: imageURLString) else {
            print("[SingleImageViewController|loadImage]: Некорректный URL изображения")
            return
        }
        
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(
            with: url,
            placeholder: nil,
            options: [
                .cacheOriginalImage,
                .transition(.fade(0.2))
            ]) { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                
                guard let self = self else { return }
                switch result {
                case .success(let imageResult):
                    self.imageView.image = imageResult.image
                    self.removePlaceholder() // Удаляем заглушку после успешной загрузки
                    self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                case .failure(let error):
                    print("[SingleImageViewController|loadImage]: Ошибка загрузки изображения: \(error.localizedDescription)")
                    self.imageView.image = nil
                    self.setupPlaceholderConstraints() // Показываем заглушку в случае ошибки
                    self.showSingleImageLoadError()
                }
            }
    }
    
    private func showSingleImageLoadError() {
        let alert = UIAlertController(title: "Ошибка!", message: "Что-то пошло не так, попробовать еще раз?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        alert.addAction(UIAlertAction(title: "Да", style: .default) { _ in
            self.loadImage()
        })
        present(alert, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageView()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        centerImageView()
    }
}
