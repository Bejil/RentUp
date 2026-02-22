//
//  UserDefaults_Extension.swift
//  ListYa
//
//  Created by BLIN Michael on 21/06/2022.
//

import Foundation

extension UserDefaults {

	public static let appGroupSuiteName = "group.com.michaelblin.RentUp"

	/// Stockage unique : uniquement la suite App Group (jamais .standard).
	public static var suite: UserDefaults? {
		UserDefaults(suiteName: appGroupSuiteName)
	}

	public enum Keys: String, CaseIterable {

		case vibrationsEnabled = "vibrationsEnabled"
		case soundsEnabled = "soundsEnabled"
		case platforms = "platforms"
		case bookings = "bookings"
		case classifieds = "classifieds"
	}

	public static func set(_ value: Any?, _ key: Keys) {

		guard let store = suite else { return }
		store.set(value, forKey: key.rawValue)
		store.synchronize()
	}

	public static func get(_ key: Keys) -> Any? {

		suite?.value(forKey: key.rawValue)
	}

	public static func delete(_ key: Keys) {

		guard let store = suite else { return }
		store.removeObject(forKey: key.rawValue)
		store.synchronize()
	}

	public static func reset() {

		guard let store = suite else { return }
		Keys.allCases.forEach { store.removeObject(forKey: $0.rawValue) }
		store.synchronize()
	}
}
