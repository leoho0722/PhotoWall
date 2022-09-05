//
//  PhotosDetailViewController.swift
//  CocoaPodsDemo
//
//  Created by Leo Ho on 2022/2/14.
//

import UIKit
import Photos
import PhotosUI
import AVKit

class PhotosDetailViewController: UIViewController {

    @IBOutlet weak var photosDetailImage: UIImageView!
    @IBOutlet weak var livePhotoView: PHLivePhotoView!
    @IBOutlet weak var customTabBarFooterView: CustomTabBarFooterView!
    
    // Photos 變數宣告
    var asset: PHAsset!
    let photosImageRequestOptions = PHImageRequestOptions()
    let livePhotoImageRequestOptions = PHLivePhotoRequestOptions()
    let videoRequestOptions = PHVideoRequestOptions()
    let imageManager = PHImageManager.default()
    
    // AVPlayer 變數宣告
    var avPlayerLayer: AVPlayerLayer!
    
    var isPlayingLivePhoto: Bool = false
    var isPlayingVideo: Bool = false
    
    var appearance: Bool = false
    
    var tabBarIsHidden: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("該張的收藏狀態：\(asset.isFavorite)")
        print("該張的 mediaType：\(asset.mediaType.rawValue), mediaSubtypes：\(asset.mediaSubtypes)")
        print("該張的檔名：\(asset.fileName)")
        
        self.title = "\(asset.fileName)"
        
        PHPhotoLibrary.shared().register(self) // 註冊相簿變化的觀察
        
        livePhotoView.delegate = self // 將 PHLivePhotoView 的委任指派給 PhotosDetailViewController
        
        appearance = (UITraitCollection.current.userInterfaceStyle == .dark) ? (true) : (false)
        
        customTabBarFooterView.isHidden = tabBarIsHidden
        
        if (asset.mediaType == .image) {
            self.setupCustomTabBarFooterView(isPlayHidden: true) // 隱藏中間的播放鍵
        } else if (asset.mediaType == .video) {
            self.setupCustomTabBarFooterView(isPlayHidden: false) // 顯示中間的播放鍵
        }
        
        self.setUpSwipeGesture() // 增加下滑手勢
        
        chooseUpdateType() // 判斷是 Image 還是 Live Photo，來決定要用哪種 Update Func
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoHasPlayedDone), name: .AVPlayerItemDidPlayToEndTime, object: nil) // 監聽影片是否已經播放完成了
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self) // 移除相簿變化的觀察
    }
    
    // MARK: - 下滑手勢回照片牆
    
    func setUpSwipeGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(popToPreviousPage))
        swipeGesture.direction = .down
        swipeGesture.numberOfTouchesRequired = 1
        swipeGesture.location(in: self.view)
        self.view.addGestureRecognizer(swipeGesture)
    }
    
    @objc func popToPreviousPage() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - 設定 CustomTabBarFooterView
    
    func setupCustomTabBarFooterView(isPlayHidden: Bool) {
        customTabBarFooterView.setInit(isDarkMode: appearance)
        customTabBarFooterView.photoOp = photoOp
        
        // 收藏按鈕
        self.customTabBarFooterView.left.isHidden = !asset.canPerform(.properties)
        self.customTabBarFooterView.left.label.text = asset.isFavorite ? "Cancel" : "Favorite"
        self.customTabBarFooterView.left.icon.image = asset.isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        
        // 播放按鈕
        self.customTabBarFooterView.mid.isHidden = isPlayHidden
        self.customTabBarFooterView.mid.label.text = ""
        self.customTabBarFooterView.mid.icon.image = UIImage(systemName: "play.circle.fill")
        
        // 刪除按鈕
        self.customTabBarFooterView.right.isHidden = !asset.canPerform(.delete)
        self.customTabBarFooterView.right.label.text = "Delete"
        customTabBarFooterView.right.icon.tintColor = .systemRed
    }

    private func photoOp(index: Int) {
        switch index {
        case 0:
            print("按下收藏鍵")
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetChangeRequest(for: self.asset)
                request.isFavorite = !self.asset.isFavorite
                print("該張照片修改後的收藏狀態：\(request.isFavorite)")
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    if (success) {
                        self.customTabBarFooterView.left.icon.image = !self.asset.isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
                        self.customTabBarFooterView.left.label.text = !self.asset.isFavorite ? "Cancel" : "Favorite"
                    } else {
                        CustomAlert.shared.customAlert(title: "Can't Change Favorite Status！", message: "Error Message：\(String(describing: error?.localizedDescription))", vc: self, actionHandler: nil)
                    }
                }
            }
        case 1:
            print("按下播放鍵")
            if (avPlayerLayer != nil) {
                if (avPlayerLayer.player?.timeControlStatus == .paused) {
                    DispatchQueue.main.async {
                        self.avPlayerLayer.player?.play()
                        self.customTabBarFooterView.mid.icon.image = UIImage(systemName: "stop.circle.fill")
                    }
                } else if (avPlayerLayer.player?.timeControlStatus == .playing) {
                    DispatchQueue.main.async {
                        self.avPlayerLayer.player?.pause()
                        self.customTabBarFooterView.mid.icon.image = UIImage(systemName: "play.circle.fill")
                    }
                }
            } else {
                self.customTabBarFooterView.mid.icon.image = UIImage(systemName: "stop.circle.fill")
                
                videoRequestOptions.deliveryMode = .highQualityFormat
                videoRequestOptions.isNetworkAccessAllowed = true
                
                imageManager.requestPlayerItem(forVideo: asset, options: videoRequestOptions) { playerItem, info in
                    DispatchQueue.main.async {
                        guard self.avPlayerLayer == nil else { return }
                        let player = AVPlayer(playerItem: playerItem)
                        let playerLayer = AVPlayerLayer(player: player)
                        playerLayer.videoGravity = AVLayerVideoGravity.resize
                        playerLayer.frame = self.photosDetailImage.layer.bounds
                        self.photosDetailImage.layer.addSublayer(playerLayer)
                        player.play()
                        self.avPlayerLayer = playerLayer
                    }
                }
            }
        case 2:
            print("按下刪除鍵")
            // 刪除單一照片
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets([self.asset] as NSArray)
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    if (success) {
                        PHPhotoLibrary.shared().unregisterChangeObserver(self)
                        CustomAlert.shared.customAlert(title: "Delete Success！", message: nil, vc: self) {
                            self.navigationController!.popViewController(animated: true)
                        }
                    }
                }
            }
        default: break
        }
    }
    
    // 監聽影片是否已經播放完畢
    @objc func videoHasPlayedDone(notification: NSNotification) {
        print("影片已經播放完了")
        DispatchQueue.main.async {
            self.avPlayerLayer = nil
            self.customTabBarFooterView.mid.icon.image = UIImage(systemName: "play.circle.fill")
        }
    }
    
    // MARK: - 選擇要顯示的種類 (照片、原況照片)
    
    func chooseUpdateType() {
        if (asset.mediaSubtypes.contains(.photoLive)) {
            updateLivePhoto()
        } else {
            updateImage()
        }
    }
    
    // MARK:  顯示照片
    func updateImage() {
        photosImageRequestOptions.deliveryMode = .highQualityFormat
        photosImageRequestOptions.isNetworkAccessAllowed = true
        
        imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: photosImageRequestOptions) { image, _ in
            guard let results = image else { return }
            self.photosDetailImage.image = results
            
            self.photosDetailImage.isHidden = false
            self.livePhotoView.isHidden = true
        }
    }
    
    // MARK: 顯示原況照片
    
    func updateLivePhoto() {
        livePhotoImageRequestOptions.deliveryMode = .highQualityFormat
        livePhotoImageRequestOptions.isNetworkAccessAllowed = true
        
        imageManager.requestLivePhoto(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: livePhotoImageRequestOptions) { livePhoto, info in
            guard let results = livePhoto else { return }
            self.livePhotoView.livePhoto = results
            
            self.photosDetailImage.isHidden = true
            self.livePhotoView.isHidden = false
            
            if (!self.isPlayingLivePhoto) {
                self.isPlayingLivePhoto = true
                self.livePhotoView.startPlayback(with: .full)
            }
        }
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension PhotosDetailViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            guard let details = changeInstance.changeDetails(for: asset) else { return }

            asset = details.objectAfterChanges as! PHAsset
            
            if (details.assetContentChanged) {
                chooseUpdateType()
            }
        }
    }
}

// MARK: - Live Photo View Delegate

extension PhotosDetailViewController: PHLivePhotoViewDelegate {
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        isPlayingLivePhoto = (playbackStyle == .full)
    }
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        isPlayingLivePhoto = (playbackStyle == .full)
    }
}
