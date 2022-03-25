//
//  ImagesViewController.swift
//  RandomlyBeautiful
//
//  Created by Abraham Abreu on 24/03/22.
//

import UIKit

class ImagesViewController: UIViewController {

    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var creditLabel: UILabel!
    @IBOutlet var profilePicture: UIImageView!
    
    var category = ""
    var appID = ""
    
    var imageViews = [UIImageView]()
    var images = [JSON]()
    
    var imageCounter = 0
    var shouldContinue = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageViews = view.subviews.compactMap { $0 as? UIImageView }
        imageViews.forEach { $0.alpha =  0 }
        
        creditLabel.layer.cornerRadius = 15
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        
        guard let url = URL(string: "https://api.unsplash.com/search/photos?client_id=\(appID)&query=\(category)&per_page=100") else { return }
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.fetch(url)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        shouldContinue = false
    }
}

// MARK: - Fetching data.

private extension ImagesViewController {
    
    func fetch(_ url: URL) {
        if let data =  try? Data(contentsOf: url) {
            let json = JSON(data)
            images = json["results"].arrayValue
            downloadImage()
        }
    }
    
    func downloadImage() {
        let currentImage = images[imageCounter % images.count]
        
        let imageName = currentImage["urls"]["full"].stringValue
        let imageCredit = currentImage["user"]["name"].stringValue
        let profile = currentImage["user"]["profile_image"]["medium"].stringValue
        
        imageCounter += 1
        
        guard let profileURL = URL(string: profile) else { return }
        guard let profileData = try? Data(contentsOf: profileURL) else { return }
        
        guard let imageURL = URL(string: imageName) else { return }
        guard let imageData = try? Data(contentsOf: imageURL) else { return }
        
        guard let imageProfile = UIImage(data: profileData) else { return }
        guard let image = UIImage(data: imageData) else { return }
        
        DispatchQueue.main.async {
            self.show(image, profile: imageProfile, credit: imageCredit)
        }
    }
    
    func show(_ image: UIImage, profile: UIImage, credit: String) {
        spinner.stopAnimating()
        
        let imageViewToUse = imageViews[imageCounter % imageViews.count]
        let otherImageView = imageViews[(imageCounter + 1) % imageViews.count]
        
        UIView.animate(withDuration: 2.0, animations: {
            imageViewToUse.image = image
            imageViewToUse.alpha = 1
            
            self.profilePicture.alpha = 0
            self.creditLabel.alpha = 0
            
            self.view.sendSubviewToBack(otherImageView)
        }) {  _ in
            self.profilePicture.image = profile
            self.creditLabel.text = " \(credit.uppercased())"
            self.creditLabel.alpha = 1
            self.profilePicture.alpha = 1
            
            otherImageView.alpha = 0
            otherImageView.transform = .identity
            
            UIView.animate(withDuration: 10.0, animations: {
                imageViewToUse.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { _ in
                DispatchQueue.global(qos: .userInteractive).async {
                    if self.shouldContinue {
                        self.downloadImage()
                    }
                }
            }
        }
    }
}
