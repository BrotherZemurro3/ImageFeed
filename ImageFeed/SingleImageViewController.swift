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
            
        }
    }
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let image else {return}
        imageView.image = image
        rescaleAndCenterImageInScrollView(image: image)
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    @IBAction func didTapBackButton() {
        dismiss(animated: true, completion: nil)
        print("Нажата кнопка назад") // чек принт, т.к. срабатывает через раз
    }

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
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

