//
//  RU_Booking_Delete_Alert_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 22/01/2026.
//

import UIKit

public class RU_Booking_Delete_Alert_ViewController : RU_Alert_ViewController {
	
	public var booking:RU_Booking?
	public var deleteCompletion:(()->Void)?
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = String(key: "bookings.delete.alert.title")
		add(String(key: "bookings.delete.alert.content"))
		let deleteButton = addButton(title: String(key: "bookings.delete.alert.button")) { [weak self] button in
			
			button?.isLoading = true
			
			self?.booking?.delete { [weak self] error in
				
				button?.isLoading = false
				
				self?.close {
					
					if let error {
						
						RU_Alert_ViewController.present(error)
					}
					else {
						
						NotificationCenter.post(.updateBookings)
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
