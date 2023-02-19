//
//  Localizables.swift
//  Photo Wall
//
//  Created by Leo Ho on 2023/2/19.
//

import Foundation

enum LocalizationKeys: String {
    
    case appName = "CFBundleName"
    
    // MARK: Alert
    
    case confitm = "Confirm"
    
    // MARK: PhotosViewController
    
    case favorite = "Favorites"
    
    case cancelFavorite = "Cancel Favorites"
    
    case favorited = "Favorited"
    
    case nonFavorited = "Non Favorited"
    
    case photos = "Photos"
    
    case livePhotos = "Live Photos"
    
    case videos = "Videos"
    
    case delete = "Delete"
    
    // MARK: PhotosDetailViewController
    
    case changeFavoriteStatusFailed = "Change Favorite Status Failed"
    
    case deleteSuccess = "Delete Success"
    
    case deleteFailed = "Delete Failed"
}

func transalte(_ keys: LocalizationKeys) -> String {
    if keys == .appName {
        return NSLocalizedString(keys.rawValue,
                                 tableName: "InfoPlist",
                                 bundle: Bundle.main,
                                 comment: "")
    } else {
        return NSLocalizedString(keys.rawValue, comment: "")
    }
}
