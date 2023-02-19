//
//  UIBarButtonItem+Extensions.swift
//  Photo Wall
//
//  Created by Leo Ho on 2023/2/19.
//

import UIKit

extension UIBarButtonItem {
    
    convenience init(icon: SFSymbols, target: Any?, action: Selector) {
        self.init(image: UIImage(icon: icon),
                  style: .done,
                  target: target,
                  action: action)
    }
    
    convenience init(icon: SFSymbols, menu: UIMenu) {
        self.init(title: nil,
                  image: UIImage(icon: icon),
                  primaryAction: nil,
                  menu: menu)
    }
}
