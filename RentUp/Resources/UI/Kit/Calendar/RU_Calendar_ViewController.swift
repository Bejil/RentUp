//
//  RU_Calendar_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 30/01/2026.
//

import UIKit
import HorizonCalendar
import SnapKit

public class RU_Calendar_ViewController: RU_ViewController {
	
	// MARK: - Properties
	
	public var startDate: Date? {
		didSet {
			updateCalendar()
			updateDatesLabel()
            
            if let startDate {
                
                calendarView.scroll(toMonthContaining: startDate, scrollPosition: .centered, animated: false)
            }
		}
	}
	
	public var endDate: Date? {
		didSet {
			updateCalendar()
			updateDatesLabel()
		}
	}
	
	public var didSelectRange: ((Date, Date) -> Void)?
	
	public var minimumDate: Date? {
		didSet {
			updateCalendar()
		}
	}
	
	/// Réservations existantes à afficher et bloquer
	public var existingBookings: [RU_Booking]? {
		didSet {
			updateCalendar()
		}
	}
	
	/// Réservation en cours d'édition (à exclure des blocages)
	public var currentBooking: RU_Booking?
	
	private var isSelectingEndDate: Bool = false
	
	private lazy var datesLabel: RU_Label = {
		
		$0.font = Fonts.Content.Title.H4
		$0.textAlignment = .center
		$0.numberOfLines = 0
		return $0
		
	}(RU_Label())
	
	private lazy var calendarView: CalendarView = {
		
		let calendarView = CalendarView(initialContent: makeContent())
		calendarView.backgroundColor = .clear
		return calendarView
	}()
	
	private lazy var validateButton: RU_Button = {
		
		$0.isEnabled = false
		$0.image = UIImage(systemName: "checkmark.circle")
		return $0
		
	}(RU_Button(String(key: "bookings.calendar.validate")) { [weak self] _ in
		
		guard let self, let startDate = self.startDate, let endDate = self.endDate else { return }
		
		self.didSelectRange?(startDate, endDate)
		self.dismiss()
	})
	
	// MARK: - Lifecycle
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		title = String(key: "bookings.calendar.title")
		
		view.addSubview(datesLabel)
		view.addSubview(calendarView)
		
		calendarView.daySelectionHandler = { [weak self] day in
			self?.handleDaySelection(day)
		}
		
		updateDatesLabel()
        
        let bottomButtonsVisualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect(style: .light))
        bottomButtonsVisualEffectView.contentView.addSubview(validateButton)
        validateButton.snp.makeConstraints { make in
            make.edges.equalTo(bottomButtonsVisualEffectView.safeAreaLayoutGuide).inset(UI.Margins)
        }
        bottomButtonsVisualEffectView.contentView.addLine(position: .top)
        view.addSubview(bottomButtonsVisualEffectView)
        
        datesLabel.snp.makeConstraints { make in
            make.top.right.left.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
            make.bottom.equalTo(calendarView.snp.top).offset(-UI.Margins)
        }
        
        calendarView.snp.makeConstraints { make in
            make.right.left.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
            make.top.equalTo(calendarView.snp.top).inset(UI.Margins)
            make.bottom.equalTo(bottomButtonsVisualEffectView.snp.top).offset(-UI.Margins)
        }
        
        bottomButtonsVisualEffectView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(UI.Margins)
            make.right.left.equalToSuperview()
            make.top.equalTo(calendarView.snp.bottom).inset(UI.Margins)
        }
        
        calendarView.scroll(toMonthContaining: Date(), scrollPosition: .centered, animated: false)
	}
	
	// MARK: - Selection
	
	private func handleDaySelection(_ day: DayComponents) {
		
		let calendar = Calendar.current
		guard let selectedDate = calendar.date(from: DateComponents(year: day.month.year, month: day.month.month, day: day.day)) else { return }
		
		// Vérifier si la date est déjà réservée
		if isDateBooked(selectedDate) {
			return
		}
		
		// Si on n'a pas de date de début ou si on a les deux dates, on recommence
		if startDate == nil || (startDate != nil && endDate != nil) {
			startDate = selectedDate
			endDate = nil
			isSelectingEndDate = true
		}
		// Si on a une date de début et qu'on sélectionne la date de fin
		else if isSelectingEndDate {
			// La date de fin doit être après la date de début
			if selectedDate > startDate! {
				// Vérifier qu'il n'y a pas de réservation entre les deux dates
				if hasBookingBetween(startDate!, and: selectedDate) {
					// Si oui, recommencer avec cette date
					startDate = selectedDate
					endDate = nil
				}
				else {
					endDate = selectedDate
					isSelectingEndDate = false
				}
			}
			else {
				// Si on clique avant la date de début, on recommence avec cette date
				startDate = selectedDate
				endDate = nil
			}
		}
		
		validateButton.isEnabled = startDate != nil && endDate != nil
	}
	
	/// Vérifie si une date est déjà réservée sur la *même annonce* (même classified).
	/// Permet de créer une réservation sur les mêmes jours qu'une autre si elles n'ont pas la même classified.
	private func isDateBooked(_ date: Date) -> Bool {
		
		let calendar = Calendar.current
		let dayStart = calendar.startOfDay(for: date)
		guard let currentClassifiedId = currentBooking?.classified?.id else { return false }
		
		return existingBookings?.contains(where: { booking in
			if let current = currentBooking, booking.id == current.id { return false }
			guard booking.classified?.id == currentClassifiedId else { return false }
			let start = calendar.startOfDay(for: booking.dates.start)
			let end = calendar.startOfDay(for: booking.dates.end)
			return dayStart >= start && dayStart <= end
		}) ?? false
	}
	
	/// Vérifie s'il y a une réservation sur la *même annonce* entre deux dates.
	private func hasBookingBetween(_ start: Date, and end: Date) -> Bool {
		
		let calendar = Calendar.current
		let rangeStart = calendar.startOfDay(for: start)
		let rangeEnd = calendar.startOfDay(for: end)
		guard let currentClassifiedId = currentBooking?.classified?.id else { return false }
		
		return existingBookings?.contains(where: { booking in
			if let current = currentBooking, booking.id == current.id { return false }
			guard booking.classified?.id == currentClassifiedId else { return false }
			let bookingStart = calendar.startOfDay(for: booking.dates.start)
			let bookingEnd = calendar.startOfDay(for: booking.dates.end)
			return bookingStart <= rangeEnd && bookingEnd >= rangeStart
		}) ?? false
	}
	
	private func updateDatesLabel() {
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .long
		dateFormatter.locale = Locale(identifier: "fr_FR")
		
		if let startDate, let endDate {
			
			let startString = dateFormatter.string(from: startDate)
			let endString = dateFormatter.string(from: endDate)
			
			let calendar = Calendar.current
			let nights = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
			let nightsString = nights > 1 ? String(key: "bookings.details.nights") : String(key: "bookings.details.night")
			
			datesLabel.text = "\(startString) ➜ \(endString)\n\(nights) \(nightsString)"
		}
		else if let startDate {
			
			let startString = dateFormatter.string(from: startDate)
			datesLabel.text = "\(startString) ➜ ?"
		}
		else {
			
			datesLabel.text = String(key: "bookings.calendar.placeholder")
		}
	}
	
	private func updateCalendar() {
		
		calendarView.setContent(makeContent())
	}
	
	private func makeContent() -> CalendarViewContent {
		
		let calendar = Calendar.current
		
		// Permettre de remonter 2 ans dans le passé
		let referenceDate = minimumDate ?? calendar.date(byAdding: .year, value: -2, to: Date())!
		let startMonth = calendar.date(from: DateComponents(year: calendar.component(.year, from: referenceDate), month: calendar.component(.month, from: referenceDate)))!
		let endMonth = calendar.date(byAdding: .year, value: 4, to: startMonth)!
		
		let dateRanges: Set<ClosedRange<Date>>
		if let start = startDate, let end = endDate, start <= end {
			dateRanges = [start...end]
		}
		else {
			dateRanges = []
		}
		
		return CalendarViewContent(
			calendar: calendar,
			visibleDateRange: startMonth...endMonth,
			monthsLayout: .vertical(options: VerticalMonthsLayoutOptions())
		)
		.interMonthSpacing(24)
		.verticalDayMargin(8)
		.horizontalDayMargin(8)
		
		// Month header
		.monthHeaderItemProvider { month in
			let dateFormatter = DateFormatter()
			dateFormatter.locale = Locale(identifier: "fr_FR")
			dateFormatter.dateFormat = "MMMM yyyy"
			
			let monthDate = calendar.date(from: DateComponents(year: month.year, month: month.month))!
			let monthText = dateFormatter.string(from: monthDate).capitalized
			
			return CalendarItemModel<MonthHeaderView>(
				invariantViewProperties: .init(font: Fonts.Content.Title.H4, textColor: Colors.Content.Title),
				content: .init(text: monthText)
			)
		}
		
		// Day of week header
		.dayOfWeekItemProvider { _, dayOfWeek in
			let weekdaySymbols = ["L", "M", "M", "J", "V", "S", "D"]
			let text = weekdaySymbols[dayOfWeek]
			
			return CalendarItemModel<DayOfWeekView>(
				invariantViewProperties: .init(font: Fonts.Content.Text.Bold, textColor: Colors.Content.Text.withAlphaComponent(0.5)),
				content: .init(text: text)
			)
		}
		
		// Day item
		.dayItemProvider { [weak self] day in
			guard let self else {
				return CalendarItemModel<DayView>(
					invariantViewProperties: .init(),
					content: .init(day: day, isSelected: false, isInRange: false, isStartDate: false, isEndDate: false, isDisabled: false, isToday: false, existingBookings: [])
				)
			}
			
			let date = calendar.date(from: DateComponents(year: day.month.year, month: day.month.month, day: day.day))!
			let dayStart = calendar.startOfDay(for: date)
			let isDisabledByMinDate = self.minimumDate.map { date < calendar.startOfDay(for: $0) } ?? false
			
			// Réservations existantes ce jour (sauf la réservation en cours) — pour l’affichage des barres
			let bookingsForDay = self.existingBookings?.filter({ booking in
				if let current = self.currentBooking, booking.id == current.id { return false }
				let start = calendar.startOfDay(for: booking.dates.start)
				let end = calendar.startOfDay(for: booking.dates.end)
				return dayStart >= start && dayStart <= end
			}) ?? []
			// Même annonce (même classified) : on désactive le jour uniquement en cas de conflit sur la même classified
			let currentClassifiedId = self.currentBooking?.classified?.id
			let bookingsSameClassified = bookingsForDay.filter { $0.classified?.id == currentClassifiedId }
			
			let existingBookingInfos: [ExistingBookingInfo] = bookingsForDay.map { booking in
				ExistingBookingInfo(
					isStartDate: calendar.isDate(date, inSameDayAs: booking.dates.start),
					isEndDate: calendar.isDate(date, inSameDayAs: booking.dates.end),
					color: booking.platform?.type?.backgroundColor ?? Colors.Primary
				)
			}
			
			let isDisabled = isDisabledByMinDate || !bookingsSameClassified.isEmpty
			let isToday = calendar.isDateInToday(date)
			
			let isStartDate = self.startDate.map { calendar.isDate(date, inSameDayAs: $0) } ?? false
			let isEndDate = self.endDate.map { calendar.isDate(date, inSameDayAs: $0) } ?? false
			let isSelected = isStartDate || isEndDate
			
			var isInRange = false
			if let start = self.startDate, let end = self.endDate {
				isInRange = date > start && date < end
			}
			
			return CalendarItemModel<DayView>(
				invariantViewProperties: .init(),
				content: .init(day: day, isSelected: isSelected, isInRange: isInRange, isStartDate: isStartDate, isEndDate: isEndDate, isDisabled: isDisabled, isToday: isToday, existingBookings: existingBookingInfos)
			)
		}
		
		// Day range item (background for the range)
		.dayRangeItemProvider(for: dateRanges) { dayRangeLayoutContext in
			
			return CalendarItemModel<DayRangeView>(
				invariantViewProperties: .init(),
				content: .init(framesOfDaysToHighlight: dayRangeLayoutContext.daysAndFrames.map { $0.frame })
			)
		}
	}
}

// MARK: - Month Header View

private struct MonthHeaderViewProperties: Hashable {
	let font: UIFont
	let textColor: UIColor
}

private struct MonthHeaderViewContent: Equatable {
	let text: String
}

private final class MonthHeaderView: UIView, CalendarItemViewRepresentable {
	
	typealias InvariantViewProperties = MonthHeaderViewProperties
	typealias Content = MonthHeaderViewContent
	
	private let label = UILabel()
	
	init() {
		super.init(frame: .zero)
		
		addSubview(label)
		label.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	static func makeView(withInvariantViewProperties invariantViewProperties: MonthHeaderViewProperties) -> MonthHeaderView {
		let view = MonthHeaderView()
		view.label.font = invariantViewProperties.font
		view.label.textColor = invariantViewProperties.textColor
		return view
	}
	
	static func setContent(_ content: MonthHeaderViewContent, on view: MonthHeaderView) {
		view.label.text = content.text
	}
}

// MARK: - Day of Week View

private struct DayOfWeekViewProperties: Hashable {
	let font: UIFont
	let textColor: UIColor
}

private struct DayOfWeekViewContent: Equatable {
	let text: String
}

private final class DayOfWeekView: UIView, CalendarItemViewRepresentable {
	
	typealias InvariantViewProperties = DayOfWeekViewProperties
	typealias Content = DayOfWeekViewContent
	
	private let label = UILabel()
	
	init() {
		super.init(frame: .zero)
		
		label.textAlignment = .center
		addSubview(label)
		label.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	static func makeView(withInvariantViewProperties invariantViewProperties: DayOfWeekViewProperties) -> DayOfWeekView {
		let view = DayOfWeekView()
		view.label.font = invariantViewProperties.font
		view.label.textColor = invariantViewProperties.textColor
		return view
	}
	
	static func setContent(_ content: DayOfWeekViewContent, on view: DayOfWeekView) {
		view.label.text = content.text
	}
}

// MARK: - Existing Booking Info

private struct ExistingBookingInfo: Equatable {
	let isStartDate: Bool
	let isEndDate: Bool
	let color: UIColor
	
	static func == (lhs: ExistingBookingInfo, rhs: ExistingBookingInfo) -> Bool {
		return lhs.isStartDate == rhs.isStartDate && lhs.isEndDate == rhs.isEndDate
	}
}

// MARK: - Day View

private struct DayViewProperties: Hashable {}

private struct DayViewContent: Equatable {
	let day: DayComponents
	let isSelected: Bool
	let isInRange: Bool
	let isStartDate: Bool
	let isEndDate: Bool
	let isDisabled: Bool
	let isToday: Bool
	let existingBookings: [ExistingBookingInfo]
	
	static func == (lhs: DayViewContent, rhs: DayViewContent) -> Bool {
		return lhs.day == rhs.day &&
			lhs.isSelected == rhs.isSelected &&
			lhs.isInRange == rhs.isInRange &&
			lhs.isStartDate == rhs.isStartDate &&
			lhs.isEndDate == rhs.isEndDate &&
			lhs.isDisabled == rhs.isDisabled &&
			lhs.isToday == rhs.isToday &&
			lhs.existingBookings == rhs.existingBookings
	}
}

private final class DayView: UIView, CalendarItemViewRepresentable {
	
	typealias InvariantViewProperties = DayViewProperties
	typealias Content = DayViewContent
	
	private let label = UILabel()
	private let backgroundCircle = UIView()
	private let todayIndicator = UIView()
	private let barsStackView = UIStackView()
	private var barViews: [UIView] = []
	
	init() {
		super.init(frame: .zero)
		
		backgroundCircle.layer.cornerRadius = 20
		addSubview(backgroundCircle)
		backgroundCircle.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.size.equalTo(40)
		}
		
		// Indicateur pour aujourd'hui (petit cercle sous le numéro)
		todayIndicator.backgroundColor = Colors.Primary
		todayIndicator.layer.cornerRadius = 3
		todayIndicator.isHidden = true
		addSubview(todayIndicator)
		todayIndicator.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().offset(12)
			make.size.equalTo(6)
		}
		
		// Stack view pour les barres de réservation existantes
		barsStackView.axis = .vertical
		barsStackView.spacing = 2
		barsStackView.distribution = .fillEqually
		addSubview(barsStackView)
		barsStackView.snp.makeConstraints { make in
			make.left.right.equalToSuperview()
			make.bottom.equalToSuperview().offset(-2)
			make.height.equalTo(10)
		}
		
		label.textAlignment = .center
		label.font = Fonts.Content.Text.Regular
		addSubview(label)
		label.snp.makeConstraints { make in
			make.top.left.right.equalToSuperview()
			make.bottom.equalTo(barsStackView.snp.top).offset(-1)
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	static func makeView(withInvariantViewProperties invariantViewProperties: DayViewProperties) -> DayView {
		return DayView()
	}
	
	static func setContent(_ content: DayViewContent, on view: DayView) {
		view.label.text = "\(content.day.day)"
		
		// Supprimer les anciennes barres
		view.barViews.forEach { $0.removeFromSuperview() }
		view.barViews.removeAll()
		
		// Afficher les barres des réservations existantes
		if content.existingBookings.isEmpty {
			view.barsStackView.isHidden = true
		}
		else {
			view.barsStackView.isHidden = false
			
			let barHeight = max(Int(UI.Margins)/3, Int(UI.Margins) / content.existingBookings.count)
			view.barsStackView.snp.updateConstraints { make in
				make.height.equalTo(content.existingBookings.count * barHeight + (content.existingBookings.count - 1) * 2)
			}
			
			for booking in content.existingBookings {
				let bar = UIView()
				bar.backgroundColor = booking.color
				bar.layer.cornerRadius = CGFloat(barHeight) / 2
				
				var corners: CACornerMask = []
				if booking.isStartDate {
					corners.insert(.layerMinXMinYCorner)
					corners.insert(.layerMinXMaxYCorner)
				}
				if booking.isEndDate {
					corners.insert(.layerMaxXMinYCorner)
					corners.insert(.layerMaxXMaxYCorner)
				}
				bar.layer.maskedCorners = corners
				
				// Le trait commence/finit à la moitié du jour (centre du jour)
				let container = UIView()
				container.addSubview(bar)
				bar.snp.makeConstraints { make in
					if booking.isStartDate && !booking.isEndDate {
						make.left.equalTo(container.snp.centerX)
						make.right.equalToSuperview()
					} else if booking.isEndDate && !booking.isStartDate {
						make.left.equalToSuperview()
						make.right.equalTo(container.snp.centerX)
					} else if booking.isStartDate && booking.isEndDate {
						make.centerX.equalToSuperview()
						make.width.equalTo(container.snp.width).multipliedBy(0.08)
					} else {
						make.left.right.equalToSuperview()
					}
					make.top.bottom.equalToSuperview()
				}
				
				view.barsStackView.addArrangedSubview(container)
				view.barViews.append(container)
			}
		}
		
		// Indicateur d'aujourd'hui
		view.todayIndicator.isHidden = !content.isToday || content.isSelected
		
		// Style du jour
		if content.isDisabled {
			view.label.textColor = Colors.Content.Text.withAlphaComponent(0.3)
			view.label.font = Fonts.Content.Text.Regular
			view.backgroundCircle.backgroundColor = .clear
			view.isUserInteractionEnabled = false
		}
		else if content.isSelected {
			view.label.textColor = .white
			view.label.font = Fonts.Content.Text.Bold
			view.backgroundCircle.backgroundColor = Colors.Primary
			view.isUserInteractionEnabled = true
		}
		else if content.isInRange {
			view.label.textColor = Colors.Primary
			view.label.font = Fonts.Content.Text.Regular
			view.backgroundCircle.backgroundColor = Colors.Primary.withAlphaComponent(0.1)
			view.isUserInteractionEnabled = true
		}
		else if content.isToday {
			view.label.textColor = Colors.Primary
			view.label.font = Fonts.Content.Text.Bold
			view.backgroundCircle.backgroundColor = .clear
			view.isUserInteractionEnabled = true
		}
		else {
			view.label.textColor = Colors.Content.Text
			view.label.font = Fonts.Content.Text.Regular
			view.backgroundCircle.backgroundColor = .clear
			view.isUserInteractionEnabled = true
		}
	}
}

// MARK: - Day Range View

private struct DayRangeViewProperties: Hashable {}

private struct DayRangeViewContent: Equatable {
	let framesOfDaysToHighlight: [CGRect]
}

private final class DayRangeView: UIView, CalendarItemViewRepresentable {
	
	typealias InvariantViewProperties = DayRangeViewProperties
	typealias Content = DayRangeViewContent
	
	private let rangeLayer = CAShapeLayer()
	
	init() {
		super.init(frame: .zero)
		
		rangeLayer.fillColor = Colors.Primary.withAlphaComponent(0.1).cgColor
		layer.addSublayer(rangeLayer)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		rangeLayer.frame = bounds
	}
	
	static func makeView(withInvariantViewProperties invariantViewProperties: DayRangeViewProperties) -> DayRangeView {
		return DayRangeView()
	}
	
	static func setContent(_ content: DayRangeViewContent, on view: DayRangeView) {
		let path = UIBezierPath()
		
		for frame in content.framesOfDaysToHighlight {
			let rect = frame.insetBy(dx: -4, dy: 4)
			path.append(UIBezierPath(roundedRect: rect, cornerRadius: 8))
		}
		
		view.rangeLayer.path = path.cgPath
	}
}
