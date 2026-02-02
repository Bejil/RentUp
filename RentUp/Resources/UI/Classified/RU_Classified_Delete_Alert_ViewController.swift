//
//  RU_Classified_Delete_Alert_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 22/01/2026.
//

import UIKit

public class RU_Classified_Delete_Alert_ViewController : RU_Alert_ViewController {
	
	public var classified:RU_Classified?
	public var deleteCompletion:(()->Void)?
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = String(key: "settings.classified.delete.alert.title")
		add(String(key: "settings.classified.delete.alert.content"))
		let deleteButton = addButton(title: String(key: "settings.classified.delete.alert.button")) { [weak self] button in
			
			button?.isLoading = true
			
			self?.classified?.delete { [weak self] error in
				
				button?.isLoading = false
				
				self?.close { [weak self] in
					
					if let error {
						
						RU_Alert_ViewController.present(error)
					}
					else {
						
						NotificationCenter.post(.updateClassifieds)
						self?.deleteCompletion?()
					}
				}
			}
		}
		deleteButton.image = UIImage(systemName: "trash")
		deleteButton.type = .delete
		addCancelButton()
	}
	
	@MainActor required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
