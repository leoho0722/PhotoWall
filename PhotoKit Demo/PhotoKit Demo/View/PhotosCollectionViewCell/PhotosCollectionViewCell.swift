//
//  PhotosCollectionViewCell.swift
//  CocoaPodsDemo
//
//  Created by Leo Ho on 2022/2/14.
//

import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photosImage: UIImageView!
    @IBOutlet weak var favoriteImage: UIButton!
    @IBOutlet weak var typeImage: UIImageView!
    
    static let identifier = "PhotosCollectionViewCell"
    
    var representedAssetIdentifier: String = ""
    var smallImage: UIImage! {
        didSet {
            photosImage.image = smallImage
        }
    }
    var sourceImage: UIImage! {
        didSet {
            typeImage.image = sourceImage
            typeImage.tintColor = .white
        }
    }
    var heartImage: String! {
        didSet {
            favoriteImage.setTitle(heartImage, for: .normal)
            favoriteImage.tintColor = .white
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
