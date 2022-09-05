//
//  PhotosViewController.swift
//  PhotoKit Demo
//
//  Created by Leo Ho on 2022/4/18.
//

import UIKit
import Photos

class PhotosViewController: UIViewController {

    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var photosCollectionViewFlowLayout: UICollectionViewFlowLayout!
    
    // Photos 變數宣告
    var allPhotos: PHFetchResult<PHAsset>!
    
    let allPhotosOptions = PHFetchOptions() // 創建 PHFetchOptions 實例
    
    let photosImageRequestOptions = PHImageRequestOptions()
    
    let photoCacheImageManager = PHCachingImageManager() // 創建 PHCachingImageManager 實例
   
    var thumbnailSize: CGSize! // 縮圖大小
    
    var previousPreheatRect: CGRect = .zero
    
    // 每行、每列的個數
    var numOfRow: Int = 3
    
    var numOfColumn: Int = 3
    
    var itemIndexPath: IndexPath = []
    
    var availableWidth: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Photo Wall"
        
        resetCachedAssets() // 重設 PHAsset Cache
        
        setUpCollectionView() // 設定 CollectionView
                
        setupNavigationBarButtonItems() // 設定 NavigationBarButtonItem
        
        requirePhotosAccess() // 處理照片權限
        
        processPhotos() // 處理預設的照片顯示
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let scale = UIScreen.main.scale
        let cellSize = photosCollectionViewFlowLayout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let width = view.bounds.inset(by: view.safeAreaInsets).width
        // Adjust the item size if the available width has changed.
        if availableWidth != width {
            availableWidth = width
            let columnCount = (availableWidth / 80).rounded(.towardZero)
            let itemLength = (availableWidth - columnCount - 1) / columnCount
            photosCollectionViewFlowLayout.itemSize = CGSize(width: itemLength, height: itemLength)
        }
    }
    
    // MARK: - 設定 CollectionView
    
    func setUpCollectionView() {
        photosCollectionView.register(UINib(nibName: "PhotosCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: PhotosCollectionViewCell.identifier)
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        photosCollectionViewFlowLayout.estimatedItemSize = .zero // 設定 Cell 的大小由 itemSize 計算
    }
    
    // MARK: - 設定 NavigationBarButtonItem
    
    func setupNavigationBarButtonItems() {
        setUpNavigationLeftBarButtonItems()
        setUpNavigationRightBarButtonItems()
    }
    
    func setUpNavigationLeftBarButtonItems() {
        let reloadItem = UIBarButtonItem(image: UIImage(systemName: "arrow.counterclockwise"), style: .plain, target: self, action: #selector(reloadItemClicked))
        self.navigationItem.leftBarButtonItems = [reloadItem]
    }
    
    @objc func reloadItemClicked() {
        print("將照片牆重設回預設")
        let defaultPredicate = "self.mediaType==1 OR self.mediaType==2 OR self.mediaSubtypes==8 OR self.isFavorite==true OR self.isFavorite==false"
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotosOptions.predicate = NSPredicate(format: defaultPredicate)
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        photosCollectionView.reloadData()
    }
    
    func setUpNavigationRightBarButtonItems() {
        let filterMenu = UIMenu(children: [
            UIAction(title: "Favorites", image: UIImage(systemName: "heart.fill"), handler: { [self] action in
                allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                allPhotosOptions.predicate = NSPredicate(format: "self.isFavorite==true")
                allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
                photosCollectionView.reloadData()
            }),
            UIAction(title: "Not Favorited", image: UIImage(systemName: "heart"), handler: { [self] action in
                allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                allPhotosOptions.predicate = NSPredicate(format: "self.isFavorite==false")
                allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
                photosCollectionView.reloadData()
            }),
            UIAction(title: "Photos", image: UIImage(systemName: "photo"), handler: { [self] action in
                allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                allPhotosOptions.predicate = NSPredicate(format: "self.mediaType==1")
                allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
                photosCollectionView.reloadData()
            }),
            UIAction(title: "Live Photos", image: UIImage(systemName: "livephoto"), handler: { [self] action in
                allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                allPhotosOptions.predicate = NSPredicate(format: "self.mediaSubtypes==8")
                allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
                photosCollectionView.reloadData()
            }),
            UIAction(title: "Videos", image: UIImage(systemName: "video"), handler: { [self] action in
                allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                allPhotosOptions.predicate = NSPredicate(format: "self.mediaType==2")
                allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
                photosCollectionView.reloadData()
            })
        ])
        
        let filterItem = UIBarButtonItem.addPullDownButtonMenu(title: "", image: UIImage(systemName: "line.horizontal.3.decrease.circle.fill"), size: CGSize(width: 30, height: 30), menu: filterMenu)
        
        self.navigationItem.rightBarButtonItems = [filterItem]
    }
    
    // MARK: - 處理照片權限
    
    func requirePhotosAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            if (status == .authorized) {
                print("App can access User's Photos")
            } else {
                print("App can't access User's Photos")
            }
        }
    }
    
    // MARK: - 處理預設的照片顯示
    
    func processPhotos() {
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        PHPhotoLibrary.shared().register(self) // 註冊相簿變化的觀察
    }
    
    // MARK: - PHAsset Cache
    
    func resetCachedAssets() {
        photoCacheImageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The window you prepare ahead of time is twice the height of the visible rect.
        let visibleRect = CGRect(origin: photosCollectionView!.contentOffset, size: photosCollectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start and stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in
                photosCollectionView!.indexPathsForElements(in: rect)
            }
            .map { indexPath in
                allPhotos.object(at: indexPath.item)
            }
        let removedAssets = removedRects
            .flatMap { rect in
                photosCollectionView!.indexPathsForElements(in: rect)
            }
            .map { indexPath in
                allPhotos.object(at: indexPath.item)
            }
        
        // Update the assets the PHCachingImageManager is caching.
        photoCacheImageManager.startCachingImages(for: addedAssets,
                                                  targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        photoCacheImageManager.stopCachingImages(for: removedAssets,
                                                 targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        // Store the computed rectangle for future comparison.
        previousPreheatRect = preheatRect
    }
    
    func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    // MARK: - 建立 UIContextMenuConfiguration
    
    func createContextMenuConfiguration(identifier: Int, asset: PHAsset, previewMenu: UIMenu) -> UIContextMenuConfiguration {
        let configuration = UIContextMenuConfiguration(identifier: String(identifier) as NSCopying) { () -> UIViewController in
            return self.createPreviewUIViewController(asset: asset, size: CGSize(width: asset.pixelWidth, height: asset.pixelHeight))
        } actionProvider: { (element) -> UIMenu? in
            return previewMenu
        }
        return configuration
    }
    
    // MARK: - 建立 UIContextMenu 的 UIViewController
    
    func createPreviewUIViewController(asset: PHAsset, size: CGSize) -> UIViewController {
        #if DEBUG
        print("size.width: \(size.width), size.height: \(size.height)")
        #endif
        
        let controller = UIViewController()
        let imageView = UIImageView(frame: controller.view.bounds)
        imageView.contentMode = .scaleAspectFill
//        imageView.center = controller.view.center

        photosImageRequestOptions.deliveryMode = .highQualityFormat
        photosImageRequestOptions.resizeMode = .exact
        photosImageRequestOptions.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: photosImageRequestOptions) { image, _ in
            guard let results = image else { return }
            imageView.image = results
        }
                
        controller.view.addSubview(imageView)
                        
        controller.preferredContentSize = size
        
        return controller
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self) // 移除相簿變化的觀察
    }

}

// MARK: - PHPhotoLibraryChangeObserver

extension PhotosViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: allPhotos) else { return }
        DispatchQueue.main.sync {
            allPhotos = changes.fetchResultAfterChanges
            if (changes.hasIncrementalChanges) {
                guard let collectionView = photosCollectionView else { fatalError() }

                collectionView.performBatchUpdates({
                    if let removed = changes.removedIndexes, removed.count > 0 {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, inserted.count > 0 {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let changed = changes.changedIndexes, changed.count > 0 {
                        collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                }, completion: nil)
            } else {
                photosCollectionView.reloadData()
            }
            resetCachedAssets()
        }
    }
}

// MARK: - UIScrollViewDelegate

extension PhotosViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
}

// MARK: - UICollectionViewDelegate、UICollectionViewDataSource

extension PhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = allPhotos.object(at: indexPath.item)
        itemIndexPath = indexPath
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotosCollectionViewCell.identifier, for: indexPath) as? PhotosCollectionViewCell else {
            fatalError("Can't Load Photos CollectionView Cell!")
        }
        cell.representedAssetIdentifier = asset.localIdentifier
        photoCacheImageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .default, options: nil) { image, _ in
            if (cell.representedAssetIdentifier == asset.localIdentifier) {
                cell.smallImage = image
                cell.heartImage = asset.isFavorite ? "♥︎" : ""
                if (asset.mediaSubtypes == .photoLive) {
                    cell.sourceImage = UIImage(systemName: "livephoto")
                } else if (asset.mediaType == .image) {
                    cell.sourceImage = UIImage(systemName: "photo")
                } else if (asset.mediaType == .video) {
                    cell.sourceImage = UIImage(systemName: "video")
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nextVC = PhotosDetailViewController()
        nextVC.asset = allPhotos.object(at: indexPath.item)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        itemIndexPath = indexPath
        
        let identifier = indexPath.item
        
        let asset = allPhotos.object(at: indexPath.item)

        let previewMenu = UIMenu(children: [
            UIAction(title: asset.isFavorite ? "Cancel Favorite" : "Favorites",
                     image: asset.isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"),
                     handler: { action in
                         PHPhotoLibrary.shared().performChanges {
                             let request = PHAssetChangeRequest(for: asset)
                             request.isFavorite = !asset.isFavorite
                             print("該張照片修改後的收藏狀態：\(request.isFavorite)")
                         } completionHandler: { success, error in
                             DispatchQueue.main.async {
                                 if (success) {
                                     print("成功修改")
                                 } else {
                                     CustomAlert.shared.customAlert(title: "Can't Change Favorite Status！", message: "Error Message：\(String(describing: error?.localizedDescription))", vc: self, actionHandler: nil)
                                 }
                             }
                         }
                     }),
            UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { action in
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.deleteAssets([asset] as NSArray)
                } completionHandler: { success, error in
                    DispatchQueue.main.async {
                        if (success) {
                            CustomAlert.shared.customAlert(title: "Delete Success！", message: nil, vc: self, actionHandler: {
                                self.reloadItemClicked()
                            })
                        } else {
                            CustomAlert.shared.customAlert(title: "Delete Failed！", message: "Error Message：\(String(describing: error?.localizedDescription))", vc: self, actionHandler: nil)
                        }
                    }
                }
            })
        ])
        
        return createContextMenuConfiguration(identifier: identifier, asset: asset, previewMenu: previewMenu)
    }
    
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {

        let asset = allPhotos.object(at: itemIndexPath.item)
        
        if let _ = Int(configuration.identifier as! String) {
            animator.addCompletion {
                let previewVC = PhotosDetailViewController()
                previewVC.asset = asset
                self.show(previewVC, sender: nil)
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    
    // Cell 的寬高
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        photosCollectionViewFlowLayout.itemSize = CGSize(width: 80, height: 80) // 設定 Cell 的大小
//        return photosCollectionViewFlowLayout.itemSize
//    }

    // Cell 的上下間距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    // Cell 的左右間距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    // Cell 與 CollectionView 的間距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

// MARK: - 參考資料

/**
1. Browsing and Modifying Photo Albums
https://developer.apple.com/documentation/photokit/browsing_and_modifying_photo_albums
 
*/
