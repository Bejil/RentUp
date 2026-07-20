//
//  RU_Classified.swift
//  RentUp
//
//  Created by BLIN Michael on 24/01/2026.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

public class RU_Classified : Codable, Equatable {
	
	public static func == (lhs: RU_Classified, rhs: RU_Classified) -> Bool {
		
		return lhs.uuid == rhs.uuid
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
	
	public class ChecklistItem : Codable, Equatable {
		
		public static func == (lhs: ChecklistItem, rhs: ChecklistItem) -> Bool {
			
			return lhs.uuid == rhs.uuid
		}
		
		public var uuid:String = UUID().uuidString
		public var title:String?
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
	
    @DocumentID public var id: String?
    public var uuid:String = UUID().uuidString
    public var uid:String? = RU_Account.shared.user?.uid
	public var creationDate:Date = .init()
	public var modificationDate:Date = .init()
	public var name:String?
    public var fees:Int?
	public var configuration:Configuration = .init()
	public var tarification:[Tarification] = .init()
	public var checklist:[ChecklistItem]?
}
