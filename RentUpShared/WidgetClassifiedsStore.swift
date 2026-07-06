//
//  WidgetClassifiedsStore.swift
//  RentUpShared
//

import Foundation

public struct WidgetClassifiedItem: Codable, Identifiable, Equatable {
	
	public var id: String
	public var name: String
	
	public init(id: String, name: String) {
		self.id = id
		self.name = name
	}
}

public struct WidgetClassifiedsSnapshot: Codable, Equatable {
	
	public var updatedAt: Date
	public var classifieds: [WidgetClassifiedItem]
	
	public init(updatedAt: Date, classifieds: [WidgetClassifiedItem]) {
		self.updatedAt = updatedAt
		self.classifieds = classifieds
	}
}

public enum WidgetClassifiedsStore {
	
	public static let storageKey = "widgetClassifiedsSnapshot"
	
	public static func load() -> WidgetClassifiedsSnapshot? {
		guard let data = UserDefaults(suiteName: WidgetBookingsStore.appGroupID)?.data(forKey: storageKey) else {
			return nil
		}
		return try? JSONDecoder().decode(WidgetClassifiedsSnapshot.self, from: data)
	}
	
	public static func save(_ snapshot: WidgetClassifiedsSnapshot) {
		guard let data = try? JSONEncoder().encode(snapshot) else { return }
		UserDefaults(suiteName: WidgetBookingsStore.appGroupID)?.set(data, forKey: storageKey)
	}
}

public enum WidgetBookingsFilter {
	
	public static func bookings(_ bookings: [WidgetBookingItem], for classifiedID: String?) -> [WidgetBookingItem] {
		guard let classifiedID, !classifiedID.isEmpty else { return bookings }
		return bookings.filter { $0.classifiedID == classifiedID }
	}
	
	public static func classifiedName(for classifiedID: String?) -> String? {
		guard let classifiedID, !classifiedID.isEmpty else { return nil }
		return WidgetClassifiedCatalog.item(for: classifiedID)?.name
	}
}
