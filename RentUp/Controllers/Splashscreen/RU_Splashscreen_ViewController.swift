//
//  RU_Splashscreen_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 02/02/2026.
//

import UIKit

public class RU_Splashscreen_ViewController : RU_ViewController {
	
	public var completion:(()->Void)?
	
	public override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		setUpPlatforms()
	}
	
	private func setUpPlatforms() {
	
		RU_Alert_ViewController.presentLoading { [weak self] alertController in
			
			RU_Platform.setUp { [weak self] error in
				
				alertController?.close { [weak self] in
					
					if let error {
						
						RU_Alert_ViewController.present(error, handler: { [weak self] in
							
							self?.setUpPlatforms()
						})
					}
					else {
						
						self?.completion?()
					}
				}
			}
		}
	}
}
