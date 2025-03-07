//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Дионисий Коневиченко on 20.01.2025.
//

import UIKit
import Foundation

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            rescaleAndCenterImageInScrollView(image: image)
            imageView.frame.size = image.size
            centerImageView()
        }
    }
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet var shareButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
        centerImageView()
    }
    
    // MARK: - Actions
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
        print("Нажата кнопка назад") // чек принт, т.к. срабатывает через раз
    }
    @IBAction private func didShareButton(_ sender: UIButton) {
        guard let image else {return}
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(share, animated: true, completion: nil)
    }
    
    // MARK: - Image Scailing & Positioning
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        centerImageView()
    }
    
    private func centerImageView() {
        guard let imageView = imageView else {return}
        
        let horizontalInset = max(0,(scrollView.bounds.width - imageView.frame.width * scrollView.zoomScale) / 2)
        let verticalInset = max(0, (scrollView.bounds.height - imageView.frame.height * scrollView.zoomScale), 2)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
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
