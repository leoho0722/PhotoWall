//
//  UIAction+Extensions.swift
//  Photo Wall
//
//  Created by Leo Ho on 2023/2/19.
//

import UIKit

extension UIAction {
    
    @MainActor convenience init(title: String,
                                subtitle: String? = nil,
                                icon: SFSymbols,
                                attributes: UIMenuElement.Attributes = [],
                                handler: @escaping UIActionHandler) {
        self.init(title: title,
                  subtitle: subtitle,
                  image: UIImage(icon: icon),
                  attributes: attributes,
                  handler: handler)
    }
}
