//
//  WidgetClassifiedCatalog.swift
//  RentUpShared
//

import Foundation

public enum WidgetClassifiedCatalog {
	
	public static func allItems() -> [WidgetClassifiedItem] {
		let stored = WidgetClassifiedsStore.load()?.classifieds ?? []
		let fromBookings = itemsFromBookings()
		
		if stored.isEmpty { return fromBookings }
		if fromBookings.isEmpty { return stored }
		
		var merged = stored
		var seen = Set(stored.map(\.id))
		for item in fromBookings where seen.insert(item.id).inserted {
			merged.append(item)
		}
		return merged.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
	}
	
	public static func item(for id: String?) -> WidgetClassifiedItem? {
		guard let id, !id.isEmpty else { return nil }
		return allItems().first { $0.id == id }
	}
	
	public static func mergeClassifieds(from bookings: [WidgetBookingItem]) {
		var items = WidgetClassifiedsStore.load()?.classifieds ?? []
		var seen = Set(items.map(\.id))
		
		for booking in bookings {
			guard let id = booking.classifiedID, !id.isEmpty else { continue }
			let name = booking.classifiedName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
			guard !name.isEmpty else { continue }
			guard seen.insert(id).inserted else { continue }
			items.append(WidgetClassifiedItem(id: id, name: name))
		}
		
		guard !items.isEmpty else { return }
		items.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
		WidgetClassifiedsStore.save(WidgetClassifiedsSnapshot(updatedAt: Date(), classifieds: items))
	}
	
	private static func itemsFromBookings() -> [WidgetClassifiedItem] {
		let bookings = WidgetBookingsStore.load()?.bookings ?? []
		var seen = Set<String>()
		var result: [WidgetClassifiedItem] = []
		
		for booking in bookings {
			guard let id = booking.classifiedID, !id.isEmpty else { continue }
			let name = booking.classifiedName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
			guard !name.isEmpty else { continue }
			guard seen.insert(id).inserted else { continue }
			result.append(WidgetClassifiedItem(id: id, name: name))
		}
		
		return result.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
	}
}
