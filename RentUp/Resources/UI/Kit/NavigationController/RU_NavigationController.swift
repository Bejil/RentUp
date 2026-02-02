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
		
		let appearance = UINavigationBarAppearance()
		appearance.configureWithTransparentBackground()
		
		let largeTitleTextAttributes: [NSAttributedString.Key: Any] = [.font: Fonts.Navigation.Title.Large as Any, .foregroundColor: Colors.Navigation.Title as Any]
		appearance.largeTitleTextAttributes = largeTitleTextAttributes
		
		let titleAttributes: [NSAttributedString.Key: Any] = [.font: Fonts.Navigation.Title.Small as Any, .foregroundColor: Colors.Navigation.Title as Any]
		appearance.titleTextAttributes = titleAttributes
		
		let buttonAttributes: [NSAttributedString.Key: Any] = [.font: Fonts.Navigation.Button as Any, .foregroundColor: Colors.Navigation.Button as Any]
		appearance.buttonAppearance.normal.titleTextAttributes = buttonAttributes
		
		UINavigationBar.appearance().tintColor = Colors.Navigation.Button
		UINavigationBar.appearance().standardAppearance = appearance
		UINavigationBar.appearance().compactAppearance = appearance
		UINavigationBar.appearance().scrollEdgeAppearance = appearance
	}
}
