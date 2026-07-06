//
//  WidgetBookingsStore.swift
//  RentUpShared
//

import Foundation

public struct WidgetBookingItem: Codable, Identifiable, Equatable {
	
	public var id: String
	public var start: Date
	public var end: Date
	public var platformType: String?
	public var classifiedID: String?
	public var classifiedName: String?
	public var doubleBeds: Int?
	public var singleBeds: Int?
	public var babyBeds: Int?
	public var isCancelled: Bool
	
	public init(
		id: String,
		start: Date,
		end: Date,
		platformType: String?,
		classifiedID: String?,
		classifiedName: String? = nil,
		doubleBeds: Int? = nil,
		singleBeds: Int? = nil,
		babyBeds: Int? = nil,
		isCancelled: Bool
	) {
		self.id = id
		self.start = start
		self.end = end
		self.platformType = platformType
		self.classifiedID = classifiedID
		self.classifiedName = classifiedName
		self.doubleBeds = doubleBeds
		self.singleBeds = singleBeds
		self.babyBeds = babyBeds
		self.isCancelled = isCancelled
	}
}

public struct WidgetBookingsSnapshot: Codable, Equatable {
	
	public var updatedAt: Date
	public var bookings: [WidgetBookingItem]
	
	public init(updatedAt: Date, bookings: [WidgetBookingItem]) {
		self.updatedAt = updatedAt
		self.bookings = bookings
	}
}

public enum WidgetBookingsStore {
	
	public static let appGroupID = "group.com.michaelblin.RentUp"
	public static let storageKey = "widgetBookingsSnapshot"
	
	public static func load() -> WidgetBookingsSnapshot? {
		guard let data = UserDefaults(suiteName: appGroupID)?.data(forKey: storageKey) else { return nil }
		return try? JSONDecoder().decode(WidgetBookingsSnapshot.self, from: data)
	}
	
	public static func save(_ snapshot: WidgetBookingsSnapshot) {
		guard let data = try? JSONEncoder().encode(snapshot) else { return }
		UserDefaults(suiteName: appGroupID)?.set(data, forKey: storageKey)
	}
}
