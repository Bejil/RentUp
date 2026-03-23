//
//  RU_Booking.swift
//  RentUp
//
//  Created by BLIN Michael on 21/01/2026.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

extension RU_Booking {

	public var status:Status {

		let calendar = Calendar.current
		let now = Date()
		let today = calendar.startOfDay(for: now)
		let startDay = calendar.startOfDay(for: dates.start)
		let endDay = calendar.startOfDay(for: dates.end)

		if isCancelled {

			return .cancelled
		}
		if endDay < today {

			return .past
		}
		if startDay <= today && endDay >= today {

			return .current
		}

		return .upcoming
	}
	public var canSave:Bool {
		
		return platform != nil && dates.end > dates.start && travelers.adults ?? 0 >= 1 && (beds.doubles ?? 0 >= 1 || beds.singles ?? 0 >= 1)
	}
	
	public static func getAll(_ completion:((Error?,[RU_Booking]?)->Void)?) {
		
		Firestore.firestore().collection("bookings").whereField("uid", isEqualTo: RU_Account.shared.user?.uid ?? "").getDocuments { querySnapshot, error in
			
			if error != nil {
				
				completion?(RU_Error(String(key: "bookings.error.getAll")), nil)
			}
			else {
				
                Task { @MainActor in
                    
                    let bookings = querySnapshot?.documents.compactMap { try? $0.data(as: RU_Booking.self) }
                    let sorted = bookings?.sorted(by: { $0.dates.start > $1.dates.start }) ?? []
                    completion?(nil, sorted)
                }
			}
		}
	}
	
	public func save(_ completion:((Error?)->Void)?) {
		
		modificationDate = Date()
		
		let collection = Firestore.firestore().collection("bookings")
		
		if let id = id, !id.isEmpty {
			
			do {
				
				try collection.document(id).setData(from: self)
				completion?(nil)
			}
			catch {
				
				completion?(RU_Error(String(key: "bookings.error.save")))
			}
		}
		else {
			
			do {
				
				let documentReference = try collection.addDocument(from: self)
				id = documentReference.documentID
				completion?(nil)
			}
			catch {
				
				completion?(RU_Error(String(key: "bookings.error.save")))
			}
		}
	}
	
	public func delete(_ completion:((Error?)->Void)?) {
		
		guard let id = id, !id.isEmpty else {
			
			completion?(RU_Error(String(key: "bookings.error.delete")))
			return
		}
		
		Firestore.firestore().collection("bookings").document(id).delete { error in
			
            if error != nil {
				
				completion?(RU_Error(String(key: "bookings.error.delete")))
			}
			else {
				
				completion?(nil)
			}
		}
	}
				
    public static func create() {
        
        RU_Alert_ViewController.presentLoading { controller in
            
            RU_Classified.getAll { error, classifieds in
                
                controller?.close {
                  
                    if let error {
                        
                        RU_Alert_ViewController.present(error)
                    }
                    else if classifieds?.isEmpty ?? true {
                        
                        RU_Alert_ViewController.present(RU_Error(String(key: "bookings.create.noClassifieds")))
                    }
                    else {
                        
                        UI.MainController.present(RU_NavigationController(rootViewController: RU_Bookings_Edit_ViewController()), animated: true)
                    }
                }
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

extension RU_Booking.Status {
    
    public var text: String {
        
        switch self {
        case .past:
            return String(key: "booking.status.past.name")
        case .current:
            return String(key: "booking.status.current.name")
        case .upcoming:
            return String(key: "booking.status.upcoming.name")
        case .cancelled:
            return String(key: "booking.status.cancelled.name")
        }
    }
    
    public var backgroundColor: UIColor {
        
        switch self {
        case .past:
            return Colors.Booking.Status.Past.Background
        case .current:
            return Colors.Booking.Status.Current.Background
        case .upcoming:
            return Colors.Booking.Status.Upcoming.Background
        case .cancelled:
            return Colors.Booking.Status.Cancelled.Background
        }
    }
    
    public var textColor: UIColor {
        
        switch self {
        case .past:
            return Colors.Booking.Status.Past.Text
        case .current:
            return Colors.Booking.Status.Current.Text
        case .upcoming:
            return Colors.Booking.Status.Upcoming.Text
        case .cancelled:
            return Colors.Booking.Status.Cancelled.Text
        }
    }
}
