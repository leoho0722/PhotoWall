//
//  UIAlertController+Extensions.swift
//  Photo Wall
//
//  Created by Leo Ho on 2023/2/19.
//

import UIKit

extension UIAlertController {
    
    /// 設定 UIAlertController message 的 attributedMessage
    /// - Parameters:
    ///   - value: attributedMessage
    func setAttributedMessage(value: Any?) {
        self.setValue(value, forKey: "attributedMessage")
    }
}
