//
//  WidgetColors.swift
//  BookingsWidget
//

import SwiftUI

enum WidgetColors {
	
	static let primary = Color(red: 27 / 255, green: 73 / 255, blue: 101 / 255)
	static let secondary = Color(red: 46 / 255, green: 196 / 255, blue: 181 / 255)
	static let viewBackground = Color(red: 1, green: 1, blue: 1)
	static let text = Color(red: 27 / 255, green: 73 / 255, blue: 101 / 255)
	static let mutedText = Color(red: 27 / 255, green: 73 / 255, blue: 101 / 255).opacity(0.45)
	static let currentStatusBackground = Color(red: 1, green: 147 / 255, blue: 0)
	static let currentStatusText = Color(red: 254 / 255, green: 1, blue: 1)
	static let upcomingStatusBackground = Color(red: 192 / 255, green: 192 / 255, blue: 192 / 255)
	static let upcomingStatusText = Color(red: 254 / 255, green: 1, blue: 1)
	
	/// Couleurs alignées sur `Colors.xcassets/Platform/Background/*` (display P3).
	static func platformColor(for type: String?) -> Color {
		switch type {
		case "airbnb":
			return Color(red: 1, green: 90 / 255, blue: 96 / 255)
		case "booking":
			return Color(red: 3 / 255, green: 39 / 255, blue: 141 / 255)
		case "abritel":
			return Color(red: 124 / 255, green: 179 / 255, blue: 240 / 255)
		case "direct":
			return Color(red: 46 / 255, green: 161 / 255, blue: 113 / 255)
		default:
			return primary.opacity(0.35)
		}
	}
}
