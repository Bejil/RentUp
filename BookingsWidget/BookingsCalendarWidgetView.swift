//
//  BookingsCalendarWidgetView.swift
//  BookingsWidget
//

import SwiftUI
import WidgetKit

struct BookingsCalendarWidgetView: View {
	
	@Environment(\.widgetFamily) private var family
	let entry: BookingsCalendarEntry
	
	private var isSmall: Bool { family == .systemSmall }
	private var isMedium: Bool { family == .systemMedium }
	private var outerPadding: CGFloat { isSmall ? 18 : (isMedium ? 20 : 20) }
	private var headerSpacing: CGFloat { isSmall ? 8 : (isMedium ? 10 : 10) }
	
	var body: some View {
		VStack(alignment: .leading, spacing: headerSpacing) {
			WidgetAppHeaderView(
				classifiedName: entry.classifiedName,
				monthTitle: family == .systemLarge ? entry.month.title : nil,
				isCompact: isSmall || isMedium
			)
			
			switch family {
			case .systemSmall, .systemMedium:
				BookingsReservationsWidgetView(entry: entry, isSmall: isSmall)
			default:
				BookingsLargeCalendarWidgetView(entry: entry)
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
		.padding(outerPadding)
	}
}
