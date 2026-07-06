//
//  WidgetCalendarMonthBuilder.swift
//  RentUpShared
//

import Foundation

public struct WidgetBookingBarSegment: Identifiable, Equatable {
	
	public var id: String
	public var isStartDate: Bool
	public var isEndDate: Bool
	public var platformType: String
	
	public init(id: String, isStartDate: Bool, isEndDate: Bool, platformType: String) {
		self.id = id
		self.isStartDate = isStartDate
		self.isEndDate = isEndDate
		self.platformType = platformType
	}
}

public struct WidgetBookingBarRow: Identifiable, Equatable {
	
	public var id: String
	public var segments: [WidgetBookingBarSegment]
	
	public init(id: String, segments: [WidgetBookingBarSegment]) {
		self.id = id
		self.segments = segments
	}
}

public struct WidgetCalendarDay: Identifiable, Equatable {
	
	public var id: String
	public var date: Date?
	public var dayNumber: Int?
	public var isToday: Bool
	public var barRows: [WidgetBookingBarRow]
	public var hiddenBarCount: Int
	/// Identifiant de la réservation si ce jour n'en contient qu'une seule (deep link widget).
	public var linkBookingID: String?
	
	public init(
		id: String,
		date: Date?,
		dayNumber: Int?,
		isToday: Bool,
		barRows: [WidgetBookingBarRow] = [],
		hiddenBarCount: Int = 0,
		linkBookingID: String? = nil
	) {
		self.id = id
		self.date = date
		self.dayNumber = dayNumber
		self.isToday = isToday
		self.barRows = barRows
		self.hiddenBarCount = hiddenBarCount
		self.linkBookingID = linkBookingID
	}
}

public struct WidgetCalendarWeek: Identifiable, Equatable {
	
	public var id: Int
	public var days: [WidgetCalendarDay]
	
	public init(id: Int, days: [WidgetCalendarDay]) {
		self.id = id
		self.days = days
	}
}

public struct WidgetCalendarMonth: Equatable {
	
	public var title: String
	public var weekdaySymbols: [String]
	public var weeks: [WidgetCalendarWeek]
	
	public init(title: String, weekdaySymbols: [String], weeks: [WidgetCalendarWeek]) {
		self.title = title
		self.weekdaySymbols = weekdaySymbols
		self.weeks = weeks
	}
}

public enum WidgetCalendarMonthBuilder {
	
	private static let columnsPerWeek = 7
	private static let maxVisibleLanesPerDay = 3
	private static let weekdaySymbols = ["L", "M", "M", "J", "V", "S", "D"]
	
	public static var calendar: Calendar {
		var calendar = Calendar(identifier: .gregorian)
		calendar.locale = Locale(identifier: "fr_FR")
		calendar.firstWeekday = 2
		calendar.minimumDaysInFirstWeek = 4
		return calendar
	}
	
	public static func build(
		for month: Date = Date(),
		bookings: [WidgetBookingItem],
		now: Date = Date(),
		maxRows: Int = 3
	) -> WidgetCalendarMonth {
		let calendar = self.calendar
		let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) ?? month
		let monthTitleFormatter = DateFormatter()
		monthTitleFormatter.locale = Locale(identifier: "fr_FR")
		monthTitleFormatter.dateFormat = "LLLL yyyy"
		
		let activeBookings = bookings.filter { !$0.isCancelled }
		let laneByBookingKey = makeLaneMapping(for: activeBookings, calendar: calendar)
		
		let range = calendar.range(of: .day, in: .month, for: monthStart) ?? 1..<31
		let firstWeekday = calendar.component(.weekday, from: monthStart)
		let leadingEmpty = (firstWeekday - calendar.firstWeekday + 7) % 7
		
		var days: [WidgetCalendarDay] = []
		for index in 0..<leadingEmpty {
			days.append(.init(id: "empty-\(index)", date: nil, dayNumber: nil, isToday: false))
		}
		
		for day in range {
			guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) else { continue }
			let dayStart = calendar.startOfDay(for: date)
			let bookingsForDay = activeBookings.filter { booking in
				let start = calendar.startOfDay(for: booking.start)
				let end = calendar.startOfDay(for: booking.end)
				return dayStart >= start && dayStart <= end
			}
			let barRows = makeBarRows(
				for: date,
				bookingsForDay: bookingsForDay,
				calendar: calendar,
				laneByBookingKey: laneByBookingKey,
				maxRows: maxRows
			)
			let hiddenCount = max(0, countPropertyRows(for: bookingsForDay) - barRows.count)
			let linkBookingID = bookingsForDay.count == 1 ? bookingsForDay[0].id : nil
			
			days.append(.init(
				id: "day-\(day)",
				date: date,
				dayNumber: day,
				isToday: calendar.isDateInToday(date),
				barRows: barRows,
				hiddenBarCount: hiddenCount,
				linkBookingID: linkBookingID
			))
		}
		
		while days.count % columnsPerWeek != 0 {
			days.append(.init(id: "empty-\(days.count)", date: nil, dayNumber: nil, isToday: false))
		}
		
		let weeks = stride(from: 0, to: days.count, by: columnsPerWeek).enumerated().map { weekIndex, start in
			WidgetCalendarWeek(
				id: weekIndex,
				days: Array(days[start..<min(start + columnsPerWeek, days.count)])
			)
		}
		
		return WidgetCalendarMonth(
			title: monthTitleFormatter.string(from: monthStart).capitalized,
			weekdaySymbols: weekdaySymbols,
			weeks: weeks
		)
	}
	
	private static func bookingKey(for booking: WidgetBookingItem) -> String {
		if !booking.id.isEmpty {
			return booking.id
		}
		return "\(booking.start.timeIntervalSince1970)|\(booking.end.timeIntervalSince1970)|\(booking.platformType ?? "-")|\(booking.classifiedID ?? "-")"
	}
	
	private static func propertyKey(for booking: WidgetBookingItem) -> String {
		if let classifiedID = booking.classifiedID, !classifiedID.isEmpty {
			return "classified:\(classifiedID)"
		}
		return "booking:\(booking.id)"
	}
	
	private static func countPropertyRows(for bookings: [WidgetBookingItem]) -> Int {
		Set(bookings.map { propertyKey(for: $0) }).count
	}
	
	private static func makeBarRows(
		for date: Date,
		bookingsForDay: [WidgetBookingItem],
		calendar: Calendar,
		laneByBookingKey: [String: Int],
		maxRows: Int
	) -> [WidgetBookingBarRow] {
		let grouped = Dictionary(grouping: bookingsForDay, by: { propertyKey(for: $0) })
		var keys = Array(grouped.keys)
		keys.sort { a, b in
			let laneA = grouped[a]!.map { laneByBookingKey[bookingKey(for: $0)] ?? .max }.min() ?? .max
			let laneB = grouped[b]!.map { laneByBookingKey[bookingKey(for: $0)] ?? .max }.min() ?? .max
			if laneA != laneB { return laneA < laneB }
			return a < b
		}
		keys = Array(keys.prefix(maxRows))
		
		return keys.map { key in
			let list = grouped[key]!.sorted { $0.start < $1.start }
			let segments = list.enumerated().compactMap { index, booking -> WidgetBookingBarSegment? in
				guard let platformType = booking.platformType else { return nil }
				return WidgetBookingBarSegment(
					id: "\(key)-\(index)",
					isStartDate: calendar.isDate(date, inSameDayAs: booking.start),
					isEndDate: calendar.isDate(date, inSameDayAs: booking.end),
					platformType: platformType
				)
			}
			return WidgetBookingBarRow(id: key, segments: segments)
		}
	}
	
	private static func makeLaneMapping(for bookings: [WidgetBookingItem], calendar: Calendar) -> [String: Int] {
		var laneByKey: [String: Int] = [:]
		var laneEndByIndex: [Int: Date] = [:]
		
		let sorted = bookings.sorted {
			if $0.start == $1.start {
				return $0.end < $1.end
			}
			return $0.start < $1.start
		}
		
		for booking in sorted {
			let start = calendar.startOfDay(for: booking.start)
			let end = calendar.startOfDay(for: booking.end)
			let key = bookingKey(for: booking)
			
			let existingLane = laneEndByIndex
				.sorted(by: { $0.key < $1.key })
				.first(where: { start >= $0.value })?.key
			
			let lane: Int
			if let existingLane {
				lane = existingLane
			} else {
				lane = (laneEndByIndex.keys.max() ?? -1) + 1
			}
			
			laneByKey[key] = lane
			laneEndByIndex[lane] = end
		}
		
		return laneByKey
	}
}
