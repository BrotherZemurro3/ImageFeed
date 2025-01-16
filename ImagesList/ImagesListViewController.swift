//
//  ViewController.swift
//  ImageFeed
//
//  Created by Дионисий Коневиченко on 21.12.2024.
//

import UIKit
import Foundation
class ImagesListViewController: UIViewController {
    
  
    
    
    @IBOutlet private var tableView: UITableView!
    private let photosName: [String] = Array(0..<20).map{ "\($0)"}
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
        override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
      
       
    }
    }


extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count // Добавляем в метод, который определяет количество ячеек в секции таблицы возврат значения.
    }
    // Метод протокола, возвращающий ячейку.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) // Метод, который из всех ячеек, зарегестрированных в таблице, возвращает ячейку, по заранее добавленному идентификатору
        guard let imageListCell = cell as? ImagesListCell else { // Приведение типов для работы с ячейками, если ничего не будет, то вернем обычную ячейку
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath )
        return imageListCell // Возврат ячейчки, являющейся наследником UITableViewCell
    }
        }
extension ImagesListViewController {
func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
guard let image = UIImage(named: photosName[indexPath.row]) else {
    return
}
cell.cellImage.image = image
cell.dateLabel.text = dateFormatter.string(from: Date())
let isLiked = indexPath.row % 2 == 1
let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
    cell.likeButton.setImage(likeImage, for: .normal)
}
}


extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {} // метод, отвечающий за дейсвтия, которые будут выполнены при тапе по ячейки таблицы. Адрес ячейки, содержащийся в indexPath передаётся в качестве аргумента. 1
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}


