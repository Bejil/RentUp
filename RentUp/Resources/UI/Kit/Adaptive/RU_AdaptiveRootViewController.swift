//
//  RU_AdaptiveRootViewController.swift
//  RentUp
//

import UIKit
import SnapKit

public final class RU_AdaptiveRootViewController: UIViewController {
	
	private let navigationControllers = RU_AppSectionFactory.makeAllNavigationControllers()
	private var selectedSection: RU_TabBarController.Indexes = .Home
	
	private var embeddedTabBarController: RU_TabBarController?
	private var embeddedSplitViewController: UISplitViewController?
	private var sidebarViewController: RU_SidebarViewController?
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = Colors.Background.Application
		installAppropriateContainer(animated: false)
		
		registerForTraitChanges([UITraitHorizontalSizeClass.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
			
			guard self.traitCollection.horizontalSizeClass != previousTraitCollection.horizontalSizeClass else { return }
			self.installAppropriateContainer(animated: true)
		}
	}
	
	public func selectSection(
		_ section: RU_TabBarController.Indexes,
		animated: Bool = true,
		configureNavigation: ((RU_NavigationController) -> Void)? = nil
	) {
		selectedSection = section
		
		if let embeddedTabBarController {
			embeddedTabBarController.selectedIndex = section.tabIndex
		}
		
		if let embeddedSplitViewController {
			embeddedSplitViewController.setViewController(navigationControllers[section], for: .secondary)
			sidebarViewController?.selectSection(section, animated: animated)
			enforceFixedSidebarLayout(on: embeddedSplitViewController)
		}
		
		if let navigationController = navigationControllers[section] {
			configureNavigation?(navigationController)
		}
	}
	
	public func updateBadges(_ sections: Set<RU_TabBarController.Indexes>) {
		sidebarViewController?.updateBadges(sections)
		
		for section in RU_TabBarController.Indexes.allCases {
			navigationControllers[section]?.tabBarItem.badgeValue = sections.contains(section) ? "!" : nil
		}
	}
	
	public func navigationController(for section: RU_TabBarController.Indexes) -> RU_NavigationController? {
		navigationControllers[section]
	}
	
	private func installAppropriateContainer(animated: Bool) {
		if traitCollection.isRegularWidth {
			guard embeddedSplitViewController == nil else { return }
			installSplitView(animated: animated)
		} else {
			guard embeddedTabBarController == nil else { return }
			installTabBar(animated: animated)
		}
	}
	
	private func installTabBar(animated: Bool) {
		removeEmbeddedContainer()
		
		let tabBar = RU_TabBarController(navigationControllers: navigationControllers)
		tabBar.selectedIndex = selectedSection.tabIndex
		embeddedTabBarController = tabBar
		
		embed(tabBar, animated: animated)
	}
	
	private func installSplitView(animated: Bool) {
		removeEmbeddedContainer()
		
		let sidebar = RU_SidebarViewController()
		sidebar.delegate = self
		sidebar.selectSection(selectedSection, animated: false)
		sidebarViewController = sidebar
		
		let sidebarNavigationController = RU_NavigationController(rootViewController: sidebar)
		sidebarNavigationController.navigationBar.prefersLargeTitles = false
		sidebarNavigationController.setNavigationBarHidden(true, animated: false)
		
		let split = UISplitViewController(style: .doubleColumn)
		configureFixedSidebar(split)
		split.setViewController(sidebarNavigationController, for: .primary)
		split.setViewController(navigationControllers[selectedSection], for: .secondary)
		split.delegate = self
		embeddedSplitViewController = split
		embeddedTabBarController = nil
		
		embed(split, animated: animated)
		enforceFixedSidebarLayout(on: split)
	}
	
	private func configureFixedSidebar(_ split: UISplitViewController) {
		let width = UI.SidebarWidth
		split.preferredSplitBehavior = .displace
		split.preferredDisplayMode = .oneBesideSecondary
		split.displayModeButtonVisibility = .never
		split.presentsWithGesture = false
		split.preferredPrimaryColumnWidth = width
		split.minimumPrimaryColumnWidth = width
		split.maximumPrimaryColumnWidth = width
		split.primaryBackgroundStyle = .sidebar
	}
	
	private func enforceFixedSidebarLayout(on split: UISplitViewController) {
		split.preferredDisplayMode = .oneBesideSecondary
		if split.displayMode != .oneBesideSecondary {
			split.show(.primary)
		}
	}
	
	private func removeEmbeddedContainer() {
		children.forEach { child in
			child.willMove(toParent: nil)
			child.view.removeFromSuperview()
			child.removeFromParent()
		}
		embeddedTabBarController = nil
		embeddedSplitViewController = nil
	}
	
	private func embed(_ child: UIViewController, animated: Bool) {
		addChild(child)
		view.addSubview(child.view)
		child.view.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		child.didMove(toParent: self)
		
		guard animated else { return }
		child.view.alpha = 0
		UIView.animate(withDuration: 0.2) {
			child.view.alpha = 1
		}
	}
	
	override public var childForStatusBarStyle: UIViewController? {
		embeddedSplitViewController?.viewControllers.last ?? embeddedTabBarController?.selectedViewController
	}
}

extension RU_AdaptiveRootViewController: RU_SidebarViewControllerDelegate {
	
	func sidebarViewController(_ controller: RU_SidebarViewController, didSelect section: RU_TabBarController.Indexes) {
		selectedSection = section
		embeddedSplitViewController?.setViewController(navigationControllers[section], for: .secondary)
		if let split = embeddedSplitViewController {
			enforceFixedSidebarLayout(on: split)
		}
		if section == .Home {
			let home = navigationControllers[.Home]?.viewControllers.first as? RU_Home_ViewController
			home?.handleTabReselect()
		}
	}
}

extension RU_AdaptiveRootViewController: UISplitViewControllerDelegate {
	
	public func splitViewController(
		_ splitViewController: UISplitViewController,
		willChangeTo displayMode: UISplitViewController.DisplayMode
	) {
		handleSplitViewLayoutChange(splitViewController)
	}
	
	public func splitViewController(_ splitViewController: UISplitViewController, willHide column: UISplitViewController.Column) {
		handleSplitViewLayoutChange(splitViewController)
	}
	
	public func splitViewController(_ splitViewController: UISplitViewController, willShow column: UISplitViewController.Column) {
		handleSplitViewLayoutChange(splitViewController)
	}
	
	public func splitViewControllerDidCollapse(_ splitViewController: UISplitViewController) {
		handleSplitViewLayoutChange(splitViewController)
	}
	
	public func splitViewControllerDidExpand(_ splitViewController: UISplitViewController) {
		handleSplitViewLayoutChange(splitViewController)
	}
	
	private func handleSplitViewLayoutChange(_ splitViewController: UISplitViewController) {
		enforceFixedSidebarLayout(on: splitViewController)
		notifySplitViewLayoutDidChange()
	}
	
	private func notifySplitViewLayoutDidChange() {
		DispatchQueue.main.async {
			NotificationCenter.default.post(name: .splitViewLayoutDidChange, object: nil)
		}
	}
}
