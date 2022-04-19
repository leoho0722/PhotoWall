//
//  CustomFunc.swift
//  CocoaPodsDemo
//
//  Created by Leo Ho on 2021/8/11.
//

import Foundation
import UIKit

class CustomAlert: NSObject {
    
    static let shared = CustomAlert()
    
    /// 單一關閉按鈕提示框
    /// - Parameters:
    ///   - title: 提示框標題
    ///   - message: 提示訊息
    ///   - vc: 要在哪一個 UIViewController 上呈現
    ///   - actionHandler: 按下按鈕後要執行的動作，沒有的話就填 nil
    func customAlert(title: String?, message: String?, vc: UIViewController, actionHandler: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "關閉", style: .default) { action in
            actionHandler?()
        }
        alertController.addAction(closeAction)
        vc.present(alertController, animated: true)
    }
    
    /// 確定取消按鈕提示框
    /// - Parameters:
    ///   - title: 提示框標題
    ///   - message: 提示訊息
    ///   - vc: 要在哪一個 UIViewController 上呈現
    ///   - actionHandler: 按下確定按鈕後要執行的動作，沒有的話就填 nil
    ///   - cancelHandler: 按下取消按鈕後要執行的動作，沒有的話就填 nil
    func customYesNoAlert(title: String?, message: String?, vc: UIViewController, actionHandler: (() -> Void)?, cancelHandler: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "確定", style: .default) { action in
            actionHandler?()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { action in
            cancelHandler?()
        }
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        vc.present(alertController, animated: true)
    }
    
    /// Action Sheet 多按鈕提示框
    /// - Parameters:
    ///   - title: 提示框標題
    ///   - vc: 要在哪一個 UIViewController 上呈現
    ///   - actionSheetTitle: 顯示的不同選項
    ///   - actionSheetsHandler: 按下不同選項要做的動作，沒有的話就填 nil
    func customActionSheetAlert(title: String?, vc: UIViewController, actionSheetsTitle: [String], actionSheetsHandler: ((Int) -> Void)?) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for name in actionSheetsTitle {
            let alertAction = UIAlertAction(title: name, style: .default) { action in
                let index = actionSheetsTitle.firstIndex(of: name)
                actionSheetsHandler?(index!)
            }
            alertController.addAction(alertAction)
        }
        let closeAction = UIAlertAction(title: "關閉", style: .cancel, handler: nil)
        alertController.addAction(closeAction)
        vc.present(alertController, animated: true)
    }
    
    /// 開啟設定內指定畫面＋關閉按鈕提示框
    /// - Parameters:
    ///   - title: 提示框標題
    ///   - message: 提示訊息
    ///   - app_prefs_title: 設定內指定畫面的名稱，請參照 CustomFunc.swift 底下的 enum App_prefs 列表
    ///   - app_prefs: 設定內指定畫面的代號，請參照 CustomFunc.swift 底下的 enum App_prefs 列表
    ///   - vc: 要在哪一個 UIViewController 上呈現
    ///   - actionHandler: 按下按鈕後要執行的動作，沒有的話就填 nil
    func urlAlert(title: String?, message: String?, app_prefs_title: String, app_prefs: App_prefs, vc: UIViewController, actionHandler: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let urlAction = UIAlertAction(title: "開啟「\(app_prefs_title)」", style: .cancel) { action in
            guard let url = URL(string: "App-prefs:\(app_prefs)") else { return }
            if (UIApplication.shared.canOpenURL(url)) {
                UIApplication.shared.open(url) { success in
                    print(success)
                }
            }
        }
        let closeAction = UIAlertAction(title: "關閉", style: .default) { action in
            actionHandler?()
        }
        alertController.addAction(urlAction)
        alertController.addAction(closeAction)
        vc.present(alertController, animated: true)
    }
    
    /// 開啟設定內指定畫面＋關閉按鈕提示框
    /// - Parameters:
    ///   - title: 提示框標題
    ///   - message: 提示訊息
    ///   - app_prefs_title: 設定內指定畫面的名稱，請參照 CustomFunc.swift 底下的 enum App_prefs_Have_path 列表
    ///   - app_prefs: 設定內指定畫面的代號 (含有 &path= 的)，請參照 CustomFunc.swift 底下的 enum App_prefs_Have_path 列表
    ///   - vc: 要在哪一個 UIViewController 上呈現
    ///   - actionHandler: 按下按鈕後要執行的動作，沒有的話就填 nil
    func urlHavePathAlert(title: String?, message: String?, app_prefs_title: String, app_prefs: String, vc: UIViewController, actionHandler: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let urlAction = UIAlertAction(title: "開啟「\(app_prefs_title)」", style: .cancel) { action in
            guard let url = URL(string: "App-prefs:\(app_prefs)") else { return }
            if (UIApplication.shared.canOpenURL(url)) {
                UIApplication.shared.open(url) { success in
                    print(success)
                }
            }
        }
        let closeAction = UIAlertAction(title: "關閉", style: .default) { action in
            actionHandler?()
        }
        alertController.addAction(urlAction)
        alertController.addAction(closeAction)
        vc.present(alertController, animated: true)
    }
    
    // MARK: - 取得送出/更新留言的當下時間
    func getSystemTime() -> String {
        let currectDate = Date()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale.ReferenceType.system
        dateFormatter.timeZone = TimeZone.ReferenceType.system
        return dateFormatter.string(from: currectDate)
    }
}

enum App_prefs: String {
    case Settings = "Settings" // 設定
//    case About = "General&path=About" // 設定 → 一般 → 關於本機
    case AIRPLANE_MODE = "AIRPLANE_MODE" // 設定 → 飛航模式
//    case AUTOLOCK = "General&path=AUTOLOCK" // 設定 → 螢幕顯示與亮度 → 自動鎖定
    case Bluetooth = "Bluetooth" // 設定 → 藍牙
//    case DATE_AND_TIME = "General&path=DATE_AND_TIME" // 設定 → 一般 → 日期與時間
    case FACETIME = "FACETIME" // 設定 → FaceTime
    case General = "General" // 設定 → 一般
//    case Keyboard = "General&path=Keyboard" // 設定 → 一般 → 鍵盤
    case CASTLE = "CASTLE" // 設定 → Apple ID → iCloud
//    case STORAGE_AND_BACKUP = "CASTLE&path=STORAGE_AND_BACKUP" // 設定 → Apple ID → iCloud
//    case INTERNATIONAL = "General&path=INTERNATIONAL" // 設定 → 一般 → 語言與地區
    case MUSIC = "MUSIC" // 設定 → 音樂
    case NOTES = "NOTES" // 設定 → 備忘錄
    case NOTIFICATIONS_ID = "NOTIFICATIONS_ID" // 設定 → 通知
    case Phone = "Phone" // 設定 → 電話
    case Photos = "Photos" // 設定 → 照片
//    case ManagedConfigurationList = "General&path=ManagedConfigurationList" // 設定 → 一般 → 描述檔
//    case Reset = "General&path=Reset" // 設定 → 一般 → 重置
//    case Ringtone = "Sounds&path=Ringtone" // 設定 → 聲音與觸覺回饋 → 鈴聲
    case Sounds = "Sounds" // 設定 → 聲音與觸覺回饋
//    case SOFTWARE_UPDATE_LINK = "General&path=SOFTWARE_UPDATE_LINK" // 設定 → 一般 → 軟體更新
    case STORE = "STORE" // 設定 → App Store
    case Wallpaper = "Wallpaper" // 設定 → 背景圖片
    case WIFI = "WIFI" // 設定 → Wi-Fi
    case INTERNET_TETHERING = "INTERNET_TETHERING" // 設定 → 個人熱點
    case DO_NOT_DISTURB = "DO_NOT_DISTURB" // 設定 → 勿擾模式
}

enum App_prefs_Have_path: String {
    case About = "General&path=About" // 設定 → 一般 → 關於本機
    case AUTOLOCK = "General&path=AUTOLOCK" // 設定 → 螢幕顯示與亮度 → 自動鎖定
    case DATE_AND_TIME = "General&path=DATE_AND_TIME" // 設定 → 一般 → 日期與時間
    case Keyboard = "General&path=Keyboard" // 設定 → 一般 → 鍵盤
    case STORAGE_AND_BACKUP = "CASTLE&path=STORAGE_AND_BACKUP" // 設定 → Apple ID → iCloud
    case INTERNATIONAL = "General&path=INTERNATIONAL" // 設定 → 一般 → 語言與地區
    case ManagedConfigurationList = "General&path=ManagedConfigurationList" // 設定 → 一般 → 描述檔
    case Reset = "General&path=Reset" // 設定 → 一般 → 重置
    case Ringtone = "Sounds&path=Ringtone" // 設定 → 聲音與觸覺回饋 → 鈴聲
    case SOFTWARE_UPDATE_LINK = "General&path=SOFTWARE_UPDATE_LINK" // 設定 → 一般 → 軟體更新
}
