//
//  RU_Booking.swift
//  RentUp
//
//  Created by BLIN Michael on 21/01/2026.
//

import UIKit

extension RU_Booking {
	
	public var status:RU_Booking_Status {
		
		let now = Date()
		
		if dates.end < now {
			
			return .past
		}
		else if dates.start <= now && dates.end >= now {
			
			return .current
		}
		
		return .upcoming
	}
	public var canSave:Bool {
		
		return platform != nil && dates.end > dates.start && travelers.adults ?? 0 >= 1 && (beds.doubles ?? 0 >= 1 || beds.singles ?? 0 >= 1)
	}
	
	public static func getAll(_ completion:((Error?,[RU_Booking]?)->Void)?) {
		
		if let data = UserDefaults.get(.bookings) as? Data {
			
			do {
				
				let bookings = try JSONDecoder().decode([RU_Booking].self, from: data)
				completion?(nil,bookings.sorted(by: { $0.dates.start > $1.dates.start }))
			}
			catch {
				
				completion?(RU_Error(String(key: "bookings.error.getAll")),nil)
			}
		}
		else {
			
			completion?(nil,[])
		}
	}
	
	public func save(_ completion:((Error?)->Void)?) {
		
		RU_Booking.getAll { [weak self] error, bookings in
			
			if error != nil {
				
				completion?(RU_Error(String(key: "bookings.error.save")))
			}
			else if let self, var bookings {
				
				if let index = bookings.firstIndex(of: self) {
					
					self.modificationDate = Date()
					bookings[index] = self
				}
				else {
					
					bookings.append(self)
				}
				
				do {
					
					let data = try JSONEncoder().encode(bookings)
					UserDefaults.set(data, .bookings)
					
					completion?(nil)
				}
				catch {
					
					completion?(RU_Error(String(key: "bookings.error.save")))
				}
			}
			else {
				
				completion?(RU_Error(String(key: "bookings.error.save")))
			}
		}
	}
	
	public func delete(_ completion:((Error?)->Void)?) {
		
		RU_Booking.getAll { [weak self] error, bookings in
			
			if error != nil {
				
				completion?(RU_Error(String(key: "bookings.error.delete")))
			}
			else if let self, var bookings {
				
				if bookings.contains(self) {
					
					bookings.removeAll { $0.id == self.id }
					
					do {
						
						let data = try JSONEncoder().encode(bookings)
						UserDefaults.set(data, .bookings)
						
						completion?(nil)
					}
					catch {
						
						completion?(RU_Error(String(key: "bookings.error.delete")))
					}
				}
				else {
					
					completion?(RU_Error(String(key: "bookings.error.delete")))
				}
			}
			else {
				
				completion?(RU_Error(String(key: "bookings.error.delete")))
			}
		}
	}
}

extension [RU_Booking] {
    
    public var current:RU_Booking? {

        return first { $0.status == .current }
    }
    
    public var next:RU_Booking? {

        let upcoming = filter { $0.status == .upcoming }.sorted { $0.dates.start < $1.dates.start }
        return upcoming.first
    }
}
