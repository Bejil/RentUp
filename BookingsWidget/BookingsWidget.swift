//
//  BookingsWidget.swift
//  BookingsWidget
//
//  Created by Michaël Blin on 16/02/2026.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {

	func placeholder(in context: Context) -> RU_Bookings_TimeLineEntry {
        
        return RU_Bookings_TimeLineEntry()
	}

	func getSnapshot(in context: Context, completion: @escaping (RU_Bookings_TimeLineEntry) -> ()) {

		RU_Booking.getAll { _, bookings in
            let timeLineEntry: RU_Bookings_TimeLineEntry = .init()
            timeLineEntry.currentBooking = bookings?.current
            timeLineEntry.nextBooking = bookings?.next
            timeLineEntry.bookings = bookings ?? []
            completion(timeLineEntry)
		}
	}

	func getTimeline(in context: Context, completion: @escaping (Timeline<RU_Bookings_TimeLineEntry>) -> ()) {

		RU_Booking.getAll { _, bookings in
            let timeLineEntry: RU_Bookings_TimeLineEntry = .init()
            timeLineEntry.currentBooking = bookings?.current
            timeLineEntry.nextBooking = bookings?.next
            timeLineEntry.bookings = bookings ?? []
            let timeline = Timeline(entries: [timeLineEntry], policy: .after(Calendar.current.date(byAdding: .minute, value: 15, to: Date())!))
			completion(timeline)
		}
	}
}

// MARK: - Labels (style app, SwiftUI pur)

private enum WidgetColors {

	static func statusBackground(_ status: RU_Booking.Status) -> Color {
		switch status {
		case .past: return Color("BookingStatusPastBackground")
		case .current: return Color("BookingStatusCurrentBackground")
		case .upcoming: return Color("BookingStatusUpcomingBackground")
        case .cancelled: return Color("BookingStatusCancelledBackground")
        }
	}

	static func statusText(_ status: RU_Booking.Status) -> Color {
		switch status {
		case .past: return Color("BookingStatusPastText")
		case .current: return Color("BookingStatusCurrentText")
		case .upcoming: return Color("BookingStatusUpcomingText")
        case .cancelled: return Color("BookingStatusCancelledText")
		}
	}

	static func platformBackground(_ type: RU_Platform.PlatformType?) -> Color {
		guard let type else { return Color.clear }
		switch type {
		case .airbnb: return Color("PlatformBackgroundAirbnb")
		case .booking: return Color("PlatformBackgroundBooking")
		case .abritel: return Color("PlatformBackgroundAbritel")
		}
	}

	static func platformText(_ type: RU_Platform.PlatformType?) -> Color {
		guard let type else { return Color.primary }
		switch type {
		case .airbnb: return Color("PlatformTextAirbnb")
		case .booking: return Color("PlatformTextBooking")
		case .abritel: return Color("PlatformTextAbritel")
		}
	}
}

private struct PlatformBadge: View {

	let platform: RU_Platform?

	var body: some View {
		Text(platform?.type?.name ?? "—")
            .font(.system(size: 9, weight: .bold))
			.foregroundStyle(WidgetColors.platformText(platform?.type))
			.padding(.horizontal, 5)
			.padding(.vertical, 3)
			.background(WidgetColors.platformBackground(platform?.type))
			.clipShape(RoundedRectangle(cornerRadius: 7))
	}
}

private struct StatusBadge: View {

	let booking: RU_Booking?

	private var statusText: String {
		guard let booking else { return "" }
		let calendar = Calendar.current
		let today = calendar.startOfDay(for: Date())
		switch booking.status {
		case .upcoming:
			let startDay = calendar.startOfDay(for: booking.dates.start)
			let days = calendar.dateComponents([.day], from: today, to: startDay).day ?? 0
			return "\(booking.status.text) ➜ \(days) j"
		case .current:
			let endDay = calendar.startOfDay(for: booking.dates.end)
			let days = calendar.dateComponents([.day], from: today, to: endDay).day ?? 0
			return "\(booking.status.text) ➜ \(days) j"
		case .past:
            return booking.status.text
        case .cancelled:
            return booking.status.text
		}
	}

	var body: some View {
		Text(statusText)
            .font(.system(size: 9, weight: .bold))
			.foregroundStyle(WidgetColors.statusText(booking?.status ?? .upcoming))
			.padding(.horizontal, 5)
			.padding(.vertical, 3)
			.background(WidgetColors.statusBackground(booking?.status ?? .upcoming))
			.clipShape(RoundedRectangle(cornerRadius: 7))
	}
}

// MARK: - Vue

private struct WidgetMonthCalendarView: View {

	let bookings: [RU_Booking]

	private let calendar = Calendar.current
    private static let cellHSpacing: CGFloat = 10
    private static let cellVSpacing: CGFloat = 3
	private static let weekdaySymbols: [String] = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"]

	private var monthStart: Date {
		calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
	}

	private var monthRange: Range<Int> {
		calendar.range(of: .day, in: .month, for: monthStart) ?? (1..<32)
	}

	/// Index de la première colonne pour le 1er du mois (0 = lundi, 6 = dimanche)
	private var firstWeekday: Int {
		let comp = calendar.component(.weekday, from: monthStart)
		return (comp - 2 + 7) % 7
	}

	private var monthTitle: String {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "fr_FR")
		formatter.dateFormat = "MMMM yyyy"
		return formatter.string(from: monthStart)
	}

	/// Pour chaque réservation qui couvre ce jour : (type, premier jour de la résa, dernier jour).
	private func bookingInfos(forDay day: Int) -> [(type: RU_Platform.PlatformType, isFirstDay: Bool, isLastDay: Bool)] {
		guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) else { return [] }
		let dayStart = calendar.startOfDay(for: date)
		var result: [(RU_Platform.PlatformType, Bool, Bool)] = []
		for booking in bookings {
            
            if !booking.isCancelled, let type = booking.platform?.type {
                let start = calendar.startOfDay(for: booking.dates.start)
                let end = calendar.startOfDay(for: booking.dates.end)
                guard dayStart >= start, dayStart <= end else { continue }
                let isFirstDay = calendar.isDate(date, inSameDayAs: booking.dates.start)
                let isLastDay = calendar.isDate(date, inSameDayAs: booking.dates.end)
                result.append((type, isFirstDay, isLastDay))
            }
		}
		return result
	}

	private func isToday(day: Int) -> Bool {
		guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) else { return false }
		return calendar.isDateInToday(date)
	}

	var body: some View {
		GeometryReader { geometry in
			let titleHeight: CGFloat = 18
			let availableWidth = max(0, geometry.size.width)
			let availableHeight = max(0, geometry.size.height - titleHeight - 4)

			let daysInMonth = monthRange.upperBound - monthRange.lowerBound
			let totalCells = firstWeekday + daysInMonth
			let rows = (totalCells + 6) / 7

			// Largeur : 7 cellules + 6 espacements = toute la largeur disponible
			let cellWidth = (availableWidth - Self.cellHSpacing * 6) / 7
			let rowHeight = rows > 0 ? (availableHeight - Self.cellVSpacing * CGFloat(rows - 1)) / CGFloat(rows) : cellWidth

			VStack(spacing: 4) {
                Text(monthTitle.capitalized)
					.font(.system(size: 14, weight: .black))
					.foregroundStyle(.primary)

				HStack(spacing: Self.cellHSpacing) {
					ForEach(Array(Self.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
						Text(symbol)
							.font(.system(size: 10, weight: .bold))
							.foregroundStyle(.secondary)
							.frame(width: cellWidth, height: rowHeight, alignment: .center)
					}
				}

				VStack(spacing: Self.cellVSpacing) {
					ForEach(0..<rows, id: \.self) { row in
						HStack(spacing: Self.cellHSpacing) {
							ForEach(0..<7, id: \.self) { col in
								let cellIndex = row * 7 + col
								if cellIndex >= firstWeekday, cellIndex < firstWeekday + daysInMonth {
									let day = cellIndex - firstWeekday + 1
									let infos = bookingInfos(forDay: day)
									VStack(spacing: 1) {
										Text("\(day)")
											.font(.system(size: 10, weight: isToday(day: day) ? .black : infos.isEmpty ? .regular : .medium))
											.foregroundStyle(.secondary)
										if !infos.isEmpty {
											VStack(spacing: 1) {
												ForEach(Array(infos.enumerated()), id: \.offset) { _, info in
													Group {
														if info.isFirstDay && info.isLastDay {
															RoundedRectangle(cornerRadius: 1.5)
																.fill(WidgetColors.platformBackground(info.type))
																.frame(width: cellWidth / 2, height: 3)
																.frame(maxWidth: .infinity, alignment: .center)
														} else if info.isFirstDay {
															RoundedRectangle(cornerRadius: 1.5)
																.fill(WidgetColors.platformBackground(info.type))
																.frame(width: cellWidth / 2, height: 3)
																.frame(maxWidth: .infinity, alignment: .trailing)
														} else if info.isLastDay {
															RoundedRectangle(cornerRadius: 1.5)
																.fill(WidgetColors.platformBackground(info.type))
																.frame(width: cellWidth / 2, height: 3)
																.frame(maxWidth: .infinity, alignment: .leading)
														} else {
															RoundedRectangle(cornerRadius: 1.5)
																.fill(WidgetColors.platformBackground(info.type))
																.frame(maxWidth: .infinity)
																.frame(height: 3)
														}
													}
												}
											}
											.frame(maxWidth: .infinity)
										}
									}
									.frame(width: cellWidth, height: rowHeight)
									.clipShape(RoundedRectangle(cornerRadius: 4))
								} else {
									Color.clear
										.frame(width: cellWidth, height: rowHeight)
								}
							}
						}
					}
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
		.frame(minHeight: 170)
	}
}

private struct InfoTag: View {

	let value: Int
	let label: String

	var body: some View {
		Text("\(value) \(label)")
			.font(.system(size: 9, weight: .medium))
			.foregroundStyle(.black)
			.padding(.horizontal, 5)
			.padding(.vertical, 3)
			.background(Color.primary.opacity(0.08))
			.clipShape(RoundedRectangle(cornerRadius: 5))
	}
}

private struct BookingStackView: View {

	let booking: RU_Booking
    var widgetFamily: WidgetFamily = .systemSmall

	private var bookingTitle: String {
		booking.classified?.name ?? booking.platform?.type?.rawValue ?? "—"
	}

	private var nights: Int {
		max(0, Calendar.current.dateComponents([.day], from: booking.dates.start, to: booking.dates.end).day ?? 0)
	}

	private var guests: Int {
		(booking.travelers.adults ?? 0) + (booking.travelers.children ?? 0) + (booking.travelers.babies ?? 0)
	}

	private var doubles: Int { booking.beds.doubles ?? 0 }
	private var singles: Int { booking.beds.singles ?? 0 }
	private var babies: Int { booking.beds.babies ?? 0 }

	var body: some View {
        VStack(alignment: .center, spacing: widgetFamily == .systemSmall ? 7.5 : 10) {
            
            HStack(alignment: .center, spacing: 7.5) {
                
                StatusBadge(booking: booking)
                PlatformBadge(platform: booking.platform)
            }

			Text(bookingTitle)
                .font(.system(size: 16, weight: .black))
				.lineLimit(1)

            if widgetFamily != .systemSmall {
                
				VStack(alignment: .center, spacing: 5) {
                    
					if nights != 0 || guests != 0 {
                        
						HStack(spacing: 5) {
                            
							if nights != 0 { InfoTag(value: nights, label: "nuits") }
							if guests != 0 { InfoTag(value: guests, label: "pers.") }
						}
					}
                    
					if doubles != 0 || singles != 0 || babies != 0 {
                        
						HStack(spacing: 5) {
                            
							if doubles != 0 { InfoTag(value: doubles, label: "doubles") }
							if singles != 0 { InfoTag(value: singles, label: "simples") }
							if babies != 0 { InfoTag(value: babies, label: "bébé") }
						}
					}
				}
			}
		}
		.frame(maxWidth: .infinity, alignment: .center)
	}
}

struct BookingsWidgetEntryView: View {

	@Environment(\.widgetFamily) private var widgetFamily
	var entry: Provider.Entry

	var body: some View {

		if entry.currentBooking != nil || entry.nextBooking != nil {

			switch widgetFamily {
			case .systemSmall:
                VStack(alignment: .center, spacing: 15) {
					if let current = entry.currentBooking {
						BookingStackView(booking: current, widgetFamily: widgetFamily)
					}
					if entry.currentBooking != nil && entry.nextBooking != nil {
						Divider()
					}
					if let next = entry.nextBooking {
						BookingStackView(booking: next, widgetFamily: widgetFamily)
					}
				}
			default:
                VStack(alignment: .center, spacing: 15) {
                    HStack(alignment: .center, spacing: 15) {
                        if let current = entry.currentBooking {
                            BookingStackView(booking: current, widgetFamily: widgetFamily)
                        }
                        if entry.currentBooking != nil && entry.nextBooking != nil {
                            Divider()
                        }
                        if let next = entry.nextBooking {
                            BookingStackView(booking: next, widgetFamily: widgetFamily)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(maxHeight: widgetFamily == .systemLarge ? nil : .infinity)

                    if widgetFamily == .systemLarge {
                        Divider()
                        WidgetMonthCalendarView(bookings: entry.bookings)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 30)
                            .padding(.horizontal, 15)
                    }
                }
			}
		}
		else {

			VStack(spacing: 4) {

				Image(systemName: "calendar.badge.exclamationmark")
					.font(.title2)
					.foregroundStyle(.secondary)

				Text("Aucune réservation")
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
	}
}

// MARK: - Widget

struct BookingsWidget: Widget {

	let kind: String = "BookingsWidget"

	var body: some WidgetConfiguration {

		StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BookingsWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
		}
		.configurationDisplayName("Réservations")
		.description("Réservation en cours et prochaine réservation.")
	}
}

#Preview(as: .systemSmall) {
    
	BookingsWidget()
    
} timeline: {
    
	RU_Bookings_TimeLineEntry()
}
