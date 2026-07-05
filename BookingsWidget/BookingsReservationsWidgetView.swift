//
//  BookingsReservationsWidgetView.swift
//  BookingsWidget
//

import SwiftUI
import WidgetKit

struct BookingsReservationsWidgetView: View {
	
	let entry: BookingsCalendarEntry
	let isSmall: Bool
	
	private var highlight: WidgetBookingsHighlight { entry.highlight }
	private let cardSpacing: CGFloat = 10
	
	var body: some View {
		Group {
			if highlight.hasAnyBooking {
				bookingsContent
			} else {
				emptyState
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
	
	@ViewBuilder
	private var bookingsContent: some View {
		if isSmall {
			if let current = highlight.current {
				WidgetCurrentBookingView(booking: current, referenceDate: entry.date)
			} else if let upcoming = highlight.upcoming {
				WidgetUpcomingBookingView(booking: upcoming, referenceDate: entry.date)
			}
		} else if let current = highlight.current, let upcoming = highlight.upcoming {
			HStack(spacing: cardSpacing) {
				WidgetCurrentBookingView(booking: current, referenceDate: entry.date)
					.frame(maxWidth: .infinity)
				sectionDivider
				WidgetUpcomingBookingView(booking: upcoming, referenceDate: entry.date)
					.frame(maxWidth: .infinity)
			}
		} else if let current = highlight.current {
			centeredBooking {
				WidgetCurrentBookingView(booking: current, referenceDate: entry.date)
			}
		} else if let upcoming = highlight.upcoming {
			centeredBooking {
				WidgetUpcomingBookingView(booking: upcoming, referenceDate: entry.date)
			}
		}
	}
	
	private func centeredBooking<Content: View>(@ViewBuilder content: () -> Content) -> some View {
		HStack {
			Spacer(minLength: 0)
			content()
				.frame(maxWidth: 260)
			Spacer(minLength: 0)
		}
	}
	
	private var emptyState: some View {
		Group {
			if isSmall {
				VStack(alignment: .leading, spacing: 6) {
					WidgetReservationsEmptyStateView()
					Spacer(minLength: 0)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
			} else {
				HStack {
					Spacer(minLength: 0)
					VStack(alignment: .leading, spacing: 8) {
						WidgetReservationsEmptyStateView()
						Spacer(minLength: 0)
					}
					.frame(maxWidth: 260, maxHeight: .infinity, alignment: .topLeading)
					Spacer(minLength: 0)
				}
			}
		}
	}
	
	private var sectionDivider: some View {
		Rectangle()
			.fill(WidgetColors.mutedText.opacity(0.25))
			.frame(width: 1)
			.padding(.vertical, 4)
	}
}

struct WidgetReservationsEmptyStateView: View {
	
	var body: some View {
		Group {
			Text("À venir")
				.font(.system(size: 9, weight: .black))
				.foregroundStyle(WidgetColors.mutedText)
				.textCase(.uppercase)
			Text("Aucune réservation")
				.font(.system(size: 12, weight: .black))
				.foregroundStyle(WidgetColors.text)
		}
	}
}

#Preview("Small", as: .systemSmall) {
	BookingsCalendarWidget()
} timeline: {
	let now = Date()
	BookingsCalendarEntry(
		date: now,
		month: WidgetCalendarMonthBuilder.build(for: now, bookings: []),
		highlight: WidgetBookingsHighlight(
			current: WidgetBookingItem(
				id: "1",
				start: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now,
				end: Calendar.current.date(byAdding: .day, value: 3, to: now) ?? now,
				platformType: "airbnb",
				classifiedID: "a",
				classifiedName: "Appartement Paris",
				doubleBeds: 1,
				singleBeds: 2,
				babyBeds: 1,
				isCancelled: false
			),
			upcoming: nil
		),
		classifiedName: "Appartement Paris",
		selectedClassifiedID: "a",
		hasBookings: true,
		isConfigured: true
	)
}

#Preview("Deux réservations", as: .systemMedium) {
	BookingsCalendarWidget()
} timeline: {
	let now = Date()
	BookingsCalendarEntry(
		date: now,
		month: WidgetCalendarMonthBuilder.build(for: now, bookings: []),
		highlight: WidgetBookingsHighlight(
			current: WidgetBookingItem(
				id: "1",
				start: Calendar.current.date(byAdding: .day, value: -2, to: now) ?? now,
				end: Calendar.current.date(byAdding: .day, value: 2, to: now) ?? now,
				platformType: "airbnb",
				classifiedID: "a",
				classifiedName: "Appartement Paris",
				doubleBeds: 1,
				singleBeds: 0,
				babyBeds: 1,
				isCancelled: false
			),
			upcoming: WidgetBookingItem(
				id: "2",
				start: Calendar.current.date(byAdding: .day, value: 8, to: now) ?? now,
				end: Calendar.current.date(byAdding: .day, value: 12, to: now) ?? now,
				platformType: "booking",
				classifiedID: "b",
				classifiedName: "Studio Lyon",
				doubleBeds: 2,
				singleBeds: 1,
				babyBeds: 0,
				isCancelled: false
			)
		),
		classifiedName: "Appartement Paris",
		selectedClassifiedID: "a",
		hasBookings: true,
		isConfigured: true
	)
}
