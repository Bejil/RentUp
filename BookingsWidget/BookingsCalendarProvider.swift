//
//  BookingsCalendarProvider.swift
//  BookingsWidget
//

import WidgetKit

struct BookingsCalendarEntry: TimelineEntry {
	
	let date: Date
	let month: WidgetCalendarMonth
	let highlight: WidgetBookingsHighlight
	let classifiedName: String?
	let selectedClassifiedID: String?
	let hasBookings: Bool
	let isConfigured: Bool
}

struct BookingsCalendarProvider: AppIntentTimelineProvider {
	
	typealias Intent = BookingsWidgetConfigurationIntent
	
	func placeholder(in context: Context) -> BookingsCalendarEntry {
		.previewSample()
	}
	
	func snapshot(for configuration: BookingsWidgetConfigurationIntent, in context: Context) async -> BookingsCalendarEntry {
		if context.isPreview {
			return .previewSample()
		}
		return makeEntry(for: Date(), snapshot: WidgetBookingsStore.load(), classified: configuration.classified)
	}
	
	func timeline(for configuration: BookingsWidgetConfigurationIntent, in context: Context) async -> Timeline<BookingsCalendarEntry> {
		let now = Date()
		let entry = makeEntry(for: now, snapshot: WidgetBookingsStore.load(), classified: configuration.classified)
		let calendar = WidgetCalendarMonthBuilder.calendar
		let nextRefresh = calendar.date(byAdding: .hour, value: 1, to: now) ?? now.addingTimeInterval(3600)
		return Timeline(entries: [entry], policy: .after(nextRefresh))
	}
	
	private func makeEntry(
		for date: Date,
		snapshot: WidgetBookingsSnapshot?,
		classified: WidgetClassifiedEntity?
	) -> BookingsCalendarEntry {
		let resolvedClassified = resolveClassified(classified)
		let selectedClassifiedID = resolvedClassified?.id
		let allBookings = snapshot?.bookings ?? []
		let bookings = WidgetBookingsFilter.bookings(allBookings, for: selectedClassifiedID)
		let month = WidgetCalendarMonthBuilder.build(for: date, bookings: bookings, now: date)
		let highlight = WidgetBookingsHighlight.resolve(from: bookings, now: date)
		let classifiedName = resolvedClassified?.displayName
			?? WidgetBookingsFilter.classifiedName(for: selectedClassifiedID)
			?? WidgetBookingsHighlight.primaryClassifiedName(from: bookings, highlight: highlight)
		
		return BookingsCalendarEntry(
			date: date,
			month: month,
			highlight: highlight,
			classifiedName: classifiedName,
			selectedClassifiedID: selectedClassifiedID,
			hasBookings: !bookings.isEmpty,
			isConfigured: resolvedClassified != nil
		)
	}
	
	private func resolveClassified(_ classified: WidgetClassifiedEntity?) -> WidgetClassifiedEntity? {
		if let classified {
			return classified
		}
		return WidgetClassifiedCatalog.allItems().first.map(WidgetClassifiedEntity.init(item:))
	}
}
