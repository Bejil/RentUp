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
		
        if let windowScene = scene as? UIWindowScene {
            
            window = UIWindow(windowScene: windowScene)
            window?.backgroundColor = Colors.Background.Application
            
            let viewController:RU_Splashscreen_ViewController = .init()
            viewController.completion = { state in
                
                if state {
                    
                    UIApplication.setTabBarControllerAsRootViewController()
                }
                else {
                    
                    UIApplication.reset()
                }
            }
            window?.rootViewController = viewController
            window?.makeKeyAndVisible()
            
            IQKeyboardManager.shared.isEnabled = true
        }
	}

	public func sceneWillEnterForeground(_ scene: UIScene) {

        UIApplication.updateTabBarBadges()
	}
}

