//
//  SceneDelegate.swift
//  MapX
//
//  Created by Piyush Kant on 2021/05/19.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window?.overrideUserInterfaceStyle = .light
        
        openSDKSelectionVC(windowScene: windowScene)
        
//        window = UIWindow(windowScene: windowScene)
//        window?.rootViewController = SDKSelectionTableViewController() //NavSelectionViewController()
//        window?.overrideUserInterfaceStyle = .light
//        window?.makeKeyAndVisible()
    }
    
    func openSDKSelectionVC(windowScene: UIWindowScene) {
        window = UIWindow(windowScene: windowScene)
        let sdkSelectionVC = SDKSelectionTableViewController()
        window?.rootViewController = UINavigationController(rootViewController: sdkSelectionVC)
        window?.makeKeyAndVisible()
    }
}

