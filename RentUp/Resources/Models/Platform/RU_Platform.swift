//
//  RU_Platform.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import Foundation

public class RU_Platform : Codable, Equatable {
	
	public enum PlatformType : String, Codable {
		
		case airbnb = "airbnb"
		case booking = "booking"
		case abritel = "abritel"
	}
	
	public class Value : Codable {
		
		public enum ValueType : Codable {
			
			case absolute
			case percentage
		}
		
		public var type:ValueType?
		public var amount:Double?
	}
	
	public class Commission : Codable {
		
		public var touristTax:Value?
		public var host:Value?
		public var traveler:Value?
		public var platform:Value?
		public var bank:Value?
		public var vat:Value?
	}
	
	public static func == (lhs: RU_Platform, rhs: RU_Platform) -> Bool {
		
		return lhs.id == rhs.id
	}
	
	public var id: String = UUID().uuidString
	public var type: PlatformType? {
		
		didSet {
			
			switch type {
			case .airbnb:
				
				commission.touristTax = .init()
				commission.touristTax?.type = .absolute
				commission.touristTax?.amount = 15.6
				
				commission.host = .init()
				commission.host?.type = .percentage
				commission.host?.amount = 3.0
				
				commission.traveler = .init()
				commission.traveler?.type = .percentage
				commission.traveler?.amount = 17.0
				
				commission.vat = .init()
				commission.vat?.type = .percentage
				commission.vat?.amount = 20.0
				
			case .booking:
				
				commission.touristTax = .init()
				commission.touristTax?.type = .absolute
				commission.touristTax?.amount = 7.4
				
				commission.platform = .init()
				commission.platform?.type = .percentage
				commission.platform?.amount = 17.0
				
				commission.bank = .init()
				commission.bank?.type = .percentage
				commission.bank?.amount = 1.4
				
			case .abritel:
				
				commission.touristTax = .init()
				commission.touristTax?.type = .absolute
				commission.touristTax?.amount = 16.25
				
				commission.traveler = .init()
				commission.traveler?.type = .percentage
				commission.traveler?.amount = 15.3
				
				commission.platform = .init()
				commission.platform?.type = .percentage
				commission.platform?.amount = 6.0
				
				commission.bank = .init()
				commission.bank?.type = .percentage
				commission.bank?.amount = 4.2
				
			default :
				break
			}
		}
	}
	public var commission: Commission = .init()
}
