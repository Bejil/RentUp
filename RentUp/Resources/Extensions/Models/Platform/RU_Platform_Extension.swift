//
//  RU_Platform.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit

extension RU_Platform {
	
	public struct PriceCalculation {
		
		public let nights: Int
		public let totalNights: Double
		public let cleaning: Double
		public let totalNightsCleaning: Double
		public let travelerFees: Double
		public let touristTax: Double
		public let travelerTotal: Double
		public let hostFees: Double
		public let hostTotal: Double
        public let hostCleaningCost: Double
        public let hostCompensationCost: Double
		public let discount: Double
		public let discountPercent: Double
	}
	
	public static var all: [RU_Platform]?
	
	public static func setUp(_ completion:((Error?)->Void)?) {
		
		if let data = UserDefaults.get(.platforms) as? Data, let platforms = try? JSONDecoder().decode([RU_Platform].self, from: data) {
			
			all = platforms
			completion?(nil)
		}
		else {
			
			let airbnb:RU_Platform = .init()
			airbnb.type = .airbnb
			
			let booking:RU_Platform = .init()
			booking.type = .booking
			
			let abritel:RU_Platform = .init()
			abritel.type = .abritel
			
			let platforms:[RU_Platform] = [airbnb, booking, abritel]
			
			do {
				
				let data = try JSONEncoder().encode(platforms)
				UserDefaults.set(data, .platforms)
				
				all = platforms
				
				completion?(nil)
			}
			catch {
				
				completion?(error)
			}
		}
	}
	
	public func save(_ completion:((Error?)->Void)?) {
		
		var platforms = RU_Platform.all
		
		if let index = platforms?.firstIndex(of: self) {
			
			platforms?[index] = self
		}
		else {
			
			platforms?.append(self)
		}
		
		do {
			
			let data = try JSONEncoder().encode(platforms)
			UserDefaults.set(data, .platforms)
			
			RU_Platform.all = platforms
			
			completion?(nil)
		}
		catch {
			
			completion?(error)
		}
	}
	
	public var detail: String {
		
		var details:[String] = []
		
		if let touristTax = commission.touristTax?.amount {
			details.append(String(format: String(key: "settings.platform.cell.touristTax"), touristTax))
		}
		
		if let host = commission.host?.amount {
			details.append(String(format: String(key: "settings.platform.cell.commission.host"), host))
		}
		
		if let traveler = commission.traveler?.amount {
			details.append(String(format: String(key: "settings.platform.cell.commission.traveler"), traveler))
		}
		
		if let platformCommission = commission.platform?.amount {
			details.append(String(format: String(key: "settings.platform.cell.commission.platform"), platformCommission))
		}
		
		return details.joined(separator: " • ")
	}
	
	public func calculatePrice(for booking: RU_Booking) -> PriceCalculation? {
		
		let calendar = Calendar.current
		let startDay = calendar.startOfDay(for: booking.dates.start)
		let endDay = calendar.startOfDay(for: booking.dates.end)
		let nights = calendar.dateComponents([.day], from: startDay, to: endDay).day ?? 0
		
		guard nights > 0 else { return nil }
		
		// Récupérer les prix depuis le classified pour cette plateforme
		guard let tarification = booking.classified?.tarification.first(where: { $0.platform == self }),
			  let pricePerNight = tarification.price else { return nil }
		
		var totalNights = Double(pricePerNight * nights)
		
		// Supplément par voyageur au-dessus de n (x € par voyageur supplémentaire par nuit) — avant réductions
		let totalTravelers = (booking.travelers.adults ?? 0) + (booking.travelers.children ?? 0)
        if let n = tarification.travelers.included, let x = tarification.travelers.extraPrice, totalTravelers > n {
			let extraTravelers = totalTravelers - n
			totalNights += Double(extraTravelers * x * nights)
		}
		
		// Appliquer les réductions selon la durée du séjour (semaine / mois)
		var discountPercent: Double = 0
		if nights >= 28, let monthPercent = tarification.offers.first(where: { $0.reductiontype == .month })?.percent {
			discountPercent = Double(monthPercent)
		}
		else if nights >= 7, let weekPercent = tarification.offers.first(where: { $0.reductiontype == .week })?.percent {
			discountPercent = Double(weekPercent)
		}
		let discount = totalNights * (discountPercent / 100)
		totalNights = totalNights - discount
		
		let cleaning = Double(tarification.cleaning ?? 0)
		let totalNightsCleaning = totalNights + cleaning
		
		var travelerFees: Double = 0
		var touristTax: Double = 0
		var hostFees: Double = 0
		
		switch type {
			
		case .airbnb:
			// Frais voyageur : pourcentage sur (nuitées + ménage)
			if let travelerPercent = commission.traveler?.amount {
				travelerFees = totalNightsCleaning * (travelerPercent / 100)
			}
			
			// Taxe de séjour : montant par personne par nuit
			if let taxAmount = commission.touristTax?.amount {
				touristTax = taxAmount * Double(totalTravelers) * Double(nights)
			}
			
			// Frais hôte : pourcentage sur (nuitées + ménage) + TVA sur ces frais
			if let hostPercent = commission.host?.amount {
				var fees = totalNightsCleaning * (hostPercent / 100)
				if let vatPercent = commission.vat?.amount {
					fees = fees * (1 + vatPercent / 100)
				}
				hostFees = fees
			}
			
		case .booking:
			// Pas de frais voyageur
			travelerFees = 0
			
			// Taxe de séjour : montant par personne par nuit
			if let taxAmount = commission.touristTax?.amount {
				touristTax = taxAmount * Double(totalTravelers) * Double(nights)
			}
			
			// Frais hôte : commission plateforme + frais bancaires
			var fees: Double = 0
			if let platformPercent = commission.platform?.amount {
				fees += totalNightsCleaning * (platformPercent / 100)
			}
			if let bankPercent = commission.bank?.amount {
				fees += totalNightsCleaning * (bankPercent / 100)
			}
			hostFees = fees
			
		case .abritel:
			// Frais voyageur : pourcentage sur (nuitées + ménage)
			if let travelerPercent = commission.traveler?.amount {
				travelerFees = totalNightsCleaning * (travelerPercent / 100)
			}
			
			// Taxe de séjour : montant par personne par nuit
			if let taxAmount = commission.touristTax?.amount {
				touristTax = taxAmount * Double(totalTravelers) * Double(nights)
			}
			
			// Frais hôte : commission plateforme + frais bancaires
			var fees: Double = 0
			if let platformPercent = commission.platform?.amount {
				fees += totalNightsCleaning * (platformPercent / 100)
			}
			if let bankPercent = commission.bank?.amount {
				fees += totalNightsCleaning * (bankPercent / 100)
			}
			hostFees = fees
			
		default:
			break
		}
		
		let travelerTotal = totalNightsCleaning + travelerFees + touristTax
        
        // Coûts spécifiques pour l'hôte (ménage + compensation)
        let hostCleaningCost = Double(booking.costs.cleaning ?? 0)
        let hostCompensationCost = Double(booking.costs.compensation ?? 0)
        let hostTotal = totalNightsCleaning - hostFees - hostCleaningCost - hostCompensationCost
		
		return PriceCalculation(
			nights: nights,
			totalNights: totalNights,
			cleaning: cleaning,
			totalNightsCleaning: totalNightsCleaning,
			travelerFees: travelerFees,
			touristTax: touristTax,
			travelerTotal: travelerTotal,
			hostFees: hostFees,
			hostTotal: hostTotal,
            hostCleaningCost: hostCleaningCost,
            hostCompensationCost: hostCompensationCost,
			discount: discount,
			discountPercent: discountPercent
		)
	}
}

extension RU_Platform.PlatformType {
    
    public var name: String {
        
        return String(key: "platform.\(rawValue).name")
    }
}
