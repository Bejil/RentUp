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

		if isCancelled {

			return .cancelled
		}
		
		// Fenêtre réelle du séjour : horaires du bien (défaut 12h → 12h).
		let now = Date()
		let checkIn = stayCheckInDate
		let checkOut = stayCheckOutDate
		
		if now >= checkOut {

			return .past
		}
		if now >= checkIn {

			return .current
		}

		return .upcoming
	}
	
	/// Heure d'arrivée / départ par défaut (midi), si le bien n'en définit pas.
	public static let defaultStayTurnoverHour = 12
	
	/// Instant d'arrivée (date de début + horaire du bien, sinon 12h).
	public var stayCheckInDate: Date {
		
		Self.stayBoundaryDate(
			on: dates.start,
			hour: classified?.effectiveCheckInHour ?? Self.defaultStayTurnoverHour,
			minute: classified?.effectiveCheckInMinute ?? 0
		)
	}
	
	/// Instant de départ (date de fin + horaire du bien, sinon 12h).
	public var stayCheckOutDate: Date {
		
		Self.stayBoundaryDate(
			on: dates.end,
			hour: classified?.effectiveCheckOutHour ?? Self.defaultStayTurnoverHour,
			minute: classified?.effectiveCheckOutMinute ?? 0
		)
	}
	
	/// Progression du séjour (0 à l'arrivée 12h, 1 au départ 12h), en temps réel.
	public var stayProgress: CGFloat {
		
		let start = stayCheckInDate
		let end = stayCheckOutDate
		let total = end.timeIntervalSince(start)
		guard total > 0 else {
			return Date() >= end ? 1 : 0
		}
		
		let elapsed = Date().timeIntervalSince(start)
		return CGFloat(min(max(elapsed / total, 0), 1))
	}
	
	/// Fractions 0…1 de chaque minuit (00:00) strictement entre l'arrivée et le départ du séjour.
	public var stayDayBoundaryProgresses: [CGFloat] {
		
		let start = stayCheckInDate
		let end = stayCheckOutDate
		let total = end.timeIntervalSince(start)
		guard total > 0 else { return [] }
		
		let calendar = Calendar.current
		// Premier 00:00 après le jour d'arrivée (horaire d'arrivée du bien).
		guard let firstMidnight = calendar.date(
			byAdding: .day,
			value: 1,
			to: calendar.startOfDay(for: start)
		) else {
			return []
		}
		
		var progresses: [CGFloat] = []
		var cursor = firstMidnight
		while cursor < end {
			let progress = CGFloat(cursor.timeIntervalSince(start) / total)
			if progress > 0.001, progress < 0.999 {
				progresses.append(progress)
			}
			guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
			cursor = next
		}
		return progresses
	}
	
	/// Étape timeline : 0 Arrivée, 1 Séjour, 2 Départ.
	public var stayTimelineStep: Int {
		
		let progress = stayProgress
		if progress <= 0.001 {
			return 0
		}
		if progress >= 0.999 || Date() >= stayCheckOutDate {
			return 2
		}
		return 1
	}
	
	/// Référence plateforme nettoyée (vide → nil).
	public var normalizedPlatformReference: String? {
		guard let raw = platformReference?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
			return nil
		}
		return raw
	}
	
	/// URL vers la réservation sur Airbnb / Booking / Abritel, si référence renseignée.
	public var platformReservationURL: URL? {
		guard let reference = normalizedPlatformReference,
			  let type = platform?.type else {
			return nil
		}
		return type.reservationURL(for: reference)
	}
	
	public var canOpenPlatformReservation: Bool {
		platformReservationURL != nil
	}
	
	private static func stayBoundaryDate(on date: Date, hour: Int, minute: Int = 0) -> Date {
		
		let calendar = Calendar.current
		let day = calendar.startOfDay(for: date)
		return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
	}
	
	public var canSave:Bool {
		
		return platform != nil && dates.end > dates.start && travelers.adults ?? 0 >= 1 && (beds.doubles ?? 0 >= 1 || beds.singles ?? 0 >= 1)
	}
	
	/// Charges du bien figées (snapshot) ou fallback sur le classified embarqué.
	public var effectiveClassifiedFees: Int? {
		
		pricingSnapshot?.classifiedFees ?? classified?.fees
	}
	
	/// Fige tarifs / charges / commissions depuis le bien et la plateforme actuels.
	public func capturePricingSnapshot() {
		
		guard let platform else { return }
		
		let tarification = classified?.tarification.first(where: { $0.platform == platform })
		let snapshot = PricingSnapshot()
		snapshot.capturedAt = Date()
		snapshot.classifiedFees = classified?.fees
		snapshot.pricePerNight = tarification?.price
		snapshot.cleaning = tarification?.cleaning
		snapshot.offers = (tarification?.offers ?? []).map { offer in
			let copy = RU_Classified.Tarification.Offer()
			copy.reductiontype = offer.reductiontype
			copy.percent = offer.percent
			return copy
		}
		let travelersCopy = RU_Classified.Tarification.Traveler()
		travelersCopy.included = tarification?.travelers.included
		travelersCopy.extraPrice = tarification?.travelers.extraPrice
		snapshot.travelers = travelersCopy
		snapshot.platformCommission = Self.copyCommission(platform.commission)
		pricingSnapshot = snapshot
	}
	
	/// Capture uniquement si aucun snapshot n'existe encore (migration douce).
	public func ensurePricingSnapshot() {
		
		guard pricingSnapshot == nil else { return }
		capturePricingSnapshot()
	}
	
	private static func copyCommission(_ commission: RU_Platform.Commission?) -> RU_Platform.Commission? {
		
		guard let commission else { return nil }
		
		let copy = RU_Platform.Commission()
		copy.touristTax = copyValue(commission.touristTax)
		copy.host = copyValue(commission.host)
		copy.traveler = copyValue(commission.traveler)
		copy.platform = copyValue(commission.platform)
		copy.bank = copyValue(commission.bank)
		copy.vat = copyValue(commission.vat)
		return copy
	}
	
	private static func copyValue(_ value: RU_Platform.Value?) -> RU_Platform.Value? {
		
		guard let value else { return nil }
		
		let copy = RU_Platform.Value()
		copy.type = value.type
		copy.amount = value.amount
		return copy
	}
	
	/// Met à jour checklist (et nom) depuis le bien live, sans écraser tarifs / charges / snapshot.
	public func resolveLiveClassified(_ completion:((RU_Classified?)->Void)?) {
		
		guard let classifiedUUID = classified?.uuid, !classifiedUUID.isEmpty else {
			
			completion?(nil)
			return
		}
		
		RU_Classified.getAll { [weak self] _, classifieds in
			
			let live = classifieds?.first(where: { $0.uuid == classifiedUUID })
				?? classifieds?.first(where: { $0.id != nil && $0.id == self?.classified?.id })
			
			if let live, let classified = self?.classified {
				
				classified.checklist = live.checklist
				classified.checkInHour = live.checkInHour
				classified.checkInMinute = live.checkInMinute
				classified.checkOutHour = live.checkOutHour
				classified.checkOutMinute = live.checkOutMinute
				if let name = live.name, !name.isEmpty {
					classified.name = name
				}
			}
			
			completion?(live)
		}
	}
	
    public static var shouldPresentReporting:Bool {
        
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        let isWithinFirstDays = day <= 5
        let monthKey = String(format: "%04d-%02d", year, month)
        
        let state = UserDefaults.get(.reportingAlertLastShownMonthKey) as? String != monthKey
        let shouldPresent = isWithinFirstDays && state
        
        if shouldPresent {
            
            UserDefaults.set(monthKey, .reportingAlertLastShownMonthKey)
        }
        
        return shouldPresent
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
					
					RU_Classified.getAll { _, classifieds in
						
						if let classifieds {
							
							for booking in sorted {
								
								booking.applyLiveSchedule(from: classifieds)
							}
						}
						
						RU_Booking_WidgetSync.updateSnapshot(with: sorted)
						completion?(nil, sorted)
					}
                }
			}
		}
	}
	
	/// Applique les horaires live du bien (sans écraser le reste du snapshot embarqué).
	public func applyLiveSchedule(from classifieds: [RU_Classified]) {
		
		guard let classified else { return }
		
		let live = classifieds.first(where: { $0.uuid == classified.uuid })
			?? classifieds.first(where: { $0.id != nil && $0.id == classified.id })
		
		guard let live else { return }
		
		classified.checkInHour = live.checkInHour
		classified.checkInMinute = live.checkInMinute
		classified.checkOutHour = live.checkOutHour
		classified.checkOutMinute = live.checkOutMinute
	}
	
	public func save(_ completion:((Error?)->Void)?) {
		
		modificationDate = Date()
		ensurePricingSnapshot()
		
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
				
    public static func create(startDate: Date? = nil) {
        
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
                        
                        let viewController = RU_Bookings_Edit_ViewController()
                        if let startDate {
                            viewController.presetStartDate = Calendar.current.startOfDay(for: startDate)
                        }
                        UI.MainController.present(RU_NavigationController(rootViewController: viewController), animated: true)
                    }
                }
            }
        }
    }
}

// MARK: - Cancellation

extension RU_Booking {
	
	public var travelerGrossAmount: Double {
		platform?.calculatePrice(for: self)?.travelerTotal ?? 0
	}
	
	public static func handleCancellationToggle(
		for booking: RU_Booking,
		markingAsCancelled: Bool,
		completion: @escaping (Error?) -> Void
	) {
		if markingAsCancelled {
			let alert = RU_Booking_Cancel_Alert_ViewController(booking: booking)
			alert.completion = completion
			alert.present()
		} else {
			RU_Alert_ViewController.presentLoading { alertController in
				booking.applyConfirmedStatus { error in
					alertController?.close {
						completion(error)
					}
				}
			}
		}
	}
	
	public func applyCancelledStatus(compensation: Double, completion: @escaping (Error?) -> Void) {
		isCancelled = true
		costs.compensation = compensation
		saveAndNotify(completion: completion)
	}
	
	public func applyConfirmedStatus(completion: @escaping (Error?) -> Void) {
		isCancelled = false
		costs.compensation = 0
		saveAndNotify(completion: completion)
	}
	
	private func saveAndNotify(completion: @escaping (Error?) -> Void) {
		save { error in
			if error == nil {
				NotificationCenter.post(.updateBookings)
			}
			completion(error)
		}
	}
}

extension [RU_Booking] {
    
    public var current:RU_Booking? {

        return first { $0.status == .current }
    }
    
    public var next:RU_Booking? {

        let upcoming = filter { $0.status == .upcoming }.sorted { $0.stayCheckInDate < $1.stayCheckInDate }
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
