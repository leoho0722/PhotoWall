//
//  UIImage+Extensions.swift
//  Photo Wall
//
//  Created by Leo Ho on 2023/2/19.
//

import UIKit

extension UIImage {
    
    convenience init?(icon: SFSymbols) {
        self.init(systemName: icon.rawValue)
    }
}
