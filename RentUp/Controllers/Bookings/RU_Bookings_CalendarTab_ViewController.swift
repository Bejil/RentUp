//
//  RU_Bookings_CalendarTab_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 30/06/2026.
//

import UIKit
import SnapKit

public class RU_Bookings_CalendarTab_ViewController: RU_Bookings_Calendar_ViewController {
	
	private var hasLoadedBookingsOnce = false
	
	private lazy var createButton: RU_Button = {
		
		$0.image = UIImage(systemName: "plus")
		return $0
		
	}(RU_Button(String(key: "bookings.create.button")) { _ in
		
		RU_Booking.create()
	})
	
	public override func loadView() {
        
        navigationItem.rightBarButtonItem = .init(title: String(key: "Liste"), primaryAction: .init(handler: { _ in
            
            UI.MainController.present(RU_NavigationController(rootViewController: RU_Bookings_List_ViewController()), animated: true)
        }))
		
		skipsInitialLayoutWithoutBookings = true
		
		super.loadView()
		
		navigationItem.title = String(key: "bookings.title")
		
		didSelectBooking = { [weak self] booking in
			
			let detailViewController = RU_Bookings_Detail_ViewController()
			detailViewController.booking = booking
			self?.navigationController?.pushViewController(detailViewController, animated: true)
		}
		
		view.addSubview(createButton)
		createButton.snp.makeConstraints { make in
			make.right.bottom.left.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
		
		NotificationCenter.add(.updateBookings) { [weak self] _ in
			
			self?.updateData(showLoading: false)
		}
	}
	
	public override func viewDidLoad() {
		
		super.viewDidLoad()
		
		updateData(showLoading: true)
	}
	
	public override func viewDidLayoutSubviews() {
		
		super.viewDidLayoutSubviews()
		
		let bottomInset = createButton.bounds.height + 2 * UI.Margins
		if let collectionView = view as? UICollectionView {
			collectionView.contentInset.bottom = bottomInset
			collectionView.verticalScrollIndicatorInsets.bottom = bottomInset
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		if hasLoadedBookingsOnce {
			updateData(showLoading: false)
		}
	}
	
	private func updateData(showLoading: Bool) {
		
		if showLoading, !hasLoadedBookingsOnce {
			view.showPlaceholder(.Loading)
		}
		
		RU_Booking.getAll { [weak self] error, bookings in
			
			guard let self else { return }
			
			self.hasLoadedBookingsOnce = true
			self.view.dismissPlaceholder()
			
			if let error {
				
				self.view.showPlaceholder(.Error, error) { [weak self] _ in
					
					self?.view.dismissPlaceholder()
					self?.updateData(showLoading: true)
				}
				return
			}
			
			self.bookings = bookings?.filter({ $0.status != .cancelled })
		}
	}
}
