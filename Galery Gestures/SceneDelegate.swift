//
//  SceneDelegate.swift
//  Galery Gestures
//
//  Created by Dmitro Levkutnyk on 15.06.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?


  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    let window = UIWindow(windowScene: windowScene)
    window.overrideUserInterfaceStyle = .dark
    self.window = window
    
    let rootVC = UINavigationController()
    rootVC.isNavigationBarHidden = true
    window.rootViewController = rootVC
    window.makeKeyAndVisible()
    
    let galleryVC = PhotoGridViewController()
        galleryVC.configure(with: [UIImage(named: "test1")!, UIImage(named: "test2")!, UIImage(named: "test3")!, UIImage(named: "test4")!, UIImage(named: "test5")!, UIImage(named: "test6")!, UIImage(named: "test7")!, UIImage(named: "test8")!, UIImage(named: "test9")!, UIImage(named: "test10")!])
    rootVC.setViewControllers([galleryVC], animated: false)
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
  }

  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }


}

