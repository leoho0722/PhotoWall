//
//  SceneDelegate.swift
//  PhotoKit Demo
//
//  Created by Leo Ho on 2022/4/18.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    var blurEffect = UIBlurEffect()
    var blurEffectView = UIVisualEffectView()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        /* 純用 Xib 設計畫面要加下面這幾行，來指定第一個畫面 */
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let rootVC = PhotosViewController(nibName: "PhotosViewController", bundle: nil)
        let navigationController = UINavigationController(rootViewController: rootVC)
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        removeVisualEffectView() // 移除模糊化
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        
        addVisualEffectView() // 新增模糊化
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        addVisualEffectView() // 新增模糊化
    }
    
    func addVisualEffectView() {
        // 取得當前畫面的 UINavigationController
        guard let navigationController = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController as? UINavigationController else {
            return
        }
        
        // 取得最上層的 UIViewController
        guard let topViewController = navigationController.visibleViewController else {
            return
        }
        
        let width = topViewController.view.frame.width
        let height = topViewController.view.frame.height
        
        blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame.size = CGSize(width: width, height: height)
        
        topViewController.view.addSubview(blurEffectView)
    }
    
    func removeVisualEffectView() {
        // 取得當前畫面的 UINavigationController
        guard let navigationController = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController as? UINavigationController else {
            return
        }
        
        // 取得最上層的 UIViewController
        guard let topViewController = navigationController.visibleViewController else {
            return
        }
        
        // 如果 blurEffectView 是屬於最上層的 UIViewController.view
        // 就將 blurEffectView 移除
        if blurEffectView.isDescendant(of: topViewController.view) {
            blurEffectView.removeFromSuperview()
        }
    }
}
