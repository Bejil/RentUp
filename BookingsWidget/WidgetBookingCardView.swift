//
//  WidgetBookingCardView.swift
//  BookingsWidget
//

import SwiftUI

private let widgetBookingCardVerticalPadding: CGFloat = 8

/// Réservation en cours — même composant en small et medium.
struct WidgetCurrentBookingView: View {
	
	let booking: WidgetBookingItem
	let referenceDate: Date
	
	var body: some View {
		WidgetBookingLink(bookingID: booking.id) {
			WidgetBookingCardView(
				booking: booking,
				role: .current,
				referenceDate: referenceDate
			)
			.padding(.vertical, widgetBookingCardVerticalPadding)
		}
	}
}

/// Réservation à venir — même composant en small et medium.
struct WidgetUpcomingBookingView: View {
	
	let booking: WidgetBookingItem
	let referenceDate: Date
	
	var body: some View {
		WidgetBookingLink(bookingID: booking.id) {
			WidgetBookingCardView(
				booking: booking,
				role: .upcoming,
				referenceDate: referenceDate
			)
			.padding(.vertical, widgetBookingCardVerticalPadding)
		}
	}
}

private struct WidgetBookingCardView: View {
	
	let booking: WidgetBookingItem
	let role: WidgetBookingHighlightRole
	let referenceDate: Date
	
	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(WidgetBookingPresentation.sectionTitle(for: role))
				.font(.system(size: 9, weight: .black))
				.foregroundStyle(WidgetColors.mutedText)
				.textCase(.uppercase)
			
			statusBadge
			
			Text(WidgetBookingPresentation.dateRangeText(for: booking))
				.font(.system(size: 10, weight: .regular))
				.foregroundStyle(WidgetColors.text)
				.lineLimit(2)
				.minimumScaleFactor(0.8)
			
			bedsRow
			
			Spacer(minLength: 0)
			
			platformBadge
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
	}
	
	private var statusBadge: some View {
		Text(WidgetBookingPresentation.statusBadgeText(for: booking, role: role, now: referenceDate))
			.font(.system(size: 9, weight: .bold))
			.foregroundStyle(roleTextColor)
			.padding(.horizontal, 7)
			.padding(.vertical, 3)
			.background {
				Capsule(style: .continuous)
					.fill(roleBackgroundColor)
			}
			.lineLimit(1)
			.minimumScaleFactor(0.8)
	}
	
	@ViewBuilder
	private var bedsRow: some View {
		let hasBeds = (booking.doubleBeds ?? 0) > 0
			|| (booking.singleBeds ?? 0) > 0
			|| (booking.babyBeds ?? 0) > 0
		
		if hasBeds {
			HStack(spacing: 8) {
				if let count = booking.doubleBeds, count > 0 {
					bedItem(icon: "bed.double.fill", count: count)
				}
				if let count = booking.singleBeds, count > 0 {
					bedItem(icon: "bed.double", count: count)
				}
				if let count = booking.babyBeds, count > 0 {
					bedItem(icon: "stroller", count: count)
				}
			}
		}
	}
	
	private func bedItem(icon: String, count: Int) -> some View {
		HStack(spacing: 3) {
			Image(systemName: icon)
				.font(.system(size: 9, weight: .semibold))
			Text("\(count)")
				.font(.system(size: 9, weight: .bold))
		}
		.foregroundStyle(WidgetColors.mutedText)
	}
	
	private var platformBadge: some View {
		HStack(spacing: 5) {
			Circle()
				.fill(WidgetColors.platformColor(for: booking.platformType))
				.frame(width: 7, height: 7)
			Text(WidgetBookingPresentation.platformName(for: booking.platformType))
				.font(.system(size: 9, weight: .bold))
				.foregroundStyle(WidgetColors.mutedText)
				.lineLimit(1)
		}
	}
	
	private var roleBackgroundColor: Color {
		switch role {
		case .current: return WidgetColors.currentStatusBackground
		case .upcoming: return WidgetColors.upcomingStatusBackground
		}
	}
	
	private var roleTextColor: Color {
		switch role {
		case .current: return WidgetColors.currentStatusText
		case .upcoming: return WidgetColors.upcomingStatusText
		}
	}
}
