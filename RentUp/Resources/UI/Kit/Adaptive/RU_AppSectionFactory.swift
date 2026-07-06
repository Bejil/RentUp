//
//  RU_AppSectionFactory.swift
//  RentUp
//

import UIKit

enum RU_AppSectionFactory {
	
	static func rootViewController(for section: RU_TabBarController.Indexes) -> RU_ViewController {
		switch section {
		case .Home:
			RU_Home_ViewController()
		case .Bookings:
			RU_Bookings_CalendarTab_ViewController()
		case .Reporting:
			RU_Reporting_ViewController()
		case .Classifieds:
			RU_Classifieds_ViewController()
		case .Settings:
			RU_Settings_ViewController()
		}
	}
	
	static func navigationController(for section: RU_TabBarController.Indexes) -> RU_NavigationController {
		RU_NavigationController(rootViewController: rootViewController(for: section))
	}
	
	static func makeAllNavigationControllers() -> [RU_TabBarController.Indexes: RU_NavigationController] {
		var controllers: [RU_TabBarController.Indexes: RU_NavigationController] = [:]
		for section in RU_TabBarController.Indexes.allCases {
			controllers[section] = navigationController(for: section)
		}
		return controllers
	}
}

extension RU_TabBarController.Indexes {
	
	var tabIndex: Int {
		Self.allCases.firstIndex(of: self) ?? 0
	}
	
	var title: String {
		switch self {
		case .Home: return String(key: "tabbar.home")
		case .Bookings: return String(key: "tabbar.bookings")
		case .Reporting: return String(key: "tabbar.reporting")
		case .Classifieds: return String(key: "tabbar.classifieds")
		case .Settings: return String(key: "tabbar.settings")
		}
	}
	
	var symbolName: String {
		switch self {
		case .Home: return "flame"
		case .Bookings: return "calendar"
		case .Reporting: return "chart.bar"
		case .Classifieds: return "house"
		case .Settings: return "gearshape"
		}
	}
}
