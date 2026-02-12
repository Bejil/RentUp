//
//  RU_UpcomingHoliday.swift
//  RentUp
//
//  Jours fériés et départs en vacances scolaires (zones A, B, C) pour inciter aux promotions.
//

import Foundation

enum RU_UpcomingHoliday {

    /// Prochaine occasion (jour férié ou début de vacances) dans les `withinDays` prochains jours.
    /// Retourne (nom localisé, date de début, date de fin) ou nil s'il n'y en a pas.
    static func nextOpportunity(withinDays days: Int = 60, calendar: Calendar = .current) -> (name: String, startDate: Date, endDate: Date)? {
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        guard let end = calendar.date(byAdding: .day, value: days, to: startOfToday) else { return nil }
        let year = calendar.component(.year, from: now)
        let nextYear = year + 1

        // Jours fériés : (year, month, day, key) → même jour pour début et fin
        let holidays: [(Int, Int, Int, String)] = [
            (year, 1, 1, "home.tip.promo.holiday.jourAn"),
            (year, 5, 1, "home.tip.promo.holiday.1ermai"),
            (year, 5, 8, "home.tip.promo.holiday.8mai"),
            (year, 7, 14, "home.tip.promo.holiday.14juillet"),
            (year, 8, 15, "home.tip.promo.holiday.15aout"),
            (year, 11, 1, "home.tip.promo.holiday.toussaint"),
            (year, 11, 11, "home.tip.promo.holiday.11novembre"),
            (year, 12, 25, "home.tip.promo.holiday.noel"),
            (nextYear, 1, 1, "home.tip.promo.holiday.jourAn"),
            (nextYear, 5, 1, "home.tip.promo.holiday.1ermai"),
            (nextYear, 5, 8, "home.tip.promo.holiday.8mai"),
            (nextYear, 7, 14, "home.tip.promo.holiday.14juillet"),
            (nextYear, 8, 15, "home.tip.promo.holiday.15aout"),
        ]

        // Vacances scolaires : (startYear, startMonth, startDay, endYear, endMonth, endDay, key)
        let vacances: [(Int, Int, Int, Int, Int, Int, String)] = [
            (year, 2, 7, year, 3, 9, "home.tip.promo.vacances.hiver"),
            (year, 4, 4, year, 5, 4, "home.tip.promo.vacances.printemps"),
            (year, 7, 4, year, 9, 1, "home.tip.promo.vacances.ete"),
            (year, 10, 18, year, 11, 3, "home.tip.promo.vacances.toussaint"),
            (year, 12, 20, nextYear, 1, 4, "home.tip.promo.vacances.noel"),
            (nextYear, 2, 7, nextYear, 3, 9, "home.tip.promo.vacances.hiver"),
            (nextYear, 4, 4, nextYear, 5, 4, "home.tip.promo.vacances.printemps"),
            (nextYear, 7, 4, nextYear, 9, 1, "home.tip.promo.vacances.ete"),
            (nextYear, 10, 17, nextYear, 11, 2, "home.tip.promo.vacances.toussaint"),
            (nextYear, 12, 19, nextYear + 1, 1, 4, "home.tip.promo.vacances.noel"),
        ]

        // Jours fériés mobiles (approximatifs 2025–2027)
        let easterMondays: [(Int, Int, Int)] = [(2025, 4, 21), (2026, 4, 6), (2027, 3, 29)]
        let ascensions: [(Int, Int, Int)] = [(2025, 5, 29), (2026, 5, 14), (2027, 5, 6)]
        let pentecotes: [(Int, Int, Int)] = [(2025, 6, 9), (2026, 5, 25), (2027, 5, 17)]

        var all: [(Date, Date, String)] = []

        for (y, m, d, key) in holidays {
            guard let date = calendar.date(from: DateComponents(year: y, month: m, day: d)),
                  date >= startOfToday, date <= end else { continue }
            all.append((date, date, String(key: key)))
        }

        for (yStart, mStart, dStart, yEnd, mEnd, dEnd, key) in vacances {
            guard let startDate = calendar.date(from: DateComponents(year: yStart, month: mStart, day: dStart)),
                  startDate >= startOfToday, startDate <= end,
                  let endDate = calendar.date(from: DateComponents(year: yEnd, month: mEnd, day: dEnd)) else { continue }
            all.append((startDate, endDate, String(key: key)))
        }

        for (y, m, d) in easterMondays where y >= year - 1 && y <= nextYear {
            guard let date = calendar.date(from: DateComponents(year: y, month: m, day: d)),
                  date >= startOfToday, date <= end else { continue }
            all.append((date, date, String(key: "home.tip.promo.holiday.paques")))
        }
        for (y, m, d) in ascensions where y >= year - 1 && y <= nextYear {
            guard let date = calendar.date(from: DateComponents(year: y, month: m, day: d)),
                  date >= startOfToday, date <= end else { continue }
            all.append((date, date, String(key: "home.tip.promo.holiday.ascension")))
        }
        for (y, m, d) in pentecotes where y >= year - 1 && y <= nextYear {
            guard let date = calendar.date(from: DateComponents(year: y, month: m, day: d)),
                  date >= startOfToday, date <= end else { continue }
            all.append((date, date, String(key: "home.tip.promo.holiday.pentecote")))
        }

        guard let first = all.sorted(by: { $0.0 < $1.0 }).first else { return nil }
        return (first.2, first.0, first.1)
    }
}
