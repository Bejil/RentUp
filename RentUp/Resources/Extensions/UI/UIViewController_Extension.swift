//
//  UIViewController_Extension.swift
//  LettroLine
//
//  Created by BLIN Michael on 13/02/2025.
//

import UIKit

extension UIViewController {
	
	func topMostViewController() -> UIViewController {
		
		if let presented = self.presentedViewController {
			
			return presented.topMostViewController()
		}
		
		if let navigation = self as? UINavigationController {
			
			return navigation.visibleViewController?.topMostViewController() ?? navigation
		}
		
		if let tab = self as? UITabBarController {
			
			return tab.selectedViewController?.topMostViewController() ?? tab
		}
		
		return self
	}
}
