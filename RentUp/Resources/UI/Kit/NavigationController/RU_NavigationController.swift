//
//  RU_NavigationController.swift
//  LettroLine
//
//  Created by BLIN Michael on 11/02/2025.
//

import UIKit

public class RU_NavigationController : UINavigationController {

	public override func loadView() {
		
		super.loadView()
		
		navigationBar.prefersLargeTitles = true
		
		let buttonAttributes: [NSAttributedString.Key: Any] = [.font: Fonts.Navigation.Button as Any, .foregroundColor: Colors.Navigation.Button as Any]
		let largeTitleTextAttributes: [NSAttributedString.Key: Any] = [.font: Fonts.Navigation.Title.Large as Any, .foregroundColor: Colors.Navigation.Title as Any]
		let titleAttributes: [NSAttributedString.Key: Any] = [.font: Fonts.Navigation.Title.Small as Any, .foregroundColor: Colors.Navigation.Title as Any]
		
		let scrollEdgeAppearance = UINavigationBarAppearance()
		scrollEdgeAppearance.configureWithTransparentBackground()
		scrollEdgeAppearance.largeTitleTextAttributes = largeTitleTextAttributes
		scrollEdgeAppearance.titleTextAttributes = titleAttributes
		scrollEdgeAppearance.buttonAppearance.normal.titleTextAttributes = buttonAttributes
		
		let standardAppearance = UINavigationBarAppearance()
		standardAppearance.configureWithTransparentBackground()
		standardAppearance.titleTextAttributes = titleAttributes
		standardAppearance.buttonAppearance.normal.titleTextAttributes = buttonAttributes
		
		navigationBar.tintColor = Colors.Navigation.Button
		navigationBar.standardAppearance = standardAppearance
		navigationBar.compactAppearance = standardAppearance
		navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
	}
}
