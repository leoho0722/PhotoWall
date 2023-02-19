//
//  Alert.swift
//  Photo Wall
//
//  Created by Leo Ho on 2021/8/11.
//

import UIKit

@MainActor class Alert: NSObject {
    
    /// 單一按鈕 Alert
    /// - Parameters:
    ///   - title: Alert 的標題
    ///   - message: Alert 的訊息
    ///   - vc: 要在哪個畫面跳出來
    ///   - isLeftAlign: Bool，message 文字是否靠左對齊
    ///   - confirmTitle: 按鈕的文字
    ///   - confirm: 按下按鈕後要做的事
    class func showAlertWith(title: String?,
                             message: String?,
                             vc: UIViewController,
                             isLeftAlign: Bool = false,
                             confirmTitle: String,
                             confirm: (() -> Void)?) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
            if isLeftAlign {
                let sbvs = alertController.view.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews
                let messageLabel: UILabel = sbvs[2] as! UILabel
                messageLabel.textAlignment = .left
            }
            let confirmAction = UIAlertAction(title: confirmTitle, style: .default) { _ in
                confirm?()
            }
            alertController.addAction(confirmAction)
            vc.present(alertController, animated: true)
        }
    }
    
    /// 確認、取消按鈕的 Alert
    /// - Parameters:
    ///   - title: Alert 的標題
    ///   - message: Alert 的訊息
    ///   - vc: 要在哪個畫面跳出來
    ///   - confirmTitle: 確認按鈕的文字
    ///   - cancelTitle: 取消按鈕的文字
    ///   - confirmActionStyle: 確認按鈕的 UIAlertAction.Style，預設為 .default
    ///   - confirm: 按下確認按鈕後要做的事
    ///   - cancel: 按下取消按鈕後要做的事
    class func showAlertWith(title: String?,
                             message: String?,
                             vc: UIViewController,
                             confirmTitle: String,
                             cancelTitle: String,
                             confirmActionStyle: UIAlertAction.Style = .default,
                             confirm: (() -> Void)?,
                             cancel: (() -> Void)?) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: confirmTitle, style: confirmActionStyle) { _ in
                confirm?()
            }
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { _ in
                cancel?()
            }
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            vc.present(alertController, animated: true)
        }
    }
    
    /// 顯示 ActionSheet
    /// - Parameters:
    ///   - title: actionSheet 的標題
    ///   - message: actionSheet 的訊息
    ///   - isLeftAlign: Bool，message 文字是否靠左對齊
    ///   - options: actionSheet 內的選項
    ///   - vc: 要在哪個畫面跳出來
    ///   - confirm: 按下選項後要做的事
    class func showAlertWithActionSheet(title: String? = nil,
                                        message: String? = nil,
                                        isLeftAlign: Bool = false,
                                        options: [String],
                                        vc: UIViewController,
                                        confirm: ((Int) -> Void)?,
                                        cancelTitle: String = "取消") {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .actionSheet)
            if isLeftAlign {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .left
                let messageText = NSMutableAttributedString(
                    string: message ?? "",
                    attributes: [
                        .paragraphStyle : paragraphStyle,
                        .font : UIFont.boldSystemFont(ofSize: 12),
                        .foregroundColor : UIColor.black
                    ]
                )
                alertController.setAttributedMessage(value: messageText)
            }
            
            for option in options {
                let optionAction = UIAlertAction(title: option, style: .default) { _ in
                    let index = options.firstIndex(of: option)
                    confirm?(index!)
                }
                alertController.addAction(optionAction)
            }
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel)
            alertController.addAction(cancelAction)
            vc.present(alertController, animated: true, completion: nil)
        }
    }
}
