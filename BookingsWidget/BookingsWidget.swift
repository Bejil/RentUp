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
            
            let timeLineEntry:RU_Bookings_TimeLineEntry = .init()
            timeLineEntry.currentBooking = bookings?.current
            timeLineEntry.nextBooking = bookings?.next
            completion(timeLineEntry)
		}
	}

	func getTimeline(in context: Context, completion: @escaping (Timeline<RU_Bookings_TimeLineEntry>) -> ()) {

		RU_Booking.getAll { _, bookings in
            
            let timeLineEntry:RU_Bookings_TimeLineEntry = .init()
            timeLineEntry.currentBooking = bookings?.current
            timeLineEntry.nextBooking = bookings?.next
            
            let timeline = Timeline(entries: [timeLineEntry], policy: .after(Calendar.current.date(byAdding: .minute, value: 15, to: Date())!))
            
			completion(timeline)
		}
	}
}

// MARK: - Vue

struct BookingsWidgetEntryView: View {

	var entry: Provider.Entry
	private var hasAny: Bool {
        
		entry.currentBooking != nil || entry.nextBooking != nil
	}

	private func title(for booking: RU_Booking) -> String {
        
		booking.classified?.name ?? booking.platform?.type?.rawValue ?? "—"
	}

	private func dateRange(_ booking: RU_Booking) -> String {
        
		let f = DateFormatter()
		f.dateStyle = .short
		f.timeStyle = .none
		f.locale = Locale(identifier: "fr_FR")
		return "\(f.string(from: booking.dates.start)) – \(f.string(from: booking.dates.end))"
	}

	var body: some View {

		if hasAny {
            
			VStack(alignment: .leading, spacing: 10) {
                
				if let current = entry.currentBooking {
                    
					VStack(alignment: .leading, spacing: 2) {
                        
						Text("En cours")
							.font(.caption2)
							.foregroundStyle(.secondary)
                        
						Text(title(for: current))
							.font(.subheadline.weight(.medium))
							.lineLimit(1)
                        
						Text(dateRange(current))
							.font(.caption2)
							.foregroundStyle(.secondary)
					}
					.frame(maxWidth: .infinity, alignment: .leading)
				}
                
				if let next = entry.nextBooking {
                    
					VStack(alignment: .leading, spacing: 2) {
                        
						Text(entry.currentBooking != nil ? "À venir" : "Prochaine réservation")
							.font(.caption2)
							.foregroundStyle(.secondary)
						Text(title(for: next))
							.font(.subheadline.weight(.medium))
							.lineLimit(1)
						Text(dateRange(next))
							.font(.caption2)
							.foregroundStyle(.secondary)
					}
					.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
			.padding()
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
