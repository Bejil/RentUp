//
//  BookingsCalendarEntry+Preview.swift
//  BookingsWidget
//

import Foundation
import WidgetKit

extension BookingsCalendarEntry {
	
	static func previewSample(for date: Date = Date()) -> BookingsCalendarEntry {
		let calendar = Calendar.current
		let classifiedID = "preview-classified"
		let classifiedName = "Appartement Paris"
		
		let bookings = [
			WidgetBookingItem(
				id: "preview-current",
				start: calendar.date(byAdding: .day, value: -1, to: date) ?? date,
				end: calendar.date(byAdding: .day, value: 3, to: date) ?? date,
				platformType: "airbnb",
				classifiedID: classifiedID,
				classifiedName: classifiedName,
				doubleBeds: 1,
				singleBeds: 1,
				babyBeds: 0,
				isCancelled: false
			),
			WidgetBookingItem(
				id: "preview-upcoming",
				start: calendar.date(byAdding: .day, value: 10, to: date) ?? date,
				end: calendar.date(byAdding: .day, value: 14, to: date) ?? date,
				platformType: "booking",
				classifiedID: classifiedID,
				classifiedName: classifiedName,
				doubleBeds: 2,
				singleBeds: 0,
				babyBeds: 1,
				isCancelled: false
			)
		]
		
		let month = WidgetCalendarMonthBuilder.build(for: date, bookings: bookings, now: date)
		let highlight = WidgetBookingsHighlight.resolve(from: bookings, now: date)
		
		return BookingsCalendarEntry(
			date: date,
			month: month,
			highlight: highlight,
			classifiedName: classifiedName,
			selectedClassifiedID: classifiedID,
			hasBookings: true,
			isConfigured: true
		)
	}
}

extension WidgetClassifiedEntity {
	
	static var previewSample: WidgetClassifiedEntity {
		WidgetClassifiedEntity(id: "preview-classified", displayName: "Appartement Paris")
	}
}
