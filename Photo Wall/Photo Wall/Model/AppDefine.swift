//
//  AppDefine.swift
//  Photo Wall
//
//  Created by Leo Ho on 2023/2/19.
//

import Foundation
import Photos

struct AppDefine {
    
    enum PhotoFilterKey {
        
        case `default`
        
        case isFavorite(Bool)
        
        case mediaType(PHAssetMediaType)
        
        case mediaSubType(PHAsset.MediaSubType)
        
        var predicate: String {
            switch self {
            case .default:
                return "self.mediaType==1 OR self.mediaType==2 OR self.mediaSubtypes==8 OR self.isFavorite==true OR self.isFavorite==false"
            case .isFavorite(let isFavorite):
                return isFavorite ? "self.isFavorite==true" : "self.isFavorite==false"
            case .mediaType(let mediaType):
                switch mediaType {
                case .unknown:
                    return "self.mediaType==0"
                case .image:
                    return "self.mediaType==1"
                case .video:
                    return "self.mediaType==2"
                case .audio:
                    return "self.mediaType==3"
                @unknown default:
                    return ""
                }
            case .mediaSubType(let mediaSubType):
                switch mediaSubType {
                case .photoPanorama:
                    return "self.mediaSubtypes==1"
                case .photoHDR:
                    return "self.mediaSubtypes==2"
                case .photoScreenshot:
                    return "self.mediaSubtypes==4"
                case .photoLive:
                    return "self.mediaSubtypes==8"
                case .photoDepthEffect:
                    return "self.mediaSubtypes==16"
                case .videoStreamed:
                    return "self.mediaSubtypes==65536"
                case .videoHighFrameRate:
                    return "self.mediaSubtypes==131072"
                case .videoTimelapse:
                    return "self.mediaSubtypes==262144"
                case .videoCinematic:
                    return "self.mediaSubtypes==2097152"
                }
            }
        }
    }
    
    enum SettingsURLScheme: String {
        
        // MARK: 設定
        
        /// 設定
        case Settings = "App-prefs:Settings"
        
        /// 設定 → 飛航模式
        case AirplaneMode = "App-prefs:AIRPLANE_MODE"
        
        /// 設定 → Wi-Fi
        case WiFi = "App-prefs:WIFI"
        
        /// 設定 → 藍牙
        case Bluetooth = "App-prefs:Bluetooth"
        
        /// 設定 → 個人熱點
        case InternetTethering = "App-prefs:INTERNET_TETHERING"
        
        /// 設定 → 通知
        case Notifications = "App-prefs:NOTIFICATIONS_ID"
        
        /// 設定 → 聲音與觸覺回饋
        case Sounds = "App-prefs:Sounds"
        
        /// 設定 → 聲音與觸覺回饋 → 鈴聲
        case Ringtone = "App-prefs:Sounds&path=Ringtone"
        
        /// 設定 → 勿擾模式
        case DonotDisturb = "App-prefs:DO_NOT_DISTURB"
        
        /// 設定 → 螢幕顯示與亮度 → 自動鎖定
        case AutoLock = "App-prefs:General&path=AUTOLOCK"
        
        /// 設定 → 背景圖片
        case Wallpaper = "App-prefs:Wallpaper"
        
        /// 設定 → Touch ID 與密碼／Face ID 與密碼
        case Passcode = "App-prefs:PASSCODE"
        
        /// 設定 → App Store
        case AppStore = "App-prefs:STORE"
        
        /// 設定 -> 密碼
        case Password = "App-prefs:PASSWORDS"
        
        /// 設定 → 備忘錄
        case Notes = "App-prefs:NOTES"
        
        /// 設定 → 電話
        case Phone = "App-prefs:Phone"
        
        /// 設定 → FaceTime
        case Facetime = "App-prefs:FACETIME"
        
        /// 設定 → 音樂
        case Music = "App-prefs:MUSIC"

        /// 設定 → 照片
        case Photos = "App-prefs:Photos"
        
        // MARK: 設定 -> Apple ID
        
        /// 設定 → Apple ID → iCloud
        case iCloud = "App-prefs:CASTLE"
        
        /// 設定 → Apple ID → iCloud
        case iCloudStorageAndBackup = "App-prefs:CASTLE&path=STORAGE_AND_BACKUP"
        
        // MARK: 設定 -> 一般
        
        /// 設定 → 一般
        case General = "App-prefs:General"
        
        /// 設定 → 一般 → 關於本機
        case About = "App-prefs:General&path=About"
        
        /// 設定 → 一般 → 軟體更新
        case SoftwareUpdate = "App-prefs:General&path=SOFTWARE_UPDATE_LINK"
        
        /// 設定 → 一般 → 日期與時間
        case DateAndTime = "App-prefs:General&path=DATE_AND_TIME"
        
        /// 設定 → 一般 → 鍵盤
        case Keyboard = "App-prefs:General&path=Keyboard"
        
        /// 設定 → 一般 → 語言與地區
        case LanguageAndRegion = "App-prefs:General&path=INTERNATIONAL"
        
        /// 設定 → 一般 → 描述檔
        case ManagedConfigurationList = "App-prefs:General&path=ManagedConfigurationList"
        
        /// 設定 → 一般 → 重置
        case Reset = "App-prefs:General&path=Reset"
    }
}
