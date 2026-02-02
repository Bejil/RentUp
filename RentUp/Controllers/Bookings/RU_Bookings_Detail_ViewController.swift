//
//  RU_Bookings_Detail_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 23/01/2026.
//

import UIKit
import SnapKit

public class RU_Bookings_Detail_ViewController : RU_ViewController {
	
	public var booking:RU_Booking? {
		
		didSet {
			
			title = booking?.classified?.name ?? String(key: "bookings.details.title")
			
			platformLabel.platform = booking?.platform
			statusLabel.booking = booking
			
			// Dates
			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .long
			dateFormatter.locale = Locale(identifier: "fr_FR")
			
			if let startDate = booking?.dates.start {
				
				let startDateString = dateFormatter.string(from: startDate)
				datesStartValueLabel.text = startDateString
			}
			
			if let endDate = booking?.dates.end {
				
				let endDateString = dateFormatter.string(from: endDate)
				datesEndValueLabel.text = endDateString
			}
			
			if let startDate = booking?.dates.start, let endDate = booking?.dates.end, let nights = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day {
				
				let nightsString = nights > 1 ? String(key: "bookings.details.nights") : String(key: "bookings.details.night")
				nightsValueLabel.text = "\(nights) \(nightsString)"
			}
			
			if let adults = booking?.travelers.adults {
				
				adultsValueLabel.text = "\(adults)"
			}
			
			if let children = booking?.travelers.children {
				
				childrenValueLabel.text = "\(children)"
			}
			else {
				
				childrenSectionRowStackView.isHidden = true
			}
			
			if let babies = booking?.travelers.babies {
				
				babiesValueLabel.text = "\(babies)"
			}
			else {
				
				babiesSectionRowStackView.isHidden = true
			}
			
			// Configuration des lits
			if let doubles = booking?.beds.doubles, doubles > 0 {
				
				doubleBedsValueLabel.text = "\(doubles)"
				doubleBedsSectionRowStackView.isHidden = false
			}
			else {
				
				doubleBedsSectionRowStackView.isHidden = true
			}
			
			if let singles = booking?.beds.singles, singles > 0 {
				
				singleBedsValueLabel.text = "\(singles)"
				singleBedsSectionRowStackView.isHidden = false
			}
			else {
				
				singleBedsSectionRowStackView.isHidden = true
			}
			
			if let babies = booking?.beds.babies, babies > 0 {
				
				babyBedsValueLabel.text = "\(babies)"
				babyBedsSectionRowStackView.isHidden = false
			}
			else {
				
				babyBedsSectionRowStackView.isHidden = true
			}
			
			// Masquer la section configuration si aucun lit
			let hasAnyBed = (booking?.beds.doubles ?? 0) > 0 || (booking?.beds.singles ?? 0) > 0 || (booking?.beds.babies ?? 0) > 0
			configurationSectionStackView.isHidden = !hasAnyBed
			
			if let booking, let calculation = booking.platform?.calculatePrice(for: booking) {
				
				travelerSectionTitleStackView.subtitle = booking.platform?.type?.priceFormulaTraveler
				travelerNightsValueLabel.text = String(format: "%.2f €", calculation.totalNights + calculation.discount)
				
				travelerDiscountSectionRowStackView.isHidden = calculation.discount == 0
				travelerDiscountValueLabel.text = String(format: "-%.2f € (%.0f%%)", calculation.discount, calculation.discountPercent)
				
				travelerCleaningSectionRowStackView.isHidden = calculation.cleaning == 0
				travelerCleaningValueLabel.text = String(format: "%.2f €", calculation.cleaning)
				
				travelerFeesSectionRowStackView.isHidden = calculation.travelerFees == 0
				travelerFeesValueLabel.text = String(format: "%.2f €", calculation.travelerFees)
				
				travelerTouristTaxValueLabel.text = String(format: "%.2f €", calculation.touristTax)
				travelerTotalValueLabel.text = String(format: "%.2f €", calculation.travelerTotal)
				
				hostSectionTitleStackView.subtitle = booking.platform?.type?.priceFormulaHost
				hostNightsValueLabel.text = String(format: "%.2f €", calculation.totalNights + calculation.discount)
				
				hostDiscountSectionRowStackView.isHidden = calculation.discount == 0
				hostDiscountValueLabel.text = String(format: "-%.2f € (%.0f%%)", calculation.discount, calculation.discountPercent)
				
				hostCleaningSectionRowStackView.isHidden = calculation.cleaning == 0
				hostCleaningValueLabel.text = String(format: "%.2f €", calculation.cleaning)
				
				hostFeesValueLabel.text = String(format: "%.2f €", calculation.hostFees)
				hostTotalValueLabel.text = String(format: "%.2f €", calculation.hostTotal)
				
				// Masquer les sections si pas de calcul possible
				travelerSectionTitleStackView.isHidden = false
				hostSectionTitleStackView.isHidden = false
			}
			else {
				
				travelerSectionTitleStackView.isHidden = true
				hostSectionTitleStackView.isHidden = true
			}
		}
	}
	private lazy var childrenSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "figure.child", title: String(key: "bookings.create.travelers.children"), view: childrenValueLabel)
	private lazy var babiesSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "stroller.fill", title: String(key: "bookings.create.travelers.babies"), view: babiesValueLabel)
	private lazy var statusLabel:RU_Booking_Status_Label = .init()
	private lazy var configurationSectionStackView:RU_Section_StackView = {
		
		$0.title = String(key: "bookings.details.configuration.section.title")
		$0.addArrangedSubview(doubleBedsSectionRowStackView)
		$0.addArrangedSubview(singleBedsSectionRowStackView)
		$0.addArrangedSubview(babyBedsSectionRowStackView)
		return $0
		
	}(RU_Section_StackView())
	private lazy var doubleBedsValueLabel:RU_Label = .init()
	private lazy var doubleBedsSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "bed.double.fill", title: String(key: "bookings.details.configuration.beds.double"), view: doubleBedsValueLabel)
	private lazy var singleBedsValueLabel:RU_Label = .init()
	private lazy var singleBedsSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "bed.double", title: String(key: "bookings.details.configuration.beds.single"), view: singleBedsValueLabel)
	private lazy var babyBedsValueLabel:RU_Label = .init()
	private lazy var babyBedsSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "stroller", title: String(key: "bookings.details.configuration.beds.baby"), view: babyBedsValueLabel)
	private lazy var contentScrollView:RU_ScrollView = {
		
		$0.isCentered = false
		$0.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.top.bottom.left.equalToSuperview()
			make.right.width.equalToSuperview()
		}
		return $0
		
	}(RU_ScrollView())
	private lazy var contentStackView:RU_StackView = {
		
		$0.axis = .vertical
		$0.spacing = 2*UI.Margins
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins = .init(UI.Margins)
		return $0
		
	}(RU_StackView())
	private lazy var platformLabel:RU_Platform_Label = .init()
	private lazy var datesStartValueLabel:RU_Label = .init()
	private lazy var datesEndValueLabel:RU_Label = .init()
	private lazy var nightsValueLabel:RU_Label = .init()
	private lazy var adultsValueLabel:RU_Label = .init()
	private lazy var childrenValueLabel:RU_Label = .init()
	private lazy var babiesValueLabel:RU_Label = .init()
	private lazy var pricesStackView:RU_StackView = {
		
		$0.axis = .vertical
		$0.spacing = 2*UI.Margins
		return $0
		
	}(RU_StackView(arrangedSubviews: [travelerSectionTitleStackView,hostSectionTitleStackView]))
	private lazy var travelerSectionTitleStackView:RU_Section_StackView = {
		
		let backgroundView:RU_Booking_Price_View = .init()
		$0.insertSubview(backgroundView, at: 0)
		backgroundView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins = .init(2*UI.Margins)
		$0.layoutMargins.bottom = UI.Margins
		$0.title = String(key: "bookings.details.travelerPrice.section.title")
		$0.addArrangedSubview(createRow(icon: "moon.fill", title: String(key: "bookings.details.price.nights"), view: travelerNightsValueLabel))
		$0.addArrangedSubview(travelerDiscountSectionRowStackView)
		$0.addArrangedSubview(travelerCleaningSectionRowStackView)
		$0.addArrangedSubview(travelerFeesSectionRowStackView)
		$0.addArrangedSubview(createRow(icon: "building.columns.fill", title: String(key: "bookings.details.price.touristTax"), view: travelerTouristTaxValueLabel))
		$0.addArrangedSubview(createRow(icon: "equal.circle.fill", title: String(key: "bookings.details.price.travelerTotal"), view: travelerTotalValueLabel, isHighlighted: true))
		
		return $0
		
	}(RU_Section_StackView())
	private lazy var travelerNightsValueLabel:RU_Label = .init()
	private lazy var travelerDiscountSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "percent", title: String(key: "bookings.details.price.discount"), view: travelerDiscountValueLabel)
	private lazy var travelerDiscountValueLabel:RU_Label = .init()
	private lazy var travelerCleaningSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "sparkles", title: String(key: "bookings.details.price.cleaning"), view: travelerCleaningValueLabel)
	private lazy var travelerCleaningValueLabel:RU_Label = .init()
	private lazy var travelerFeesSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "plus", title: String(key: "bookings.details.price.travelerFees"), view: travelerFeesValueLabel)
	private lazy var travelerFeesValueLabel:RU_Label = .init()
	private lazy var travelerTouristTaxValueLabel:RU_Label = .init()
	private lazy var travelerTotalValueLabel:RU_Label = .init()
	private lazy var hostSectionTitleStackView:RU_Section_StackView = {
		
		let backgroundView:RU_Booking_Price_View = .init()
		$0.insertSubview(backgroundView, at: 0)
		backgroundView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins = .init(2*UI.Margins)
		$0.layoutMargins.bottom = UI.Margins
		$0.title = String(key: "bookings.details.hostRevenue.section.title")
		$0.addArrangedSubview(createRow(icon: "moon.fill", title: String(key: "bookings.details.price.nights"), view: hostNightsValueLabel))
		$0.addArrangedSubview(hostDiscountSectionRowStackView)
		$0.addArrangedSubview(hostCleaningSectionRowStackView)
		$0.addArrangedSubview(createRow(icon: "minus", title: String(key: "bookings.details.price.hostFees"), view: hostFeesValueLabel))
		$0.addArrangedSubview(createRow(icon: "equal.circle.fill", title: String(key: "bookings.details.price.hostTotal"), view: hostTotalValueLabel, isHighlighted: true))
		
		return $0
		
	}(RU_Section_StackView())
	private lazy var hostNightsValueLabel:RU_Label = .init()
	private lazy var hostDiscountSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "percent", title: String(key: "bookings.details.price.discount"), view: hostDiscountValueLabel)
	private lazy var hostDiscountValueLabel:RU_Label = .init()
	private lazy var hostCleaningSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "sparkles", title: String(key: "bookings.details.price.cleaning"), view: hostCleaningValueLabel)
	private lazy var hostCleaningValueLabel:RU_Label = .init()
	private lazy var hostFeesValueLabel:RU_Label = .init()
	private lazy var hostTotalValueLabel:RU_Label = .init()
	
	public override func loadView() {
		
		super.loadView()
		
		contentView.addSubview(contentScrollView)
		contentScrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		let datesSectionTitleStackView:RU_Section_StackView = .init()
		datesSectionTitleStackView.title = String(key: "bookings.details.dates.section.title")
		let platformStackView:RU_StackView = .init(arrangedSubviews: [.init(),platformLabel])
		platformStackView.axis = .horizontal
		let statusStackView:RU_StackView = .init(arrangedSubviews: [.init(),statusLabel])
		statusStackView.axis = .horizontal
		datesSectionTitleStackView.addArrangedSubview(createRow(icon: "checkmark.circle.fill", title: String(key: "bookings.details.status"), view: statusStackView))
		datesSectionTitleStackView.addArrangedSubview(createRow(icon: "app.badge.fill", title: String(key: "bookings.details.platform"), view: platformStackView))
		datesSectionTitleStackView.addArrangedSubview(createRow(icon: "airplane.arrival", title: String(key: "bookings.details.dates.start"), view: datesStartValueLabel))
		datesSectionTitleStackView.addArrangedSubview(createRow(icon: "airplane.departure", title: String(key: "bookings.details.dates.end"), view: datesEndValueLabel))
		datesSectionTitleStackView.addArrangedSubview(createRow(icon: "moon.fill", title: String(key: "bookings.details.nights.label"), view: nightsValueLabel))
		contentStackView.addArrangedSubview(datesSectionTitleStackView)
		
		let travelersSectionTitleStackView:RU_Section_StackView = .init()
		travelersSectionTitleStackView.title = String(key: "bookings.details.travelers.section.title")
		travelersSectionTitleStackView.addArrangedSubview(createRow(icon: "person.fill", title: String(key: "bookings.create.travelers.adults"), view: adultsValueLabel))
		travelersSectionTitleStackView.addArrangedSubview(childrenSectionRowStackView)
		travelersSectionTitleStackView.addArrangedSubview(babiesSectionRowStackView)
		contentStackView.addArrangedSubview(travelersSectionTitleStackView)
		
		contentStackView.addArrangedSubview(configurationSectionStackView)
		contentStackView.addArrangedSubview(pricesStackView)
	}
	
	private func createRow(icon: String, title: String, view: UIView, isHighlighted: Bool = false) -> RU_Section_Row_StackView {
		
		let stackView:RU_Section_Row_StackView = .init()
		stackView.image = UIImage(systemName: icon)
		stackView.title = title
		stackView.view = view
		stackView.isHighlighted = isHighlighted
		return stackView
	}
}

//import UIKit
//import SnapKit
//
//public class RU_Bookings_Detail_ViewController : RU_ViewController {
//	
//	public var booking:RU_Booking? {
//		
//		didSet {
//			
//			guard let booking else { return }
//
//			title = booking.classified?.name ?? String(key: "bookings.details.title")
//
//				// Header
//			platformLabel.platform = booking.platform
//			statusLabel.booking = booking
//			
//				// Dates
//			let dayFormatter = DateFormatter()
//			dayFormatter.dateFormat = "dd"
//			let monthFormatter = DateFormatter()
//			monthFormatter.dateFormat = "MMM"
//			monthFormatter.locale = Locale(identifier: "fr_FR")
//			
//			startDayLabel.text = dayFormatter.string(from: booking.dates.start)
//			startMonthLabel.text = monthFormatter.string(from: booking.dates.start).uppercased()
//			endDayLabel.text = dayFormatter.string(from: booking.dates.end)
//			endMonthLabel.text = monthFormatter.string(from: booking.dates.end).uppercased()
//			
//			let calendar = Calendar.current
//			let startDay = calendar.startOfDay(for: booking.dates.start)
//			let endDay = calendar.startOfDay(for: booking.dates.end)
//			let nights = calendar.dateComponents([.day], from: startDay, to: endDay).day ?? 0
//			let nightsString = nights > 1 ? String(key: "bookings.details.nights") : String(key: "bookings.details.night")
//			nightsLabel.text = "\(nights) \(nightsString)"
//			
//				// Travelers
//			let totalTravelers = (booking.travelers.adults ?? 0) + (booking.travelers.children ?? 0) + (booking.travelers.babies ?? 0)
//			travelersCountLabel.text = "\(totalTravelers)"
//			
//			var travelersDetails:[String] = []
//			if let adults = booking.travelers.adults, adults > 0 {
//				travelersDetails.append("\(adults) adulte\(adults > 1 ? "s" : "")")
//			}
//			if let children = booking.travelers.children, children > 0 {
//				travelersDetails.append("\(children) enfant\(children > 1 ? "s" : "")")
//			}
//			if let babies = booking.travelers.babies, babies > 0 {
//				travelersDetails.append("\(babies) bébé\(babies > 1 ? "s" : "")")
//			}
//			travelersDetailLabel.text = travelersDetails.joined(separator: "\n")
//			
//				// Configuration
//			let totalBeds = (booking.beds.doubles ?? 0) + (booking.beds.singles ?? 0) + (booking.beds.babies ?? 0)
//			bedsCountLabel.text = "\(totalBeds)"
//			
//			var bedsDetails:[String] = []
//			if let doubles = booking.beds.doubles, doubles > 0 {
//				bedsDetails.append("\(doubles) lit\(doubles > 1 ? "s" : "") double\(doubles > 1 ? "s" : "")")
//			}
//			if let singles = booking.beds.singles, singles > 0 {
//				bedsDetails.append("\(singles) lit\(singles > 1 ? "s" : "") simple\(singles > 1 ? "s" : "")")
//			}
//			if let babies = booking.beds.babies, babies > 0 {
//				bedsDetails.append("\(babies) lit\(babies > 1 ? "s" : "") bébé")
//			}
//			
//			if bedsDetails.isEmpty {
//				configurationCard.isHidden = true
//			}
//			else {
//				configurationCard.isHidden = false
//				bedsDetailLabel.text = bedsDetails.joined(separator: "\n")
//			}
//			
//				// Prix
//			if let calculation = booking.platform?.calculatePrice(for: booking) {
//				
//				travelerSectionTitleStackView.subtitle = booking.platform?.type?.priceFormulaTraveler
//				travelerNightsValueLabel.text = String(format: "%.2f €", calculation.totalNights)
//				
//				travelerCleaningSectionRowStackView.isHidden = calculation.cleaning == 0
//				travelerCleaningValueLabel.text = String(format: "%.2f €", calculation.cleaning)
//				
//				travelerFeesSectionRowStackView.isHidden = calculation.travelerFees == 0
//				travelerFeesValueLabel.text = String(format: "%.2f €", calculation.travelerFees)
//				
//				travelerTouristTaxValueLabel.text = String(format: "%.2f €", calculation.touristTax)
//				travelerTotalValueLabel.text = String(format: "%.2f €", calculation.travelerTotal)
//				
//				hostSectionTitleStackView.subtitle = booking.platform?.type?.priceFormulaHost
//				hostNightsValueLabel.text = String(format: "%.2f €", calculation.totalNights)
//				
//				hostCleaningSectionRowStackView.isHidden = calculation.cleaning == 0
//				hostCleaningValueLabel.text = String(format: "%.2f €", calculation.cleaning)
//				
//				hostFeesValueLabel.text = String(format: "%.2f €", calculation.hostFees)
//				hostTotalValueLabel.text = String(format: "%.2f €", calculation.hostTotal)
//				
//				pricesStackView.isHidden = false
//			}
//			else {
//				
//				pricesStackView.isHidden = true
//			}
//		}
//	}
//	
//		// MARK: - Header
//	private lazy var statusLabel:RU_Booking_Status_Label = .init()
//	private lazy var platformLabel:RU_Platform_Label = .init()
//
//		// MARK: - Dates Card
//	private lazy var startDayLabel:RU_Label = {
//		
//		$0.font = Fonts.Content.Title.H1.withSize(42)
//		$0.textAlignment = .center
//		return $0
//		
//	}(RU_Label())
//	private lazy var startMonthLabel:RU_Label = {
//		
//		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size - 2)
//		$0.textColor = Colors.Primary
//		$0.textAlignment = .center
//		return $0
//		
//	}(RU_Label())
//	private lazy var endDayLabel:RU_Label = {
//		
//		$0.font = Fonts.Content.Title.H1.withSize(42)
//		$0.textAlignment = .center
//		return $0
//		
//	}(RU_Label())
//	private lazy var endMonthLabel:RU_Label = {
//		
//		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size - 2)
//		$0.textColor = Colors.Primary
//		$0.textAlignment = .center
//		return $0
//		
//	}(RU_Label())
//	private lazy var nightsLabel:RU_Label = {
//		
//		$0.font = Fonts.Content.Text.Bold
//		$0.textAlignment = .center
//		$0.backgroundColor = Colors.Primary
//		$0.textColor = .white
//		$0.contentInsets = .init(horizontal: UI.Margins, vertical: UI.Margins/2)
//		$0.layer.cornerRadius = UI.CornerRadius
//		return $0
//		
//	}(RU_Label())
//	
//		// MARK: - Travelers Card
//	private lazy var travelersCountLabel:RU_Label = {
//		
//		$0.font = Fonts.Content.Title.H1.withSize(42)
//		$0.textAlignment = .center
//		return $0
//		
//	}(RU_Label())
//	private lazy var travelersDetailLabel:RU_Label = {
//		
//		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size - 2)
//		$0.textColor = Colors.Content.Text.withAlphaComponent(0.7)
//		$0.textAlignment = .center
//		$0.numberOfLines = 0
//		return $0
//		
//	}(RU_Label())
//	
//		// MARK: - Configuration Card
//	private lazy var configurationCard:UIView = .init()
//	private lazy var bedsCountLabel:RU_Label = {
//		
//		$0.font = Fonts.Content.Title.H1.withSize(42)
//		$0.textAlignment = .center
//		return $0
//		
//	}(RU_Label())
//	private lazy var bedsDetailLabel:RU_Label = {
//		
//		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size - 2)
//		$0.textColor = Colors.Content.Text.withAlphaComponent(0.7)
//		$0.textAlignment = .center
//		$0.numberOfLines = 0
//		return $0
//		
//	}(RU_Label())
//	
//		// MARK: - Content
//	private lazy var contentScrollView:RU_ScrollView = {
//		
//		$0.isCentered = false
//		$0.addSubview(contentStackView)
//		contentStackView.snp.makeConstraints { make in
//			make.top.bottom.left.equalToSuperview()
//			make.right.width.equalToSuperview()
//		}
//		return $0
//		
//	}(RU_ScrollView())
//	private lazy var contentStackView:RU_StackView = {
//		
//		$0.axis = .vertical
//		$0.spacing = 2*UI.Margins
//		$0.isLayoutMarginsRelativeArrangement = true
//		$0.layoutMargins = .init(UI.Margins)
//		return $0
//		
//	}(RU_StackView())
//	
//		// MARK: - Prices
//	private lazy var pricesStackView:RU_StackView = {
//		
//		$0.axis = .vertical
//		$0.spacing = 2*UI.Margins
//		return $0
//		
//	}(RU_StackView(arrangedSubviews: [travelerSectionTitleStackView, hostSectionTitleStackView]))
//	private lazy var travelerSectionTitleStackView:RU_Section_StackView = {
//		
//		let backgroundView:RU_Booking_Price_View = .init()
//		$0.insertSubview(backgroundView, at: 0)
//		backgroundView.snp.makeConstraints { make in
//			make.edges.equalToSuperview()
//		}
//		
//		$0.isLayoutMarginsRelativeArrangement = true
//		$0.layoutMargins = .init(2*UI.Margins)
//		$0.layoutMargins.bottom = UI.Margins
//		$0.title = String(key: "bookings.details.travelerPrice.section.title")
//		$0.addArrangedSubview(createRow(icon: "moon.fill", title: String(key: "bookings.details.price.nights"), view: travelerNightsValueLabel))
//		$0.addArrangedSubview(travelerCleaningSectionRowStackView)
//		$0.addArrangedSubview(travelerFeesSectionRowStackView)
//		$0.addArrangedSubview(createRow(icon: "building.columns.fill", title: String(key: "bookings.details.price.touristTax"), view: travelerTouristTaxValueLabel))
//		$0.addArrangedSubview(createRow(icon: "equal.circle.fill", title: String(key: "bookings.details.price.travelerTotal"), view: travelerTotalValueLabel, isHighlighted: true))
//		
//		return $0
//		
//	}(RU_Section_StackView())
//	private lazy var travelerNightsValueLabel:RU_Label = .init()
//	private lazy var travelerCleaningSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "sparkles", title: String(key: "bookings.details.price.cleaning"), view: travelerCleaningValueLabel)
//	private lazy var travelerCleaningValueLabel:RU_Label = .init()
//	private lazy var travelerFeesSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "plus", title: String(key: "bookings.details.price.travelerFees"), view: travelerFeesValueLabel)
//	private lazy var travelerFeesValueLabel:RU_Label = .init()
//	private lazy var travelerTouristTaxValueLabel:RU_Label = .init()
//	private lazy var travelerTotalValueLabel:RU_Label = .init()
//	private lazy var hostSectionTitleStackView:RU_Section_StackView = {
//		
//		let backgroundView:RU_Booking_Price_View = .init()
//		$0.insertSubview(backgroundView, at: 0)
//		backgroundView.snp.makeConstraints { make in
//			make.edges.equalToSuperview()
//		}
//		
//		$0.isLayoutMarginsRelativeArrangement = true
//		$0.layoutMargins = .init(2*UI.Margins)
//		$0.layoutMargins.bottom = UI.Margins
//		$0.title = String(key: "bookings.details.hostRevenue.section.title")
//		$0.addArrangedSubview(createRow(icon: "moon.fill", title: String(key: "bookings.details.price.nights"), view: hostNightsValueLabel))
//		$0.addArrangedSubview(hostCleaningSectionRowStackView)
//		$0.addArrangedSubview(createRow(icon: "minus", title: String(key: "bookings.details.price.hostFees"), view: hostFeesValueLabel))
//		$0.addArrangedSubview(createRow(icon: "equal.circle.fill", title: String(key: "bookings.details.price.hostTotal"), view: hostTotalValueLabel, isHighlighted: true))
//		
//		return $0
//		
//	}(RU_Section_StackView())
//	private lazy var hostNightsValueLabel:RU_Label = .init()
//	private lazy var hostCleaningSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "sparkles", title: String(key: "bookings.details.price.cleaning"), view: hostCleaningValueLabel)
//	private lazy var hostCleaningValueLabel:RU_Label = .init()
//	private lazy var hostFeesValueLabel:RU_Label = .init()
//	private lazy var hostTotalValueLabel:RU_Label = .init()
//	
//	public override func loadView() {
//		
//		super.loadView()
//		
//		title = String(key: "bookings.details.title")
//		
//		contentView.addSubview(contentScrollView)
//		contentScrollView.snp.makeConstraints { make in
//			make.edges.equalToSuperview()
//		}
//		
//			// MARK: - Header
//		let headerStackView:RU_StackView = .init(arrangedSubviews: [statusLabel, platformLabel])
//		headerStackView.axis = .horizontal
//		headerStackView.spacing = UI.Margins/2
//		headerStackView.alignment = .center
//		contentStackView.addArrangedSubview(headerStackView)
//
//			// MARK: - Dates Card
//		let startDateStackView:RU_StackView = .init(arrangedSubviews: [startDayLabel, startMonthLabel])
//		startDateStackView.axis = .vertical
//		startDateStackView.spacing = 2
//		startDateStackView.alignment = .center
//		
//		let endDateStackView:RU_StackView = .init(arrangedSubviews: [endDayLabel, endMonthLabel])
//		endDateStackView.axis = .vertical
//		endDateStackView.spacing = 2
//		endDateStackView.alignment = .center
//		
//		let arrowImageView:UIImageView = .init(image: UIImage(systemName: "arrow.right"))
//		arrowImageView.tintColor = Colors.Content.Text.withAlphaComponent(0.3)
//		arrowImageView.contentMode = .scaleAspectFit
//		arrowImageView.snp.makeConstraints { make in
//			make.size.equalTo(24)
//		}
//		
//		let datesRowStackView:RU_StackView = .init(arrangedSubviews: [startDateStackView, arrowImageView, endDateStackView])
//		datesRowStackView.axis = .horizontal
//		datesRowStackView.spacing = UI.Margins * 1.5
//		datesRowStackView.alignment = .center
//		
//		let datesStackView:RU_StackView = .init(arrangedSubviews: [datesRowStackView, nightsLabel])
//		datesStackView.axis = .vertical
//		datesStackView.spacing = UI.Margins
//		datesStackView.alignment = .center
//		
//		let datesCard = createCard(content: datesStackView, icon: "calendar")
//		contentStackView.addArrangedSubview(datesCard)
//		
//			// MARK: - Travelers & Config Row
//		let personIconView:UIImageView = .init(image: UIImage(systemName: "person.2.fill"))
//		personIconView.tintColor = Colors.Primary
//		personIconView.contentMode = .scaleAspectFit
//		personIconView.snp.makeConstraints { make in
//			make.size.equalTo(28)
//		}
//		
//		let travelersStackView:RU_StackView = .init(arrangedSubviews: [personIconView, travelersCountLabel, travelersDetailLabel])
//		travelersStackView.axis = .vertical
//		travelersStackView.spacing = UI.Margins/2
//		travelersStackView.alignment = .center
//		
//		let travelersCard = createCard(content: travelersStackView, icon: nil)
//		
//		let bedIconView:UIImageView = .init(image: UIImage(systemName: "bed.double.fill"))
//		bedIconView.tintColor = Colors.Primary
//		bedIconView.contentMode = .scaleAspectFit
//		bedIconView.snp.makeConstraints { make in
//			make.size.equalTo(28)
//		}
//		
//		let configStackView:RU_StackView = .init(arrangedSubviews: [bedIconView, bedsCountLabel, bedsDetailLabel])
//		configStackView.axis = .vertical
//		configStackView.spacing = UI.Margins/2
//		configStackView.alignment = .center
//		
//		configurationCard = createCard(content: configStackView, icon: nil)
//		
//		let cardsRowStackView:RU_StackView = .init(arrangedSubviews: [travelersCard, configurationCard])
//		cardsRowStackView.axis = .horizontal
//		cardsRowStackView.spacing = UI.Margins
//		cardsRowStackView.distribution = .fillEqually
//		contentStackView.addArrangedSubview(cardsRowStackView)
//		
//			// MARK: - Prices
//		contentStackView.addArrangedSubview(pricesStackView)
//	}
//	
//	private func createCard(content: UIView, icon: String?) -> UIView {
//		
//		let card:UIView = .init()
//		card.backgroundColor = Colors.Background.View
//		card.layer.cornerRadius = UI.CornerRadius * 1.5
//		card.layer.borderWidth = 1
//		card.layer.borderColor = Colors.Content.Text.withAlphaComponent(0.08).cgColor
//		
//			// Shadow
//		card.layer.shadowColor = UIColor.black.cgColor
//		card.layer.shadowOffset = CGSize(width: 0, height: 4)
//		card.layer.shadowOpacity = 0.08
//		card.layer.shadowRadius = 12
//		
//		card.addSubview(content)
//		content.snp.makeConstraints { make in
//			make.edges.equalToSuperview().inset(UI.Margins * 1.5)
//		}
//		
//		if let icon {
//			
//			let iconContainer:UIView = .init()
//			iconContainer.backgroundColor = Colors.Primary.withAlphaComponent(0.1)
//			iconContainer.layer.cornerRadius = 16
//			
//			let iconImageView:UIImageView = .init(image: UIImage(systemName: icon))
//			iconImageView.tintColor = Colors.Primary
//			iconImageView.contentMode = .scaleAspectFit
//			
//			iconContainer.addSubview(iconImageView)
//			iconImageView.snp.makeConstraints { make in
//				make.center.equalToSuperview()
//				make.size.equalTo(16)
//			}
//			
//			card.addSubview(iconContainer)
//			iconContainer.snp.makeConstraints { make in
//				make.top.right.equalToSuperview().inset(UI.Margins)
//				make.size.equalTo(32)
//			}
//		}
//		
//		return card
//	}
//	
//	private func createRow(icon: String, title: String, view: UIView, isHighlighted: Bool = false) -> RU_Section_Row_StackView {
//		
//		let stackView:RU_Section_Row_StackView = .init()
//		stackView.image = UIImage(systemName: icon)
//		stackView.title = title
//		stackView.view = view
//		stackView.isHighlighted = isHighlighted
//		return stackView
//	}
//}
