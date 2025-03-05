//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Дионисий Коневиченко on 18.01.2025.
//

import UIKit
import Foundation



final class ProfileViewController: UIViewController {
    
    private let nameLabel = UILabel()
    private let loginLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let profileService = ProfileService.shared
    private let profileImage = UIImage(named: "profile_photo")
    private var profileimageSeviceObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        profileimageSeviceObserver = NotificationCenter.default    // 2
                   .addObserver(
                       forName: ProfileImageService.didChangeNotification, // 3
                       object: nil,                                        // 4
                       queue: .main                                        // 5
                   ) { [weak self] _ in
                       guard let self = self else { return }
                       self.updateAvatar()                                 // 6
                   }
               updateAvatar()                                              // 7
           }
           
           private func updateAvatar() {                                   // 8
               guard
                   let profileImageURL = ProfileImageService.shared.avatarURL,
                   let url = URL(string: profileImageURL)
               else { return }
               // TODO [Sprint 11] Обновить аватар, используя Kingfisher
    
        
            let imageView = UIImageView(image: profileImage)
            imageView.tintColor = .gray
            imageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
                imageView.widthAnchor.constraint(equalToConstant: 70),
                imageView.heightAnchor.constraint(equalToConstant: 70),])
            
            let logoutButton = UIButton(type: .system)
            logoutButton.setImage(UIImage(named: "logoutButton"), for: .normal)
            logoutButton.tintColor = .ypRed
            logoutButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(logoutButton)
            NSLayoutConstraint.activate([
                logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                logoutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor) ])
            
            
            
            nameLabel.text = "Екатерина Новикова"
            nameLabel.textColor = .white
            nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
            
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(nameLabel)
            NSLayoutConstraint.activate([
                nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
                nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8)])
            
            loginLabel.text = "@ekaterina_nov"
            loginLabel.textColor = .lightGray
            loginLabel.font = .systemFont(ofSize: 13,weight: .regular)
            loginLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(loginLabel)
            NSLayoutConstraint.activate([
                loginLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
                loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)])
            
            descriptionLabel.text = "Hello,world!"
            descriptionLabel.textColor = .white
            descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(descriptionLabel)
            NSLayoutConstraint.activate([
                descriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
                descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8)])
        
        guard let profile = profileService.profile else { return }
               updateProfileDetails(profile: profile)
        }

    func updateProfileDetails(profile: Profile) {
        print("[ProfileViewController]: Обновляем профиль - \(profile)")
              nameLabel.text = profile.name.isEmpty ? "No Name" : profile.name
             loginLabel.text = profile.loginName
              descriptionLabel.text = profile.bio ?? "No Bio"
          }
   
    }
    

