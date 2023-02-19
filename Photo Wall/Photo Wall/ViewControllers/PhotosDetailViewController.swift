//
//  PhotosDetailViewController.swift
//  Photo Wall
//
//  Created by Leo Ho on 2022/2/14.
//

import UIKit
import Photos
import PhotosUI
import AVKit

class PhotosDetailViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var ivPhotos: UIImageView!
    @IBOutlet weak var livePhotoView: PHLivePhotoView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    // MARK: - Variables
    
    // Photos 變數宣告
    var asset: PHAsset!
    let photosImageRequestOptions = PHImageRequestOptions()
    let livePhotoImageRequestOptions = PHLivePhotoRequestOptions()
    let videoRequestOptions = PHVideoRequestOptions()
    let imageManager = PHImageManager.default()
    let assetResource = PHAssetResource()
    
    // AVPlayer 變數宣告
    var avPlayerLayer: AVPlayerLayer!
    
    var isPlayingLivePhoto: Bool = false
    var isPlayingVideo: Bool = false
    
    // UIBarButtonItem
    var favoriteItem = UIBarButtonItem()
    var playItem = UIBarButtonItem()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("該張的收藏狀態：\(asset.isFavorite)")
        print("該張的 mediaType：\(asset.mediaType.rawValue), mediaSubtypes：\(asset.mediaSubtypes)")
        print("該張的檔名：\(asset.fileName)")
        
        title = "\(asset.fileName)"
        
        PHPhotoLibrary.shared().register(self) // 註冊相簿變化的觀察
        
        livePhotoView.delegate = self // 將 PHLivePhotoView 的委任指派給 PhotosDetailViewController
        
        setupUI()
        
        chooseUpdateType() // 判斷是 Image 還是 Live Photo，來決定要用哪種 Update Func
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(videoHasPlayedDone),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil) // 監聽影片是否已經播放完成了
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self) // 移除相簿變化的觀察
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        setUpSwipeGesture()
        setupNavigationBarButtonItem()
        
        if asset.mediaType == .image {
            // 隱藏中間的播放鍵
            setupToolBar(isPlayHidden: true)
        } else if asset.mediaType == .video {
            // 顯示中間的播放鍵
            setupToolBar(isPlayHidden: false)
        }
    }
    
    /// 下滑手勢回照片牆
    private func setUpSwipeGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self,
                                                    action: #selector(popToPreviousPage))
        swipeGesture.direction = .down
        swipeGesture.numberOfTouchesRequired = 1
        swipeGesture.location(in: self.view)
        self.view.addGestureRecognizer(swipeGesture)
    }
    
    @objc func popToPreviousPage() {
        dismiss(animated: true)
    }
    
    /// 設定 UINavigationBarButtonItem
    private func setupNavigationBarButtonItem() {
        let shareItem = UIBarButtonItem(icon: .share,
                                        target: self,
                                        action: #selector(shareItemClicked))
        self.navigationItem.rightBarButtonItems = [shareItem]
    }
    
    @objc func shareItemClicked() {
        let activityItems = [assetResource.getPHAssetURL(asset: asset)]
        let activityVC = UIActivityViewController(activityItems: activityItems,
                                                  applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    /// 設定 UIToolBar
    private func setupToolBar(isPlayHidden: Bool) {
        favoriteItem = UIBarButtonItem(icon: asset.isFavorite ? .favorite : .nonFavorite,
                                       target: self,
                                       action: #selector(favoriteItemClicked))
        
        playItem = UIBarButtonItem(icon: .play,
                                   target: self,
                                   action: #selector(playItemClicked))
        
        let deleteItem = UIBarButtonItem(icon: .trash,
                                         target: self,
                                         action: #selector(deleteItemClicked))
        deleteItem.tintColor = .systemRed
        
        let flexSpace = UIBarButtonItem(systemItem: .flexibleSpace)
        
        if isPlayHidden {
            // 收藏、刪除
            toolbar.items = [favoriteItem, flexSpace, deleteItem]
        } else {
            // 收藏、播放、刪除
            toolbar.items = [favoriteItem, flexSpace, playItem, flexSpace, deleteItem]
        }
    }
    
    @objc func favoriteItemClicked() {
        print("按下收藏鍵")
        Task {
            do {
                try await PHPhotoLibrary.shared().performChanges {
                    let request = PHAssetChangeRequest(for: self.asset)
                    request.isFavorite = !self.asset.isFavorite
                    print("該張照片修改後的收藏狀態：\(request.isFavorite)")
                }
                let favoriteImage = UIImage(icon: .favorite)
                let nonFavoriteImage = UIImage(icon: .nonFavorite)
                self.favoriteItem.image = !self.asset.isFavorite ? favoriteImage : nonFavoriteImage
            } catch {
                Alert.showAlertWith(title: transalte(.changeFavoriteStatusFailed),
                                    message: error.localizedDescription,
                                    vc: self,
                                    confirmTitle: transalte(.confitm),
                                    confirm: nil)
            }
        }
    }
    
    @objc func playItemClicked() {
        print("按下播放鍵")
        if let avPlayerLayer {
            if avPlayerLayer.player?.timeControlStatus == .paused {
                DispatchQueue.main.async {
                    self.avPlayerLayer.player?.play()
                    self.playItem.image = UIImage(icon: .stop)
                }
            } else if avPlayerLayer.player?.timeControlStatus == .playing {
                DispatchQueue.main.async {
                    self.avPlayerLayer.player?.pause()
                    self.playItem.image = UIImage(icon: .play)
                }
            }
        } else {
            self.playItem.image = UIImage(icon: .stop)
            
            videoRequestOptions.deliveryMode = .highQualityFormat
            videoRequestOptions.isNetworkAccessAllowed = true
            
            imageManager.requestPlayerItem(forVideo: asset,
                                           options: videoRequestOptions) { playerItem, info in
                DispatchQueue.main.async {
                    guard self.avPlayerLayer == nil else { return }
                    let player = AVPlayer(playerItem: playerItem)
                    let playerLayer = AVPlayerLayer(player: player)
                    playerLayer.videoGravity = AVLayerVideoGravity.resize
                    playerLayer.frame = self.ivPhotos.layer.bounds
                    self.ivPhotos.layer.addSublayer(playerLayer)
                    player.play()
                    self.avPlayerLayer = playerLayer
                }
            }
        }
    }
    
    @objc func deleteItemClicked() {
        print("按下刪除鍵")
        // 刪除單一照片
        Task {
            do {
                try await PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.deleteAssets([self.asset!] as NSArray)
                }
                await MainActor.run {
                    PHPhotoLibrary.shared().unregisterChangeObserver(self)
                    Alert.showAlertWith(title: transalte(.deleteSuccess),
                                        message: nil,
                                        vc: self,
                                        confirmTitle: transalte(.confitm)) {
                        self.dismiss(animated: true)
                    }
                }
            } catch {
                Alert.showAlertWith(title: transalte(.deleteFailed),
                                    message: error.localizedDescription,
                                    vc: self,
                                    confirmTitle: transalte(.confitm),
                                    confirm: nil)
            }
        }
    }
    
    /// 監聽影片是否已經播放完畢
    @objc func videoHasPlayedDone(notification: NSNotification) {
        print("影片已經播放完了")
        DispatchQueue.main.async {
            self.avPlayerLayer = nil
            self.playItem.image = UIImage(icon: .play)
        }
    }
    
    /// 選擇要顯示的種類 (照片、原況照片)
    func chooseUpdateType() {
        if asset.mediaSubtypes.contains(.photoLive) {
            updateLivePhoto()
        } else {
            updateImage()
        }
    }
    
    /// 顯示照片
    func updateImage() {
        photosImageRequestOptions.deliveryMode = .highQualityFormat
        photosImageRequestOptions.isNetworkAccessAllowed = true
        
        imageManager.requestImage(for: asset,
                                  targetSize: PHImageManagerMaximumSize,
                                  contentMode: .aspectFit,
                                  options: photosImageRequestOptions) { image, _ in
            guard let results = image else { return }
            self.ivPhotos.image = results
            
            self.ivPhotos.isHidden = false
            self.livePhotoView.isHidden = true
        }
    }
    
    /// 顯示原況照片
    func updateLivePhoto() {
        livePhotoImageRequestOptions.deliveryMode = .highQualityFormat
        livePhotoImageRequestOptions.isNetworkAccessAllowed = true
        
        imageManager.requestLivePhoto(for: asset,
                                      targetSize: PHImageManagerMaximumSize,
                                      contentMode: .aspectFit,
                                      options: livePhotoImageRequestOptions) { livePhoto, info in
            guard let results = livePhoto else { return }
            self.livePhotoView.livePhoto = results
            
            self.ivPhotos.isHidden = true
            self.livePhotoView.isHidden = false
            
            if !self.isPlayingLivePhoto {
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
            
            asset = details.objectAfterChanges!
            
            if details.assetContentChanged {
                chooseUpdateType()
            }
        }
    }
}

// MARK: - PHLivePhotoViewDelegate

extension PhotosDetailViewController: PHLivePhotoViewDelegate {
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView,
                       willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        isPlayingLivePhoto = (playbackStyle == .full)
    }
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView,
                       didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        isPlayingLivePhoto = (playbackStyle == .full)
    }
}
