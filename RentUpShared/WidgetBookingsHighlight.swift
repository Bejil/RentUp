//
//  WidgetBookingsHighlight.swift
//  RentUpShared
//

import Foundation

public struct WidgetBookingsHighlight: Equatable {
	
	public var current: WidgetBookingItem?
	public var upcoming: WidgetBookingItem?
	
	public init(current: WidgetBookingItem?, upcoming: WidgetBookingItem?) {
		self.current = current
		self.upcoming = upcoming
	}
	
	public static func resolve(from bookings: [WidgetBookingItem], now: Date = Date()) -> WidgetBookingsHighlight {
		let calendar = WidgetCalendarMonthBuilder.calendar
		let today = calendar.startOfDay(for: now)
		let active = bookings.filter { !$0.isCancelled }
		let sortedByStartDesc = active.sorted { $0.start > $1.start }
		
		let current = sortedByStartDesc.first { booking in
			let start = calendar.startOfDay(for: booking.start)
			let end = calendar.startOfDay(for: booking.end)
			return start <= today && end >= today
		}
		
		let upcoming = active
			.filter { calendar.startOfDay(for: $0.start) > today }
			.sorted { $0.start < $1.start }
			.first
		
		return WidgetBookingsHighlight(current: current, upcoming: upcoming)
	}
	
	public var hasAnyBooking: Bool {
		current != nil || upcoming != nil
	}
	
	public static func primaryClassifiedName(
		from bookings: [WidgetBookingItem],
		highlight: WidgetBookingsHighlight
	) -> String? {
		if let name = highlight.current?.classifiedName, !name.isEmpty {
			return name
		}
		if let name = highlight.upcoming?.classifiedName, !name.isEmpty {
			return name
		}
		return bookings.compactMap(\.classifiedName).first { !$0.isEmpty }
	}
}

public enum WidgetBookingHighlightRole: Equatable {
	case current
	case upcoming
}

public enum WidgetBookingPresentation {
	
	public static func sectionTitle(for role: WidgetBookingHighlightRole) -> String {
		switch role {
		case .current: return "En cours"
		case .upcoming: return "À venir"
		}
	}
	
	public static func statusBadgeText(
		for booking: WidgetBookingItem,
		role: WidgetBookingHighlightRole,
		now: Date = Date()
	) -> String {
		let calendar = WidgetCalendarMonthBuilder.calendar
		let today = calendar.startOfDay(for: now)
		
		switch role {
		case .current:
			let endDay = calendar.startOfDay(for: booking.end)
			let days = calendar.dateComponents([.day], from: today, to: endDay).day ?? 0
			if days == 0 { return "Départ auj" }
			if days == 1 { return "Départ dem" }
			return "En cours ➜ \(days) j"
		case .upcoming:
			let startDay = calendar.startOfDay(for: booking.start)
			let days = calendar.dateComponents([.day], from: today, to: startDay).day ?? 0
			if days == 0 { return "Arrivée auj" }
			if days == 1 { return "À venir dem" }
			return "À venir ➜ \(days) j"
		}
	}
	
	public static func dateRangeText(for booking: WidgetBookingItem) -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "fr_FR")
		formatter.dateFormat = "dd/MM/yyyy"
		return "\(formatter.string(from: booking.start)) – \(formatter.string(from: booking.end))"
	}
	
	public static func platformName(for type: String?) -> String {
		switch type {
		case "airbnb": return "Airbnb"
		case "booking": return "Booking"
		case "abritel": return "Abritel"
		case "direct": return "Direct"
		default: return "Réservation"
		}
	}
	
	public static func classifiedTitle(for booking: WidgetBookingItem) -> String {
		if let name = booking.classifiedName, !name.isEmpty {
			return name
		}
		return platformName(for: booking.platformType)
	}
}
