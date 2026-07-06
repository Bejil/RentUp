//
//  RU_TabBarController.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit
import SnapKit

public class RU_TabBarController : UITabBarController {
	
	public enum Indexes : CaseIterable {
		
		case Home
        case Bookings
		case Reporting
		case Classifieds
		case Settings
	}
	
	private let injectedNavigationControllers: [UINavigationController]?
	
	public init(navigationControllers: [RU_TabBarController.Indexes: RU_NavigationController]) {
		injectedNavigationControllers = Indexes.allCases.compactMap { navigationControllers[$0] }
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		injectedNavigationControllers = nil
		super.init(coder: coder)
	}
	
	public convenience override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		self.init(navigationControllers: RU_AppSectionFactory.makeAllNavigationControllers())
	}

	public override func loadView() {
		
		super.loadView()
        
		let appearance = UITabBarAppearance()
		appearance.configureWithOpaqueBackground()
        
        let normalAttributes:[NSAttributedString.Key: Any] = [.font: Fonts.TabBar.Default]
        let selectedAttributes:[NSAttributedString.Key: Any] = [.foregroundColor : Colors.TabBar.Selected, .font: Fonts.TabBar.Selected]
        let selectedColor: UIColor = Colors.TabBar.Selected
        let badgeColor: UIColor = Colors.TabBar.Badge
		
		appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.compactInlineLayoutAppearance.normal.badgeBackgroundColor = badgeColor
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes
		appearance.compactInlineLayoutAppearance.selected.iconColor = selectedColor
        appearance.compactInlineLayoutAppearance.selected.badgeBackgroundColor = badgeColor
        
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.inlineLayoutAppearance.normal.badgeBackgroundColor = badgeColor
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.inlineLayoutAppearance.selected.iconColor = selectedColor
        appearance.inlineLayoutAppearance.selected.badgeBackgroundColor = badgeColor
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.normal.badgeBackgroundColor = badgeColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.badgeBackgroundColor = badgeColor

		tabBar.standardAppearance = appearance
		tabBar.scrollEdgeAppearance = appearance
		
		if let injectedNavigationControllers {
			viewControllers = injectedNavigationControllers
		} else {
			viewControllers = Indexes.allCases.map {
				RU_AppSectionFactory.navigationController(for: $0)
			}
		}
		
		delegate = self
	}
	
	override public var childForStatusBarStyle: UIViewController? {
		
		return self.selectedViewController
	}
}

extension RU_TabBarController : UITabBarControllerDelegate {
	
	public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		
        RU_Feedback.shared.make(.On)
		
		return true
	}
}

