//
//  RU_Home_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit
import SnapKit

public class RU_Home_ViewController: RU_ViewController {
	
	private var bookings: [RU_Booking]? {
		
		didSet {
			
			contentView.dismissPlaceholder()
			
			let currentBooking = bookings?.first { $0.status == .current }
			let upcomingBookings = bookings?.filter { $0.status == .upcoming }.sorted { $0.dates.start < $1.dates.start }
			let nextBooking = upcomingBookings?.first
			
			currentBookingSectionStackView.booking = currentBooking
			nextBookingSectionStackView.booking = nextBooking
			
			if [currentBooking,nextBooking].allSatisfy({ $0 == nil }) {
				
				let placeholderView = contentView.showPlaceholder(.Empty)
				
				let addButton:RU_Button = .init(String(key: "bookings.create.button")) { _ in
					
					UI.MainController.present(RU_NavigationController(rootViewController: RU_Bookings_Edit_ViewController()), animated: true)
				}
				addButton.image = UIImage(systemName: "plus.circle")
				placeholderView.contentStackView.addArrangedSubview(addButton)
			}
		}
	}
	private lazy var currentBookingSectionStackView: RU_Booking_Card_Section_StackView = {
		
		$0.title = String(key: "home.currentBooking.section.title")
		return $0
		
	}(RU_Booking_Card_Section_StackView())
	private lazy var nextBookingSectionStackView: RU_Booking_Card_Section_StackView = {
		
		$0.title = String(key: "home.nextBooking.section.title")
		return $0
		
	}(RU_Booking_Card_Section_StackView())

	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		tabBarItem = .init(title: String(key: "tabbar.home"), image: UIImage(systemName: "flame"), tag: RU_TabBarController.Indexes.allCases.firstIndex(of: .Home) ?? 0)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func loadView() {
		
		super.loadView()
		
		navigationItem.title = String(key: "home.title")
		
		let contentScrollView:RU_ScrollView = .init()
		contentScrollView.isCentered = false
		
		let contentStackView:RU_StackView = .init()
		contentStackView.axis = .vertical
		contentStackView.spacing = 2*UI.Margins
		contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.layoutMargins = .init(UI.Margins)
		contentScrollView.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.top.bottom.left.equalToSuperview()
			make.right.width.equalToSuperview()
		}
		
		contentView.addSubview(contentScrollView)
		contentScrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		contentStackView.addArrangedSubview(currentBookingSectionStackView)
		contentStackView.addArrangedSubview(nextBookingSectionStackView)
		
		NotificationCenter.add(.updateBookings) { [weak self] _ in
			
			self?.updateBookings()
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		updateBookings()
	}
	
	private func updateBookings() {
		
		contentView.showPlaceholder(.Loading)
			
		RU_Booking.getAll { [weak self] error, bookings in
			
			self?.contentView.dismissPlaceholder()
				
			if let error {
				
				self?.contentView.showPlaceholder(.Error, error) { [weak self] _ in
					
					self?.contentView.dismissPlaceholder()
					
					self?.updateBookings()
				}
			}
			else {
				
				self?.bookings = bookings
			}
		}
	}
}
