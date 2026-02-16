//
//  Date_UpcomingHoliday_Extension.swift
//  RentUp
//

import Foundation

// MARK: - Opportunity type

public struct UpcomingHolidayOpportunity {
	public let startDate: Date
	public let endDate: Date
	/// Clé de localisation (ex. "home.tip.promo.holiday.paques")
	public let name: String
}

// MARK: - Date extension

extension Date {

	/// Prochaine opportunité (jour férié ou vacances) dans les `withinDays` prochains jours à partir de cette date.
	public func nextUpcomingHolidayOpportunity(withinDays: Int, calendar: Calendar = .current) -> UpcomingHolidayOpportunity? {
		let from = calendar.startOfDay(for: self)
		guard let end = calendar.date(byAdding: .day, value: withinDays, to: from) else { return nil }
		let year = calendar.component(.year, from: self)
		let nextYear = year + 1
		var candidates: [UpcomingHolidayOpportunity] = []

		// Jours fériés fixes
		let fixedHolidays: [(month: Int, day: Int, key: String)] = [
			(1, 1, "home.tip.promo.holiday.jourAn"),
			(5, 1, "home.tip.promo.holiday.1ermai"),
			(5, 8, "home.tip.promo.holiday.8mai"),
			(7, 14, "home.tip.promo.holiday.14juillet"),
			(8, 15, "home.tip.promo.holiday.15aout"),
			(11, 1, "home.tip.promo.holiday.toussaint"),
			(11, 11, "home.tip.promo.holiday.11novembre"),
			(12, 25, "home.tip.promo.holiday.noel")
		]
		for (month, day, key) in fixedHolidays {
			for y in [year, nextYear] {
				guard let d = calendar.date(from: DateComponents(year: y, month: month, day: day)) else { continue }
				if d >= from && d <= end {
					candidates.append(UpcomingHolidayOpportunity(startDate: d, endDate: d, name: key))
				}
			}
		}

		// Fêtes mobiles (Pâques et dérivées)
		for y in [year, nextYear] {
			guard let easter = Self.easterSunday(year: y, calendar: calendar) else { continue }
			let mondayEaster = calendar.date(byAdding: .day, value: 1, to: easter)!
			let ascension = calendar.date(byAdding: .day, value: 39, to: easter)!
			let pentecostMonday = calendar.date(byAdding: .day, value: 50, to: easter)!
			for (d, key) in [(mondayEaster, "home.tip.promo.holiday.paques"), (ascension, "home.tip.promo.holiday.ascension"), (pentecostMonday, "home.tip.promo.holiday.pentecote")] {
				if d >= from && d <= end {
					candidates.append(UpcomingHolidayOpportunity(startDate: d, endDate: d, name: key))
				}
			}
		}

		// Vacances scolaires (approximatif zone A)
		for (start, endDate, key) in Self.schoolVacationRanges(year: year, nextYear: nextYear, calendar: calendar) {
			if endDate >= from && start <= end {
				let s = max(start, from)
				let e = min(endDate, end)
				if s <= e {
					candidates.append(UpcomingHolidayOpportunity(startDate: s, endDate: e, name: key))
				}
			}
		}

		return candidates.min(by: { $0.startDate < $1.startDate })
	}

	// MARK: - Pâques (algorithme grégorien Meeus)

	public static func easterSunday(year: Int, calendar: Calendar) -> Date? {
		var cal = calendar
		cal.timeZone = TimeZone(identifier: "Europe/Paris") ?? .current
		let a = year % 19
		let b = year / 100
		let c = year % 100
		let d = b / 4
		let e = b % 4
		let f = (b + 8) / 25
		let g = (b - f + 1) / 3
		let h = (19 * a + b - d - g + 15) % 30
		let i = c / 4
		let k = c % 4
		let l = (32 + 2 * e + 2 * i - h - k) % 7
		let m = (a + 11 * h + 22 * l) / 451
		let month = (h + l - 7 * m + 114) / 31
		let day = ((h + l - 7 * m + 114) % 31) + 1
		return cal.date(from: DateComponents(year: year, month: month, day: day))
	}

	// MARK: - Vacances scolaires (approximatif)

	private static func schoolVacationRanges(year: Int, nextYear: Int, calendar: Calendar) -> [(Date, Date, String)] {
		var result: [(Date, Date, String)] = []
		guard let easter = easterSunday(year: year, calendar: calendar) else { return result }

		// Hiver : 2e samedi de février → +3 semaines
		if let feb2Sat = secondSaturday(month: 2, year: year, calendar: calendar),
		   let end = calendar.date(byAdding: .day, value: 21, to: feb2Sat) {
			result.append((feb2Sat, end, "home.tip.promo.vacances.hiver"))
		}
		// Printemps : 2 semaines avant Pâques → lundi de Pâques
		if let twoWeeksBefore = calendar.date(byAdding: .day, value: -14, to: easter),
		   let mondayEaster = calendar.date(byAdding: .day, value: 1, to: easter) {
			result.append((twoWeeksBefore, mondayEaster, "home.tip.promo.vacances.printemps"))
		}
		// Été : 1er samedi de juillet → 1er septembre
		if let jul1Sat = firstSaturday(month: 7, year: year, calendar: calendar),
		   let sep1 = calendar.date(from: DateComponents(year: year, month: 9, day: 1)) {
			result.append((jul1Sat, sep1, "home.tip.promo.vacances.ete"))
		}
		// Toussaint : samedi de la semaine du 18 octobre → +2 semaines
		if let oct18 = calendar.date(from: DateComponents(year: year, month: 10, day: 18)),
		   let sat = saturdayOfWeek(of: oct18, calendar: calendar),
		   let end = calendar.date(byAdding: .day, value: 14, to: sat) {
			result.append((sat, end, "home.tip.promo.vacances.toussaint"))
		}
		// Noël : samedi de la semaine du 20 décembre → 4 janvier
		if let dec20 = calendar.date(from: DateComponents(year: year, month: 12, day: 20)),
		   let sat = saturdayOfWeek(of: dec20, calendar: calendar),
		   let jan4 = calendar.date(from: DateComponents(year: nextYear, month: 1, day: 4)) {
			result.append((sat, jan4, "home.tip.promo.vacances.noel"))
		}
		return result
	}

	private static func firstSaturday(month: Int, year: Int, calendar: Calendar) -> Date? {
		guard let first = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else { return nil }
		return saturdayOfWeek(of: first, calendar: calendar)
	}

	private static func secondSaturday(month: Int, year: Int, calendar: Calendar) -> Date? {
		guard let first = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else { return nil }
		guard let firstSat = saturdayOfWeek(of: first, calendar: calendar) else { return nil }
		return calendar.date(byAdding: .day, value: 7, to: firstSat)
	}

	private static func saturdayOfWeek(of date: Date, calendar: Calendar) -> Date? {
		let weekday = calendar.component(.weekday, from: date)
		let daysToSaturday = (7 - weekday + 7) % 7
		if daysToSaturday == 0 { return calendar.startOfDay(for: date) }
		return calendar.date(byAdding: .day, value: daysToSaturday, to: calendar.startOfDay(for: date))
	}
}
