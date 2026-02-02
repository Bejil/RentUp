//
//  RU_Home_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit
import SnapKit

public class RU_Home_ViewController: RU_ViewController {
	
	private var bookings: [RU_Booking]? {
		didSet {
			
			updateDashboard()
		}
	}
	private lazy var contentScrollView: RU_ScrollView = {
		
		$0.isCentered = false
		$0.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.top.bottom.left.equalToSuperview()
			make.right.width.equalToSuperview()
		}
		return $0
		
	}(RU_ScrollView())
	private lazy var contentStackView: RU_StackView = {
		
		$0.axis = .vertical
		$0.spacing = 2 * UI.Margins
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins = .init(UI.Margins)
		return $0
		
	}(RU_StackView())
	private lazy var generalSectionStackView: RU_Section_StackView = {
		$0.title = String(key: "home.general.section.title")
		return $0
		
	}(RU_Section_StackView())
	private lazy var totalRevenueLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var totalNightsLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var averageNightsLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var averageTravelersLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var mostUsedPlatformLabel: RU_Platform_Label = .init()
	private lazy var mostProfitablePlatformLabel: RU_Platform_Label = .init()
	private lazy var averageOccupancyLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var forecastOccupancyLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var averageProfitabilityLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var forecastProfitabilityLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var currentMonthSectionStackView: RU_Section_StackView = {
		
		$0.title = String(key: "home.currentMonth.section.title")
		return $0
		
	}(RU_Section_StackView())
	private lazy var currentOccupancyLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var forecastMonthOccupancyLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var currentYieldLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var forecastYieldLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var estimatedMonthRevenueLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textColor = Colors.Primary
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var currentBookingSectionStackView: RU_Section_StackView = {
		
		$0.title = String(key: "home.currentBooking.section.title")
		return $0
		
	}(RU_Section_StackView())
	private lazy var currentBookingDepartureLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var currentBookingPlatformLabel: RU_Platform_Label = .init()
	private lazy var currentBookingNightsLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var currentBookingTravelersLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var currentBookingRevenueLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textColor = Colors.Primary
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var nextBookingSectionStackView: RU_Section_StackView = {
		
		$0.title = String(key: "home.nextBooking.section.title")
		return $0
		
	}(RU_Section_StackView())
	private lazy var nextBookingArrivalLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var nextBookingPlatformLabel: RU_Platform_Label = .init()
	private lazy var nextBookingNightsLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var nextBookingTravelersLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var nextBookingRevenueLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textColor = Colors.Primary
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var currentBookingContentStackView: RU_StackView = {
		
		$0.axis = .vertical
		return $0
		
	}(RU_StackView())
	private lazy var nextBookingContentStackView: RU_StackView = {
		
		$0.axis = .vertical
		return $0
		
	}(RU_StackView())
	
	// MARK: - Init

	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		tabBarItem = .init(title: String(key: "tabbar.home"), image: UIImage(systemName: "house"), tag: RU_TabBarController.Indexes.Home.rawValue)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Load View
	
	public override func loadView() {
		
		super.loadView()
		
		navigationItem.title = String(key: "home.title")
		
		contentView.addSubview(contentScrollView)
		contentScrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		// Section Générale
		generalSectionStackView.addArrangedSubview(createRow(icon: "banknote.fill", title: String(key: "home.general.totalRevenue"), view: totalRevenueLabel))
		generalSectionStackView.addArrangedSubview(createRow(icon: "moon.fill", title: String(key: "home.general.totalNights"), view: totalNightsLabel))
		generalSectionStackView.addArrangedSubview(createRow(icon: "moon", title: String(key: "home.general.averageNights"), view: averageNightsLabel))
		generalSectionStackView.addArrangedSubview(createRow(icon: "person.2.fill", title: String(key: "home.general.averageTravelers"), view: averageTravelersLabel))
		let mostUsedPlatformStackView:RU_StackView = .init(arrangedSubviews: [.init(),mostUsedPlatformLabel])
		mostUsedPlatformStackView.axis = .horizontal
		mostUsedPlatformStackView.alignment = .center
		generalSectionStackView.addArrangedSubview(createRow(icon: "star.fill", title: String(key: "home.general.mostUsedPlatform"), view: mostUsedPlatformStackView))
		let mostProfitablePlatformStackView:RU_StackView = .init(arrangedSubviews: [.init(),mostProfitablePlatformLabel])
		mostProfitablePlatformStackView.axis = .horizontal
		mostProfitablePlatformStackView.alignment = .center
		generalSectionStackView.addArrangedSubview(createRow(icon: "trophy.fill", title: String(key: "home.general.mostProfitablePlatform"), view: mostProfitablePlatformStackView))
		generalSectionStackView.addArrangedSubview(createRow(icon: "chart.pie.fill", title: String(key: "home.general.averageOccupancy"), view: averageOccupancyLabel))
		generalSectionStackView.addArrangedSubview(createRow(icon: "chart.line.uptrend.xyaxis", title: String(key: "home.general.forecastOccupancy"), view: forecastOccupancyLabel))
		generalSectionStackView.addArrangedSubview(createRow(icon: "percent", title: String(key: "home.general.averageProfitability"), view: averageProfitabilityLabel))
		generalSectionStackView.addArrangedSubview(createRow(icon: "arrow.up.right", title: String(key: "home.general.forecastProfitability"), view: forecastProfitabilityLabel))
		contentStackView.addArrangedSubview(generalSectionStackView)
		
		// Section Mois en cours
		currentMonthSectionStackView.addArrangedSubview(createRow(icon: "calendar", title: String(key: "home.currentMonth.currentOccupancy"), view: currentOccupancyLabel))
		currentMonthSectionStackView.addArrangedSubview(createRow(icon: "calendar.badge.clock", title: String(key: "home.currentMonth.forecastOccupancy"), view: forecastMonthOccupancyLabel))
		currentMonthSectionStackView.addArrangedSubview(createRow(icon: "chart.bar.fill", title: String(key: "home.currentMonth.currentYield"), view: currentYieldLabel))
		currentMonthSectionStackView.addArrangedSubview(createRow(icon: "chart.bar", title: String(key: "home.currentMonth.forecastYield"), view: forecastYieldLabel))
		currentMonthSectionStackView.addArrangedSubview(createRow(icon: "eurosign.circle.fill", title: String(key: "home.currentMonth.estimatedRevenue"), view: estimatedMonthRevenueLabel, isHighlighted: true))
		contentStackView.addArrangedSubview(currentMonthSectionStackView)
		
		// Section Réservation en cours
		currentBookingContentStackView.addArrangedSubview(createRow(icon: "calendar.badge.minus", title: String(key: "home.currentBooking.departure"), view: currentBookingDepartureLabel))
		let currentBookingPlatformStackView:RU_StackView = .init(arrangedSubviews: [.init(),currentBookingPlatformLabel])
		currentBookingPlatformStackView.axis = .horizontal
		currentBookingPlatformStackView.alignment = .center
		currentBookingContentStackView.addArrangedSubview(createRow(icon: "building.2.fill", title: String(key: "home.booking.platform"), view: currentBookingPlatformStackView))
		currentBookingContentStackView.addArrangedSubview(createRow(icon: "moon.fill", title: String(key: "home.booking.nights"), view: currentBookingNightsLabel))
		currentBookingContentStackView.addArrangedSubview(createRow(icon: "person.2.fill", title: String(key: "home.booking.travelers"), view: currentBookingTravelersLabel))
		currentBookingContentStackView.addArrangedSubview(createRow(icon: "eurosign.circle.fill", title: String(key: "home.booking.revenue"), view: currentBookingRevenueLabel, isHighlighted: true))
		currentBookingSectionStackView.addArrangedSubview(currentBookingContentStackView)
		contentStackView.addArrangedSubview(currentBookingSectionStackView)
		
		// Section Prochaine réservation
		nextBookingContentStackView.addArrangedSubview(createRow(icon: "calendar.badge.plus", title: String(key: "home.nextBooking.arrival"), view: nextBookingArrivalLabel))
		let nextBookingPlatformStackView:RU_StackView = .init(arrangedSubviews: [.init(),nextBookingPlatformLabel])
		nextBookingPlatformStackView.axis = .horizontal
		nextBookingPlatformStackView.alignment = .center
		nextBookingContentStackView.addArrangedSubview(createRow(icon: "building.2.fill", title: String(key: "home.booking.platform"), view: nextBookingPlatformStackView))
		nextBookingContentStackView.addArrangedSubview(createRow(icon: "moon.fill", title: String(key: "home.booking.nights"), view: nextBookingNightsLabel))
		nextBookingContentStackView.addArrangedSubview(createRow(icon: "person.2.fill", title: String(key: "home.booking.travelers"), view: nextBookingTravelersLabel))
		nextBookingContentStackView.addArrangedSubview(createRow(icon: "eurosign.circle.fill", title: String(key: "home.booking.revenue"), view: nextBookingRevenueLabel, isHighlighted: true))
		nextBookingSectionStackView.addArrangedSubview(nextBookingContentStackView)
		contentStackView.addArrangedSubview(nextBookingSectionStackView)
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		loadBookings()
	}
	
	private func createRow(icon: String, title: String, view: UIView, isHighlighted: Bool = false) -> RU_Section_Row_StackView {
		
		let row = RU_Section_Row_StackView()
		row.image = UIImage(systemName: icon)
		row.title = title
		row.view = view
		row.isHighlighted = isHighlighted
		return row
	}
	
	private func loadBookings() {
		
		RU_Alert_ViewController.presentLoading { [weak self] alertController in
			
			RU_Booking.getAll { [weak self] error, bookings in
				
				alertController?.close { [weak self] in
					
					if let error {
						
						RU_Alert_ViewController.present(error) { [weak self] in
							
							self?.loadBookings()
						}
					}
					else {
						
						self?.bookings = bookings
					}
				}
			}
		}
	}
	
	private func updateDashboard() {
		
		guard let bookings = bookings else { return }
		
		let calendar = Calendar.current
		let now = Date()
		
		let pastBookings = bookings.filter { $0.status == .past }
		let currentBooking = bookings.first { $0.status == .current }
		let upcomingBookings = bookings.filter { $0.status == .upcoming }.sorted { $0.dates.start < $1.dates.start }
		let nextBooking = upcomingBookings.first
		
		let totalRevenue = pastBookings.compactMap { booking -> Double? in
			return booking.platform?.calculatePrice(for: booking)?.hostTotal
		}.reduce(0, +)
		totalRevenueLabel.text = String(format: "%.2f €", totalRevenue)
		
		let totalNights = pastBookings.compactMap { booking -> Int? in
			return booking.platform?.calculatePrice(for: booking)?.nights
		}.reduce(0, +)
		totalNightsLabel.text = "\(totalNights)"
		
		// Nombre de nuitées moyen
		let averageNights = pastBookings.isEmpty ? 0.0 : Double(totalNights) / Double(pastBookings.count)
		averageNightsLabel.text = String(format: "%.1f", averageNights)
		
		// Nombre de personnes moyen
		let totalTravelers = pastBookings.compactMap { booking -> Int? in
			return (booking.travelers.adults ?? 0) + (booking.travelers.children ?? 0)
		}.reduce(0, +)
		let averageTravelers = pastBookings.isEmpty ? 0.0 : Double(totalTravelers) / Double(pastBookings.count)
		averageTravelersLabel.text = String(format: "%.1f", averageTravelers)
		
		// Plateforme la plus utilisée
		var platformUsage: [RU_Platform.PlatformType: Int] = [:]
		for booking in pastBookings {
			if let type = booking.platform?.type {
				platformUsage[type, default: 0] += 1
			}
		}
		if let mostUsed = platformUsage.max(by: { $0.value < $1.value }),
		   let platform = RU_Platform.all?.first(where: { $0.type == mostUsed.key }) {
			mostUsedPlatformLabel.platform = platform
		} else {
			mostUsedPlatformLabel.platform = nil
		}
		
		// Plateforme la plus rentable
		var platformRevenue: [RU_Platform.PlatformType: Double] = [:]
		for booking in pastBookings {
			if let type = booking.platform?.type, let revenue = booking.platform?.calculatePrice(for: booking)?.hostTotal {
				platformRevenue[type, default: 0] += revenue
			}
		}
		if let mostProfitable = platformRevenue.max(by: { $0.value < $1.value }),
		   let platform = RU_Platform.all?.first(where: { $0.type == mostProfitable.key }) {
			mostProfitablePlatformLabel.platform = platform
		} else {
			mostProfitablePlatformLabel.platform = nil
		}
		
		// Occupation moyenne (basée sur les 12 derniers mois)
		let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
		let recentBookings = pastBookings.filter { $0.dates.start >= oneYearAgo }
		let recentNights = recentBookings.compactMap { booking -> Int? in
			return booking.platform?.calculatePrice(for: booking)?.nights
		}.reduce(0, +)
		let daysInYear = 365.0
		let averageOccupancy = (Double(recentNights) / daysInYear) * 100
		averageOccupancyLabel.text = String(format: "%.1f%%", averageOccupancy)
		
		// Occupation prévisionnelle (basée sur les réservations à venir)
		let upcomingNights = upcomingBookings.compactMap { booking -> Int? in
			return booking.platform?.calculatePrice(for: booking)?.nights
		}.reduce(0, +)
		let daysRemaining = calendar.dateComponents([.day], from: now, to: calendar.date(byAdding: .year, value: 1, to: now)!).day ?? 365
		let forecastOccupancy = daysRemaining > 0 ? (Double(upcomingNights) / Double(daysRemaining)) * 100 : 0
		forecastOccupancyLabel.text = String(format: "%.1f%%", forecastOccupancy)
		
		// Rentabilité moyenne (revenu par nuit)
		let averageProfitability = recentNights > 0 ? totalRevenue / Double(recentNights) : 0
		averageProfitabilityLabel.text = String(format: "%.2f €/nuit", averageProfitability)
		
		// Rentabilité prévisionnelle
		let upcomingRevenue = upcomingBookings.compactMap { booking -> Double? in
			return booking.platform?.calculatePrice(for: booking)?.hostTotal
		}.reduce(0, +)
		let forecastProfitability = upcomingNights > 0 ? upcomingRevenue / Double(upcomingNights) : 0
		forecastProfitabilityLabel.text = String(format: "%.2f €/nuit", forecastProfitability)
		
		// MARK: - Section Mois en cours
		
		let currentMonth = calendar.component(.month, from: now)
		let currentYear = calendar.component(.year, from: now)
		let startOfMonth = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1))!
		let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
		let daysInMonth = calendar.component(.day, from: endOfMonth)
		let currentDayOfMonth = calendar.component(.day, from: now)
		
		// Réservations du mois en cours
		let monthBookings = bookings.filter { booking in
			let start = calendar.startOfDay(for: booking.dates.start)
			let end = calendar.startOfDay(for: booking.dates.end)
			return (start >= startOfMonth && start <= endOfMonth) || (end >= startOfMonth && end <= endOfMonth) || (start < startOfMonth && end > endOfMonth)
		}
		
		// Calcul des nuits occupées ce mois
		var occupiedNightsThisMonth = 0
		var occupiedNightsUntilNow = 0
		for booking in monthBookings {
			let bookingStart = max(calendar.startOfDay(for: booking.dates.start), startOfMonth)
			let bookingEnd = min(calendar.startOfDay(for: booking.dates.end), endOfMonth)
			let nights = calendar.dateComponents([.day], from: bookingStart, to: bookingEnd).day ?? 0
			occupiedNightsThisMonth += max(0, nights)
			
			let nightsUntilNow = calendar.dateComponents([.day], from: bookingStart, to: min(bookingEnd, now)).day ?? 0
			occupiedNightsUntilNow += max(0, nightsUntilNow)
		}
		
		// Occupation actuelle
		let currentMonthOccupancy = currentDayOfMonth > 0 ? (Double(occupiedNightsUntilNow) / Double(currentDayOfMonth)) * 100 : 0
		
		// Comparer avec le mois précédent
		let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: startOfMonth)!
		let previousMonthEnd = calendar.date(byAdding: .day, value: -1, to: startOfMonth)!
		let previousMonthBookings = bookings.filter { booking in
			let start = calendar.startOfDay(for: booking.dates.start)
			let end = calendar.startOfDay(for: booking.dates.end)
			return (start >= previousMonthStart && start <= previousMonthEnd) || (end >= previousMonthStart && end <= previousMonthEnd) || (start < previousMonthStart && end > previousMonthEnd)
		}
		var previousMonthNights = 0
		for booking in previousMonthBookings {
			let bookingStart = max(calendar.startOfDay(for: booking.dates.start), previousMonthStart)
			let bookingEnd = min(calendar.startOfDay(for: booking.dates.end), previousMonthEnd)
			let nights = calendar.dateComponents([.day], from: bookingStart, to: bookingEnd).day ?? 0
			previousMonthNights += max(0, nights)
		}
		let previousMonthDays = calendar.component(.day, from: previousMonthEnd)
		let previousMonthOccupancy = previousMonthDays > 0 ? (Double(previousMonthNights) / Double(previousMonthDays)) * 100 : 0
		
		let occupancyVariation = currentMonthOccupancy - previousMonthOccupancy
		let occupancyVariationString = occupancyVariation >= 0 ? "+\(String(format: "%.1f", occupancyVariation))%" : "\(String(format: "%.1f", occupancyVariation))%"
		currentOccupancyLabel.text = "\(String(format: "%.1f", currentMonthOccupancy))% (\(occupancyVariationString))"
		
		// Occupation prévisionnelle du mois
		let forecastMonthOccupancy = daysInMonth > 0 ? (Double(occupiedNightsThisMonth) / Double(daysInMonth)) * 100 : 0
		let forecastVariation = forecastMonthOccupancy - previousMonthOccupancy
		let forecastVariationString = forecastVariation >= 0 ? "+\(String(format: "%.1f", forecastVariation))%" : "\(String(format: "%.1f", forecastVariation))%"
		forecastMonthOccupancyLabel.text = "\(String(format: "%.1f", forecastMonthOccupancy))% (\(forecastVariationString))"
		
		// Rendement actuel et prévisionnel
		let monthRevenue = monthBookings.filter { $0.status == .past || $0.status == .current }.compactMap { booking -> Double? in
			return booking.platform?.calculatePrice(for: booking)?.hostTotal
		}.reduce(0, +)
		let previousMonthRevenue = previousMonthBookings.compactMap { booking -> Double? in
			return booking.platform?.calculatePrice(for: booking)?.hostTotal
		}.reduce(0, +)
		
		let currentYield = currentDayOfMonth > 0 ? monthRevenue / Double(currentDayOfMonth) * Double(daysInMonth) : 0
		let previousMonthTotalRevenue = previousMonthRevenue
		let yieldVariation = previousMonthTotalRevenue > 0 ? ((currentYield - previousMonthTotalRevenue) / previousMonthTotalRevenue) * 100 : 0
		let yieldVariationString = yieldVariation >= 0 ? "+\(String(format: "%.1f", yieldVariation))%" : "\(String(format: "%.1f", yieldVariation))%"
		currentYieldLabel.text = "\(String(format: "%.2f", monthRevenue)) € (\(yieldVariationString))"
		
		let forecastRevenue = monthBookings.compactMap { booking -> Double? in
			return booking.platform?.calculatePrice(for: booking)?.hostTotal
		}.reduce(0, +)
		let forecastYieldVariation = previousMonthTotalRevenue > 0 ? ((forecastRevenue - previousMonthTotalRevenue) / previousMonthTotalRevenue) * 100 : 0
		let forecastYieldVariationString = forecastYieldVariation >= 0 ? "+\(String(format: "%.1f", forecastYieldVariation))%" : "\(String(format: "%.1f", forecastYieldVariation))%"
		forecastYieldLabel.text = "\(String(format: "%.2f", forecastRevenue)) € (\(forecastYieldVariationString))"
		
		estimatedMonthRevenueLabel.text = String(format: "%.2f €", forecastRevenue)
		
		// MARK: - Section Réservation en cours
		
		if let current = currentBooking {
			currentBookingSectionStackView.isHidden = false
			
			let daysUntilDeparture = calendar.dateComponents([.day], from: now, to: current.dates.end).day ?? 0
			currentBookingDepartureLabel.text = String(format: String(key: "home.days"), daysUntilDeparture)
			
			currentBookingPlatformLabel.platform = current.platform
			
			if let nights = current.platform?.calculatePrice(for: current)?.nights {
				currentBookingNightsLabel.text = "\(nights)"
			}
			
			let travelers = (current.travelers.adults ?? 0) + (current.travelers.children ?? 0) + (current.travelers.babies ?? 0)
			currentBookingTravelersLabel.text = "\(travelers)"
			
			if let revenue = current.platform?.calculatePrice(for: current)?.hostTotal {
				currentBookingRevenueLabel.text = String(format: "%.2f €", revenue)
			}
		} else {
			currentBookingSectionStackView.isHidden = true
		}
		
		// MARK: - Section Prochaine réservation
		
		if let next = nextBooking {
			nextBookingSectionStackView.isHidden = false
			
			let daysUntilArrival = calendar.dateComponents([.day], from: now, to: next.dates.start).day ?? 0
			nextBookingArrivalLabel.text = String(format: String(key: "home.days"), daysUntilArrival)
			
			nextBookingPlatformLabel.platform = next.platform
			
			if let nights = next.platform?.calculatePrice(for: next)?.nights {
				nextBookingNightsLabel.text = "\(nights)"
			}
			
			let travelers = (next.travelers.adults ?? 0) + (next.travelers.children ?? 0) + (next.travelers.babies ?? 0)
			nextBookingTravelersLabel.text = "\(travelers)"
			
			if let revenue = next.platform?.calculatePrice(for: next)?.hostTotal {
				nextBookingRevenueLabel.text = String(format: "%.2f €", revenue)
			}
		} else {
			nextBookingSectionStackView.isHidden = true
		}
	}
}
