//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Дионисий Коневиченко on 14.01.2025.
//

import UIKit
import Foundation
import Kingfisher


final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    
    private var currentImageURL: String?
    weak var delegate: ImagesListCellDelegate?
    
override func prepareForReuse() {
    super.prepareForReuse()
        cellImage.kf.cancelDownloadTask() // Отмена загрузки при переиспользовании ячейки
        cellImage.image = nil
}
    @IBAction private func likeButtonClicked() {
       delegate?.imageListCellDidTapLike(self)
    }
    func setIsLiked(_ isLiked: Bool) {
          let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
          likeButton.setImage(likeImage, for: .normal)
      }
      
    func configure(with photo: Photo) {
        currentImageURL = photo.thumbImageURL
        let placeholder = UIImage(named: "stubForImageCell")
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(with: URL(string: photo.thumbImageURL), placeholder: placeholder)
        dateLabel.text = photo.createdAt?.dateTimeString ?? "Неизвестно"
    }
    
    

    
}
