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
            
            RU_Firebase.shared.start()
            _ = RU_Account.shared
            
            IQKeyboardManager.shared.isEnabled = true
            
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
            
            if let url = connectionOptions.urlContexts.first?.url {
                RU_WidgetDeepLinkHandler.handle(url)
            }
        }
	}

	public func sceneWillEnterForeground(_ scene: UIScene) {

        UIApplication.updateTabBarBadges()
		RU_WidgetBackgroundRefresh.schedule()
	}
    
    public func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        guard let url = URLContexts.first?.url else { return }
        
        if WidgetBookingDeepLink.bookingID(from: url) != nil {
            RU_WidgetDeepLinkHandler.handle(url)
            return
        }
        
        RU_Firebase.shared.handle(url)
    }
}

