//
//  SceneDelegate.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit
import IQKeyboardManagerSwift

public class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	public var window: UIWindow?

	public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
		guard let windowScene = (scene as? UIWindowScene) else { return }
		
		window = UIWindow(windowScene: windowScene)
		window?.backgroundColor = Colors.Background.Application
		
		let viewController:RU_Splashscreen_ViewController = .init()
		viewController.completion = { [weak self] state in
			
            if state {
                
                self?.setTabBarControllerAsRootViewController()
            }
            else {
                
                let controller:RU_Onboarding_Welcome_ViewController = .init()
                controller.completion = { [weak self] in
                    
                    self?.setTabBarControllerAsRootViewController()
                }
                self?.window?.rootViewController = controller
            }
		}
		window?.rootViewController = viewController
		window?.makeKeyAndVisible()
		
		IQKeyboardManager.shared.isEnabled = true
	}

	public func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
	}

	public func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
	}

	public func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
	}

	public func sceneWillEnterForeground(_ scene: UIScene) {
		// Called as the scene transitions from the background to the foreground.
		// Use this method to undo the changes made on entering the background.
	}

	public func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.
	}
    
    private func setTabBarControllerAsRootViewController() {
        
        window?.rootViewController = RU_TabBarController()
        
        if let window {
            
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {}, completion:nil)
        }
    }
}

