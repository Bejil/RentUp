//
//  WidgetBookingLink.swift
//  BookingsWidget
//

import SwiftUI

/// Zone cliquable dédiée par réservation (Link plutôt que widgetURL pour éviter les conflits en medium/large).
struct WidgetBookingLink<Content: View>: View {
	
	let bookingID: String?
	@ViewBuilder let content: () -> Content
	
	var body: some View {
		if let bookingID, let url = WidgetBookingDeepLink.url(forBookingID: bookingID) {
			Link(destination: url) {
				content()
			}
		} else {
			content()
		}
	}
}
