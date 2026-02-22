//
//  RU_Booking.swift
//  RentUp
//
//  Created by BLIN Michael on 21/01/2026.
//

import Foundation

public class RU_Booking : Codable, Equatable {
    
    public enum Status : Codable {
        
        case past
        case current
        case upcoming
        case cancelled
    }
	
	public static func == (lhs: RU_Booking, rhs: RU_Booking) -> Bool {
		
		return lhs.id == rhs.id
	}
	
	public class Dates : Codable {
		
		public var start:Date = .init()
		public var end:Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
	}
	
	public class Travelers : Codable {
		
		public var adults:Int?
		public var children:Int?
		public var babies:Int?
	}
    
    public class Costs : Codable {
        
        public var cleaning:Int?
        public var compensation:Int?
    }
	
	public var id:String = UUID().uuidString
	public var creationDate:Date = .init()
	public var modificationDate:Date = .init()
	public var platform:RU_Platform?
	public var dates:Dates = .init()
	public var travelers:Travelers = .init()
	public var classified:RU_Classified?
	public var beds:RU_Classified.Configuration.Beds = .init()
	public var comment:String?
    public var costs:Costs = .init()
    public var isCancelled:Bool = false
}
