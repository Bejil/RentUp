//
//  RU_WidgetDeepLinkHandler.swift
//  RentUp
//

import UIKit

enum RU_WidgetDeepLinkHandler {
	
	private static var pendingBookingID: String?
	
	static func handle(_ url: URL) {
		guard let bookingID = WidgetBookingDeepLink.bookingID(from: url) else { return }
		
		if canNavigateImmediately {
			openBookingDetail(bookingID: bookingID)
		} else {
			pendingBookingID = bookingID
		}
	}
	
	static func flushPendingIfNeeded() {
		guard let bookingID = pendingBookingID else { return }
		pendingBookingID = nil
		openBookingDetail(bookingID: bookingID)
	}
	
	private static var canNavigateImmediately: Bool {
		let root = keyWindow?.rootViewController
		return root is RU_AdaptiveRootViewController || root is RU_TabBarController
	}
	
	private static func openBookingDetail(bookingID: String) {
		RU_Booking.getAll { error, bookings in
			guard error == nil, let booking = booking(matching: bookingID, in: bookings ?? []) else { return }
			
			DispatchQueue.main.async {
				navigateToBooking(booking)
			}
		}
	}
	
	private static func booking(matching deepLinkID: String, in bookings: [RU_Booking]) -> RU_Booking? {
		bookings.first { candidate in
			if let documentID = candidate.id, !documentID.isEmpty, documentID == deepLinkID {
				return true
			}
			return candidate.uuid == deepLinkID
		}
	}
	
	private static func navigateToBooking(_ booking: RU_Booking) {
		guard let root = keyWindow?.rootViewController else {
			pendingBookingID = widgetBookingID(for: booking)
			return
		}
		
		if let adaptiveRoot = root as? RU_AdaptiveRootViewController {
			adaptiveRoot.selectSection(.Bookings) { navigationController in
				navigationController.dismiss(animated: false)
				navigationController.popToRootViewController(animated: false)
				let detailViewController = RU_Bookings_Detail_ViewController()
				detailViewController.booking = booking
				navigationController.pushViewController(detailViewController, animated: true)
			}
			return
		}
		
		guard let tabBar = root as? RU_TabBarController else {
			pendingBookingID = widgetBookingID(for: booking)
			return
		}
		
		tabBar.dismiss(animated: false)
		
		if let index = RU_TabBarController.Indexes.allCases.firstIndex(of: .Bookings) {
			tabBar.selectedIndex = index
		}
		
		guard let navigationController = tabBar.selectedViewController as? UINavigationController else { return }
		navigationController.popToRootViewController(animated: false)
		
		let detailViewController = RU_Bookings_Detail_ViewController()
		detailViewController.booking = booking
		navigationController.pushViewController(detailViewController, animated: true)
	}
	
	private static var keyWindow: UIWindow? {
		UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.flatMap(\.windows)
			.first(where: \.isKeyWindow)
	}
	
	private static func widgetBookingID(for booking: RU_Booking) -> String {
		if let documentID = booking.id, !documentID.isEmpty {
			return documentID
		}
		return booking.uuid
	}
}
