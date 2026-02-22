//
//  RU_Platform.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit

extension RU_Platform.PlatformType {
	
	public var backgroundColor: UIColor {
		
		switch self {
		case .airbnb:
			return Colors.Platform.Background.Airbnb
		case .booking:
			return Colors.Platform.Background.Booking
		case .abritel:
			return Colors.Platform.Background.Abritel
		}
	}
	
	public var textColor: UIColor {
		
		switch self {
		case .airbnb:
			return Colors.Platform.Text.Airbnb
		case .booking:
			return Colors.Platform.Text.Booking
		case .abritel:
			return Colors.Platform.Text.Abritel
		}
	}
	
	public var priceFormulaTraveler: String {
		
		return String(key: "platform.\(rawValue).priceFormula.traveler")
	}
	
	public var priceFormulaHost: String {
		
		return String(key: "platform.\(rawValue).priceFormula.host")
	}
}
