//
//  UIApplication_Extension.swift
//  LettroLine
//
//  Created by BLIN Michael on 13/02/2025.
//

import UIKit

extension UIApplication {
	
	public static var isDebug:Bool {
		
		var state = false
		
#if DEBUG
		state = true
#endif
		
		return state
	}
	
	public func topMostViewController() -> UIViewController? {
		
		return UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }.first { $0.rootViewController != nil }?.rootViewController?.topMostViewController()
	}
	
	public static func wait(_ delay:Double = 0.3, _ completion:(()->Void)?) {
		
		DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
			
			completion?()
		}
	}
}
