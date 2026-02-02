//
//  RU_Booking_Status_Extension.swift
//  RentUp
//
//  Created by BLIN Michael on 21/01/2026.
//

import UIKit

extension RU_Booking_Status {
	
	public var backgroundColor: UIColor {
		
		switch self {
		case .past:
			return Colors.Booking.Status.Past.Background
		case .current:
			return Colors.Booking.Status.Current.Background
		case .upcoming:
			return Colors.Booking.Status.Upcoming.Background
		}
	}
	
	public var textColor: UIColor {
		
		switch self {
		case .past:
			return Colors.Booking.Status.Past.Text
		case .current:
			return Colors.Booking.Status.Current.Text
		case .upcoming:
			return Colors.Booking.Status.Upcoming.Text
		}
	}
	
	public var text: String {
		
		switch self {
		case .past:
			return String(key: "booking.status.past.name")
		case .current:
			return String(key: "booking.status.current.name")
		case .upcoming:
			return String(key: "booking.status.upcoming.name")
		}
	}
}
