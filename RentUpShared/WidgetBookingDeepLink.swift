//
//  WidgetBookingDeepLink.swift
//  RentUpShared
//

import Foundation

public enum WidgetBookingDeepLink {
	
	public static let scheme = "rentup"
	
	public static func url(forBookingID id: String) -> URL? {
		guard !id.isEmpty else { return nil }
		var components = URLComponents()
		components.scheme = scheme
		components.host = "booking"
		components.queryItems = [URLQueryItem(name: "id", value: id)]
		return components.url
	}
	
	public static func bookingID(from url: URL) -> String? {
		guard url.scheme == scheme, url.host == "booking" else { return nil }
		let value = URLComponents(url: url, resolvingAgainstBaseURL: false)?
			.queryItems?
			.first(where: { $0.name == "id" })?
			.value
		guard let value, !value.isEmpty else { return nil }
		return value
	}
}
