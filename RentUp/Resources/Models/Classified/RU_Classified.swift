//
//  RU_Classified.swift
//  RentUp
//
//  Created by BLIN Michael on 24/01/2026.
//

import Foundation

public class RU_Classified : Codable, Equatable {
	
	public static func == (lhs: RU_Classified, rhs: RU_Classified) -> Bool {
		
		return lhs.id == rhs.id
	}
	
	public class Configuration : Codable {
		
		public class Beds : Codable {
			
			public var doubles:Int?
			public var singles:Int?
			public var babies:Int?
		}
		
		public var beds:Beds = .init()
		public var capacity:Int?
	}
	
	public class Tarification : Codable {
		
		public class Offer : Codable {
			
			public enum ReductionType : String, Codable {
				
				case week = "week"
				case month = "month"
			}
			
			public var reductiontype:ReductionType?
			public var percent:Int?
		}

		public class Traveler : Codable {
			
			public var included:Int?
			public var extraPrice:Int?
		}
		
		public var platform:RU_Platform?
		public var price:Int?
		public var cleaning:Int?
		public var offers:[Offer] = .init()
		public var travelers:Traveler = .init()
	}
	
	public var id:String = UUID().uuidString
	public var creationDate:Date = .init()
	public var modificationDate:Date = .init()
	public var name:String?
    public var fees:Int?
	public var configuration:Configuration = .init()
	public var tarification:[Tarification] = .init()
}
