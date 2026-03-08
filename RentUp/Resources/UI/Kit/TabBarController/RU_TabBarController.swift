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
		case Reporting
		case Bookings
		case Classifieds
		case Settings
	}
	
	private lazy var indicatorView:UIView = {
		
		$0.backgroundColor = Colors.TabBar.Item.Selected
		$0.isUserInteractionEnabled = false
		$0.snp.makeConstraints { (make) in
			make.height.equalTo(3)
		}
		
		return $0
		
	}(UIView())
	
	public override func loadView() {
		
		super.loadView()
		
		tabBar.isOpaque = true
		
		let appearance = UITabBarAppearance()
		appearance.configureWithDefaultBackground()
		
		appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = [.font: Fonts.TabBar.Default]
		appearance.compactInlineLayoutAppearance.normal.badgeBackgroundColor = Colors.TabBar.Badge
		appearance.compactInlineLayoutAppearance.selected.iconColor = Colors.TabBar.Item.Selected
		appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor : Colors.TabBar.Item.Selected, .font: Fonts.TabBar.Selected]

		appearance.inlineLayoutAppearance.normal.badgeBackgroundColor = Colors.TabBar.Badge
		appearance.inlineLayoutAppearance.normal.iconColor = appearance.compactInlineLayoutAppearance.normal.iconColor
		appearance.inlineLayoutAppearance.normal.titleTextAttributes = appearance.compactInlineLayoutAppearance.normal.titleTextAttributes
		appearance.inlineLayoutAppearance.selected.iconColor = appearance.compactInlineLayoutAppearance.selected.iconColor
		appearance.inlineLayoutAppearance.selected.titleTextAttributes = appearance.compactInlineLayoutAppearance.selected.titleTextAttributes
		
		appearance.stackedLayoutAppearance.normal.badgeBackgroundColor = Colors.TabBar.Badge
		appearance.stackedLayoutAppearance.normal.iconColor = appearance.compactInlineLayoutAppearance.normal.iconColor
		appearance.stackedLayoutAppearance.normal.titleTextAttributes = appearance.compactInlineLayoutAppearance.normal.titleTextAttributes
		appearance.stackedLayoutAppearance.selected.iconColor = appearance.compactInlineLayoutAppearance.selected.iconColor
		appearance.stackedLayoutAppearance.selected.titleTextAttributes = appearance.compactInlineLayoutAppearance.selected.titleTextAttributes
		
		tabBar.standardAppearance = appearance
		tabBar.scrollEdgeAppearance = tabBar.standardAppearance
		tabBar.tintColor = .white
		tabBar.isOpaque = true
		
		viewControllers = Indexes.allCases.compactMap({
			
			switch $0 {
			case .Home:
				RU_Home_ViewController()
			case .Reporting:
				RU_Reporting_ViewController()
			case .Bookings:
				RU_Bookings_ViewController()
			case .Classifieds:
				RU_Classifieds_ViewController()
			case .Settings:
				RU_Settings_ViewController()
			}
		}).compactMap({
			
			RU_NavigationController(rootViewController: $0)
		})
		
		delegate = self
		
		tabBar.addSubview(indicatorView)
		
		indicatorView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(0)
			make.width.equalTo(0)
			make.top.equalTo(tabBar.snp.top)
		}
		
		UIApplication.wait { [weak self] in
			
			self?.selectedIndex = 0
		}
	}
	
	public func select(_ index:Indexes) {
		
		if let tabIndex = RU_TabBarController.Indexes.allCases.firstIndex(of: index) {
			
			selectedIndex = tabIndex
		}
	}
	
	public override var selectedIndex: Int {
		
		didSet {
			
			selectIndex(selectedIndex)
		}
	}
	
	override public var childForStatusBarStyle: UIViewController? {
		
		return self.selectedViewController
	}
	
	public func view(atIndex index:Int) -> UIView? {
		
		let items = tabBar.subviews.filter({ $0.isUserInteractionEnabled }).sorted(by: { $0.frame.origin.x < $1.frame.origin.x })
		return items.count > index ? items[index] : nil
	}
	
	private func selectIndex(_ index:Int) {
		
		if indicatorView.superview != nil, let subview = view(atIndex: index), let imageView = subview.subviews.compactMap({ $0 as? UIImageView }).first {
			
			RU_Feedback.shared.make(.On)
			imageView.pulse(Colors.TabBar.Item.Selected)
			
			UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut) {
				
				self.indicatorView.snp.updateConstraints { (make) in
					make.left.equalToSuperview().inset(subview.frame.origin.x + imageView.frame.origin.x - (UI.Margins / 2))
					make.width.equalTo(imageView.frame.size.width + UI.Margins)
				}
				self.tabBar.layoutIfNeeded()
			}
		}
	}
}

extension RU_TabBarController : UITabBarControllerDelegate {
	
	public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		
		if let index = viewControllers?.firstIndex(of: viewController) {
			
			RU_Feedback.shared.make(.On)
			selectIndex(index)
		}
		
		return true
	}
}
