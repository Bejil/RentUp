//
//  RU_Reporting_MetricsPeriod.swift
//  RentUp
//

import Foundation

public enum RU_Reporting_MetricsPeriod: Equatable {
	
	case allTime
	case yearToDate
	case last12Months
	case last6Months
	case custom(from: Date, to: Date)
	
	public static let `default`: Self = .allTime
	
	public static var presets: [RU_Reporting_MetricsPeriod] {
		[.allTime, .yearToDate, .last12Months, .last6Months]
	}
	
	public var isCustom: Bool {
		if case .custom = self { return true }
		return false
	}
	
	public var title: String {
		switch self {
		case .allTime:
			return String(key: "reporting.period.allTime")
		case .yearToDate:
			return String(key: "reporting.period.yearToDate")
		case .last12Months:
			return String(key: "reporting.period.last12Months")
		case .last6Months:
			return String(key: "reporting.period.last6Months")
		case .custom(let from, let to):
			let formatter = DateFormatter()
			formatter.locale = Locale(identifier: "fr_FR")
			formatter.dateStyle = .short
			return "\(formatter.string(from: from)) – \(formatter.string(from: to))"
		}
	}
	
	public struct Bounds {
		public let start: Date
		/// Fin exclusive (premier instant après la période).
		public let end: Date
	}
	
	public func bounds(
		calendar: Calendar,
		now: Date,
		earliestBookingStart: Date?,
		latestBookingEnd: Date?
	) -> Bounds {
		let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
		let currentMonthDays = calendar.range(of: .day, in: .month, for: now)?.count ?? 30
		let currentMonthExclusiveEnd = calendar.date(byAdding: .day, value: currentMonthDays, to: currentMonthStart) ?? now
		let horizonEnd = exclusiveEnd(covering: latestBookingEnd, atLeast: currentMonthExclusiveEnd, calendar: calendar)
		
		switch self {
		case .allTime:
			let start = calendar.startOfDay(for: earliestBookingStart ?? currentMonthStart)
			return Bounds(start: start, end: max(start, horizonEnd))
			
		case .yearToDate:
			let year = calendar.component(.year, from: now)
			let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) ?? currentMonthStart
			return Bounds(start: calendar.startOfDay(for: start), end: horizonEnd)
			
		case .last12Months:
			let start = calendar.date(byAdding: .month, value: -12, to: currentMonthStart) ?? currentMonthStart
			return Bounds(start: calendar.startOfDay(for: start), end: horizonEnd)
			
		case .last6Months:
			let start = calendar.date(byAdding: .month, value: -6, to: currentMonthStart) ?? currentMonthStart
			return Bounds(start: calendar.startOfDay(for: start), end: horizonEnd)
			
		case .custom(let from, let to):
			let start = calendar.startOfDay(for: min(from, to))
			let endDay = calendar.startOfDay(for: max(from, to))
			let exclusiveEnd = calendar.date(byAdding: .day, value: 1, to: endDay) ?? endDay
			return Bounds(start: start, end: max(start, exclusiveEnd))
		}
	}
	
	public func matchesPreset(_ preset: RU_Reporting_MetricsPeriod) -> Bool {
		switch (self, preset) {
		case (.allTime, .allTime), (.yearToDate, .yearToDate),
			(.last12Months, .last12Months), (.last6Months, .last6Months):
			return true
		default:
			return false
		}
	}
	
	public func monthRange(
		calendar: Calendar,
		now: Date,
		earliestBookingStart: Date?,
		latestBookingEnd: Date?
	) -> (firstMonthStart: Date, lastMonthStart: Date) {
		let bounds = bounds(
			calendar: calendar,
			now: now,
			earliestBookingStart: earliestBookingStart,
			latestBookingEnd: latestBookingEnd
		)
		let firstMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: bounds.start)) ?? bounds.start
		let lastDay = calendar.date(byAdding: .day, value: -1, to: bounds.end) ?? bounds.end
		let lastMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: lastDay)) ?? lastDay
		return (firstMonthStart, max(firstMonthStart, lastMonthStart))
	}
	
	/// Fin exclusive couvrant au moins `floor`, et au-delà jusqu’à la fin du jour de `latestBookingEnd` si plus lointaine.
	private func exclusiveEnd(covering latestBookingEnd: Date?, atLeast floor: Date, calendar: Calendar) -> Date {
		guard let latestBookingEnd else { return floor }
		let endDay = calendar.startOfDay(for: latestBookingEnd)
		let exclusive = calendar.date(byAdding: .day, value: 1, to: endDay) ?? endDay
		return max(floor, exclusive)
	}
}
