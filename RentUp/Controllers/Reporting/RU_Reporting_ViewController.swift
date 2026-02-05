//
//  RU_Reporting_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 04/02/2026.
//

import UIKit

public class RU_Reporting_ViewController : RU_ViewController {
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		tabBarItem = .init(title: String(key: "tabbar.reporting"), image: UIImage(systemName: "square.grid.2x2"), tag: RU_TabBarController.Indexes.allCases.firstIndex(of: .Reporting) ?? 0)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func loadView() {
		
		super.loadView()
		
		navigationItem.title = String(key: "reporting.title")
	}
}
