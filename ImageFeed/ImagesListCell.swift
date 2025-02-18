//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Дионисий Коневиченко on 14.01.2025.
//

import UIKit
import Foundation

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
}
