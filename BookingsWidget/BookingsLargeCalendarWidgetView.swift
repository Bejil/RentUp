//
//  BookingsLargeCalendarWidgetView.swift
//  BookingsWidget
//

import SwiftUI
import WidgetKit

struct BookingsLargeCalendarWidgetView: View {
	
	let entry: BookingsCalendarEntry
	
	private let sectionSpacing: CGFloat = 10
	private let barHeight: CGFloat = 5
	private let dayCornerRadius: CGFloat = 7.5
	private let dayHorizontalInset: CGFloat = 3.75
	private let dayVerticalInset: CGFloat = 7.5
	private let horizontalDayGap: CGFloat = 2
	private let weekRowGap: CGFloat = 15
	private let maxVisibleBarRows: Int = 3
	
	var body: some View {
		calendarContent
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
	}
	
	private var calendarContent: some View {
		VStack(alignment: .leading, spacing: sectionSpacing) {
			weekdayHeader
			GeometryReader { geometry in
				calendarGrid(gridWidth: geometry.size.width, gridHeight: geometry.size.height)
					.frame(width: geometry.size.width, height: geometry.size.height)
			}
		}
	}
	
	private var weekdayHeader: some View {
		HStack(spacing: horizontalDayGap) {
			ForEach(entry.month.weekdaySymbols, id: \.self) { symbol in
				Text(symbol)
					.font(.system(size: 10, weight: .bold))
					.foregroundStyle(WidgetColors.mutedText)
					.frame(maxWidth: .infinity)
			}
		}
	}
	
	private func calendarGrid(gridWidth: CGFloat, gridHeight: CGFloat) -> some View {
		let weekCount = entry.month.weeks.count
		let totalGapHeight = weekRowGap * CGFloat(max(0, weekCount - 1))
		let rowHeight = weekCount > 0 ? max(0, (gridHeight - totalGapHeight) / CGFloat(weekCount)) : 0
		let cellWidth = cellWidth(for: gridWidth)
		
		return VStack(spacing: weekRowGap) {
			ForEach(entry.month.weeks) { week in
				weekRow(week, gridWidth: gridWidth, cellWidth: cellWidth, rowHeight: rowHeight)
			}
		}
		.frame(width: gridWidth, height: gridHeight)
	}
	
	private func cellWidth(for gridWidth: CGFloat) -> CGFloat {
		(gridWidth - horizontalDayGap * 6) / 7
	}
	
	private func weekRow(_ week: WidgetCalendarWeek, gridWidth: CGFloat, cellWidth: CGFloat, rowHeight: CGFloat) -> some View {
		HStack(spacing: horizontalDayGap) {
			ForEach(week.days) { day in
				WidgetDayCellView(
					day: day,
					barHeight: barHeight,
					cornerRadius: dayCornerRadius,
					horizontalInset: dayHorizontalInset,
					verticalInset: dayVerticalInset,
					maxVisibleBarRows: maxVisibleBarRows,
					isCompact: false
				)
				.frame(width: cellWidth, height: rowHeight)
			}
		}
		.frame(width: gridWidth, height: rowHeight)
	}
}

private struct WidgetDayCellView: View {
	
	let day: WidgetCalendarDay
	let barHeight: CGFloat
	let cornerRadius: CGFloat
	let horizontalInset: CGFloat
	let verticalInset: CGFloat
	let maxVisibleBarRows: Int
	let isCompact: Bool
	
	private var visibleBarRows: [WidgetBookingBarRow] {
		Array(day.barRows.prefix(maxVisibleBarRows))
	}
	
	private var totalHiddenBarCount: Int {
		day.hiddenBarCount + max(0, day.barRows.count - visibleBarRows.count)
	}
	
	var body: some View {
		Group {
			if let dayNumber = day.dayNumber {
				WidgetBookingLink(bookingID: day.linkBookingID) {
					dayCellContent(dayNumber: dayNumber)
				}
			} else {
				Color.clear
			}
		}
	}
	
	private func dayCellContent(dayNumber: Int) -> some View {
		VStack(spacing: 3) {
			barsSection
			Spacer(minLength: 0)
			Text("\(dayNumber)")
				.font(.system(size: 12, weight: dayNumberFontWeight))
				.foregroundStyle(dayNumberColor)
				.lineLimit(1)
				.minimumScaleFactor(0.7)
		}
		.padding(.vertical, verticalInset)
		.padding(.horizontal, horizontalInset)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background {
			RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
				.fill(dayBackgroundColor)
		}
		.clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
		.shadow(color: .black.opacity(0.1), radius: 18, x: 0, y: 4)
	}
	
	@ViewBuilder
	private var barsSection: some View {
		VStack(spacing: 2) {
			if !visibleBarRows.isEmpty {
				Spacer().frame(height: 2)
			}
			ForEach(visibleBarRows) { row in
				WidgetBookingBarRowView(
					segments: row.segments,
					barHeight: barHeight,
					segmentGap: 3
				)
			}
			if totalHiddenBarCount > 0 {
				Text("+\(totalHiddenBarCount)")
					.font(.system(size: 9, weight: .bold))
					.foregroundStyle(WidgetColors.mutedText)
					.lineLimit(1)
			}
		}
		.frame(maxWidth: .infinity)
	}
	
	private var dayBackgroundColor: Color {
		if day.isToday {
			return WidgetColors.primary.opacity(0.12)
		}
		return WidgetColors.viewBackground
	}
	
	private var dayNumberFontWeight: Font.Weight {
		day.isToday ? .bold : .regular
	}
	
	private var dayNumberColor: Color {
		if day.isToday && !day.barRows.isEmpty {
			return WidgetColors.primary
		}
		if day.isToday {
			return WidgetColors.secondary
		}
		if !day.barRows.isEmpty {
			return WidgetColors.primary
		}
		return WidgetColors.text
	}
}

private struct WidgetBookingBarRowView: View {
	
	let segments: [WidgetBookingBarSegment]
	let barHeight: CGFloat
	let segmentGap: CGFloat
	
	var body: some View {
		if segments.count == 1, let segment = segments.first {
			GeometryReader { geometry in
				barShape(for: segment)
					.frame(
						width: barWidth(for: segment, totalWidth: geometry.size.width),
						height: barHeight
					)
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: barAlignment(for: segment))
			}
			.frame(height: barHeight)
		} else {
			HStack(spacing: segmentGap) {
				ForEach(segments) { segment in
					barShape(for: segment)
						.frame(height: barHeight)
						.frame(maxWidth: .infinity)
				}
			}
			.frame(height: barHeight)
		}
	}
	
	private func barWidth(for segment: WidgetBookingBarSegment, totalWidth: CGFloat) -> CGFloat {
		if segment.isStartDate && segment.isEndDate {
			return totalWidth * 0.5
		}
		if segment.isStartDate || segment.isEndDate {
			return totalWidth * 0.5
		}
		return totalWidth
	}
	
	private func barAlignment(for segment: WidgetBookingBarSegment) -> Alignment {
		if segment.isStartDate && segment.isEndDate {
			return .center
		}
		if segment.isStartDate {
			return .trailing
		}
		if segment.isEndDate {
			return .leading
		}
		return .center
	}
	
	private func barShape(for segment: WidgetBookingBarSegment) -> some View {
		let radius = barHeight / 2
		return UnevenRoundedRectangle(
			topLeadingRadius: segment.isStartDate ? radius : 0,
			bottomLeadingRadius: segment.isStartDate ? radius : 0,
			bottomTrailingRadius: segment.isEndDate ? radius : 0,
			topTrailingRadius: segment.isEndDate ? radius : 0,
			style: .continuous
		)
		.fill(WidgetColors.platformColor(for: segment.platformType))
	}
}

#Preview(as: .systemLarge) {
	BookingsCalendarWidget()
} timeline: {
	let now = Date()
	BookingsCalendarEntry(
		date: now,
		month: WidgetCalendarMonthBuilder.build(for: now, bookings: []),
		highlight: WidgetBookingsHighlight(current: nil, upcoming: nil),
		classifiedName: "Mon bien",
		selectedClassifiedID: "a",
		hasBookings: false,
		isConfigured: true
	)
}
