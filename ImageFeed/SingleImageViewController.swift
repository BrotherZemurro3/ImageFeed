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
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }

    @IBOutlet private var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
}
