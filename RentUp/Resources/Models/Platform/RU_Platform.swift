//
//  RU_Platform.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import Foundation
import FirebaseFirestore

public class RU_Platform : Codable, Equatable {
	
	public enum PlatformType : String, Codable {
		
		case airbnb = "airbnb"
		case booking = "booking"
		case abritel = "abritel"
        case direct = "direct"
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
		
		return lhs.uuid == rhs.uuid
	}
	
    @DocumentID public var id: String?
    public var uuid:String = UUID().uuidString
	public var type: PlatformType?
	public var commission: Commission? = .init()
    public var order:Int?
}
