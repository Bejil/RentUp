//
//  BookingsWidget.swift
//  BookingsWidget
//

import AppIntents
import WidgetKit
import SwiftUI

@main
struct BookingsWidgetBundle: WidgetBundle {
	
	var body: some Widget {
		BookingsCalendarWidget()
	}
}

struct BookingsCalendarWidget: Widget {
	
	let kind = "BookingsCalendarWidget"
	
	var body: some WidgetConfiguration {
		AppIntentConfiguration(kind: kind, intent: BookingsWidgetConfigurationIntent.self, provider: BookingsCalendarProvider()) { entry in
			BookingsCalendarWidgetView(entry: entry)
				.containerBackground(for: .widget) {
					WidgetColors.viewBackground
				}
		}
		.contentMarginsDisabled()
		.configurationDisplayName("Calendrier")
		.description("Réservations et calendrier par bien.")
		.supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
	}
}
