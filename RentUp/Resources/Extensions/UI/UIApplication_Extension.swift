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
    
    public static func reset() {
        
        UserDefaults.reset()
        
        UIApplication.presentWelcome()
    }
    
    public static func presentWelcome() {
        
        let connectedScenes = UIApplication.shared.connectedScenes
        let windowScene = connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        let window = windowScene?.keyWindow
        (window?.rootViewController as? RU_TabBarController)?.viewControllers?.forEach { $0.tabBarItem.badgeValue = nil }
        
        let controller:RU_Onboarding_Welcome_ViewController = .init()
        controller.completion = {
            
            UIApplication.setTabBarControllerAsRootViewController()
        }
        window?.rootViewController = controller
    }
    
    public static func setTabBarControllerAsRootViewController() {
        
        let connectedScenes = UIApplication.shared.connectedScenes
        let windowScene = connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        let window = windowScene?.keyWindow
        window?.rootViewController = RU_TabBarController()
        
        updateTabBarBadges()
    }
    
    public static func updateTabBarBadges() {
        
        let connectedScenes = UIApplication.shared.connectedScenes
        let windowScene = connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        let window = windowScene?.keyWindow
        
        if let tabBarController = window?.rootViewController as? RU_TabBarController {
            
            tabBarController.viewControllers?.forEach { $0.tabBarItem.badgeValue = nil }
            
            RU_Booking.getAll { _, bookings in
                
                if !(bookings?.isEmpty ?? true) {
                    
                    let calendar = Calendar.current
                    let now = Date()
                    let thresholdDate = calendar.date(byAdding: .day, value: 5, to: now) ?? now
                    let hasCurrentBooking = bookings?.current != nil
                    let hasUpcomingBookingWithin5Days = (bookings?.contains(where: { $0.status == .upcoming && $0.dates.start <= thresholdDate }) ?? false)
                    let hasUpcomingHolidayWithin60Days = Date().nextUpcomingHolidayOpportunity(withinDays: 60) != nil
                    var indexesToBadge = Set<RU_TabBarController.Indexes>()
                    
                    if hasCurrentBooking || hasUpcomingBookingWithin5Days || hasUpcomingHolidayWithin60Days {
                        
                        indexesToBadge.insert(.Home)
                    }
                    
                    for index in indexesToBadge {
                        
                        if let tabIndex = RU_TabBarController.Indexes.allCases.firstIndex(where: { $0 == index }), tabIndex < (tabBarController.viewControllers?.count ?? 0) {
                            
                            tabBarController.viewControllers?[tabIndex].tabBarItem.badgeValue = "!"
                        }
                    }
                }
            }
        }
    }
}
