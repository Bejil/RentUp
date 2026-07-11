//
//  WidgetTimelineRefreshDates.swift
//  RentUpShared
//

import Foundation

public enum WidgetTimelineRefreshDates {
	
	/// Dates futures auxquelles le widget doit se rafraîchir (badges, mois, résa en cours / à venir).
	public static func upcoming(
		from now: Date = Date(),
		bookings: [WidgetBookingItem],
		calendar: Calendar = WidgetCalendarMonthBuilder.calendar,
		maxCount: Int = 40
	) -> [Date] {
		var dates = Set<Date>()
		
		for hour in 1...24 {
			if let date = calendar.date(byAdding: .hour, value: hour, to: now) {
				dates.insert(date)
			}
		}
		
		let todayStart = calendar.startOfDay(for: now)
		for dayOffset in 0...14 {
			if let midnight = calendar.date(byAdding: .day, value: dayOffset, to: todayStart), midnight > now {
				dates.insert(midnight)
			}
		}
		
		if let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
		   let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: monthStart),
		   nextMonthStart > now {
			dates.insert(nextMonthStart)
		}
		
		for booking in bookings where !booking.isCancelled {
			let startDay = calendar.startOfDay(for: booking.start)
			let endDay = calendar.startOfDay(for: booking.end)
			if startDay > now {
				dates.insert(startDay)
			}
			if let dayAfterEnd = calendar.date(byAdding: .day, value: 1, to: endDay), dayAfterEnd > now {
				dates.insert(dayAfterEnd)
			}
		}
		
		return dates
			.filter { $0 > now }
			.sorted()
			.prefix(maxCount)
			.map { $0 }
	}
}
