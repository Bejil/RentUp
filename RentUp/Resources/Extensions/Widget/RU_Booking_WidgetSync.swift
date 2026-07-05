//
//  RU_Booking_WidgetSync.swift
//  RentUp
//

import Foundation
import WidgetKit

enum RU_Booking_WidgetSync {
	
	static func updateSnapshot(with bookings: [RU_Booking]?) {
		let active = bookings?.filter { !$0.isCancelled } ?? []
		let items = active.map { booking in
			WidgetBookingItem(
				id: widgetBookingID(for: booking),
				start: booking.dates.start,
				end: booking.dates.end,
				platformType: booking.platform?.type?.rawValue,
				classifiedID: booking.classified?.uuid,
				classifiedName: booking.classified?.name,
				doubleBeds: booking.beds.doubles,
				singleBeds: booking.beds.singles,
				babyBeds: booking.beds.babies,
				isCancelled: booking.isCancelled
			)
		}
		WidgetBookingsStore.save(WidgetBookingsSnapshot(updatedAt: Date(), bookings: items))
		WidgetClassifiedCatalog.mergeClassifieds(from: items)
		WidgetCenter.shared.reloadAllTimelines()
	}
	
	private static func widgetBookingID(for booking: RU_Booking) -> String {
		if let documentID = booking.id, !documentID.isEmpty {
			return documentID
		}
		return booking.uuid
	}
}
